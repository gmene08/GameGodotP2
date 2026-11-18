extends Estado
## Recém-solto pelo gerador, ainda dentro do túnel na parede: voa reto para
## fora, na direção da saída, sem colidir com nada (senão nasceria preso na
## parede) e aparecendo aos poucos do escuro. Já fora do túnel, passa a vagar.

## Quantos pixels voa até sair do túnel. Os pontos de saída ficam uns 6-12 px
## antes da beirada da parede; 24 dá folga para o corpo sair inteiro.
@export var distancia := 24.0
@export var velocidade := 40.0

var _percorrido := 0.0
var _mascara_colisao := 0

@onready var morcego := owner as Morcego


func entrar() -> void:
	_percorrido = 0.0
	_mascara_colisao = morcego.collision_mask
	morcego.collision_mask = 0
	morcego.modulate.a = 0.0
	morcego.sprite.speed_scale = 1.0
	morcego.velocity = morcego.direcao_saida * velocidade


func sair() -> void:
	morcego.collision_mask = _mascara_colisao
	morcego.modulate.a = 1.0


func atualizar_fisica(delta: float) -> void:
	morcego.move_and_slide()
	_percorrido += velocidade * delta
	morcego.modulate.a = minf(_percorrido / distancia, 1.0)
	if _percorrido >= distancia:
		transicao_pedida.emit(&"Vagando")
