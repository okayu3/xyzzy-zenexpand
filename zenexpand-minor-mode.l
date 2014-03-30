;;; -*- Mode: Lisp; Package: EDITOR -*-
;;;
;;; This file is not part of xyzzy.
;;;
;; $Id: zenexpand-minor-mode.l,v 0.006 2014/03/30 22:45:10 okayu3 Exp $
;;
;; zenexpand-minor-mode.l
;;
;; ■zenexpand-minor-mode.l とは？
;;
;;	Emmet(旧 Zen-Coding) の、HTMLをCSS風の省略記法で
;;	書く機能(expand-abbreviation)を実装したものです。例えば、
;;
;;	ul>li#arg$$$*3.small.nav
;;
;;	というようなことを書けば、キー一発で
;;
;;    <ul>
;;      <li id="arg001" class="small nav"></li>
;;      <li id="arg002" class="small nav"></li>
;;      <li id="arg003" class="small nav"></li>
;;    </ul>
;;
;;	のように展開してくれる機能です。
;;	minor-modeで実装していますので html+-mode と一緒に使うと楽できると思います。  
;;	(また、snippet.lと一緒に使うことでカーソルジャンプもできます。)
;;
;;	Zen-CodingのSyntaxは
;;	http://docs.emmet.io/abbreviations/syntax/
;;	http://docs.emmet.io/cheat-sheet/
;;	をご覧ください。
;;
;; ■ちょっとした特長
;;	再帰的に略称を展開します。(そのせいでちょっと遅いです)
;;
;; ■動作環境
;;	xyzzy-0.2.2.245/0.2.2.252 での実行は確認しました。
;;
;; ■インストール
;;	1. zenexpand-minor-mode.l を site-lisp に置いてください。
;;	2. .xyzzy / sitelinit.l に次のように書いてください。
;;
;;		(require "zenexpand-minor-mode")
;;もしくは
;;		(export 'ed::zenexpand-minor-mode "ed")
;;		(autoload 'zenexpand-minor-mode "zenexpand-minor-mode" t)
;;
;; ■動かし方
;;	"M-x zenexpand-minor-mode" とするか、
;;	html+-mode のhookなどに
;;	(add-hook '*html+-mode-hook*
;;	          #'(lambda ()
;;	              ...blah-blah-blah...
;;	              (ed::zenexpand-minor-mode)
;;	              ))
;;	などと書いてください。
;;
;; ■動かし方(2)
;;	snippet.l を使うことで、展開時に、カーソルをジャンプすることができるようになります。
;;	[zen-snippet-expand]
;;	.xyzzy / siteinit.l などで、
;;
;;	(require "snippet")
;;
;;	と読み込んだ上で、
;;
;;	(define-key ed::*zenexpand-minor-mode-map* '#\M-e 'ed::zen-snippet-expand) ;;※1
;;
;;	としてください。
;;
;;	[ご注意][autoload された方へ] hookを作ってないので、
;;	   html+-mode-hook など、メジャーモードのhookに上記※1を付け足してください。
;;
;; ■使い方
;;	任意の場所で
;;	{<!DOCTYPE:html>}>html[lang="ja"]>(head>utf8+title+jq)+body>div#content>ul>li*3^(div#a>(ul>li#item01$$*4)+(ol>li#item02$$@-*5))+(div#b)+ta#aa[cols="20"]{this is a sample. }*3
;;	などと書いて、カーソルを省略記法の最後のところにある状態で "M-e" を押下すると 展開されます。
;;
;; ■そんな呪文覚えるの無理。。。
;;	って方のために簡単にご説明。基本的には、
;;		">" で階層を降りる。
;;		"+" で同じ階層に継ぎ足す。
;;		"^" で１つ上の階層に
;;		"#" でidを入れる。
;;		"." でクラスを指定
;;		"*N" (N:integer) で繰返し
;;		"$" をいれておけば １から数字をインクリメントして挿入
;;		"$@-" とすれば デクリメント
;;		[注意]スペース入れると展開できません。
;;	詳しくは
;;		"(" ")" でグルーピング
;;		"{" "}" で内容記載
;;		"[" "]" で id/class 以外の属性指定(カスタム属性)
;;		$$$ と"$"を並べれば zero-fill
;;	以上。あとは HTMLの通常のタグ(またはその省略形)を間にはさめばOK。
;;	5分で慣れます。これホント。詳しくは 下記cheat sheetご参照あれ。
;;	[refer] http://docs.emmet.io/cheat-sheet/
;;
;; ■問題点
;;	0. 2014/03段階でのEmmet仕様と合わせています。
;;	1. 未実装機能
;;		a. "[～]" のカスタム属性で、ダブルクォーテーションの補填を行う仕様
;;		b. 属性の textmate 風の デフォルト値指定
;;	2. おかしいところ
;;		・"ul+" "ol+" など "+"のついた略語の解釈が多分間違ってます。(仕様の記載通りなのだけど)
;;		  "ul+#$$*3" などは意図した動きだと思いますが、"ul+li" などは完全におかしい。
;;		  "ul++li" とか "ul+^ol" とかで代用できますが、もう訳が分からない。
;;		  普段は "ul>li#$$*3"  というような書き方をしてください。ご面倒かけます。
;;		・ implicit tag があるとインデントがうまくいかない場合が。
;;	3. これは純正品ではありません。
;;	4. いろいろ拡張できますが、拡張設定しやすいように作る方法が分からない
;;	   ので次に使うあなたが拡張してくださいね。
;;
;; ■設定
;;	展開するとき、入力したzen-codeを コメントとして残すことができます。  
;;	.xyzzy/siteinit.lに
;;	```
;;	(setq ed::*zenexpand-silent* nil)
;;	```
;;	と入れていただければ、入力をコメント行にして次の行に展開します。
;;
;; ■由来
;;	OTCHYさんによる perlによるZen-Coding実装 "SSSCoding.pm"
;;	http://www.otchy.net/20100225/zen-coding-for-perl/
;;	をベースに Lispで翻訳するところからはじめました。
;;	lexer/parse/expandがきれいにまとまっていて非常に読みやすかったです。
;;	# Copyright (c) 2010 Otchy
;;	# This source file is subject to the MIT license.
;;	# http://www.otchy.net
;;
;; ■変更履歴
;;	[2014/03/30]
;;		・class/id/text以外の任意の箇所(タグ名/属性)でのナンバリング。また子供への波及。
;;		  "h$*3" とか。"ul>li*5>a{Item $}" とか (タグ名や子供への波及)。
;;		・implicit tag の包括的解決。implicit tag利用時にインデントがうまくいかなかった件の解消
;;		・unit test 作成 [zen-test]
;;	[2014/03/29]
;;		・Git 導入。 codebreakにて公開しました。
;;	[2014/03/28]
;;		・改行ルールを、google html style guide に従うように変更。
;;			(要は inline要素以外は new lineにしようね、って仕様です。)
;;			[ref] http://google-styleguide.googlecode.com/svn/trunk/htmlcssguide.xml#HTML_Style_Rules
;;			まとめると、次のようになります。
;;			1. 子要素が全部inline要素の場合は改行しない。
;;			2. それ以外の場合、inline 要素の次がblock-level要素の場合改行を入れる。
;;		・indent も自前で実装
;;		・サイレントモード実装。zen-codeを残す/消すの制御ができます。
;;		・グルーピングの繰り返しに対応。(dt+dd)*3 のような。
;;	[2014/03/27]
;;		text, custom attributes のdebug
;;		再帰的abbrev実装 (zen-pre-abbrev)
;;		emmetの全ての略語を網羅
;;		numbering の スタート地点指定を追加 (@N, @-N)
;;		implicit tagの解決
;;		html-mode の標準では indent-regionしてくれないのに気づいて直す。
;;		snippet.lとの連携で、カーソルジャンプを可能に。
;;	[2014/03/26]
;;		text, custom attributes, numberingのデクリメント実装。
;;		公開にむけてこの説明書書き始める。
;;	[2014/03/25]
;;		グルーピングやら遡上やら実装。insertできるようになった。
;;	[2014/03/24]
;;		Lisp思い出すのに四苦八苦。コア部完成。
;;
;; ■License
;;	翻訳元に倣い、MITライセンスです。
;;
;;	Copyright (c) 2014 Satoshi Moriwaki
;;	Released under the MIT license
;;	http://opensource.org/licenses/mit-license.php
;;
;; ■common Lisp の bugじゃないんだろうけど よく分からないこと
;;	・正規表現の "[\]\[]" と "[\[\]]" が違う意味らしい。後者は基本NGです。
;;	  →[教訓] 終わり角括弧("]") は 正規表現character classの中では先頭に配置すること。

(provide "zenexpand-minor-mode")

(in-package "editor")

(export '(*zenexpand-minor-mode-map*
          zen-expand-and-insert
          zen-snippet-expand
          zen-expand
          zenexpand-minor-mode
          zen-test))

