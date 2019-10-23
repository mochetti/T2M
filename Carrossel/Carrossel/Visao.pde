/*

 Variáveis 
 
 */
boolean todosEncontrados = false;
boolean isCampoDimensionado = false;
PShape shapeCampo;

void camConfig() {

  String[] cameras = Capture.list();

  if (cameras == null) {
    println("Failed to retrieve the list of available cameras, will try the default...");
    cam = new Capture(this, 800, 448, 30);
  } else if (cameras.length == 0) {
    println("There are no cameras available for capture.");
    //exit();
  } else {
    println("Available cameras:");
    printArray(cameras);

    // The camera can be initialized directly using an element
    // from the array returned by list():
    cam = new Capture(this, cameras[54]);
    // Or, the settings can be defined based on the text in the list
    //cam = new Capture(this, 640, 480, "Built-in iSight", 30);

    // Start capturing the images from the camera
    cam.start();
  }
}

/*
// Funcao que le a tela do mac e usa como dado
 void screenshot() {
 int xPrint = 0;
 int yPrint = 50;
 try{
 Robot robot_Screenshot = new Robot();
 screenshot = new PImage(robot_Screenshot.createScreenCapture
 (new Rectangle(xPrint, yPrint, width, height)));
 }
 catch (AWTException e){ }
 filtrado.setLocation(displayWidth/2, 0);
 }
 */

/*
0 - Laranja
 1 - Verde
 2 - Vermelho
 */
int[] corAchada = {0, 0, 0};

// Funcao que define os blobs no campo para os objetos
void track() {

  // limpa as cores encontradas
  for (int i=0; i<corAchada.length; i++) corAchada[i] = 0;

  // Verifica se há blobs salvos no filtrado anterior, se não houver:
  //Itera a princípio 3x (numero de cores diferentes no jogo - laranja, verde, vermelho)

  //Buscar de novo se id do blobs virar -1 ou se bola não for mais encontrada
  //Aqui to colocando o teste caso a bola não tenha sido encontrada pq não ta interna na funcao "id" dela
  //Aqui é pra blobs ter um elemento apenas com cor == 0

  blobs.clear();
  for (int i = 0; i < 3; i++) {
    searchNew(i);
  }
  stop();

  //blobs.clear();
  //searchNew(0);
  ////stop();
  //searchNew(1);  //seta o blob na array blobs apenas pra bola  

  //for (Blob b : blobs) if (b.cor == 0) {

  //  id(b);
  //}

  //println(bola.pos);
  //bola.b.show(color(255));
  //println(bola.pos);

  //searchNew(1);  //seta o blob na array blobs apenas pros robôs que se perderem
  //println(robos.get(0).pos);
  //id(robos.get(0));

  //searchNew(2);  //seta o blob na array blobs apenas pros robôs que se perderem
  //println(robos.get(0).pos);
  //id();
  //Nesse ponto do código array blobs contem os elementos com numPixels etc mas todos id = -1 e sem ordenar.
  //Onde estão cada blob colorido e seus centros

  //Dentro de id na hr de definir posicao dos robos ele checa se o robo ja foi encontrado ou não.

  id(robos.get(1));
  //id(robos.get(2));
  //for(Robo r : robos) println(r.pos);
}

float distSq(PVector v, PVector u) {
  float d = (u.x-v.x)*(u.x-v.x) + (u.y-v.y)*(u.y-v.y);
  return d;
}
float distSq(float x1, float y1, float x2, float y2) {
  float d = (x2-x1)*(x2-x1) + (y2-y1)*(y2-y1);
  return d;
}
float distSq(float x1, float y1, float z1, float x2, float y2, float z2) {
  float d = (x2-x1)*(x2-x1) + (y2-y1)*(y2-y1) +(z2-z1)*(z2-z1);
  return d;
}

// Retorna a distancia ao quadrado entre duas cores
float distColorSq(color c1, color c2) {

  float r1 = red(c1);
  float g1 = green(c1);
  float b1 = blue(c1);
  float r2 = red(c2);
  float g2 = green(c2);
  float b2 = blue(c2);

  // Cuidado adicional
  if (r1 - r2 > 20 || r2 - r1 > 20 || g1 - g2 > 20 || g2 - g1 > 20 || b1 - b2 > 20 || b2 - b1 > 20) return 2000;

  // Using euclidean distance to compare colors
  return distSq(r1, g1, b1, r2, g2, b2);
}

