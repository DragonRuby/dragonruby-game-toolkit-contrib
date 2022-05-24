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