;; マイナーモードのOn・Offを管理するバッファローカルな変数を宣言
;; (マイナーモードの状態は、バッファごとに管理する)
(defvar-local *zenexpand-minor-mode* nil)

;; マイナーモード用のキーマップを保持する変数を宣言
;; (defvar で宣言された変数は、グローバルなスペシャル変数になる)
(defvar *zenexpand-minor-mode-map* nil)

;;;; onになったタイミングでのhook
;;(defvar *zenexpand-minor-mode-hook* nil "zenexpand-minor-mode: フック変数")

;; サイレントモード
;; t   入力を削除してその位置に展開。
;; nil 入力をコメント行にして次の行に展開。
(defvar *zenexpand-silent* t "zenexpand-minor-mode: サイレント")

;; 宣言した変数にキーマップをセットする (これはメジャーモードと同じ)
;; この処理は、1度だけ実行される
(unless *zenexpand-minor-mode-map*
  (setq *zenexpand-minor-mode-map* (make-sparse-keymap))
  (define-key *zenexpand-minor-mode-map* #\M-e 'zen-expand-and-insert)
  )

;;単独で(閉じタグなしで)使われるタグ
(defvar *zenexpand-singles* nil)
(unless *zenexpand-singles*
  (setq base "base,basefont,br,frame,hr,col,link,meta,img,embed,param,area,input,isindex,keygen,command")
  (setq *zenexpand-singles* (make-hash-table :test #'equalp))
  (dolist (one (split-string base ","))
    (setf (gethash one *zenexpand-singles*) 1))
  )

;; インライン要素のリストを作成します。
(defvar *zenexpand-inline-elements* nil)
(unless *zenexpand-inline-elements*
  (setq *zenexpand-inline-elements* (make-hash-table :test #'equalp))
  (setq base "b,big,i,small,tt,abbr,acronym,cite,code,dfn,em,kbd,strong,samp,var,a,bdo,br,img,map,object,q,script,span,sub,sup,button,input,label,select,textarea")
  (dolist (one (split-string base ","))
    (setf (gethash one *zenexpand-inline-elements*) 1))
  )

;;[略語辞書] 実際のタグにはない表記を行いたいときにはこちらを拡充します。
;;[hint] キーに "[" "]" "{" "}" "." "#" を含めることはできません。
;;[hint] valueが 任意の既存のキーと同じ場合無視されます。(再帰的に展開する際の無限ループを避けるため)
;;[hint] valueには、タグ名、*zenexpand-attrs* のキー、この*zenexpand-abbrevs*のキー、
;;       またはこれらを組み合わせた zen-code を入れます。
;;[hint] 長文定型のzen-codeは dabbrev.l/snippet.l などで管理するのも手ですね。
(defun zen-push-abbrev (k v)
  (let ((tbl *zenexpand-abbrevs*))
    (if (not (gethash v tbl))
        (setf (gethash k tbl) v))))
(defvar *zenexpand-abbrevs* nil)
(unless *zenexpand-abbrevs*
  (setq *zenexpand-abbrevs* (make-hash-table :test #'equalp))
  (zen-push-abbrev "!!!" "{<!DOCTYPE:html>}")
  (zen-push-abbrev "!!!4t" "{<!DOCTYPE HTML PUBLIC \"-//W3C//DTD HTML 4.01 Transitional//EN\" \"http://www.w3.org/TR/html4/loose.dtd\">}")
  (zen-push-abbrev "!!!4s" "{<!DOCTYPE HTML PUBLIC \"-//W3C//DTD HTML 4.01//EN\" \"http://www.w3.org/TR/html4/strict.dtd\">}")
  (zen-push-abbrev "!!!xt" "{<!DOCTYPE html PUBLIC \"-//W3C//DTD XHTML 1.0 Transitional//EN\" \"http://www.w3.org/TR/xhtml1/DTD/xhtml1-transitional.dtd\">}")
  (zen-push-abbrev "!!!xs" "{<!DOCTYPE html PUBLIC \"-//W3C//DTD XHTML 1.0 Strict//EN\" \"http://www.w3.org/TR/xhtml1/DTD/xhtml1-strict.dtd\">}")
  (zen-push-abbrev "!!!xxs" "{<!DOCTYPE html PUBLIC \"-//W3C//DTD XHTML 1.1//EN\" \"http://www.w3.org/TR/xhtml11/DTD/xhtml11.dtd\">}")
  (zen-push-abbrev "doc4" "html[lang=\"ja\"]>(head>title+utf)+body")
  (zen-push-abbrev "html:4t" "!!!4t+doc4")
  (zen-push-abbrev "html:4s" "!!!4s+doc4")
  (zen-push-abbrev "htmlx" "html:xml>(head>title+utf)+body")
  (zen-push-abbrev "html:xt" "!!!xt+htmlx")
  (zen-push-abbrev "html:xs" "!!!xs+htmlx")
  (zen-push-abbrev "html:xxs" "!!!xxs+htmlx")
  (zen-push-abbrev "doc" "html[lang=\"ja\"]>(head>utf8+title)+body")
  (zen-push-abbrev "html:5" "!!!+doc")
  (zen-push-abbrev "!" "!!!+doc")
  (zen-push-abbrev "hgr" "hgroup")
  (zen-push-abbrev "hdr" "header")
  (zen-push-abbrev "ftr" "footer")
  (zen-push-abbrev "adr" "address")
  (zen-push-abbrev "dlg" "dialog")
  (zen-push-abbrev "bq" "blockquote")
  (zen-push-abbrev "ol+" "ol>li")
  (zen-push-abbrev "ul+" "ul>li")    ;; "ul+*3" で３要素のlistができます。
  (zen-push-abbrev "dl+" "dl>(dt+dd)")
  (zen-push-abbrev "str" "strong")
  (zen-push-abbrev "acr" "acronym")
  (zen-push-abbrev "prg" "progress")
  (zen-push-abbrev "emb" "embed")
  (zen-push-abbrev "obj" "object")
  (zen-push-abbrev "src" "source")
  (zen-push-abbrev "map+" "map>area")
  (zen-push-abbrev "table+" "table>tr>td")
  (zen-push-abbrev "cap" "caption")
  (zen-push-abbrev "colg" "colgroup")
  (zen-push-abbrev "colg+" "colgroup>col")
  (zen-push-abbrev "tr+" "tr>td")
  (zen-push-abbrev "fset" "fieldset")
  (zen-push-abbrev "leg" "legend")
  (zen-push-abbrev "btn" "button")
  (zen-push-abbrev "select+" "select>option")
  (zen-push-abbrev "optg" "optgroup")
  (zen-push-abbrev "optgroup+" "optgroup>option")
  (zen-push-abbrev "optg+" "optgroup+")
  (zen-push-abbrev "datag" "datagrid")
  (zen-push-abbrev "datal" "datalist")
  (zen-push-abbrev "inp" "input:text")
  (zen-push-abbrev "tarea" "textarea")
  (zen-push-abbrev "kg" "keygen")
  (zen-push-abbrev "out" "output")
  (zen-push-abbrev "det" "details")
  (zen-push-abbrev "cmd" "command")
  (zen-push-abbrev "c" "{<!-- @N -->}")
  (zen-push-abbrev "cc:ie6" "{<!--[if lte IE 6]><![endif]-->}")
  (zen-push-abbrev "cc:ie" "{<!--[if IE]><![endif]-->}")
  (zen-push-abbrev "cc:noie" "{<!--[if !IE]><!--><!--<![endif]-->}")
  ;;original
  (zen-push-abbrev "css" "link:css")
  (zen-push-abbrev "utf" "meta:utf")
  (zen-push-abbrev "utf8" "meta:utf8")
  (zen-push-abbrev "sc" "script")
  (zen-push-abbrev "jq" "script:jquery")
  (zen-push-abbrev "ta" "textarea")
  (zen-push-abbrev "html5" "{<!DOCTYPE:html>}>html[lang=\"ja\"]>(head>title+utf8+jq)+body>div#content")
  (zen-push-abbrev "--" "{<!-- @N -->}")
  )

;;id,class以外の属性を含めたいタグと、展開したい属性のリスト。
(defvar *zenexpand-attrs* nil)
(unless *zenexpand-attrs*
  (setq *zenexpand-attrs* (make-hash-table :test #'equalp))
  (let ((tbl *zenexpand-attrs*))
    (setf (gethash "a" tbl) "href=\"\"")
    (setf (gethash "a:link" tbl) "href=\"http://\"")
    (setf (gethash "a:mail" tbl) "href=\"mailto:\"")
    (setf (gethash "abbr" tbl) "title=\"\"")
    (setf (gethash "acronym" tbl) "title=\"\"")
    (setf (gethash "base" tbl) "href=\"\"")
    (setf (gethash "bdo" tbl) "dir=\"\"")
    (setf (gethash "bdo:r" tbl) "dir=\"rtl\"")
    (setf (gethash "bdo:l" tbl) "dir=\"ltr\"")
    (setf (gethash "link" tbl) "rel=\"stylesheet\" href=\"\"")
    (setf (gethash "link:css" tbl) "rel=\"stylesheet\" type=\"text/css\" href=\"style.css\" media=\"all\"")
    (setf (gethash "link:print" tbl) "rel=\"stylesheet\" type=\"text/css\" href=\"print.css\" media=\"print\"")
    (setf (gethash "link:favicon" tbl) "rel=\"shortcut icon\" type=\"image/x-icon\" href=\"favicon.ico\"")
    (setf (gethash "link:touch" tbl) "rel=\"apple-touch-icon\" href=\"favicon.png\"")
    (setf (gethash "link:rss" tbl) "rel=\"alternate\" type=\"application/rss+xml\" title=\"RSS\" href=\"rss.xml\"")
    (setf (gethash "link:atom" tbl) "rel=\"alternate\" type=\"application/atom+xml\" title=\"Atom\" href=\"atom.xml\"")
    (setf (gethash "meta:utf8" tbl) "charset=\"UTF-8\"")
    (setf (gethash "meta:utf" tbl) "http-equiv=\"Content-Type\" content=\"text/html;charset=UTF-8\"")
    (setf (gethash "meta:win" tbl) "http-equiv=\"Content-Type\" content=\"text/html;charset=windows-1251\"")
    (setf (gethash "meta:compat" tbl) "http-equiv=\"X-UA-Compatible\" content=\"IE=7\"")
    (setf (gethash "style" tbl) "type=\"text/css\"")
    (setf (gethash "script" tbl) "type=\"text/javascript\"")
    (setf (gethash "script:src" tbl) "type=\"text/javascript\" src=\"\"")
    (setf (gethash "script:jquery" tbl) "type=\"text/javascript\" src=\"//ajax.googleapis.com/ajax/libs/jquery/2.1.0/jquery.min.js\"")
    (setf (gethash "img" tbl) "src=\"\" alt=\"\"")
    (setf (gethash "iframe" tbl) "src=\"\" frameborder=\"0\"")
    (setf (gethash "embed" tbl) "src=\"\" type=\"\"")
    (setf (gethash "object" tbl) "data=\"\" type=\"\"")
    (setf (gethash "param" tbl) "name=\"\" value=\"\"")
    (setf (gethash "map" tbl) "name=\"\"")
    (setf (gethash "area" tbl) "shape=\"\" coords=\"\" href=\"\" alt=\"\"")
    (setf (gethash "area:d" tbl) "shape=\"default\" href=\"\" alt=\"\"")
    (setf (gethash "area:c" tbl) "shape=\"circle\" coords=\"\" href=\"\" alt=\"\"")
    (setf (gethash "area:r" tbl) "shape=\"rect\" coords=\"\" href=\"\" alt=\"\"")
    (setf (gethash "area:p" tbl) "shape=\"poly\" coords=\"\" href=\"\" alt=\"\"")
    (setf (gethash "form" tbl) "action=\"\"")
    (setf (gethash "form:get" tbl) "action=\"\" method=\"get\"")
    (setf (gethash "form:post" tbl) "action=\"\" method=\"post\"")
    (setf (gethash "label" tbl) "for=\"\"")
    (setf (gethash "input" tbl) "type=\"\"")
    (setf (gethash "input:hidden" tbl) "type=\"hidden\" name=\"\"")
    (setf (gethash "input:h" tbl) "type=\"hidden\" name=\"\"")
    (setf (gethash "input:text" tbl) "type=\"text\" name=\"\"")
    (setf (gethash "input:t" tbl) "type=\"text\" name=\"\"")
    (setf (gethash "input:search" tbl) "type=\"search\" name=\"\"")
    (setf (gethash "input:email" tbl) "type=\"email\" name=\"\"")
    (setf (gethash "input:url" tbl) "type=\"url\" name=\"\"")
    (setf (gethash "input:password" tbl) "type=\"password\" name=\"\"")
    (setf (gethash "input:p" tbl) "type=\"password\" name=\"\"")
    (setf (gethash "input:datetime" tbl) "type=\"datetime\" name=\"\"")
    (setf (gethash "input:datetime-local" tbl) "type=\"datetime-local\" name=\"\"")
    (setf (gethash "input:date" tbl) "type=\"date\" name=\"\"")
    (setf (gethash "input:month" tbl) "type=\"month\" name=\"\"")
    (setf (gethash "input:week" tbl) "type=\"week\" name=\"\"")
    (setf (gethash "input:time" tbl) "type=\"time\" name=\"\"")
    (setf (gethash "input:number" tbl) "type=\"number\" name=\"\"")
    (setf (gethash "input:range" tbl) "type=\"range\" name=\"\"")
    (setf (gethash "input:color" tbl) "type=\"color\" name=\"\"")
    (setf (gethash "input:checkbox" tbl) "type=\"checkbox\" name=\"\"")
    (setf (gethash "input:c" tbl) "type=\"checkbox\" name=\"\"")
    (setf (gethash "input:radio" tbl) "type=\"radio\" name=\"\"")
    (setf (gethash "input:r" tbl) "type=\"radio\" name=\"\"")
    (setf (gethash "input:file" tbl) "type=\"file\" name=\"\"")
    (setf (gethash "input:f" tbl) "type=\"file\" name=\"\"")
    (setf (gethash "input:submit" tbl) "type=\"submit\" value=\"\"")
    (setf (gethash "input:s" tbl) "type=\"submit\" value=\"\"")
    (setf (gethash "input:image" tbl) "type=\"image\" src=\"\" alt=\"\"")
    (setf (gethash "input:i" tbl) "type=\"image\" src=\"\" alt=\"\"")
    (setf (gethash "input:reset" tbl) "type=\"reset\" value=\"\"")
    (setf (gethash "input:button" tbl) "type=\"button\" value=\"\"")
    (setf (gethash "input:b" tbl) "type=\"button\" value=\"\"")
    (setf (gethash "select" tbl) "name=\"\"")
    (setf (gethash "option" tbl) "value=\"\"")
    (setf (gethash "textarea" tbl) "name=\"\" cols=\"30\" rows=\"10\"")
    (setf (gethash "menu:context" tbl) "type=\"context\"")
    (setf (gethash "menu:c" tbl) "type=\"context\"")
    (setf (gethash "menu:toolbar" tbl) "type=\"toolbar\"")
    (setf (gethash "menu:t" tbl) "type=\"toolbar\"")
    (setf (gethash "video" tbl) "src=\"\"")
    (setf (gethash "audio" tbl) "src=\"\"")
    (setf (gethash "html:xml" tbl) "xmlns=\"http://www.w3.org/1999/xhtml\" lang=\"ja\"")
    )
  )

;; マイナーモードの切り替えを行う関数
(defun zenexpand-minor-mode (&optional (arg nil sv))
  (interactive "p")
  (toggle-mode '*zenexpand-minor-mode* arg sv)
  (update-mode-line t)
  (if *zenexpand-minor-mode*
      (set-minor-mode-map *zenexpand-minor-mode-map*)
    (unset-minor-mode-map *zenexpand-minor-mode-map*))
  t)

;; マイナーモードを有効にした時の、モードライン表示の設定
(pushnew
 '(*zenexpand-minor-mode* . "Zen") *minor-mode-alist* :key #'car)

;; snippet.lと連携して 動的略語展開(dabbrev)します。
(defun zen-snippet-expand ()
  (interactive)
  (let* (
         (input (zen-pick-previous-word))
         (len-real (length (substitute-string (or input "") "_@_" " ")))
         (setback (- (current-column) len-real))
         (expand-str (zen-expand input))
         (loc (point))
         )
    (if expand-str
        (progn
          (interactive)
          (if (string-match "\n$" expand-str) (setf expand-str (substitute-string expand-str "\n$" "")))
          (setf expand-str (zen-item-indent-local expand-str setback t))
          (backward-delete-char-untabify len-real)
          (when (not *zenexpand-silent*)
            (insert (concat "<!-- " (substitute-string (or input "") "_@_" " ") "-->"))
            (if (not (string-match "^\n" expand-str)) (insert "\n")))
          ;;          (setf expand-str (substitute-string expand-str "\\@N" "$0"))
          (setf expand-str (substitute-string expand-str "\"\"" "\"@N\""))
          (setf expand-str (zen-numbering-for-snippet expand-str))

          (define-abbrev *local-abbrev-table* "zenexpand-wk" expand-str)
          (setf *snippet-select* "zenexpand-wk")
          (snippet-expand)
          ;;major-mode の indent-regionを使うのをやめました。
          ;;(ignore-errors (indent-region (point-min) (point-max)))
          )
      (message "[ZEN]illegal format...")
      )))

;; zen-codeを文字列にして、カーソル位置直後に挿入します。
(defun zen-expand-and-insert ()
  (interactive)
  (let* (
         (input (zen-pick-previous-word))
         (len-real (length (substitute-string (or input "") "_@_" " ")))
         (setback (- (current-column) len-real))
         (expand-str (zen-expand input))
         (loc (point))
         )
    (if expand-str
        (progn
          (interactive)
          (if (string-match "\n$" expand-str) (setf expand-str (substitute-string expand-str "\n$" "")))
          (setf expand-str (zen-item-indent-local expand-str setback t))
          (backward-delete-char-untabify len-real)
          (when (not *zenexpand-silent*)
            (insert (concat "<!-- " (substitute-string (or input "") "_@_" " ") "-->"))
            (if (not (string-match "^\n" expand-str)) (insert "\n")))
          (setf expand-str (substitute-string expand-str "\\@N" ""))
          (insert expand-str)
          ;;major-mode の indent-regionを使うのをやめました。
          ;;(ignore-errors (indent-region (point-min) (point-max)))
          ;;(goto-char loc)
          )
      (message "[ZEN]illegal format...")
      )))

;; zen-codeを文字列に変換します。
(defun zen-expand (input)
  (setf ans nil)
  (when input
    ;;まず内部abbrevの解決を行います。
    (setf input (zen-pre-abbrev input))
    ;;lexical analysisします。
    (setf lst-token (zen-lexer input))
    ;;parse します。
    (setf root (zen-parser lst-token))
    ;;(princ root)
    ;;implicit tag の解決
    (zen-resolve-implicit-tag root nil)
    ;;root から文字列を出す
    (setf ans (zen-item-tostring root nil 1))
    );;when
  ans)

;; token list を parseします。
(defun zen-parser (lst-token)
  (setf ans nil)
  (let* (item
         (root (zen-item-new "ROOT" ""))
         (lst-ancestors '())
         (lst-grp '())
         (current root)
         (prev root)
         (flg-ignore nil)
         (flg-kokka nil)
         )
    ;;(push root lst-ancestors)
    ;;parseしていきます。
    (dolist (token lst-token)
      (cond ((equal ">" token)
             (push current lst-ancestors)
             (setf current prev)
             )
            ((equal "(" token)  ;;( は "g>" と同じとみなす。
             (setf grp (zen-item-new "GROUP" ""))
             (zen-item-add-child current grp)
             (setf prev grp)
             (push current lst-ancestors)
             (setf current prev)
;;             (push grp lst-ancestors)
             (push grp lst-grp)
             )
            ((equal ")" token)
             (when (> (length lst-grp) 0)
               (setf grp (pop lst-grp))
;;               (princ lst-ancestors)
               (if (member grp lst-ancestors)
                   (while (not (eq grp (pop lst-ancestors)))))
               (setf current grp)
               (setf flg-kokka t))
             )
            ((equal "+" token))
            ((equal "^" token)
             (when (and (> (length lst-ancestors) 0)
                        (not (zen-item-is-group current)))
               (setf current(pop lst-ancestors)))
             )
            (t
             (setf flg-ignore nil)
             (when (and flg-kokka (zen-item-is-group current))
               (when (string-match "^\\*\\([0-9]+\\)" token)
                 (zen-item-group-apply-scale current token (match-string 1))
                 (setf flg-ignore t))
               (setf flg-kokka nil)
               (setf current (pop lst-ancestors)))
             (when (not flg-ignore)
               (setf item (zen-item-new "ELEMENT" token))
               (zen-item-add-child current item)
               (setf prev item))
             )
            );;cond
      );;dolist
    (setf ans root)
    );;let*
  ans)

(defun zen-item-is-group (itm)
  (equal "GROUP" (elt itm 0)))

(defun zen-item-group-apply-scale (itm token scale)
  (setf (aref itm 4) scale))

;;入力を zen-code的に正しく 字句解析します。
(defun zen-lexer (input)
  (setf input (ch-empty input))
  (let* ((token "")
         (lst-token '())
         (lst-flg-text '())
         (lst-flg-catt '())
         (vec-freetxt (vector lst-flg-text lst-flg-catt))
         )
    (dotimes (i (length input))
      (setf c (string (char input i)))
      (if (and (not (zen-check-freetext c i vec-freetxt))
               (zen-is-specifier c))
          (progn
            (if (> (length token) 0)
                (progn
                  (push token lst-token)
                  (setf token nil))
              )
            (push c lst-token)
            )
        (setf token (concat token c))
        )
      )
    (if (and token (length token))
        (push token lst-token))
    (if (length lst-token)
        (setf lst-token (reverse lst-token)))
    (message (zen-string-join lst-token ","))
    (return-from zen-lexer lst-token)
    )
  nil
  )

;;zen-codingの構文制御子であるかどうかを判断します。
;;lexer のとき使います。
(defun zen-is-specifier (c)
  (and (= 1 (length c))
       (string-match "[>\+\(\)^]" c)))

;;lexer中に今 テキスト/カスタム属性内にいるかどうかを判断します。
;;テキスト{～} と カスタム属性[～] 内はスペースを含んだ
;;自由テキストを入れることができます。
;;テキスト中の 角括弧記載を許す処理が面倒。
(defun zen-check-freetext (c idx vec-freetxt)
  (setf ans nil)
  (let ((lst-flg-text (aref vec-freetxt 0))
        (lst-flg-catt (aref vec-freetxt 1)))
    (if (string-match "[\]\[\{\}]" c)
        (progn
          (setf ans t)
          (cond  ((equal c "{")
                  (push idx lst-flg-text))
                 ((equal c "}")
                  (pop lst-flg-text))
                 ((equal c "[")
                  (if (= (length lst-flg-text) 0)
                      (push idx lst-flg-catt)
                    (setf ans nil)))
                 ((equal c "]")
                  (if (= (length lst-flg-text) 0)
                      (pop lst-flg-catt)
                    (setf ans nil))))
          (setf (aref vec-freetxt 0) lst-flg-text)
          (setf (aref vec-freetxt 1) lst-flg-catt)
          )
      (setf ans
            (or (> (length lst-flg-catt) 0)
                (> (length lst-flg-text) 0)))
      ))
  ans)

;;単独で現われるタグか判断します
(defun zen-is-single (nm)
  (gethash nm *zenexpand-singles*))

;;HTML インライン要素か判断します
(defun zen-is-inline-element (nm)
  (if (null nm) t
    (gethash nm *zenexpand-inline-elements*)))

(defun zen-item-is-inline (one)
  (zen-is-inline-element (elt one 1)))
(defun zen-item-is-blocklevel (one)
  (if (null one) nil
    (not (zen-item-is-inline one))))

;;タグ名に対応する id/class以外の属性を返します。
(defun zen-get-attrs (nm)
  (gethash nm *zenexpand-attrs*))

;;*zenexpand-abbrevs* を元に略語の事前展開を行います。
(defun zen-pre-abbrev (input)
  (setf result (zen-pre-abbrev-one input))
  (while (not (equal result input))
    (setf input result)
    (setf result (zen-pre-abbrev-one input)))
  result)

;; token１つについて略語の事前展開を行っています。
(defun zen-pre-abbrev-one (input)
  (setf lst-token (zen-lexer input))
  (setf lst-ans '())
  (dolist (token lst-token)
    (if (string-match "^\\([^\]\[\}\{\>\<_.# ]+\\)\\(.*\\)" token)
        (if (equal "+" token)
            (setf lst-ans (zen-pre-abbrev-plus lst-ans token))
          (push (concat (zen-item-expand-name (match-string 1)) (match-string 2)) lst-ans))
      (push token lst-ans)))
  (zen-string-join (reverse lst-ans) "")
  )

;; "+" つきの略語の事前展開です。"+"１文字で 別トークンになってるので
;; sequence を１つさかのぼる処理をしています。
(defun zen-pre-abbrev-plus (lst-wk token)
  (if (= (length lst-wk) 0)
      (push token lst-wk)
    (progn
      (setf cand-tag (concat (car lst-wk) token))
      (if (not (gethash cand-tag *zenexpand-abbrevs*))
          (push token lst-wk)
        (progn
          (pop lst-wk)
          (push (zen-item-expand-name cand-tag) lst-wk)))))
  lst-wk)

;;トークンから、
;;属性とテキストをカットしたもの、カットされた属性とテキスト を arrayにして返します。
(defun zen-item-cut (input)
  (setf lst-cattr '())
  (setf lst-text '())
  (while (string-match "\\[[^\]]+\\]\\|\\{[^\}]+\\}" input)
    (let* ((matched (match-string 0))
           (head (string (char matched 0))))
      (cond
       ((equal head "[")
        (setf matched (substitute-string matched "\\[" "\\\\["))
        (setf matched (substitute-string matched "\\]" "\\\\]"))
        (setf input (substitute-string input matched ""))
        (setf matched (substitute-string matched "\\\\\\[" ""))
        (setf matched (substitute-string matched "\\\\\\]" ""))
        (push matched lst-cattr))
       ((equal head "{")
        (setf matched (substitute-string matched "\\[" "\\\\["))
        (setf matched (substitute-string matched "\\]" "\\\\]"))
        (setf input (substitute-string input matched ""))
        (setf matched (substitute-string matched "\\\\\\[" "\\["))
        (setf matched (substitute-string matched "\\\\\\]" "\\]"))
        (setf matched (substitute-string matched "\\{" ""))
        (setf matched (substitute-string matched "\\}" ""))
        (push matched lst-text))
       )))
  (setf ans (make-array 3))
  (setf (aref ans 0) input)
  (setf (aref ans 1) (reverse lst-cattr))
  (setf (aref ans 2) (reverse lst-text))
  ans)

;;構文木のノードを作成します。
;;cls : ROOT / ELEMENT
(defun zen-item-new (typ input)
  (let ((mode 0)
        (cls nil)
        (lst-class '())
        (nm nil)
        (id nil)
        (scale nil)
        )
    ;;まずfree textをカットします。
    (setf arr-cut (zen-item-cut input))
    (setf input (aref arr-cut 0))
    (setf lst-cattr (aref arr-cut 1))
    (setf lst-text (aref arr-cut 2))
    (dotimes (i (length input))
      (setf c (string (char input i)))
      (if (or (equal "#" c) (equal "." c) (equal "*" c))
          (progn
            (if (equal "#" c) (setf mode 1))
            (if (equal "." c) (setf mode 2))
            (if (equal "*" c) (setf mode 3))
            (if (> (length cls) 0)
                (progn
                  (push cls lst-class)
                  (setf cls nil)))
            )
        (cond ((= mode 0)
               (setf nm (concat nm c)))
              ((= mode 1)
               (setf id (concat id c)))
              ((= mode 2)
               (setf cls (concat cls c)))
              ((= mode 3)
               (setf scale (concat scale c))))
        )
      )
    (if (> (length cls) 0)
        (push cls lst-class))
    ;;    (setf nm (zen-item-expand-name nm))
    (setf attr (or (zen-get-attrs nm) nil))
    (if nm
        (setf nm (elt (split-string nm ":") 0)))
    (setf ans (make-array 9))
    (setf (aref ans 0) typ)   ;;type
    (setf (aref ans 1) nm)    ;;name
    (setf (aref ans 2) id)    ;;id
    (setf (aref ans 3) (reverse lst-class))   ;;classes
    (setf (aref ans 4) scale) ;;scale
    (setf (aref ans 5) attr)    ;;attrs
    (setf (aref ans 6) '())   ;;children
    (setf (aref ans 7) lst-cattr);;custom attributes
    (setf (aref ans 8) lst-text) ;;text
    ans
    )
  )

;;略語展開
(defun zen-item-expand-name (nm)
  (let* ((expanded0 (gethash nm *zenexpand-abbrevs*))
         (lst-nm (split-string nm ":"))
         (target (elt lst-nm 0))
         (expanded (gethash target *zenexpand-abbrevs*))
         )
    (if (and expanded0
             (not (gethash expanded0 *zenexpand-abbrevs*)))
        (setf nm expanded0)
      (if (and expanded
               (not (gethash expanded *zenexpand-abbrevs*)))
          (setf nm (zen-string-join (cons expanded (cdr lst-nm)) ":"))
        )))
  nm
  )

;;ノードに子要素を追加します。
(defun zen-item-add-child (prnt chld)
  (push chld (aref prnt 6)))

;;文字列へ変換します。
;; itm : 対象のノード
;; parent-nm : 親のタグ名。implicit tagname を判断するのに使います。
(defun zen-item-tostring (itm parent-nm parent-cnt)
  (let (ans
        (typ (aref itm 0))
        (nm (aref itm 1))
        (scale (aref itm 4))
        scale-val
        )
    (if (not (null scale))
        (setf scale-val (parse-integer scale :junk-allowed t))
      (setf scale-val 1))
    (cond ((equal "ROOT" typ)
           (let ((children (reverse (aref itm 6))))
             (dolist (one children)
               (setf ans (concat ans (zen-item-tostring one nm scale-val))))))
          ((equal "ELEMENT" typ)
           (if (> scale-val 0)
               (progn
                 (dotimes (i scale-val)
                   (setf ans (concat ans (zen-item-tostring-detail itm (+ i 1) scale-val parent-nm parent-cnt)))
                   )
                 )
             (setf ans (concat ans (zen-item-tostring-detail itm -1 -1 parent-nm parent-cnt)))
             ))
          ((equal "GROUP" typ)
           (let ((children (reverse (aref itm 6))))
             (dotimes (i scale-val)
               (dolist (one children)
                 (setf ans (concat ans (zen-item-tostring one nm i)))
                 ))))
      )
    ans)
  )

;;文字列へ変換します。(詳細)
;; itm : 対象のノード
;; cnt : numbering時の繰り替えし数 (1～scale-val)
;; scale-val : numbering 数
;; parent-nm : 親のタグ名。implicit tagname を判断するのに使います。
(defun zen-item-tostring-detail (itm cnt scale-val parent-nm parent-cnt)
  (let* ((nm (aref itm 1))
         (id (aref itm 2))
         (lst-class (aref itm 3))
         (attr (aref itm 5))
         (children (reverse (aref itm 6)))
         (lst-cattr (aref itm 7))
         (lst-text (aref itm 8))
         (ans nil)
;;         (nm (zen-item-resolve-implicit-tag nm-base parent-nm id lst-class lst-cattr))
         (flg-inline (zen-is-inline-element nm))
         (flg-has-block-child (zen-item-has-block-elem children))
         )
;;    (setf flg-inline nil)
    ;;(format nil "~VA" setback " ")
    (when nm
      (setf nm (zen-item-resolve-dollar nm cnt scale-val parent-cnt))
      (setf ans (concat "<" nm)))
    (if id
        (setf ans (concat ans " id=\"" (zen-item-dsc-id itm cnt scale-val parent-cnt) "\"")))
    (if (> (length lst-class) 0)
        (setf ans (concat ans " class=\"" (zen-item-dsc-class itm cnt scale-val parent-cnt) "\"")))
    (if attr
        (setf ans (concat ans " " attr)))
    (if (> (length lst-cattr) 0)
        (dolist (one-cattr lst-cattr)
          (setf one-cattr (substitute-string one-cattr "_@_" " "))
          (setf one-cattr (zen-item-resolve-dollar one-cattr cnt scale-val parent-cnt))
          (setf ans (concat ans " " one-cattr))))
    (when (zen-is-single nm)
      (setf ans (concat ans " />"))
      (when (or (not flg-inline) (equal nm "br"))
        (setf ans (concat ans "\n")))
      (return-from zen-item-tostring-detail ans))
    (when nm
      (setf ans (concat ans ">")))
    
    (when (and (not flg-inline) flg-has-block-child)
      (setf ans (concat ans "\n")))
    (when (> (length lst-text) 0)
      (dolist (one-text lst-text)
        (setf one-text (substitute-string one-text "_@_" " "))
        (setf one-text (zen-item-resolve-dollar one-text cnt scale-val parent-cnt))
        (setf cr (if (and flg-has-block-child
                          (not (zen-item-is-inline (car children))))
                     "\n"
                   ""))
        (setf ans (concat ans one-text cr))))
;;     (dolist (one children)
;;       (let ((child-dsc (zen-item-tostring one nm)))
;;         (setf ans (concat ans child-dsc)))
;;       )
    (dotimes (i (length children))
      (let* ((one (nth i children))
             (two (nth (+ i 1) children))
             (child-dsc (zen-item-tostring one nm cnt)))
        (setf cr (if (and flg-has-block-child
                          (zen-item-is-inline one)
                          (not (zen-item-is-inline two)))
                     "\n"
                   ""))
        (setf ans (concat ans child-dsc cr))))
    
    (if (and (not (equal nm "script"))
             (= (length lst-text) 0)
             (= (length children) 0))
        (setf ans (concat ans "@N")))

    
    (if nm
        (setf ans (concat ans "</" nm  ">")))
    (when (not flg-inline)
      (setf ans (zen-item-indent-local ans 2 nil))
      (setf ans (concat ans "\n"))
      )

    
    (return-from zen-item-tostring-detail ans)
    )
  nil
  )

(defun zen-item-indent-local (input setback force)
  (setf ans nil)
  (if (or (null input) (= setback 0))
      (setf ans input)
    (let ((ind (concat "\n" (format nil "~VA" setback " "))))
      (if force
          (setf ans (substitute-string input  "\n" ind))
        (progn
          (setf lst-parts (split-string input "\n"))
          (setf len-p (length lst-parts))
          (setf ans "")
          (dotimes (i len-p)
            (cond ((= i (- len-p 2))
                   (setf ans (concat ans (nth i lst-parts) "\n")))
                  ((= i (- len-p 1))
                   (setf ans (concat ans (nth i lst-parts))))
                  (t
                   (setf ans (concat ans (nth i lst-parts) ind)))))
          )
        )))
  ans)

;; (defun zen-item-indent-local (input setback force)
;;   (if (= setback 0)
;;       (return-from zen-item-indent-local input))
;;   (setf lst_parts (split-string input "\n"))
;;   (setf lst_wk '())
;;   (setf ind (format nil "~VA" setback " "))
;;   (let ((len-p (length lst_parts)))
;;     (if (<= len-p 2)
;;         (return-from zen-item-indent-local input))
;;     (dotimes (i len-p)
;;       (push (nth i lst_parts) lst_wk)
;;       (if (< i (- len-p 2))
;;           (push (concat "\n" ind) lst_wk)
;;         (if force
;;             (push (concat "\n" ind) lst_wk)
;;           (push "\n" lst_wk))))
;;     (zen-string-join (reverse lst_wk) "")))


;;子供に inline要素しかないなら改行しなくていいチェック
;;本当は 孫・ひ孫 まで deep-searchして調べたいけど iterationしても重くなるだけだよね？
(defun zen-item-has-block-elem (children)
  ;;なので dolistでごまかす
  (dolist (itm children)
    (if (zen-item-is-group itm)
        (return-from zen-item-has-block-elem t))
    (setf nm (aref itm 1))
    (if (not (zen-is-inline-element nm))
        (return-from zen-item-has-block-elem t)))
  nil)

;;id名の解決
(defun zen-item-dsc-id (itm cnt scale-val parent-scale-val)
  (let ((nm (aref itm 2)))
    (zen-item-resolve-dollar nm cnt scale-val parent-scale-val)))

;;numberingの解決
(defun zen-item-resolve-dollar (nm cnt scale-val parent-scale-val)
  (when (> parent-scale-val cnt)
    (setf cnt parent-scale-val))
  (when (string-match "\\$\\@\\([0-9]+\\)" nm)
    (let* ((lbl-start (match-string 1))
           (lbl-start-val (parse-integer lbl-start :junk-allowed t)))
      (setf cnt (- (+ cnt lbl-start-val) 1))
      (setf nm (substitute-string nm (concat "\\@" lbl-start) "")))
    );;flg-has-(@N)
  (when (string-match "\\$\\@-\\([0-9]+\\)" nm)
    (let* ((lbl-start (match-string 1))
           (lbl-start-val (parse-integer lbl-start :junk-allowed t)))
      (setf cnt (+ lbl-start-val (- scale-val cnt)))
      (setf nm (substitute-string nm (concat "\\@-" lbl-start) "")))
    );;flg-has-(@-N)
  (when (string-match "\\$\\@-" nm)
    (setf cnt (+ 1 (- scale-val cnt)))
    (setf nm (substitute-string nm "\\@-" ""))
    );;flg-has-(@-)
  (if (and (> cnt 0) (string-match "[\$]+" nm))
      (let* ((dsc-dollar (match-string 0))
             (len-dollar (length dsc-dollar))
             ans
             )
        (setf dsc-dollar (substitute-string dsc-dollar "\\$" "\\\\$"))
        (if (> len-dollar 1)
            (setf ans (substitute-string nm dsc-dollar (format nil "~V,'0D" len-dollar cnt)))
          (setf ans (substitute-string nm dsc-dollar (format nil "~D" cnt))))
        ans
        )
    nm))

;;list の join
(defun zen-string-join (lst sep)
  (cond ((null (car lst))
         "")
        ((null (cdr lst))
         (car lst))
        (t
         (concat (car lst) sep (zen-string-join (cdr lst) sep)))))

;;クラス名の解決
(defun zen-item-dsc-class (itm cnt scale-val parent-scale-val)
  (let ((ans "")
        (classes (aref itm 3)))
    (setf ans (zen-string-join classes " "))
    (zen-item-resolve-dollar ans cnt scale-val parent-scale-val)))

;;implicit tagの解決
(defun zen-resolve-implicit-tag (itm parent-nm)
  (let ((nm (zen-item-resolve-implicit-tag itm parent-nm))
        (children (reverse (aref itm 6))))
    (setf (aref itm 1) nm)
    (dolist (child children)
      (zen-resolve-implicit-tag child nm)
      )
    )
  )


(defun zen-item-resolve-implicit-tag (itm parent-nm)
  (let ((nm-base (aref itm 1))
        (id (aref itm 2))
         (lst-class (aref itm 3))
         (lst-cattr (aref itm 7))
        nm
        )
    (if (not (null nm-base)) (setf nm nm-base))
    (when (and (null nm-base)
               (or   (not (null id))
                     (> (length lst-class) 0)
                     (> (length lst-cattr) 0))
               )
      (setf nm "div")
      (cond ((equal parent-nm "ul")
             (setf nm "li"))
            ((equal parent-nm "ol")
             (setf nm "li"))
            ((equal parent-nm "dl")
             (setf nm "dt"))
            ((equal parent-nm "table")
             (setf nm "tr"))
            ((equal parent-nm "tbody")
             (setf nm "tr"))
            ((equal parent-nm "thead")
             (setf nm "tr"))
            ((equal parent-nm "tfoot")
             (setf nm "tr"))
            ((equal parent-nm "tr")
             (setf nm "td"))
            ((equal parent-nm "select")
             (setf nm "option"))
            ((equal parent-nm "optgroup")
             (setf nm "option"))
            ((equal parent-nm "em")
             (setf nm "span")))
      )
    nm))

;; numbering for snippet.l
;; 最初は $N 形式でOK。その後 ${N: default} 形式に対応する予定。
;; INPUT 時点では、@N または @{N: default} 形式になっている予定。
(defun zen-numbering-for-snippet (input)
  (setf lst_parts (split-string input "\\@N"))
  (setf lst_wk '())
  (setf idx 0)
  (let ((len_p (length lst_parts)))
    (dotimes (i len_p)
      (setf one (nth i lst_parts))
      (push one lst_wk)
      (if (< i (- len_p 2))
          (push (concat "$" (format nil "~D" (+ i 1))) lst_wk)
        (push "$0" lst_wk))
      )
    (zen-string-join (reverse lst_wk) "")))

;; カーソル直前のワードを取り出す
;; 2014/03/24(Mon) (英数字以外もとるため、 (forward-word -1) とか使えない)
;; 2014/03/26(Wed) [custom attributes] {text} にも対応
(defun zen-pick-previous-word ()
  (interactive "*p")
  (let ((posnow (point))
        (posbol (progn (goto-bol) (point)))
        )
    (goto-char posnow)
    (setf aa (buffer-substring posbol posnow))
    (setf aa (ch-empty aa))
    (string-match "\\([^ ]+\\)$" aa)
    (match-string 1)))

;; [],{}に囲まれた中の文字列の空白文字を "_@_" に escapeする
;; 2014/03/26(Wed) [custom attributes] {text} にも対応
(defun ch-empty (input)
  (setf start 0)
  (while (setf start (string-match "\\[[^\]]+\\]" input start))
    (let* ((matched (match-string 0))
           (de-empty (substitute-string matched " " "_@_")))
      (setf start (+ start (length de-empty)))
      (when (string-match " " matched)
        (setf matched (substitute-string matched "\\[" "\\\\["))
        (setf matched (substitute-string matched "\\]" "\\\\]"))
        (setf input (substitute-string input matched de-empty)))))
  (setf start 0)
  (while (setf start (string-match "\\{[^\}]+\\}" input start))
    (let* ((matched (match-string 0))
           (de-empty (substitute-string matched " " "_@_")))
      (setf start (+ start (length de-empty)))
      (when (string-match " " matched)
        (setf matched (substitute-string matched "\\{" "\\\\{"))
        (setf matched (substitute-string matched "\\}" "\\\\}"))
        (setf input (substitute-string input matched de-empty)))))
  input)

(defun zen-test ()
  (setq tests
        '(("nav>ul>li" "<nav>\n  <ul>\n    <li>@N</li>\n  </ul>\n</nav>\n")
          ("div+p+bq" "<div>@N</div>\n<p>@N</p>\n<blockquote>@N</blockquote>\n")
          ("div+div>p>span+em^bq" "<div>@N</div>\n<div>\n  <p><span>@N</span><em>@N</em></p>\n  <blockquote>@N</blockquote>\n</div>\n")
          ("div+div>p>span+em^^bq" "<div>@N</div>\n<div>\n  <p><span>@N</span><em>@N</em></p>\n</div>\n<blockquote>@N</blockquote>\n")
          ("div>(header>ul>li*2>a)+footer>p" "<div>\n  <header>\n    <ul>\n      <li><a href=\"\">@N</a></li>\n      <li><a href=\"\">@N</a></li>\n    </ul>\n  </header>\n  <footer>\n    <p>@N</p>\n  </footer>\n</div>\n")
          ("(div>dl>(dt+dd)*3)+footer>p" "<div>\n  <dl>\n    <dt>@N</dt>\n    <dd>@N</dd>\n    <dt>@N</dt>\n    <dd>@N</dd>\n    <dt>@N</dt>\n    <dd>@N</dd>\n  </dl>\n</div>\n<footer>\n  <p>@N</p>\n</footer>\n")
          ("ul>li#itm$$*5>a{Item $}" "<ul>\n  <li id=\"itm01\"><a href=\"\">Item 1</a></li>\n  <li id=\"itm02\"><a href=\"\">Item 2</a></li>\n  <li id=\"itm03\"><a href=\"\">Item 3</a></li>\n  <li id=\"itm04\"><a href=\"\">Item 4</a></li>\n  <li id=\"itm05\"><a href=\"\">Item 5</a></li>\n</ul>\n")
          ("ul>li*5" "<ul>\n  <li>@N</li>\n  <li>@N</li>\n  <li>@N</li>\n  <li>@N</li>\n  <li>@N</li>\n</ul>\n")
          ("ul>li.item$*5" "<ul>\n  <li class=\"item1\">@N</li>\n  <li class=\"item2\">@N</li>\n  <li class=\"item3\">@N</li>\n  <li class=\"item4\">@N</li>\n  <li class=\"item5\">@N</li>\n</ul>\n")
          ("h$[title=item$]{Header $}*3" "<h1 title=item1>Header 1</h1>\n<h2 title=item2>Header 2</h2>\n<h3 title=item3>Header 3</h3>\n")
          ("#page>div.logo+ul#navigation>li*5>a{Item $}" "<div id=\"page\">\n  <div class=\"logo\">@N</div>\n  <ul id=\"navigation\">\n    <li><a href=\"\">Item 1</a></li>\n    <li><a href=\"\">Item 2</a></li>\n    <li><a href=\"\">Item 3</a></li>\n    <li><a href=\"\">Item 4</a></li>\n    <li><a href=\"\">Item 5</a></li>\n  </ul>\n</div>\n")
          ("ul>li.item$$$*5" "<ul>\n  <li class=\"item001\">@N</li>\n  <li class=\"item002\">@N</li>\n  <li class=\"item003\">@N</li>\n  <li class=\"item004\">@N</li>\n  <li class=\"item005\">@N</li>\n</ul>\n")
          ("ul>li.item$@-*5" "<ul>\n  <li class=\"item5\">@N</li>\n  <li class=\"item4\">@N</li>\n  <li class=\"item3\">@N</li>\n  <li class=\"item2\">@N</li>\n  <li class=\"item1\">@N</li>\n</ul>\n")
          ("ul>li.item$@3*5" "<ul>\n  <li class=\"item3\">@N</li>\n  <li class=\"item4\">@N</li>\n  <li class=\"item5\">@N</li>\n  <li class=\"item6\">@N</li>\n  <li class=\"item7\">@N</li>\n</ul>\n")
          ("ul>li.item$@-3*5" "<ul>\n  <li class=\"item7\">@N</li>\n  <li class=\"item6\">@N</li>\n  <li class=\"item5\">@N</li>\n  <li class=\"item4\">@N</li>\n  <li class=\"item3\">@N</li>\n</ul>\n")
          ("#header" "<div id=\"header\">@N</div>\n")
          (".title" "<div class=\"title\">@N</div>\n")
          ("form#search.wide" "<form id=\"search\" class=\"wide\" action=\"\">@N</form>\n")
          ("p.class1.class2.class3" "<p class=\"class1 class2 class3\">@N</p>\n")
          ("p[title=\"Hello world\"]" "<p title=\"Hello world\">@N</p>\n")
          ("td[rowspan=2 colspan=3 title]" "<td rowspan=2 colspan=3 title>@N</td>\n")
          ("[a='value1' b=\"value2\"]" "<div a='value1' b=\"value2\">@N</div>\n")
          ("a{Click me}" "<a href=\"\">Click me</a>")
          ("p>{Click }+a{here}+{ to continue}" "<p>Click <a href=\"\">here</a> to continue</p>\n")
          (".class" "<div class=\"class\">@N</div>\n")
          ("em>.class" "<em><span class=\"class\">@N</span></em>")
          ("ul>.class" "<ul>\n  <li class=\"class\">@N</li>\n</ul>\n")
          ("table>.row>.col" "<table>\n  <tr class=\"row\">\n    <td class=\"col\">@N</td>\n  </tr>\n</table>\n")
          ))
  (setf success 0)
  (setf failed 0)
  (dolist (onetest tests)
    (let ((test (equal (zen-expand (car onetest)) (cadr onetest))))
      (if (not test) (princ (concat "FAILED:" (car onetest) "\n")))
      (if test
          (setf success (+ 1 success))
        (setf failed (+ 1 failed)))))
  (list success failed))
