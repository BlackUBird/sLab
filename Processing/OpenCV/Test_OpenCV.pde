import gab.opencv.*;
import controlP5.*;

// OpenCV用
OpenCV cv;

// 画像
PImage im;
PImage im_edge;
PImage im_out;  // 出力用

// ウィンドウサイズ
int WINDOW_SIZE_X;
int WINDOW_SIZE_Y;

// Canny法用
// 閾値
int CANNY_THRESHOLD_UNDER = 530;
int CANNY_THRESHOLD_UPPER = 1000;


void setup() 
{
  // 画像の読み込み
  im = loadImage( "data/osc2022_8_24_0.png" );
//  im = loadImage( "data/sample.png" );
//  im = loadImage( "data/kosen.jpg" );
//  im = loadImage( "data/test1.png" );
  cv = new OpenCV( this , im );
  
  // 画面サイズの設定
  WINDOW_SIZE_X = cv.width;
  WINDOW_SIZE_Y = cv.height;
  // ウィンドウサイズの変更を可能にする
  surface.setResizable( true );
  // サイズを設定
  surface.setSize( WINDOW_SIZE_X , WINDOW_SIZE_Y );
  // 画像サイズを表示
  println( WINDOW_SIZE_X );
  println( WINDOW_SIZE_Y );
  
  // 背景
  background( 0 , 255 , 0 ); 
}

void draw() 
{  
  // 画像を表示
  image( im , 0 , 0 );
  println( "im.height"+im.height );
  println( "im.width"+im.width );
  
  //// 線を表示
  //stroke( 255 , 0 , 0 );  // 赤色にする
  //strokeWeight( 5 );  // 太くする
  //line( 0 , cv.height/2 , cv.width , cv.height/2 );
  //line( cv.width/2 , 0 , cv.width/2 , cv.height );
  
  // キャニー法による画像のエッジを検出
  cv.gray();
  cv.findCannyEdges( CANNY_THRESHOLD_UNDER , CANNY_THRESHOLD_UPPER );
  
  // エッジ画像を取得
  im_edge = cv.getSnapshot();
  // 表示
//  image( im_edge , 0 , WINDOW_SIZE_Y/2 );
  
  // Hough変換で直線を表示
  
  // 時間測定
  println( hour()+":"+minute()+":"+second() );
  myTransform_Hough( im_edge );
  println( hour()+":"+minute()+":"+second() );
  // 画像を取得
  im_out = im_edge;
  
  // draw()のループを止める
  noLoop();
}

