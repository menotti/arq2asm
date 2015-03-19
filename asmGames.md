

# Sokoban #

<p>Sokoban (倉庫番 sōkoban, warehouse keeper, funcionário de armazém) é um tipo de quebra-cabeça, no qual o jogador empurra caixas para suas devidas posições no armazém. O jogador só pode empurrar as caixas, nunca puxá-las. O objetivo do jogo é resolver os quebra-cabeças com o menor número de movimentos possível.</p>
<br>
<p>Referencia: <a href='http://sokoban.info/'><a href='http://sokoban.info/'>http://sokoban.info/</a></a></p>

<h1>Detalhes</h1>
<p>O jogo é dividido da seguinte forma:</p>

<hr />

<h2>GeeckoGamesSokoban.asm</h2>
<p>Esse é o arquivo principal do jogo. Ele inicia o jogo, controla o loop e chama todas as outras funções do jogo. </p>
<h2>GeeckoGamesSokoban</h2>
<p>É a função inicial do jogo. Ela é chamada somente uma vez a partir do menu inicial do projeto. Ela define a cor de fundo do console como branca e a cor de texto como preta pra facilitar a visualização. Ela desenha a tela inicial, quando o usuário aperta “enter” ela inicializa a primeira fase do jogo entrando no game loop.O game loop é uma parte do código onde esperamos um input do usuário, o processamos e chamamos a função que deve tratar disso. Ao final do processamento, chamamos as funções de desenhar na tela.</p>
<p>
Ao termino de uma fase, checamos se existe uma próxima fase para ser jogada. Se não existir o jogo exibe a tela final.<br>
</p>
<h2>UpdateGame</h2>
<p>
É a função responsável por atualizar o jogo logicamente. Ela espera um input do usuário e o processa, chamando a função de mover personagem quando necessária. Caso o input não seja de movimentação é definida uma “flag” que será tratada no game loop.<br>
</p>

<hr />

<h2>GeeckoGamesFileIO.asm</h2>

<p>É onde se encontram todas as funções de escrita e leitura de arquivos. </p>
<p>O mapa está salvo no arquivo sequencialmente em duas camadas e score. Primeiro a camada background, depois a camada interactive e no fim do arquivo o score.</p>
<h2>ReadMap</h2>
<p>Le o mapa de um arquivo. Para fazer isso recebe o tamanho do mapa, o nome do mapa e o endereço na memória em que deve ser colocado. </p>
<h2>UpdateMapName</h2>
<p>Função que simplesmente incrementa um no nome do mapa. Para isso ela utiliza o nome do mapa que está em uma variável global.</p>
<h2>SaveNewMapScore</h2>
<p>Função que atualiza o menor número de movimentos do jogador em uma fase. Essa função não analisa se o score é realmente menor. Essa verificação é feita antes dessa função ser chamada. Ela recebe como parâmetro onde o mapa está na memória, o tamanho do mapa e o nome do mapa.</p>

<hr />

<h2>GeeckoGamesDrawing.asm</h2>

<p>É o arquivo onde estão implementadas as funções de desenhar na tela. O jogo trabalha com duas camadas: background e interactive. Na camada background estão as paredes e os alvos. Na camada interactive estão o personagem e os diamantes.</p>
<h2>DrawBackground</h2>
<p>É a função que desenha as paredes e alvos do mapa. Recebe como parâmetros o tamanho do mapa, endereço da camada background e o tamanho da linha.</p>
<h2>DrawInteractive</h2>
<p>É a função que desenha os diamantes e o personagem do mapa. Quando um diamante está em cima de um alvo, a cor do mesmo muda. Recebe como parâmetros o tamanho do mapa, endereço da camada interactive, endereço da camada background e o tamanho da linha.</p>
<p>Devido às dificuldades encontradas em se achar um editor de texto cujo output tivesse uma codificação de caracteres comum àquela usada pelo console do asm fizemos uso de caracteres comuns (<code>*</code>, 0, +, x) para representar nossos objetos e na hora de desenhá-los os trocamos por caracteres especiais que deixaram o jogo mais agradável aos olhos.</p>

<h2>DrawMainScreen</h2>
<p>Desenha a tela inicial do jogo(menu). Não recebe nenhum parâmetro pois a tela está salva em uma variável global.</p>
<h2>DrawFinishedGame</h2>
<p>Desenha a tela final do jogo. Não recebe nenhum parâmetro pois a tela está salva em uma variável global.</p>
 <br>
<hr />

<h2>GeeckoGamesLogic.asm</h2>
<p>É o arquivo que contem uma única função para checar o final de jogo.</p>
<h2>CheckMapState</h2>
<p>Essa função verifica se todos os diamantes estão sobre um alvo, ou seja, fase completa. Ela recebe o endereço da camada background, o endereço da camada interactive e o tamanho do mapa. Ela define uma flag para avisar se a fase já terminou.</p>
 <br>
<hr />

<h2>GeeckoGamesCharacterControl.asm</h2>
<p>É o arquivo que controla a movimentação de elementos dentro do jogo.</p>

<h2>MoveChar</h2>
<p>É a função que move efetivamente o personagem. Ela checa a possibilidade de movimento e chama quando necessário MoveDiamond. Recebe o endereço da camada background, o endereço da camada interactive, o tamanho da linha, o tamanho do mapa, a posição do personagem e a direção do movimento.</p>

<h2>MoveDiamond</h2>
<p>É a função que tenta mover um diamante quando necessário. Recebe o endereço da camada background, o endereço da camada interactive, o tamanho da linha, o tamanho do mapa, a posição do personagem e a direção do movimento.</p>

<h2>GetCharPos</h2>
<p>É a função que procura no mapa onde está o personagem e retorna esse valor em uma variável passada por referência. Essa função recebe o endereço da camada interactive, o tamanho do mapa, o tamanho da linha e onde deve ser retornada a posição xy do personagem.</p>


<h1>Space Invaders</h1>

Jogo que buscamos implementar: Space Invaders<br>
Basicamente, o conceito  do jogo se resume a inimigos gerados no topo da tela que descem aos poucos, e o jogador, fixo na base da tela, deve se posicionar de maneira a eliminar os inimigos com seus tiros (trajetória linear) antes que os inimigos consigam tocar a base da tela.<br>
Para mais informações, <a href='http://pt.wikipedia.org/wiki/Space_Invaders'>http://pt.wikipedia.org/wiki/Space_Invaders</a>

Seguimos o conceito inicial, e criamos um jogo no qual você está na base, seus inimigos são gerados aleatoriamente no topo da tela, e a dificuldade aumenta de acordo com sua pontuação atual.<br>
<br>
<h2>Detalhes</h2>

