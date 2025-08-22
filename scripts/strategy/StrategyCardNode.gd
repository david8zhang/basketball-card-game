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

func process(blackboard: Blackboard):
	add_result_to_bb(NodeResultType.SUCCESS, blackboard)
	return NodeResultType.SUCCESS

func add_result_to_bb(result_type: NodeResultType, blackboard: Blackboard):
	var node_result = NodeResult.new(result_type, self)
	blackboard.node_results.append(node_result)