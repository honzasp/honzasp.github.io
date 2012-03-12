var Fish = function(game, x, y, velX, size) {
	this.game = game;
	this.x = x;
	this.y = y;
	this.velX = velX;
	this.size = size;
	this.dead = false;

	var color = Math.floor(Math.random() * (Fish.strokeColors.length - 1)) + 1;
	this.fillColor = Fish.fillColors[color];
	this.strokeColor = Fish.strokeColors[color];

	this.id = ++Fish.lastID;
};

Fish.width = 1.3 * 0.8;
Fish.height = 0.35 * 0.8;
Fish.lastID = 0;
Fish.energyValue = 0.08;
Fish.minSize = 10;
Fish.maxSize = 130;
Fish.maxSpeed = 250;

Fish.strokeColors = ["#d23e1e", "#1d832e", "#3558bb", "#773d09", "#d27c2e"];
Fish.fillColors = ["#ff7759", "#60bb6f", "#5174d9", "#b87539", "#e79c59"];

Fish.prototype = {

	/*

	  x
  y +-----------+
	  |::::fish:::|
	  +-----------+

	 */
	update: function(time) {
		this.x += this.velX * time;

		if(this.x > this.game.width) {
			this.dead = true;
		}

		if(this.x + this.width() < 0) {
			this.dead = true;
		}
	},

	draw: function(ctx) {
		var w = Fish.width * 35;
		var h = Fish.height * 35;

		ctx.save();
		ctx.translate(this.x, this.y);
		ctx.scale(this.size / 35, this.size / 35);

		if(this.direction() > 0) {
			ctx.translate(w, 0);
			ctx.scale(-1, 1);
		} else {
			//ctx.scale(1, 1);
		}
			
		ctx.beginPath();

		ctx.moveTo(0.00 * w, 0.50 * h);
		ctx.lineTo(0.20 * w, 0.00 * h);
		ctx.lineTo(0.50 * w, 0.10 * h);
		ctx.lineTo(1.00 * w, 0.90 * h);
		ctx.lineTo(0.90 * w, 0.50 * h);
		ctx.lineTo(1.00 * w, 0.10 * h);
		ctx.lineTo(0.50 * w, 0.90 * h);
		ctx.lineTo(0.20 * w, 1.00 * h);
		ctx.lineTo(0.00 * w, 0.50 * h);

		ctx.moveTo(0.24 * w, 0.45 * h);
		ctx.arc(0.20 * w, 0.45 * h, 0.04 * w, 0, Math.PI * 2, 0);

		ctx.fillStyle = this.fillColor;
		ctx.strokeStyle = this.strokeColor;
		//ctx.lineWidth = this.size / 100 + 0.8;
		ctx.fill();
		ctx.stroke();
		ctx.restore();
	},

	width: function() {
		return this.size * Fish.width;
	},

	height: function() {
		return this.size * Fish.height;
	},

	direction: function() {
		return this.velX;
	}

};
