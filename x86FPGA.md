# Processador Zet na placa Altera DE2-115 #

---


## Introdução ##


O processador **Zet** é uma implementação aberta da arquitetura IA-32 (também conhecida como x86). Podendo ser sintetizado em placas FPGA, onde atualmente há 5 que são suportadas: _Altera DE0, DE1, DE2, DE2-155 e Xilinx ML403_.


No _[site do Zet](http://zet.aluzina.org/index.php/Zet_processor)_ podemos encontrar informações mais detalhadas quanto à sua implementação, código fonte e também um guia de como sintetizá-lo na placa **_[Altera DE1](http://zet.aluzina.org/index.php/Altera_DE1_Installation_guide)_**, que foi utilizado para entendermos e testarmos na placa _**DE2-115**_.


Vamos descrever abaixo passo a passo como deve ser realizado este procedimento, recomendamos que seja feito primeiramente a **leitura atenta de cada item** para que não haja dúvidas e evite erros durante a implementação pois encontramos muitos problemas no guia do site do Zet, informações ambíguas, explicações que geravam dúvidas e informações jogadas o que torna esta experiência extremamente cansativa e frustrante, todos querem que tudo ocorra como esperado logo na primeira vez. :)


---


## Antes de Começar ##
### Periféricos ###
Obviamente é necessário que você possua uma placa Altera DE2-115 mas além dela são necessários alguns itens para que possamos utilizar o Zet:
  * Monitor com entrada vga
  * Cabo vga
  * Teclado PS2
  * Mouse PS2
  * Cartão SD de até 2GB

