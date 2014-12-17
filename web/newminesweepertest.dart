import 'dart:html';
import 'dart:math';

const EASY = const Difficulty(6);
const INTERMEDIATE = const Difficulty(9);
const HARD = const Difficulty(14);

TableElement gameGrid;
Element bombsLeftLabel;

var gameover = false;
var difficulty = EASY;
int bombsLeft = 6;
int gamenum = 0;
Grid logicGrid;

void main() {
  var header = new DivElement();
  var newGameButton = new ButtonElement()..text='New Game'
                                         ..onClick.listen(handleNewGameClick);
  bombsLeftLabel = new SpanElement();
  header.append(newGameButton);
  header.appendText("Bombs Remaining:");
  header.append(bombsLeftLabel);
  document.body.append(header);
  
  var difficultyBar = new DivElement();
  var easyButton = new ButtonElement()..text='EASY'
                                      ..onClick.listen(handleDifficultyClick(EASY));
  var intermediateButton = new ButtonElement()..text='INTERMEDIATE'
                                              ..onClick.listen(handleDifficultyClick(INTERMEDIATE));
  var hardButton = new ButtonElement()..text='HARD'
                                      ..onClick.listen(handleDifficultyClick(HARD));
  difficultyBar..append(easyButton)
               ..append(intermediateButton)
               ..append(hardButton);
  document.body.append(difficultyBar);
  

  gameGrid = new TableElement();
  document.body.append(gameGrid);

  startNewGame();
}

void startNewGame(){
  gameover = false;
  bombsLeft = difficulty.bombs;
  logicGrid = new Grid(difficulty.size, difficulty.size);
  bombsLeftLabel.text = bombsLeft.toString();
  gameGrid.children.clear();
  for(int x=0;x<logicGrid.rows;x++){
    gameGrid.addRow();
    for(int y=0;y<logicGrid.columns;y++){
      gameGrid.rows[x].addCell();
      gameGrid.rows[x].cells[y].append(new ImageButtonInputElement()
                                            ..src = 'tileDefault.ico'
                                            ..onClick.listen(handleCellClick)
                                            ..style.width = '50px'
                                            ..style.height = '50px');
    }
  }
  gamenum+= 1;
}

handleNewGameClick(_)=> startNewGame();

void handleCellClick(MouseEvent e){
  if(gameover) return;

  ImageButtonInputElement button = e.target;
  int clickedColumn = (button.parent as TableCellElement).cellIndex;
  int clickedRow = (button.parent.parent as TableRowElement).rowIndex;
  //print('$clickedRow $clickedColumn');
  var cell = logicGrid[clickedColumn][clickedRow];
  //print('${cell.row} ${cell.column} ${cell.adjacentCount}');
  if(cell.isUncovered) return;

  bool shifted = e.shiftKey;
  //ShiftClick
  if(shifted){
    if(cell.isFlagged){
      button.src = 'tileDefault.ico';
      button.style
        ..width = '50px'
        ..height = '50px';
      cell.isFlagged = false;
      bombsLeft += 1;
    } else {
      cell.isFlagged = true;
      button.src = 'tileFlagged.ico';
      bombsLeft -= 1;
    }
  } else {//Normal Click
    if(cell.isMine){
      button.src = 'tileBomb.ico';
      loseGame();
    } else {
      int neighbors = cell.adjacentCount;
      cell.isUncovered = true;
      button.src = 'tile${neighbors}.ico';
    }
  }
  bombsLeftLabel.text = bombsLeft.toString();

  //Victory Handler
  if(isGameWon()){
    winGame();
  }
}

handleDifficultyClick(Difficulty diff){
  return (_)=> difficulty = diff;
}


/*
void clearAdjacentZeros(GridCell cell){
  cell.isUncovered = true;
  (gameGrid.rows[cell.row].cells[cell.column] as ImageButtonInputElement).src = 'tile0.ico';
  //check every valid nearby square. call clearAdjacentZeros on any 0s found
  var neighbors = logicGrid.getValidNeighbors(cell);
  for(int n=0;n<neighbors.length;n++){
    
  }
  
  
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
void clearAdjacentTiles(GridCell cell){
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
}

*/




