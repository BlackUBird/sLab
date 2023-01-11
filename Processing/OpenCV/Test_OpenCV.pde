import gab.opencv.*;
import controlP5.*;

ControlP5 p5slider;
ControlP5 p5button;

OpenCV cv;

PImage im;
PImage im_edge;
PImage im_Canny , im_Scharr , im_SobelX , im_SobelY;

int Threshold_under = 100;  // 閾値下
int Threshold_upper = 200;  // 閾値上


void setup() 
{
  // 画像の読み込み
  im = loadImage( "data/osc2022_8_24_0.png" );
  cv = new OpenCV( this , im );
  // 画像サイズを表示
  println( cv.width );
  println( cv.height );
  
  // キャニー法
  cv.findCannyEdges( Threshold_under , Threshold_upper );
  im_Canny = cv.getSnapshot();
  
  // Scharrフィルタ
  cv.loadImage( im );
  cv.findScharrEdges( OpenCV.HORIZONTAL );
  im_Scharr = cv.getSnapshot();
  
  // Sobelフィルタ(X方向)
  cv.loadImage( im );
  cv.findSobelEdges( 1 , 0 );
  im_SobelX = cv.getSnapshot();
  
  // Sobelフィルタ(Y方向)
  cv.loadImage( im );
  cv.findSobelEdges( 0 , 1 );
  im_SobelY = cv.getSnapshot();
  
  // 画面サイズの設定
  // ウィンドウサイズの変更を可能にする
  surface.setResizable( true );
  // サイズを設定
  surface.setSize( cv.width*2 , cv.height*2 );
//  size(cv.width, cv.height);

  
  
  //// スライダーの作成
  //p5slider = new ControlP5( this );
  //// 閾値下用
  //p5slider.addSlider( "Threshold_under" , 0 , 255 , 128 , 10 , 10 , 100 , 30 );
  //// 閾値上用
  //p5slider.addSlider( "Threshold_upper" , 0 , 255 , 128 , 10 , 50 , 100 , 30 );
  
  //// ボタンの作成
  //p5button = new ControlP5( this );
  //p5button.addButton( "next" )
  //        .setLabel( "NEXT" )
  //        .setPosition( cv.width - 50 , 10 )
  //        .setSize( 20 , 30 )
  //        .setColorActive( color(128) )
  //        .setColorBackground( color(255) )
  //        .setColorForeground( color(255) )
  //        .setColorCaptionLabel( color(0) );
  
}

void draw() 
{
   
  // 取得したエッジ画像を表示
  image( im_Canny , 0 , 0 );
  image( im_Scharr , cv.width , 0 );
  image( im_SobelX , 0 , cv.height );
  image( im_SobelY , cv.width , cv.height );
  
  println( Threshold_under );
  println( Threshold_upper );
}
