extends Estado
## Igual ao andar, só que mais rápido. Não tem animação própria de correr: usa a
## de andar acelerada na mesma proporção da velocidade, para os passos acompanharem.

@onready var jogador := owner as Jogador


func atualizar_fisica(delta: float) -> void:
	var entrada := jogador.ler_entrada()
	if entrada == Vector2.ZERO:
		transicao_pedida.emit(&"Parado")
		return
	if not jogador.quer_correr():
		transicao_pedida.emit(&"Andando")
		return
	jogador.atualizar_direcao(entrada)
	jogador.mover(entrada * jogador.velocidade_correndo, delta)
	jogador.tocar_animacao("andar", jogador.velocidade_correndo / jogador.velocidade_andando)
