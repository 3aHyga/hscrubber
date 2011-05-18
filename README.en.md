# HScrubber

HScrubber is HTML reha engine, and it allows filtering an input flow according to the special reha template that is formed as YAML-document.

# Reha
## Description of reha filter

Reha is set up as an YAML-document. The allowed in an output flow HTML tags is described at the top level of the document. The following level described allowed attributes of the specified tag, and also rule keys that controls the tag and ots containment. The keys, and its values are the following:

 * '_' declares that the containment of the tag will be cleaned up, if it matches to the specified rule;

 * '-' a tag will be removed, if its containment matches to the specified rule;

 * '^' containment of a tag will be added to containment of the parent tag, if containment of the tag matches to the specified rule, or if the rule isn't defined;

 * '%' sets the attributes order in the output file. The attributes is writing via comma.

The keys are ranged according to priority their analysing. The '@' symbol necessarily outruns each of the keys.

## Sample

Sample reha template is described as follows:

    ---
    html:
    body:
    p:
    i:
      @-: ^[.,:;!?\s]*$
    font:
      face:
      size:
      @%: size,face
      @-: ^\s+$
      @_: ^[.,:!?#]+$
    span:
      @^:
      @-: ^[.,:;!?\s]*$
    
Descriptions:

Tag 'i' hasn't allowable attributes, so them will be removed from an output stream. In case, the tag containment meets a remove rule, the tag will be absent in the output;


    <i id="i_id">Text</i> -> <i>Text</i>
    <font>Text<i>?</i></font> -> <font>Text</font>

Allowable attributes for the 'font' tag are 'face', and 'size'. In case, if the tag containment meets a remove rule, the tag will be absent in the output, and if meets a cleanup rule, the containment will be purged, and the attributes will be ordered as 'size', and then 'face';

    <font size="5" color="blue">Text</font> -> <font size="5">Text</font>
    <i>Text<font>  </font></i> -> <i>Text</i>
    <i>Text<font>??</font></i> -> <i>Text<font></font></i>
    <font face="Arial" size="5">Text</font> -> <font size="5" face="Arial">Text</font>

Tag 'span' hasn't allowable attributes, so them will be removed from an output stream. In case, the tag containment meets a remove rule, the tag will be absent in the output as it is. In other cases, its containment will be added to a parent tag.

    <span id="span_id">Text</span> -> <span>Text</span>
    <i>Text<span>?</span></i> -> <i>Text</i>

## Usage
There are 2 ways to use the package in ruby applications.

### Using the class instance method
Make a class instance, passing a reha to its initialize function. The reha must be loaded as a String, or an IO class. Then filter a HTML:

    рѣха = IO.read('.рѣха.yml.sample')
    hs = HScrubber.new(рѣха)

    html = IO.read('sample.html').gsub(/\r/, '')
    new_html = hs.scrub_html(html)

    puts html

### Using the class method
Thou art able to filter the HTML-document without a class instance creation. Do as follows:

    рѣха = IO.read('.рѣха.yml.sample')
    html = IO.read('sample.html').gsub(/\r/, '')
    new_html = HScrubber.scrub_html(html, рѣха)

    puts html

# Copyright
Copyright (c) 2011 Malo Skrylevo. See LICENSE for details.

