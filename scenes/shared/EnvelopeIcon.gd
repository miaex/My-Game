extends Control
## EnvelopeIcon
## Petite icône d'enveloppe dessinée (même logique que BulbIcon : fiable,
## indépendante des polices/emoji du téléphone).

func _ready() -> void:
	queue_redraw()


func _draw() -> void:
	var w: float = size.x
	var h: float = size.y
	var margin: float = w * 0.08

	var body := Rect2(margin, margin, w - margin * 2, h - margin * 2)
	draw_rect(body, Color(1, 1, 1, 0.95))

	var top_left := Vector2(body.position.x, body.position.y)
	var top_right := Vector2(body.position.x + body.size.x, body.position.y)
	var mid := Vector2(body.position.x + body.size.x / 2.0, body.position.y + body.size.y * 0.55)
	var bottom_left := Vector2(body.position.x, body.position.y + body.size.y)
	var bottom_right := Vector2(body.position.x + body.size.x, body.position.y + body.size.y)

	draw_line(top_left, mid, Color(0.906, 0.573, 0.573), 3.0)
	draw_line(top_right, mid, Color(0.906, 0.573, 0.573), 3.0)
	draw_line(bottom_left, mid, Color(0.941, 0.859, 0.831), 2.0)
	draw_line(bottom_right, mid, Color(0.941, 0.859, 0.831), 2.0)

	draw_rect(body, Color(0.906, 0.573, 0.573), false, 3.0)

	# Petit cachet central
	draw_circle(mid, w * 0.09, Color(0.796, 0.478, 0.518))
