extends Control
## CardBackIcon
## Dos de carte décoratif dessiné par code (10 motifs), dans la palette
## JieePlay — évite de dépendre d'images externes pour ce premier jet
## du système de récompense.

@export var pattern_id: int = 0
@export var base_color: Color = Color(0.475, 0.353, 0.451)
@export var accent_color: Color = Color(0.85, 0.62, 0.35)

func _ready() -> void:
	queue_redraw()

func set_pattern(id: int, base: Color, accent: Color) -> void:
	pattern_id = id
	base_color = base
	accent_color = accent
	queue_redraw()

func _draw() -> void:
	var w: float = size.x
	var h: float = size.y
	var c: Vector2 = size / 2.0

	# Fond de carte + bordure dorée
	var card_rect := Rect2(Vector2.ZERO, size)
	draw_rect(card_rect, base_color)
	draw_rect(card_rect, accent_color, false, 3.0)

	match pattern_id % 10:
		0: # étoile scintillante
			_draw_star(c, min(w, h) * 0.28)
		1: # fleur
			_draw_flower(c, min(w, h) * 0.22)
		2: # lune
			draw_circle(c, min(w, h) * 0.22, accent_color)
			draw_circle(c + Vector2(min(w, h) * 0.1, 0), min(w, h) * 0.2, base_color)
		3: # cercle ornemental
			draw_arc(c, min(w, h) * 0.26, 0, TAU, 32, accent_color, 3.0)
			draw_circle(c, min(w, h) * 0.06, accent_color)
		4: # coeur
			_draw_heart(c, min(w, h) * 0.24)
		5: # feuille
			_draw_leaf(c, min(w, h) * 0.28)
		6: # vagues
			for i in range(3):
				var y: float = c.y - min(w,h)*0.15 + i * min(w,h) * 0.15
				_draw_wave(y, w, accent_color)
		7: # soleil
			_draw_sun(c, min(w, h) * 0.16)
		8: # nuage
			_draw_cloud(c, min(w, h) * 0.18)
		9: # losange
			_draw_diamond(c, min(w, h) * 0.26)


func _draw_star(c: Vector2, r: float) -> void:
	var points := PackedVector2Array()
	for i in range(8):
		var angle: float = i * PI / 4.0
		var radius: float = r if i % 2 == 0 else r * 0.4
		points.append(c + Vector2(cos(angle), sin(angle)) * radius)
	draw_colored_polygon(points, accent_color)


func _draw_flower(c: Vector2, r: float) -> void:
	for i in range(6):
		var angle: float = i * TAU / 6.0
		var petal_center: Vector2 = c + Vector2(cos(angle), sin(angle)) * r * 0.6
		draw_circle(petal_center, r * 0.45, accent_color)
	draw_circle(c, r * 0.3, base_color)


func _draw_heart(c: Vector2, r: float) -> void:
	draw_circle(c + Vector2(-r * 0.5, -r * 0.3), r * 0.5, accent_color)
	draw_circle(c + Vector2(r * 0.5, -r * 0.3), r * 0.5, accent_color)
	var points := PackedVector2Array([
		c + Vector2(-r, -r * 0.2), c + Vector2(0, r * 1.1), c + Vector2(r, -r * 0.2)
	])
	draw_colored_polygon(points, accent_color)


func _draw_leaf(c: Vector2, r: float) -> void:
	draw_circle(c, r, accent_color)
	draw_line(c - Vector2(0, r * 0.9), c + Vector2(0, r * 0.9), base_color, 2.0)


func _draw_wave(y: float, w: float, color: Color) -> void:
	var points := PackedVector2Array()
	var steps: int = 20
	for i in range(steps + 1):
		var x: float = (w / steps) * i
		var dy: float = sin((x / w) * TAU) * 6.0
		points.append(Vector2(x, y + dy))
	for i in range(points.size() - 1):
		draw_line(points[i], points[i + 1], color, 2.0)


func _draw_sun(c: Vector2, r: float) -> void:
	draw_circle(c, r, accent_color)
	for i in range(8):
		var angle: float = i * TAU / 8.0
		var p1: Vector2 = c + Vector2(cos(angle), sin(angle)) * r * 1.3
		var p2: Vector2 = c + Vector2(cos(angle), sin(angle)) * r * 1.9
		draw_line(p1, p2, accent_color, 3.0)


func _draw_cloud(c: Vector2, r: float) -> void:
	draw_circle(c + Vector2(-r * 0.6, 0), r * 0.7, accent_color)
	draw_circle(c + Vector2(r * 0.6, 0), r * 0.7, accent_color)
	draw_circle(c, r * 0.9, accent_color)


func _draw_diamond(c: Vector2, r: float) -> void:
	var points := PackedVector2Array([
		c + Vector2(0, -r), c + Vector2(r, 0), c + Vector2(0, r), c + Vector2(-r, 0)
	])
	draw_colored_polygon(points, accent_color)
	var points2 := PackedVector2Array([
		c + Vector2(0, -r * 0.5), c + Vector2(r * 0.5, 0), c + Vector2(0, r * 0.5), c + Vector2(-r * 0.5, 0)
	])
	draw_colored_polygon(points2, base_color)
