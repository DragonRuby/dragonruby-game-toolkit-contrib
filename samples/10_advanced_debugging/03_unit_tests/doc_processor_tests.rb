def test_docs_process_header(args, assert)
  called_methods = process_doc_string <<~DOC
    * This is a header.

    This is text.

    ** This is a sub-header.
    *** This is a sub-sub-header.
    **** This is a sub-sub-sub-header.
    ***** This is the deepest header.
  DOC

  assert.equal! called_methods, [
    [:process_header_start, 1],
    [:process_text, 'This is a header.'],
    [:process_header_end, 1],
    [:process_text, 'This is text.'],
    [:process_header_start, 2],
    [:process_text, 'This is a sub-header.'],
    [:process_header_end, 2],
    [:process_header_start, 3],
    [:process_text, 'This is a sub-sub-header.'],
    [:process_header_end, 3],
    [:process_header_start, 4],
    [:process_text, 'This is a sub-sub-sub-header.'],
    [:process_header_end, 4],
    [:process_header_start, 5],
    [:process_text, 'This is the deepest header.'],
    [:process_header_end, 5]
  ]
end

def test_header_with_markup(args, assert)
  called_methods = process_doc_string <<~DOC
    * DOCS: ~GTK::Runtime~
  DOC

  assert.equal! called_methods, [
    [:process_header_start, 1],
    [:process_text, 'DOCS: '],
    [:process_inline_code, 'GTK::Runtime'],
    [:process_header_end, 1]
  ]
end

def test_docs_process_code_block(args, assert)
  called_methods = process_doc_string <<~DOC
    #+begin_src ruby
      def tick args
        args.outputs.labels << [580, 400, 'Hello World!']
      end
    #+end_src

    #+begin_src
    shell_command
    #+end_src
  DOC

  assert.equal! called_methods, [
    [:process_code_block_start, :ruby],
    [:process_code_block_content, "def tick args\n  args.outputs.labels << [580, 400, 'Hello World!']\nend\n"],
    [:process_code_block_end, :ruby],
    [:process_code_block_start],
    [:process_code_block_content, "shell_command\n"],
    [:process_code_block_end]
  ]
end

