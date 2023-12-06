void setup(){
 //fullScreen();
 size(500, 500);
}
int N_A = 500;
int sizeA = 3;
int sizeB = 1;

int state_w = 500;
int state_h = 500;

int t = 0;

int[][] popA = new int[N_A][2];

int[] action = new int[4];
float[][][] Q = new float[state_w][state_h][];

int sum_reward  = 0;
int[] sum_reward_list  = new int[state_w];
int epock = 0;

void draw(){
  background(0);
  fill(color(200,10,100));
  if (t == 0){
    popA = init(popA);
    Q = init_Q(Q);
  }
  else if(t%500 == 0){
    popA = init(popA);
  }
  else {
    popA = update_state(popA, Q);
    Q = update_Q(popA, Q);
  }
  display_Q(Q);
  for (int i = 0;i< popA.length;i++){
    noStroke();
    fill(color(random(256),255,255));
    int x = popA[i][0];
    int y = popA[i][1];
    ellipse(x, y,sizeA, sizeA);
  }
  
  t++;
  //display_reward();
  //save("snap.jpg");
}

int[][] init(int pop[][]){
  for (int i = 0;i< pop.length;i++){
    int x = int(random(state_w));
    int y = int(random(state_h));
    pop[i][0] = x;
    pop[i][1] = y;
  }
  return pop;
}

int[][] update_state(int pop[][], float Q[][][]){
  for (int i = 0;i< pop.length;i++){
    int x = pop[i][0];
    int y = pop[i][1];
    int dx = 0;
    int dy = 0;
    float epsilon = 0.9;
    if (epsilon <= random(1) || Q[x][y][0] == Q[x][y][1] || Q[x][y][2] == Q[x][y][3]){
      if(random(1) <= 0.5 && x+1 < state_w){
        dx += 1;
      } else if (x-1 > 0){
        dx -= 1;
      }
      if(random(1) <= 0.5  && y+1 < state_h){
        dy += 1;
      } else if (y-1 > 0){
        dy -= 1;
      }
    } else {
      if (Q[x][y][0] > Q[x][y][1] && x+1 < state_w){
      dx += 1;
      } else if (x-1 > 0){
        dx -= 1;
      }
      if (Q[x][y][2] > Q[x][y][3] && y+1 < state_h){
        dy += 1;
      } else if (y-1 > 0){
        dy -= 1;
      }
    }
    pop[i][0] += dx;
    pop[i][1] += dy;
  }
  return pop;
}

float[][][] update_Q(int pop[][], float Q[][][]){
  for (int n = 0;n< pop.length;n++){
     int x = pop[n][0];
     int y = pop[n][1];
     float learning = 0.1;
     float discount = 0.9;
     float[] Q_prime = new float[action.length];
     
     if (x+1 < state_w){
     Q_prime[0] = reward(x+1,y);
       for (int i=0; i<action.length; i++){
         Q_prime[0] += Q[x+1][y][i];
       }
     } else Q_prime[0] = -1;
     if (x-1 > 0){
       Q_prime[1] = reward(x-1,y);
      for (int i=0; i<action.length; i++){
         Q_prime[1] += Q[x-1][y][i];
       }
     } else Q_prime[1] = -1;
     if (y+1 < state_h){
       Q_prime[2] = reward(x,y+1);
       for (int i=0; i<action.length; i++){
         Q_prime[2] += Q[x][y+1][i];
       }
     } else Q_prime[2] = -1;
    if (y-1 > 0){
       Q_prime[3] = reward(x,y-1);
       for (int i=0; i<action.length; i++){
         Q_prime[3] += Q[x][y-1][i];
       }
     } else Q_prime[3] = -1;
     
     for (int a=0; a < action.length;a++){
       Q[x][y][a] += learning*(reward(x,y)+discount*max(Q_prime) - Q[x][y][a]);
     }
  }
  return Q;
}


float reward(int x, int y) {
    // 円のパラメータを定義
    int cx = state_w / 2;
    int cy = state_h / 2;
    int font_width = 50;
    int outerRadius = state_w/2-20; // 外側の半径
    int innerRadius = outerRadius - font_width; // 内側の半径

    // 棒のパラメータを定義
    int Ax1 = state_w * 2 / 3;
    int Ay1 = state_w * 2 / 3;
    int Bx1 = state_w * 2 / 3+font_width;
    int By1 = state_w * 2 / 3;
    int Ax2 = state_w * 3 / 4;
    int Ay2 = state_w * 3 / 4;
    int Bx2 = state_w * 3 / 4+font_width;
    int By2 = state_w * 3 / 4;

    // 中空円の範囲内にあるか判断
    int distanceSquared = (x - cx) * (x - cx) + (y - cy) * (y - cy);
    if (distanceSquared <= outerRadius * outerRadius && distanceSquared >= innerRadius * innerRadius) {
        return 1;
    }

    // 長方形（棒）の領域内にあるか判断
    if (isPointAboveLine(Ax1, Ay1, Ax2, Ay2, x, y) == 1 && isPointAboveLine(Bx1, By1, Bx2, By2, x, y) == 0 && x >= 300 && y >= 300) {
        return 1;
    }

    return 0;
}

int isPointAboveLine(int x1, int y1, int x2, int y2, int x, int y) {
    int d = (x - x1) * (y2 - y1) - (y - y1) * (x2 - x1);
    if (d > 0){
      return 1;
    }else{
      return 0;
    }
}


float[][][] init_Q(float Q[][][]){
  for(int i=0; i<Q.length;i++){
    for(int j=0; j<Q[0].length;j++){
      Q[i][j] = new float[action.length];
    }
  }
  return Q;
}

void display_Q(float Q[][][]){
  for(int i=0; i<Q.length;i++){
    for(int j=0; j<Q[0].length;j++){
      for(int k=0; k<Q[0][0].length;k++){
        noStroke();
        float sigm = 1/(1+exp(-Q[i][j][k]));
        fill(color(0,int(255*sigm),128));
        if(k == 1) square(i*sizeB,j*sizeB,sizeB);
      }
    }
  }
}

void display_reward(){
  for(int i=0; i<state_w;i++){
    for(int j=0; j<state_h;j++){
      fill(color(int(255*reward(i,j))));
      square(i*sizeB,j*sizeB,sizeB);
    }
  }
}
