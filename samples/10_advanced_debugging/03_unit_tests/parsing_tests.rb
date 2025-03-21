def test_parse_json args, assert
  result = GTK.parse_json '{ "name": "John Doe", "aliases": ["JD"] }'
  assert.equal! result, { "name"=>"John Doe", "aliases"=>["JD"] }, "Parsing JSON failed."
end

def test_parse_xml args, assert
  result = GTK.parse_xml <<-S
<Person id="100">
  <Name>John Doe</Name>
</Person>
S

 expected = {:type=>:element,
             :name=>nil,
             :children=>[{:type=>:element,
                          :name=>"Person",
                          :children=>[{:type=>:element,
                                       :name=>"Name",
                                       :children=>[{:type=>:content,
                                                    :data=>"John Doe"}]}],
                          :attributes=>{"id"=>"100"}}]}

 assert.equal! result, expected, "Parsing xml failed."
end
