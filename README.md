﻿# zenexpand-minor-mode

### ■zenexpand-minor-mode.l とは？
これは、xyzzy の拡張プラグインのひとつです。xyzzy をご存じない方は こちらをご覧ください [xyzzyサイト](http://xyzzy-022.github.io/)  
	Emmet(旧 Zen-Coding) の、HTMLをCSS風の省略記法で書く機能(expand-abbreviation)を実装したものです。例えば、
```
	ul>li#arg$$$*3.small.nav
```
というようなことを書けば、キー一発で
```
    <ul>
      <li id="arg001" class="small nav"></li>
      <li id="arg002" class="small nav"></li>
      <li id="arg003" class="small nav"></li>
    </ul>
```
のように展開してくれる機能です。
minor-modeですので、html+-mode と一緒に使うと楽できると思います。
(また、snippet.lと一緒に使うことでカーソルジャンプもできます。)

Zen-CodingのSyntaxは
* [emmet syntax](docs.emmet.io/abbreviations/syntax/)
* [emmet cheat](docs.emmet.io/cheat-sheet/)  
をご覧ください。

### ■ちょっとした特長
再帰的に略称を展開します。(そのせいでちょっと遅いです)

### ■動作環境
xyzzy-0.2.2.245/ 0.2.2.252 での実行を確認しました。

### ■インストール
1. zenexpand-minor-mode.l を site-lisp に置いてください。
2. .xyzzy / sitelinit.l に次のように書いてください。
```
		(require "zenexpand-minor-mode")
```
もしくは
```
		(export 'ed::zenexpand-minor-mode "ed")
		(autoload 'zenexpand-minor-mode "zenexpand-minor-mode" t)
```
### ■動かし方
"M-x zenexpand-minor-mode" とするか、  
html+-mode のhookなどに
```
	(add-hook '*html+-mode-hook*
	          #'(lambda ()
	              ...blah-blah-blah...
	              (ed::zenexpand-minor-mode)
	              ))
```
などと書いてください。

### ■動かし方(2) カーソルジャンプ
snippet.l を使うことで、展開時に、カーソルをジャンプすることができるようになります。[zen-snippet-expand]  
.xyzzy / siteinit.l などで、
```
(require "snippet")
```
と読み込んだ上で、
```
(define-key ed::*zenexpand-minor-mode-map* '#\M-e 'ed::zen-snippet-expand) ;;※1
```
としてください。

[ご注意][autoload された方へ] hookを作ってないので、
   html+-mode-hook など、メジャーモードのhookに上記※1を付け足してください。

### ■使い方
任意の場所で
```
{<!DOCTYPE:html>}>html[lang="ja"]>(head>utf8+title+jq)+body>div#content>ul>li*3^(div#a>(ul>li#item01$$*4)+(ol>li#item02$$@-*5))+(div#b)+ta#aa[cols="20"]{this is a sample. }*3
```
などと書いて、カーソルを省略記法の最後のところにある状態で "M-e" を押下すると 展開されます。

### ■って冗談？
では行頭で
```
!
```
とだけ打って "M-e" を押下しましょう。そのあと WoW! と叫ぶと展開されます。

### ■いずれにせよ こんな呪文覚えるの無理。。。
って方のために簡単にご説明。基本的には、

   記号       |説明
--------------|-----------------
	">"   |階層を降りる。
	"+"   |同じ階層に継ぎ足す。
	"^"   |１つ上の階層に
	"#"   |idを入れる。
	"."   |クラスを指定
	"*N"  |(N:integer) 繰返し
	"$"   |１から数字をインクリメントして挿入
	"$@-" |デクリメント
	[注意]スペース入れると展開できません。

詳しくは

   記号       |説明
--------------|-----------------
"(" ")"       | グルーピング
"{" "}"       | 内容記載
"[" "]"       | id/class 以外の属性指定(カスタム属性)
$$$           |  "$"を並べれば zero-fill

以上。あとは HTMLの通常のタグ(またはその省略形)を間にはさめばOK。  
5分で慣れます。これホント。  
詳しくは 下記cheat sheetご参照あれ。  
[refer] http://docs.emmet.io/cheat-sheet/

### ■問題点
1. 2014/03段階でのEmmet仕様と合わせています。
2. 未実装機能
  * "[～]" のカスタム属性で、ダブルクォーテーションの補填を行う仕様
  * 属性の textmate 風の デフォルト値指定
3. おかしいところ
  * "ul+" "ol+" など "+"のついた略語の解釈が多分間違ってます。(仕様の記載通りなのだけど)
    "ul+#$$*3" などは意図した動きだと思いますが、"ul+li" などは完全におかしい。
    "ul++li" とか "ul+^ol" とかで代用できますが、もう訳が分からない。
    普段は "ul>li#$$*3"  というような書き方をしてください。ご面倒かけます。
4. これは純正品ではありません。
5. いろいろ拡張できますが、拡張設定しやすいように作る方法が分からない
   ので次に使うあなたが拡張してくださいね。

### ■設定
展開するとき、入力したzen-codeを コメントとして残すことができます。
.xyzzy/siteinit.lに
```
(setq ed::*zenexpand-silent* nil)
```
と入れていただければ、入力をコメント行にして次の行に展開します。

### ■由来
OTCHYさんによる perlによるZen-Coding実装 [SSSCoding.pm](http://www.otchy.net/20100225/zen-coding-for-perl/)
をベースに Lispで翻訳するところからはじめました。
lexer/parse/expandがきれいにまとまっていて非常に読みやすかったです。

	# Copyright (c) 2010 Otchy  
	# This source file is subject to the MIT license.  
	# http://www.otchy.net

### ■変更履歴
	[2014/03/31]
		・zen-codeに日本語など多バイト文字があるとindentがずれる問題に対処。
		  length と count-column の使い方を学ぶ。
		・select は inline要素だけども HTMLコーディング上は Listと同じような書き方が想定されるので、
		  inline要素判定からはずす。(インデント処理上は block-level要素のように扱う)
		・numberingの[子要素への波及]機能のdebug
	[2014/03/30]
		・class/id/text以外の任意の箇所(タグ名/属性)でのナンバリング。また子供への波及。
		  "h$*3" とか。"ul>li*5>a{Item $}" とか (タグ名や子供への波及)。
		・implicit tag の包括的解決
		・unit test 作成 [zen-test]
		・2ch で 試してもらった感想をもらって大喜びする。
	[2014/03/29]
		・Git 導入。 codebreak, github にて公開しました。
	[2014/03/28]
		・改行ルールを、google html style guide に従うように変更。
			(要は inline要素以外は new lineにしようね、って仕様です。)
			[ref] http://google-styleguide.googlecode.com/svn/trunk/htmlcssguide.xml#HTML_Style_Rules
			まとめると、次のようになります。
			1. 子要素が全部inline要素の場合は各子要素の末尾では改行しない。
			2. それ以外の場合、子のinline 要素について、次がblock-level要素の場合改行を入れる。
			3. 子要素のblock-level要素の末尾は必ず改行を入れる。
		・indent も自前で実装
		・サイレントモード実装。zen-codeを残す/消すの制御ができます。
		・グルーピングの繰り返しに対応。(dt+dd)*3 のような。
	[2014/03/27]
		text, custom attributes のdebug
		再帰的abbrev実装 (zen-pre-abbrev)
		emmetの全ての略語を網羅
		numbering の スタート地点指定を追加 (@N, @-N)
		implicit tagの解決
		html-mode の標準では indent-regionしてくれないのに気づいて直す。
		snippet.lとの連携で、カーソルジャンプを可能に。
	[2014/03/26]
		text, custom attributes, numberingのデクリメント実装。
		公開にむけてこの説明書を書き始める。
	[2014/03/25]
		グルーピングやら遡上やら実装。insertできるようになった。
	[2014/03/24]
		Lisp思い出すのに四苦八苦。コア部完成。

### ■License
翻訳元に倣い、MITライセンスです。

	Copyright (c) 2014 Okayu3
	Released under the MIT license
	http://opensource.org/licenses/mit-license.php

### ■common Lisp の bugじゃないんだろうけど よく分からないこと
	・正規表現の "[\]\[]" と "[\[\]]" が違う意味らしい。後者は基本NGです。
	  →[教訓] 終わり角括弧("]") は 正規表現character classの中では先頭に配置すること。