### Quartus II ###
Utilizamos a versão do **Quartus II 12.1 _Web Edition_** disponível no site do [Altera](http://www.altera.com/index.jsp) que pode ser encontrada [aqui](https://www.altera.com/download/dnl-index.jsp).
Basta clicar na versão Windows ou Linux, baixar o instalador e durante o processo de instalação mudar para a versão **free**! Lembrando que é necessário ter um cadastro para realizar o download e para utilizar o Quartus II, mesmo que seja na versão free, caso contrário o mesmo não fará a compilação dos seus projetos.

_Observação: Para deixar sua licença funcional é necessário abrir o Quartus II, ir em **Tools/License Setup** clicar em Web License Update e escolher para realizar seu cadastro, após preencher todos os dados (será necessário inclusive o MAC Address da sua placa de rede) um arquivo .dat será enviado ao seu e-mail, baixe-o e atualize o arquivo dentro da opção License Setup do Quartus II._

### DE2-115 Control Panel ###

O Control Panel é um software fornecido pelo Altera que funciona como um painel de controles para configurar e testar a placa, vamos utilizá-lo para escrever na memória FLASH e também para verificar se todas as entradas reconheceram os periféricos instalados.
Ele pode ser encontrado no CD que vem junto com a placa, mas também pode ser obtido [aqui](http://www.terasic.com.tw/cgi-bin/page/archive.pl?Language=English&CategoryNo=139&No=502&PartNo=4) em sua ultima versão.
Utilizamos a versão mais atualizada neste guia que é a v.1.0.6, após extrair o arquivo é possível encontrar o executável na pasta:
  * _DE2-115\_V.1.0.6\_SystemCD\DE2\_115\_tools\DE2\_115\_control\_panel_

### Preparando os arquivos ###
Recomendamos que seja criado uma pasta onde você deverá realizar o download de todos os arquivos necessários para que possamos implementar o Zet.

  * **[Processador Zet](http://zet.aluzina.org/images/f/f5/Zet-1.2.0.zip)**: _está localizado na [página inicial](http://zet.aluzina.org/index.php/Zet_processor) do Zet (a versão utilizada neste tutorial é a 1.2.0)_.
    1. Extrair o zip para uma pasta qualquer, neste tutorial vamos utilizar a pasta _Zet-1.2.0_ (nome padrão do arquivo .zip)
    1. Os arquivos utilizados serão:
      * **bios.rom**: _localizado em Zet-1.2.0\src\bios_
      * **kotku.qpf**: _localizado em Zet-1.2.0\boards\altera-de2-115\syn_


  * **[Floppy Image](http://zet.aluzina.org/images/e/e8/A-zet.zip)**: _Extrair o arquivo **a-zet.img** para a pasta._

  * **[Hard Disk Image](http://zet.aluzina.org/images/9/9c/C.img.zip)**: _Extrair o arquivo **c.img** para a pasta._

Estes são os arquivos necessários para fazer nosso processador Zet funcionar!


---

## Botando a mão na massa! ##

### Instalando os drivers da DE2-115 _(Windows)_ ###

Caso você já tenha utilizado a DE2-115 no seu computador e já a tenha configurado, não há a necessidade de seguir este passo, mas caso seja a primeira vez vamos ter de instalar o driver para que ela possa funcionar corretamente.
Ligue a placa na energia e também no usb do seu computador, então aperte o botão de Power para ligá-la. Um programa pré-carregado vai começar a executar fazendo com que os leds e displays fiquem funcionando. Para instalar o driver basta localizá-lo na pasta onde você instalou o Altera:
  * C:\altera\12.1\quartus\drivers

Não selecione nenhuma das pastas dentro de _drivers_ ou o driver não será reconhecido!

### Criando a imagem da HD ###
**_Recomendamos fortemente utilizar Linux nesta etapa! Utilizamos o Ubuntu ;)_**

No **Linux** é muito simples de realizar este passo, utilizando o terminal, navegue até a pasta onde está localizado o arquivo _c.img_ e execute o seguinte comando:
```
dd if=./c.img of=/dev/sdc
```
_Observação: nem sempre o cartão estará em **sdc**, verifique antes de exceutar o comando_

No **Windows** é necessário utilizar um programa chamado [WinImage](http://www.winimage.com/), a versão do site é trial e funciona apenas 30 dias, com um pouco de esforço é possível achar a versão "[completa](http://torrentz.eu/6977435afaa316876887cd018e102e35264412fc)". Nós não conseguimos entender como ele funciona, muito menos escrever corretamente no cartão SD utilizando ele, portanto fica por sua conta e risco.

### Carregando arquivos na FLASH da DE2-115 ###

Agora vamos utilizar o **Control Panel**. Antes de abrir o executável, temos de abrir o arquivo _DE2\_115\_ControlPanel.sof_ no Quartus II e carregá-lo na DE2-115. Ao abrir o arquivo a janela _Programmer_ já será aberta automaticamente, basta clicar em _Start_, mas caso ela não apareça, é possível encontrá-la em _Tools/Programmer_.

Todos os _leds_ e filamentos dos _displays_ estarão acesos, agora já é possível abrir o executável _DE2\_115\_ControlPanel.exe_. Pode fechar o Quartus II pois o programa já está carregado na placa.

Vamos realizar os testes para ver se tudo está sendo reconhecido corretamente:
  * Cartão SD
    1. Insira o cartão SD na lateral esquerda da placa, fica na parte de baixo.
    1. Clique em **SD CARD** no Control Panel.
    1. Clique em **Read** e verifique se ele reconhece o cartão.

  * Outros testes podem ser realizados, fique à vontade para mexer no Control Panel.

Agora vamos carregar os arquivos na memória FLASH:
  1. Clique em **Memory**.
  1. Em _Memory Type_ escolha **_FLASH(400000h WORDS, 8MB)_**.
  1. Clique em **Chip Erase (75 sec)**.
  1. Aguarde o processo terminar.
  1. Em Sequential Write selecione a box _**File Length**_.
  1. Clique em _Write a File to Memory_.
  1. Escolha o arquivos **_bios.rom_** localizado na pasta _Zet-1.2.0\src\bios_.
  1. Aguarde o processo terminar.
  1. Agora no _Address_ também dentro de _Sequential Write_ vamos mudá-lo para **00020000** _(4 zeros depois do 2)._
  1. Clique em _Write a File to Memory_.
  1. Escolha agora o arquivo **_a-zet.img_**
  1. Aguarde o processo terminar.

Pronto! Já carregamos os arquivos necessários na memória FLASH da DE2-115, pode fechar o Control Panel.

### Carregar o programa do Zet ###

Vamos abrir o projeto **_kotku.qpf_** localizado em _Zet-1.2.0\boards\altera-de2-115\syn_ no Quartus II. Após aberto, temos de compilá-lo, lembrando que caso você esteja usando a ultima versão do Quartus II é necessário estar com sua licença cadastrada, caso contrário ele não irá compilar! Clique em _Processing/Start Compilation_ ou simplesmente aperte _CTRL+L_. O processo de compilação é demorado, favor aguardar, já estamos quase no final!

Após compilado, vamos carregar o programa na DE2-115, abra o _Tools/Programmer_ e clique em _Start_ ! Pronto, nosso processador Zet já está funcionando!

### Algumas observações ###
  * A chave **SW0** é o _Power ON/OFF_ utilize-a para ligar e desligar seu processador Zet.
  * Os leds estão exibindo FEld e no monitor está escrito: _No more devices to boot - System halted._
Neste caso a imagem do HD não foi escrito corretamente no cartão SD, é um problema usual, aqui nós simplesmente desistimos de entender como funciona o WinImage e partimos para o Ubuntu, utilizamos o comando no terminal e tudo funcionou corretamente, ele deixa apenas 50MB do cartão particionado como FAT16 e o resto não alocado.
  * Ao carregar o MS-DOS caso queira acessar o Windows 3.0:
    1. cd WINDOWS
    1. win
  * Há também outros programas:
    * Diversos jogos na pasta GAMES - _o ROGUE é um RPG em ASCII!_
    * TurboC na pasta TC - é possível programar e compilar seus códigos normalmente! Muito bacana :D
    * QBasic na pasta QBASIC - testamos um "Hello, World" em BASIC, mas o TurboC é mais interessante.


---


<br>
<h1>Arquitetura do Zet</h1>
<hr />
<h2>Considerações Iniciais</h2>
Primeiramente, vamos esclarecer algumas coisas  em relação a nomenclatura dos processadores:<br>
<ul><li>Processadores 	IA-32: processadores da Intel baseados na arquitetura IA-32, e.g., 	8086/88, Intel 286, Intel386, Intel486, Pentium, Pentium Pro, Pentium II, Pentium III, Pentium 4 e Intel Xeon.<br>
</li><li>Processadores de 32-bits:  processadores IA-32 que usam arquitetura de 32-bits que inclui os processadores Intel386, Intel486, Pentium, Pentium Pro, Pentium II, Pentium III, Pentium 4 e Intel Xeon.<br>
</li><li>Processadores de 16-bits:  processadores IA-32 que usam arquitetura de 16-bits que inclui os processadores 8086/88 e o Intel 286</li></ul>

O Zet, processador implementado neste trabalho, é uma implementação da arquitetura IA-32 (x86), porém somente a parte 16-bits é suportada. Ele foi feito baseado no Intel 8086.<br>
O conjunto de instruções do Zet suporta 89 das 92 instruções do 8086 e podem ser encontradas em <a href='http://zet.aluzina.org/index.php/Zet_status'>http://zet.aluzina.org/index.php/Zet_status</a>.<br>
<br>
As 3 instruções não implementadas são wait, esc e lock, essas instruções foram desnecessárias pois não foi usado nenhum coprocessador. A falta deste coprocessador também acarretou no fato que o Zet não suporta instruções de ponto flutuante, pois o 8086 delegava estas instruções a um coprocessador Intel 8087 (vide <a href='http://www.cpu-world.com/CPUs/8086/index.html'>http://www.cpu-world.com/CPUs/8086/index.html</a>)<br>
<br>
<hr />
<h2>Visão Geral</h2>
<img src='http://imageshack.us/a/img46/4925/zet.png' /><br>
Como a figura acima mostra, o processador Zet controla vários módulos responsáveis por tarefas específicas, como controle da memória flash, do teclado, dos led’s e switchs, do vídeo, da SRAM, da SDRAM e do cartão SD.<br>
<br>
<h2>Formato das instruções 8086</h2>
Cada instrução pode ter tamanho de até 9 bytes onde cada campo de uma instrução pode ter tamanho de 1 byte ou 2, e toda instrução possui 1 Opcode.<br>
<img src='http://imageshack.us/a/img694/5791/instrl.png' /><br>
<ul><li>Instruction Prefixes<br>
Prefixos modificam o comportamento da instrução de várias maneiras, podendo mudar por exemplo o segmento padrão de uma instrução ou controlar o loop numa instrução de string.<br>
</li><li>Opcode<br>
O Opcode diz ao processador qual instrução executar. No 8086 o tamanho do campo do Opcode é de 1 byte, o que limita o numero de instruções possíveis.<br>
</li><li>Operand Address<br>
Endereço do Operando<br>
</li><li>Displacement<br>
Campo contém o deslocamento do endereço<br>
</li><li>Immediate<br>
Valor imediato utilizado para realizar uma operação</li></ul>

<h2>Decoder</h2>
As etapas seguidas do Decoder são:<br>
<ol><li>É pego o endereço do sequenciador do Opcode e ModRM (O ModRM diz ao processador qual registrador ou posição de memória usar como operando da instrução). Para minimizar o uso da memória essa etapa é implementada na lógica.<br>
</li><li>O sequenciador continua lendo na ROM até atingir o valor “1”<br>
</li><li>Cada endereço no sequenciador é usado para indexar o microcode ROM para pegar a microinstrução atual</li></ol>

<img src='http://imageshack.us/a/img254/7793/zet01.png' />

<h2>Pipeline de 8 estágios</h2>
<ul><li>Fetch: busca 6 bytes da memória<br>
</li><li>Decode: decodifica a instrução. Calcula o endereço do sequencer baseado no opcode no modrm, além do tamanho da instrução, realimentando o estado Fetch<br>
</li><li>Sequencer: calcula o endereço do microcode e manda para a  microcode ROM<br>
</li><li>Issue:  pega a microinstrução da microcode ROM<br>
</li><li>Read: lê o conteúdo de um registrador<br>
</li><li>Execute: executa as operações na ALU<br>
</li><li>Memory: lê ou escreve na memória<br>
</li><li>Write back: escreve em um registrador<br>
<hr />
<br>Fontes:<br>
<a href='http://zet.aluzina.org/images/d/d8/Pres.pdf'>http://zet.aluzina.org/images/d/d8/Pres.pdf</a><br>
<a href='http://www.swansontec.com/sintel.html'>http://www.swansontec.com/sintel.html</a><br>
www.scs.stanford.edu/nyu/04fa/lab/ia32/IA32-3.pdf<br>
<a href='http://www.cpu-world.com/CPUs/8086/index.html'>http://www.cpu-world.com/CPUs/8086/index.html</a>