// Checa se o blob está próximo ao do filtrado anterior
boolean search (Blob b) {
  // raio de busca em relacao à ultima posicao de cada blob
  int raioBusca = 20;
  // Contagem de pixels por blob
  int count = 0;
  // offset 
  PVector offset = new PVector();
  float angOff = 0;
  // relacao blob - robo
  int[] relacaoBlobRobo = {-1, 0, 1, 2, 0, 1, 2};

  offset = bola.pos;

  // nao precisa dar popMatrix() agora pq nao afeta o array cam.pixels[]
  pushMatrix();
  translate(offset.x, offset.y);
  rotate(angOff);

  //println("VISAO: buscando blob " + b.id + " em " + offset);

  // Procura nas coordenadas dadas
  for (int x = int(offset.x) - raioBusca; x < int(offset.x) + raioBusca; x++ ) {
    for (int y = int(offset.y) - raioBusca; y < int(offset.y) + raioBusca; y++ ) {
      // posicao no array de pixels da camera
      int loc = 0;
      if (inputVideo == 0) loc = int( x + y * cam.width);
      if (loc < 0) loc = 0;
      // cor do pixel atual
      color currentColor = 0;
      if (inputVideo == 0) currentColor = cam.pixels[loc];
      else if (inputVideo == 2) currentColor = get(x, y);

      // Compara as cores
      if (filtroCor(currentColor, cores[b.cor], false) && msmCor(currentColor, cores[b.cor])) {
        b.add(x, y);
        count++;
      }
    }
  }

  noFill();
  rectMode(CORNER);
  stroke(255);
  rect(-raioBusca, -raioBusca, 2*raioBusca, 2*raioBusca);
  popMatrix();

  // Projeta a area de busca
  //stroke(0);
  //rectMode(CORNERS);
  //rect(xi, yi, xf, yf);

  if (count > 5) {
    //println("VISÃO: O objeto estava próximo ao anterior");
    blobs.add(new Blob(b.clone()));
    corAchada[b.cor]++;
    return true;
  } else {
    //println("VISÃO: Não encontramos o objeto nessa região");
    return false;
  }
}

//Checa se o robô está próximo ao filtrado anterior
boolean search(Robo r) {
  //println("VISAO: robo " + r.index + " encontrado e procurando ao redor");
  // raio de busca em relacao à ultima posicao de cada robo
  int raioBusca = 20;
  // Contagem de pixels por robo
  int count = 0;
  // offset 
  PVector offset = new PVector();
  float angOff = 0;
  // relacao blob - robo

  //Se aqui não for a bola offset = como segue

  //println(oldRobos.size());

  offset.x = int(r.oldRobo.pos.x);
  offset.y = int(r.oldRobo.pos.y);
  angOff = r.oldRobo.ang;

  //println(angOff);


  // nao precisa dar popMatrix() agora pq nao afeta o array cam.pixels[]
  pushMatrix();
  translate(offset.x, offset.y);
  rotate(angOff);

  //println("VISAO: buscando blob " + b.id + " em " + offset);

  // Procura nas coordenadas dadas
  Blob b = new Blob(r.oldRobo.pos.x, r.oldRobo.pos.y);

  for (int x = int(offset.x) - raioBusca; x < int(offset.x) + raioBusca; x++ ) {
    for (int y = int(offset.y) - raioBusca; y < int(offset.y) + raioBusca; y++ ) {
      // posicao no array de pixels da camera
      int loc = 0;
      if (inputVideo == 0) loc = int( x + y * cam.width);
      if (loc < 0) loc = 0;
      // cor do pixel atual
      color currentColor = 0;
      if (inputVideo == 0) currentColor = filtrado.pixels[loc];  //Aplica o threshold
      else if (inputVideo == 1) currentColor = get(x, y);
      else if (inputVideo == 2) currentColor = get(x, y);

      // Compara as cores
      //Aqui tem que aplicar o filtro de threshhold
      if (filtroCor(currentColor, color(255), false) && msmCor(currentColor, color(255))) {
        b.add(x, y);
        count++;
      }
    }
  }

  noFill();
  rectMode(CORNER);
  stroke(255);
  rect(-raioBusca, -raioBusca, 2*raioBusca, 2*raioBusca);
  popMatrix();

  // Projeta a area de busca
  //stroke(0);
  //rectMode(CORNERS);
  //rect(xi, yi, xf, yf);

  if (count > 5) {
    //println("VISÃO: O objeto estava próximo ao anterior");
    //blobs.add(new Blob(b.clone()));
    corAchada[b.cor]++;
    r.pos = b.center();
    r.getAng();

    return true;
  } else {
    //println("VISÃO: Não encontramos o objeto nessa região");
    return false;
  }
}

