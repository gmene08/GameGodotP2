class_name Jogador
extends CharacterBody2D
## Minerador controlado pelo jogador. O que ele faz em cada situação (parado,
## andando, correndo) fica nos estados filhos da MaquinaEstados; aqui fica só
## o que os estados têm em comum.

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

## Para onde o minerador está olhando; escolhe a animação (ex.: "andar_cima").
var direcao := Vector2.DOWN

@onready var sprite: AnimatedSprite2D = $AnimatedSprite2D


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
