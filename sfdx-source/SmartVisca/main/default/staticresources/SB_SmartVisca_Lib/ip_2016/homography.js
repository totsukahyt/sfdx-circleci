/*
	テクスチャマッピング入門 射影変換(ホモグラフィ)
		http://jsdo.it/yaju3D/zUk5
*/

var Point = (function () {
	function Point(x, y) {
		this.x = x;
		this.y = y;
	}
	return Point;
})();
var HomographyApp = (function () {
	function HomographyApp() {
		var _this = this;
		this.offset = new Point(256, 256);
		this.origin = [];
		this.markers = [];
		this.vertexs = [];
	}
	HomographyApp.prototype.initRender = function (id, imageData, w, h, W, H, org) {
		this.width = w;
		this.height = h;
		var canvas = document.getElementById(id);
		if (!canvas) {
			canvas = document.createElement("canvas");
			canvas.id = id;
			document.getElementById('take_img').appendChild(canvas);
		}
		this.ctx = canvas.getContext('2d');
		canvas.width = W;
		canvas.height = H;
		this.input = imageData;
		this.ctx.putImageData(this.input, 0, 0);
		this.origin = org;
	};
	// initRender を修正して、CANVAS は オンメモリのを使う。
	HomographyApp.prototype.initRender2 = function (canvas, imageData, w, h, W, H, org) {
		this.width = w;
		this.height = h;
		this.ctx = canvas.getContext('2d');
		canvas.width = W;
		canvas.height = H;
		this.input = imageData;
		this.ctx.putImageData(this.input, 0, 0);
		this.origin = org;
	};
	HomographyApp.prototype.ReSize = function (imageData, w, h, W, H) {
		var data = new Array();
		for (var i = 0; i < w * h; i++) {
			data[i] = imageData.data[i];
		}
		imageData.data = new Array();
		for (var i = 0; i < H; i++) {
			for (var j = 0; i < W; j++) {
				var k = (i * w + j) * 4;
				imageData.data[k    ] = data[k    ];
				imageData.data[k + 1] = data[k + 1];
				imageData.data[k + 2] = data[k + 2];
				imageData.data[k + 3] = data[k + 3];
			}
		}
		return imageData;
	};
	HomographyApp.prototype.rotate2d = function (x, y, rad) {
		var pt = new Point();
		pt.x = Math.cos(rad) * x - Math.sin(rad) * y;
		pt.y = Math.sin(rad) * x + Math.cos(rad) * y;
		return pt;
	};
	HomographyApp.prototype.getParam = function (src, dest) {
		var Z = function (val) { return val == 0 ? 0.5 : val; };
		var X1 = Z(src[0][0]);
		var X2 = Z(src[1][0]);
		var X3 = Z(src[2][0]);
		var X4 = Z(src[3][0]);
		var Y1 = Z(src[0][1]);
		var Y2 = Z(src[1][1]);
		var Y3 = Z(src[2][1]);
		var Y4 = Z(src[3][1]);
		var x1 = Z(dest[0][0]);
		var x2 = Z(dest[1][0]);
		var x3 = Z(dest[2][0]);
		var x4 = Z(dest[3][0]);
		var y1 = Z(dest[0][1]);
		var y2 = Z(dest[1][1]);
		var y3 = Z(dest[2][1]);
		var y4 = Z(dest[3][1]);
		var tx = mat4.create(new Float32Array([
			X1, Y1, -X1 * x1, -Y1 * x1,
			X2, Y2, -X2 * x2, -Y2 * x2,
			X3, Y3, -X3 * x3, -Y3 * x3,
			X4, Y4, -X4 * x4, -Y4 * x4
		]));
		mat4.inverse(tx);
		var kx1 = tx[0] * x1 + tx[1] * x2 + tx[2] * x3 + tx[3] * x4;
		var kc1 = tx[0] + tx[1] + tx[2] + tx[3];
		var kx2 = tx[4] * x1 + tx[5] * x2 + tx[6] * x3 + tx[7] * x4;
		var kc2 = tx[4] + tx[5] + tx[6] + tx[7];
		var kx3 = tx[8] * x1 + tx[9] * x2 + tx[10] * x3 + tx[11] * x4;
		var kc3 = tx[8] + tx[9] + tx[10] + tx[11];
		var kx4 = tx[12] * x1 + tx[13] * x2 + tx[14] * x3 + tx[15] * x4;
		var kc4 = tx[12] + tx[13] + tx[14] + tx[15];
		var ty = mat4.create(new Float32Array([
			X1, Y1, -X1 * y1, -Y1 * y1,
			X2, Y2, -X2 * y2, -Y2 * y2,
			X3, Y3, -X3 * y3, -Y3 * y3,
			X4, Y4, -X4 * y4, -Y4 * y4
		]));
		mat4.inverse(ty);
		var ky1 = ty[0] * y1 + ty[1] * y2 + ty[2] * y3 + ty[3] * y4;
		var kf1 = ty[0] + ty[1] + ty[2] + ty[3];
		var ky2 = ty[4] * y1 + ty[5] * y2 + ty[6] * y3 + ty[7] * y4;
		var kf2 = ty[4] + ty[5] + ty[6] + ty[7];
		var ky3 = ty[8] * y1 + ty[9] * y2 + ty[10] * y3 + ty[11] * y4;
		var kf3 = ty[8] + ty[9] + ty[10] + ty[11];
		var ky4 = ty[12] * y1 + ty[13] * y2 + ty[14] * y3 + ty[15] * y4;
		var kf4 = ty[12] + ty[13] + ty[14] + ty[15];
		var det_1 = kc3 * (-kf4) - (-kf3) * kc4;
		if(det_1 == 0) { det_1 = 0.0001; }
		det_1 = 1 / det_1;
		var param = new Array(8);
		var C = (-kf4 * det_1) * (kx3 - ky3) + (kf3 * det_1) * (kx4 - ky4);
		var F = (-kc4 * det_1) * (kx3 - ky3) + (kc3 * det_1) * (kx4 - ky4);
		param[2] = C;
		param[5] = F;
		param[6] = kx3 - C * kc3;
		param[7] = kx4 - C * kc4;
		param[0] = kx1 - C * kc1;
		param[1] = kx2 - C * kc2;
		param[3] = ky1 - F * kf1;
		param[4] = ky2 - F * kf2;
		return param;
	};
	HomographyApp.prototype.computeH = function (src, dest, min, max) {
		for(var i = 0; i < dest.length; i++) {
			var x = dest[i][0];
			var y = dest[i][1];
			if(x > max.x) { max.x = x; }
			if(y > max.y) { max.y = y; }
			if(x < min.x) { min.x = x; }
			if(y < min.y) { min.y = y; }
		}
		for(var i = 0; i < dest.length; i++) {
			dest[i][0] -= min.x;
			dest[i][1] -= min.y;
		}
		var param = this.getParam(src, dest);
		var mx = mat4.create(new Float32Array([
			param[0], param[1], param[2], 0,
			param[3], param[4], param[5], 0,
			param[6], param[7], 1, 0,
				   0, 0, 0, 1
		]));
		mat4.inverse(mx);
		var inv_param = new Array(9);
		inv_param[0] = mx[0];
		inv_param[1] = mx[1];
		inv_param[2] = mx[2];
		inv_param[3] = mx[4];
		inv_param[4] = mx[5];
		inv_param[5] = mx[6];
		inv_param[6] = mx[8];
		inv_param[7] = mx[9];
		inv_param[8] = mx[10];
		return inv_param;
	};
	HomographyApp.prototype.drawNearest = function (ctx, param, sx, sy, w, h) {
		var imgW = this.width;
		var imgH = this.height;
		var output = ctx.createImageData(w, h);
		for(var i = 0; i < h; ++i) {
			for(var j = 0; j < w; ++j) {
				var tmp = j * param[6] + i * param[7] + param[8];
				var tmpX = (j * param[0] + i * param[1] + param[2]) / tmp;
				var tmpY = (j * param[3] + i * param[4] + param[5]) / tmp;
				var floorX = (tmpX + 0.5) | 0;
				var floorY = (tmpY + 0.5) | 0;
				if(floorX >= 0 && floorX < imgW && floorY >= 0 && floorY < imgH) {
					var pixelData = this.getPixel(this.input, floorX, floorY, imgW, imgH);
					var R = pixelData.R;
					var G = pixelData.G;
					var B = pixelData.B;
					this.setPixel(output, j, i, R, G, B, 255);
				}
			}
		}
		ctx.putImageData(output, sx, sy);
	};
	HomographyApp.prototype.drawBilinear = function (ctx, param, sx, sy, w, h) {
		var imgW = this.width;
		var imgH = this.height;
		var output = ctx.createImageData(w, h);
		for(var i = 0; i < h; ++i) {
			for(var j = 0; j < w; ++j) {
				var tmp = j * param[6] + i * param[7] + param[8];
				var tmpX = (j * param[0] + i * param[1] + param[2]) / tmp;
				var tmpY = (j * param[3] + i * param[4] + param[5]) / tmp;
				var floorX = tmpX | 0;
				var floorY = tmpY | 0;
				if(floorX >= 0 && floorX < imgW && floorY >= 0 && floorY < imgH) {
					var dx = tmpX - floorX;
					var dy = tmpY - floorY;
					var rgb00 = this.getPixel(this.input, floorX, floorY, imgW, imgH);
					var rgb10 = this.getPixel(this.input, floorX + 1, floorY, imgW, imgH);
					var rgb01 = this.getPixel(this.input, floorX, floorY + 1, imgW, imgH);
					var rgb11 = this.getPixel(this.input, floorX + 1, floorY + 1, imgW, imgH);
					var r0 = (rgb00.R * (1 - dx)) + (rgb10.R * dx);
					var r1 = (rgb01.R * (1 - dx)) + (rgb11.R * dx);
					var R = (r0 * (1 - dy) + r1 * dy) | 0;
					var g0 = (rgb00.G * (1 - dx)) + (rgb10.G * dx);
					var g1 = (rgb01.G * (1 - dx)) + (rgb11.G * dx);
					var G = (g0 * (1 - dy) + g1 * dy) | 0;
					var b0 = (rgb00.B * (1 - dx)) + (rgb10.B * dx);
					var b1 = (rgb01.B * (1 - dx)) + (rgb11.B * dx);
					var B = (b0 * (1 - dy) + b1 * dy) | 0;
					this.setPixel(output, j, i, R, G, B, 255);
				}
			}
		}
		ctx.putImageData(output, sx, sy);
	};
	HomographyApp.prototype.getPixel = function (imageData, x, y, w, h) {
		if(x == w) { x = w - 1; }
		if(y == h) { y = h - 1; }
		var pixels = imageData.data;
		var index = (imageData.width * y * 4) + (x * 4);
		if(index < 0 || index + 3 > pixels.length) { return undefined; }
		return { R: pixels[index + 0], G: pixels[index + 1], B: pixels[index + 2], A: pixels[index + 3] };
	};
	HomographyApp.prototype.setPixel = function (imageData, x, y, r, g, b, a) {
		var pixels = imageData.data;
		var index = (imageData.width * y * 4) + (x * 4);
		if(index < 0 || index + 3 > pixels.length) { return false; }
		pixels[index + 0] = r;
		pixels[index + 1] = g;
		pixels[index + 2] = b;
		pixels[index + 3] = a;
		return true;
	};
	HomographyApp.prototype.drawInfo = function (pt) {
		for(var i = 0; i < pt.length; i++) {
			var elm = document.getElementById("i" + (i + 1));
			elm.innerText = 'Anchor' + (i + 1) + '(' + pt[i].x + ',' + pt[i].y + ')';
		}
	};
	HomographyApp.prototype.transRender = function (markers) {
		var min = {x:0, y:0};
		var max = {x:0, y:0};
		var pt = [];
		this.markers = markers;
		var inv_param = this.computeH(this.origin, this.markers, min, max);
		var w = max.x - min.x;
		var h = max.y - min.y;
		this.ctx.clearRect(0, 0, this.ctx.canvas.width, this.ctx.canvas.height);
		this.drawNearest(this.ctx, inv_param, min.x, min.y, w, h);
	};
	return HomographyApp;
})();
