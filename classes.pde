class Entidade{
	int tID;
	int x,y;
  boolean solido;
	Entidade( int tID, int x, int y, boolean solido ){
		this.tID = tID;
		this.x = x;
		this.y = y;
    this.solido = solido;
	}
	void display( PImage[] tiles ){
		image( tiles[ tID ], x*16, y*16 );
	}

	// O step() de cada entidade roda todo frame.
	// se ele devolver false, a entidade é retirada do jogo.
	boolean step(){ return true; }

	void morri(){} //função executada antes da entidade ser removida do jogo.

	void signal( int s ){} //função pra enviarmos "sinais" pras entidades

  String get_string(){ return null; }

  boolean mesma_posicao( Entidade E ){
    return ( x == E.x && y == E.y );
  }

	void move( int up, int left, int down, int right, int[][] MAP ){
		if( up + down + left + right > 0 ){
			int dx = right - left;
			int dy = down - up;

			if( dx != 0 && dy != 0 ){//diagonal movement
				if( MAP[x + dx][y + dy] > 0 ){
					boolean ox = MAP[x + dx][y] > 0;
					boolean oy = MAP[x][y + dy] > 0;
					if( ox && !oy ) dx = 0;
					else if( !ox && oy ) dy = 0;
					else{
						return;
					}
				}
			}
			else if( dx != 0 || dy != 0 ){
				if( MAP[x + dx][y] > 0 ){//horizontal
					dx = 0;
				}
				if( MAP[x][y + dy] > 0 ){//vertical
					dy = 0;
				}
			}
			x += dx;
			y += dy;
		}
	}
}

class Tiro extends Entidade{
	int dir;
	Tiro( int tID, int x, int y, int dir ){
		super( tID, x, y, false );
		this.dir = dir;
	}
	boolean step(){
		int    up = (dir == 0)? 1 : 0;
		int right = (dir == 1)? 1 : 0;
		int  down = (dir == 2)? 1 : 0;
		int  left = (dir == 3)? 1 : 0;
		int px = x;
		int py = y;
		super.move( up, left, down, right, MAP );
		if( px == x && py == y ) return false;
		return true;
	}
}

int[] explosao = { 413, 412, 412, 414, 756, 414, 756, 414, 756 };

class Inimigo extends Entidade{
	boolean vivo;
	Inimigo( int tID, int x, int y ){
		super( tID, x, y, true );
		vivo = true;
	}
	boolean step(){
		return vivo;
	}
	void morri(){
		entidades.add( new SFX( x, y, explosao ) );
	}
	void signal( int s ){
		if( s == -99 ){
			vivo = false;
			//println("Fui atingido!!");
		}
	}
}

class Porta extends Entidade{
	Porta( int tID, int x, int y ){
		super( tID, x, y, true );
	}
	void signal( int s ){// quando a porta abre ela muda o seu tile para a porta aberta.
		if( s == 222 ){
			tID = 290;
      solido = false;
		}
	}
}

class SFX extends Entidade{
	int[] animacao;
	int idade;
	SFX( int x, int y, int[] anim ){
		super( 0, x, y, false );
		animacao = anim;
		idade = 0;
	}

	boolean step(){ 
		if( idade < animacao.length ){
			tID = animacao[ idade ];
			idade += 1;
			return true;
		}
		else{
			return false;
		}
	}
}

class Portal extends Entidade{
  String destino;
  Portal( int tID, int x, int y, String dest ){
    super( tID, x, y, false );
    destino = dest;
  }
  String get_string(){ return destino; }
}