O jogo tem basicamente a seguinte estrutura:<br>
<h3>Inicialização das variáveis:</h3>
O programa realiza o "set" de suas variáveis para iniciar uma nova partida, como limpar a tela, desenhar as linhas do fundo da tela, desenhar o personagem no centro da tela, carregar as dificuldades do arquivo de dificuldades, e iniciar o gerador de inimigos.<br>
<br>
<h3>Game Loop:</h3>
Dentro do Gameloop, temos um trecho inicial que inicializa inimigos, por meio de verificação de tempo. Essa verificação é exatamente o que dá ao jogo sua dificuldade. A dificuldade na verdade corresponde ao tempo entre geração de inimigos, em milisegundos.<br>
Nossa verificação vê quanto tempo se passou desde que o último inimigo foi gerado. Se o tempo for maior do que a dificuldade, outro inimigo é gerado nessa iteração do gameloop.<br>
<br>
Em seguida, após gerar um novo inimigo(inicializa as variáveis do inimigo), entramos no trecho de código que realiza leituras constantes do teclado. Este trecho corresponde a um dos maiores problemas que encontramos na implementação, que só conseguimos aperfeiçoar após muitas tentativas. O grande desafio estava em realizar essa leitura constante das teclas e ter precisão de leitura, ou seja, sempre que uma tecla fosse pressionada, o jogo deveria responder com precisão.<br>
Nossa solução, por fim, foi realizar um Delay de 10 milisegundos logo antes da leitura de teclas, pois assim a precisão da leitura aumenta, e o jogo finalmente ficou limpo quanto a isso. (Antes a leitura era travada, com teclas não sendo reconhecidas, ou sendo reconhecidas mais de uma vez.)<br>
<br>
Na leitura de teclas, o personagem nao sofre mudanças em sua posição, e sim variáveis de controle indicam que ele deverá sofrer essas mudanças. As mudanças são então computadas dentro do PROC EscrevePersonagem, na sessão de processamento do código.<br>
A parte mais importante aqui fica no caso de pressionar a barra de espaços. Quando ela é pressionada, um tiro deve ser gerado. Temos então um loop, que busca um tiro que não esteja em uso (em tela) e dá para ele a posição do jogador e inicializa o tiro.<br>
<br>
Depois disso, temos o processamento, ainda dentro do gameloop. Esse processamento começa com o update do nosso personagem, seguido da checagem de colisões, que podem modificar variáveis, por isso ela é a segunda parte a ser executada no processamento.<br>
Em seguida, os inimigos são escritos ou apagados, dependendo do resultado da checagem de colisões. Depois disso, temos a mesma situação agora para os tiros. A última coisa é a atualização do placar e da vida.<br>
<br>
Lembrando que todos os elementos que são modificados no processamento tem como parâmetros para serem escritos na tela os seus "tempos", que corresponde à ultima vez que o elemento foi atualizado, ou variáveis de existência, indicando se um elemento ainda existe ou não (tiros e inimigos), ou ainda variáveis de estado, indicando se algo deve ou não ser atualizado (personagem e placar/vida, por exemplo).<br>
<br>
A ultima coisa do gameloop é a verificação de se o jogo deve terminar, vendo se a vida do personagem chegou a zero. Se chegou, uma variável de fim de jogo é acionada , e a próxima iteração do gameloop terminará o jogo.<br>
<br>
<h3>Game Over:</h3>
Quando o jogo termina(vidas = 0), o programa entra na sessão do Game Over, que nada mais é do que uma limpeza geral da tela e informa que o jogo terminou, e indica a pontuação final do jogador nessa sessão.<br>
<br>
A verificação do highscore por arquivo acontece nessa parte também, por meio do procedimento carregaHighscore.<br>
<br>
<br>
<br>
<h2>Procedures</h2>
Nossas procedures foram as seguintes:<br>
<br>
<b>escreveTiro1</b>: Recebe em ESI um índice de qual tiro deve ser escrito. Esse tiro será atualizado em X e em Y, e será escrito em tela, ou no caso de uma colisão, o mesmo será deletado.<br>
<br>
<b>EscrevePersonagem</b>: Baseado nas variáveis de controle do personagem e do teclado, o procedure realiza o update da posição do personagem, e redesenha o personagem na tela.<br>
<br>
<b>escreveInimigo1</b>: Recebe em ESI o índice de um inimigo. Este inimigo será atualizado caso não exista colisão, e será desenhado em tela. No caso de colisão com um tiro, o inimigo é deletado, e a pontuação é incrementada. No caso de colisão com o chão, o inimigo é deletado e as vidas são decrementadas em 1.<br>
<br>
<b>gerarInimigos</b>: O procedimento apenas busca o primeiro inimigo disponível(não está em tela) e inicializa ele no topo da tela, com um X aleatório, dentro do espaço indicado pela tela do jogador.<br>
<br>
<b>checaColisões</b>: Verifica se os tiros atingiram algum inimigo, e indica isso ao jogo por meio das variáveis de controle dos inimigos e dos tiros.<br>
<br>
<b>verificaScore</b>: Vê se a dificuldade deve ser alterada, observando o score do jogador.<br>
<br>
<b>reinicializaVariaveis</b>: Apenas reinicia tudo, caso o jogador deseje iniciar outra sessão do jogo, a partir do menu inicial que o professor Menotti escreveu.<br>
<br>
<b>intToString</b>: Converte um inteiro para string.<br>
<br>
<b>carregaHighscore</b>: Carrega e atualiza o arquivo de highscore. Crian ovo arquivo caso não exista nenhum.<br>
<br>
<h2>Arquivo complementar:</h2>
Nosso jogo também faz uso de um arquivo complementar "dificuldades.txt", cujo conteúdo corresponde aos valores, em milisegundos, dos intervalos de geração de inimigos. Estes valores são carregados no início do jogo, e são utilizados como parâmetros na geração de inimigos novos.<br>
<br>
Além disso, usamos um arquivo "highscore.txt", cujo conteúdo é apenas uma string que contem 3 caracteres com o nome de quem fez o highscore, e  o highscore em seguida.<br>
<br>
<br>
<br>
<h1>Snake</h1>

O jogo Snake se trata de um dos mais tradicionais jogos presentes no mundo, onde um segmento de 3 quadrados consecutivos (normalmente são 3, em algumas implementações do jogo mais, menos ou mesmo outras representações que não sejam quadrados) se movimenta pela tela. Esse segmento é chamado de "cobra" (uma alusão ao próprio réptil) e tem como objetivo movimentar-se na tela a procura de quadrados menores os quais são intitulados como "comida". Quando a cobra chega com seu primeiro quadrado em cima da comida, o segmento da própria cobra aumenta em um quadrado. O jogo segue assim até a cobra chocar-se com um quadrado de seu próprio corpo ou com o limite da tela destinado para ela andar.<br>
<br>
O jogador tem o controle sobre os movimentos da cobra e visualiza a comida, procurando então comê-la para que o tamanho da cobra aumente, quanto maior a cobra ficar até o final do jogo, maior a pontuação do jogador.<br>
<br>
<h2>Detalhes da Implementação</h2>
Os procedimentos de desenho e movimentação, junto com algumas verificações, são feitas no segmento de código chamado "GameLoop" em que é repetido em intervalos de 60 milisegundos. As verificações feitas são de colisão com paredes (verificaColisao), colisão com a própria cobra (autoColisao), de passar pela comida (come) e de teclas lidas pelo teclado (identificaDirecao).<br>
<br>
Os procedimentos de atualização de pontuações são feitos, em sua maioria, separado ao restante do controle do jogo. Apenas a rotina de atualização de pontuação atual é feita utilizando-se da procedure "movimentaEDesenha" para atualizar a contagem de quanto tempo passou desde que a última comida apareceu. A rotina de pontuação é separada em três segmentos, são eles:<br>
<br>
<h3>Atualização da pontuação atual</h3>

