extends Node
## Autoload "Jogo" (Projeto > Configurações do Projeto > Globais). Guarda a
## ordem das fases e quantos cristais cada uma pede, e faz as trocas de cena:
## menu -> fase 1 -> fase 2 -> ... -> vitória. Quem percebe que a fase acabou
## (meta batida ou jogador morto) é o HUD, que então chama as funções daqui.

const MENU := "res://ui/menu_principal.tscn"
## A campanha, em ordem. "meta" = cristais para passar da fase.
const FASES: Array[Dictionary] = [
	{"cena": "res://scenes/arena.tscn", "nome": "Arena da mina", "meta": 8},
	{"cena": "res://scenes/mapa_mina.tscn", "nome": "Galerias da mina", "meta": 10},
]

## Índice em FASES da fase em andamento.
var fase_atual := 0
## Soma dos cristais das fases já concluídas nesta partida.
var cristais_da_partida := 0

var _cena_atual := ""


## Começa a campanha do zero, pela primeira fase.
func novo_jogo() -> void:
	fase_atual = 0
	cristais_da_partida = 0
	_trocar_cena(FASES[0].cena)


## O HUD chama quando a fase abre. Acha a fase pelo arquivo da cena, então
## também funciona rodando um mapa direto (F6) sem passar pelo menu.
func entrar_na_fase(cena: String) -> Dictionary:
	_cena_atual = cena
	for i in FASES.size():
		if FASES[i].cena == cena:
			fase_atual = i
			return FASES[i]
	# Mapa fora da campanha (ex.: um mapa de teste): meta padrão.
	return {"cena": cena, "nome": cena.get_file().get_basename(), "meta": 10}


func eh_ultima_fase() -> bool:
	return fase_atual >= FASES.size() - 1


func nome_da_proxima_fase() -> String:
	return "" if eh_ultima_fase() else FASES[fase_atual + 1].nome


## Soma os cristais da fase que acabou de ser concluída.
func concluir_fase(cristais: int) -> void:
	cristais_da_partida += cristais


func proxima_fase() -> void:
	fase_atual = mini(fase_atual + 1, FASES.size() - 1)
	_trocar_cena(FASES[fase_atual].cena)


func reiniciar_fase() -> void:
	_trocar_cena(_cena_atual)


func voltar_ao_menu() -> void:
	_trocar_cena(MENU)


func _trocar_cena(cena: String) -> void:
	# Troca no fim do frame: o pedido pode vir no meio da física (ex.: ao pegar
	# o último cristal), e trocar ali apagaria nós que a física ainda está usando.
	_trocar_cena_agora.call_deferred(cena)


func _trocar_cena_agora(cena: String) -> void:
	get_tree().paused = false
	get_tree().change_scene_to_file(cena)