// Acha novos blobs
void searchNew (int c) {

  ArrayList<Blob> blobAux = new ArrayList<Blob>();
  //Variavel de quantidade de blobs encontrados da cor que está sendo buscada
  int encontramos = 0;
  // Procura por todo o campo
  for (int x = int(shapeCampo.getVertex(0).x); x < shapeCampo.getVertex(2).x; x++ ) {
    for (int y = int(shapeCampo.getVertex(0).y); y < shapeCampo.getVertex(2).y; y++ ) {
      int loc = 0;
      if  (inputVideo == 0) loc = x + y * cam.width;

      //int loc = x + y * width;
      // What is current color
      color currentColor = 0;
      if (inputVideo == 0) currentColor = cam.pixels[loc];
      else if (inputVideo == 2) currentColor = get(x, y);
      else if (inputVideo == 3) currentColor = get(x, y);
      // Compara as cores
      /*
        caso a cor do pixel que está sendo avaliado que passa pelo filtroCor seja uma cor real e
       a cor do pixel que está sendo avaliado seja a mesma cor que está sendo procurada. As propriedades da cor que está sendo procurada
       está dentro da array cores na posição "c"
       */
      if (filtroCor(currentColor, cores[c], false) && msmCor(currentColor, cores[c])) {
        // Verifica se algum elemento dessa cor já foi encontrado aqui perto
        //Caso seja, veja se o tamanho da array blobs é maior que 0 (já contém algum blob salvo).
        if (blobAux.size() > 0) {
          //Booleana que testa se encontrou um blob no campo da cor c
          boolean found = false;


          /*
            Checo dentro dos blobs já existentes se o blob tá perto da posição x, y e se tem a mesma cor. Se tiver perto e tiver a mesma cor, adiciona como mesmo elemento de blob
           */
          for (Blob b : blobAux) {
            /*
              Caso o ponto x, y (loc)/pixel que está sendo avaliado no momento esteja próximo do blob em questão
             e a cor do blob é igual à cor que está sendo procurada, a função add() do elemento blob define novos limites
             (em x e y) tanto max quanto minimos para sabermos se aquele ponto faz parte do todo ou não
             */
            if (b.isNear(x, y) && b.cor == c) {
              b.add(x, y);
              //a variável found atualiza para true, assim sabemos que encontramos um novo ponto que compoem o todo
              found = true;
              break;
            }
          }
          /*
            Caso a variável found retorne falso (o ponto nao compoem o todo próximo)
           ele entende que é o primeiro ponto que contem um novo blob na região. Gera um novo blob b na posição do ponto
           com a cor c em questão. Atualiza também o valor do encontramos++ para sabermos que encontramos um novo blob.
           Na próxima iterada provavelmente iremos entrar no bloco de cima, buscanndo os pontos próximos
           */

          //Caso seja uma cor, mas não estava próximo de nenhum blob existente de mesma cor, é um novo elemento de blob
          if (!found) {
            // É o pioneiro na região
            //println("VISÃO: Novo blob encontrado");
            Blob b = new Blob(x, y, c);
            blobAux.add(b);
            encontramos++;
            //ellipse(x, y, 30, 30);
          }
        }
        // Este é o primeiro blob
        else {
          // Primeiro blob no campo todo
          //faz a mesma coisa que os outros. Gera novo elemento de blob, na posição x, y, com a cor c em questão e add na array
          //println("VISÃO: Primeiro blob encontrado");
          Blob b = new Blob(x, y, c);
          blobAux.add(b);
          encontramos++;
          //fill(255);
          //point(x, y);
        }

         //Debug
        stroke(255);
        strokeWeight(1);
        point(x, y);
      }
    }
  }

  for (Blob b : blobAux) println(b.numPixels);

  /*
    Daqui pra baixo no código, já paramos de buscar todo o campo. A principio, a variável blobAux agora contem todos os blobs encontrados. Ainda estão sem ID, apenas possuem cor e coordenada
   0 - blob da bola
   1 - centro do verde robo 0
   2 - centro do verde robo 1
   3 - centro do verde robo 2
   4 - centro do vermelho robo 0
   5 - centro do vermelho robo 1
   6 - centro do vermelho robo 2
   */
  //println(blobAux.size());

  //print("VISÃO: Quantidade de blobs: ");
  //println(blobs.size());

  // Confere se os blobs tem um numero minimo de pixels
  //Caso tenha algum com menos q o numero minimo de pixel, foi impostor e subtrai um nos blobs encontrados

  //for (Blob b : blobAux) println("b.cor: " + b.cor + " b.pos: " + b.center());

  for (int i = 0; i < blobAux.size(); i++) {
    //Elimina impostores
    //println();
    println(blobAux.get(i).center());
    //blobAux.get(i).show(color(255));
    //println(i + " - " + blobAux.get(i).center());
    //println(blobAux.get(i).numPixels);
    //if (blobAux.get(i).numPixels < 15) blobAux.set(i, new Blob());
    //Se algum blob tiver menos que 15 pixels não considera que foi encontrado
    //Aqui reseta id = -1

    //println(blobAux.get(i).center());
  }

  // Verifica se esse searchNew encontrou alguem novo
  //Se encontrou, na posicao de cor da variavel corAchada soma o tanto que encontrou, agora temos dentro de
  //
  if (encontramos > 0) {
    corAchada[c] += encontramos;
    //return encontramos;
  }

  //for (int i = 0; i < blobs.size(); i++) {
  //  //println(blobs.ge);
  //  if (blobs.get(i).numPixels > 15) blobs.set(i, blobAux.get(i).clone());
  //}



  //if (!robos.get(0).encontrado) {
  //  blobs.set(1, blobAux.get(1).clone());
  //  blobs.set(4, blobAux.get(4).clone());
  //}
  //if (!robos.get(1).encontrado) {
  //  blobs.set(2, blobAux.get(2).clone());
  //  blobs.set(5, blobAux.get(5).clone());
  //}
  //if (!robos.get(2).encontrado) {
  //  blobs.set(3, blobAux.get(3).clone());
  //  blobs.set(6, blobAux.get(6).clone());
  //}
  
  if(c == 0){
    
  }

  //Aqui vou ter a array blobs sem considerar a ordem dos elementos dentro dela mas a princípio com numPixels e seus minimos/maximos definidos (ainda sem ID) também
}

