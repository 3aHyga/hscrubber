# HScrubber

HScrubber есть движокъ для прорѣшиванія HTML-документа. Онъ позволяетъ процѣдить содержимое входного потока очистивъ его отъ ненужныхъ предмѣтовъ на основѣ рѣхи, являющейся YAML-документомъ, по опредѣлённымъ правиламъ состаленнымъ.

HScrubber is HTML reha engine, and it allows filtering an input flow according to the special reha template that is formed as YAML-document.

# Рѣха (Reha)
## Объясненіе рѣхи (Description of reha filter)

Рѣха задаётся въ видѣ YAML-документа. На самомъ верхнемъ уровнѣ описываются мѣты (HTML tags), допустимыя въ выходномъ документѣ. Слѣдующій уровень задаётъ допустимыя свойства (attributes) для опредѣлённой мѣты, а также ключи, управляющія мѣтою и её содержимымъ. Возможныя ключи и их значенія суть такія:

 * '_' содержимое мѣты будетъ очищено, если оно подпадаетъ подъ заданное въ значеніи ключа правило;

 * '-' мѣта удаляется въ томъ случаѣ, если её содержимое подпадаетъ подъ заданное въ значеніи ключа правило;

 * '^' содержимое мѣты добавляется къ содержимому родителькой мѣты въ томъ случаѣ, если содержимое сей мѣты подпадаетъ подъ правило, или если правило не задано.

Ключи здѣ расположены въ порядкѣ первичности ихъ провѣрки. Каджый изъ нихъ обязательно предваряется символомъ '@'

Reha is set up as an YAML-document. The allowed in an output flow HTML tags is described at the top level of the document. The following level described allowed attributes of the specified tag, and also rule keys that controls the tag and ots containment. The keys, and its values are the following:

 * '_' declares that the containment of the tag will be cleaned up, if it matches to the specified rule;

 * '-' a tag will be removed, if its containment matches to the specified rule;

 * '^' containment of a tag will be added to containment of the parent tag, if containment of the tag matches to the specified rule, or if the rule isn't defined.

The keys are ranged according to priority their analysing. The '@' symbol necessarily outruns each of the keys.

## Примѣръ (Sample)
Примѣрный шаблонъ файла рѣхи представленъ нижѣ:

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
      @-: ^\s+$
      @_: ^[.,:!?#]+$
    span:
      @^:
      @-: ^[.,:;!?\s]*$
    
Поясненія:

Мѣта 'i' не имѣетъ допустимыхъ ключей, и они будутъ удалены изъ входного потока. Въ случаѣ, если содержимое мѣты удовлѣтворяетъ правилу удаления, на выходѣ сія мѣта будетъ отсутствовать. Примѣры:

    <i id="i_id">Text</i> -> <i>Text</i>
    <font>Text<i>?</i></font> -> <font>Text</font>

Допустимыми ключами для мѣты 'font' являются 'face' и 'size'. Въ случаѣ, если содержимое мѣты удовлѣтворяетъ правилу удаления, на выходѣ сія мѣта будетъ отсутствовать, а если правилу очищенія, то её содержимое станетъ порожнимъ. Примѣры:

    <font size="5" color="blue">Text</font> -> <font size="5">Text</font>
    <i>Text<font>  </font></i> -> <i>Text</i>
    <i>Text<font>??</font></i> -> <i>Text<font></font></i>

Допустимыя ключи для мѣты 'span' отсутствуютъ, и въ случаѣ ихъ обнаруженія въ входномъ потокѣ они будутъ вырѣзаны изъ него. Если содержимое мѣты удовлѣтворяетъ правилу удаления, на выходѣ сія мѣта будетъ отсутствовать какъ таковая. Въ остальныхъ же случаяхъ её содержимое будетъ добавлено къ мѣтѣ родительской. Примѣры:

    <span id="span_id">Text</span> -> <span>Text</span>
    <i>Text<span>?</span></i> -> <i>Text</i>

Descriptions:

Tag 'i' hasn't allowable attributes, so them will be removed from an output stream. In case, the tag containment meets a remove rule, the tag will be absent in the output;

Allowable attributes for the 'font' tag are 'face', and 'size'. In case, if the tag containment meets a remove rule, the tag will be absent in the output, and if meets a cleanup rule, the containment will be purged;

Tag 'span' hasn't allowable attributes, so them will be removed from an output stream. In case, the tag containment meets a remove rule, the tag will be absent in the output as it is. In other cases, its containment will be added to a parent tag.

## Использованіе (Usage)
Суть 2 способа испозованія пакета въ ruby-приложеніяхъ.

### Используя методъ экземпляра класса (Using the class instance method)
Создай экземпляръ класса, передавъ конструктору рѣху загруженную въ видѣ строки или IO-класса, а затѣмъ прорѣши HTML-документъ:

Make a class instance, passing a reha to its initialize function. The reha must be loaded as a String, or an IO class. Then filter a HTML:

    рѣха = IO.read('.рѣха.yml.sample')
    hs = HScrubber.new(рѣха)

    html = IO.read('sample.html').gsub(/\r/, '')
    new_html = hs.scrub_html(html)

    puts html

### Используя методъ класса (Using the class method)
Можно прорѣшить HTML-документъ и не создавая экземпляръ класса. Тогда дѣлай такъ:

We able to filter the HTML-document without a class instance creation. Do as follows:

    рѣха = IO.read('.рѣха.yml.sample')
    html = IO.read('sample.html').gsub(/\r/, '')
    new_html = HScrubber.scrub_html(html, рѣха)

    puts html

# Права (Copyright)

Авторскія и исключительныя права (а) 2011 Малъ Скрылевъ
Зри LICENSE за подробностями.

Copyright (c) 2011 Malo Skrylevo
See LICENSE for details.

