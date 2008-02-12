/*==========================================================================
 *
 *  Copyright (C) 2004 HELLO WORLD PROJECT. All Rights Reserved.
 *
 *  ○ゲームタイトル：AREA2048
 *  ○ジャンル      ：全方向スクロールシューティング
 *  ○プレイ人数    ：一人
 *  ○バージョン    ：1.01
 *  ○公開日付      ：2004/9/15
 *  ○更新日付      ：2008/2/12
 *
 ==========================================================================*/

・はじめに

  四方八方絶対包囲。全方向シューティング「AREA2048」。


・操作説明

  [TYPE-1]
  自機移動      ：カーソルキーorテンキー
  ショット      ：Zキー
  ワイドショット：Xキー

  [TYPE-2]
  自機移動      ：WASDキーorテンキー
  ショット      ：BACKSLAHSキー
  ワイドショット：右SHIFTキー

  [TYPE-3]
  自機移動      ：カーソルキーorテンキー
  ショット      ：左シフトキー
  ワイドショット：左CTRLキー

  [TYPE-4]
  自機移動      ：カーソルキーorテンキー
  ショット      ：スペースキー
  ワイドショット：左ALTキー

  [JOYPAD(TYPEに関係なし)]
  自機移動      ：ジョイパッドの十字キー
  ショット      ：ジョイパッドの一つ目のボタン
  ワイドショット：ジョイパッドの二つ目のボタン


＜ルール＞

  各シーン内にいる敵を全滅させてください。
  敵弾や敵本体に触れると、死にます。
  敵を全滅させると、次のシーンに進みます。
  １０シーンクリアすると、次のエリアに進みます。
  全５エリアクリアすると、コンプリートです。
  また、制限時間内に全エリアクリアできなければ、残機数に関係なくゲームオーバ
  ーになります。


＜最後に＞

・謝辞

  AREA2048 は D言語 で書かれています。(Ver 1.026)
    D Programming Language
    http://www.digitalmars.com/d/index.html
    日本語訳
    http://www.kmonos.net/alang/d/

  「ABA Games」のお世話になっております。
  弾の制御に BulletML を利用しています。
  弾の定義に Bulletnote を利用しています。
  ソースの一部を PARSEC47 から流用しています。
    ABA Games
    http://www.asahi-net.or.jp/~cs8k-cyu/
    BulletML
    http://www.asahi-net.or.jp/~cs8k-cyu/bulletml/index.html
    Bulletnote
    http://www.asahi-net.or.jp/~cs8k-cyu/bulletml/bulletnote/index.html
    PARSEC47
    http://www.asahi-net.or.jp/~cs8k-cyu/windows/p47.html

  「Entangled Space」のお世話になっております。
  BulletML ファイルのパースに libBulletML を利用しています。
  D - porting の SDL_mixer ヘッダファイルを利用しています。
    Entangled Space
    http://user.ecc.u-tokyo.ac.jp/~s31552/wp/
    libBulletML
    http://user.ecc.u-tokyo.ac.jp/~s31552/wp/libbulletml/
    D - porting
    http://user.ecc.u-tokyo.ac.jp/~s31552/wp/d/porting.html

  画面の出力には Simple DirectMedia Layer を利用しています。
    Simple DirectMedia Layer
    http://www.libsdl.org/

  BGM と SE の出力に SDL_mixer と Ogg Vorbis CODEC を利用しています。
    SDL_mixer 1.2
    http://www.libsdl.org/projects/SDL_mixer/
    Vorbis.com
    http://www.vorbis.com/

  DedicateDのD言語用 OpenGL, SDL ヘッダファイルを利用しています。
    DedicateD
    http://int19h.tamb.ru/files.html


＜連絡＞

・御意見、ご感想などはこちらまで。
    ads00721@nifty.com


＜WEBページ＞

    http://homepage2.nifty.com/isshiki/prog_win_d.html


＜更新履歴＞

2008/02/12  Ver1.03  キーアサインを2タイプ追加。

2005/01/17  Ver1.02  ボイスを変更。
                     dmd ver0.110 でコンパイルを通るようにした。
                     当たり判定の無い状態の敵にロックしないようにした。
                     デモプレイをつけた。なんとなく。

2005/01/09  Ver1.01  Andrew Walker 氏よりボイスデータの提供。

2004/09/15  Ver1.00  公開。


＜ライセンス＞

AREA2048はBSDスタイルライセンスのもと配布されます。

ライセンス
-------

Copyright 2004 HELLO WORLD PROJECT (Jumpei Isshiki). All rights reserved. 

 1.ソースコード形式であれバイナリ形式であれ、変更の有無に 関わらず、以下の条件を
   満たす限りにおいて、再配布および使用を許可します。

 2.ソースコード形式で再配布する場合、上記著作権表示、 本条件書および下記責任限定
   規定を必ず含めてください。 

バイナリ形式で再配布する場合、上記著作権表示、 本条件書および下記責任限定規定を、
配布物とともに提供される文書 および/または 他の資料に必ず含めてください。 
本ソフトウェアは HELLO WORLD PROJECT によって、”現状のまま” 提供されるものとし
ます。 本ソフトウェアについては、明示黙示を問わず、 商用品として通常そなえるべき
品質をそなえているとの保証も、 特定の目的に適合するとの保証を含め、何の保証もな
されません。 事由のいかんを問わず、 損害発生の原因いかんを問わず、且つ、 責任の
根拠が契約であるか厳格責任であるか (過失その他) 不法行為であるかを問わず、
 HELLO WORLD PROJECT も寄与者も、 仮にそのような損害が発生する可能性を知らされて
いたとしても、 本ソフトウェアの使用から発生した直接損害、間接損害、偶発的な損害、
 特別損害、懲罰的損害または結果損害のいずれに対しても (代替品または サービスの提
供; 使用機会、データまたは利益の損失の補償; または、業務の中断に対する補償を含め) 
責任をいっさい負いません。
