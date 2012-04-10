#!/usr/bin/ruby -KU
# encoding: utf-8

require 'rdoba/hashorder'
require 'yaml'
require 'hpricot'
require 'hscrubber/version'

class HScrubber
  def self.fix(str)
      str.unpack('C*').pack('U*') # Workaround to fix HPricot error
  end

  def self.scrub_special(elem)
      elem.each_child do |sub|
	  if sub.class == Hpricot::Text
	      sub.content = sub.content.gsub(/\x1F+/x, '')
	  end
      end
      false
  end

  def self.scrub_follower(elem)
      chnaged = false
      if elem.children and elem.children.size == 1
	  sub = elem.children[0]
	  if sub.class == Hpricot::Elem and elem.name == sub.name
	      html = sub.inner_html
	      if elem.raw_attributes
		  if sub.raw_attributes
		      elem.raw_attributes.merge! sub.raw_attributes
		  end
	      else
		  elem.raw_attributes = sub.raw_attributes
	      end
	      elem.children.delete(sub)
	      elem.inner_html += html
	      changed = true
	  end
      end
      changed
  end

  def self.scrub_children(elem, verility)
      changed = false
      old = nil
      elem.children.delete_if do |sub|
	  if sub.class == Hpricot::Elem and sub.parent == elem
	      self.scrub_elem(sub, verility)
	      if old and old.name == sub.name and
		      (old.raw_attributes.class == sub.raw_attributes.class and
		      old.raw_attributes.class == NilClass or
		      (old.raw_attributes.class == Hash and
		      old.raw_attributes == sub.raw_attributes))
		  sub_ch = sub.children
		  next unless sub_ch

		  idx = elem.children.index(sub)
		  
		  sub_ch.each do |x| x.parent = old end
		  if not old.children
		      old.children = sub_ch
		  elsif old.children.empty?
		      old.children.replace sub_ch
		  else
		      old.children.concat sub_ch
		  end
		  changed = true
		  true
	      elsif sub.children and sub.children.size != 0
		  idx = elem.children.index(sub)
		  old = sub
		  false
	      else
		  idx = elem.children.index(sub)
		  changed = true
		  true
	      end
	  else
	      old = nil
	      false
	  end
      end if elem.children

      changed
  end

  def self.process_specials(elem, verility)
      changed = nil
      repeat = true

      res = []

      if elem.children and not elem.children.empty?
	  elem.children.each do |sub|
	  repeat = false
	  sub_ch = nil
	  case sub.class.to_s
	  when 'Hpricot::Elem'
	      if verility.key? sub.name
		  new_attrs = {}
		  strip_tags = []
		  verility[sub.name].keys.sort do |x,y|
		      x == '@-' ? -1 : y == '@-' ? 1 : x <=> y
		  end.each do |key|
		      value = verility[sub.name][key]
		      # TODO match value to as regexp to attr value
		      case key
		      when '@-'
			  # delete elem if match to re
			  inner = sub.inner_html.gsub(/(\r\n|\n)/,' ')
			  if self.fix(inner) =~ /#{value}/
			      if elem.children.index(sub)
				  repeat = true; changed = true
			      end
			  end
		      when '@%'
			  (sub.raw_attributes.order = value.split(',').map do |x| x.strip end) if value
		      when '@^'
			  inner = sub.inner_html.gsub(/(\r\n|\n)/,' ')
			  unless value and self.fix(inner) !~ /#{value}/
			      sub_ch = sub.children
			      idx = elem.children.index(sub)
			      if idx and not sub_ch.empty?
				  sub_ch.each do |x| x.parent = elem end
				  elem.children[idx] = sub_ch
			      else
				  repeat = true; changed = true
			      end
			  end
		      when '@_'
			  # clear elem if match to re
			  inner = sub.inner_html.gsub(/(\r\n|\n)/,' ')
			  if self.fix(inner) =~ /#{value}/
			      new = Hpricot::Text.new("\x1F")
			      new.parent = sub
			      sub.children.replace [ new ]
			      changed = true
			  end
		      else
			  attr = sub.get_attribute(key)
			  new_attrs[key] = attr if attr
		      end
		  end if verility[sub.name]
		  if sub.raw_attributes != new_attrs
		      sub.raw_attributes = new_attrs
		      changed = true
		  end
	      else
		  repeat = true; changed = true
	      end
	  when 'Hpricot::Text'
	  else
	      repeat = true; changed = true
	  end if sub.parent == elem
	  if not repeat
	      if sub_ch
		  res.concat sub_ch
	      else
		  res << sub
	      end
	  end
	  end

	  elem.children.replace res
      end

      changed
  end

  def self.scrub_elem(elem, verility)
      while (
	  self.scrub_children(elem, verility) ||
	  self.process_specials(elem, verility) ||
	  self.scrub_follower(elem) ||
	  self.scrub_special(elem))
      end
  end

  def self.scrub_html(content, реха)
      return content unless реха
      реха = YAML.load( StringIO.new реха ) if реха.class == String
      doc = Hpricot(content)
      self.scrub_elem(doc, реха)
      doc.inner_html
  end

  def initialize(реха)
      @реха = YAML.load( StringIO.new реха ) if реха.class == String
  end

  def scrub_html(content)
      return content unless @реха
      doc = Hpricot(content)
      self.class.scrub_elem(doc, @реха)
      doc.inner_html
  end

end

