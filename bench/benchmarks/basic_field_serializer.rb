##
# Bench test for serializing multiple fields.
class BasicFieldSerializer
  Idea = Struct.new(:name, :grade, :cool)

  Output = SoberSwag::OutputObject.define do
    field :name, primitive(:String)
    field :grade, primitive(:Integer)
    field :cool, primitive(:Bool)
  end

  OutputSerializer = Output.serializer

  MyIdea = Idea.new('Bob', 12, false)

  Bench.report 'Basic Field Serializers' do |bm|
    bm.report('Output Object') { Output.serialize(MyIdea) }
    bm.report('Serializer of Output Object') { OutputSerializer.serialize(MyIdea) }
    bm.compare!
  end
end
