extends Control
## Tela inicial (cena principal do projeto). "Jogar" começa a campanha pela
## primeira fase; a ordem das fases fica em scenes/jogo.gd.

@onready var jogar: Button = %Jogar
@onready var sair: Button = %Sair


func _ready() -> void:
	jogar.pressed.connect(Jogo.novo_jogo)
	sair.pressed.connect(get_tree().quit)
	# No navegador não dá para fechar o jogo.
	sair.visible = not OS.has_feature("web")
	jogar.grab_focus()
