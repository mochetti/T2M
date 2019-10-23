PVector golInimigo = new PVector();
PVector golAmigo = new PVector();

void estrategia(Robo r, int n) {
  // Mudar para as coordenadas do gol inimigo
  noFill();

  // Distancia que o robo pega pra empurrar a bola
  float distSombra = 60;
  // Distancia entre o X do goleiro e o X do centro do gol
  float distXGoleiro = 25;
  // Distancia em Y que o goleiro pode se afastar do centro do gol
  int distYGoleiro = 120;
  // Parametros da reta da bola
  float aBola, bBola;
  // Raio de tolerancia para colisao
  int distColisao = 100;
  // Raio de tolerancia pra considerar que o robo chegou
  int tolDist = 10;

  //PVector velBola = velBola();

  // Raio de colisao da bola
  //ellipse(bola.x, bola.y, distColisao, distColisao);
  PVector inter = new PVector();

  switch(n) {

  case 0:     // Goleiro segue o y da bola

    // Antes de qualquer coisa, checa se está perto da bola
    if (r.isNear(bola.pos, 50)) {
      if (frameCount - qtdFrames > 45) {
        r.girando = false;
        qtdFrames = frameCount;
        //println("ESTRATEGIA: Bola está proxima do goleiro, girando no próprio eixo.");
      } else {
        r.girando = true;
        // checa o sentido do giro
        if (bola.pos.y < r.pos.y) {
          println("ESTRATEGIA: Bola está proxima do goleiro, girando no sentido horário.");
          gira(r, true);
        } else {
          println("ESTRATEGIA: Bola está proxima do goleiro, girando no sentido anti horario.");
          gira(r, false);
        }
      }
      break;
    }
    r.girando = false;

    // a distancia do gol depende se é o goleiro de fato ou o zagueiro
    if (r.index == 0) {
      distXGoleiro = 20;
      distYGoleiro = 60;
    } else {
      distXGoleiro = 200;
      distYGoleiro = 150;
    }

    if (ladoCampo)inter.x = golAmigo.x - distXGoleiro;
    if (!ladoCampo)inter.x = golAmigo.x + distXGoleiro;
    inter.y = bola.pos.y;
    if (inter.y > golAmigo.y + distYGoleiro) inter.y = golAmigo.y + distYGoleiro;
    if (inter.y < golAmigo.y - distYGoleiro) inter.y = golAmigo.y - distYGoleiro;
    //ellipse(inter.x, inter.y, 15, 15);

    // Checa se o goleiro já está perto do objetivo
    if (distSq(r.pos, inter) < tolDist*tolDist) {

      r.angObj = PI/2;
      if (abs(r.ang - PI/2) > PI/2) r.angObj = 3*PI/2;
      //println(degrees(r.ang - PI/2));
    } else r.angObj = -1;
    r.setObj(inter);

    break; 


    /*
     No case 1 tentarei separar a estratégia em etapas. O problema que estamos tendo é que cada sequência lógica de passo envolve uma variável booleana
     na maioria das vezes para fazer as checagens. As coisas estão começando a se perder, pois para resetar seu estado inicial (como se fosse a primeira vez da execucao) as variáveis
     precisam ser zeradas e isso precisa ser feita no lugar certo na hora certa
     */
  case 1:    // Empurra a bola pro gol através da sombra
    // Calcula a sombra da bola
    /*antes de correr atrás do que seria o estágio em que estou, preciso que o robô se pergunte:
     Mas faz sentido continuar atrás do objetivo em que estou?
     e baseado na resposta desta pergunta, devemos ser capaz de dizer se sim -> continua na estratégia, ou se não -> reseta a estratégia.
     O X da questão é: qual pergunta é essa que devemos nos fazer? A estratégia 1 é a estratégia do jogador, deve chutar a bola e fazer o gol.
     Resetar a estratégia só faz sentido se a estratégia já não for a inicial (diferente de 0). Se for diferente, será 1 ou 2.
     No caso da estratégia 1, é onde ele encontrou a bola no caminho e está indo para a projeção da sombra. Que pergunta devemos nos fazer para saber se
     faz sentido continuar indo até a sombra? Para mim, o que fez sentido foi: Checar a distancia entre a sombra projetada e a bola.
     */
    //Se igual a 0, a estratégia deve ser correr atrás da sombra

    //Informações referentes a angulos e posição da sombra real deverão estar disponíveis a qualquermomento em qualquer IF
    //Por isso o motivo de estar do lado de fora (se vamos usar assim ou não fica a caráter do estágio decidir)
    float ang = atan2(golInimigo.y - bola.pos.y, golInimigo.x - bola.pos.x);
    ang += PI;
    PVector sombra = new PVector();
    sombra.x = bola.pos.x + distSombra * cos(ang);
    sombra.y = bola.pos.y + distSombra * sin(ang);

    // Condiciona a sombra dentro do campo
    if (sombra.x < shapeCampo.getVertex(0).x) sombra.x = shapeCampo.getVertex(0).x + 15;
    if (sombra.y < shapeCampo.getVertex(0).y) sombra.y = shapeCampo.getVertex(0).y + 20;
    if (sombra.x > shapeCampo.getVertex(2).x) sombra.x = shapeCampo.getVertex(2).x - 15;
    if (sombra.y > shapeCampo.getVertex(2).y) sombra.y = shapeCampo.getVertex(2).y - 20;
    //println("ESTRATÉGIA: Estágio " + r.estagio);

    if (r.estagio == 0) {

      //Set de funções para sempre definir qual o ponto do objetivo
      r.setObj(sombra);
      //noFill();
      //stroke(255);
      //ellipse(sombra.x, sombra.y, 20, 20);
      //arrow(sombra.x, sombra.y, bola.x, bola.y);

      /*
        Até aqui apenas calculamos a posição da sombra e nesse meio tempo o robô está seguindo ela
       A partir daqui, sempre no fim da estratégia, apenas checamos se a bola está dentro do raio do robô
       definido na função. Caso esteja, automaticamente o estágio passa a ser 1.
       */
      if (r.isBolaEntre(sombra)) {
        /*
          Aqui é importante visualizarmos que neste ponto do código estaremos usando a variável dentro do robo "Obj"
         como uma variável que gaurdará a posição da sombra da sombra no momento em que a sombra for projetada.
         Guardando assim a cópia dessa sombra (e não a atualizando), podemos checar a cada novo frame se a distancia
         entre sombra projetada e posicao da bola é menor que um raio determinado, para sabermos se deve ou não
         resetar o estágio para 0
         */
        if (sombra.y > height/2) r.setObj(new PVector(sombra.x, sombra.y - 60));  
        else r.setObj(new PVector(sombra.x, sombra.y + 60));
        //println("ESTRATÉGIA: Robo " + r.index + " encontrou a bola no caminho. Indo para a projeção da sombra");
        r.estagio = 1;
        //print(r.estagio);
        break;
      }
      //Nesta parte do código, o robô encontrou a sombra sem a bola estar entre eles e foi direto para o estágio de chutar a bola
      if (distSq(r.pos, sombra) < 15*15) {
        println("ESTRATÉGIA: Robo " + r.index + " chegou na sombra real. Indo em direção a bola");
        r.estagio = 3;
        break;
      }
      break;
      //// Verifica se a bola é um obstáculo
      /*
        Neste estágio iremos fazer o robô ir atrás da projeção da sombra. Caso a projeção da sombra esteja longe da bola, devemos
       resetar o estagio.
       */
    } else if (r.estagio == 1) {
      //

      //pintamos na tela o novo objetivo do robô, que é a projeção da sombra
      //noFill();
      //stroke(255);
      //ellipse(r.obj.x, r.obj.y, 20, 20);
      //arrow(r.obj.x, r.obj.y, sombra.x, sombra.y);
      //ellipse(sombra.x, sombra.y, 10, 10);


      /*
        Aqui, antes de mandarmos ele seguir a projeção da sombra devemos checar se faz sentido correr na projeção ou não. Isso checaremos
       através da distância entre a sombra projetada e a bola
       */
      float distTol = 130;
      //Significa que tá muito longe, reseta tudo
      //println(r.obj);
      if (distSq(r.obj, bola.pos) > distTol*distTol) {
        println("ESTRATÉGIA: projeção se afastou demais da bola. Reiniciando estágios");
        r.estagio = 0;
        break;
      }



      /*
       a sombra projetada ainda tá perto da bola o suficiente, segue o baile
       setando a sombra projetada como objetivo.
       Caso aconteça do robô chegar na sombra projetada, vamos para o penultimo estágio, que é ir até a sombra real
       */

      // Verifica se o robô esta perto o suficiente da sombra projetada
      if (distSq(r.pos.x, r.pos.y, r.obj.x, r.obj.y) < 15*15) {
        println("ESTRATEGIA: Chegou na projeção da sombra. Indo para a sombra real");
        r.estagio = 2;
        break;
      }


      //O robô não chegou na sombra projetada: segue o baile que é fazer absolutamente nada
      //Continuar indo até a projeção da sombra até chegar ou até a projeção se distanciar muito da bola


      //if (isInside(r.pos, shapeCampo.getChild(0))) {
      //}

      //if (r.isNear(bola) && isInside(r.pos, shapeCampo.getChild(0))) {
      //  gira(r, true);
      //  return;
      //}
      //if (r.isNear(bola) && isInside(r.pos, shapeCampo.getChild(1))) {
      //  gira(r, false);
      //  return;
      //}




      /*
        Neste ponto do código o robô deverá agora perseguir a sombra real da bola 
       Porém, em casos mto específicos pode acontecer do robô cair nesta rotina de seguir a sombra real da bola mas a bola voltar a ficar entre
       robo e projeção (nesse caso o estágio não prevê e tudo bem) ou acontecerá da robô se afastar demais da bola, precisando resetar para o estágio 0.
       O robô não poderá apenas seguir a sombra caso este se afaste demais da bola justamente porque é no estágio 0 onde a verificação se a bola está perto ou não
       ocorre. Se ocorrer uma verificação aqui também, o robô ficará perdido. Por isso, o estágio 2 é exatamente igual o estágio 0 mas sem a verificação
       */
    } else if (r.estagio == 2) {

      //Set de funções para sempre definir qual o ponto do objetivo
      r.setObj(sombra);
      //noFill();
      //stroke(255);
      //ellipse(sombra.x, sombra.y, 20, 20);
      //arrow(sombra.x, sombra.y, bola.x, bola.y);

      if (distSq(r.pos, sombra) < 15*15) {

        println("ESTRATÉGIA: Chegou na sombra real. Indo em direção a bola");
        r.setObj(bola.pos);
        r.estagio = 3;
        break;
      }

      /*
        Este bloco nos diz que caso a bola se distancie muito do robô enquanto ele perseguia sua sombra, não podemos continuar
       ignorando a bola estando possivelmente entre o robô e a sombra, pois agora o código estaria preso no estagio == 2.
       Neste caso, devemos resetar para o estágio 0, onde existe a checagem se a bola está no meio ou não
       */
      if (distSq(r.pos, bola.pos) > 150*150) {
        println("ESTRATÉGIA: Robô " + r.index + " se distanciou muito da bola enquanto perseguia sua sombra real. Resetando estágios");
        r.estagio = 0;
      }

      /*
        Neste ponto do código o robô´já encontrou a sombra da bola. Agora ele irá em direção
       a bola e só irá parar caso a distância entre eles também fique muito grande
       */
    } else if (r.estagio == 3) {
      //println("passou por aqui");
      //novo objetivo do robo é a própria bola
      r.setObj(bola.pos);
      //noFill();
      //stroke(255);
      //ellipse(r.obj.x, r.obj.y, 20, 20);
      //arrow(r.obj.x, r.obj.y, bola.x, bola.y);

      /*
        Aqui, antes de mandarmos ele seguir a bola devemos checar se faz sentido correr atrás dela ou não. Isso checaremos
       através da distância entre o robô e a bola
       */
      float distTol = 130;
      //Significa que tá muito longe, reseta tudo
      if (distSq(r.pos, bola.pos) > distTol*distTol) {
        println("ESTRATÉGIA: Robo " + r.index + " se afastou demais da bola. Resetando os estágios");
        r.estagio = 0;
        break;
      }

      //Caso não esteja muito longe, segue o baile.
    }


    break;

  case 3:    // zagueiro jogando como "goleiro adiantado" 
    // Se a bola estiver atrás, ativa o atacante basico
    if (!ladoCampo && bola.pos.x < r.pos.x) {
      println("EST: bola atrás do robo");
      r.setEstrategia(1);
    } else if (ladoCampo && bola.pos.x > r.pos.x) r.setEstrategia(1);
    // Se a bola estiver na frente, atua como o goleiro
    else {
      println("EST: bola na frente do robo");
      r.setEstrategia(0);
    }
    break;

  case 2:     // Goleiro segue a projecao da bola

    // Antes de qualquer coisa, checa se está perto da bola
    if (r.isNear(bola.pos, 50)) {
      if (frameCount - qtdFrames > 45) {
        r.girando = false;
        qtdFrames = frameCount;
        //println("ESTRATEGIA: Bola está proxima do goleiro, girando no próprio eixo.");
      } else {
        r.girando = true;
        // checa o sentido do giro
        if (bola.pos.y < r.pos.y) {
          println("ESTRATEGIA: Bola está proxima do goleiro, girando no sentido horário.");
          gira(r, true);
        } else {
          println("ESTRATEGIA: Bola está proxima do goleiro, girando no sentido anti horario.");
          gira(r, false);
        }
      }
      break;
    }
    r.girando = false;

    // Garante que a bola ja possui rastro
    if (bola.vel == null) return;

    // Garante que a bola está se aproximando com velocidade minima
    if (!bola.isAprox(golAmigo) || bola.vel.mag() < 5) {
      // Se estiver se afastando, segue o Y da bola
      r.setEstrategia(0);
      return;
    }

    // Equacao da reta da bola
    aBola = bola.vel.y / bola.vel.x;
    bBola = bola.pos.y - aBola * bola.pos.x;
    //line(bola.x, bola.y, bola.x + 100*velBola.x, bola.y + 100*velBola.y);

    // Intereseccao com a linha do gol
    if (ladoCampo) inter.x = golAmigo.x - distXGoleiro;
    if (!ladoCampo) inter.x = golAmigo.x + distXGoleiro;
    inter.y = aBola * inter.x + bBola;

    // Só admite projecao se nao houver choques com as paredes
    if (inter.y < 0 || inter.y > height) {
      r.setEstrategia(0);
      return;
    }

    if (inter.y > golAmigo.y + distYGoleiro) inter.y = golAmigo.y + distYGoleiro;
    if (inter.y < golAmigo.y - distYGoleiro) inter.y = golAmigo.y - distYGoleiro;

    ellipse(inter.x, inter.y, 15, 15);
    r.setObj(inter);

    break;

    // segue a bola
  case 4:
    r.setObj(bola.pos);
    break;

    // segue o mouse
  case 5:
    if (distSq(r.pos.x, r.pos.y, mouseX, mouseY) < 15*15) r.setObj(r.pos);
    else r.setObj(mouseX, mouseY);
    break;

  case 6: // começo de jogo com posse de bola (p)
    // assim liberar o radio, ja ta valendo
    // o goleiro continua sendo goleiro
    if (r.index == 0) r.setEstrategia(0);
    // o zagueiro continua sendo zagueiro
    if (r.index == 1) r.setEstrategia(3);
    // o atacante... bem, ataca rs
    if (r.index == 2) {
      r.frente = false;
      r.girando = true;      // gambiarra pra permitir velocidades maiores q velMax
      r.setVel(63, 63);
    }
    break;

  case 7:  // começo de jogo sem a posse de bola (P)
    // assim que liberar o radio, ja ta valendo
    // o goleiro continua sendo goleiro
    if (r.index == 0) r.setEstrategia(0);
    // o zagueiro e o atacante aceleram pra frente
    if (r.index == 1 || r.index == 2) {
      r.frente = false;
      r.girando = true;    // gambiarra pra permitir velocidades maiores q velMax
      r.setVel(63, 63);
    }
    break;
    // falta a nosso favor (f)
  case 8:
    // checa se vamos nos posicionar ou já é pra valer
    if (posicionarParado) {
      // assim que liberar o radio, ainda vamos nos posicionar
    } else {
      // assim liberar o radio, ja ta valendo
      // o goleiro continua sendo goleiro
      if (r.index == 0) r.setEstrategia(0);
      // o zagueiro continua sendo zagueiro
      if (r.index == 1) r.setEstrategia(3);
      // o atacante... bem, ataca rs
      if (r.index == 2) {
        r.frente = false;
        r.girando = true;      // gambiarra pra permitir velocidades maiores q velMax
        r.setVel(63, 63);
      }
    }
    break;
    // falta contra nós (F)
  case 9:
    // checa se vamos nos posicionar ou já é pra valer
    if (posicionarParado) {
      // assim que liberar o radio, ainda vamos nos posicionar
    } else {
      // assim que liberar o radio, ja ta valendo
      // o goleiro continua sendo goleiro
      if (r.index == 0) r.setEstrategia(0);
      // o zagueiro acelera pra frente
      if (r.index == 1) {
        r.frente = false;
        r.girando = true;    // gambiarra pra permitir velocidades maiores q velMax
        r.setVel(63, 63);
      }
      // o atacante espera a bola se aproximar e gira
      if (r.index == 2) r.setEstrategia(10);
    }
    break;
    // gira no próprio eixo na presença da bola
  case 10:
    // Antes de qualquer coisa, checa se está perto da bola
    if (r.isNear(bola.pos, 50)) {
      if (frameCount - qtdFrames > 45) {
        r.girando = false;
        qtdFrames = frameCount;
        //println("ESTRATEGIA: Bola está proxima do goleiro, girando no próprio eixo.");
      } else {
        r.girando = true;
        // checa o sentido do giro
        if (bola.pos.y < r.pos.y) {
          println("ESTRATEGIA: Bola está proxima do goleiro, girando no sentido horário.");
          gira(r, true);
        } else {
          println("ESTRATEGIA: Bola está proxima do goleiro, girando no sentido anti horario.");
          gira(r, false);
        }
      }
      break;
    }
    r.girando = false;
    break;
  }
}
