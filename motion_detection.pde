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
int threshold_BGSub = 80;
int threshold_ChangedPixels = 35000;

//画像ナンバー
int photonum = 0;

//日時
int y;
int m;
int d;

//--------------------------------------------

//事前の処理
//--------------------------------------------
void setup()
{
  //画面サイズ決定
  //size( 960, 540 );
  size( 960, 1080 );
  println( "width:" + width + ",height:" + height );

  //背景色を決定
  background( 127, 255, 255 );

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
  
  //日時保存
  y = year();
  m = month();
  d = day();
}
//--------------------------------------------

//メインの処理
//--------------------------------------------
void draw()
{
  //変更のあったピクセル数
  int changedpixels;
  //グレースケール（輝度）による背景差分
  changedpixels = BackgroundSubtractionByLuminance();
  
  //閾値以上だったら保存して背景画像を更新  
  if( changedpixels >= threshold_ChangedPixels && bgImageisAvailable == true && photonum < 255 )
  {
    //保存
    //一時的な画像を作成
    PImage img = createImage( width , height/2 , RGB );
    //保存したい領域を一時的な画像にコピー
    video.loadPixels();
    img.pixels = video.pixels;
    img.updatePixels();
    //保存
    img.save( "data/osc" + y + "_" + m + "_" + d + "_" + photonum + ".png" );
    
    //背景画像の更新
    bgImage = get( 0, 0, width, height );
    
    println( "data/osc" + y + m + d + "_" + photonum + ".png" );
    println( "changedpixels:" + changedpixels );
    photonum++;
  }
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
    //メディアンフィルタを適用
    //MedianFilter();
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
  } 
  else
  {
    //現在のフレームのピクセル情報を取得・変更可能にする
    video.loadPixels();

    //背景画像のピクセル情報を取得・変更可能にする
    bgImage.loadPixels();

    //すべてのピクセルの輝度の情報を取得する
    for ( int i = 0; i < video.pixels.length; i++ )
    {
      //現在のフレームのピクセルの輝度情報
      //重みあり
      //float nowLuminance =  0.299 * red( video.pixels[i] ) +
      //                      0.587 * green( video.pixels[i] ) +
      //                      0.114 * blue( video.pixels[i] );
      //重みなし
      float nowLuminance =  red( video.pixels[i] ) +
                            green( video.pixels[i] ) +
                            blue( video.pixels[i] );

      //背景画像のフレームのピクセルの輝度情報
      //重みあり
      //float bgLuminance =   0.299 * red( bgImage.pixels[i] ) +
      //                      0.587 * green( bgImage.pixels[i] ) +
      //                      0.114 * blue( bgImage.pixels[i] );
      //重みなし
      float bgLuminance =   red( bgImage.pixels[i] ) +
                            green( bgImage.pixels[i] ) +
                            blue( bgImage.pixels[i] );

      //輝度の差を取得
      float sub = abs( nowLuminance - bgLuminance );

      //輝度の差が閾値を超えていたら
      if ( int(sub) > threshold_BGSub )
      {
        //そのピクセルの色を緑色にする
        //video.pixels[i] = color( 0, 255, 0 );
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
  //背景画像が有効で背景画像が空であったら
  else if( bgImageisAvailable == true && bgImage == null )
  {
    //背景画像をセット
    bgImage = get( 0, 0, width, height );
  }

  //変更のあったピクセル数を返却
  return (ChangedPixelsNum);
}

//クイックソート
void Sort_Quick( float array[] , int start , int end )
{
  if( start >= end )
  {
    return;
  }

  int i,j;  //雑用
  int PlaceOfPivot;  //ピボットの位置を記憶
  float Pivot;  //ピボットの値を記憶

  PlaceOfPivot = (start + end) / 2;  //ピボットの位置をソート範囲の中間にする

  Pivot = array[PlaceOfPivot];  //

  //走査用の数値を設定
  i = start;
  j = end;

  //ソート
  while( i <= j )
  {
    //ピボットより小さい値が見つかるまで
    //データの始点から終点に向けて走査していく
    while( array[i] < Pivot )
    {
      i++;
    }
    //ピボットより大きい値が見つかるまで
    //データの終点から始点に向けて走査していく
    while( array[j] > Pivot )
    {
      j--;
    }
    //もし、上2つの走査線が交差していたら
    //入れ替え・走査線の移動を行う
    if( i <= j )
    {
      //入れ替え
      float tmp = array[i];
      array[i] = array[j];
      array[j] = tmp;

      //移動(両方1進める)
      i++;
      j--;
    }
  }

  Sort_Quick(array , start , j);  //データの始点側を再ソート
  Sort_Quick(array , i , end);  //データの終点側を再ソート
}

//配列から中央値を求め、返却
float GetMedian( float array[] , int len )
{
  //配列をソート
  Sort_Quick( array , 0 , len-1 );
  
  //中央のインデックス値を求める
  int m;
  if( len % 2 == 0 )
  {
    m = len / 2 - 1;
  }
  else
  {
    m = (len+1) / 2 - 1;
  }
  
  //返却
  return (array[m]);
}

//(i,j)成分の輝度を取得
float Video_GetLuminance( int i , int j )
{
  //輝度
  float  luminance =  red(video.pixels[i*width+j])+
                      green(video.pixels[i*width+j])+
                      blue(video.pixels[i*width+j]);
  
  //返却
  return (luminance);
}

//(i,j)成分の赤色成分を取得
float Video_GetRed( int i , int j )
{
  //輝度
  float  red =  red(video.pixels[i*width+j]);
  
  //返却
  return (red);
}

//(i,j)成分の緑色成分を取得
float Video_GetGreen( int i , int j )
{
  //輝度
  float  green =  green(video.pixels[i*width+j]);
  
  //返却
  return (green);
}

//(i,j)成分の青色成分を取得
float Video_GetBlue( int i , int j )
{
  //輝度
  float  blue =  blue(video.pixels[i*width+j]);
  
  //返却
  return (blue);
}

//(i,j)成分のアルファ値を取得
float Video_GetAlpha( int i , int j )
{
  //輝度
  float  alpha =  alpha(video.pixels[i*width+j]);
  
  //返却
  return (alpha);
}

//メディアンフィルタ
int MedianFilter()
{
  //縦方向にループ
  for( int i = 1 ; i < (height/2 - 1) ; i++  )
  {
    //横方向にループ
    for( int j = 1 ; j < (width - 1) ; j++ )
    {
      //3*3画素
      float pixels_alpha[] = 
      {
        Video_GetAlpha( i-1 , j-1 ) , Video_GetAlpha( i-1 ,  j  ) , Video_GetAlpha( i-1 , j-1 ) ,
        Video_GetAlpha(  i  , j-1 ) , Video_GetAlpha(  i  ,  j  ) , Video_GetAlpha(  i  , j-1 ) ,
        Video_GetAlpha( i+1 , j-1 ) , Video_GetAlpha( i+1 ,  j  ) , Video_GetAlpha( i+1 , j-1 )
      };
      float pixels_red[] = 
      {
        Video_GetRed( i-1 , j-1 ) , Video_GetRed( i-1 ,  j  ) , Video_GetRed( i-1 , j-1 ) ,
        Video_GetRed(  i  , j-1 ) , Video_GetRed(  i  ,  j  ) , Video_GetRed(  i  , j-1 ) ,
        Video_GetRed( i+1 , j-1 ) , Video_GetRed( i+1 ,  j  ) , Video_GetRed( i+1 , j-1 )
      };
      float pixels_green[] = 
      {
        Video_GetGreen( i-1 , j-1 ) , Video_GetGreen( i-1 ,  j  ) , Video_GetGreen( i-1 , j-1 ) ,
        Video_GetGreen(  i  , j-1 ) , Video_GetGreen(  i  ,  j  ) , Video_GetGreen(  i  , j-1 ) ,
        Video_GetGreen( i+1 , j-1 ) , Video_GetGreen( i+1 ,  j  ) , Video_GetGreen( i+1 , j-1 )
      };
      float pixels_blue[] = 
      {
        Video_GetBlue( i-1 , j-1 ) , Video_GetBlue( i-1 ,  j  ) , Video_GetBlue( i-1 , j-1 ) ,
        Video_GetBlue(  i  , j-1 ) , Video_GetBlue(  i  ,  j  ) , Video_GetBlue(  i  , j-1 ) ,
        Video_GetBlue( i+1 , j-1 ) , Video_GetBlue( i+1 ,  j  ) , Video_GetBlue( i+1 , j-1 )
      };
      
      //画素値を変更
      video.pixels[i*width+j] = color( GetMedian( pixels_red , 9 ) , 
                                GetMedian( pixels_green , 9 ) , 
                                GetMedian( pixels_blue , 9 ) ,
                                GetMedian( pixels_alpha , 9) );
    }
  }
  
  return (0);
}


//マウス操作があった時の処理
void mousePressed()
{
  //背景画像を有効/無効にする
  bgImageisAvailable = !bgImageisAvailable;
  println( "bgImageisAvailable:" + bgImageisAvailable );
}
