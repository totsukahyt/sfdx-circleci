/*
	ó÷äsê¸íäèo
		http://jsdo.it/TKC.TNK/ea9N
*/

function detect(origin, width, height) {
	_edge = null;
	var result = detectEdge(origin, width, height);
	var imageData = {};
	imageData.width = width;
	imageData.height = height;
	imageData.data = new Array();
	for (var i=0; i < result.length; i++) {
		if (result[i]) {
			imageData.data[i * 4 + 0] = 255;
			imageData.data[i * 4 + 1] = 255;
			imageData.data[i * 4 + 2] = 255;
			imageData.data[i * 4 + 3] = 255;
		} else {
			imageData.data[i * 4 + 0] = 0;
			imageData.data[i * 4 + 1] = 0;
			imageData.data[i * 4 + 2] = 0;
			imageData.data[i * 4 + 3] = 255;
		}
	}
	return imageData;
}
var _edge = null;
function detectEdge(origin, width, height) {
	var result = new Array(origin.data.length / 4);
	var gray = grayScale(origin.data);
	if (_edge !== null) {
		var edge = range(150, 50);
	}else{
		var edge = filterCanny(gray, 150, 50, width, height);
	}
	result = edge;
	return result;
}
function grayScale(data) {
	var gray = new Array(data.length/4);
	for (var i=0; i<data.length; i+=4) {
		var R = data[i+0];
		var G = data[i+1];
		var B = data[i+2];
		var A = data[i+3];
		gray[i/4] = (0.298912*R + 0.586611*G + 0.114478*B)*A/255|0;
	}
	return gray;
}
function matrix(data, filter, width, height) {
	var result = new Array(data.length);
	var sizeY  = filter.length;
	var sizeX  = filter[0].length;
	for (var i=0; i < data.length; i++) {
		var v = 0;
		for (var x=0; x < sizeX; x++) {
			for (var y=0; y<sizeY; y++) {
				var hx = x - sizeX / 2 | 0;
				var hy = y - sizeY / 2 | 0;
				var index = i+width * hy + hx;
				if (index % width < sizeX / 2 | 0) index += (sizeX / 2 | 0);
				if (index % width >= width - sizeX / 2 | 0) index -= (sizeX / 2 | 0);
				if (index < width * (sizeY / 2 | 0)) index += width*(sizeY / 2 | 0);
				if (index >= data.length - width * (sizeY / 2 | 0)) index -= width*(sizeY / 2 | 0);
				v += data[index] * filter[y][x];
			}
		}
		if (v < 0)   v = 0;
		if (v > 255) v = 255;
		result[i] = v | 0;
	}
	return result;
}
function filterCanny(data, ht, lt, width, height) {
console.log("canny " + ht + " " + lt + " " + data.length);
	var g  = [[2,4,5,4,2], [4,9,12,9,4], [5,12,15,12,5], [4,9,12,9,4], [2,4,5,4,2]]
	for (var i=0; i<5; i++) for (var j=0; j<5; j++) g[i][j] /= 159;
	var gaussian = matrix(data, g, width, height);
	var sobX = [[-1, 0, 1], [-2, 0, 2], [-1, 0, 1]];
	var sobY = [[1, 2, 1], [0, 0, 0], [-1, -2, -1]];
	var sobel = new Array(gaussian.length);
	for (var i=0; i < gaussian.length; i++) {
		var gx = 0;
		var gy = 0;
		for (var x=-1; x <= 1; x++) {
			for (var y=-1; y <= 1; y++) {
				var index = i + width * y + x;
				gx += gaussian[index]*sobX[y + 1][x + 1];
				gy += gaussian[index]*sobY[y + 1][x + 1];
			}
		}
		var G = Math.sqrt(gx * gx + gy * gy);
		var t = gy / gx;
		if (-0.4142 < t && t <= 0.4142) {
			sobel[i] = {s:G, t:0};
		}else if (0.4142 < t && t <= 2.4142) {
			sobel[i] = {s:G, t:1};
		}else if (-2.4142 < t && t < -0.4142) {
			sobel[i] = {s:G, t:3};
		}else{
			sobel[i] = {s:G, t:2};
		}
	}
	var edge = new Array(sobel.length);
	for (var i=0; i < sobel.length; i++) edge[i] = sobel[i].s;
	var result = new Array(edge.length);
	for (var i=0; i<edge.length; i++) {
		if (edge[i] > ht) {
			result[i] = 255;
		}else if (edge[i] < lt) {
			result[i] = 0;
		}else{
			if (edge[i-1] || edge[i+1] || edge[i-width] || edge[i+width] || edge[i-1+width] || edge[i+1+width] || edge[i-1-width] || edge[i+1-width]) {
				result[i] = 255;
			}else{
				result[i] = 0;
			}
		}
	}
	var i = 0;
	for (var j = 0; j < width; j++) {
		var c = i * width + j;
		result[c] = 0;
	}
	i = 1;
	for (var j = 0; j < width; j++) {
		var c = i * width + j;
		result[c] = 0;
	}
	i = height - 2;
	for (var j = 0; j < width; j++) {
		var c = i * width + j;
		result[c] = 0;
	}
	i = height - 1;
	for (var j = 0; j < width; j++) {
		var c = i * width + j;
		result[c] = 0;
	}
	var j = 0;
	for (var i = 0; i < height; i++) {
		var c = i * width + j;
		result[c] = 0;
	}
	j = 1;
	for (var i = 0; i < height; i++) {
		var c = i * width + j;
		result[c] = 0;
	}
	j = width - 2;
	for (var i = 0; i < height; i++) {
		var c = i * width + j;
		result[c] = 0;
	}
	j = width - 1;
	for (var i = 0; i < height; i++) {
		var c = i * width + j;
		result[c] = 0;
	}
	edge = dilationData(1, result, width, height, 255);
	var th = new thin(8, edge, width, height);
	th.nwg_method(1, 1, width - 1, height - 1);
	result = th.getData();
	_edge = edge;
console.log("canny end");
	return result;
}
function range(ht, lt) {
	var edge = _edge;
	var result = new Array(edge.length);
	for (var i=0; i<edge.length; i++) {
		if (edge[i] > ht) {
			result[i] = 255;
		}else if (edge[i] < lt) {
			result[i] = 0;
		}else{
			if (edge[i-1] || edge[i+1] || edge[i-width] || edge[i+width] || edge[i-1+width] || edge[i+1+width] || edge[i-1-width] || edge[i+1-width]) {
				result[i] = 255;
			}else{
				result[i] = 0;
			}
		}
	}
	return result;
}
function dilationData(ne, data, width, height, color) {
	var srcData = new Array(data.length);
	var dstData = new Array(data.length);
	for (var i = 0; i < data.length; i++) {
		srcData[i] = data[i];
		dstData[i] = data[i];
	}
	for (var k = 0; k < ne; k++) {
		for (var i = 1; i < height - 1; i++) {
			for (var j = 1; j < width - 1; j++) {
				var c = i * width + j;
				var v = srcData[c];
					if (srcData[c - width - 1] == color) dstData[c] = color;
					if (srcData[c - width    ] == color) dstData[c] = color;
					if (srcData[c - width + 1] == color) dstData[c] = color;
					if (srcData[c         - 1] == color) dstData[c] = color;
					if (srcData[c         + 1] == color) dstData[c] = color;
					if (srcData[c + width - 1] == color) dstData[c] = color;
					if (srcData[c + width    ] == color) dstData[c] = color;
					if (srcData[c + width + 1] == color) dstData[c] = color;
					if (srcData[c] == color) dstData[c] = color;
			}
		}
		for (var i = 0; i < data.length; i++) {
			srcData[i] = dstData[i];
		}
	}
	return dstData;
}
