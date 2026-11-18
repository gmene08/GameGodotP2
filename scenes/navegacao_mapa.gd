extends NavigationRegion2D
## Malha de navegação do mapa, usada pelos inimigos para achar caminho até o
## jogador sem atravessar parede. A área navegável é o contorno (outline) do
## NavigationPolygon, do tamanho do mapa; os obstáculos são as colisões dos
## tiles dos nós do grupo "navegacao" e dos filhos deles (a raiz do mapa está
## nesse grupo, então todo tile com colisão conta).
##
## A malha é gerada ("assada") toda vez que o mapa abre, então sempre bate com
## as paredes, mesmo depois de editar o mapa. Para vê-la no editor, selecione
## este nó e clique em "Assar NavigationPolygon"; no jogo, ligue
## Depurar > Navegação Visível.


func _ready() -> void:
	# false = assa agora, sem thread: leva poucos milissegundos e assim a malha
	# já está pronta antes do primeiro morcego sair.
	bake_navigation_polygon(false)
