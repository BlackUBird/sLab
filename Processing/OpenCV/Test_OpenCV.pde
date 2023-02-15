import gab.opencv.*;
import controlP5.*;

ControlP5 p5slider;
ControlP5 p5button;

OpenCV cv;
OpenCV cv_dilate;

PImage im;
PImage im_edge;
PImage im_out;  // 出力用

int Threshold_under = 100;  // 閾値下
int Threshold_upper = 200;  // 閾値上

int arrayVoteHough[][];

void setup() 
{
  // 画像の読み込み
  im = loadImage( "data/osc2022_8_24_0.png" );
  cv = new OpenCV( this , im );
  
  // 画面サイズの設定
  // ウィンドウサイズの変更を可能にする
  surface.setResizable( true );
  // サイズを設定
  surface.setSize( cv.width , cv.height );
  // 画像サイズを表示
  println( cv.width );
  println( cv.height );
  
  // 背景
  background( 0 , 255 , 0 );
  
  // スライダーの作成
  //p5slider = new ControlP5( this );
  //// 閾値下用
  //p5slider.addSlider( "Threshold_under" , 0 , 255 , 128 , 10 , 10 , 100 , 30 );
  //// 閾値上用
  //p5slider.addSlider( "Threshold_upper" , 0 , 255 , 128 , 10 , 50 , 100 , 30 );
    
}

void draw() 
{  
  // 画像を表示
  image( im , 0 , 0 );
  println( "im.height"+im.height );
  println( "im.width"+im.width );
  
  // 線を表示
  stroke( 255 , 0 , 0 );  // 赤色にする
  strokeWeight( 5 );  // 太くする
  line( 0 , cv.height/2 , cv.width , cv.height/2 );
  line( cv.width/2 , 0 , cv.width/2 , cv.height );
  
  // キャニー法による画像のエッジを検出
  cv.gray();
  cv.findCannyEdges( Threshold_under , Threshold_upper );
  
  // エッジ画像を取得
  im_edge = cv.getSnapshot();
  
  // Hough変換で直線を表示
  // 時間測定
  println( hour()+":"+minute()+":"+second() );
  myTransform_Hough( im_edge );
  println( hour()+":"+minute()+":"+second() );
  // 画像を取得
  im_out = im_edge;
  
  // 膨張用
  //cv_dilate = new OpenCV( this , im_edge );
  // 膨張処理をする
  //cv_dilate.gray();
  //cv_dilate.threshold(100);
  //cv_dilate.erode();  // 収縮
  //cv_dilate.dilate();  // 膨張
  //// 画像の取得
  //im_out = cv_dilate.getSnapshot();
  
  // 取得したエッジ画像を表示
//  image( im_out , 0 , 0 );
  
  // draw()のループを止める
  noLoop();
}

void myTransform_Hough( PImage image )
{
  // 角度θの分割数(0～πを分割)
  int splitAngle = 1024;
  // 距離の最大値
  int maxDistance = int( sqrt( pow(image.width,2)+pow(image.height,2) ) );
  
  // 投票データを格納する2次元配列
  int[] vote[];  // まずは1次元を用意
  vote = new int[ splitAngle ][];  // 2次元にするよ！
  // そして追加していく
  // 角度θの分割数だけループ
  for( int i = 0 ; i < splitAngle ; i++ )
  {
    // 次元を確定させる
    vote[i] = new int[ maxDistance*2+1 ];
  }
  // 0で埋める
  for( int i = 0 ; i < splitAngle ; i++ )
  {
    for( int j = 0 ; j < maxDistance*2+1 ; j++ )
    {
      vote[i][j] = 0;
    }
  }
  
  // 三角関数のテーブルを作成(時間短縮のため)
  float[] table_sin = new float[ splitAngle ];
  float[] table_cos = new float[ splitAngle ];
  for( int i = 0 ; i < splitAngle ; i++ )
  {
    table_sin[i] = sin( PI/180*i );
    table_cos[i] = cos( PI/180*i );
  }
  
  // 投票開始
  // x:画像の横方向の画素の軸
  for( int x = 0 ; x < image.width ; x++ )
  {
    // y:画像の縦方向の画素の軸
    for( int y = 0 ; y < image.height ; y++ )
    {
      // 推定角度について
      for( int angle = 0 ; angle < splitAngle ; angle++ )
      {
        // 推定角度を計算
        float theta = PI/180*angle;
        // 垂線の長さを計算
        int roh = int(x*cos(theta)+y*sin(theta));
        
        // 投票
        vote[angle][maxDistance+roh] += 1;
      }
    }
  }
  
  // 投票結果から直線を求める
  int lineNumMax = 5;  // 5本求まったら終了
  while( lineNumMax > 0 )
  {
    // 最高得票の位置を求める
    int roh_max=0 , angle_max=0;  // 位置を記憶
    // 現時点での得票数を記憶
    int vote_max = 0;
    for( int i = 0 ; i < splitAngle ; i++ )
    {
      for( int j = 0 ; j < maxDistance ; j++ )
      {
        // 現時点での最高得票数を更新
        if( vote[i][j] > vote_max )
        {
          angle_max = i;
          roh_max = j;
        }
      }
    }
    
//    println( vote[angle_max][roh_max] );
    
    // Hough逆変換を行い、直線を引く
    // xを動かしながらy座標を求める
    int y0 = int( roh_max/table_sin[angle_max]);  // 線を引くときの開始点
    println( "y0:"+y0 );
    for( int x = 1 ; x < image.width ; x++ )
    {
      // y座標を計算(逆変換)
      int y1 = 0;
      y1 = int( -(table_cos[angle_max]/table_sin[angle_max])*x+roh_max/table_sin[angle_max]);
//      y1 = int(-( cos(PI/180*angle_max) / sin(PI/180*angle_max))*x+roh_max/sin(PI/180*angle_max));
      // 画像の外の座標である場合
      //if( y1 < 0 || y1 >= image.height )
      //{
      //  continue;
      //}
      // それ以外の時は線を表示
      stroke( 255 , 0 , 0 );  // 赤色にする
      strokeWeight( 5 );  // 太くする
      line( 0 , y0 , x , y1 );
//      println( "y1"+y1 );
    }
    // yを動かしながらx座標を求める
    // xを動かしながらy座標を求める
    int x0 = int( roh_max/table_cos[angle_max]);  // 線を引くときの開始点
    println( "x0:"+x0 );
    for( int y = 1 ; y < image.height ; y++ )
    {
      // y座標を計算
      int x1 = 0;
      x1 = int( -(table_sin[angle_max]/table_cos[angle_max])*y+roh_max/table_cos[angle_max]);
//      x1 = int(-( sin(PI/180*angle_max) / cos(PI/180*angle_max))*y+roh_max/cos(PI/180*angle_max));
      // 画像の外の座標である場合
      //if( x1 < 0 || x1 >= image.width )
      //{
      //  continue;
      //}
      // それ以外の時は線を表示
      stroke( 255 , 0 , 0 );  // 赤色にする
      strokeWeight( 5 );  // 太くする
      line( x0 , 0 , x1 , y );
//      println( "x1"+x1 );
    }
    
    // 最高得票の位置とその近傍を削除する
    for( int i = -10 ; i < 10 ; i++ )
    {
      for( int j = -10 ; j < 10 ; j++ )
      {
        if( angle_max+i < 0 || roh_max+j < 0 || angle_max+i >= splitAngle || roh_max >= maxDistance )
        {
          continue;
        }
        vote[angle_max+i][roh_max+j] = 0;
      }
    }
    
    lineNumMax -= 1;
  }
}
