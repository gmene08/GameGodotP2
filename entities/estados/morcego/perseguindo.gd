extends Estado
## Percebeu o jogador: vai atrás dele pelo caminho da navegação, contornando as
## paredes e batendo as asas mais rápido. Se o jogador se afastar além do raio
## de desistência, volta a vagar.

@onready var morcego := owner as Morcego


func entrar() -> void:
	morcego.sprite.speed_scale = 1.8


func atualizar_fisica(delta: float) -> void:
	var alvo := morcego.jogador()
	if alvo == null or morcego.global_position.distance_to(alvo.global_position) > morcego.raio_desistencia:
		transicao_pedida.emit(&"Vagando")
		return
	morcego.definir_destino(alvo.global_position)
	morcego.seguir_caminho(morcego.velocidade_perseguindo, delta)
