extends Estado
## Percebeu o jogador: vai atrás dele pelo caminho da navegação, contornando as
## paredes e batendo as asas mais rápido. Ao encostar, machuca (se o jogador
## não estiver piscando) e recua. Se o jogador se afastar além do raio de
## desistência, ou morrer, volta a vagar.

@onready var morcego := owner as Morcego


func entrar() -> void:
	morcego.sprite.speed_scale = 1.8


func atualizar_fisica(delta: float) -> void:
	var alvo := morcego.jogador()
	if alvo == null:
		transicao_pedida.emit(&"Vagando")
		return
	var distancia := morcego.global_position.distance_to(alvo.global_position)
	if distancia > morcego.raio_desistencia:
		transicao_pedida.emit(&"Vagando")
		return
	if distancia <= morcego.alcance_ataque:
		alvo.levar_dano(morcego.global_position)
		transicao_pedida.emit(&"Recuando")
		return
	morcego.definir_destino(alvo.global_position)
	morcego.seguir_caminho(morcego.velocidade_perseguindo, delta)
