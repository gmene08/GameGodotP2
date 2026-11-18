class_name Morcego
extends CharacterBody2D
## Morcego de pedra, o inimigo. Nasce dentro de um túnel (ver gerador_morcegos.gd),
## sai voando e, quando percebe o jogador, vai atrás dele pelo caminho da
## navegação do mapa, contornando as paredes; ao encostar, machuca e recua.
## O que ele faz em cada situação (saindo do túnel, vagando, perseguindo,
## recuando) fica nos estados filhos da MaquinaEstados; aqui fica só o que os
## estados têm em comum.

@export var velocidade_vagando := 30.0
## Um pouco mais lento que o jogador andando (90): dá para fugir andando,
## e correndo (160) com folga.
@export var velocidade_perseguindo := 80.0
## Quanto a velocidade muda por segundo (px/s²). Mais baixo que o do jogador
## para o voo ficar mais solto, "derrapando" um pouco nas curvas.
@export var aceleracao := 500.0
## Morcego se guia pelo som: percebe o jogador dentro deste raio (px), mesmo
## com parede no meio.
@export var raio_deteccao := 120.0
## Só desiste da perseguição quando o jogador passa deste raio. É maior que o
## de detecção para o morcego não ficar trocando de estado na beirada do raio.
@export var raio_desistencia := 180.0
## Distância (px) entre os centros em que o morcego encosta no jogador e o machuca.
@export var alcance_ataque := 10.0

## Para onde aponta o túnel de onde o morcego sai. O gerador define ao soltá-lo.
var direcao_saida := Vector2.DOWN

@onready var sprite: AnimatedSprite2D = $AnimatedSprite2D
@onready var agente: NavigationAgent2D = $NavigationAgent2D


## O jogador do mapa, ou null se não tiver nenhum vivo (morto não é perseguido).
func jogador() -> Jogador:
	var alvo := get_tree().get_first_node_in_group(&"jogador") as Jogador
	if alvo == null or not alvo.esta_vivo():
		return null
	return alvo


## Distância em linha reta até o jogador (INF se não tiver jogador).
func distancia_do_jogador() -> float:
	var alvo := jogador()
	if alvo == null:
		return INF
	return global_position.distance_to(alvo.global_position)


## Troca o destino; o NavigationAgent2D recalcula o caminho contornando as paredes.
func definir_destino(destino: Vector2) -> void:
	agente.target_position = destino


## Voa pelo caminho até o destino atual e freia quando chega.
func seguir_caminho(velocidade: float, delta: float) -> void:
	var direcao := Vector2.ZERO
	if not agente.is_navigation_finished():
		direcao = global_position.direction_to(agente.get_next_path_position())
	mover(direcao * velocidade, delta)


## Acelera (ou freia) até a velocidade alvo e move respeitando as colisões.
func mover(velocidade_alvo: Vector2, delta: float) -> void:
	velocity = velocity.move_toward(velocidade_alvo, aceleracao * delta)
	move_and_slide()
