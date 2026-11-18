extends Estado
## Acabou de encostar no jogador: voa para trás, para longe dele, freando aos
## poucos, e só depois volta a perseguir. Sem isso o morcego ficaria grudado no
## jogador e o acertaria de novo assim que a invencibilidade acabasse; com o
## recuo, o ataque vira um "mergulho" e o jogador tem tempo de fugir.

@export var duracao := 1.2
## Velocidade (px/s) no começo do recuo; vai caindo até zero no fim.
@export var velocidade := 110.0

var _tempo := 0.0
var _direcao := Vector2.ZERO

@onready var morcego := owner as Morcego


func entrar() -> void:
	_tempo = 0.0
	morcego.sprite.speed_scale = 1.0
	# Usa o nó do jogador mesmo que ele tenha acabado de morrer com o golpe.
	var jogador := get_tree().get_first_node_in_group(&"jogador") as Node2D
	_direcao = Vector2.from_angle(randf() * TAU)
	if jogador and not jogador.global_position.is_equal_approx(morcego.global_position):
		_direcao = jogador.global_position.direction_to(morcego.global_position)


func atualizar_fisica(delta: float) -> void:
	_tempo += delta
	morcego.velocity = _direcao * velocidade * maxf(1.0 - _tempo / duracao, 0.0)
	morcego.move_and_slide()
	if _tempo >= duracao:
		transicao_pedida.emit(&"Perseguindo")
