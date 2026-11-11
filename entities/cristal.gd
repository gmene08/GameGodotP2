extends Area2D
## Cristal, a "moeda" do jogo. Quando o jogador encosta, conta ponto, some
## com um brilho e se apaga.

@onready var sprite: AnimatedSprite2D = $Sprite
@onready var brilho: AnimatedSprite2D = $Brilho


func _ready() -> void:
	body_entered.connect(_ao_encostar)


func _ao_encostar(corpo: Node2D) -> void:
	var jogador := corpo as Jogador
	if jogador == null:
		return
	jogador.coletar_cristal()
	# Desliga a detecção para não contar de novo enquanto o brilho toca.
	set_deferred(&"monitoring", false)
	sprite.hide()
	brilho.show()
	brilho.play(&"brilho")
	await brilho.animation_finished
	queue_free()