A pontuação atual é atualizada a cada vez que o jogador come uma das comidas, sendo feita então um cálculo relacionado a quantos pontos extras ele terá de acordo com o tempo que ele demorou para comer. O cálculo é:<br>
<br>
<b>ValorMax</b> - valor maximo da razão de bônus<br>
<br>
<b>tempoUltimaComida</b> - tempo que o jogador demorou para comer a comida<br>
<br>
<b>numeroQuadradosCobra</b> - número de quadrados que a cobra tem no momento que comeu<br>
<br>
<b>Se (ValorMax - tempoUltimaComida) > 0</b>

pontuaçãoAtual += (ValorMax - tempoUltimaComida)/2*numeroQuadradosCobra<br>
<br>
<b>Senão</b>

pontuacaoAtual += numeroQuadradosCobra<br>
<br>
Essa razão beneficia quem demora pouco tempo até comer a comida gerada pelo jogo, estimulando o jogador a não ficar apenas se movimentando pela tela, mas sim a fazer o propósito do jogo, que é aumentar o número de quadrados da cobra.<br>
<br>
<h3>Atualização das melhores pontuações</h3>

Após o término do jogo, a variável pontuacaoAtual é comparada com os 5 valores do vetor melhoresPontuacoes (que é ordenado) e é colocada como uma das melhores pontuações dependendo de qual é a colocação que ela fica, isto é, se for a quinta melhor pontuação, ficará na quinta posição do vetor.<br>
<br>
Também é pedido um nome ao jogador quando o mesmo consegue uma das 5 melhores pontuações, armazenando tudo posteriormente no arquivo.<br>
<br>
<h3>Leitura e escrita do arquivo de melhores pontuações</h3>

Ao iniciar o jogo as 5 melhores pontuações são exibidas com os respectivos nomes dos jogadores que as fizeram. O acesso desses dados é feito acessando o arquivo melhoresPontuacoes.txt e cortando os valores do mesmo a cada "/" encontrado e guardando nas variáveis melhoresPontuacoes as pontuações e nas strings nomePontuacao1 até nomePontuacao5 os nomes dos jogadores que fizeram essas pontuações.<br>
<br>
A escrita é feita pegando os valores das mesmas variáveis e guardando no arquivo novamente, não esquecendo de colocar o "/" entre elas, para manter o arquivo no mesmo padrão. Foi necessária a criação de uma função que convertesse valores inteiros para string, para que a gravação das pontuações pudesse ser feita corretamente no arquivo.<br>
<br>
<h2>Procedures</h2>
<h2>autoColisao</h2>
Essa procedure tem por objetivo verificar se a cobra colidiu com ela mesma setando a flag colidiu para 1, faz isso comparando o valor do primeiro ponto da cobra com os demais valores do vetor cobraPontos, com o detalhe que o ponto que esta sendo verificado é trocado temporariamente por um valor que não representa uma coordenada na tela para que o primeiro ponto não seja considerado nas comparações.<br>
<br>
<h2>geraComida</h2>
Essa procedure tem por objetivo gerar coordenadas aleatórias para a posição da comida e desenhá-la com a cor amarela definida pela procedure setTextColor. Os números aleatórios são gerados pelas procedures randomize (gera semente) e randomRange (número aleatório dentro da tela). As coordenadas geradas não podem ter o mesmo valor da coordenada de qualquer ponto da cobra, por esse fato é feita uma busca em vetor, através da instrução "repne scasb", para verificar se a comida gerada tem posição diferente da cobra, caso tenha, uma nova comida é gerada.<br>
<br>
<h2>verificaColisao</h2>
Essa é uma procedure que verifica se a cobra colidiu com as paredes da extremidade da tela. Ela define colidiu como 1 quando duas condições são atendidas: o primeiro ponto da cobra estar em uma das extremidades da tela e a cobra estar se movimentando em direção à extremidade em questão.<br>
<br>
<h2>identificaDirecao</h2>
Essa procedure lê o teclado e muda a direção da cobra de acordo com a seta pressionada. Um controle de direção é feito, pois a cobra não pode mudar para a direção contrária a que está; se pudesse, ela estaria colidindo consigo mesma, terminando o jogo.<br>
<br>
<h2>movimentaEdesenha</h2>
Essa procedure é responsável pela lógica de movimentação dos pontos da cobra e pelo desenho dela na tela. Os pontos afetados pela procedure são apenas o primeiro e o último, de forma que o último ponto é apagado e desenhado a frente do primeiro se tornando o novo primeiro ponto, com suas coordenadas atualizadas e a variável cobraIndiceUltimo é atualizada com o índice do novo último ponto da cobra.<br>
<br>
<h2>exibeMelhoresPontuacoes</h2>
Essa procedure exibe as melhores pontuações através do acesso aos dados do arquivo de pontuação, também é a procedure que carrega nas variáveis as pontuações e o nome, para posterior comparação com as pontuações feitas e a atualização do arquivo.<br>
<br>
<h2>exibeMensagemErroArquivo</h2>
Caso o arquivo nao seja aberto corretamente, essa procedure será chamada, exibindo uma mensagem informando o erro.<br>
<br>
<h2>offsetNomePontuacoes</h2>
Procedure que, dado um parâmetro entre 1 e 5 passado em eax, retorna o OFFSET da variavel nomePontuacao correspondente.<br>
<br>
Ex: se eax for 2 o OFFSET retornado será o da variável nomePontuacao2<br>
<br>
<h2>escreveArquivoPontuacao</h2>
Escreve os dados de volta no arquivo de pontuação, pegando todos os dados das variáveis de nome e o vetor de valores e armazenando conforme o padrão inicial do arquivo.<br>
<br>
<h2>intParaString</h2>
Função que converte um valor inteiro em uma String.<br>
<br>
<h2>atualizaMelhoresPontuacoes</h2>
Procedure que atualiza as melhores pontuações comparando-as com a pontuação efetuada ao final do jogo.<br>
<br>
<h2>atualizaPontuacao</h2>
Atualiza no vetor a pontuação do jogador, seguindo a fórmula citada acima.<br>
<br>
<h2>mostraPontuacaoAtual</h2>
Atualiza na tela a pontuação do jogador.<br>
<br>
<h2>mostraCabecalhoPontuacao</h2>
Procedure que carrega os limites inferiores da tela e as mensagens de melhor pontuação realizada e pontuação atual (iniciada com 0 nesse instante)<br>
<br>
<h2>come</h2>
A procedure verifica se o primeiro ponto da cobra é igual as coordenadas da comida. Se forem iguais um ponto é inserido ordenadamente à cobra na última posicão, pois a última posicão não é fixa.<br>
<br>
<br>
<br>
<h1>Genius</h1>

