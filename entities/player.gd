class_name Jogador
extends CharacterBody2D
## Minerador controlado pelo jogador. O que ele faz em cada situação (parado,
## andando, correndo, machucado, morto) fica nos estados filhos da
## MaquinaEstados; aqui fica só o que os estados têm em comum.

signal cristais_mudou(total: int)
signal vida_mudou(atual: int, maxima: int)
## Emitido no fim da animação de morte (estado Morto), para o HUD mostrar o fim de jogo.
signal morreu

const NOMES_DIRECAO: Dictionary[Vector2, String] = {
	Vector2.UP: "cima",
	Vector2.DOWN: "baixo",
	Vector2.LEFT: "esquerda",
	Vector2.RIGHT: "direita",
}

@export var velocidade_andando := 70.0
@export var velocidade_correndo := 130.0
## Quanto a velocidade muda por segundo ao acelerar ou frear (px/s²).
## Mais alto = mais responsivo; mais baixo = mais "escorregadio".
@export var aceleracao := 1000.0
@export var vida_maxima := 3
## Segundos piscando, sem levar dano, depois de ser atingido.
@export var tempo_invencivel := 1.5
## Velocidade (px/s) com que o minerador é empurrado para longe de quem o atingiu.
@export var forca_empurrao := 200.0

## Para onde o minerador está olhando; escolhe a animação (ex.: "andar_cima").
var direcao := Vector2.DOWN
var cristais := 0
## Enquanto pisca depois de levar dano, nada machuca o minerador.
var invencivel := false

@onready var vida := vida_maxima
@onready var sprite: AnimatedSprite2D = $AnimatedSprite2D
@onready var maquina: MaquinaEstados = $MaquinaEstados


## Direção que o jogador está apertando, já normalizada (na diagonal não fica mais rápido).
func ler_entrada() -> Vector2:
	return Input.get_vector(&"mover_esquerda", &"mover_direita", &"mover_cima", &"mover_baixo")


func quer_correr() -> bool:
	return Input.is_action_pressed(&"correr")


## Acelera (ou freia) até a velocidade alvo e move respeitando as colisões.
func mover(velocidade_alvo: Vector2, delta: float) -> void:
	velocity = velocity.move_toward(velocidade_alvo, aceleracao * delta)
	move_and_slide()


## Vira o minerador para a entrada. Na diagonal mantém a direção atual, senão o
## sprite fica alternando entre, por exemplo, "cima" e "direita".
func atualizar_direcao(entrada: Vector2) -> void:
	if entrada == Vector2.ZERO:
		return
	if direcao.dot(entrada) >= maxf(absf(entrada.x), absf(entrada.y)) - 0.01:
		return
	if absf(entrada.x) > absf(entrada.y):
		direcao = Vector2(signf(entrada.x), 0)
	else:
		direcao = Vector2(0, signf(entrada.y))


## Toca a animação da ação na direção atual: tocar_animacao("andar") -> "andar_cima".
func tocar_animacao(acao: String, velocidade := 1.0) -> void:
	sprite.play(acao + "_" + NOMES_DIRECAO[direcao], velocidade)


## Chamado pelo cristal quando o jogador encosta nele.
func coletar_cristal() -> void:
	cristais += 1
	cristais_mudou.emit(cristais)


func esta_vivo() -> bool:
	return vida > 0


## Chamado pelo inimigo que encostou no minerador. Tira vida e empurra o
## minerador para longe de `origem`; se ainda tiver vida, ele fica piscando,
## sem levar dano, por `tempo_invencivel`. Retorna se o dano contou (não conta
## enquanto pisca nem depois de morto).
func levar_dano(origem: Vector2, dano := 1) -> bool:
	if invencivel or not esta_vivo():
		return false
	vida = maxi(vida - dano, 0)
	vida_mudou.emit(vida, vida_maxima)
	velocity = origem.direction_to(global_position) * forca_empurrao
	if esta_vivo():
		maquina.trocar_para(&"Machucado")
		_piscar_invencivel()
	else:
		maquina.trocar_para(&"Morto")
	return true


func _piscar_invencivel() -> void:
	invencivel = true
	# Tween criado pelo próprio nó: pausa junto com o jogo e some se o nó sumir.
	var piscar := create_tween().set_loops(maxi(roundi(tempo_invencivel / 0.2), 1))
	piscar.tween_property(sprite, "modulate:a", 0.25, 0.1)
	piscar.tween_property(sprite, "modulate:a", 1.0, 0.1)
	await piscar.finished
	invencivel = false