void myTransform_Hough( PImage image )
{
  // 検知できる直線の本数
  int LINE_MAX = 18;
  // 角度θの分割数(0～πを分割)
  int THETA_SPLIT_MAX = 1024;
  // 距離(垂線の長さ)の最大値
  int RHO_LENGTH_MAX = int( sqrt( pow(image.width,2)+pow(image.height,2) ) );
  // 角度θの配列を作成
  // πをTHETA_SPLIT_MAX分割した値を生成
  float PI_SPLIT = PI / THETA_SPLIT_MAX;
  // 三角関数の配列を作成(時間短縮のため)
  float[] TABLE_SIN = new float[ THETA_SPLIT_MAX ];
  float[] TABLE_COS = new float[ THETA_SPLIT_MAX ];
  for( int i = 0 ; i < THETA_SPLIT_MAX ; i++ )
  {
    TABLE_SIN[i] = sin( PI_SPLIT*i );
    TABLE_COS[i] = cos( PI_SPLIT*i );
//    println( "("+TABLE_COS[i]+","+TABLE_SIN[i]+")" );
  }
  
  // 画像の色情報を配列pixelsとして読み込む
  image.loadPixels();
//  println( "("+red(image.pixels[0])+","+green(image.pixels[0])+","+blue(image.pixels[0])+")" );
  
  
  // 投票データを格納する2次元配列
  int[][] vote;
  // 垂線の長さrhoはマイナスになる場合があるが、
  // 添え字にマイナスは使えないため、マイナスになる分加算する(2倍する)
  vote = new int[ RHO_LENGTH_MAX*2 ][ THETA_SPLIT_MAX ];
  // 0で埋める
  for( int i = 0 ; i < RHO_LENGTH_MAX*2 ; i++ )
  {
    for( int j = 0 ; j < THETA_SPLIT_MAX ; j++ )
    {
      vote[i][j] = 0;
    }
  }
  
  
  // 投票をする
  // 画像横方向(x軸方向)
  for( int x = 0 ; x < image.width ; x++ )
  {
    // 画像縦方向(y軸方向)
    for( int y = 0 ; y < image.height ; y++ )
    {
      // 対応する画素が黒の場合
      if( red(image.pixels[x+y*image.width]) == 0.0 && green(image.pixels[x+y*image.width]) == 0.0 && blue(image.pixels[x+y*image.width]) == 0.0 )
      {
//        print( "("+red(image.pixels[x+y*image.width])+","+green(image.pixels[x+y*image.width])+","+blue(image.pixels[x+y*image.width])+")" );
        continue;  // 処理をしない
      }
      // 対応する画素が白だった場合
      else
      {
//        print( "("+red(image.pixels[x+y*image.width])+","+green(image.pixels[x+y*image.width])+","+blue(image.pixels[x+y*image.width])+")" );
//        println( "("+red(image.pixels[x+y*image.width])+","+green(image.pixels[x+y*image.width])+","+blue(image.pixels[x+y*image.width])+")" );
//        println( image.get( x , y )+","+color( 0 , 0 , 0 ) );
        // 対応する点を通る直線に向かって原点から下した垂線とX軸とのなす角theta
        // を変化させて、垂線の長さrhoを求める
        for( int theta = 0 ; theta < THETA_SPLIT_MAX ; theta++ )
        {
          // 垂線の長さrhoを求める
          int rho;
          rho = int( x*TABLE_COS[ theta ] + y*TABLE_SIN[ theta ] );
          
          // 投票
          vote[ rho+RHO_LENGTH_MAX ][ theta ] += 1;
        }
      }
    }
  }  
  
  // 投票結果から直線を求める
  int count = 0;  // 検知できた直線の本数
  boolean flag_end = false;  // 終了用フラグ
  int condition_end = 100;  // 最高得票数が100未満になったら終了
  while( count < LINE_MAX && flag_end == false )
  {
    // 最高得票の位置を求める
    int theta_max;
    theta_max = 0;
    int rho_max;
    rho_max = 0;
    // 現時点での最高得票数
    int vote_max;
    vote_max = 0;
    for( int rho = 0 ; rho < RHO_LENGTH_MAX*2 ; rho++ )
    {
      for( int theta = 0 ; theta < THETA_SPLIT_MAX ; theta++ )
      {
        // 投票結果において現時点での最高得票数を超えていた場合
        if( vote[ rho ][ theta ] > vote_max )
        {
          rho_max = rho;
          theta_max = theta;
          vote_max = vote[ rho ][ theta ];
        }
      }
    }
    // 最高得票数が100未満の場合
    if( vote[ rho_max ][ theta_max ] < condition_end )
    {
      flag_end = true;
    }
    
    // 表示
    println( count+":(theta_max,rho_max)="+"("+theta_max+","+rho_max+")="+vote[ rho_max ][ theta_max ] );
    
    // 取得したrho_maxとtheta_maxを用いて、
    // Hough逆変換により直線を求め、引く
    // 直線を引くときの開始点を格納する変数
    int x0 = -1;  // 格納されていない場合はマイナスの値を保持
    int y0 = -1;  // 格納されていない場合はマイナスの値を保持
    // x座標を変化させてy座標を求める方法
    // 分母が0になる場合
    if( TABLE_COS[ theta_max ] == 0.0 || TABLE_SIN[ theta_max ] == 0.0 )
    {
      ;  // 処理しない(continueにすると∞になります。気を付けて)
    }
    // 分母が0にならない場合
    else
    {
      // x座標を変化させてy座標を求める方法
      for( int x = 0 ; x < image.width ; x++ )
      {
        // y座標を計算する
        int y;
//        y = int( (rho_max-RHO_LENGTH_MAX)/TABLE_COS[ theta_max ] - x*TABLE_COS[ theta_max ]/TABLE_SIN[ theta_max ] );
        y = int( (rho_max-RHO_LENGTH_MAX)/TABLE_SIN[ theta_max ] - x*TABLE_COS[ theta_max ]/TABLE_SIN[ theta_max ] );
  //      println( "y="+y );
        // 求めたy座標が画像の外に出ていた場合
        if( y < 0 || y >= image.height )
        {
          continue;  // 処理をしない
        }
        // 求めたy座標が画像の外に出ていなかった場合
        else
        {
          // 直線の開始点がまだ格納されていない場合
          if( y0 < 0 )
          {
            y0 = y;  // 格納する
            x0 = x;  // x座標も同タイミングで格納する
            point( x0 , y0 );
//            println( "x:("+x0+","+y0+")" );
          }
          // 直線の開始点がまだ格納されている場合
          else
          {
            // 表示する直線の設定
            stroke( 0 , 255 ,255 );
            strokeWeight( 5 );
            // 直線を表示する
            line( x0 , y0 , x , y );
//            point( x , y );
          }
        }
      }
    }
    // y座標を変化させてx座標を求める方法
    // 直線の開始点に格納されているものを消去
    x0 = -1;
    y0 = -1;
    // 分母が0になる場合
    if( TABLE_COS[ theta_max ] == 0.0 || TABLE_SIN[ theta_max ] == 0.0 )
    {
      ;  // 処理しない(continueにすると∞になります。気を付けて)
    }
    // 分母が0にならない場合
    else
    {
      // y座標を変化させてx座標を求める方法
      for( int y = 0 ; y < image.height ; y++ )
      {
        // x座標を計算する
        int x;
//        x = int( (rho_max-RHO_LENGTH_MAX)/TABLE_SIN[ theta_max ] - y*TABLE_SIN[ theta_max ]/TABLE_COS[ theta_max ] );
        x = int( (rho_max-RHO_LENGTH_MAX)/TABLE_COS[ theta_max ] - y*TABLE_SIN[ theta_max ]/TABLE_COS[ theta_max ] );
  //      println( "x="+x );
        // 求めたx座標が画像の外に出ていた場合
        if( x < 0 || x >= image.width )
        {
          continue;  // 処理をしない
        }
        // 求めたy座標が画像の外に出ていなかった場合
        else
        {
          // 直線の開始点がまだ格納されていない場合
          if( x0 < 0 )
          {
            x0 = x;  // 格納する
            y0 = y;  // y座標も同タイミングで格納する
            point( x0 , y0 );
//            println( "y:("+x0+","+y0+")" );
          }
          // 直線の開始点がまだ格納されている場合
          else
          {
            // 表示する直線の設定
            stroke( 0 , 0 ,255 );
            strokeWeight( 5 );
            // 直線を表示する
            line( x0 , y0 , x , y );
//            point( x , y );
          }
        }
      }
    }
    
    
    // 最高得票数の位置とその近傍の得票数を0にする
    for( int rho = -30 ; rho < 30 ; rho++ )
    {
      for( int theta = -10 ; theta < 10 ; theta++ )
      {
        // 投票結果における位置
        int pos_rho = rho_max + rho;
        int pos_theta = theta_max + theta;
        // 位置が投票結果用配列の外側に来た場合
        if(  pos_rho < 0 || pos_theta < 0 || pos_rho >= RHO_LENGTH_MAX*2 || pos_theta >= THETA_SPLIT_MAX )
        {
          ;  // 処理しない
        }
        // 位置が投票結果用配列の内側に来た場合
        else
        {
          vote[ pos_rho ][ pos_theta ] = 0;  // 得票数を0にする
        }
      }
    }
    
    // 検知した直線の本数を+1する
    count++;
  }
  
  
}