<blockquote>O jogo projetado é conhecido como Genius, onde o objetivo é ver a sequência mostrada pelo jogo e ser repetida ao final da sequência. Ao conseguir sucesso, o próximo nível é somado mais um comando ao final da sequência.<br>
</blockquote><blockquote>Mais informações:  <a href='http://pt.wikipedia.org/wiki/Genius_(jogo'>http://pt.wikipedia.org/wiki/Genius_(jogo</a>)<br>
Exemplo de jogo :  <a href='http://neave.com/pt/genius/'>http://neave.com/pt/genius/</a></blockquote>


<h2>Detalhes de estrutura</h2>

<blockquote>O game tem início com a criação de uma sequência com 30 comandos, criados aleatoriamente podendo ser cima, baixo, direita ou esquerda.<br>
Genius tem a entrada de comandos feita pelas teclas de direção, e de acordo com o comando armazenado, seu respectivo bloco será destacado na tela de execução.<br>
Em seguida o jogador inicia no level 1, assim deve conter apenas 1 comando para ser memorizado pelo jogador, e se conseguir sucesso ele passa de nível, aumentando mais um comando no próximo level. Caso o jogador erre, o jogo é encerrado.</blockquote>

<h2>Procedures</h2>

<h2>Menu</h2>

<blockquote>O procedimento Menu tem como objetivo mostrar as instruções e o objetivo do jogo logo na tela inicial da execução. Além de ter a espera de leitura de uma tecla para prosseguir para a próxima tela.<br>
Na próxima tela, temos uma espera para que o jogador possa se preparar.</blockquote>


<h2>CriaSequência</h2>

<blockquote>O CriaSequencia tem como objetivo criar os 30 comandos da sequencia utilizando o RandomRange variando de 0 a 3, onde cada número tem sua respectiva direção para ser associada, e assim que criado é armazenado na memória o código das setas do teclado.</blockquote>

<h2>MostraSequencia</h2>

<blockquote>O MostraSequencia tem como função mostrar os comandos respectivo da fase atual e de acordo do comando ele vai destacando o seu bloco na tela de execução.</blockquote>


<h2>Imprime(Cor)</h2>
Obs: (Cor) deve ser substituída pela cor do quadrado que deseja imprimir na tela (vermelhor, azul, verde ou amarelo)<br>
<br>
<br>
<blockquote>A impressão dos quadrados do jogo na tela é feita de forma análoga para os quatro quadrados:<br>
Ulitaza-se o proc GotoXY aponta para a vértice superior esquerda para então escrever um caracter por vez até completar uma linha (17 vezes), e ao completá-la, e assim mudar de linha e repetir até formar as 10 linhas de 17 elementos.<br>
Amarelo é o quadrado acionado pela seta CIMA.<br>
Vermelho é o quadrado acionado pela seta BAIXO.<br>
Verde é o quadrado acionado pela seta DIRETA.<br>
Azul é o quadrado acionado pela seta ESQUERDA.</blockquote>

<h2>ImprimeJogo</h2>

<blockquote>Esta função chama as funções que imprimem os principais objetos da tela: imprimeAmarelo, imprimeAzul, imprimeVerde e imprimeVermelho que imprimem os blocos coloridos na tela, além de imprimir o rótulo "Genius!".</blockquote>

<h2>PiscaAmarelo</h2>
<blockquote>Esta função define as coordenadas (x,y) do bloco amarelo e chama a função "Pisca" que sobrescreve um bloco de cor branca sobre o bloco amarelo a partir das coordenadas.</blockquote>

<h2>PiscaVermelho</h2>
<blockquote>Esta função define as coordenadas (x,y) do bloco vermelho e chama a função "Pisca" que sobrescreve um bloco de cor branca sobre o bloco vermelho a partir das coordenadas.</blockquote>

<h2>PiscaAzul</h2>
<blockquote>Esta função define as coordenadas (x,y) do bloco azul e chama a função "Pisca" que sobrescreve um bloco de cor branca sobre o bloco azul a partir das coordenadas.</blockquote>

<h2>PiscaVerde</h2>
<blockquote>Esta função define as coordenadas (x,y) do bloco verde e chama a função "Pisca" que sobrescreve um bloco de cor branca sobre o bloco verde a partir das coordenadas.</blockquote>

<h2>Pisca</h2>
Esta função recebe as coordenadas no registrador "EDX" e imprime linha por linha um bloco de cor branca a partir das coordenadas. Após a impressão na tela, é utilizada a função "Delay" que preserva o bloco na tela por alguns milisegundos e depois é chamada a função "ImprimeJogo" que imprime na tela os blocos iniciais.<br>
<br>
<br>
<br>
<br>
<h1>Labirinto</h1>

Documentação do jogo Labirinto da Morte, desenvolvido pela disciplina de Laboratório de Arquitetura e Organização de Computadores II.<br>
<br>
O objetivo do jogo consiste em um personagem O que percebe que sua mulher L some ao passar de um dia e segue suas pegadas a fim de encontra-la. O jogador deve seguir por vários labirintos obtendo medalhas de prata e ouro para conquistar novos labirintos.<br>
<br>
<b>Data de criação</b>: 12/12/2012<br>
<br>
<b>Última modificação</b>: 29/01/2013<br>
<br>
<hr />
<h2>Grupo de alunos</h2>

<ul><li>Camilo Moreira - 359645<br>
</li><li>George Pagliuso - 407623<br>
</li><li>Heitor Chiquito - 407500<br>
</li><li>Pedro Augusto Vicente - 407658</li></ul>

<hr />
<h2>Desenvolvimento</h2>

O jogo foi construído inicialmente baseado em um PACMAN, que é próximo de um labirinto. Depois, adaptando as funções, fomos chegando mais próximos do que imaginamos inicialmente, onde um personagem anda pelo labirinto com uma visão limitada (que é o nível de dificuldade) do início até o fim para prosseguir com outros detalhes.<br>
<br>
Nesta ordem, foram feitos: funções para carregar os labirintos do arquivo para memória, impressão desse arquivo em tela, mudanças de valores dentro da matriz na memória, funções que definem a jogabilidade do jogo (movimento e a visão) e a implementação dos menus. Em seguida, fomos adaptando essas funções para executar outros detalhes dentro dos mapas, e.g., o Minotauro no mapa do Minotauro, cenas iniciais e intermediárias, sistema de pontuação e fases liberadas a partir dessa pontuação.<br>
<br>
<hr />
<h2>Jogabilidade</h2>

Pelas setas do teclado, você deve andar pela labirinto até encontrar uma saída no menor número possível de passos.<br>
<br>
Setas :<br>
movimenta o usuário<br>
<br>
Caracteres:<br>
# - parede do labirinto<br>
<br>
O - o usuário/jogador<br>
<br>
L - a sua namorada sumida/fugitiva<br>
<br>
I - indica o início do labirinto. Se optar trocar de labirinto, volte até ele.<br>
<br>
F - final do labirinto.<br>
<br>
M - Minotauro. NÃO ENCARE ELE!<br>
<br>
X - Armadilha. NÃO PISE NELA!<br>
<br>
Você deve fazer um caminho de I até F de forma que seja a menor possível.<br>
<br>
A pontuação é calculada a partir da porcentagem de passos que você deu acima do RECORDE daquele labirinto.<br>
<br>
0 a 5% acima do melhor - medalha de ouro<br>
6 a 30% acima do melhor - medalha de prata<br>
31 a 60% acima do melhor - medalha de bronze<br>
61 em diante acima do melhor - sem medalha<br>
<br>
Você deve obter medalhas de prata e ouro para proseeguir em outros labirintos.<br>
<br>
<hr />
<h2>Sobre a implementação</h2>