//USAR APENAS PARA A BOLA
void id(Blob b) {
  //println(b.center());
  bola.pos = b.center();
  bola.b = new Blob(b);
  bola.encontrada = true;
}

// Funcao que atribui a posição aos objetos
void id(Robo r) {


  // raio de busca com o vermelho no centro
  int raioBusca = 55;

  //Robô 0 mesma proporção de 
  if (r.index == 0 && !r.encontrado) {
    //Busca na array blobs os dois elementos que possuem a mesma proporção e estão próximos um do outro


    //ou verde
    for (Blob azul : blobs) {
      if (azul.cor == 1) {
        for (Blob vermelho : blobs) {
          if (vermelho.cor == 2 && (distSq(azul.center(), vermelho.center()) < (raioBusca*raioBusca))) {
            //Se for azul e vermelho e estiverem próximos
            float pixelsVermelho = float(vermelho.numPixels);
            float pixelsAzul = float(azul.numPixels);

            //Azul
            r.b1 = new Blob(azul);
            r.b2 = new Blob(vermelho);
            r.b1.id = 1;
            r.b2.id = 4;


            //println("pixels Vermelho: " + vermelho);
            //println("pixels verde: " + verde);
            //println("Verde/Vermelho: " + verde/vermelho);
            //println(float(v.numPixels/~b.numPixels));
            //println(b.numPixels);
            //Se for o vermelho comprido, significa que são os ids 1 e 4 para o verde e para o vermelho
            //Nesse caso testamos: Se o numero de pixels vermelhos for mais ou menos a mesma qtd de pixels verde:
            //é o robo 0: metade verde e metade vermelho
            //println(abs(vermelho/verde));

            if (!r.encontrado) {
              println(abs(pixelsVermelho/pixelsAzul));
              //println(verde);
              if (abs(pixelsVermelho/pixelsAzul) > 0.80 && abs(pixelsVermelho/pixelsAzul) < 1.2) {
                //println("Achou CORES MESMA PROPORCAO");
                r.pos.x = (vermelho.center().x + azul.center().x) / 2;
                r.pos.y = (vermelho.center().y + azul.center().y) / 2;

                r.encontrado = true;
                //println(blobs.get(1).id);
              } else {
                println("VISÃO: robô " + r.index + " não foi encontrado");
                r.encontrado = false;
              }
            } else {
              search(r);
            }
          }
        }
      }
    }
    //return;
  } 
  if (r.index == 1) {

    //ou verde
    for (Blob azul : blobs) {
      if (azul.cor == 1) {
        for (Blob vermelho : blobs) {
          if (vermelho.cor == 2 && (distSq(azul.center(), vermelho.center()) < (raioBusca*raioBusca))) {
            //Se for azul e vermelho e estiverem próximos
            float pixelsVermelho = float(vermelho.numPixels);
            float pixelsAzul = float(azul.numPixels);

            //Azul
            r.b1 = new Blob(azul);
            r.b2 = new Blob(vermelho);
            r.b1.id = 2;
            r.b2.id = 5;

            //println("pixels Vermelho: " + vermelho);
            //println("pixels verde: " + verde);
            //println("Verde/Vermelho: " + verde/vermelho);
            //println(float(v.numPixels/~b.numPixels));
            //println(b.numPixels);
            //é o robo 1: metade vermelho e 1/4 azul (ou verde)
            //println(abs(vermelho/verde));
            //println(abs(pixelsVermelho/pixelsAzul));
            //println(verde);
            if (!r.encontrado) {

              if (abs(pixelsVermelho/pixelsAzul) > 1.5) {
                //println("Achou CORES MESMA PROPORCAO");
                float angulo1 = r.ang;
                if (r.frente) angulo1 -= PI;
                //println("ROBO: angulo = " + degrees(angulo));
                float distCentros1 = dist(azul.center().x, azul.center().y, vermelho.center().x, vermelho.center().y);
                distCentros1 /= 2;
                r.pos.x = (vermelho.center().x + cos(angulo1)*distCentros1);
                r.pos.y = (vermelho.center().y + sin(angulo1)*distCentros1);
                //Azul
                r.b1 = new Blob(azul);
                r.b2 = new Blob(vermelho);
                r.encontrado = true;
              } else {
                println("VISÃO: robô " + r.index + " não foi encontrado");
                r.encontrado = false;
              }
            } else {
              search(r);
            }
          }
        }
      }
    }
    //return;
  }
  if (r.index == 2) {
    //Busca na array blobs os dois elementos que possuem a mesma proporção e estão próximos um do outro

    //ou verde
    for (Blob azul : blobs) {
      if (azul.cor == 1) {
        for (Blob vermelho : blobs) {
          if (vermelho.cor == 2 && (distSq(azul.center(), vermelho.center()) < (raioBusca*raioBusca))) {
            //Se for azul e vermelho e estiverem próximos
            float pixelsVermelho = float(vermelho.numPixels);
            float pixelsAzul = float(azul.numPixels);

            //Azul
            r.b1 = new Blob(azul);
            r.b2 = new Blob(vermelho);
            r.b1.id = 3;
            r.b2.id = 6;

            //println("pixels Vermelho: " + vermelho);
            //println("pixels verde: " + verde);
            //println("Verde/Vermelho: " + verde/vermelho);
            //println(float(v.numPixels/~b.numPixels));
            //println(b.numPixels);
            //é o robo 2: metade azul(ou verde) e 1/4 vermelho
            //println(abs(vermelho/verde));
            //println(abs(pixelsVermelho/pixelsAzul));
            //println(verde);
            if (!r.encontrado) {
              if (abs(pixelsAzul/pixelsVermelho) > 1.5 && !r.encontrado) {
                //println("Achou CORES MESMA PROPORCAO");
                float angulo2 = r.ang;
                if (r.frente) angulo2 -= PI;
                //println("ROBO: angulo = " + degrees(angulo));
                float distCentros2 = dist(azul.center().x, azul.center().y, vermelho.center().x, vermelho.center().y);
                distCentros2 /= 2;
                r.pos.x = (azul.center().x + cos(angulo2)*distCentros2);
                r.pos.y = (azul.center().y + sin(angulo2)*distCentros2);
                //Azul
                r.b1 = new Blob(azul);
                r.b2 = new Blob(vermelho);
                r.encontrado = true;
              } else {
                println("VISÃO: robô " + r.index + " não foi encontrado");
                r.encontrado = false;
              }
            } else {
              search(r);
            }
          }
        }
      }
    }
  }
  //todosEncontrados = true;
  //while (blobs.size() < elementos) {
  //  blobs.add(new Blob());
  //  //todosEncontrados = false;
  //}

  for (Blob b : blobs) if (b.id == 0) rastro.add(new PVector(b.center().x, b.center().y));
  //ordenar();
  return;
}

