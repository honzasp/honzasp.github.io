var Player = function(game) {
	this.game = game;
	this.dead = false;

	this.x = 0;
	this.y = 0;
	this.velX = 0;
	this.velY = 0;
	this.accX = 0;
	this.accY = 0;
	this.force = 1;

	this.size = 1;
	this.density = Player.density;

	this.fillColor = Fish.fillColors[0];
	this.strokeColor = Fish.strokeColors[0];
};

Player.damping = 0.7;
Player.density = 0.002;

Player.prototype = {

	update: function(time) {
		this.velX += this.accX * this.force * time; // (this.size * this.density);
		this.velY += this.accY * this.force * time; // (this.size * this.density);

		this.velX -= this.velX * Player.damping * time;
		this.velY -= this.velY * Player.damping * time;

		this.x += this.velX * time;
		this.y += this.velY * time;

		if(this.x > this.game.width) {
			this.x = -this.width();
		} else if(this.x + this.width() < 0) {
			this.x = this.game.width;
		}

		if(this.y >= this.game.height - this.height()) {
			this.y = this.game.height - this.height();
			this.velY = 0;
		} else if(this.y < 0) {
			this.y = 0;
			this.velY = 0;
		}
	},

	collision: function(fish) {
		if(fish.size < this.size) {
			fish.dead = true;
			this.size += fish.size * Fish.energyValue;
			this.game.playerSizeChanged();
		} else {
			this.dead = true;
		}
	},

	draw: Fish.prototype.draw,
	width: Fish.prototype.width,
	height: Fish.prototype.height,

	direction: function() {
		if(this.accX != 0) {
			return this.accX;
		} else {
			return this.velX;
		}
	}

};

