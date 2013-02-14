/* Makes explosion of object obj */
var Explosion = function(obj) {
	this.timeToLive = Explosion.timeToLive;
	this.x = obj.x;
	this.y = obj.y;
	this.alive = true;

	if(obj.klass) {
		this.force = obj.klass.explosionForce;
		this.size = obj.klass.explosionSize;
		this.crater = obj.klass.craterSize / 2;
		this.color = obj.klass.explosionColor;
	} else {
		this.force = Math.max(10, obj.player.score);
		this.size = this.force;
		this.crater = this.size / 2;
		this.color = obj.player.color;
	}

	/* make crater */
	for(var i = -this.crater; i <= this.crater; i++) {
		var y = obj.y + Math.sqrt(this.crater * this.crater - i * i);

		if(BattleJS.terrain[Math.round(obj.x + i)] < y) {
			BattleJS.terrain[Math.round(obj.x + i)] = y;
		}
	}
	BattleJS.drawTerrain();

	/* hit tanks */
	for(var i = 0; i != BattleJS.tanks.length; i++) {
		var tank = BattleJS.tanks[i];
		var dx = obj.x - tank.x;
		var dy = obj.y - tank.y;
		var d = Math.sqrt(dx*dx + dy*dy);

		if(d < this.size) {
			tank.hit(obj, ((this.size - d) / this.size) * this.force);
		}
	}
};

Explosion.timeToLive = 0.5;

Explosion.prototype = {

	update: function(time) {
		this.timeToLive -= time;

		if(this.timeToLive <= 0) {
			this.alive = false;
		}
	},

	draw: function(ctx) {
		var radius = Math.max(0, Math.sin(Math.PI / 2 + (Explosion.timeToLive - this.timeToLive) 
			/ Explosion.timeToLive * Math.PI) / 2);

		ctx.save();
		ctx.fillStyle = this.color;
		ctx.globalAlpha = 0.7;

		ctx.beginPath();
		ctx.arc(this.x, this.y, radius * this.size, 0, Math.PI * 2, true);
		ctx.fill();
		ctx.restore();

		return [this.x - this.size * 0.5, this.y - this.size * 0.5,
			this.size, this.size];
	}

};
