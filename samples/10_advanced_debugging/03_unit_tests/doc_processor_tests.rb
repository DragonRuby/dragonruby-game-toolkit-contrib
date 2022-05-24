def test_docs_process_header(args, assert)
  called_methods = process_doc_string <<~DOC
    * This is a header.
    ** This is a sub-header.
    *** This is a sub-sub-header.
    **** This is a sub-sub-sub-header.
    ***** This is the deepest header.
  DOC

  assert.equal! called_methods, [
    [:process_header_start, 1],
    [:process_text, 'This is a header.'],
    [:process_header_end, 1],
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

def test_docs_process_code(args, assert)
  called_methods = process_doc_string <<~DOC
    Now run ~dragonruby~ ...did you get a window with "Hello World!" written in it? Good, you're officially a game developer!
  DOC

  assert.equal! called_methods, [
    [:process_text, 'Now run '],
    [:process_code, 'dragonruby'],
    [:process_text, " ...did you get a window with \"Hello World!\" written in it? Good, you're officially a game developer!"]
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
