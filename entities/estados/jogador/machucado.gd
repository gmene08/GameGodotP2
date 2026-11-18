extends Estado
## Acabou de levar dano: fica avermelhado e sem controle por um instante,
## enquanto o empurrão (a velocidade que o Jogador deixou pronta em
## levar_dano) vai freando. A invencibilidade, piscando, dura mais que este
## estado e fica no Jogador.

@export var duracao := 0.3

var _tempo := 0.0

@onready var jogador := owner as Jogador


func entrar() -> void:
	_tempo = 0.0
	jogador.tocar_animacao("parado")
	jogador.sprite.self_modulate = Color(1.0, 0.45, 0.45)


func sair() -> void:
	jogador.sprite.self_modulate = Color.WHITE


func atualizar_fisica(delta: float) -> void:
	_tempo += delta
	jogador.mover(Vector2.ZERO, delta)
	if _tempo >= duracao:
		transicao_pedida.emit(&"Parado")
