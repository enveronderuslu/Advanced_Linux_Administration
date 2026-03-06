YAML Basics
For Ansible, nearly every YAML file starts with a list. Each item in the list is a list of key/value pairs, commonly called a “hash” or a “dictionary”. YAML files either have the extension .yaml or .yml. All YAML files (regardless of their association with Ansible or not) can optionally begin with --- and end with .... This is part of the YAML format and indicates the start and end of a document.

**********LISTS (In Yaml called as sequence)**************
All members of a list are lines beginning at the same indentation level starting with a "- " (a dash and a space):

/*/EXAMPLE:/*/
---
# A list of tasty fruits
Fruits:
   - Orange
   - Apple
   - Strawberry
   - Mango
...
Python 
Fruits = ["Orange","Apple", "Strawberry", "Mango"]

/*/EXAMPLE:/*/
---
Numbers:
  - 1
  - 2
  - 3
---
Python  Numbers = [1, 2, 3]

************Dictionary (In Yaml called as Maps)************
A dictionary is represented in a simple key: value form (the colon must be followed by a space):

/*/EXAMPLE:/*/
---
# An employee record
martin:
  name: Martin D'vloper
  job: Developer
  skill: Elite
---

/*/EXAMPLE:/*/
---
# A car report
araba:
  marka: Ford
  model: Focus
  yil: 2015
---
python karsiligi 
araba = { "marka": "Ford", "model": "Focus", "yil": 2015 }

/*/EXAMPLE:/*/
---
# icice map örnegi
firma:
  ad: TechSoft
  adres:
    sehir: İzmir
    posta_kodu: 35000
---

/*/EXAMPLE:/*/
More complicated data structures are possible, such as lists of dictionaries, dictionaries whose values are lists or a mix of both:
---
# Employee records
Employee:
   - martin:
       name: Martin D'vloper
       job: Developer
       skills:
         - python
         - perl
         - pascal
   - muhittin:
       name: Tabitha Bitumen
       job: Developer
       skills:
         - lisp
         - fortran
         - erlang
---


/*/EXAMPLE:/*/

Liste icinde Maps
---
kullanicilar:
  - ad: Ali
    yas: 30
  - ad: Zeynep
    yas: 25
---

Vars icinde liste:
---
vars:
  paketler:
    - nginx
    - git
    - curl
---

tasks listesi 
---
tasks:
  - name: A
    ansible.builtin.debug:
      msg: "Görev A"
  
  - name: B
    ansible.builtin.debug:
      msg: "Görev B"
---
/*/EXAMPLE:/*/
Listede IP adresleri tanimlama: Vars isimli map icinde  "sunucular" isimli bir liste var
---
vars:                   # Burasi bir map
  sunucular:            # Burasi bir liste
    - 192.168.1.10
    - 192.168.1.11
---

/*/EXAMPLE:/*/ 
---
vars:                # Map
  ayarlar:           # Msp
    diller:          # Liste
      - tr
      - en
    tema: koyu
---


Literals (Strings, numbers, boolean, etc.)
The content of a scalar node is an opaque datum that can be presented as a series of zero or more Unicode characters.

/*/EXAMPLE:/*/
---
# key: value [mapping]
company: spacelift
# key: value is an array [sequence]
domain:
 - devops
 - devsecops
tutorial:
  - yaml:
      name: "YAML Ain't Markup Language" #string [literal]
      type: awesome #string [literal]
      born: 2001 #number [literal]
  - json:
      name: JavaScript Object Notation #string [literal]
      type: great #string [literal]
      born: 2001 #number [literal]
  - xml:
      name: Extensible Markup Language #string [literal]
      type: good #string [literal]
      born: 1996 #number [literal]
author: omkarbirade
published: true
---

/*/EXAMPLE:/*/

Yapı Özeti:
YAML Elemanı                         Türü  (Key: Value)
company                              Map → literal (string)
domain                               Map → Sequence (liste)
tutorial                             Map → Sequence (liste)
Liste elemanları (yaml, json, xml)   Sequence içinde Map
---
# A sample yaml file
company: spacelift
domain:
 - devops
 - devsecops
tutorial:
  - yaml:
      name: "YAML Ain't Markup Language"
      type: awesome
      born: 2001
  - json:
      name: JavaScript Object Notation
      type: great
      born: 2001
  - xml:
      name: Extensible Markup Language
      type: good
      born: 1996
