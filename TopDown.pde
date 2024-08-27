
int E = 20;

PImage[] tiles;

XML[] layers;
int[][] MAP;

ArrayList<Entidade> entidades;

int[] ent_ids = {752, 288, 223, 998};

int up, left, down, right;
int bu, bl, bd, br;

int direcao = -1;
/*     0           
     3 d 1          
       2      */
boolean atirar = false;

boolean tem_chave = false;
boolean tem_arma = false;

void setup() {
  size(640, 640);

  PImage tilesheet = loadImage("Kenney 1-bit colored_transparent.png");
  tiles = new PImage[1024];
  int t = 0;
  for (int j = 0; j < 32; j++) {
    for (int i = 0; i < 32; i++) {
      tiles[t++] = tilesheet.get( 17*i, 17*j, 16, 16 );
    }
  }

  entidades = new ArrayList();
  // criar o player
  entidades.add( new Entidade( 121, 1, 1 ) );

  XML mapa = loadXML("mapa.xml");
  layers = mapa.getChildren("layer");
  MAP = new int [E][E];
  load_layer( 0 );

  noSmooth();
  frameRate(8);
}

void draw() {
  background(0);
  
  // desenhar o mapa
  scale(2);
  for (int j = 0; j < 20; j++) {
    int J = j * 16;
    for (int i = 0; i < 20; i++) {
      image( tiles[ MAP[i][j] ], i*16, J );
    }
  }
  
  if ( atirar ) {
    //colocar o novo tiro na lista de entidades
    entidades.add( new Tiro( 663 + direcao, entidades.get(0).x, entidades.get(0).y, direcao ) );
    atirar = false;
  }
  
  //player da o passinho
  entidades.get(0).move( up, left, down, right, MAP );
  
  // esses latches ajudam um pouco no 'gamefeel'...
  if ( bu < 0 ) up    = 0;
  if ( bd < 0 ) down  = 0;
  if ( bl < 0 ) left  = 0;
  if ( br < 0 ) right = 0;

  if ( up    > 0 && bu == 0 ) bu = 1;
  if ( down  > 0 && bd == 0 ) bd = 1;
  if ( left  > 0 && bl == 0 ) bl = 1;
  if ( right > 0 && br == 0 ) br = 1;
  
  // nesses loops estamos detectando as colisões dos tiros com os inimigos
  for (int i = entidades.size()-1; i >= 1; i--) {
    if ( entidades.get(i) instanceof Tiro ) {
      for (int j = entidades.size()-1; j >= 1; j--) {
        if ( entidades.get(j).tID == 223 ) {
          if ( entidades.get(i).x == entidades.get(j).x &&
               entidades.get(i).y == entidades.get(j).y ) {
            if ( j < i ) {
              entidades.remove(i);
              entidades.remove(j);
            } else {
              entidades.remove(j);
              entidades.remove(i);
            }
            i--;
            break;
          }
        }
      }
    }
  }
  
  // e aqui detectamos as colisões do player com os itens com os quais ele pode interagir.
  for (int i = entidades.size()-1; i >= 1; i--) {
    if ( entidades.get(0).x == entidades.get(i).x &&
         entidades.get(0).y == entidades.get(i).y ) {

      switch( entidades.get(i).tID ) {
      case 752 :// CHAVE
        tem_chave = true;
        entidades.remove(i);
        break;
      case 998 :// ARMA
        tem_arma = true;
        entidades.remove(i);
        break;
      case 288 :// PORTA
        if ( tem_chave ) {
          entidades.remove(i);
        } else {
          entidades.get(0).x -= 1;
        }
        break;
      }
    }
  }
  
  //aqui damos o 'step' e desenhamos todas as entidades
   // incluido o player, inimigos, tiros, chave, etc
  for (int i = entidades.size()-1; i >= 0; i--) {
    if ( entidades.get(i).step( MAP ) ) {
      entidades.get(i).display( tiles );
    } else {
      entidades.remove(i);
    }
  }
}




void keyPressed() {
  if (key == 'w' || key == 'W' || (key == CODED && keyCode == UP   ) ) {
    up = 1;
    bu = 0;
    direcao = 0;
  }
  if (key == 's' || key == 'S' || (key == CODED && keyCode == DOWN ) ) {
    down = 1;
    bd = 0;
    direcao = 2;
  }
  if (key == 'a' || key == 'A' || (key == CODED && keyCode == LEFT ) ) {
    left = 1;
    bl = 0;
    direcao = 3;
  }
  if (key == 'd' || key == 'D' || (key == CODED && keyCode == RIGHT) ) {
    right = 1;
    br = 0;
    direcao = 1;
  }
}
void keyReleased() {
  if (key == 'w' || key == 'W' || (key == CODED && keyCode == UP)    ) {
    if ( bu > 0 ) up = 0;
    else bu = -1;
  }
  if (key == 's' || key == 'S' || (key == CODED && keyCode == DOWN)  ) {
    if ( bd > 0 ) down = 0;
    else bd = -1;
  }
  if (key == 'a' || key == 'A' || (key == CODED && keyCode == LEFT)  ) {
    if ( bl > 0 ) left = 0;
    else bl = -1;
  }
  if (key == 'd' || key == 'D' || (key == CODED && keyCode == RIGHT) ) {
    if ( br > 0 ) right = 0;
    else br = -1;
  }
  if ( key == ' ' ) atirar = true;
}



void load_layer( int L ) {
  String data = layers[L].getContent();
  String[] spl = split(data, ',');
  int t = 0;
  for (int j = 0; j < 20; j++) {
    for (int i = 0; i < 20; i++) {
      MAP[i][j] = int(trim(spl[t++]))-1;
      if ( MAP[i][j] < 0 ) MAP[i][j] = 0;

      for ( int e = 0; e < ent_ids.length; e++ ) {
        if ( MAP[i][j] == ent_ids[e] ) {
          entidades.add( new Entidade( MAP[i][j], i, j ) );
          MAP[i][j] = 0;
        }
      }
    }
  }
}
