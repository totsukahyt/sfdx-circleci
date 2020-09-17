/*
	JavaScriptでJavaのStringクラスのメソッドを実装
		http://d.hatena.ne.jp/hysa/20090731/1248970363

var text = 'ABCDEFG';
text.startsWith('ABC');		 // true
text.startsWith('BC');			// false
text.startsWith('CDE', 2);	// true
text.startsWith('AB', 2);	 // false

var text = ' ABCDEFG 　 ';
text.trimLeft();		// 'ABCDEFG 　 '
text.trimRight();	 // ' ABCDEFG'
text.trim();				// 'ABCDEFG'

*/
String.prototype.startsWith = function(prefix, toffset) {
	var i = 0;
	if(toffset && (typeof toffset === 'number')) {
		i = toffset;
	}
	return this.slice(i).indexOf(prefix) === 0;
};

String.prototype.endsWith = function(suffix) {
	var sub = this.length - suffix.length;
	return (sub >= 0) && (this.lastIndexOf(suffix) === sub);
};

String.prototype.endsWith2 = function(suffix) {
		return this.startsWith(suffix, this.length - suffix.length);
};

String.prototype.trimLeft = function() {
	return this.replace(/^\s+/,'');
};

String.prototype.trimRight = function() {
	return this.replace(/\s+$/,'');
};

String.prototype.trim = function() {
	return this.replace(/^\s+|\s+$/g,'');
};

/*
	全角英数記号を半角にする関数
		http://www.m-bsys.com/code/toHalfWidth

	使用例
	var str = "１２３ＡＢＣ＊＋－／";
	alert(str.toHalfWidth());

	以下が変換対象文字です。これが
	！＂＃＄％＆＇（）＊＋，－．／
	０１２３４５６７８９：；＜＝＞？
	＠ＡＢＣＤＥＦＧＨＩＪＫＬＭＮＯ
	ＰＱＲＳＴＵＶＷＸＹＺ［＼］＾＿
	｀ａｂｃｄｅｆｇｈｉｊｋｌｍｎｏ
	ｐｑｒｓｔｕｖｗｘｙｚ｛｜｝～

	こうなります
	!"#$%&'()*+,-./
	0123456789:;<=>?
	@ABCDEFGHIJKLMNO
	PQRSTUVWXYZ[\]^_
	`abcdefghijklmno
	pqrstuvwxyz{|}~
*/
String.prototype.toHalfWidth = function() {
	return this.replace(/[！-～]/g, function(s) {
		return String.fromCharCode(s.charCodeAt(0) - 0xFEE0);
	});
}

// 全置換：全ての文字列 org を dest に置き換える
String.prototype.replaceAll = function (org, dest){
	return this.split(org).join(dest);
}

/*
	ちょっと便利な String の拡張
		http://zombiebook.seesaa.net/article/30900575.html
*/
// 文字順を反転させる
String.prototype.reverse = function (){
	var t = "";
	for(var i = this.length; i > 0; i--) t = t + this.substring(i - 1, i);
	return t;
}

// 文字列から数値を全て抜き出す（文字配列を返す）
String.prototype.extractNumber = function (){
	return this.match(/\-?[0-9]*\.?[0-9]+/g);
}

/*
	トライ木格納のためのコードナンバーを取得
*/
//var char_table="abcdefghijklmnopqrstuvwxyz0123456789 #$%()*+,-./:@";//6bitの範囲
var char_table="abcdefghijklmnopqrstuvwxyz _-./,";//5bitの範囲
String.prototype.charNumberAt = function (n){
	var s=this.charAt(n);
	return char_table.indexOf(s);
}

String.prototype.fromCharNumber = function (n){
	return char_table.charAt(n);
}
