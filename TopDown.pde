int E = 20;

PImage[] tiles;

XML[] layers;
XML[] objectgroups;
HashMap<String,Integer> tipos_de_entidade;
int[][] MAP;

ArrayList<Entidade> entidades;

int up, left, down, right;
int bu, bl, bd, br;

int direcao = -1;
/*   0
   3 d 1
     2   */
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
	entidades.add( new Entidade( 121, 1, 1, true ) );

	tipos_de_entidade = new HashMap<String,Integer>();
	tipos_de_entidade.put(   "arma", 1);
	tipos_de_entidade.put(  "chave", 2);
	tipos_de_entidade.put(  "porta", 3);
	tipos_de_entidade.put("inimigo", 4);

	XML mapa = loadXML("mapa.xml");
	layers = mapa.getChildren("layer");
	objectgroups = mapa.getChildren("objectgroup");
	println("mapa.xml has", layers.length, "layers, and", objectgroups.length, "objectgroups." );
	MAP = new int [E][E];
	load_map( 0 );

	noSmooth();
	frameRate(8);
}

void draw() {
	background(0);
	
	// desenhar o mapa
	scale(2);
	for( int j = 0; j < E; j++ ){
		int J = j * 16;
		for (int i = 0; i < E; i++) {
			image( tiles[ MAP[i][j] ], i*16, J );
		}
	}
	
	if ( atirar && tem_arma ) {
		//colocar o novo tiro na lista de entidades
		entidades.add( new Tiro( 663 + direcao, entidades.get(0).x, entidades.get(0).y, direcao ) );
		atirar = false;
	}
	
  int px = entidades.get(0).x;
  int py = entidades.get(0).y;
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
	for(int i = entidades.size()-1; i >= 1; i--){
		if( entidades.get(i) instanceof Tiro ) {
			for(int j = entidades.size()-1; j >= 1; j--){
				if( entidades.get(j) instanceof Inimigo ){
					if( entidades.get(i).mesma_posicao(entidades.get(j)) ) {
						entidades.get(j).signal( -99 );
						entidades.remove(i);
						i--;
						break;
					}
				}
			}
		}
	}
	
	// e aqui detectamos as colisões do player com os itens com os quais ele pode interagir.
	for (int i = entidades.size()-1; i >= 1; i--) {
		if ( entidades.get(0).mesma_posicao(entidades.get(i)) ){
  
      if( entidades.get(i).solido ){
        entidades.get(0).x = px;
        entidades.get(0).y = py;
      }

			switch( entidades.get(i).tID ) {
				case 753:// CHAVE
					tem_chave = true;
					entidades.remove(i);
					break;
				case 998:// ARMA
					tem_arma = true;
					entidades.remove(i);
					break;
				case 288:// PORTA
					if ( tem_chave ) {
						entidades.get(i).signal( 222 );
					}
					break;
			}

      if( entidades.get(i) instanceof Portal ){
        XML mapa = loadXML( entidades.get(i).get_string()+".xml" );
        println( "indo para novo mapa: ", entidades.get(i).get_string() );
        
        for (int j = entidades.size()-1; j >= 1; j--){
          entidades.remove(j);
        }
        
        layers = mapa.getChildren("layer");
        objectgroups = mapa.getChildren("objectgroup");
        println("mapa.xml has", layers.length, "layers, and", objectgroups.length, "objectgroups." );
        MAP = new int [E][E];
        load_map( 0 );
        i = 0;        
      }
		}
	}
	
	//aqui damos o 'step' e desenhamos todas as entidades
	// incluido o player, inimigos, tiros, chave, etc
	for (int i = entidades.size()-1; i >= 0; i--) {
		if( entidades.get(i).step() ){
			entidades.get(i).display( tiles );
		} 
		else{
			entidades.get(i).morri();
			entidades.remove(i);
		}
	}

	//display_text( "Texto * 12345$", 1, 1 );
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



//const float angles [] =           { 0,             -90,                 0,                 -90,           0,                   90,            180,           90 };
//const SDL_RendererFlip flips [] = { SDL_FLIP_NONE, SDL_FLIP_HORIZONTAL, SDL_FLIP_VERTICAL, SDL_FLIP_NONE, SDL_FLIP_HORIZONTAL, SDL_FLIP_NONE, SDL_FLIP_NONE, SDL_FLIP_HORIZONTAL };
//const byte flags [] =               { 0,             0,                   1,                 0,             2,                   0,             3,             0  };

void load_map( int L ){
	println( "Loading layer "+layers[L].getString("name") );
	String data = layers[L].getContent();
	String[] spl = split(data, ',');
	int t = 0;
	for (int j = 0; j < 20; j++) {
		for (int i = 0; i < 20; i++) {

			int N = int(trim(spl[t++]));

			if( N > 0x1FFFFFFF ){
				MAP[i][j] = (N & 0x1FFFFFFF) - 1;
				//char transform = N >> 29;
				// = flags[ transform ];
			} else{
				MAP[i][j] = N-1;
			}
			if ( MAP[i][j] < 0 ) MAP[i][j] = 0;

			/*for ( int e = 0; e < ent_ids.length; e++ ) {
				if ( MAP[i][j] == ent_ids[e] ) {
					entidades.add( new Entidade( MAP[i][j], i, j ) );
					MAP[i][j] = 0;
				}
			}*/
		}
	}

	println( "and now looking into layer "+objectgroups[L].getString("name") );

	XML[] ents = objectgroups[L].getChildren("object");
	println( "contem", ents.length, "ents");

	for(int i = 0; i < ents.length; i++) {
		int tID = int(ents[i].getString("gid"))-1;
		int x = int(ents[i].getString("x")) / 16;
		int y = (int(ents[i].getString("y")) / 16)-1;
		//println( tID, x, y );	
		XML[] props = ents[i].getChildren("properties");
		XML[] prop = props[0].getChildren("property");
		for(int p = 0; p < prop.length; p++){
			//println( prop[p].getString("value") );
			if( prop[p].getString("name").equals("tipo") ){

				int tipo = tipos_de_entidade.get( prop[p].getString("value") );
				//println( "tipo:", tipo );
				switch( tipo ){
					case 1: // arma
						entidades.add( new Entidade( tID, x, y, false ) );
						break;
					case 2: // chave
						entidades.add( new Entidade( tID, x, y, false ) );
						break;
					case 3: // porta
						entidades.add( new Porta( tID, x, y ) );
						break;
					case 4: // inimigo
						entidades.add( new Inimigo( tID, x, y ) );
						break;
				}
			}
			else{//outras propriedades...
        if( prop[p].getString("name").equals("portal") ){
          entidades.add( new Portal( tID, x, y, prop[p].getString("value") ) );
        }
			}
		}
	}
	println( "entidades.size(): ", entidades.size() );
}


void display_text( String text, int x, int y ){
	String str = text.toUpperCase();
	fill(0);
	int ox = x;
	for ( int i = 0; i < text.length(); i++ ) {
		int tID = 0;
		if( str.charAt(i) >= 'A' && str.charAt(i) < 'N' ){
			tID = 979 + (str.charAt(i) - 'A');
		} else if( str.charAt(i) >= 'N' && str.charAt(i) <= 'Z' ){
			tID = 1011 + (str.charAt(i) - 'N');
		} else if ( str.charAt(i) >= '0' && str.charAt(i) <= '9' ){
			tID = 947 + (str.charAt(i) - '0');
		}
		else if( str.charAt(i) == ':' ) tID = 957;
		else if( str.charAt(i) == '.' ) tID = 958;
		else if( str.charAt(i) == '%' ) tID = 959;
		else if( str.charAt(i) == '$' ) tID = 809;//915;
		else if( str.charAt(i) == '!' ) tID = 819;
		else if( str.charAt(i) == '?' ) tID = 821;
    else if( str.charAt(i) == '*' ) tID = 335;
		else if( str.charAt(i) == '\n'){
			y += 1;
			x = ox;
			continue;
		}
		rect( x*16, y*16, 16, 16 );
		image( tiles[ tID ], x*16, y*16 );
		x += 1;
	}
}
