import processing.video.*;

//グローバル変数
//--------------------------------------------
//カメラからの情報を扱うためのインスタンス
Capture video;

//フレームレート
float fps = 60;

//背景画像(BackGround)
PImage bgImage;
//背景画像が有効かどうか
boolean bgImageisAvailable = false;
//閾値
int threshold_BGSub = 30;

//--------------------------------------------

//事前の処理
//--------------------------------------------
void setup()
{
  //画面サイズ決定
  //size( 960, 540 );
  size( 960, 1080 );

  //背景色を決定
  background( 0, 255, 255 );

  //フレームレートを決定
  frameRate( fps );

  //カメラをセットアップ
  //利用可能なカメラの名前を取得
  String[] cameras = Capture.list();
  //見つかるまでループする
  while ( cameras.length == 0 )
  {
    println( "Camera is not found." );
    cameras = Capture.list();
  }

  //利用可能なカメラの名前を表示
  for ( int i = 0; i < cameras.length; i++ )
  {
    println( "[" + i + "]:" + cameras[i] );
  }
  //カメラを扱うインスタンスを生成(カメラは0番を使用)
  //video = new Capture( this, width, height, cameras[0] );
  video = new Capture( this, width, height/2, cameras[0] );
  //利用開始
  video.start();
}
//--------------------------------------------

//メインの処理
//--------------------------------------------
void draw()
{
  //グレースケール（輝度）による背景差分
  BackgroundSubtractionByLuminance();
}
//--------------------------------------------


//その他処理 （関数） 
//--------------------------------------------
//グレースケール（輝度）による背景差分
int BackgroundSubtractionByLuminance()
{
  //変更のあったピクセル数
  int ChangedPixelsNum = 0;
  
  //もしカメラから新規フレームを読み込み可能な状態なら
  if ( video.available() == true )
  {
    //読み込みを行う
    video.read();
  }
  else
  {
    //失敗
    return (-1);
  }

  //もし背景画像が設定されていなかったら
  if ( bgImage == null )
  {
    //現在のフレームを表示
    image( video, 0, 0 );
  } else
  {
    //現在のフレームのピクセル情報を取得・変更可能にする
    video.loadPixels();

    //背景画像のピクセル情報を取得・変更可能にする
    bgImage.loadPixels();

    //すべてのピクセルの輝度の情報を取得する
    for ( int i = 0; i < video.pixels.length; i++ )
    {
      //現在のフレームのピクセルの輝度情報
      float nowLuminance =  0.299 * red( video.pixels[i] ) +
                            0.587 * green( video.pixels[i] ) +
                            0.114 * blue( video.pixels[i] );

      //背景画像のフレームのピクセルの輝度情報
      float bgLuminance =   0.299 * red( bgImage.pixels[i] ) +
                            0.587 * green( bgImage.pixels[i] ) +
                            0.114 * blue( bgImage.pixels[i] );

      //輝度の差を取得
      float sub = abs( nowLuminance - bgLuminance );

      //輝度の差が閾値を超えていたら
      if ( int(sub) > threshold_BGSub )
      {
        //そのピクセルの色を緑色にする
        video.pixels[i] = color( 0, 255, 0 );
        //数を更新
        ChangedPixelsNum++;
      }
    }

    //ピクセルへの変更を適用
    video.updatePixels();

    //表示
    image( video, 0, 0 );
    image( bgImage , 0 , height/2 );
  }

  //背景画像が無効であったら
  if ( bgImageisAvailable == false )
  {
    //背景画像を空にする
    bgImage = null;
  }
  else if( bgImageisAvailable == true && bgImage == null )
  {
    //背景画像を更新
    bgImage = get( 0, 0, width, height );
  }

  //変更のあったピクセル数を返却
  return (ChangedPixelsNum);
}

//マウス操作があった時の処理
void mousePressed()
{
  //背景画像を有効/無効にする
  bgImageisAvailable = !bgImageisAvailable;
  println( "bgImageisAvailable:" + bgImageisAvailable );
}
