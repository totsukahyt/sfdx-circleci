/*
	自己参照のオブジェクトや配列をディープコピーする
		http://qiita.com/cocottejs/items/19cfc914c5c1722ad616
*/

var clone = (function() {
	function cp (val) {
		if (val === null ||
				val === void 0 ||
				typeof val === 'string' ||
				typeof val === 'number' ||
				typeof val === 'boolean' ||
				typeof val === 'function') {
			return val;
		}
		var constructor = Object.getPrototypeOf(val).constructor;
		if (constructor === RegExp) {
			var att = String(val).slice(val.source.length + 2);
			return new RegExp(val.source, att);
		}
		if (constructor === Date) {
			return new Date(val.getTime());
		}
		var self = this;
		var idx = self.obj1.indexOf(val);
		if (~idx) {
			return self.obj2[idx];
		}
		var rtn = constructor === Array ? [] : {};
		this.obj1.push(val);
		this.obj2.push(rtn);
		if (constructor === Array) {
			val.forEach(function(x) {
				rtn.push(self.cp(x));
			});
		} else {
			Object.keys(val).forEach(function(x){
				rtn[x] = self.cp(val[x]);
			});
		}
		return rtn;
	}
	function clone (val) {
		var self = {
			cp: cp,
			obj1: [], 
			obj2: []
		};
		return self.cp(val);
	}
	return clone;
})();
