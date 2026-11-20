extends Estado
## Ainda não percebeu o jogador: voa devagar de um ponto a outro ali por perto,
## sempre por caminhos livres. Quando o jogador entra no raio de detecção,
## começa a perseguir.

## Distância máxima (px) do próximo ponto para onde voar.
@export var alcance := 80.0
## Troca de destino depois desse tempo mesmo sem chegar (ex.: outro morcego no caminho).
@export var tempo_maximo := 3.0

var _tempo := 0.0

@onready var morcego := owner as Morcego


func entrar() -> void:
	morcego.sprite.speed_scale = 1.0
	_escolher_destino()


func atualizar_fisica(delta: float) -> void:
	# Agro dos morcegos feito com ajuda de IA.
	if morcego.distancia_do_jogador() <= morcego.raio_deteccao:
		transicao_pedida.emit(&"Perseguindo")
		return
	_tempo += delta
	if _tempo >= tempo_maximo or morcego.agente.is_navigation_finished():
		_escolher_destino()
	morcego.seguir_caminho(morcego.velocidade_vagando, delta)


## Sorteia um ponto em volta do morcego. Se cair dentro de uma parede, a
## navegação leva até o ponto livre mais perto dele.
func _escolher_destino() -> void:
	_tempo = 0.0
	var deslocamento := Vector2.from_angle(randf() * TAU) * randf_range(alcance / 2.0, alcance)
	morcego.definir_destino(morcego.global_position + deslocamento)
