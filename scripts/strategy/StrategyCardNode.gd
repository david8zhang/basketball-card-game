class_name StrategyCardNode
extends Resource

enum NodeType {
  CONDITION,
  SEQUENCE,
  BONUS,
  ACTION
}

enum NodeResultType {
  SUCCESS,
  FAILURE
}

class NodeResult:
  var node_ref: StrategyCardNode
  var result_type: NodeResultType
  func _init(_result_type, _node_ref):
    result_type = _result_type
    node_ref = _node_ref

var node_type: NodeType

func process(blackboard):
  var node_result = NodeResult.new(NodeResultType.SUCCESS, self)
  blackboard.node_results.append(node_result)
  return NodeResultType.SUCCESS