Abaixo, a indicação de cada dado na memória com exceção dos caminhos de dados e mensagens:<br>
<br>
tamanhoX - numero de colunas dos mapas<br>
tamanhoY - numero de linhas dos mapas<br>
tamanhoM - tamanho total de uma mapa carregado do arquivo<br>
matriz - memoria destinada ao arquivo e a imagens carregadas durante as cenas<br>
<br>
posicao - posicao corrente do usuario em um labirinto<br>
posicaoS - posicao de saida de um labirinto<br>
posicaoVelha - onde é salvo a posicao corrente quando a mesma é alterada<br>
<br>
direcao - usado para identificar a direcao lida no teclado<br>
mapa - labirinto atual que o usuário está<br>
mapaPossivel - número de mapas que o usuário já liberou<br>
liberado - usado como auxiliar para desenhar o labirinto<br>
visao - tamanho da visão (dificuldade) escolhida pelo usuário<br>
lore - booleano para saber se a cena inicial já foi visualizada<br>
<br>
E os procedimentos definidos:<br>
<br>
PROC jogaLabirinto: onde está a lógica do jogo com os menus e as chamadas de funções que controlam a jogabilidade.<br>
<br>
PROC escreveMenu, escreveDificuldade, escreveOpcao,: mostra as opções do menu inicial, dificuldades e diz ao usuário opção para escolher, respectivamente. Separados para deixarem o códido mais limpo.<br>
<br>
PROC escreveFase: apesar de ser parecida com as funções anteriores, as fases só são carregadas de acordo com o mapaPossível, então exibe apenas as fases disponíveis para serem jogadas.<br>
<br>
PROC leLabirinto: carrega o labirinto a ser jogado na memória, chama as funções buscaPosicao e buscaPosicaoSaida<br>
<br>
PROC buscaPosicao: como cada labirinto tem entradas diferentes, essa função busca e deixa armazenado na memória a posição do usuário no mapa.<br>
<br>
PROC buscaPosicaoS: faz o mesmo que a função anterior, mas para a saída.<br>
<br>
PROC liberaMapa: deixa todo o mapa disponível ao usuário. Usada como auxiliar no desenvolvimento inicial.<br>
<br>
PROC desliberaMapa: reinicia o mapa liberado. Todo o mapa anterior ao cheat também é perdido.<br>
<br>
PROC escreveLabirinto: passa para o procedimento escreveChar para desenhar a parte já percorrida do mapa, mostra o número de passos percorridos do usuário, seu melhor tempo e o recorde (menor possível) do labirinto.<br>
<br>
PROC escreveChar: escreve os caracteres definidos no mapa. Para o usuário O, o início I, o fim F, o minotauro M, as armadilhas X e as paredes. Para as paredes, existe uma lógica que troca o valor da memória <code>*</code> por #, para saber o que já foi percorrido.<br>
<br>
PROC movimento: recebe a direção que o usuário escolheu e contém a lógica de movimenta quando possível o usuário no mapa.<br>
<br>
PROC verificaMovimento: verifica se o movimento é possível (não irá passar por cima de uma parede). Quando encontra alguns tipos de caracteres, não move, mas executa outras funções tais como mostrar que encontrou um Minotauro, um portal, uma armadilha ou voltou a tela de escolher as fases.<br>
<br>
PROC atualizaLabirinto: atualiza o que mudou no labirinto a cada passo. Aparece novas paredes e minotauros encontrados. O método carrega de acordo com o tamanho da visão (1 ou 2).<br>
<br>
PROC substituiParede: troca o valor de <code>*</code> por # na memória, para saber que aquela parede já foi descoberta no percurso. Chama a função substituiMino e substituiArmadilha.<br>
<br>
PROC substituiMino: idem a função anterior, troca o caractere P por M, quando o minotauro foi descoberto.<br>
<br>
PROC substituiArmadilha: idem a função anterior, troca o caractere A por X, quando a armadilha foi descoberta.<br>
<br>
PROC verificaBorda: verifica se o caractere lido está dentro ou fora do labirinto. Retorna 0 quando está fora e 1 quando está dentro. Apenas 0Dh e 0Ah devem ser valores fora do labirinto.<br>
<br>
PROC mostraPontuacao: função chamada quando um labirinto é completado. Calcula e exibe a medalha que o usuário irá ganhar. Adiciona o valor de mapaPossivel quando boas medalhas são obtidas.<br>
<br>
PROC esperaXms: espera o valor de EBX em milisecundos usando a função GetMseconds. Similar a função Delay do biblioteca Irvine, antes desconhecida.<br>
<br>
PROC mudaCores: recebe um valor específico em AL e escolhe um esquema de cores para ser mudado. Não é usado para colorir figuras, pois a lógica é um pouco diferente e depende dos caracteres.<br>
<br>
PROC mudaTelaPreta: similar a anterior, chamando tela preta com texto branco e limpando em seguida<br>
<br>
PROC loreInicial: função que mostra a história inicial do jogo. Exibida apenas 1 vez. Chamada pelo procedimento jogaLabirinto<br>
<br>
PROC chamaDialogoFinal: função que mostra a história final do jogo. Exibe duas figuras, uma parte em texto carregado do arquivo e algumas perguntas também carregado do arquivo. Após exibe os créditos.<br>
<br>
PROC chamaMorte: função que exibe uma morte quando você morre por meio de uma armadilha ou errou alguma pergunta do dragão.<br>
<br>
PROC escreveVoceMorreu: usada na função anterior. Devido a coloração foi deixada separada.<br>
<br>
PROC fazTeletransporte: usada para mudar o usuário de posição de acordo com algumas posições especiais no mapa.<br>
<br>
<h1>Frogger</h1>

#Descricao do projeto Frogger.<br>
<br>
<img src='http://sphotos-a.ak.fbcdn.net/hphotos-ak-ash3/528879_331991300240669_283131540_n.jpg' />

<i>Descrição: tela de introdução do jogo Frogger. Imagem carregada dinamicamente do arquivo Frogger.txt</i>

<h2>Introdução</h2>

Documentação do jogo Frogger, desenvolvido pela disciplina de Laboratório de Arquitetura e Organização de Computadores II.<br>
<br>
O objetivo do jogo consiste em, controlando um sapo, conseguir caminhar até o gramado do outro lado do cenário. O cenário oferece dois tipos de obstáculos: a rodovia e o rio. Para atravessar a rodovia, basta impedir que o sapo colida com qualquer um dos veículos. Para atravessar o rio, por outro lado, é necessário caminha pelos troncos flutuantes, sem deixar o sapo cair na água.<br>
<br>
<ul><li><b>Data de criação</b>: 18/12/2012<br>
</li><li><b>Última modificação</b>: 24/01/2013</li></ul>

<hr />
<h2>Grupo de alunos</h2>