// Funcao para fazer coincidir o id do blob com o index dele dentro do array
//void ordenar() {
//  // Ainda que nem todo mundo esteja em campo, inicializa o array todo
//  ArrayList<Blob> newBlobs = new ArrayList<Blob>();

//  for (int i = 0; i < elementos; i++) newBlobs.add(new Blob());

//  for (Blob b : blobs) if (b.id >= 0) newBlobs.set(b.id, b.clone());

//  // Copia de volta

//  blobs.clear();
//  for (Blob b : newBlobs) blobs.add(b.clone());

//  // Alimenta o array que guarda o rastro da bola


//  //Esse bloco de código garante que ao encontrar um novo elemento (robô)
//  //As informações dos outros como estágio, estratégia, posição, não se percam no próximo filtrado atualizado
//  if (todosEncontrados) {
//    for (Blob b : blobs) if (b.id == -1) todosEncontrados = false;
//  } else if (oldRobos.size() > 0) {

//    //Checar se todoEncontrados era false e virou true
//    //Seta true, passa pelo teste. Se virar false é porq não virou true. Se continuar true é porque virou.
//    todosEncontrados = true;

//    for (Blob b : blobs) if (b.id == -1) todosEncontrados = false;

//    if (todosEncontrados) {  //Virou true
//      println("VISAO: Novo elemento encontrado!");

