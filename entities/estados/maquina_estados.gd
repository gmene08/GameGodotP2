class_name MaquinaEstados
extends Node
## Máquina de estados genérica: os estados são os nós filhos (scripts que
## estendem Estado) e só o estado atual roda a cada frame de física.
## Serve para o jogador e, depois, para os inimigos.

signal estado_mudou(anterior: Estado, novo: Estado)

@export var estado_inicial: Estado

var estado_atual: Estado

var _estados: Dictionary[StringName, Estado] = {}


func _ready() -> void:
	for filho in get_children():
		var estado := filho as Estado
		if estado:
			_estados[estado.name] = estado
			estado.transicao_pedida.connect(_trocar_para)

	# Os filhos ficam prontos antes do pai: espera o personagem terminar o
	# _ready() para os estados já poderem usar as variáveis @onready dele.
	if not owner.is_node_ready():
		await owner.ready
	estado_atual = estado_inicial
	estado_atual.entrar()


func _physics_process(delta: float) -> void:
	estado_atual.atualizar_fisica(delta)


func _trocar_para(proximo: StringName) -> void:
	if not _estados.has(proximo):
		push_error("Estado \"%s\" não existe em %s." % [proximo, get_path()])
		return
	var anterior := estado_atual
	anterior.sair()
	estado_atual = _estados[proximo]
	estado_atual.entrar()
	estado_mudou.emit(anterior, estado_atual)
