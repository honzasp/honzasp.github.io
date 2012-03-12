var Cloth = {
	stepTime: 1000 / 20, // ms
	pointsNum: 30,
	gravity: 30,
	speed: 1,

	init: function(canvas) {
		this.canvas = canvas;
		this.context = this.canvas[0].getContext('2d');

		this.pointMasses = [];

		this.width = parseInt(this.canvas[0].width);
		this.height = parseInt(this.canvas[0].height);

		/* create point masses */
		var padding = 20;
		var space = (this.width - 2 * padding) / this.pointsNum;

		this.pointMasses = [];
		for(var a = 0; a != this.pointsNum; a++) {
			for(var b = 0; b != this.pointsNum; b++) {
				var pointMass = new PointMass(padding + a * space, padding + b * space);
				pointMass.gravity(this.gravity);
				this.pointMasses[b * this.pointsNum + a] = pointMass;
			}
		}

		/* connect them with a constraints */
		this.constraints = [];

		for(var b = 0; b != this.pointsNum; b++) {
			for(var a = 1; a != this.pointsNum; a++) {
				var constraint = new Constraint(
					this.pointMasses[b * this.pointsNum + a - 1],
					this.pointMasses[b * this.pointsNum + a]
				);
				this.constraints.push(constraint);
			}
		}

		for(var b = 1; b != this.pointsNum; b++) {
			for(var a = 0; a != this.pointsNum; a++) {
				var constraint = new Constraint(
					this.pointMasses[b * this.pointsNum + a],
					this.pointMasses[b * this.pointsNum + a - this.pointsNum]
				);
				this.constraints.push(constraint);
			}
		}

		/* delete random constraints */
		for(var i = 0; i != 0; i++) {
			var n = Math.round(Math.random() * this.constraints.length);
			this.constraints[n] = this.constraints.pop();
		}

		/* make the corner points static */
		this.pointMasses[0].setStatic();
		this.pointMasses[this.pointsNum - 1].setStatic();
		//this.pointMasses[this.pointsNum * this.pointsNum - 1].setStatic();
	},

	start: function() {
		var ths = this;
		setInterval(function() { ths.step(); }, this.stepTime);
	},

	step: function() {
		this.update(this.stepTime * this.speed / 1000);
		this.draw();
	},

	update: function(time) {
		for(var i = 0; i != this.pointMasses.length; i++) {
			this.pointMasses[i].gravity(this.gravity);
		}

		for(var i = 0; i != this.constraints.length; i++) {
			this.constraints[i].satisfy();
		}

		for(var i = 0; i != this.pointMasses.length; i++) {
			this.pointMasses[i].move(time);
		}
	},

	draw: function() {
		var ctx = this.context;
		ctx.clearRect(0, 0, this.width, this.height);
		ctx.fillStyle = "black";
		ctx.strokeStyle = "black";
		ctx.lineWidth = 0.5;

		/*
		for(var i = 0; i != this.pointMasses.length; i++) {
			this.pointMasses[i].draw(ctx);
		}
		*/

		for(var i = 0; i != this.constraints.length; i++) {
			this.constraints[i].draw(ctx);
		}
	},

	findNearest: function(x, y) {
		var nearestDist = -1;
		var nearest = null;

		for(var i = 0; i != this.pointMasses.length; i++) {
			var p = this.pointMasses[i];
			var dist = (x - p.posX) * (x - p.posX) + (y - p.posY) * (y - p.posY);
			if(nearestDist < 0 || dist < nearestDist) {
				nearestDist = dist;
				nearest = p;
			}
		}

		return nearest;
	},

	mousedown: function(x, y) {
		this.selectedPoint = this.findNearest(x, y);
		this.mousemove(x, y);
	},

	mousemove: function(x, y) {
		if(this.selectedPoint && this.selectedPoint.invMass != 0) {
			this.selectedPoint.posX = x;
			this.selectedPoint.posY = y;
		}
	},

	mouseup: function(x, y) {
		this.selectedPoint = null;
	}

};

$(document).ready(function() {
		Cloth.init($("#cloth"));
		$(document).mousedown(function(e) { Cloth.mousedown(e.pageX, e.pageY); });
		$(document).mousemove(function(e) { Cloth.mousemove(e.pageX, e.pageY); });
		$(document).mouseup(function(e) { Cloth.mouseup(e.pageX, e.pageY); });
		Cloth.start();
	});
