# `Zlib`

The `Zlib` class provides functions to compress and uncompress strings.

If you want a fluent interface you can patch `String` like so:

```ruby
class String
  def compress
    Zlib.compress self
  end
  
  def uncompress
    Zlib.uncompress self
  end
end

# usage
compressed = "hello world".compress
original = compressed.uncompress
```

## `compress`, `deflate`

Class method `compress` (aliased to `deflate`) takes in a single parameter being the string to compress, and returns a compressed value.

## `uncompress`, `inflate`

Class method `uncompress` (aliased to `inflate`) takes in a single parameter being the compressed string, and returns the uncompressed value.
