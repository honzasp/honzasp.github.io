var Constraint = function(pointA, pointB) {
	this.pointA = pointA;
	this.pointB = pointB;

	var x = pointA.posX - pointB.posX;
	var y = pointA.posY - pointB.posY;
	this.restLength = Constraint.sqrt(x * x + y * y);
};

Constraint.sqrts = [];

Constraint.sqrt = function(num) {
	var i = Math.round(num / 2);

	if(!Constraint.sqrts[i]) {
		Constraint.sqrts[i] = Math.sqrt(num);
	}

	return Constraint.sqrts[i];
};

Constraint.prototype.satisfy = function() {
	var deltaX = this.pointA.posX - this.pointB.posX;
	var deltaY = this.pointA.posY - this.pointB.posY;
	var deltaLength = Constraint.sqrt(deltaX * deltaX + deltaY * deltaY);
	var diff = (deltaLength - this.restLength) / deltaLength;

	if(diff > 0) {
		this.pointA.posX -= deltaX * 0.5 * diff * this.pointA.invMass;
		this.pointA.posY -= deltaY * 0.5 * diff * this.pointA.invMass;
		this.pointB.posX += deltaX * 0.5 * diff * this.pointB.invMass;
		this.pointB.posY += deltaY * 0.5 * diff * this.pointB.invMass;
	}
};

Constraint.prototype.draw = function(ctx) {
	ctx.beginPath();
	ctx.moveTo(this.pointA.posX, this.pointA.posY);
	ctx.lineTo(this.pointB.posX, this.pointB.posY);
	ctx.stroke();
};