<ul><li><b>Antonio Pedro Avanzi Nunes</b> - 407852<br>
</li><li><b>Lucas Oliveira David</b> - 407917<br>
</li><li><b>Pedro Padoveze Barbosa</b> - 407895</li></ul>

<hr />
<h2>Detalhes da implementação (versão 1.0)</h2>

O jogo foi dividido em duas partes. Uma lógica e uma gráfica. Ambas as partes funcionam de forma independente, a fim de garantir uma melhor integração entre diferentes trabalhos dos integrantes do grupo no código em si.<br>
<br>
Para a implementação da parte lógica, foi utilizado uma estrutura de dados do tipo tabela, de tamanho 15x15, representada a partir do vetor FROG_Campo. O vetor armazena valores inteiros de 16 bits.<br>
Cada inteiro representa um determinado objeto, e a parte gráfica do jogo será responsável por obter tais inteiros e associá-los a diferentes caracteres:<br>
<br>
<ul><li>0: chão ou tronco.<br>
</li><li>1 - 6: diferentes veículos que estão na rodovia.<br>
</li><li>7: água.<br>
</li><li>9: o sapo.</li></ul>

<i>Importante: todos os elementos do campo possuem o valor menor que o sapo! Isso é essencial para que a lógica funcione corretamente. Entretanto, tais valores podem variar. Em outras palavras, é possível criar novos objetos.</i>

A matriz do jogo é obtida de forma dinâmica de um arquivo texto "campo.txt".<br>
<br>
Quando as teclas são pressionadas, verificamos se o sapo está na fronteira da matriz através das variáveis <b>FROG_sapoX</b> e <b>FROG_sapoY</b>. Se sim, não fazemos nada. Caso contrário, subtraímos o valor do sapo na posição atual e adicionamos seu valor à nova posição, além de atualizar os indexadores FROG_sapoX e FROG_sapoY.<br>
<br>
A movimentação dos veículos acontece de forma similar: vetores armazenam quais linhas na matriz possuem veículos, seus sentidos e suas velocidades. A cada interação, o carro é movimentado para a esquerda ou direita através da subtração e da soma.<br>
<br>
No caso do rio, quem se move de fato é a água. Porém, tal efeito faz parece que quem está se movendo são os troncos. Nota-se que se o sapo estiver sobre um tronco qualquer, ele "se move" juntamente com esse, um fato que não ocorre durante a rotação do transito.<br>
<br>
A cada interação, de movimentação do sapo, dos veículos ou da água, um procedimento (FROG_VerificarColisao) é chamado. Esse procedimento varre toda a tabela e verificamos se existe algum elemento que seja maior que o valor do sapo. Se sim, sabemos que o sapo está ocupando a mesma posição que um carro, e o jogo é finalizado, exibindo a tela de derrota.<br>
<br>
A cada interação também é verificado se o valor do sapo é encontrado na primeira linha da matriz. Se sim, significa que o sapo atingiu a última faixa da rodovia. O jogo é finalizado e a tela de vitória, exibida.<br>
<br>
<hr />
<h2>Descrição das informações armazenadas</h2>

<h2>Constantes</h2>

<ul><li><b>FROG_SAPO_A</b>: define numérico referente ao sapo A!<br>
</li><li><b>FROG_SAPO_B</b>: define numérico referente ao sapo B!<br>
</li><li><b>FROG_CAMPO_TAM</b>: tamanho de entrada do campo extraído de um arquivo.<br>
</li><li><b>FROG_INTRO_TAM</b>: tamanho da introdução extraída do arquivo.<br>
</li><li><b>FROG_LINHAS</b>: n. de linhas da matriz que representa o campo.<br>
</li><li><b>FROG_COLUNAS</b>: n. de colunas da matriz que representa o campo.<br>
</li><li><b>FROG_CAMPO_INI_X</b>: define a coordenada X onde o mapa começará a ser desenhado.<br>
</li><li><b>FROG_CAMPO_INI_Y</b>: define a coordenada Y onde o mapa começará a ser desenhado.</li></ul>

<h2>Variáveis</h2>

<ul><li><b>FROG_respiracao</b>: variável auxiliar para a criação do efeito de respiração do sapo. Também utilizada para as animações dos obstáculos 7 e 8.<br>
</li><li><b>FROG_ganharamJogo</b>: mostra que os sapos ganharam o jogo.<br>
</li><li><b>FROG_Movimentos</b>: contabiliza os movimentos dos sapos.<br>
</li><li><b>FROG_Movimento_Total</b>: contabiliza os movimentos dos sapos das fases que já passaram.</li></ul>

<h3>Variáveis de Movimentos</h3>

<ul><li><b>FROG_TransitoLinha</b>: armazena quais das FROG_LINHAS da matriz contem elementos nocivos ao sapo.<br>
</li><li><b>FROG_TransitoVeloc</b>: armazena a velocidade com que os elementos contidos nas FROG_LINHAS referenciadas por FROG_TransitoLinha andam no<br>
cenário.<br>
</li><li><b>FROG_VelocAtual</b>: serve como contador para ajustar o delay de velocidade sem perder os valores de FROG_TransitoVeloc<br>
</li><li><b>FROG_TransitoSentido</b>: armazena o sentido dos elementos contidos em FROG_TransitoLinha.</li></ul>

<h3>Variáveis Relativas a Arquivo</h3>

<ul><li><b>FROG_Intro</b>: matriz que armazena imagem da tela de introdução.<br>
</li><li><b>FROG_Campo</b>: o campo por onde toda a lógica do jogo está estruturada.<br>
</li><li><b>FROG_Campo_Temp</b>: matriz temporária no processo de leitura do arquivo.<br>
</li><li><b>FROG_fCampo</b>: arquivo de inicialização do campo. Default: (src/Frogger/campo.txt)<br>
</li><li><b>FROG_fIntro</b>: arquivo do desenho inicial do sapo. Default: (src/Frogger/frogger.txt)<br>
</li><li><b>FROG_fHandle</b>: manipulador geral dos arquivos.</li></ul>

<h3>Variáveis do Sapo A</h3>

<ul><li><b>FROG_sapoA_X</b>: armazena a posição horizontal do sapo A no campo.<br>
</li><li><b>FROG_sapoA_Y</b>: armazena a posição vertical do sapo A no campo.<br>
</li><li><b>FROG_ApassouFase</b>: verifica se o sapo A passou de fase.<br>
</li><li><b>FROG_AperdeuJogo</b>: verifica se o sapo A perdeu.<br>
</li><li><b>FROG_A_Vidas</b>: contabiliza o número de vidas do sapo A.</li></ul>

<h3>Variáveis do Sapo B</h3>

<ul><li><b>FROG_sapoB_X</b>: armazena a posição horizontal do sapo B no campo.<br>
</li><li><b>FROG_sapoB_Y</b>: armazena a posição vertical do sapo B no campo.<br>
</li><li><b>FROG_BpassouFase</b>: verifica se o sapo B passou de fase.<br>
</li><li><b>FROG_BperdeuJogo</b>: verifica se o sapo B perdeu.<br>
</li><li><b>FROG_B_Vidas</b>: contabiliza o número de vidas do sapo B.</li></ul>

