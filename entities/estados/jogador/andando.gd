extends Estado
## Anda na velocidade normal enquanto houver entrada sem o botão de correr.

@onready var jogador := owner as Jogador


func atualizar_fisica(delta: float) -> void:
	var entrada := jogador.ler_entrada()
	if entrada == Vector2.ZERO:
		transicao_pedida.emit(&"Parado")
		return
	if jogador.quer_correr():
		transicao_pedida.emit(&"Correndo")
		return
	jogador.atualizar_direcao(entrada)
	jogador.mover(entrada * jogador.velocidade_andando, delta)
	jogador.tocar_animacao("andar")
