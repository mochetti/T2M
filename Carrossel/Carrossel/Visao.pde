/*

 Variáveis 
 
 */

boolean isCampoDimensionado = false;
PShape shapeCampo;

void camConfig() {

  String[] cameras = Capture.list();

  if (cameras == null) {
    println("Failed to retrieve the list of available cameras, will try the default...");
    cam = new Capture(this, 640, 480);
  } else if (cameras.length == 0) {
    println("There are no cameras available for capture.");
    exit();
  } else {
    println("Available cameras:");
    printArray(cameras);

    // The camera can be initialized directly using an element
    // from the array returned by list():
    cam = new Capture(this, cameras[18]);
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
 frame.setLocation(displayWidth/2, 0);
 }
 */

/*
0 - Laranja
 1 - Verde
 2 - Vermelho
 */
int[] corAchada = {0, 0, 0};

// Funcao que atribui coordenadas para os objetos
boolean track() {
  // limpa as cores encontradas
  for (int i=0; i<corAchada.length; i++) corAchada[i] = 0;
  // raio de busca em relacao à ultima posicao de cada blob
  int raioBusca = 10;

  // Verifica se há blobs salvos
  if (oldBlobs.size() == 0) {
    for (int index = 0; index < quantCor.length; index++) {
      if (quantCor[index] > 0) {
        print("VISÃO: Buscando novos blobs na cor ");
        println(index);
        searchNew(index);
      }
    }
  } else if (oldBlobs.size() > 0) {
    //println("VISÃO: size old blobs: " + oldBlobs.size());
    for (Blob b : oldBlobs) {
      if (b.id >= 0) {
        //println("VISÃO: Buscando blob " + b.id);
        // Salva as coordenadas anteriores do blob
        //println("id = " + b.id);
        //println("x = " + b.center().x);
        //println("y = " + b.center().y);
        int prevX = int(b.center().x);
        int prevY = int(b.center().y);
        // Limpa as coordenadas do blob
        b.reset();
        //println("x = " + prevX);
        //println("y = " + prevY);
        // Tenta buscar por perto
        int xi = prevX - raioBusca;
        if (xi < shapeCampo.getVertex(0).x) xi = int(shapeCampo.getVertex(0).x);
        int xf = prevX + raioBusca;
        if (xf > shapeCampo.getVertex(2).x) xf = int(shapeCampo.getVertex(2).x);
        int yi = prevY - raioBusca;
        if (yi < shapeCampo.getVertex(0).y) yi = int(shapeCampo.getVertex(0).y);
        int yf = prevY + raioBusca;
        if (yf > shapeCampo.getVertex(2).y) yf = int(shapeCampo.getVertex(2).y);

        if (!search(xi, xf, yi, yf, b)) println("VISÃO: O objeto não está no campo");
      }
    }
  }

  // Verifica se todos os elementos foram encontrados
  boolean erro = false;
  erro = false;
  for (int i = 0; i<quantCor.length; i++) {
    int blobsFaltantes = 0;
    if (corAchada[i] < quantCor[i]) {
      println("VISÃO: Achamos " + corAchada[i] + " elementos na cor " + i);
      blobsFaltantes = quantCor[i] - corAchada[i];
      if (searchNew(i) != blobsFaltantes) erro = true;
    } else if (corAchada[i] > quantCor[i]) {
      corAchada[i] = 0;
      println("VISÃO: Nos excedemos na cor " + i);
      if (searchNew(i) != quantCor[i]) erro = true;
    }
  }

  // Distingue o vermelho maior dos outros
  pxMaiorBlobVermelho = 0;
  for (Blob b : blobs) if (b.cor == 2) if (b.numPixels > pxMaiorBlobVermelho) pxMaiorBlobVermelho = b.numPixels;
  // Distingue o verde maior dos outros
  pxMenorBlobVerde = pxMaiorBlobVermelho;
  for (Blob b : blobs) if (b.cor == 1) if (b.numPixels < pxMenorBlobVerde) pxMenorBlobVerde = b.numPixels;
  //println("VISÃO: pxMaiorBlobVermelho = " + pxMaiorBlobVermelho);

  // if desnecessario
  if (!erro) {
    //println("VISÃO: Todos os blobs foram encontrados!");

    // Confere identidade aos objetos
    if (id()) return true;
  }

  return false;
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

// Checa se o blob está na área desejada
boolean search (int xi, int xf, int yi, int yf, Blob b) {
  // Contagem de pixels por blob
  int count = 0;
  // Procura nas coordenadas dadas
  for (int x = xi; x < xf; x++ ) {
    for (int y = yi; y < yf; y++ ) {
      //int loc = x + y * cam.width;
      int loc = x + y * width;
      // What is current color
      //color currentColor = cam.pixels[loc];
      color currentColor = pixels[loc];

      // Compara as cores
      if (filtroCor(currentColor) && msmCor(currentColor, cores[b.cor])) {
        b.add(x, y);
        count++;
        // Debug
        //stroke(255);
        //strokeWeight(1);
        //point(x, y);
      }
    }
  }

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
    println("VISÃO: Não encontramos o objeto nessa região");
    return false;
  }
}

// Acha novos blobs
int searchNew (int c) {
  int encontramos = 0;
  // Procura por todo o campo
  for (int x = int(shapeCampo.getVertex(0).x); x < shapeCampo.getVertex(2).x; x++ ) {
    for (int y = int(shapeCampo.getVertex(0).y); y < shapeCampo.getVertex(2).y; y++ ) {
      //int loc = x + y * cam.width;
      int loc = x + y * width;
      // What is current color
      //color currentColor = cam.pixels[loc];
      color currentColor = pixels[loc];

      // Compara as cores
      if (filtroCor(currentColor) && msmCor(currentColor, cores[c])) {
        // Verifica se algum elemento dessa cor já foi encontrado aqui perto
        if (blobs.size() > 0) {
          boolean found = false;
          for (Blob b : blobs) {
            if (b.isNear(x, y) && b.cor == c) {
              b.add(x, y);
              found = true;
              break;
            }
          }
          if (!found) {
            // É o pioneiro na região
            println("VISÃO: Novo blob encontrado");
            Blob b = new Blob(x, y, c);
            blobs.add(b);
            encontramos++;
            //ellipse(x, y, 30, 30);
          }
        }
        // Este é o primeiro blob
        else {
          // Primeiro blob no campo todo
          println("VISÃO: Primeiro blob encontrado");
          Blob b = new Blob(x, y, c);
          blobs.add(b);
          encontramos++;
          //fill(255);
          //point(x, y);
        }

        // Debug
        //stroke(255);
        //strokeWeight(1);
        //point(x, y);
      }
    }
  }

  //print("VISÃO: Quantidade de blobs: ");
  //println(blobs.size());

  // Confere se os blobs tem um numero minimo de pixels
  ArrayList<Blob> pixelsBlobs = new ArrayList<Blob>();
  for (Blob b : blobs) {
    if (b.numPixels > 15) pixelsBlobs.add(new Blob(b.clone()));
    else {
      println("VISÃO: Achamos um impostor com " + b.numPixels + " pixels !");
      encontramos--;
    }
  }  
  blobs.clear();
  // Copia de volta
  if (pixelsBlobs.size() > 0) {
    // Adiciona no array master
    for (Blob b : pixelsBlobs) blobs.add(new Blob(b.clone()));
    // Mostra os blobs
    for (Blob b : blobs) {
      b.show(color(255));
    }
  }
  // Verifica se esse searchNew encontrou alguem novo
  if (encontramos > 0) {
    corAchada[c] += encontramos;
    return encontramos;
  }
  return -1;
}

// Funcao que atribui identidade aos objetos
boolean id() {
  // raio de busca com o vermelho no centro
  int raioBusca = 55;
  for (Blob b : blobs) {
    // Laranja
    if (b.cor == 0) {
      // O objeto só pode ser a bola
      b.id = 0;
      continue;
    }

    // Verde
    if (b.cor == 1) {
      // Verifica se o v já foi catalogado
      if (b.id >= 0) continue;

      for (Blob v : blobs) {
        noFill();
        stroke(255);
        //ellipse(b.center().x, b.center().y, raioBusca, raioBusca);
        if (v.cor == 2 && (distSq(b.center(), v.center()) < (raioBusca*raioBusca))) {

          // Verifica se é o vermelho comprido
          //println("VISÃO: numPixels = " + v.numPixels);
          if (v.numPixels == pxMaiorBlobVermelho) {
            b.id = 1;
            v.id = 4;
            continue;
          }

          // Verifica se é o xadrez
          //println("VISÃO: pxMenorBlobVerde = " + pxMenorBlobVerde);
          //println("VISÃO: numPixels = " + b.numPixels);
          if (b.numPixels == pxMenorBlobVerde) {
            b.id = 2;
            v.id = 5;
            continue;
          }

          // Só pode ser o vermelho na direita
          b.id = 3;
          v.id = 6;
        }
      }
    }
  }
  // Confere o numero de ids validos
  int elementos = 0;
  for (int a : corAchada) elementos += a;
  int idsValidos = 0;
  for (Blob b : blobs) if (b.id >= 0) idsValidos++;
  if (idsValidos >= elementos) {
    // Coloca em ordem crescente de id
    if (ordenar()) return true;
  }
  println("VISÃO: Erro no numero de ids validos");
  return false;
}

// Funcao para fazer coincidir o id do blob com o index dele dentro do array
boolean ordenar() {
  // Ainda que nem todo mundo esteja em campo, inicializa o array todo
  ArrayList<Blob> newBlobs = new ArrayList<Blob>();
  for (int i=0; i<10; i++) {
    newBlobs.add(new Blob());
  }
  for (Blob b : blobs) {
    if (b.id >= 0) newBlobs.set(b.id, b.clone());
  }
  // Copia de volta
  //print("VISÃO: ids: ");
  blobs.clear();
  for (Blob b : newBlobs) blobs.add(b.clone());
  //for(Blob b : blobs) {
  //  if(b.id >= 0) println(b.id + " com " + b.numPixels + " pixels");
  //}
  //println("");
  // Confere
  boolean correto = true;
  for (Blob b : blobs) {
    if (b.id >= 0 && b.id != blobs.get(b.id).id) {
      correto = false;
    }
    if (b.id == 0) rastro.add(new PVector(b.center().x, b.center().y));
  }
  if (correto) return true;
  return false;
}

// Marca a bola com um circulo na tela
void showBola() {
  fill(255, 130, 0);
  // Coordenadas
  for (Blob b : blobs) {
    if (b.cor == 0) {
      PVector bolaAtual = new PVector(b.center().x, b.center().y);
      // cor laranja
      fill(255, 150, 0);
      ellipse(bolaAtual.x, bolaAtual.y, 10, 10);
    }
  }
}

// Retorna o vetor velocidade da bola, originado no centro dela
PVector velBola() {
  // Remove os rastros mais antigos
  while (rastro.size() > 15) rastro.remove(0);
  // Espera colher dados o suficiente
  if (rastro.size() < 14) return null;
  // Coordenadas
  PVector bolaAtual = new PVector(blobs.get(0).center().x, blobs.get(0).center().y);

  // Mostra o rastro na tela
  //for(int i = 0; i < rastro.size()-1; i++) ellipse(rastro.get(i).x, rastro.get(i).y, 15, 15);

  // Descobre o angulo e o modulo da bola
  float ang = 0;
  float modulo = 50;
  // Numero de frames entre duas bolas para calcular a velocidade
  int frames = 3;

  for (int i = 0; i < 9; i++) {
    // Começa pelo mais antigo
    PVector bolaAnt = new PVector(rastro.get(i).x, rastro.get(i).y);
    //PVector bolaRec = new PVector(rastro.get(i+frames).x, rastro.get(i+frames).y);
    //modulo += PVector.dist(bolaAnt, bolaRec);
    ang += atan2(bolaAtual.y - bolaAnt.y, bolaAtual.x - bolaAnt.x);
  }

  ang /= 9;
  //modulo /= 9;

  PVector vel = new PVector();
  vel.x = modulo*cos(ang);
  vel.y = modulo*sin(ang);
  //vel.mult(10);
  //arrow(bolaAtual.x, bolaAtual.y, PVector.add(bolaAtual, vel).x, PVector.add(bolaAtual, vel).y);

  return vel;
}

// Retorna true se a bola estiver se aproximando do ponto fornecido
boolean bolaIsAprox(PVector aqui) {
  PVector bolaAtual = new PVector(blobs.get(0).center().x, blobs.get(0).center().y);
  PVector velBola = velBola();
  // Se a distancia entre a bola futura e o ponto for maior que a distancia entre a bola atual e o ponto, a abola esta se afastando
  if (distSq(bolaAtual.x + velBola.x, bolaAtual.y + velBola.y, aqui.x, aqui.y) > distSq(bolaAtual.x, bolaAtual.y, aqui.x, aqui.y)) {
    //println("VISÃO: afastando");
    return false;
  } else {
    //println("VISÃO: aproximando");
    return true;
  }
}

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
boolean filtroCor(color c) {
  float soma = red(c) + green(c) + blue(c);
  int bgLimit = 100;
  int bgHValue = 100;
  int difLimit = 50;
  // é fundo se as tres componentes forem menor q bgLimit
  boolean back = (red(c) < bgLimit && green(c) < bgLimit && blue(c) < bgLimit) || brightness(c) < 100;
  // é cor se pelo menos uma componente for maior q bgHValue
  boolean highValue = red(c) > bgHValue || green(c) > bgHValue || blue(c) > bgHValue || brightness(c) > 100;
  // é cor se a distancia entre pelo menos duas das componentes for maior q difLimit
  boolean dif = (abs(red(c) - green(c)) > difLimit) || (abs(red(c) - blue(c)) > difLimit) || (abs(blue(c) - green(c)) > difLimit);
  if (soma > 100 && soma < 600 && !back && highValue && dif) {
    return true;
  }
  return false;
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

  ellipse(mouseX, mouseY, raio, raio);
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

  for (int x = xi; x < xf; x++) {
    for (int y = yi; y < yf; y++) {
      //int loc = x + y * cam.width;
      int loc = x + y * width;
      // What is current color
      //color currentColor = cam.pixels[loc];
      color currentColor = pixels[loc];
      // Verifica se é colorido
      if (filtroCor(currentColor)) {
        quantidade++;
        r += red(currentColor);
        g += green(currentColor);
        b += blue(currentColor);
        //println("R = " + red(currentColor) + "  G = " + green(currentColor) + "  B = " + blue(currentColor));
        if (red(currentColor) < menorR) menorR = red(currentColor);
        if (red(currentColor) > maiorR) maiorR = red(currentColor);
        if (green(currentColor) < menorG) menorG = green(currentColor);
        if (green(currentColor) > maiorG) maiorG = green(currentColor);
        if (blue(currentColor) < menorB) menorB = blue(currentColor);
        if (blue(currentColor) > maiorB) maiorB = blue(currentColor);
      }
    }
  }
  if (quantidade > 10) {
    println("Q = " + quantidade);
    r /= quantidade;
    g /= quantidade;
    b /= quantidade;
    println("Médias:");
    print("R = " + r);
    print("  G = " + g);
    println("  B = " + b);
    println("Intervalos:");
    println("R: " + menorR + " -> " + maiorR);
    println("G: " + menorG + " -> " + maiorG);
    println("B: " + menorB + " -> " + maiorB);
    color mediaColor = color(r, g, b);
    //println("Distancia Sq = " + distColorSq(mediaColor, cores[2]));
    fill(r, g, b);
    ellipse(mouseX + 100, mouseY, 30, 30);
    // Considera o intervalo de 0 a 9 na ASCII
    if (calColor >= 48 && calColor <= 57) {
      cores[calColor - 48] = mediaColor;
      for (int i = 0; i < cores.length; i++) {
        print("R = " + red(cores[i]));
        print("  G = " + green(cores[i]));
        println("  B = " + blue(cores[i]));
      }
    }
  }
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
    isCampoDimensionado = true;
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

// Compara duas cores por intervalos em cada componente
boolean msmCor(color c1, color c2) {
  // limite de diferenca de cor
  int lim = 20;
  // talvez seja necessario criar um limite diferente p cada componente
  if (abs(red(c1) - red(c2)) < lim && abs(green(c1) - green(c2)) < lim && abs(blue(c1) - blue(c2)) < lim) return true;
  else return false;
}