def test_docs_process_link(args, assert)
  called_methods = process_doc_string <<~DOC
    Our Discord channel is [[http://discord.dragonruby.org]].
  DOC

  assert.equal! called_methods, [
    [:process_text, 'Our Discord channel is '],
    [:process_link, { href: 'http://discord.dragonruby.org' }],
    [:process_text, '.']
  ]
end

def test_docs_process_inline_code(args, assert)
  called_methods = process_doc_string <<~DOC
    Now run ~dragonruby~ ...did you get a window with "Hello World!" written in it? Good, you're officially a game developer!
  DOC

  assert.equal! called_methods, [
    [:process_text, 'Now run '],
    [:process_inline_code, 'dragonruby'],
    [:process_text, " ...did you get a window with \"Hello World!\" written in it? Good, you're officially a game developer!"]
  ]
end

def test_docs_process_markup_at_end_of_paragraph(args, assert)
  called_methods = process_doc_string <<~DOC
    Now run ~dragonruby~

    This is a link to [[http://discord.dragonruby.org]]
  DOC

  assert.equal! called_methods, [
    [:process_text, 'Now run '],
    [:process_inline_code, 'dragonruby'],
    [:process_text, 'This is a link to '],
    [:process_link, { href: 'http://discord.dragonruby.org' }]
  ]
end

def test_docs_process_quote(args, assert)
  called_methods = process_doc_string <<~DOC
    When someone asks you:

    #+begin_quote
    What game engine do you use?
    #+end_quote

    Reply with:

    #+begin_quote
    I am a Dragon Rider.
    #+end_quote
  DOC

  assert.equal! called_methods, [
    [:process_text, 'When someone asks you:'],
    [:process_quote_start],
    [:process_text, 'What game engine do you use?'],
    [:process_quote_end],
    [:process_text, 'Reply with:'],
    [:process_quote_start],
    [:process_text, 'I am a Dragon Rider.'],
    [:process_quote_end]
  ]
end

def test_docs_process_paragraphs(args, assert)
  called_methods = process_doc_string <<~DOC
    Here's the most important thing you should know: Ruby lets you do some
    complicated things really easily, and you can learn that stuff
    later. I'm going to show you one or two cool tricks, but that's all.

    Do you know what an if statement is? A for-loop? An array? That's all
    you'll need to start.
  DOC

  assert.equal! called_methods, [
    [
      :process_text,
      "Here's the most important thing you should know: Ruby lets you do some " +
      'complicated things really easily, and you can learn that stuff ' +
      "later. I'm going to show you one or two cool tricks, but that's all."
    ],
    [
      :process_text,
      "Do you know what an if statement is? A for-loop? An array? That's all " +
      "you'll need to start."
    ]
  ]
end

def test_docs_process_ordered_list(args, assert)
  called_methods = process_doc_string <<~DOC
    1. Intermediate Introduction to Ruby Syntax
    2. Intermediate Introduction to Arrays in Ruby
    3. You may also want to try this
       free course provided at

    Text

    1. Another
    2. List
  DOC

  assert.equal! called_methods, [
    [:process_ordered_list_start],
    [:process_ordered_list_item_start],
    [:process_text, 'Intermediate Introduction to Ruby Syntax'],
    [:process_ordered_list_item_end],
    [:process_ordered_list_item_start],
    [:process_text, 'Intermediate Introduction to Arrays in Ruby'],
    [:process_ordered_list_item_end],
    [:process_ordered_list_item_start],
    [:process_text, 'You may also want to try this free course provided at'],
    [:process_ordered_list_item_end],
    [:process_ordered_list_end],
    [:process_text, 'Text'],
    [:process_ordered_list_start],
    [:process_ordered_list_item_start],
    [:process_text, 'Another'],
    [:process_ordered_list_item_end],
    [:process_ordered_list_item_start],
    [:process_text, 'List'],
    [:process_ordered_list_item_end],
    [:process_ordered_list_end]
  ]
end

def test_docs_process_unordered_list(args, assert)
  called_methods = process_doc_string <<~DOC
    Ok, here are few rules with regards to game development with GTK:

    - Your game is all going to happen under one function ...
    - that runs 60 times a second ...
    - and has to tell the computer
      what to draw each time.

    That's an entire video game in one run-on sentence.

    - another item
  DOC

  assert.equal! called_methods, [
    [:process_text, 'Ok, here are few rules with regards to game development with GTK:'],
    [:process_unordered_list_start],
    [:process_unordered_list_item_start],
    [:process_text, 'Your game is all going to happen under one function ...'],
    [:process_unordered_list_item_end],
    [:process_unordered_list_item_start],
    [:process_text, 'that runs 60 times a second ...'],
    [:process_unordered_list_item_end],
    [:process_unordered_list_item_start],
    [:process_text, 'and has to tell the computer what to draw each time.'],
    [:process_unordered_list_item_end],
    [:process_unordered_list_end],
    [:process_text, 'That\'s an entire video game in one run-on sentence.'],
    [:process_unordered_list_start],
    [:process_unordered_list_item_start],
    [:process_text, 'another item'],
    [:process_unordered_list_item_end],
    [:process_unordered_list_end]
  ]
end

class TestProcessor
  attr_reader :called_methods

  def initialize
    @called_methods = []
  end

  def respond_to?(method_name)
    true
  end

  def method_missing(name, *args)
    @called_methods << [name, *args]
  end
end

def process_doc_string(doc_string)
  test_processor = TestProcessor.new
  processor = Docs::Processor.new processors: [test_processor]
  processor.process doc_string
  test_processor.called_methods
end