//      for (int i = 0; i < oldRobos.size(); i++) {
//        oldRobos.set(i, new Robo(oldRobos.get(i).clone()));
//        oldRobos.get(i).index = i;
//      }
//    }
//  }
//}

// Funcao para desenhar uma seta
void arrow(float x1, float y1, float x2, float y2) {
  line(x1, y1, x2, y2);
  pushMatrix();
  translate(x2, y2);
  float a = atan2(x1-x2, y2-y1);
  rotate(a);
  line(0, 0, -10, -10);
  line(0, 0, 10, -10);
  popMatrix();
} 

// Funcao que checa se o pixel pode ser uma cor real
boolean filtroCor(color c, color corBase, boolean isHueImportant) {
  float soma = red(c) + green(c) + blue(c);
  int bgLimit = 100;
  int bgHValue = 100;
  int difLimit = 50;

  float tol = 0.15;

  float difRGB = 90;
  float difBHS = 7;

  //Primeiro filtrar por RGB;
  //Depois filtrar por Brilho, Hue e brightness

  //É fundo ou não

  //float hue = hue(corBase);

  //float hueCurrentColor = hue(c);

  float difRed = abs(red(c) - red(corBase));
  float difGreen = abs(green(c) - green(corBase));
  float difBlue = abs(blue(c) - blue(corBase));

  float difHue = abs(hue(c) - hue(corBase));
  float difBright = abs(brightness(c) - brightness(corBase));
  float difSaturation = abs(saturation(c) - saturation(corBase));

  // é fundo se as tres componentes forem menor q bgLimit
  boolean back = (red(c) < bgLimit && green(c) < bgLimit && blue(c) < bgLimit) || brightness(c) < 100;
  // é cor se pelo menos uma componente for maior q bgHValue
  boolean highValue = red(c) > bgHValue || green(c) > bgHValue || blue(c) > bgHValue || brightness(c) > 100;
  // é cor se a distancia entre pelo menos duas das componentes for maior q difLimit
  boolean dif = (abs(red(c) - green(c)) > difLimit) || (abs(red(c) - blue(c)) > difLimit) || (abs(blue(c) - green(c)) > difLimit);

  if (back) return false;
  else if (soma > 100 && soma < 600 && !back && highValue && dif) return true;
  else if (difHue + difBright + difSaturation < difBHS) return true;
  else return false;

  //if (soma > 100 && soma < 600 && !back && highValue && dif && !isHueImportant) {

  //  //print("soma: " + soma + "back: " + back + " highValue: " + highValue + " dif: " + dif);
  //  //println();
  //  return true;
  //} else if (hueCurrentColor > hue*(1-tol) && hueCurrentColor < hue*(1+tol) && isHueImportant) return true;
  ////if(!back && saturation(c))
  //return false;
}
// Funcao para ajustar as medias das cores
void calibra() {

  int raio = 5;

  float menorR = 255;
  float maiorR = 0;
  float menorG = 255;
  float maiorG = 0;
  float menorB = 255;
  float maiorB = 0;

  int r = 0, g = 0, b = 0;
  int quantidade = 0;
  int xi = mouseX - raio;
  int xf = mouseX + raio;
  int yi = mouseY - raio;
  int yf = mouseY + raio;

  stroke(255);
  noFill();
  rectMode(CORNERS);
  rect(xi, yi, xf, yf);

  //BUSCA AO REDOR DO CLIQUE COM RAIO DE 5 pixels
  // Verifica se é colorido

  color corBase = color(255);
  if (inputVideo == 3) corBase = get(mouseX, mouseY);
  else if (inputVideo == 0) corBase = color(red(cam.pixels[mouseX + mouseY * cam.width]), green(cam.pixels[mouseX + mouseY * cam.width]), blue(cam.pixels[mouseX + mouseY * cam.width]));
  else if (inputVideo == 1) corBase = color(red(mov.pixels[mouseX + mouseY * mov.width]), green(mov.pixels[mouseX + mouseY * mov.width]), blue(mov.pixels[mouseX + mouseY * mov.width]));
  else if (inputVideo == 2) corBase = get(mouseX, mouseY);
  for (int x = xi; x < xf; x++) {
    for (int y = yi; y < yf; y++) {
      int loc = 0;
      if (inputVideo == 0) loc = x + y * cam.width;

      // cor do pixel atual
      color currentColor = 0;
      if (inputVideo == 0) currentColor = cam.pixels[loc];
      else if (inputVideo == 2) currentColor = get(x, y);


      if (filtroCor(currentColor, corBase, false)) {
        quantidade++;
        //soma as componentes individualmente
        r += red(currentColor);
        g += green(currentColor);
        b += blue(currentColor);


        //println("TESTE: R = " + red(currentColor) + "  G = " + green(currentColor) + "  B = " + blue(currentColor));
        //Atualiza as menores cores e as maiores cores para cada componente
        if (red(currentColor) < menorR) menorR = red(currentColor);
        if (red(currentColor) > maiorR) maiorR = red(currentColor);
        if (green(currentColor) < menorG) menorG = green(currentColor);
        if (green(currentColor) > maiorG) maiorG = green(currentColor);
        if (blue(currentColor) < menorB) menorB = blue(currentColor);
        if (blue(currentColor) > maiorB) maiorB = blue(currentColor);
      }
      //fill(255);
      //point(x, y);
    }
  }
  //Depois de rodar a área, se a quantidade de pixels for maior que 10
  if (quantidade > 10) {
    println("Q = " + quantidade);
    //Tira as médias de cada componente
    r /= quantidade;
    g /= quantidade;
    b /= quantidade;
    //println("Médias:");
    //print("R = " + r);
    //print("  G = " + g);
    //println("  B = " + b);
    //println("Intervalos:");
    //println("R: " + menorR + " -> " + maiorR);
    //println("G: " + menorG + " -> " + maiorG);
    //println("B: " + menorB + " -> " + maiorB);
    //Encontra a cor média
    println("  Brilho = " + brightness(get(mouseX, mouseY)));
    println("  Hue = " + hue(get(mouseX, mouseY)));
    println("  Saturacao = " + saturation(get(mouseX, mouseY)));
    color mediaColor = color(r, g, b);
    println("  Brilho = " + brightness(mediaColor));
    println("  Hue = " + hue(mediaColor));
    println("  Saturacao = " + saturation(mediaColor));
    //println("Distancia Sq = " + distColorSq(mediaColor, cores[2]));
    fill(r, g, b);
    ellipse(mouseX + 100, mouseY, 30, 30);
    // Considera o intervalo de 0 a 9 na ASCII
    if (calColor >= 48 && calColor <= 57) {
      cores[calColor - 48] = mediaColor;
      //for (int i = 0; i < cores.length; i++) {
      //  print("R = " + red(cores[i]));
      //  print("  G = " + green(cores[i]));
      //  println("  B = " + blue(cores[i]));
      //}
    }
  }

  //println("LARANJA");
  //println("R = " + red(cores[0]));
  //println("  G = " + green(cores[0]));
  //println("  B = " + blue(cores[0]));
  //println("  Brilho = " + brightness(cores[0]));
  //println("VERDE");
  //println("R = " + red(cores[1]));
  //println("  G = " + green(cores[1]));
  //println("  B = " + blue(cores[1]));
  //println("  Brilho = " + brightness(cores[1]));
  //println("VERMELHO");
  //println("R = " + red(cores[2]));
  //println("  G = " + green(cores[2]));
  //println("  B = " + blue(cores[2]));
  //println("  Brilho = " + brightness(cores[2]));
}

