import gab.opencv.*;
import controlP5.*;

ControlP5 cp5;
OpenCV cv;
PImage im;
PImage im_edge;

int Threshold_under = 100;
int Threshold_upper = 200;


void setup() 
{
  // 画像の読み込み
  im = loadImage( "osc2022_8_10_2.png" );
  cv = new OpenCV( this , im );
  // 画像サイズを表示
  println( cv.width );
  println( cv.height );
  
  // 画面サイズの設定
  // ウィンドウサイズの変更を可能にする
  surface.setResizable( true );
  // サイズを設定
  surface.setSize( cv.width , cv.height );
//  size(cv.width, cv.height);
  
  // スライダーの作成
  cp5 = new ControlP5( this );
  cp5.addSlider( "Threshold_under" , 0 , 255 , 128 , 10 , 10 , 100 , 30 );
  cp5.addSlider( "Threshold_upper" , 0 , 255 , 128 , 10 , 50 , 100 , 30 );
  
}

void draw() 
{
  // キャニー法による画像のエッジを検出
  cv.gray();
  cv.findCannyEdges( Threshold_under , Threshold_upper );
  // エッジ画像を取得
  im_edge = cv.getSnapshot();
  // 取得したエッジ画像を表示
  image( im_edge , 0 , 0 );
}
