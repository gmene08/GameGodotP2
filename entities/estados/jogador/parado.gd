extends Estado
## Sem entrada: freia até parar e fica na animação de parado.

@onready var jogador := owner as Jogador


func entrar() -> void:
	jogador.tocar_animacao("parado")


func atualizar_fisica(delta: float) -> void:
	if jogador.ler_entrada() != Vector2.ZERO:
		transicao_pedida.emit(&"Correndo" if jogador.quer_correr() else &"Andando")
		return
	jogador.mover(Vector2.ZERO, delta)
