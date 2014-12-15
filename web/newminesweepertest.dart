
import 'dart:html';
import 'dart:math';


TableElement gameGrid;

int numrows = 5;
int difficulty = 4;
int diff1 = 4;
int diff2 = 6;
int diff3 = 10;
int bombsLeft = 6;
int gamenum = 0;
int numcols = 5;
Grid logicGrid;
void main() {
  ButtonElement btn = querySelector('#newGame');
  btn.onClick.listen(newGameHandler);
  //Difficulty buttons
  querySelector('#easy').onClick.listen(diffHandler);
  querySelector('#intermediate').onClick.listen(diffHandler);
  querySelector('#hard').onClick.listen(diffHandler);
  startNewGame();
  
}
void startNewGame(){
  bombsLeft = (difficulty*difficulty)~/7 + (difficulty);
  numrows = numcols = difficulty+1;
  logicGrid = new Grid(numrows,numcols);
  setupLogicGrid();
    gameGrid = querySelector('#gameGrid');
    gameGrid.children.clear();
    for(int x=0;x<numrows;x++){
      gameGrid.addRow();
      for(int y=0;y<numcols;y++){
        gameGrid.rows[x].addCell();
        ImageButtonInputElement button = new ImageButtonInputElement();
        button.src = 'tileDefault.ico';
        button.onClick.listen(clickHandler);
        gameGrid.rows[x].cells[y].append(button);
      }
    }
    gamenum+= 1;
}
void clickHandler(MouseEvent e){
  int clickedY = ((e.target as Node).parent as TableCellElement).cellIndex;
  int clickedX = ((e.target as Node).parent.parent as TableRowElement).rowIndex;
  int code = logicGrid[clickedY][clickedX];
  bool shifted = e.shiftKey;
  print(clickedX);print(clickedY);
  print(code);
  ImageButtonInputElement button = gameGrid.rows[clickedX].cells[clickedY].lastChild;
  //ShiftClick
  if(shifted){
    if(code==1){
      code = 91;
      button.src = 'tileFlagged.ico';
      bombsLeft-=1;
    }else if(code%10==0){
      button.src = 'tileFlagged.ico';
      code += 9;
      bombsLeft-=1;
    }else if(code==91 || code%10==9){
      button.src = 'tileDefault.ico';
      code==91?code=1:code-=9;
      bombsLeft+=1;
      
    }else{}
  }else{//Normal Click
    if(code==1){
      button.src = 'tileBomb.ico';
      loseGame();
    }else if(code%10==0 || code%10==9){
      int neighbors = code~/10;
      if(neighbors==0){
        //clearAdjacentZeros(clickedX,clickedY);
      }
      //else{
        code += 2;
        button.src = 'tile' + neighbors.toString() + '.ico';
      //}
    }
  }
  querySelector('#bombsLeft').innerHtml = bombsLeft.toString();
  logicGrid[clickedY][clickedX] = code;
  gameGrid.rows[clickedX].cells[clickedY].lastChild.replaceWith(button);
  //Victory Handler
  if(gameWon()){
    print('game is won');
    winGame();
  }
}
void newGameHandler(MouseEvent e){
  print("newgame!");
  startNewGame();
}

void diffHandler(MouseEvent e){
  print((e.target as ButtonElement).id);
  if((e.target as ButtonElement).id == 'easy'){
    difficulty = diff1;
  }else if((e.target as ButtonElement).id == 'intermediate'){
    difficulty = diff2;
  }else if((e.target as ButtonElement).id == 'hard'){
    difficulty = diff3;
  }
  print(difficulty);
  numrows = numcols = difficulty+1;
}

void setupLogicGrid(){
  for(int j=0;j<numcols;j++){
      for(int k=0;k<numrows;k++){
        logicGrid[j][k] = 0;
      }
    }
  var rand = new Random();
  for(int i=0;i<bombsLeft;i++){
    int nextbomb;
    do{nextbomb = rand.nextInt(numrows*numcols);}while(logicGrid.data[nextbomb] == 1);
    
    logicGrid.data[nextbomb] = 1;
  }
  for(int j=0;j<numcols;j++){
    for(int k=0;k<numrows;k++){
      if(logicGrid[j][k]==0){
        logicGrid[j][k] = countAdjacentBombs(j,k);
      }
    }
  }
  querySelector('#bombsLeft').innerHtml = bombsLeft.toString();
}


int countAdjacentBombs(int j, int k){
  int count = 0;
  if(j>0){
    if(k>0){
      logicGrid[j-1][k-1]%10==1?count+=10:count=count;
    }
    logicGrid[j-1][k]%10==1?count+=10:count=count;
  }
  if(k>0){
    logicGrid[j][k-1]%10==1?count+=10:count=count;
  }
  if(j<(numcols-1)){
    logicGrid[j+1][k]%10==1?count+=10:count=count;
    if(k<(numrows-1)){
      logicGrid[j+1][k+1]%10==1?count+=10:count=count;
    }
  }
  if(k<(numrows-1)){
    logicGrid[j][k+1]%10==1?count+=10:count=count;
  }
  if(j>0&&k<(numrows-1))logicGrid[j-1][k+1]%10==1?count+=10:count=count;;
  
  
  if(j<(numcols-1)&&k>0)logicGrid[j+1][k-1]%10==1?count+=10:count=count;;
  
  return count;
}

void loseGame(){
  //Just remove clickhandler from the table, 
  print("You Lose!");
  for(int i=0;i<numrows;i++){
    for(int j=0;j<numcols;j++){
      gameGrid.rows[i].cells[j].removeEventListener('onClick', clickHandler);
    }
  }
}

