extends Control
## BulbIcon
## Icône d'ampoule dessinée directement (évite de dépendre d'un glyphe
## emoji 💡 qui ne s'affiche pas sur toutes les polices/téléphones).

func _ready() -> void:
	queue_redraw()


func _draw() -> void:
	var c: Vector2 = size / 2.0
	var r: float = min(size.x, size.y) * 0.26

	# Halo doux derrière l'ampoule
	draw_circle(Vector2(c.x, c.y - r * 0.35), r * 1.3, Color(1, 1, 1, 0.15))

	# Globe de l'ampoule
	draw_circle(Vector2(c.x, c.y - r * 0.35), r, Color(1, 0.85, 0.35))

	# Reflet
	draw_circle(Vector2(c.x - r * 0.35, c.y - r * 0.65), r * 0.28, Color(1, 1, 1, 0.55))

	# Base / culot
	var base_w: float = r * 0.9
	var base_h: float = r * 0.55
	var base_top: float = c.y - r * 0.35 + r * 0.75
	draw_rect(Rect2(c.x - base_w / 2.0, base_top, base_w, base_h), Color(0.55, 0.5, 0.52))

	# Petits traits du culot
	for i in range(2):
		var y: float = base_top + base_h * 0.3 + i * (base_h * 0.4)
		draw_line(Vector2(c.x - base_w / 2.0, y), Vector2(c.x + base_w / 2.0, y), Color(0.35, 0.32, 0.34), 2.0)
