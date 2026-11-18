extends CanvasLayer
## Interface da fase: vida, cristais (coletados/meta), o anúncio da fase no
## começo e as telas de pausa, fim de jogo, fase concluída e vitória.
## É o HUD que percebe que a fase acabou e pede a próxima cena ao Jogo
## (autoload). Roda mesmo com o jogo pausado (process_mode = Always) para os
## botões das telas funcionarem.

@export var coracao_cheio: Texture2D
@export var coracao_vazio: Texture2D

var _jogador: Jogador
var _meta := 0
## Vitória ou derrota já aconteceu: o Esc não pausa/despausa mais.
var _fase_acabou := false
## O que o botão principal da tela aberta faz (continuar, próxima fase...).
var _acao_principal := Callable()

@onready var vida: HBoxContainer = $Vida
@onready var quantidade: Label = $Cristais/Quantidade
@onready var anuncio: Control = $Anuncio
@onready var tela: Control = $Tela
@onready var titulo: Label = %Titulo
@onready var texto: Label = %Texto
@onready var botao_principal: Button = %BotaoPrincipal
@onready var botao_menu: Button = %BotaoMenu


func _ready() -> void:
	tela.hide()
	botao_principal.pressed.connect(func() -> void: _acao_principal.call())
	botao_menu.pressed.connect(Jogo.voltar_ao_menu)
	var fase := Jogo.entrar_na_fase(owner.scene_file_path if owner else "")
	_meta = fase.meta
	_anunciar(fase)
	_jogador = get_tree().get_first_node_in_group(&"jogador") as Jogador
	if _jogador == null:
		return
	_jogador.cristais_mudou.connect(_ao_mudar_cristais)
	_jogador.vida_mudou.connect(_mostrar_vida)
	_jogador.morreu.connect(_ao_morrer)
	_ao_mudar_cristais(_jogador.cristais)
	_mostrar_vida(_jogador.vida, _jogador.vida_maxima)


func _unhandled_input(event: InputEvent) -> void:
	if _fase_acabou or not event.is_action_pressed(&"pausar"):
		return
	get_viewport().set_input_as_handled()
	if tela.visible:
		_fechar_tela()
	else:
		_abrir_tela("Pausado", "WASD ou setas: andar\nShift: correr", "Continuar", _fechar_tela)


## Mostra o nome e a meta da fase por alguns segundos e some.
func _anunciar(fase: Dictionary) -> void:
	$Anuncio/NomeFase.text = "Fase %d: %s" % [Jogo.fase_atual + 1, fase.nome]
	$Anuncio/Objetivo.text = "Pegue %d cristais e fuja dos morcegos" % fase.meta
	var tween := create_tween()
	tween.tween_interval(2.5)
	tween.tween_property(anuncio, "modulate:a", 0.0, 0.8)


func _mostrar_vida(atual: int, maxima: int) -> void:
	while vida.get_child_count() < maxima:
		vida.add_child(TextureRect.new())
	for i in vida.get_child_count():
		var coracao := vida.get_child(i) as TextureRect
		coracao.texture = coracao_cheio if i < atual else coracao_vazio


func _ao_mudar_cristais(total: int) -> void:
	quantidade.text = "%d/%d" % [total, _meta]
	if total < _meta or _fase_acabou:
		return
	_fase_acabou = true
	Jogo.concluir_fase(total)
	# Adiado: o cristal é pego no meio da física, e a tela pausa o jogo.
	_mostrar_fim_da_fase.call_deferred(total)


func _mostrar_fim_da_fase(total: int) -> void:
	if Jogo.eh_ultima_fase():
		_abrir_tela("Você venceu!", "Você saiu da mina com %d cristais." % Jogo.cristais_da_partida,
				"Jogar de novo", Jogo.novo_jogo)
	else:
		_abrir_tela("Fase concluída!", "%d cristais coletados.\nPróxima: %s" % [total, Jogo.nome_da_proxima_fase()],
				"Próxima fase", Jogo.proxima_fase)


func _ao_morrer() -> void:
	if _fase_acabou:
		return
	_fase_acabou = true
	_abrir_tela("Fim de jogo", "Os morcegos te pegaram.\nCristais: %d/%d" % [_jogador.cristais, _meta],
			"Tentar de novo", Jogo.reiniciar_fase)


func _abrir_tela(titulo_tela: String, texto_tela: String, rotulo_botao: String, acao: Callable) -> void:
	titulo.text = titulo_tela
	texto.text = texto_tela
	botao_principal.text = rotulo_botao
	_acao_principal = acao
	anuncio.hide()
	tela.show()
	botao_principal.grab_focus()
	get_tree().paused = true


func _fechar_tela() -> void:
	tela.hide()
	get_tree().paused = false