author: omkarbirade
published: true
---



These are called “Flow collections”.

Ansible doesn’t really use these too much, but you can also specify a boolean value (true/false) in several forms:

create_key: true
needs_agent: false
knows_oop: True
likes_emacs: TRUE
uses_cvs: false
Use lowercase ‘true’ or ‘false’ for boolean values in dictionaries if you want to be compatible with default yamllint options.

Values can span multiple lines using | or >. Spanning multiple lines using a “Literal Block Scalar” | will include the newlines and any trailing spaces. Using a “Folded Block Scalar” > will fold newlines to spaces; it is used to make what would otherwise be a very long line easier to read and edit. In either case the indentation will be ignored. Examples are:

include_newlines: |
            exactly as you see
            will appear these three
            lines of poetry

fold_newlines: >
            this is really a
            single line of text
            despite appearances
While in the above > example all newlines are folded into spaces, there are two ways to enforce a newline to be kept:

fold_some_newlines: >
    a
    b
    c
    d
     e
    f
Alternatively, it can be enforced by including newline \n characters:

fold_same_newlines: "a b\nc d\n  e\nf\n"
Let’s combine what we learned so far in an arbitrary YAML example. This really has nothing to do with Ansible, but will give you a feel for the format:

---
# An employee record
name: Martin D'vloper
job: Developer
skill: Elite
employed: True
foods:
  - Apple
  - Orange
  - Strawberry
  - Mango
languages:
  perl: Elite
  python: Elite
  pascal: Lame
education: |
  4 GCSEs
  3 A-Levels
  BSc in the Internet of Things
That’s all you really need to know about YAML to start writing Ansible playbooks.

PIPE ISARETI
run: |
   rpm install etwas
   rpm install baskabisey
Buradaki pipe isareti ile kodlar arka arkaya sirasiyla calisacak. 



Gotchas
While you can put just about anything into an unquoted scalar, there are some exceptions. A colon followed by a space (or newline) ": " is an indicator for a mapping. A space followed by the pound sign " #" starts a comment.

Because of this, the following is going to result in a YAML syntax error:

foo: somebody said I should put a colon here: so I did

windows_drive: c:
…but this will work:

windows_path: c:\windows
You will want to quote hash values using colons followed by a space or the end of the line:

foo: 'somebody said I should put a colon here: so I did'

windows_drive: 'c:'
…and then the colon will be preserved.

Alternatively, you can use double quotes:

foo: "somebody said I should put a colon here: so I did"

windows_drive: "c:"
The difference between single quotes and double quotes is that in double quotes you can use escapes:

foo: "a \t TAB and a \n NEWLINE"
The list of allowed escapes can be found in the YAML Specification under “Escape Sequences” (YAML 1.1) or “Escape Characters” (YAML 1.2).

The following is invalid YAML:

foo: "an escaped \' single quote"
Further, Ansible uses “{{ var }}” for variables. If a value after a colon starts with a “{”, YAML will think it is a dictionary, so you must quote it, like so:

foo: "{{ variable }}"
If your value starts with a quote the entire value must be quoted, not just part of it. Here are some additional examples of how to properly quote things:

foo: "{{ variable }}/additional/string/literal"
foo2: "{{ variable }}\\backslashes\\are\\also\\special\\characters"
foo3: "even if it is just a string literal it must all be quoted"
Not valid:

foo: "E:\\path\\"rest\\of\\path
In addition to ' and " there are a number of characters that are special (or reserved) and cannot be used as the first character of an unquoted scalar: [] {} > | * & ! % # ` @ ,.

You should also be aware of ? : -. In YAML, they are allowed at the beginning of a string if a non-space character follows, but YAML processor implementations differ, so it is better to use quotes.

In Flow Collections, the rules are a bit more strict:

a scalar in block mapping: this } is [ all , valid

flow mapping: { key: "you { should [ use , quotes here" }
Boolean conversion is helpful, but this can be a problem when you want a literal yes or other boolean values as a string. In these cases just use quotes:

non_boolean: "yes"
other_string: "False"
YAML converts certain strings into floating-point values, such as the string 1.0. If you need to specify a version number (in a requirements.yml file, for example), you will need to quote the value if it looks like a floating-point value:

version: "1.0"