void loseGame(){
  window.alert("You Lose!");
  gameover = true;
}

void winGame(){
  window.alert("You Win!");
  gameover = true;
}

bool isGameWon() => logicGrid.hasNoMoreSquares && bombsLeft == 0;

class Grid {
  final int rows;
  final int columns;
  List<GridCol> _cols;
  Grid(this.rows, this.columns) {
    //print('Gridstart r$rows c$columns');
    _cols = new List.generate(columns, (ndx)=> new GridCol(ndx+1));
    
    _randomizeMineLocations();

    for(int j=0;j<rows;j++){
      for(int k=0;k<columns;k++){
        if(!_cols[j][k].isMine){
          _cols[j][k].adjacentCount = _countAdjacentBombs(_cols[j][k]);
        }
      }
    }
    print(this);
  }
  
  GridCol operator [](int x) => _cols[x];

  bool get hasNoMoreSquares {
    for(int c = 0; c < columns; c++){
      for(int r = 0; r < rows; r++){
        var cell = _cols[c][r];
        if(cell.isNotActivated){
          return false;
        }
      }
    }
    return true;
  }
  List<GridCell> getValidNeighbors(GridCell cell){
    int c=cell.row;
    int r=cell.column;
    //print('r$r c$c');
    var neighbors = new List<GridCell>();
    if(r>0){
      if(c>0){
        neighbors.add(_cols[r-1][c-1]);
      }
      neighbors.add(_cols[r-1][c]);
    }
    if(c>0){
      neighbors.add(_cols[r][c-1]);
    }
    if(r<(rows-1)){
      neighbors.add(_cols[r+1][c]);
      if(c<(columns-1)){
        neighbors.add(_cols[r+1][c+1]);
      }
    }
    if(c<(columns-1)){
      neighbors.add(_cols[r][c+1]);
    }
    if(r>0&&c<(columns-1))neighbors.add(_cols[r-1][c+1]);
    if(r<(columns-1)&&c>0)neighbors.add(_cols[r+1][c-1]);
    //print('$cell n${neighbors.length}');
    return neighbors;
  }
 
  _randomizeMineLocations(){
    var rand = new Random();
    for(int i=0;i<bombsLeft;i++){
      var r;
      do{
        r = rand.nextInt(rows*columns);
        //print('bomb@ $r');
        
      }while((_cols[r % columns][r ~/ columns]).isMine);
      (_cols[r % columns][r ~/ columns]).isMine = true;
    }
  }

  _countAdjacentBombs(cell){
    List<GridCell> neighbs = getValidNeighbors(cell);
    int count = 0;
    for(int n=0;n< neighbs.length;n++){
      if(neighbs[n].isMine)count++;
    }
    return count;
  }
  String toString(){
    String gridString='';
    for(int r=0;r<rows;r++){
      String rowString='';
      for(int c=0;c<columns;c++){
        if(_cols[r][c].isMine)rowString+='* ';
        else
        rowString += _cols[r][c].adjacentCount.toString() + ' ';
      }
      gridString += rowString + '\n';
    }
    return gridString;
  }
}

class GridCol {
  List<GridCell> data;

  GridCol(int columnIndex){
      data = new List.generate(difficulty.size, (ndx)=> new GridCell(ndx,columnIndex-1));
      //print(data);
  }
  GridCell operator [](int y){ 
    //TODO: reset this to an inline function
    //print('returning cell ${data[y]}');
    return data[y];
    }
  operator []= (int y, GridCell value) => data[y] = value;
}

class GridCell {
  bool isMine = false;
  bool isUncovered = false;
  bool isFlagged = false;
  int row=0;
  int column=0;
  int adjacentCount = 0;
  
  GridCell(this.row,this.column){
    
  }
  String toString()=>'r$row c$column aC$adjacentCount';
 
  bool get isNotActivated => (!isUncovered && !isFlagged);
}

class Difficulty {
  final int value;
  const Difficulty(this.value);
  ///This is the bomb/difficulty equation! ///
  int get bombs => (value*value)~/7 + (value);
  int get size => value+1;
}