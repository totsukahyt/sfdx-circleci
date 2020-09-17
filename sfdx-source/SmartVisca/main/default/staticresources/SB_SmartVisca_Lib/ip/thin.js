/*
	Zhang-Suen thinning algorithm
		http://rosettacode.org/wiki/Zhang-Suen_thinning_algorithm
	JavascriptÇ≈ç◊ê¸âª
		http://www.hundredsoft.jp/win7blog/log/eid119.html
	Arranged by T. Osaka(2015/8/26)
*/

var thin = (function(undefined) {

var grid;
var g;
var width, w;
var height, h;
var mode;

var thin = function(Mode, ImageData, W, H) {
	mode = Mode;
	width = W;
	height = H;
	w = width;
	h = height;
//console.log("mode=" + mode + " w=" + w + " h=" + h);

	if (mode == 32) {
		g = new Array(w * h);
		var n = 0;
		for (var i = 0; i < h; i++) {
			for (var j = 0; j < w; j++) {
				var c = i * w + j;
				g[n++] = ImageData[4 * c];
			}
		}
	}
	else {
		var size = w * h;
		g = new Array(size);
		for (var i = 0; i < size; i++) g[i] = ImageData[i];
	}
	grid = null;
//console.log("thin " + width + " " + height + " " + g.length);
//console.log("w h " + w + " " + h);
}


//
// JavascriptÇ≈ç◊ê¸âª NWG Algorithm
//		http://www.hundredsoft.jp/win7blog/log/eid119.html
//
//thin.prototype.nwg_method = function(g, w, h, x1,y1, x2, y2) {
thin.prototype.nwg_method = function(x1,y1, x2, y2) {
//	width = w;
//	height = h;
//console.log("w h " + w + " " + h);
//console.log("wh " + width + " " + height);
	grid = new Array(width * height);
	for (var i = 0; i < g.length; i++) {
		grid[i] = g[i];
	}
/*
	for (var i = 0; i < g.length; i++) {
		grid[i] = ~g[i];
		g[i] = ~g[i];
	}
*/

	var bFlag = true;

	for (var k = 0; k < 100 && bFlag; k++) {
		bFlag = false;
		for (var i = 0; i < g.length; i++) {
			g[i] = grid[i];
		}
		for (var y = y1; y < y2; y++) {
			for (var x = x1; x < x2; x++) {
				var i = y * w + x;
				if (g[i]) {
					// [p7 p0 p1]
					// [p6	  p2]
					// [p5 p4 p3]
					var p0 = (g[i - w    ]) ? 1 : 0;
					var p1 = (g[i - w + 1]) ? 1 : 0;
					var p2 = (g[i      +1]) ? 1 : 0;
					var p3 = (g[i + w + 1]) ? 1 : 0;
					var p4 = (g[i + w    ]) ? 1 : 0;
					var p5 = (g[i + w - 1]) ? 1 : 0;
					var p6 = (g[i      -1]) ? 1 : 0;
					var p7 = (g[i - w - 1]) ? 1 : 0;
					var a = 0;
					if (!p0 && p1) {a++;}
					if (!p1 && p2) {a++;}
					if (!p2 && p3) {a++;}
					if (!p3 && p4) {a++;}
					if (!p4 && p5) {a++;}
					if (!p5 && p6) {a++;}
					if (!p6 && p7) {a++;}
					if (!p7 && p0) {a++;}
					var b = p0 + p1 + p2 + p3 + p4 + p5 + p6 + p7;

					if (2 <= b && b <= 6) {
						var c = 0;
						if ((p0 + p1 + p2 + p5 == 0 && p4 + p6 == 2)
						 || (p2 + p3 + p4 + p7 == 0 && p0 + p6 == 2)) {
							c = 1;
						}
						if (a == 1 || c == 1) {
							var e = (p2+p4) * p0 * p6;
							var f = (p0+p6) * p2 * p4;
							if ((!(k & 1) && e == 0) || ( (k & 1) && f == 0)) {
								grid[i] = 0;
								bFlag = true;
							}
						}
					}
				}
			}
		}
	}
/*	for (var i = 0; i < grid.length; i++) {
		g[i] = ~g[i];
		grid[i] = ~grid[i];
	}*/
};

thin.prototype.getData = function() {
//console.log("Mode=" + mode + " w=" + w + " h=" + h);
	var data;
	if (mode == 32) {
		data = new Array(w * h * 4);
		for (var i = 0; i < h; i++) {
			for (var j = 0; j < w; j++) {
				var c = i * w + j;
				data[4 * c + 0] = grid[c];
				data[4 * c + 1] = grid[c];
				data[4 * c + 2] = grid[c]
				data[4 * c + 3] = 255;
			}
		}
	}
	else {
		data = new Array(w * h);
		for (var i = 0; i < w * h; i++) data[i] = grid[i];
	}
	return data;
}

return thin;

})();
