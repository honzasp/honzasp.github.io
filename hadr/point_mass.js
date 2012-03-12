var PointMass = function(x, y) {
	this.forceX = 0;
	this.forceY = 0;
	this.posX = x;
	this.posY = y;
	this.oldX = x;
	this.oldY = y;
	this.invMass = 1 / 1;
};

PointMass.prototype = {

	gravity: function(force) {
		if(this.invMass != 0) {
			this.forceY = force / this.invMass;
		}
	},

	setStatic: function() {
		this.invMass = 0;
	},

	move: function(time) {
		var tempX = this.posX;
		var tempY = this.posY;
		this.posX += this.posX - this.oldX + this.forceX * time * time * this.invMass;
		this.posY += this.posY - this.oldY + this.forceY * time * time * this.invMass;
		this.oldX = tempX;
		this.oldY = tempY;
	},

	draw: function(ctx) {
		ctx.beginPath();
		ctx.arc(this.posX, this.posY, 2, 0, Math.PI * 2, true);
		ctx.fill();
	}

};

