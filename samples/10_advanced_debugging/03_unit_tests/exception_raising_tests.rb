begin :shared
  class ExceptionalClass
    def initialize exception_to_throw = nil
      raise exception_to_throw if exception_to_throw
    end
  end
end

def test_exception_in_newing_object args, assert
  begin
    ExceptionalClass.new TypeError
    raise "Exception wasn't thrown!"
  rescue Exception => e
    assert.equal! e.class, TypeError, "Exceptions within constructor should be retained."
  end
end

$gtk.reset 100
$gtk.log_level = :off