// Dimensiona o campo
void dimensionaCampo(int x, int y) {

  // dimensiona o campo como quatro pontos

  shapeCampo.setStroke(255);
  shapeCampo.beginShape();
  shapeCampo.strokeWeight(2);
  shapeCampo.noFill();
  shapeCampo.beginContour();
  shapeCampo.vertex(x, y);
  shapeCampo.endContour();
  shapeCampo.endShape(CLOSE);

  if (shapeCampo.getVertexCount() == 4) {   
    PShape linhaSuperior = createShape();
    linhaSuperior.setStroke(255);
    linhaSuperior.beginShape();
    linhaSuperior.noFill();
    linhaSuperior.vertex(shapeCampo.getVertex(0).x, shapeCampo.getVertex(0).y);
    linhaSuperior.vertex(shapeCampo.getVertex(1).x, shapeCampo.getVertex(1).y);
    linhaSuperior.vertex(shapeCampo.getVertex(1).x, shapeCampo.getVertex(1).y + 50);
    linhaSuperior.vertex(shapeCampo.getVertex(0).x, shapeCampo.getVertex(0).y + 50);
    linhaSuperior.endShape(CLOSE);
    shapeCampo.addChild(linhaSuperior);
    PShape linhaInferior = createShape();
    linhaInferior.setStroke(255);
    linhaInferior.beginShape();
    linhaInferior.noFill();
    linhaInferior.vertex(shapeCampo.getVertex(3).x, shapeCampo.getVertex(3).y - 50);
    linhaInferior.vertex(shapeCampo.getVertex(2).x, shapeCampo.getVertex(2).y - 50);
    linhaInferior.vertex(shapeCampo.getVertex(2).x, shapeCampo.getVertex(2).y);
    linhaInferior.vertex(shapeCampo.getVertex(3).x, shapeCampo.getVertex(3).y);
    linhaInferior.endShape(CLOSE);
    shapeCampo.addChild(linhaInferior);

    isCampoDimensionado = true;
    inicializou = true;
  }

  return;
}
/*
// Retorna a quantidade de pixels de uma cor especifica numa regiao especifica
 int qPixels(int xr, int yr, color c) {
 int raio = 10;
 noFill();
 rectMode(CORNERS);
 rect(xr-raio, yr-raio, xr+raio, yr+raio);
 int count = 0;
 for(int x = (xr-raio); x < (xr+raio); x++) {
 for(int y = (yr-raio); y < (yr+raio); y++) {
 int loc = x + y * cam.width;
 // What is current color
 color currentColor = cam.pixels[loc];
 // Compara as cores
 if (msmCor(currentColor, c)) {
 count++;
 }
 }  
 }
 return count;
 }
 */
