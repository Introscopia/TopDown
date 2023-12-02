
class Entidade{
  int tID;
  int x,y;
  Entidade( int tID, int x, int y ){
    this.tID = tID;
    this.x = x;
    this.y = y;
  }
  void display( PImage[] tiles ){
    image( tiles[ tID ], x*16, y*16 );
  }
  boolean step( int[][] MAP ){ return true; }
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
    super(tID, x, y );
    this.dir = dir;
  }
  boolean step(int[][] MAP){
    int up = (dir == 0)? 1 : 0;
    int left = (dir == 3)? 1 : 0;
    int down = (dir == 2)? 1 : 0;
    int right = (dir == 1)? 1 : 0;
    int px = x;
    int py = y;
    super.move( up, left, down, right, MAP );
    if( px == x && py == y ) return false;
    return true;
  }
}
