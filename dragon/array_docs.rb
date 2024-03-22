# coding: utf-8
# Copyright 2019 DragonRuby LLC
# MIT License
# array_docs.rb has been released under MIT (*only this file*).

module ArrayDocs
  def docs_method_sort_order
    [
      :docs_class,
      :docs_map_2d,
      :docs_include_any?,
      :docs_any_intersect_rect?,
      :docs_map,
      :docs_each,
      :docs_reject_nil,
      :docs_reject_false,
      :docs_product,
    ]
  end

  def docs_include_any?
    <<-'S'
** ~include_any?~

Given a collection of items, the function will return
~true~ if any of ~self~'s items exists in the collection of items passed in:

#+begin_src
  l1 = [:a, :b, :c]
  result = l1.include_any?(:b, :c, :d)
  puts result # true

  l1 = [:a, :b, :c]
  l2 = [:b, :c, :d]
  # returns true, but requires the parameter to be "splatted"
  # consider using (l1 & l2) instead
  result = l1.include_any?(*l2)
  puts result # true

  # & (bit-wise and) operator usage
  l1 = [:a, :b, :c]
  l2 = [:d, :c]
  result = (l1 & l2)
  puts result # [:c]

  # | (bit-wise or) operator usage
  l1 = [:a, :b, :c, :a]
  l2 = [:d, :f, :a]
  result = l1 | l2
  puts result # [:d, :f, :a, :b, :c]
#+end_src
S
  end

  def docs_class
    DocsOrganizer.get_docsify_content path: "docs/api/array.md",
                                      heading_level: 1,
                                      heading_include: "Array",
                                      max_depth: 0
  end

  def docs_reject_nil
    DocsOrganizer.get_docsify_content path: "docs/api/array.md",
                                      heading_level: 2,
                                      heading_include: __method__.to_s.gsub("docs_", "")
  end

  def docs_reject_false
    DocsOrganizer.get_docsify_content path: "docs/api/array.md",
                                      heading_level: 2,
                                      heading_include: __method__.to_s.gsub("docs_", "")
  end

  def docs_product
    DocsOrganizer.get_docsify_content path: "docs/api/array.md",
                                      heading_level: 2,
                                      heading_include: __method__.to_s.gsub("docs_", "")
  end

  def docs_map_2d
    DocsOrganizer.get_docsify_content path: "docs/api/array.md",
                                      heading_level: 2,
                                      heading_include: __method__.to_s.gsub("docs_", "")
  end

  def docs_any_intersect_rect?
    DocsOrganizer.get_docsify_content path: "docs/api/array.md",
                                      heading_level: 2,
                                      heading_include: __method__.to_s.gsub("docs_", "")
  end

  def docs_map
    DocsOrganizer.get_docsify_content path: "docs/api/array.md",
                                      heading_level: 2,
                                      heading_include: __method__.to_s.gsub("docs_", "")
  end

  def docs_each
    DocsOrganizer.get_docsify_content path: "docs/api/array.md",
                                      heading_level: 2,
                                      heading_include: __method__.to_s.gsub("docs_", "")
  end
end

class Array
  extend Docs
  extend ArrayDocs
end