<hr />

<h2>Procedimentos</h2>

<ul><li><b>FROG_Clock</b>: procedimento principal, executa um loop ate que o jogador ganhe, perca ou saia do jogo.</li></ul>

<h2>Procedimentos de Movimento</h2>

<ul><li><b>FROG_VerificarColisao</b>: verifica se o sapo colidiu com um carro. Para isso, percorre a matriz inteira, verificando se existe algum elemento para qual o valor ee maior que o valor do sapo (considera-se que nenhum outro elemento tem valor maior que o sapo). Se sim, houve colisão e a variável FROG_perdeuJogo  1. Caso contrario, nada acontece.<br>
</li><li><b>FROG_VerificarVitoria</b>: verifica se a posição vertical do sapo é 1. Se sim, ele esta na primeira linha, o que mostra que este atravessou todo o campo. A variável FROG_ganhouJogo recebe 1. Caso contrario, nada acontece.<br>
</li><li><b>FROG_ControleMovimento</b>: lê uma tecla pressionada pelo jogador e, caso essa seja uma seta direcional, chama um dos seguintes procedimentos, a fim de movimentar o sapo pelo campo.</li></ul>

<ul><li><b>FROG_MovimentaEsq</b>: movimenta para a esquerda.<br>
</li><li><b>FROG_MovimentaDir</b>: movimenta para a direita.<br>
</li><li><b>FROG_MovimentaCima</b>: movimenta para cima.<br>
</li><li><b>FROG_MovimentaBaixo</b>: movimenta para baixo.</li></ul>

<ul><li><b>FROG_AtualizarTransito</b>: interpreta os vetores responsáveis por definir quais linhas, em qual sentido e com que velocidade devem se movimentar e invoca o procedimento pra realizar tal operação.<br>
</li><li><b>FROG_RotacionarTransito</b>: dados a linha (dx) e o sentido (ax), rotaciona os elementos da linha.<br>
</li><li><b>FROG_RotacionarAgua</b>: executa a mesma operação que o procedimento acima, mas para os elementos superiores da matriz. Esse procedimento também rotaciona o sapo (visualmente, ele estaria sobre uma plataforma de madeira).</li></ul>

<h2>Procedimentos de Jogo/Campo</h2>

<ul><li><b>FROG_InitJogo</b>: chama o procedimento acima, estabelece o número de vidas, e chama o procedimento abaixo.<br>
</li><li><b>FROG_LerCampo</b>: lê o arquivo de campo e grava ele em um vetor.<br>
</li><li><b>FROG_DefinirCampo</b>: define o campo, a partir do vetor que armazena as informações do arquivo.<br>
</li><li><b>FROG_NovoCampo</b>: aumenta a variável que guarda o nome do arquivo (para a próxima fase) e chama FROG_DefinirCampo. Créditos ao TioGuedes por esse procedimento.<br>
</li><li><b>FROG_NovoJogo</b>: restaura os valores inicias das variáveis e do campo.</li></ul>

<h3>Procedimentos de Desenho</h3>

<ul><li><b>FROG_DesenharCampo</b>: atualiza o campo no console.<br>
</li><li><b>FROG_DesenharCaracteres</b>: chamado pelo procedimento acima, esse tem como objetivo interpretar os elementos na matriz e desenhá-los no console de um jeito melhor.</li></ul>

<h2>Procedimentos de Exibição</h2>

<ul><li><b>FROG_ExibirIntro</b>: exibe janela de introdução.<br>
</li><li><b>FROG_ExibirVitoria</b>: exibe janela de vitória.<br>
</li><li><b>FROG_ExibirDerrota</b>: exibe janela de derrota.<br>
</li><li><b>FROG_EntreFases</b>: exibe uma tela preta com mensagem que mostra qual o número e nome do próximo level. Espera Enter para continuar.<br>
</li><li><b>FROG_PressEnter</b>: exibe a mensagem de "pressione enter" abaixo do campo e espera o Enter ser inserido.<br>
</li><li><b>FROG_ExibirHUD</b>: mostra informações, como número de vidas, número de passos, level da fase, nome da fase, etc...</li></ul>

<hr />
<h2>Correção de bugs (versão 1.1)</h2>

Os <i>bugs</i> presentes na versão 1.0, que implicavam na duplicação do sapo quando este se movimentava rapidamente ou que impediam que os carros se movimentassem no limite da matriz foi corrigido, estando estes correlacionados. Outro bug que também foi corrigido nessa versão: o clock exigia uma grande quantidade de tempo para processar as informações, quando o sapo se encontrava na primeira linha (mais à cima). A partir daqui, as versões 1.2a e 1.2b puderam finalmente se iniciar.<br>
<br>
<h2>Modo cooperativo (versão 1.2a)</h2>

<b>Ideia inicial: co-op!</b>
A fim de cumprir com as novas regras do jogo - a vitória agora ocorre quando os dois sapos atravessam o campo, enquanto a derrota ocorre quando um dos sapos perde suas três vidas - a implementação do modo cooperativo ocorreu através da duplicação de várias variáveis que eram relaciondas ao sapo A. As novas variáveis então fariam referência ao sapo B. Os procedimentos RotacionaAgua, RotacionaTransito, VerificaDerrota, VerificaVitoria, ControleMovimento, Init e Clock também foram modificados para que o jogo aceitasse os dois jogadores.<br>
<br>
<b>Diferenciando colisões com os diferentes sapos...</b>
O sapo B assume o valor do sapo A multiplicado por 2. Temos, por uma definição acima que todos os elementos possuem um valor inferior que o sapo A. Logo, para sabermos qual sapo colidiu com algum objeto, verificamos se<br>
<ul><li>Existe um valor maior que o sapo A e menor que o sapo B: o sapo A colidiu!<br>
</li><li>Existe um valor maior que o sapo B: o sapo B colidiu!</li></ul>

<i>Nota: na teoria, seria possível modificar facilmente o algoritmo a fim de incluir mais sapos no jogo.</i>

<b>Como jogar com um único sapo?</b>
No início do jogo, é verificado se ele esta no modo cooperativo. Se não, o sapo B não é posicionado na matriz e sua variável FROG_BganhouJogo assume o valor verdadeiro. Desta forma, assim que o sapo A chegar ao outro lado, ele vencerá sozinho o jogo.<br>
<br>
<b>Como o sapo B pode jogar?</b>
No decorrer do jogo, se a tecla F2 for pressionada, o sapo B será inserido no campo de forma "online" (e a posição do sapo A será restaurada para a inicial).<br>
<br>
<b>Contando seus passos...</b>
Um contador de passos é utilizado. A cada movimentação de um dos sapos, este é incrementado. Tal elemento tem como objetivo incentivar os jogadores a realizarem um número mínimo de passos (14, considerando o tamanho padrão da matriz).<br>
<br>
<b>Novo jeito de exibir informações:</b>
Com um crescimento na quantidade de informação que necessitava ser mostrada, um procedimento chamado FROG_ExibirHUD foi criado. Dentro deste procedimento, o cursor é deslocado para uma posição pré-definida e<br>
exibe informações relativas às vidas restantes dos sapos (ou a tecla necessária para a entrada de um novo sapo), além do número de passos realizados.<br>
<br>
<hr />
<h2>Progressão de multiplas fases e leitura dinâmica de texturas (versão 1.2b)</h2>

