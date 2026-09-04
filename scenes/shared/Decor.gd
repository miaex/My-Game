class_name Decor
extends RefCounted
## Decor
## Petites touches visuelles réutilisables : particules flottantes en
## fond d'écran, et pulsation douce pour les boutons principaux — pour
## donner un peu de vie à l'interface (voir demande utilisateur).

const SPARKLE_COLORS := [
	Color(0.906, 0.573, 0.573, 0.45),
	Color(0.85, 0.62, 0.35, 0.35),
	Color(0.63, 0.5, 0.7, 0.3),
]


static func add_sparkles(parent: Control, count: int = 7) -> void:
	var viewport_size: Vector2 = Vector2(1080, 1920)
	for i in range(count):
		var dot := Panel.new()
		var s: float = randf_range(8, 18)
		dot.custom_minimum_size = Vector2(s, s)
		dot.size = Vector2(s, s)
		dot.position = Vector2(randf_range(30, viewport_size.x - 30), randf_range(60, viewport_size.y - 200))
		dot.mouse_filter = Control.MOUSE_FILTER_IGNORE

		var style := StyleBoxFlat.new()
		style.bg_color = SPARKLE_COLORS[randi() % SPARKLE_COLORS.size()]
		style.set_corner_radius_all(int(s))
		dot.add_theme_stylebox_override("panel", style)

		parent.add_child(dot)
		parent.move_child(dot, 0)

		var dy: float = randf_range(20, 55)
		var dur: float = randf_range(2.6, 4.2)
		var tween := dot.create_tween()
		tween.set_loops()
		tween.tween_property(dot, "position:y", dot.position.y - dy, dur).set_trans(Tween.TRANS_SINE)
		tween.tween_property(dot, "position:y", dot.position.y, dur).set_trans(Tween.TRANS_SINE)


## Grandes formes douces en fond, pour donner de la présence visuelle
## sans distraire du contenu (voir demande : "rajoute du design tout autour").
static func add_blobs(parent: Control, count: int = 4) -> void:
	var viewport_size: Vector2 = Vector2(1080, 1920)
	var positions := [
		Vector2(-80, -80), Vector2(viewport_size.x - 200, 40),
		Vector2(-100, viewport_size.y - 420), Vector2(viewport_size.x - 260, viewport_size.y - 300),
	]
	for i in range(min(count, positions.size())):
		var blob := Panel.new()
		var s: float = randf_range(260, 360)
		blob.custom_minimum_size = Vector2(s, s)
		blob.size = Vector2(s, s)
		blob.position = positions[i]
		blob.mouse_filter = Control.MOUSE_FILTER_IGNORE

		var style := StyleBoxFlat.new()
		style.bg_color = SPARKLE_COLORS[i % SPARKLE_COLORS.size()]
		style.bg_color.a = 0.18
		style.set_corner_radius_all(int(s))
		blob.add_theme_stylebox_override("panel", style)

		parent.add_child(blob)
		parent.move_child(blob, 0)

		var tween := blob.create_tween()
		tween.set_loops()
		tween.tween_property(blob, "scale", Vector2(1.08, 1.08), randf_range(3.5, 5.0)).set_trans(Tween.TRANS_SINE)
		tween.tween_property(blob, "scale", Vector2(1.0, 1.0), randf_range(3.5, 5.0)).set_trans(Tween.TRANS_SINE)


static func pulse(node: Control) -> void:
	node.pivot_offset = node.size / 2.0
	var tween := node.create_tween()
	tween.set_loops()
	tween.tween_property(node, "scale", Vector2(1.05, 1.05), 0.8).set_trans(Tween.TRANS_SINE)
	tween.tween_property(node, "scale", Vector2(1.0, 1.0), 0.8).set_trans(Tween.TRANS_SINE)
