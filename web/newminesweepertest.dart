import 'dart:html';
import 'dart:math';

const EASY = const Difficulty(8);
const INTERMEDIATE = const Difficulty(11);
const HARD = const Difficulty(15);

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
  if(cell.isUncovered) return;//TODO: Don't return. check for chordability

  bool shifted = e.shiftKey;
  //ShiftClick
  if(shifted){
    if(cell.isFlagged){
      button.src = 'tileDefault.ico';
      button.style
        ..width = '30px'
        ..height = '30px';
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
      if(neighbors==0){
        clearAdjacentZeros(cell);
      }
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



void clearAdjacentZeros(GridCell cell){
  print('CZ $cell');
  cell.isUncovered = true;
  (gameGrid.rows[cell.row].cells[cell.column].lastChild as ImageButtonInputElement).src = 'tile0.ico';
  //check every valid nearby square. call clearAdjacentZeros on any 0s found
  var neighbors = logicGrid.getValidNeighbors(cell);
  for(int n=0;n<neighbors.length;n++){
    if(!neighbors[n].isUncovered && !neighbors[n].isMine && !neighbors[n].isFlagged){
      if(neighbors[n].adjacentCount==0) {
        clearAdjacentZeros(neighbors[n]);
      }
      else {
        clearAdjacentTiles(cell);
      }
    }
  }
}
void clearAdjacentTiles(GridCell cell){
  print('CT $cell');
  cell.isUncovered = true;
  (gameGrid.rows[cell.row].cells[cell.column].lastChild as ImageButtonInputElement).src = 'tile${cell.adjacentCount}.ico';
  var neighbors = logicGrid.getValidNeighbors(cell);
  for(int n=0;n<neighbors.length;n++){
    if(!neighbors[n].isUncovered && !neighbors[n].isMine && !neighbors[n].isFlagged){
      if(neighbors[n].adjacentCount==0) {
        clearAdjacentZeros(neighbors[n]);
      }
      else {
        neighbors[n].isUncovered = true;
        (gameGrid.rows[neighbors[n].row].cells[neighbors[n].column].lastChild as ImageButtonInputElement).src = 'tile${neighbors[n].adjacentCount}.ico';
      }
    }
  }
}






void loseGame(){
  print('lost');
  redraw();

  window.alert("You Lose!");
  gameover = true;
}

void winGame(){
  window.alert("You Win!");
  gameover = true;
}

bool isGameWon() => logicGrid.hasNoMoreSquares && bombsLeft == 0;

void redraw(){
  for(int r=0;r<logicGrid.rows;r++){
    for(int c=0;c<logicGrid.columns;c++) {
      GridCell cell = logicGrid[r][c];
      if (!cell.isUncovered) {
        if (cell.isMine && !cell.isFlagged)(gameGrid.rows[c].cells[r].lastChild as ImageButtonInputElement).src = 'tileBomb.ico';
        else if(!cell.isMine)(gameGrid.rows[c].cells[r].lastChild as ImageButtonInputElement).src = 'tile${cell.adjacentCount}.ico';
      }

      cell.isUncovered = true;
    }
  }
}

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
  int get bombs => ((value*value)*.42).floor() + (-3.1*value).floor()+6;
  int get size => value+1;
}