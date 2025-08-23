# QuarterCheckCondition

A new `StrategyCardCondition` for Godot 4.4 that checks what quarter it currently is in the game.

## Overview

The `QuarterCheckCondition` allows strategy cards to have different effects based on the current quarter of the basketball game. This can be used to create cards that are more effective in early quarters, late quarters, or specific quarters.

## Features

- **Quarter Comparison**: Check if the current quarter is less than, equal to, or greater than a threshold
- **Flexible Thresholds**: Set any quarter number (1-4) as the comparison point
- **Multiple Comparators**: Use LESS, EQUAL, or GREATER comparison types

## Usage

### Basic Setup

1. **Create the Condition**: The condition is already implemented in `scripts/strategy/condition/QuarterCheckCondition.gd`

2. **Configure the Condition**: Set the `quarter_threshold` and `comparator_type` in the editor or code

3. **Add to Strategy Card**: Use the condition in your strategy card's node tree

### Configuration Options

```gdscript
@export var quarter_threshold := 1  # Quarter to compare against (1-4)
@export var comparator_type := ComparatorType.EQUAL  # LESS, EQUAL, or GREATER
```

### Examples

#### "First Quarter Only" Card
- `quarter_threshold = 1`
- `comparator_type = EQUAL`
- Effect: Only works in Q1

#### "Late Game" Card  
- `quarter_threshold = 3`
- `comparator_type = GREATER`
- Effect: Works in Q3 and Q4

#### "Early Game" Card
- `quarter_threshold = 2`
- `comparator_type = LESS`
- Effect: Works in Q1 and Q2

## Technical Details

### How It Works

1. The condition receives game state information through the `Blackboard`
2. It extracts the current quarter from `blackboard.game_state["current_quarter"]`
3. It compares the current quarter against the configured threshold
4. Returns SUCCESS or FAILURE based on the comparison result

### Integration

The condition integrates with the existing strategy card system:
- Extends `StrategyCardConditionNode`
- Uses the new `QUARTER_CHECK` condition type
- Works with the existing pass/fail child node system

### Game State Access

The condition accesses quarter information through:
- Primary: `blackboard.game_state["current_quarter"]`
- Fallback: `blackboard.game_state["quarter_scores"]`
- Default: Returns quarter 1 if no information is available

## File Structure

```
scripts/strategy/condition/
├── QuarterCheckCondition.gd          # Main condition implementation
└── QuarterCheckCondition.gd.uid      # Unique identifier file

scripts/strategy/
├── StrategyCardConditionNode.gd      # Base condition class (updated)
├── StrategyCardConfig.gd             # Strategy card config (updated)
└── Blackboard.gd                     # Blackboard with game state (updated)

scripts/
└── StrategyCardProcessor.gd          # Processor with game state (updated)
```

## Future Enhancements

- Add support for overtime periods
- Include quarter-specific bonuses
- Add quarter range conditions (e.g., "Q2-Q3 only")
- Support for quarter-based probability modifiers

## Testing

To test the condition:
1. Create a strategy card with the `QuarterCheckCondition`
2. Set different quarter thresholds and comparator types
3. Play the game and observe the condition behavior in different quarters
4. Verify that the condition correctly passes/fails based on the current quarter
