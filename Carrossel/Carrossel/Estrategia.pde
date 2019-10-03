void estrategia(Robo r, int n) {
  // Mudar para as coordenadas do gol inimigo
  noFill();
  //PVector golInimigo = new PVector(shapeCampo.getVertex(2).x, (shapeCampo.getVertex(2).y + shapeCampo.getVertex(0).y)/2);
  PVector golInimigo = new PVector((shapeCampo.getVertex(1).x + shapeCampo.getVertex(2).x) /2, (shapeCampo.getVertex(1).y+shapeCampo.getVertex(2).y) / 2);
  ellipse(golInimigo.x, golInimigo.y, 20, 20);
  //PVector golAmigo = new PVector(shapeCampo.getVertex(0).x, (shapeCampo.getVertex(2).y + shapeCampo.getVertex(0).y)/2);
  PVector golAmigo = new PVector((shapeCampo.getVertex(0).x + shapeCampo.getVertex(3).x) /2, (shapeCampo.getVertex(0).y+shapeCampo.getVertex(3).y) / 2);
  ellipse(golAmigo.x, golAmigo.y, 20, 20);
  // Distancia que o robo pega pra empurrar a bola
  float distSombra = 50;
  // Distancia entre o X do goleiro e o X do centro do gol
  float distGoleiro = 30;
  // Parametros da reta da bola
  float aBola, bBola;
  // Raio de tolerancia para colisao
  int distColisao = 100;
  // Raio de tolerancia pro goleiro alinhar quando estiver próximo ao objetivo
  int limiteDistGoleiro = 10;
  
  PVector velBola = velBola();
  
  // Raio de colisao da bola
  //ellipse(bola.x, bola.y, distColisao, distColisao);
  PVector inter = new PVector();
  
  switch(n) {
    
    case 0:     // Goleiro segue o y da bola
      // Mudar coordenada x para x da linha do gol 
      inter.x = golAmigo.x + distGoleiro;
      inter.y = blobs.get(0).center().y;
      if(inter.y > golAmigo.y + Y_AREA/2) inter.y = golAmigo.y + Y_AREA/2;
      if(inter.y < golAmigo.y - Y_AREA/2) inter.y = golAmigo.y - Y_AREA/2;
      //ellipse(inter.x, inter.y, 15, 15);
      
      // Checa se o goleiro já está perto do objetivo
      if(distSq(r.pos, inter) < limiteDistGoleiro*limiteDistGoleiro) r.angObj = radians(90);
      else r.angObj = -1;
      r.setObj(inter);
      
    break;
    
    case 1:    // Empurra a bola pro gol através da sombra
      // Calcula a sombra da bola
      float ang = atan2(golAmigo.y - blobs.get(0).center().y, golAmigo.x - blobs.get(0).center().x);
      ang += PI;
      PVector sombra = new PVector();
      sombra.x = bola.x + distSombra * cos(ang);
      sombra.y = bola.y + distSombra * sin(ang);
      
      // Condiciona a sombra dentro do campo
      if(sombra.x < shapeCampo.getVertex(0).x) sombra.x = shapeCampo.getVertex(0).x;
      if(sombra.y < shapeCampo.getVertex(0).y) sombra.y = shapeCampo.getVertex(0).y;
      if(sombra.x > shapeCampo.getVertex(2).x) sombra.x = shapeCampo.getVertex(2).x;
      if(sombra.y > shapeCampo.getVertex(2).y) sombra.y = shapeCampo.getVertex(2).y;
      
      noFill();
      stroke(255);
      ellipse(sombra.x, sombra.y, 20, 20);
      //line(sombra.x, sombra.y, golInimigo.x, golInimigo.y);
      arrow(sombra.x, sombra.y, bola.x, bola.y);
      
      // Verifica se o robo esta perto o suficiente da sombra
      if(distSq(r.pos.x, r.pos.y, sombra.x, sombra.y) < 15*15) {
        r.setObj(bola);
      }
      else {
        // Ainda precisa chegar ate a sombra
        r.setObj(sombra);
      }
    break;
    
    case 2:    // Interseccao na defesa
      // O robo precisa estar atras da bola e ela deve estar se aproximando
      // Garante que a bola ja possui rastro
      if(velBola() == null) return;
      
      // Se a bola estiver se afastando do nosso gol, deixa ela
      if(!bolaIsAprox(golAmigo)) {
        // Meio do campo de defesa
        //r.setObj(width/4 + 50, height/2);
        r.setEstrategia(1);
        return;
      }
      
      // Equacao da reta da bola
      aBola = velBola.y / velBola.x;
      bBola = bola.y - aBola * bola.x;
      //line(bola.x, bola.y, bola.x + 100*velBola.x, bola.y + 100*velBola.y);
      
      // Preve choques da bola com as paredes
      // Ponto de colisão com a parede
      PVector impacto = new PVector();
      if(aBola > 0) impacto.y = 0;
      else impacto.y = height;
      impacto.x = (impacto.y - bBola) / aBola;
      if(impacto.x < 0) impacto.x = 0;
      else if(impacto.x > width) impacto.x = width;
      impacto.y = aBola * impacto.x + bBola;
      ellipse(impacto.x, impacto.y, 30, 30);
      
      float angInicial = 0;
      
      // Só são considerados choques em cima e embaixo
      if(impacto.x > 0 && impacto.x < width && distSq(bola.x, bola.y, impacto.x, impacto.y) < distColisao*distColisao) {
        // Considera a projecao pós impacto
        //println("ESTRATÉGIA: Colisão a caminho !");
        angInicial = atan2(r.pos.y - impacto.y, r.pos.x - impacto.x) + PI;
        aBola = -aBola;
        bBola = impacto.y - aBola * impacto.x;
        
        //Testa qual angulo permite chegar a tempo
        for(float angulo = angInicial; angulo > angInicial - PI; angulo -= PI/20) {
          //println("ESTRATÉGIA: angulo = " + degrees(angulo));
          //println("ESTRATÉGIA: tangente = " + tan(angulo));
          if(tan(angulo) < 20 || tan(angulo) > -20) {
          
            // Equacao da reta do robo para este angulo
            float aRobo = tan(angulo);
            float bRobo = r.pos.y - aRobo * r.pos.x;
            //line(r.pos.x, r.pos.y, r.pos.x + 1000*cos(angulo), r.pos.y + 1000*sin(angulo));
            
            // Calcula a interseccao das duas retas
            inter.x = (bRobo - bBola) / (aBola - aRobo);
            inter.y = aRobo * inter.x + bRobo;
            //ellipse(inter.x, inter.y, 15, 15);
            
            // Condiciona a interseccao
            if(inter.y < 0 || inter.y > height || inter.x < 0 || inter.x > width) inter = impacto;
            
            // Verifica se a interseccao pode ser alcancada antes da bola
            // Sem levar em conta a velocidade
            // A distancia da bola até o inter é a soma das trajetorias até o impacto depois ate o inter
            if(distSq(r.pos, inter) < distSq(bola, impacto) + distSq(impacto, inter)) {
              //println("ESTRATÉGIA: Da tempo !");
              //println("ESTRATÉGIA: inter = " + inter);
              stroke(255);
              ellipse(inter.x, inter.y, 15, 15);
              r.setObj(inter);
              return;
            }
          }
        }
      }
      
      // Não há colisões no caminho
      else {
        angInicial = atan2(r.pos.y - bola.y, r.pos.x - bola.x) + PI;
        //println("ESTRATÉGIA: angulo inicial = " + degrees(angInicial));
        
        //Testa qual angulo permite chegar a tempo
        for(float angulo = angInicial; angulo > angInicial - PI; angulo -= PI/20) {
          //println("ESTRATÉGIA: angulo = " + degrees(angulo));
          //println("ESTRATÉGIA: tangente = " + tan(angulo));
          if(tan(angulo) < 20 || tan(angulo) > -20) {
          
            // Equacao da reta do robo para este angulo
            float aRobo = tan(angulo);
            float bRobo = r.pos.y - aRobo * r.pos.x;
            line(r.pos.x, r.pos.y, r.pos.x + 1000*cos(angulo), r.pos.y + 1000*sin(angulo));
            
            // Calcula a interseccao das duas retas
            inter.x = (bRobo - bBola) / (aBola - aRobo);
            inter.y = aRobo * inter.x + bRobo;
            //ellipse(inter.x, inter.y, 15, 15);
            
            // Condiciona a interseccao
            if(inter.y < 0 || inter.y > height || inter.x < 0 || inter.x > width) {
              r.setObj(impacto);
              return;
            }
            
            // Verifica se a interseccao pode ser alcancada antes da bola
            // Sem levar em conta a velocidade
            if(distSq(r.pos, inter) < distSq(bola, inter)) {
              //println("ESTRATÉGIA: Da tempo !");
              //println("ESTRATÉGIA: inter = " + inter);
              stroke(255);
              ellipse(inter.x, inter.y, 15, 15);
              r.setObj(inter);
              return;
            }
          }
        }
      }
      
      // Caso nenhum angulo permita interceder
      //r.setEstrategia(0);
      r.setObj(bola);
    break;
      
    case 3:     // Goleiro segue a projecao da bola
    
      // Garante que a bola ja possui rastro
      if(velBola() == null) return;
      
      // Garante que a bola está se aproximando
      // Mudar o argumento para r.pos (?)
      if(!bolaIsAprox(golAmigo)) {
        r.setEstrategia(0);
        return;
      }
      
      // Equacao da reta da bola
      aBola = velBola.y / velBola.x;
      bBola = bola.y - aBola * bola.x;
      //line(bola.x, bola.y, bola.x + 100*velBola.x, bola.y + 100*velBola.y);

      // Intereseccao com a linha do gol
      inter.x = golAmigo.x + distGoleiro;
      inter.y = aBola * inter.x + bBola;
      
      // Só admite projecao se nao houver choques com as paredes
      if(inter.y < 0 || inter.y > height) {
        r.setEstrategia(0);
        return;
      }
      
      if(inter.y > golAmigo.y + Y_AREA/2) inter.y = golAmigo.y + Y_AREA/2;
      if(inter.y < golAmigo.y - Y_AREA/2) inter.y = golAmigo.y - Y_AREA/2;
      
      ellipse(inter.x, inter.y, 15, 15);
      r.setObj(inter);
      
    break;
    
    // segue a bola
    case 4:
      r.setObj(bola);
    break;
    
    // segue o mouse
    case 5:
      r.setObj(mouseX, mouseY);
    break;
  }
}