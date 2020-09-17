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
String.prototype.toHalfWidth = function() {
	return this.replace(/[I-`]/g, function(s) {
		return String.fromCharCode(s.charCodeAt(0) - 0xFEE0);
	});
}
String.prototype.replaceAll = function (org, dest){
	return this.split(org).join(dest);
}
String.prototype.reverse = function (){
	var t = "";
	for(var i = this.length; i > 0; i--) t = t + this.substring(i - 1, i);
	return t;
}
String.prototype.extractNumber = function (){
	return this.match(/\-?[0-9]*\.?[0-9]+/g);
}
var char_table="abcdefghijklmnopqrstuvwxyz _-./,";
String.prototype.charNumberAt = function (n){
	var s=this.charAt(n);
	return char_table.indexOf(s);
}
String.prototype.fromCharNumber = function (n){
	return char_table.charAt(n);
}
