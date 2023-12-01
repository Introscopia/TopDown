
int E = 20;

PImage[] tiles;

XML[] layers;
int[][] MAP;

ArrayList<Entidade> entidades;

int up, left, down, right;
int bu, bl, bd, br;

void setup() {
   size(640, 640);
   
  PImage tilesheet = loadImage("Kenney 1-bit colored_transparent.png");
  tiles = new PImage[1024];
  int t = 0;
  for(int j = 0; j < 32; j++){
    for(int i = 0; i < 32; i++){
      tiles[t++] = tilesheet.get( 17*i, 17*j, 16, 16 );
    }
  }
    
  XML mapa = loadXML("mapa.xml");
  layers = mapa.getChildren("layer");
  MAP = new int [E][E];
  load_layer( 0 );
  
  entidades = new ArrayList();
  entidades.add( new Entidade( 121, 1, 1 ) );
  
  noSmooth();
  frameRate(6);
}

void draw() {
   background(0);
   
  scale(2);
  for(int j = 0; j < 20; j++){
    int J = j * 16;
    for(int i = 0; i < 20; i++){
      image( tiles[ MAP[i][j] ], i*16, J );
    }
  }

  entidades.get(0).move( up, left, down, right, MAP );

  if( bu < 0 ) up    = 0;
  if( bd < 0 ) down  = 0;
  if( bl < 0 ) left  = 0;
  if( br < 0 ) right = 0;

  if( up    > 0 && bu == 0 ) bu = 1;
  if( down  > 0 && bd == 0 ) bd = 1;
  if( left  > 0 && bl == 0 ) bl = 1;
  if( right > 0 && br == 0 ) br = 1;
  
  for(int i = 0; i < entidades.size(); i++){
    entidades.get(i).display( tiles );
  }
  
}




void keyPressed() {
  if (key == 'w' || key == 'W' || (key == CODED && keyCode == UP   ) ) { up = 1;    bu = 0; }
  if (key == 's' || key == 'S' || (key == CODED && keyCode == DOWN ) ) { down = 1;  bd = 0; }
  if (key == 'a' || key == 'A' || (key == CODED && keyCode == LEFT ) ) { left = 1;  bl = 0; }
  if (key == 'd' || key == 'D' || (key == CODED && keyCode == RIGHT) ) { right = 1; br = 0; }
}
void keyReleased(){
  if (key == 'w' || key == 'W' || (key == CODED && keyCode == UP)    ) {
    if( bu > 0 ) up = 0;
    else bu = -1;
  }
  if (key == 's' || key == 'S' || (key == CODED && keyCode == DOWN)  ) {
    if( bd > 0 ) down = 0;
    else bd = -1;
  }
  if (key == 'a' || key == 'A' || (key == CODED && keyCode == LEFT)  ) {
    if( bl > 0 ) left = 0;
    else bl = -1;
  }
  if (key == 'd' || key == 'D' || (key == CODED && keyCode == RIGHT) ) {
    if( br > 0 ) right = 0;
    else br = -1;
  }
}



void load_layer( int L ){
  String data = layers[L].getContent();
  String[] spl = split(data, ',');
  int t = 0;
  for(int j = 0; j < 20; j++){
     for(int i = 0; i < 20; i++){
       MAP[i][j] = int(trim(spl[t++]))-1;
       if( MAP[i][j] < 0 ) MAP[i][j] = 0;
     }
  }
}
