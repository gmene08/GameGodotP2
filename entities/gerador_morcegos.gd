extends Node2D
## Vai no nó SaidasMorcegos do mapa. De tempos em tempos solta um morcego por
## uma das saídas (os Marker2D filhos, que ficam nos túneis dentro das
## paredes), até ter `maximo_no_mapa` morcegos voando ao mesmo tempo.
## O morcego sai na direção para onde a saída aponta: sem rotação é para baixo;
## gire o Marker2D se fizer um túnel virado para outro lado.

const CENA_MORCEGO := preload("res://entities/morcego.tscn")

@export var maximo_no_mapa := 4
## Segundos entre um morcego sair e o próximo.
@export var intervalo := 4.0
## Espera antes do primeiro morcego, para o jogador se situar no mapa.
@export var atraso_inicial := 2.0
## Saída mais perto do jogador que isso (px) não solta morcego, senão ele
## nasceria em cima do jogador, sem chance de reagir.
@export var distancia_minima_do_jogador := 64.0

var _timer := Timer.new()


func _ready() -> void:
	# Timer de uma vez só, religado a cada morcego: assim a primeira espera
	# (atraso_inicial) pode ser diferente das outras (intervalo).
	_timer.one_shot = true
	_timer.timeout.connect(_ao_terminar_espera)
	add_child(_timer)
	_timer.start(atraso_inicial)


func _ao_terminar_espera() -> void:
	_soltar_morcego()
	_timer.start(intervalo)


func _soltar_morcego() -> void:
	if get_tree().get_nodes_in_group(&"morcegos").size() >= maximo_no_mapa:
		return
	var jogador := get_tree().get_first_node_in_group(&"jogador") as Node2D
	var livres: Array[Marker2D] = []
	for filho in get_children():
		var saida := filho as Marker2D
		if saida == null:
			continue
		if jogador == null or saida.global_position.distance_to(jogador.global_position) >= distancia_minima_do_jogador:
			livres.append(saida)
	if livres.is_empty():
		return
	var saida: Marker2D = livres.pick_random()
	var morcego := CENA_MORCEGO.instantiate() as Morcego
	morcego.position = saida.position
	morcego.direcao_saida = Vector2.DOWN.rotated(saida.global_rotation)
	add_child(morcego)
