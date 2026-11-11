class_name Estado
extends Node
## Classe base dos estados. Cada estado é um nó filho de uma MaquinaEstados
## e só recebe atualizar_fisica() enquanto for o estado atual.

## Emita para trocar de estado, passando o nome do nó do próximo estado
## (ex.: transicao_pedida.emit(&"Correndo")).
signal transicao_pedida(proximo: StringName)


## Chamado quando a máquina entra neste estado.
func entrar() -> void:
	pass


## Chamado quando a máquina sai deste estado.
func sair() -> void:
	pass


## Chamado a cada frame de física enquanto este for o estado atual.
func atualizar_fisica(_delta: float) -> void:
	pass
