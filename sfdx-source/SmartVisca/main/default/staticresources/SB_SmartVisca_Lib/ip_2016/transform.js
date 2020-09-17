var progressBar;
var progressValue;
function bar_pro(){
	var pBarDisp = document.getElementById('pBarDisp');
	var pBar = document.getElementById('pBar');
	if (!pBar) {
		pBar = document.createElement('div');
		pBar.id = 'pBar';
		pBar.style.textAlign = 'middle';
			var ntext = document.createTextNode('進行状況：');
			pBar.appendChild(ntext);
		pBarDisp.appendChild(pBar);
	}
	progressBar = document.getElementById('pb');
	if (!progressBar) {
		progressBar = document.createElement('progress');
		progressBar.id = 'pb';
		progressBar.value = 0;
		progressBar.setAttribute("max", 100);
		progressBar.style.textAlign = 'middle';
		pBar.appendChild(progressBar);
	}
	progressValue = document.getElementById('pv');
	if (!progressValue) {
		progressValue = document.createElement('span');
		progressValue.id = 'pv';
		progressValue.style.color = '#00b200';
			var ntext = document.createTextNode('0');
			progressValue.appendChild(ntext);
		pBar.appendChild(progressValue);
	}
}
function updateProgress(newValue) {
	if(newValue > 100){
		progressbarRemove();
		return;
	}
	progressBar.value = newValue;
	progressValue.innerHTML = "　" + newValue + "%";
	setTimeout(function(){updateProgress(newValue + 5);}, 1000);
}
function progressbarStart() {
	bar_pro();
	updateProgress(0);
}
function progressbarRemove() {
	var pBar = document.getElementById('pBar');
	if(pBar)pBar.parentNode.removeChild(pBar);
}
var print_img_id = 'print_img';
var print_DataURL_id = 'print_DataURL';
function hiddenImage(img, w, h) {
	var c2 = document.getElementById("canvas_h");
	var ctx2 = c2.getContext("2d");
		c2.width = w * BAIRITU;
		c2.height = h * BAIRITU;
	ctx2.drawImage(img, 0, 0, w * BAIRITU, h * BAIRITU);
}
function loadTransImage(img, x, y) {
	document.getElementById("upload").style.display = "none";
	var node = document.getElementById("canvas_t");
	if (node) 	document.getElementById('canvas_t').parentNode.removeChild(document.getElementById('canvas_t'));
	var w = img.width / WIDTH;
	var h = img.height / HEIGHT;
	if (w >= h && w > 1){
		h = img.height / w;
		w = WIDTH;
	}
	else if (h > w && h > 1){
		w = img.width / h;
		h = HEIGHT;
	}
	else{
		w = img.width;
		h = img.height;
	}
	w = marume(w, 0);
	h = marume(h, 0);
	if(w == 0 || h == 0)return;
	var canvas = document.getElementById('canvas');
	if (!canvas) {
		canvas = document.createElement('canvas');
		canvas.id = 'canvas';
		document.getElementById('take_img').appendChild(canvas);
	}
	var ctx = canvas.getContext('2d');
	canvas.width = w;
	canvas.height = h;
	ctx.drawImage(img, x, y, w, h);
	var ImageData = ctx.getImageData(0, 0, w, h);
	hiddenImage(img, w, h);
	document.getElementById("treat").style.display = "";
	quality(ImageData.data, w, h);
	Xdata = ImageData;
	return ImageData;
}
var Xdata;
function quality(data, w, h) {
	var n = w * 40;
	var gray = new Array(n);
	for (var i = 0; i < n * 4 ; i += 4) {
		var R = data[i + 0];
		var G = data[i + 1];
		var B = data[i + 2];
		var A = data[i + 3];
		gray[i / 4] = (0.298912 * R + 0.586611 * G + 0.114478 * B) * A / 255 | 0;
	}
	var a0 = new Array();
	for (var i = 0; i < 20; i++) {
		for (var j = 0; j < 20; j++) {
			var v = (i + 10) * w + (j + 10);
			a0.push(gray[v]);
		}
	}
	var a1 = new Array();
	for (var i = 0; i < 20; i++) {
		for (var j = 0; j < 20; j++) {
			var v = (i + 10) * w + (j + Math.floor(w / 2) - 10);
			a1.push(gray[v]);
		}
	}
	var a2 = new Array();
	for (var i = 0; i < 20; i++) {
		for (var j = 0; j < 20; j++) {
			var v = (i + 10) * w + (j + w - 30);
			a2.push(gray[v]);
		}
	}
	var v0 = standard_deviation(a0);
	var v1 = standard_deviation(a1);
	var v2 = standard_deviation(a2);
console.log("v0 " + JSON.stringify(v0));
console.log("v1 " + JSON.stringify(v1));
console.log("v2 " + JSON.stringify(v2));
}
function transformationMain() {
ImageData = Xdata;
	var w = ImageData.width;
	var h = ImageData.height;
	var data = detect(ImageData, w, h);
	getSVGdata(data, w, h);
	var data = dataTrans(meishiV);
	start_homo = searchRect(data, w, h);
	if (start_homo == null) {
alert("\n\nThis picture is not correct.\n\nPlese, take a picture.\n\n");
		document.getElementById("treat").style.display = "none";
		return;
	}
	app = new HomographyApp();
	if (w > h) draw_homo('canvas_h', 'canvas_t', start_homo, meishiSy);
	else draw_homo('canvas_h', 'canvas_t', start_homo, meishiSt);
	document.getElementById("treat").style.display = "none";
	document.getElementById("upload").style.display = "";
}
function draw_homo(srcid, dstid, srcPosition, dstPosition) {
	var canvas = document.getElementById(srcid);
	if (!canvas) {
		canvas = document.createElement('canvas');
		canvas.id = srcid;
		document.getElementById('take_img').appendChild(canvas);
	}
	var ctx = canvas.getContext('2d');
	w = canvas.width;
	h = canvas.height;
	var start_homo = srcPosition;
	var imageData_homo = ctx.getImageData(0, 0, w, h);
	if (w > h)
		app.initRender(dstid, imageData_homo, w, h, 600, 360, start_homo);
	else
		app.initRender(dstid, imageData_homo, h, w, 360, 600, start_homo);
	app.transRender(dstPosition);
	document.getElementById('canvas').parentNode.removeChild(document.getElementById('canvas'));
}
function getPoint4(w, h) {
	var p = [
		[randGen(0, w / 2 * 0.8), randGen(0, h / 2 * 0.8)],
		[randGen(w / 2 * 0.8, w), randGen(0, h / 2 * 0.8)],
		[randGen(w / 2 * 1.2, w), randGen(h / 2 * 1.2, h)],
		[randGen(0, w / 2 * 0.8), randGen(h / 2 * 1.2, h)]
	];
	return p;
}
function dataTrans(d) {
	var data = new Array();
	for (var i = 0; i < d.data.length; i++) {
		var d_d = d.data[i];
		var d_d0 = d_d.data;
		for (var j = 0; j < d_d0.length; j++) {
			if (d_d0[j].c != 'M') continue
				data.push({x: d_d0[j].d[0], y: d_d0[j].d[1], a: d_d0[j].a, b: d_d0[j].b, di: d_d0[j].di, tox: d_d0[j].d[2], toy: d_d0[j].d[3]});
		}
	}
	return data;
}
var AT, AB, AR, AL;
var nb = 5;
function searchRect(data, w, h) {
	AT = [];
	AB = [];
	AR = [];
	AL = [];
	var wH = w / 2;
	var hH = h / 2;
	var wn = Math.floor(w / nb);
	var hn = Math.floor(h / nb);
	var rt = new Array();
	var rb = new Array();
	var rr = new Array();
	var rl = new Array();
	for (var i = 0;  i < wn; i++) {
		rb[i] = {x: -9999, y: -9999};
		rt[i] = {x: 9999, y: 9999};
	}
	for (var i = 0;  i < hn; i++) {
		rr[i] = {x: -9999, y: -9999};
		rl[i] = {x: 9999, y: 9999};
	}
	for (var j = 1; j < wn - 1; j++) {
		var x = j * nb;
		for (var i = 0; i < data.length; i++) {
			var cr = cross(1, 0, -x, -data[i].a, 1, -data[i].b);
			if (cr) {
				if (!checkInclude(data[i].x, data[i].y, data[i].tox, data[i].toy, cr[0], cr[1])) continue;
				if (rb[j].y < cr[1]) {
					if (data[i].y > hH) {
						rb[j] = clone(data[i]);
						rb[j]["cx"] = cr[0];
						rb[j]["cy"] = cr[1];
					}
				}
				if (rt[j].y > cr[1]) {
					if (data[i].y < hH) {
						rt[j] = clone(data[i]);
						rt[j]["cx"] = cr[0];
						rt[j]["cy"] = cr[1];
					}
				}
			}
		}
	}
	for (var j = 1; j < hn - 1; j++) {
		var y = j * nb;
		for (var i = 0; i < data.length; i++) {
			var cr = cross(0, 1, -y, -data[i].a, 1, -data[i].b);
			if (cr) {
				if (!checkInclude(data[i].x, data[i].y, data[i].tox, data[i].toy, cr[0], cr[1])) continue;
				if (rr[j].x < cr[0]) {
					if (data[i].x > wH) {
						rr[j] = clone(data[i]);
						rr[j]["cx"] = cr[0];
						rr[j]["cy"] = cr[1];
					}
				}
				if (rl[j].x > cr[0]) {
					if (data[i].x < wH) {
						rl[j] = clone(data[i]);
						rl[j]["cx"] = cr[0];
						rl[j]["cy"] = cr[1];
					}
				}
			}
		}
	}
	var cdt = findLine("rt", rt, w, h);
	var cdb = findLine("rb", rb, w, h);
	var cdr = findLine("rr", rr, w, h);
	var cdl = findLine("rl", rl, w, h);
		var ct = cross(0, 1,    0, -AT[0], 1, -AT[1]);
		var cb = cross(0, 1, -HEIGHT, -AB[0], 1, -AB[1]);
		var c0 = cross(1, 0,    0, -AT[0], 1, -AT[1]);
		var c1 = cross(1, 0, -WIDTH, -AT[0], 1, -AT[1]);
		var c0 = cross(1, 0,    0, -AT[0], 1, -AT[1]);
		var c1 = cross(1, 0, -WIDTH, -AT[0], 1, -AT[1]);
		c0 = cross(1, 0,    0, -AB[0], 1, -AB[1]);
		c1 = cross(1, 0, -WIDTH, -AB[0], 1, -AB[1]);
		c0 = cross(0, 1,    0, -AR[0], 1, -AR[1]);
		c1 = cross(0, 1, -HEIGHT, -AR[0], 1, -AR[1]);
		c0 = cross(0, 1,    0, -AL[0], 1, -AL[1]);
		c1 = cross(0, 1, -HEIGHT, -AL[0], 1, -AL[1]);
	var p0 = cross(-AT[0], 1, -AT[1], -AL[0], 1, -AL[1]);
	var p1 = cross(-AT[0], 1, -AT[1], -AR[0], 1, -AR[1]);
	var p2 = cross(-AB[0], 1, -AB[1], -AR[0], 1, -AR[1]);
	var p3 = cross(-AB[0], 1, -AB[1], -AL[0], 1, -AL[1]);
console.log("p0=" + p0[0] + " " + p0[1]);
console.log("p1=" + p1[0] + " " + p1[1]);
console.log("p2=" + p2[0] + " " + p2[1]);
console.log("p3=" + p3[0] + " " + p3[1]);
	var thr = 15
	if (p0[0] < -thr || p3[0] < -thr) return null;
	if (p1[0] > w + thr || p2[0] > w + thr) return null;
	if (p0[1] < -thr || p1[1] < -thr) return null;
	if (p2[1] > h + thr || p3[1] > h + thr) return null;
	p0[0] *= BAIRITU;
	p0[1] *= BAIRITU;
	p1[0] *= BAIRITU;
	p1[1] *= BAIRITU;
	p2[0] *= BAIRITU;
	p2[1] *= BAIRITU;
	p3[0] *= BAIRITU;
	p3[1] *= BAIRITU;
	return [p0, p1, p2, p3];
}
Array.prototype.average = function() {
	var array_length, value, i;
	array_length = this.length;
	value = 0;
	for (i = 0; i < array_length; i++) {
		value += this[i];
	}
	return value / array_length;
}
Array.prototype.median = function() {
	var array_length, value, mid;
	array_length = this.length;
	new_array = this.slice(0);
	new_array.sort(function(a, b) {
		return a - b;
	});
	mid = Math.floor(array_length / 2);
	if (array_length % 2 == 1) {
		return new_array[mid];
	} else {
		return (new_array[mid - 1] + new_array[mid]) / 2;
	}
}
Array.prototype.mode = function() {
	var array_length, count, i, max, value;
	array_length = this.length;
	count = [];
	for (i = 0; i < array_length; i++) {
		if (count[this[i]]) {
			count[this[i]] ++;
		} else {
			count[this[i]] = 1;
		}
	}
	max = 0;
	for (i = 0; i < count.length; i++) {
		if (count[i] > max) {
			max = count[i];
			value = i;
		}
	}
	if (value > 1) {
		return value;
	} else {
		return "Error";
	}
}
function findLine(mode, r, w, h) {
	var cx = w /2;
	var cy = h / 2;
	var dist0 = new Array();
	var dt0 = new Array();
	for (var i = 0; i < r.length; i++) {
		if (!r[i].a) continue;
		var nn = Math.ceil(r[i].di / nb);
		var d = Math.floor(distance(r[i].a, r[i].b, cx, cy));
		for (var j = 0; j < nn; j++) {
			dist0.push(r[i]);
			dt0.push(d);
		}
	}
	var av = dt0.average();
	var ac = dt0.median();
	var am = dt0.mode();
	if (ac != am) {
		var dist1 = new Array();
		var dt1 = new Array();
		for (var i = 0; i < dt0.length; i++) {
			if (dt0[i] > av) {
				dist1.push(dist0[i]);
				dt1.push(dt0[i]);
			}
		}
		am = dt1.mode();
		dist0 = clone(dist1);
		dt0 = clone(dt1);
	}
	var out = null;
	for (var i = 0; i < dt0.length; i++ ) {
		if (dt0[i] == am) {
try {
			out = [dist0[i].a, dist0[i].b];
			if (mode == "rt")		AT = [dist0[i].a, dist0[i].b];
			else if (mode == "rb")  AB = [dist0[i].a, dist0[i].b];
			else if (mode == "rr")  AR = [dist0[i].a, dist0[i].b];
			else if (mode == "rl")  AL = [dist0[i].a, dist0[i].b];
			return dist0;
} catch(e) {
}
		}
	}
	return out;
}
function marume(a, n) {
	var p = Math.pow(10, n);
	return Math.round(a * p) / p;
}
function checkInclude(ax, ay, bx, by, cx, cy) {
	if (ax < bx) {
		if (cx >= ax && cx <= bx) ;
		else return false;
	}
	else {
		if (cx >= bx && cx <= ax) ;
		else return false;
	}
	if (ay < by) {
		if (cy >= ay && cy <= by) return true;
		else return false;
	}
	else {
		if (cy >= by && cy <= ay) return true;
		else return false;
	}
}
function drawSegment(data, width, color) {
	var col = ["red", "green", "blue"];
	var canvas = document.getElementById('canvas');
	var context = canvas.getContext('2d');
	for (var i = 0; i < data.length; i++) {
		context.beginPath();
		context.lineWidth = width;
		var color = col[i % 3];
		context.strokeStyle = color;
			context.moveTo(data[i].x, data[i].y);
			context.lineTo(data[i].tox, data[i].toy);
		context.stroke();
	}
}
function ObjArraySort(ary, key, order) {
	var reverse = 1;
	if(order && order.toLowerCase() == "desc") reverse = -1;
	ary.sort(function(a, b) {
		if(a[key] < b[key])
			return -1 * reverse;
		else if(a[key] == b[key])
			return 0;
		else
			return 1 * reverse;
	});
}
function distance(a, b, x, y) {
	dist = Math.abs(-a * x + y - b) / Math.sqrt(a * a + 1);
	return dist;
}
function cross(a1, b1, c1, a2, b2, c2) {
	var A = new Array();
	 A[0] = new Array();
	 A[1] = new Array();
	var x = new Array();
	var D, eps = 0.000001, sw = 0;
	D = a1 * b2 - a2 * b1;
	if (Math.abs(D) > eps) {
		A[0][0] =  b2 / D;
		A[0][1] = -b1 / D;
		A[1][0] = -a2 / D;
		A[1][1] =  a1 / D;
		x[0]    = -A[0][0] * c1 - A[0][1] * c2;
		x[1]    = -A[1][0] * c1 - A[1][1] * c2;
		sw      = 1;
	}
	if (sw == 0) x = null;
	return x;
}
function drawLine(context, x1, y1, x2, y2, width, color) {
	context.beginPath();
	context.lineWidth = width;
	context.strokeStyle = color;
	context.moveTo(x1, y1);
	context.lineTo(x2, y2);
	context.stroke();
}
function drawRect(context, x, y, width, height, color) {
	context.strokeStyle = color;
	context.strokeRect(x, y, width, height);
}
function isIntersection(p1, p2, p3, p4) {
	var p = intersectionPoint(p1, p2, p3, p4);
	return p &&
		(p.x - p3.x) * (p.x - p4.x) + (p.y - p3.y) * (p.y - p4.y) < 0 &&
		(p.x - p1.x) * (p.x - p2.x) + (p.y - p1.y) * (p.y - p2.y) < 0;
}
function intersectionPoint(p1, p2, p3, p4) {
	return intersectionPoint$8(p1.x, p1.y, p2.x, p2.y, p3.x, p3.y, p4.x, p4.y);
}
function intersectionPoint$8(p1x, p1y, p2x, p2y, p3x, p3y, p4x, p4y) {
	var ax = p2x - p1x;
	var ay = p2y - p1y;
	var bx = p4x - p3x;
	var by = p4y - p3y;
	var cx = p3x - p1x;
	var cy = p3y - p1y;
	var cross1 = bx * cy - by * cx;
	var cross2 = bx * ay - by * ax;
	if (!cross2) return null;
	var t = cross1 / cross2;
	return {
		x: p1x + ax * t,
		y: p1y + ay * t
	};
}
