import processing.video.*;
import processing.serial.*;


/*

 Checar conexão do rádio com a serial do TX e também do receptor. Aparentemente está perdendo por mal contato do rádio.
 
 Por algum motivo os blobs não tão reconhecendo. Não to entendendo o porque o b.show() tá mostrando os blobs. Debugar a visão inteira e debugar a parte dos id's.
 Printar os id's e colocar robô por robô no campo e tentar separadamente para depois juntá-los. Garantir que estão na posição certa da array
 
 */

// Flags de debug
boolean debug = true;

boolean isRene = true;

boolean inicializou = false;

// Controla a entrada da imagem
// 0 - camera
// 1 - video 
// 2 - simulador
int inputVideo = 3;

boolean calibra = true;  //Flag de controle se deve ou não calibrar as cores
boolean visao = false;  //Flag de controle para parar o código logo após jogar a imagem no canvas (visão) a visão ou não
boolean controle = true;  // Flag para rodar o bloco de controle
boolean estrategia = true; // Flag para rodar o bloco de estratégia
boolean radio = true; //Flag de controle para emitir ou não sinais ao rádio (ultimo passo da checagem)
boolean gameplay = false;  //Flag de controle que diz se o jogo está no automático ou no manual (apenas do robô 0 por enquanto)
boolean simManual = true;  // Flag de controle que define se os comandos vem pelas setas ou do modulo de controle
boolean filtro = false;

// estretagia usada quando estrategia = false;
int estFixa = 0;

//Variavel para contar filtrados
int qtdfiltrados = 0;

// variaveis pro controle do arrasto do mouse
PVector clique = new PVector();
int dragged = 0;

// Verifica se ainda estamos configurando o robo
//boolean configRobo = false;

boolean pausado = false;

PImage filtrado;

//boolean andaReto = false; //DENTRO DE INERCIA()

Serial myPort;

// Salvar as cores num txt pra poupar tempo na hora de calibrar (?)
// Cores
color cores[] = { 
  color(245, 166, 73), // Laranja
  color(16, 148, 238), // Azul
  color(238, 96, 119) // Vermelho
};

// id de cada objeto
// 0 - Bola
// 1 - Meio Robo 0 (vermelho maior)
// 2 - Meio Robo 1 (robo xadrez)
// 3 - Meio Robo 2 (vermelho na direita)
// 4 - Quina Robo 0
// 5 - Quina Robo 1
// 6 - Quina Robo 2

// 6 - Quina 1 Robo 1
// 7 - Quina 0 Robo 2
// 8 - Quina 1 Robo 2
// 9 - Quina 2 Robo 2
// 10 - Inimigo

// campo[i]
// 0        1
// 3        2

color trackColor;  //Qual cor estou procurando
color mouseColor;  //Ultima cor selecionada no clique do mouse

// current color sendo calibrada
int calColor = -1;

// Numero de pixels do maior blob da cor vermelha, usado para distinguir o goleiro dos outros dois robôs (robo 0)
int pxMaiorBlobVermelho = 0;

// Numero de pixels do menor blob da cor verde, usado para distinguir do outro robô com verde (robo 1)
int pxMenorBlobVerde = 0;

// Conta o tempo de execucao
double tempo = millis();
double antes = millis();

// Quantidade de quadros para vencer a inercia no controle alinhandando
//int contagemAlinhandando = 0;


// Propriedades do campo
int Y_AREA = 120;

// define o campo como dois pontos
//PVector shapeCampo.getVertex(0) = new PVector();
//PVector shapeCampo.getVertex(2) = new PVector();

Movie mov;
Capture cam;
//PImage screenshot;

// quantidade de objetos de cada cor
// [] - Cor
// 0 - Laranja
// 1 - Azul
// 2 - Vermelho
int[] quantCor = {1, 3, 3};
int elementos = 0;

ArrayList<Blob> blobs = new ArrayList<Blob>();
ArrayList<Robo> robos = new ArrayList<Robo>();
ArrayList<Robo> robosSimulados = new ArrayList<Robo>();
ArrayList<PVector> rastro = new ArrayList<PVector>();
PImage foto;

// bola real
Bola bola = new Bola(true);

void setup() {

  shapeCampo = createShape();

  for (int i : quantCor) elementos += i;

  if (inputVideo == 1) {
    mov = new Movie(this, "seis_robos_mais_bola.mov");
    mov.play();
    mov.loop();
  }


  //mov.filtradoRate(30);
  ellipseMode(RADIUS);
  size(800, 448);
  filtrado = createImage(width, height, RGB);

  //byte[] txBuffer = {};
  //txBuffer = new byte[7];
  //txBuffer[0] = byte(128);

  for (int i = 0; i < 3; i++) robos.add(new Robo(-1));
  for (int i = 0; i < elementos; i++) blobs.add(new Blob());

  frame.removeNotify();
  frameRate(30);
  if (inputVideo == 0) {
    printArray(Serial.list());
    //myPort = new Serial(this, Serial.list()[0], 115200);
    camConfig();
  }

  foto = loadImage("teste.png");
}