//boolean isInsride(PVector pos, PShape input) {
//  int i, j;
//  boolean c = false;
//  PShape forma = createShape();
//  forma.beginShape();
//  forma.vertex(input.getChild(0).getVertex(0).x, input.getChild(0).getVertex(0).y);
//  forma.endShape(CLOSE);
//  int sides = 4;          // descobrir como contar os lados de um PShape do tipo GROUP
//  for (i=0, j=sides-1; i<sides; j=i++) {
//    if (( ((forma.getVertex(i).y <= pos.y) && (pos.y < forma.getVertex(j).y)) || ((forma.getVertex(j).y <= pos.y) && (pos.y < forma.getVertex(i).y))) && (pos.x < (forma.getVertex(j).x - forma.getVertex(i).x) * (pos.y - forma.getVertex(i).y) / (forma.getVertex(j).y - forma.getVertex(i).y) + forma.getVertex(i).x)) {
//      c = !c;
//    }
//  }
//  return c;
//}


//Objeto dentro da forma
boolean isInside(PVector objeto, PShape forma) {
  if (objeto.x >= forma.getVertex(0).x && objeto.x <= forma.getVertex(2).x && objeto.y >= forma.getVertex(0).y && objeto.y <= forma.getVertex(2).y) {
    println("VISAO: ISINSIDE() - TRUE");
    return true;
  }
  return false;
}

// Compara duas cores por intervalos em cada componente
boolean msmCor(color c1, color c2) {

  int bgLimit = 100;
  int bgHValue = 100;
  int difLimit = 50;

  // limite de diferenca de cor
  int lim = 30;
  float saturationc1 = saturation(c1);
  float saturationc2 = saturation(c2);
  float brightnessc1 = brightness(c1);
  float brightnessc2 = brightness(c2);
  boolean back = (red(c1) < bgLimit && green(c1) < bgLimit && blue(c1) < bgLimit) || brightness(c1) < 100;
  // talvez seja necessario criar um limite diferente p cada componente
  if (abs(red(c1) - red(c2)) < lim && abs(green(c1) - green(c2)) < lim && abs(blue(c1) - blue(c2)) < lim && brightnessc1 > brightnessc2 - lim && brightnessc1 < brightnessc2 + lim && saturationc1 < saturationc2 + lim && saturationc1 > saturationc2 - 30 && !back) return true;
  else return false;
}
