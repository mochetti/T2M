/*
// Funcao que atribui identidade aos objetos
boolean id() {
  // raio de busca por verdes com o vermelho no centro
  int raioBusca = 55;
  for(Blob b : blobs) {
    switch(b.cor) {
      // O id depende da cor do blob
      case 0:    // Laranja
        // O objeto só pode ser a bola
        b.id = 0;
      break;
      
      case 1:    // Vermelho
        // O objeto depende da quantidade de verdes ao redor
        int qVerde = 0;
        for(Blob v : blobs) {
          if(v.cor == 2 && distSq(b.center().x, b.center().y, v.center().x, v.center().y) < raioBusca*raioBusca) {
            qVerde++;
          }
        }
        if(qVerde > 0) b.id = qVerde;
        else b.id = -1;
        
        // Raio de busca por verdes
        //noFill();
        //stroke(255);
        //ellipse(b.center().x, b.center().y, raioBusca, raioBusca);
      break;
      
      case 2:    // Verde
        // O objeto depende da orientação do robo
        // Verifica qual robo
        for(Blob v : blobs) {
          // Distancia entre as tags vermelha e verde
          float distVV = dist(b.center().x, b.center().y, v.center().x, v.center().y);
          float ang, cx, cy;
          boolean achou = false, achou2 = false;
          
          if(v.cor == 1 && distVV < raioBusca) {
            
            switch(v.id) {
              case 1:     // Somente 1 verde
                b.id = 4;
              break;
              
              case 2:    // 2 verdes
                // Calcula o angulo da reta formada pelo verde em questao e o centro do robo
                ang = atan2(- v.center().y + b.center().y, - v.center().x + b.center().x);
                //println("Ang = " + ang*180/PI);
                
                // Soma 90 graus nesse angulo
                if(ang < 0) ang += PI/2;
                else ang -= PI/2;
                
                // Coordenada de onde o outro verde pode estar
                cx = v.center().x + distVV * cos(ang);
                cy = v.center().y + distVV * sin(ang);
                
                // Raio de busca por outra quina
                //noFill();
                //stroke(255);
                //ellipse(cx, cy, 15, 15);
                                                
                // Verifica se há outro verde onde deveria haver
                achou = false;
                for(Blob t : blobs) {
                  if(t.cor == 2 && distSq(t.center().x, t.center().y, cx, cy) < 15*15) {
                    // Havia outro verde lá
                    b.id = 5;
                    achou = true;
                    //b.show(color(0,255,0));
                  }
                }
                if(!achou) {
                  // Não havia outro verde lá
                  b.id = 6;
                  //b.show(color(255,0,0));
                }
              break;
              
              case 3:    // 3 verdes
                ang = atan2(b.center().x - v.center().x, b.center().y - v.center().y);
                //println("Ang = " + ang*180/PI);
                if(ang > -PI/2 && ang < 0) ang -= PI/2;
                else ang += PI/2;
             
                cx = v.center().x + distVV * cos(ang);
                cy = v.center().y + distVV * sin(ang);
                
                // Raio de busca por outra quina
                //noFill();
                //stroke(255);
                //ellipse(cx, cy, 15, 15);
                
                // Verifica se há outro verde onde deveria haver
                for(Blob t : blobs) {
                  if(t.cor == 2 && distSq(t.center().x, t.center().y, cx, cy) < 15*15) {
                    // Verifica se há um terceiro verde
                    if(ang > -PI/2 && ang < 0) ang -= PI/2;
                    else ang += PI/2;
                    cx = v.center().x + distVV * cos(ang);
                    cy = v.center().y + distVV * sin(ang);
                    
                    // Raio de busca por outra quina
                    //noFill();
                    //stroke(255);
                    //ellipse(cx, cy, 15, 15);
                    
                    for(Blob u : blobs) {
                      if(u.cor == 2 && distSq(u.center().x, u.center().y, cx, cy) < 15*15) {
                        //println("id 9");
                        b.id = 9;
                        achou = true;
                      }
                      else {
                        //println("id 8");
                        b.id = 8;
                        achou2 = true;
                      }
                      if(achou) break;
                    }
                  }
                  else {
                    //println("id 7");
                    b.id = 7; 
                  }
                  if(achou || achou2) break;
                }
              break;
              
              default:
                b.id = -1;
              break;
            }
          }
        }
      default:
      break;
    }
  }
  
  // Coloca em ordem crescente de id
  if(ordenar()) return true;
  return false;
}
*/
