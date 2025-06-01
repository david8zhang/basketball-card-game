class_name StrategyCardNode
extends Resource

enum StrategyCardNodeType {
  CONDITION,
  SEQUENCE,
  BONUS
}

enum NodeResultType {
  SUCCESS,
  FAILURE
}

class NodeResult:
  var result_type: NodeResultType
  func _init(_result_type):
    result_type = _result_type

var node_type: StrategyCardNodeType

func process(blackboard):
  var node_result = NodeResult.new(NodeResultType.SUCCESS)
  blackboard.append(node_result)
  return NodeResultType.SUCCESS
