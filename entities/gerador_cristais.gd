extends Node2D
## Vai no nó PontosDeCristal do mapa. Faz cristais nascerem nos pontos
## (os Marker2D filhos), sempre num ponto livre e longe do jogador, até ter
## `maximo_no_mapa` cristais ao mesmo tempo. Cada cristal vira filho do seu
## ponto, então ponto com filho = ponto ocupado.

const CENA_CRISTAL := preload("res://entities/cristal.tscn")

@export var maximo_no_mapa := 3
## Segundos entre um cristal nascer e o próximo.
@export var intervalo := 2.0
## Cristal não nasce mais perto do jogador que isso (px), senão seria pego na hora.
@export var distancia_minima_do_jogador := 48.0

var _timer := Timer.new()


func _ready() -> void:
	_timer.wait_time = intervalo
	_timer.timeout.connect(_gerar_cristal)
	add_child(_timer)
	_timer.start()
	# Já começa com o mapa cheio para o jogador ter o que pegar.
	for i in maximo_no_mapa:
		_gerar_cristal()


func _gerar_cristal() -> void:
	var jogador := get_tree().get_first_node_in_group(&"jogador") as Node2D
	var livres: Array[Marker2D] = []
	var no_mapa := 0
	for filho in get_children():
		var ponto := filho as Marker2D
		if ponto == null:
			continue
		if ponto.get_child_count() > 0:
			no_mapa += 1
		elif jogador == null or ponto.global_position.distance_to(jogador.global_position) >= distancia_minima_do_jogador:
			livres.append(ponto)
	if no_mapa < maximo_no_mapa and not livres.is_empty():
		livres.pick_random().add_child(CENA_CRISTAL.instantiate())