void movieEvent(Movie m) {
  m.read();
}
void captureEvent(Capture c) {
  c.read();
}

void draw() {

  //tempo = 0;


  if (inputVideo == 0 || inputVideo == 1 || inputVideo == 2 || inputVideo == 3) {
    //loadPixels();
    background(0);
    tempo = millis();
    //println(tempo);

    //if (inputVideo == 0 && filtro) image(filtrado, 0, 0);
    //else if (!filtro && inputVideo == 0) image(cam, 0, 0);
    //else if (inputVideo == 1) image(mov, 0, 0, width, height);

    if (inicializou) {
      filtrado.loadPixels();
      for (int x = 0; x < width; x++) {
        for (int y = 0; y < height; y++) {
          if (filtrado != null && cam != null) {
            if (inputVideo == 0) filtrado.pixels[x + y * filtrado.width] = cam.pixels[x + y * filtrado.width];
            else if (inputVideo == 1) filtrado.pixels[x + y * filtrado.width] = mov.pixels[x + y * filtrado.width];
          }
        }
      }
      filtrado.filter(THRESHOLD, 0.35);
    }
    
    image(foto, 0, 0);

    //noFill();
    stroke(255);
    if (isCampoDimensionado) {
      // Mostra o campo na tela

      shape(shapeCampo);
      shape(shapeCampo.getChild(0));
      shape(shapeCampo.getChild(1));
      // Mostra os gols
      golInimigo = new PVector((shapeCampo.getVertex(0).x + shapeCampo.getVertex(3).x) /2, (shapeCampo.getVertex(0).y+shapeCampo.getVertex(3).y) / 2);  //LADO NOSSO = LADO DIREITO
      //golInimigo = new PVector((shapeCampo.getVertex(1).x + shapeCampo.getVertex(2).x) /2, (shapeCampo.getVertex(1).y+shapeCampo.getVertex(2).y) / 2); //LADO NOSSO = LADO ESQUERDO
      golAmigo = new PVector((shapeCampo.getVertex(1).x + shapeCampo.getVertex(2).x) /2, (shapeCampo.getVertex(1).y+shapeCampo.getVertex(2).y) / 2);  //LADO NOSSO = LADO DIREITO
      //golAmigo = new PVector((shapeCampo.getVertex(0).x + shapeCampo.getVertex(3).x) /2, (shapeCampo.getVertex(0).y+shapeCampo.getVertex(3).y) / 2);  //LADO NOSSO = LADO EESQUERDO

      fill(0, 0);
      ellipse(golAmigo.x, golAmigo.y, 20, 20);
      ellipse(golInimigo.x, golInimigo.y, 20, 20);

      if  (inputVideo == 2) simulador();

      /*
    OBSERVAÇÕES RELACIONADAS A VISÃO PERTINENTES:
       Antes de chamar a função track(), a array blobs precisa ser resetada para se buscar novos pontos na tela. Assim não deixa o negócio "lento"
       */

      if (debug) return;

      //Atualiza blobs
      //for (Blob b : blobs) b.oldBlob = new Blob(b.clone());

      track();  //Procura blobs e só atualizo os blobs dos robôs que não foram encontrados
      //for (Blob b : blobs) println(b.id);
      //for (Robo r : robos) if (!r.encontrado) id(r);
      //for (Blob b : blobs) println(b.id);
      //id();  //Define id's;


      //Robo 0 encontrado
      if (blobs.get(1).numPixels > 0 && blobs.get(4).numPixels > 0) {
        robos.get(0).index = 0;
        robos.get(0).encontrado = true;
      }

      //Robo 1 encontrado
      if (blobs.get(2).numPixels > 0 && blobs.get(5).numPixels > 0) {
        robos.get(1).index = 1;
        robos.get(1).encontrado = true;
      }

      //Robo 2 encontrado
      if (blobs.get(3).numPixels > 0 && blobs.get(6).numPixels > 0) {
        robos.get(2).index = 2;
        robos.get(2).encontrado = true;
      }

      //Defino a bola
      bola.atualiza();
      //println(bola.pos);
      //
      //Angulo do robô ainda depende dos blobs. aplicar o filtro threshhold APENAS depois de calculado o angulo.
      //O threshhold vai apenas garantir a posição do robô

      //A partir daqui pode definir os objetivos.

      //Defino as estratégias
      if (estrategia) {
        // Define as estratégias dos robos
        // 5 - seguir mouse, 6 fazer nada (por enquanto), 1 - atacante, 3 - goleiro

        //println(robos.get(0).obj);
        //println("Indexs");
        //for (Robo r : robos) println(r.index);
        if (robos.get(0).index >= 0) robos.get(0).setEstrategia(3);
        //println(bola.pos);
        if (robos.get(1).index >= 0) robos.get(1).setEstrategia(1);
        if (robos.get(2).index >= 0) {
          robos.get(2).setEstrategia(6);
          //  robos.get(2).obj = new PVector(robos.get(2).obj.x, robos.get(2).obj.y + 100);
        }
      } // posicoes fixas
      else for (Robo r : robos) if (r.index >= 0) r.setEstrategia(estFixa);

      //r.frente() não pode vir antes da estratégia, precisa ter os objetivos definidos.
      for (Robo r : robos) if (r.index >= 0 && !r.girando) r.frente();

      //print(robos.get(0).ang);

      // Debugo as estrategias (mostra na tela)
      for (Robo r : robos) if (r.index >= 0) r.debugObj();

      //A partir daqui controle assume

      if (controle) {

        //println(robos.get(0).girando);
        //robos.get(0).velE = robos.get(0).velMin;

        //robos.get(0).velD = robos.get(0).velMin;
        if (robos.get(0).index >= 0 && !robos.get(0).girando) alinhaAnda(robos.get(0));
        if (robos.get(1).index >= 0 && !robos.get(1).girando) alinhaAnda(robos.get(1));
        if (robos.get(2).index >= 0 && !robos.get(2).girando) alinhaAnda(robos.get(2));

        if (gameplay) gameplay(robos.get(0));
      }

      //for (Robo r : robos) r.atualiza();
      //for (Blob b : blobs) b.atualiza();
      //A partir daqui envia dados
      //if (inputVideo == 0) enviar();
    } else {
      // no simulador, o campo é o próprio canvas
      if (inputVideo == 2) {
        dimensionaCampo(0, 0);
        dimensionaCampo(width, 0);
        dimensionaCampo(width, height);
        dimensionaCampo(0, height);
        return;
      }

      //desenha as linhas na tela se formando
      for (int i = 0; i < shapeCampo.getVertexCount() - 1; i++) {
        fill(255);
        strokeWeight(2);
        line(shapeCampo.getVertex(i).x, shapeCampo.getVertex(i).y, shapeCampo.getVertex(i+1).x, shapeCampo.getVertex(i+1).y);
      }
    }
  }
}


