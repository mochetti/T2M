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
    exit();
  } else {
    println("Available cameras:");
    printArray(cameras);

    // The camera can be initialized directly using an element
    // from the array returned by list():
    cam = new Capture(this, cameras[19]);
    // Or, the settings can be defined based on the text in the list
    //cam = new Capture(this, 640, 480, "Built-in iSight", 30);

    // Start capturing the images from the camera
    cam.start();
  }
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

void search(int index) {

  // raio de busca em relacao à ultima posicao de cada elemento
  int raioBusca = 20;
  // offset 
  PVector offset = new PVector();
  float angOff = 0;
  int qtdPixelsV = 0;
  int qtdPixelsA = 0;

  // reseta os blobs anteriores
  if (index == 3) bola.bola.reset();
    else {
    robos.get(index).azul.reset();
    robos.get(index).vermelho.reset();
  }

  // selecionamos o robo com o mouse
  if (procurarRobo) {
    offset.x = mouseX;
    offset.y = mouseY;
    angOff = 0;
    raioBusca = 30;
  }
  // estamos buscando a bola
  else if (index == 3) {
    offset.x = bola.bolaAntiga.center().x;
    offset.y = bola.bolaAntiga.center().y;
    angOff = 0;
    raioBusca = 60;
  }
  // o robo ja existia
  else {
    offset.x = int(robos.get(index).oldRobo.pos.x);
    offset.y = int(robos.get(index).oldRobo.pos.y);
    angOff = robos.get(index).oldRobo.ang;
  }

  pushMatrix();
  translate(offset.x, offset.y);
  rotate(angOff);

  // retangulo de busca
  noFill();
  stroke(255);
  rectMode(CENTER);
  rect(0, 0, 2*raioBusca, 2*raioBusca);

  for (int x = int(offset.x) - raioBusca; x < int(offset.x) + raioBusca; x++) {
    for (int y = int(offset.y) - raioBusca; y < int(offset.y) + raioBusca; y++) {
      int loc = 0;
      color currentColor = 0;

      if (inputVideo == 0) {
        loc = x + y * cam.width;
        if (loc < 0) loc = 0;
        currentColor = cam.pixels[loc];
      } else if (inputVideo == 1) {
        currentColor = get(x, y);
      } else if (inputVideo == 2) {
        currentColor = get(x, y);
      }
      //println("r: " + red(currentColor) + " g: " + green(currentColor) + " b: " + blue(currentColor));
      //Preto
      if (red(currentColor) + green(currentColor) + blue(currentColor) < 100) {
        //println("SEARCH: pixel preto");
        //qtdPixelsPretos++;
        continue;
      }
      // Laranja
      if (index == 3 && distColorSq(currentColor, cores[0]) < 1000) {
        //println("SEARCH: pixels add na bola");
        //println(distColorSq(currentColor, cores[0]));
        //qtdPixels++;
        bola.bola.add(x, y);
      }
      // Vermelho
      else if (index < 3 && distColorSq(currentColor, cores[2]) < distColorSq(currentColor, cores[1])) {
        //println("SEARCH: pixel vermelho add");
        //qtdPixelsV++;
        robos.get(index).vermelho.add(x, y);
      }
      // Azul
      else if (index < 3 && distColorSq(currentColor, cores[2]) > distColorSq(currentColor, cores[1])) {
        //println("SEARCH: pixel azul add");
        //qtdPixelsA++;
        robos.get(index).azul.add(x, y);
      }
    }
  }
  //println("SEARCH: qtdPixelsV = " + qtdPixelsV + "  qntPixelsA = " + qtdPixelsA);
  popMatrix();
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

  //É fundo ou não

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
  for (int x = xi; x < xf; x++) {
    for (int y = yi; y < yf; y++) {
      int loc = 0;
      if (inputVideo == 0) loc = x + y * cam.width;

      // cor do pixel atual
      color currentColor = 0;
      if (inputVideo == 0) currentColor = cam.pixels[loc];
      else if (inputVideo == 2) currentColor = get(x, y);

      // Verifica se é colorido
      if (filtroCor(currentColor)) {
        quantidade++;
        //soma as componentes individualmente
        r += red(currentColor);
        g += green(currentColor);
        b += blue(currentColor);
        //println("R = " + red(currentColor) + "  G = " + green(currentColor) + "  B = " + blue(currentColor));
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
    println("Médias:");
    print("R = " + r);
    print("  G = " + g);
    println("  B = " + b);
    println("Intervalos:");
    println("R: " + menorR + " -> " + maiorR);
    println("G: " + menorG + " -> " + maiorG);
    println("B: " + menorB + " -> " + maiorB);
    //Encontra a cor média
    color mediaColor = color(r, g, b);
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

  println("LARANJA");
  println("R = " + red(cores[0]));
  println("  G = " + green(cores[0]));
  println("  B = " + blue(cores[0]));
  println("  Brilho = " + brightness(cores[0]));
  println("VERDE");
  println("R = " + red(cores[1]));
  println("  G = " + green(cores[1]));
  println("  B = " + blue(cores[1]));
  println("  Brilho = " + brightness(cores[1]));
  println("VERMELHO");
  println("R = " + red(cores[2]));
  println("  G = " + green(cores[2]));
  println("  B = " + blue(cores[2]));
  println("  Brilho = " + brightness(cores[2]));
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
  }

  return;
}


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
  // limite de diferenca de cor
  int lim = 30;
  float brightnessc1 = brightness(c1);
  float brightnessc2 = brightness(c2);
  // talvez seja necessario criar um limite diferente p cada componente
  if (abs(red(c1) - red(c2)) < lim && abs(green(c1) - green(c2)) < lim && abs(blue(c1) - blue(c2)) < lim && brightnessc1 > brightnessc2 - lim && brightnessc1 < brightnessc2 + lim) return true;
  else return false;
}
