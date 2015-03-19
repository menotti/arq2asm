# Introdução #

No último código (versão 120) adicionamos a funcionalidade de captura de imagem usando a webcam. No entanto, alguns passos adicionais são necessários para que tal funcionalidade seja usada corretamente. Os requisitos são:
<ul>
<blockquote><li>Ter a biblioteca OpenCV instalada na sua máquina<br>
<li>Configurar o projeto para incluir as bibliotecas do OpenCV (lembrando que é necessário acrescentar algumas variáveis de ambiente no PATH do sistema)<br>
<li>Descomentar a linha 18 de stdafx.h</blockquote>

<h1>Detalhes</h1>
<ol>
<li>Para baixar a biblioteca OpenCV, visite o link <a href='http://opencv.willowgarage.com/wiki/InstallGuide'>http://opencv.willowgarage.com/wiki/InstallGuide</a> <br>
Escolha a versão para Windows e, ao baixar, escolha OpenCV-2.3.1-win-superpack.exe<br>
<li>Extraia o conteúdo do arquivo baixado para alguma pasta de sua preferência.<br>
<li>Siga os passos do seguinte tutorial para configuração do OpenCV em sua máquina: <a href='http://bit.ly/vdQd31'>http://bit.ly/vdQd31</a>
<br>
<b>Nota</b>: independentemente de seu SO ser x64 ou x86, siga o tutorial atentando-se para mudar onde houver "x64" para "x86" na especificação dos caminhos mostrados no tutorial. E <b>não</b> é necessário mudar o tipo de compilação para Active(x64). Basta deixar como está.<br>
<li>Descomentar a linha 18 do header stdafx.h e pronto! Quando selecionar a opção de Webcam no menu Mode, a captura terá início, sendo possível ainda aplicar as transformações feitas pelos outros grupos até o momento.<br><br>




<b>Passos rápidos para o Linker:</b><br>

Na configuração do Linker, inclua o seguinte (para o OpenCV 2.30):<br>
<br>
"..\OpenCV2.3\build\x86\vc10\lib\opencv_core230d.lib"; "..\OpenCV2.3\build\x86\vc10\lib\opencv_highgui230d.lib"; "..\OpenCV2.3\build\x86\vc10\lib\opencv_video230d.lib"; "..\OpenCV2.3\build\x86\vc10\lib\opencv_ml230d.lib"; "..\OpenCV2.3\build\x86\vc10\lib\opencv_legacy230d.lib"; "..\OpenCV2.3\build\x86\vc10\lib\opencv_imgproc230d.lib"<br>
<br>
Para o OpenCV 2.31:<br>
<br>
"..\build\x86\vc10\lib\opencv_core231d.lib"; "..\build\x86\vc10\lib\opencv_highgui231d.lib"; "..\build\x86\vc10\lib\opencv_video231.lib"; "..\build\x86\vc10\lib\opencv_ml231d.lib"; "..\build\x86\vc10\lib\opencv_legacy231d.lib"; "..\build\x86\vc10\lib\opencv_imgproc231d.lib"<br>
<br>
Lembrando que é necessário substituir o ".." pelo caminho da pasta onde o OpenCV foi instalado.<br><br>
Vale reforçar que não é necessário (e nem se deve) mudar o tipo de compilação para x64, pois o assembly inline não é reconhecido nesse modo.