void keyPressed() {
  if (key == TAB) {
    roboControlado++;
    if (roboControlado == 3) roboControlado = 0;
    println("KEY: Controlando o robo " + roboControlado);
  }
  if (key == 'd') {
    println("KEY: debug on/off");
    debug = !debug;
  }
  if (key == 'f') {
    if (filtro) {
      println("KEY: filtro off");
      filtro = false;
    } else {
      println("KEY: filtro on");
      filtro = true;
    }
  }
  if (key == 'c') {
    calibra = !calibra;
    if (calibra) {
      println("KEY: calibra on");
    } else {
      println("KEY: calibra off");
    }
  }
  if (key >= '0' && key <= '9') {
    println("KEY: Cor " + key);
    calColor = key;
  }
  if (key == 'r') {
    println("KEY: radio on/off");
    radio = !radio;
  }
  if (key == 'C') {
    println("KEY: redefinir campo");
    isCampoDimensionado = false;
    shapeCampo = createShape();
  }

  //MOVIE
  if (key == ' ') {
    // chute aleatorio na bola
    if (inputVideo == 2) bolaV.vel.set(random(20)-10, random(20)-10);
    if (pausado) {
      mov.play();
      pausado = false;
    } else {
      mov.pause();
      pausado = true;
    }
  }
  if (key == 'v') {
    println("KEY: debug visao on/off");
    visao = !visao;
  }
  if (key == 'S') {
    println("KEY: simulador manual/automatico");
    simManual = !simManual;
  }
  if (key == 'g') {
    println("KEY: gameplay on/off");
    gameplay = !gameplay;
  }
  // posicao inicial
  if (key == 'P') {
    println("KEY: posicao inicial");
    estFixa = 6;
    estrategia = !estrategia;
  }
}

void mouseDragged() {
}

void mouseReleased() {
  PVector mouse = new PVector(mouseX, mouseY);
  PVector tiro = PVector.sub(mouse, clique);
  tiro.setMag(sqrt(distSq(mouse, clique))/40);
  bolaV.vel = tiro;
}

void keyReleased() {
  if (robos.size() > 0) {
    robos.get(0).velE = 0;
    robos.get(0).velD = 0;
  }
}

void mousePressed() {
  clique.x = mouseX;
  clique.y = mouseY;

  //print("R = " + red(mov.get(mouseX, mouseY)));
  //print("  G = " + green(mov.get(mouseX, mouseY)));
  //println("  B = " + blue(mov.get(mouseX, mouseY)));
  //println("  Brilho = " + brightness(get(mouseX, mouseY)));
  //println("  Hue = " + hue(get(mouseX, mouseY)));
  //println("  Saturacao = " + saturation(get(mouseX, mouseY)));
  //println("X: " + mouseX + " Y: " + mouseY);

  if (!isCampoDimensionado) dimensionaCampo(mouseX, mouseY);
  if (calibra) calibra();
}