Nesta versão, foi implementado um leitor que pudesse carregar dinamicamente de arquivos nomeados de forma sequencial "campo00.txt" e, a partir desses, carregar fases no jogo.<br>
<br>
Quando o(os) sapo(os) vence(em) uma fase, o leitor buscará a próxima fase na pasta src/Frogger/. Caso exista, essa fase será carregada. Caso contrário, o jogo acaba e o jogador finalmente venceu o jogo.<br>
<br>
As propriedades das fases estão mais livres. Agora, é possível definir não só a ordem dos objetos pelos arquivos, mas também suas velocidades e suas texturas.<br>
<br>
<img src='http://sphotos-h.ak.fbcdn.net/hphotos-ak-prn1/69597_332316380208161_1295791066_n.jpg' />

No exemplo acima, é possível ver a estrutura de cada arquivo. É <b>ESTRITAMENTE</b> importante que os primeiros 582 caracteres estejam estruturados dessa forma, incluindo a divisão em linhas. (totalizando 648 bytes) Qualquer caractere depois disso será irrelevante.<br>
<br>
A partir da procedimento FROG_LerMapa, o jogo carrega em um vetor de 648 bytes o arquivo, e acessa esse vetor em uma determinada posição para informação.<br>
<br>
<ul><li>"Título##############" (os 20 primeiros bytes são reservados para o título do mapa, que, se menor que 20, deve ser preenchido com # no final até obter o tamanho de 20 bytes)</li></ul>

<ul><li>"S S 000000000000000 XXX CC XXX" representa cada uma das 15 linhas do mapa.</li></ul>

No lugar do primeiro S, coloca-se a direção (par: direita, ímpar: esquerda; caso seja 2 ou 3, o sapo se movimentará automaticamente na linha, como em exemplos de água). Nota-se que caso o sentido seja S, a linha não terá movimento.<br>
<br>
No lugar do segundo S, coloca-se a velocidade. (1 é a maior velocidade possível, 4 já é uma velocidade bem lerda)<br>
<br>
Os quinze 0s representam o quê de fato terá naquela linha, no campo. (0 representam chão. 1 a 8 representam obstáculos)<br>
<br>
Os primeiros XXX representam a parte de cima do desenho do chão, daquela linha.<br>
<br>
Os CC representam a cor do desenho do chão (para ambas as partes de cima e de baixo). Ver abaixo sobre as cores.<br>
<br>
Os segundos XXX representam a parte de baixo do desenho do chão, daquela linha.<br>
<br>
<ul><li>XXX CC<br>
</li><li>XXX CC</li></ul>

Em ordem, para cada um dos seis exemplos acima, temos os gráficos dos obstáculos de 1 a 6.<br>
<br>
Os primeiros XXX representam a parte de cima do obstáculo.<br>
<br>
Os primeiros CC representam a cor da parte de cima do obstáculo.<br>
<br>
Os segundos XXX representam a parte de baixo do obstáculo.<br>
<br>
Os segundos CC representam a cor da parte de baixo do obstáculo.<br>
<br>
<ul><li>XXX CC XXX<br>
</li><li>XXX CC XXX</li></ul>

Representando, em ordem, os obstáculos 7 e 8. Em relação aos primeiros XXX e CC de cada linha, eles são iguais ao descrito acima. Porém, esses obstáculos possem um segundo gráfico (respiração), que será exibido no lugar do original em metade do tempo.<br>
<br>
Os XXX após a parte de cima representam a segunda imagem da parte de cima.<br>
<br>
Os XXX após a parte de baixo representam a segunda imagem da parte de baixo.<br>
<br>
<h2>Cores</h2>

O primeiro C representa a cor de fundo a ser exibida, e o segundo C representa a cor dos caracteres a serem exibidos.<br>
<br>
As cores são:<br>
<br>
0 - Preto<br>
<br>
1 - Azul<br>
<br>
2 - Verde<br>
<br>
3 - Cyan<br>
<br>
4 - Red<br>
<br>
5 - Vermelho<br>
<br>
6 - Rosa<br>
<br>
7 - Marrom<br>
<br>
8 - Cinza Claro<br>
<br>
9 - Cinza<br>
<br>
A - Azul Claro<br>
<br>
B - Verde Claro<br>
<br>
C - Cyan Claro<br>
<br>
D - Rosa Claro<br>
<br>
E - Amarelo<br>
<br>
F - Branco<br>
<br>
<hr />
<h2>Junção das versões 1.2a e 1.2b (versão 1.3)</h2>

Esta é a versão final do jogo. A junção das duas versões anteriores (1.2a e 1.2b) foi realizada, o que se mostrou uma tarefa extremamente difícil. Pequenos ajustes também foram realizados, como a necessidade de limpar as variáveis que definiam os campos (o jogo não assumia os valores corretos quando o jogo reiniciava).<br>
O resultado pode ser visto na imagem abaixo:<br>
<img src='http://i37.photobucket.com/albums/e81/0810119020/B_zpsdb2b66f1.png' />

<hr />
<h2>O Jogo</h2>

O jogo é atualmente composto por dez fases.<br>
<br>
1. Barão Geraldo City<br>
<br>
<img src='http://sphotos-d.ak.fbcdn.net/hphotos-ak-ash4/314873_331996443573488_1654685255_n.jpg' />

2. São Paulo City<br>
<br>
<img src='http://sphotos-b.ak.fbcdn.net/hphotos-ak-ash4/484732_331996450240154_1100967264_n.jpg' />

3. Nova York City<br>
<br>
<img src='http://sphotos-h.ak.fbcdn.net/hphotos-ak-prn1/69644_331996453573487_1729904192_n.jpg' />

4. Vulcano<br>
<br>
<img src='http://sphotos-e.ak.fbcdn.net/hphotos-ak-ash4/309757_331996483573484_459190532_n.jpg' />

5. Digital Chaos<br>
<br>
<img src='http://sphotos-c.ak.fbcdn.net/hphotos-ak-ash4/408498_331996490240150_743562494_n.jpg' />

6. Amazonas Rainforest<br>
<br>
<img src='http://sphotos-a.ak.fbcdn.net/hphotos-ak-prn1/46709_331996500240149_1736752528_n.jpg' />

7. Texas Stampede<br>
<br>
<img src='http://sphotos-g.ak.fbcdn.net/hphotos-ak-ash4/385369_331996520240147_1349147487_n.jpg' />

8. The Asteroid Field<br>
<br>
<img src='http://sphotos-e.ak.fbcdn.net/hphotos-ak-ash4/408534_331998680239931_1383827925_n.jpg' />

9. The Helltrix<br>
<br>
<img src='http://sphotos-b.ak.fbcdn.net/hphotos-ak-ash3/533855_331996536906812_1417044941_n.jpg' />

10. The Final Boss<br>
<br>
<img src='http://sphotos-e.ak.fbcdn.net/hphotos-ak-ash3/549931_331996550240144_1491065989_n.jpg' />