void winGame(){
  print("You Win!");
  //get the board to stop responding somehow
  for(int i=0;i<numrows;i++){
    for(int j=0;j<numcols;j++){
      gameGrid.rows[i].cells[j].removeEventListener('onClick', clickHandler);
    }
  }
}
/*
void clearAdjacentZeros(int y,int x){
  logicGrid[x][y] = 2;
  (gameGrid.rows[y].cells[x].lastChild as ImageButtonInputElement).src = 'tile0.ico';
  //check every valid nearby square. call clearAdjacentZeros on any 0s found
  if(x>0){
    if(y>0){
      logicGrid[x-1][y-1]==0?clearAdjacentZeros(y-1,x-1):clearAdjacentTiles(y-1, x-1);
    }
    logicGrid[x-1][y]==0?clearAdjacentZeros(y,x-1):clearAdjacentTiles(y, x-1);
  }
  if(y>0){
    logicGrid[x][y-1]==0?clearAdjacentZeros(y-1,x):clearAdjacentTiles(y-1, x);
  }
  if(x<(numcols-1)){
    logicGrid[x+1][y]==0?clearAdjacentZeros(y,x+1):clearAdjacentTiles(y, x+1);
    if(y<(numrows-1)){
      logicGrid[x+1][y+1]==0?clearAdjacentZeros(y+1,x+1):clearAdjacentTiles(y+1, x+1);
    }
  }
  if(y<(numrows-1)){
    logicGrid[x][y+1]==0?clearAdjacentZeros(y+1,x):clearAdjacentTiles(y+1, x);
  }
  if(x>0&&y<(numrows-1))logicGrid[x-1][y+1]==0?clearAdjacentZeros(y+1,x-1):clearAdjacentTiles(y+1, x-1);
  
  
  if(x<(numcols-1)&&y>0)logicGrid[x+1][y-1]==0?clearAdjacentZeros(y-1,x+1):clearAdjacentTiles(y-1, x+1);
  //reveal square
  
  logicGrid[x][y] = 2;
}


void clearAdjacentTiles(int y, int x){
  if(x>0){
    if(y>0){
      (gameGrid.rows[y-1].cells[x-1].lastChild as ImageButtonInputElement).src = 'tile'+(logicGrid[x-1][y-1]~/10).toString()+'.ico';
      logicGrid[x-1][y-1] += 2;
    }
    (gameGrid.rows[y].cells[x-1].lastChild as ImageButtonInputElement).src = 'tile'+(logicGrid[x-1][y]~/10).toString()+'.ico';
    logicGrid[x-1][y] += 2;
  }
  if(y>0){
    (gameGrid.rows[y-1].cells[x].lastChild as ImageButtonInputElement).src = 'tile'+(logicGrid[x][y-1]~/10).toString()+'.ico';
    logicGrid[x][y-1] += 2;
  }
  if(x<(numcols-1)){
    (gameGrid.rows[y].cells[x+1].lastChild as ImageButtonInputElement).src = 'tile'+(logicGrid[x+1][y]~/10).toString()+'.ico';
    logicGrid[x+1][y] += 2;
    if(y<(numrows-1)){
      (gameGrid.rows[y+1].cells[x+1].lastChild as ImageButtonInputElement).src = 'tile'+(logicGrid[x+1][y+1]~/10).toString()+'.ico';
      logicGrid[x+1][y+1] += 2;
    }
  }
  if(y<(numrows-1)){
    (gameGrid.rows[y+1].cells[x].lastChild as ImageButtonInputElement).src = 'tile'+(logicGrid[x][y+1]~/10).toString()+'.ico';
    logicGrid[x][y+1] += 2;
  }
  if(x>0&&y<(numrows-1)){
    (gameGrid.rows[y+1].cells[x-1].lastChild as ImageButtonInputElement).src = 'tile'+(logicGrid[x-1][y+1]~/10).toString()+'.ico';
    logicGrid[x-1][y+1] += 2;
  }
  
  if(x<(numcols-1)&&y>0){
    (gameGrid.rows[y-1].cells[x+1].lastChild as ImageButtonInputElement).src = 'tile'+(logicGrid[x+1][y-1]~/10).toString()+'.ico';
    logicGrid[x+1][y-1] += 2;
  }
}*/

bool gameWon(){
  bool won = false;
  print('1');
  if(noMoreSquares()){
    print("nomoresquares");
    if(bombsLeft==0)won=true;
  }
  return won;
}

bool noMoreSquares(){
  bool nomore = true;
  int art = 1;
  print('nms?');
  for(int k=0;k<logicGrid.data.length;k++){
    if(logicGrid.data[k]<90 && logicGrid.data[k]%10<2)nomore=false;
  }
  print(nomore);
  return nomore;
}
class Grid {
  //w is rows, h is columns
  int w, h;
  List data;
  List cols;
  Grid(this.w, this.h) {
    data = new List.filled(w * h,0);
    cols = new List.filled(h,new GridCol(data,1,h));
    //x is which column
    for (int x = 0; x < h; x++) {
      cols[x] = new GridCol(data, x, w);
    }
  }
  GridCol operator [](int x) {
    return cols[x];
  }
}
class GridCol {
  int x, w;
  List data;
  GridCol(this.data, this.x, this.w);
  int operator [](int y) {
    return data[y + x * w];
  }
  void operator []= (int y, int value) {
    data[y + x * w] = value;
  }
}
