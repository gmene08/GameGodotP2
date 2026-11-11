extends CanvasLayer
## Contador de cristais coletados, no canto da tela.

@onready var quantidade: Label = $Cristais/Quantidade


func _ready() -> void:
	var jogador := get_tree().get_first_node_in_group(&"jogador") as Jogador
	if jogador == null:
		return
	jogador.cristais_mudou.connect(_mostrar)
	_mostrar(jogador.cristais)


func _mostrar(total: int) -> void:
	quantidade.text = str(total)
