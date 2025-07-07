class_name MatchupPlayerCard
extends BallPlayerCard

# Called when the node enters the scene tree for the first time.
func _ready():
  super._ready()
  first_name.add_theme_font_size_override("font_size", int(ball_player_stats.first_name_size))
  last_name.add_theme_font_size_override("font_size", int(ball_player_stats.last_name_size))
