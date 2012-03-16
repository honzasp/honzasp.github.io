var Tank = function(x, y, player) {
	this.x = x;
	this.y = y;
	this.player = player;
	player.tank = this;
	this.alive = true;

	this.vely = 0; // falling velocity
	this.falling = true; // is falling?
	this.cannonAngle = Math.PI / 4; // cannon angle
	this.lives = 100;
	this.maxFirePower = 200;
	this.fuel = 400; 

	this.hillMove = 20;
	this.speed = 20;
	this.firePower = 100;

	this.missiles = [];
	for(num in Missile.classes) {
		this.missiles[num] = Missile.classes[num].defaultAmount;
	}
}

Tank.width = 16;
Tank.height = 8;
Tank.firePowerChangeSpeed = 30;
Tank.cannonRotationSpeed = 1; // rad/s
Tank.cannonSize = 10;
Tank.cannonY = -5; // cannon Y coordinate in tank

Tank.repairAmount = 5;
Tank.repairCost = 15;

Tank.fuelAmount = 50;
Tank.fuelCost = 20;

Tank.prototype = {

	/* draws tank to canvas and returns rectangle [x, y, w, h] needed to draw it */
	draw: function(ctx) {
		ctx.save();
		ctx.translate(this.x, this.y);

		//ctx.scale(Tank.width, Tank.height);
		var w = Tank.width;
		var h = Tank.height;

		/* tank shape */
		ctx.beginPath();
		ctx.moveTo(-0.3 * w, -1 * h);
		ctx.lineTo(-0.5 * w, -0.4 * h);
		ctx.lineTo(-0.4 * w, 0 * h);
		ctx.lineTo(0.4 * w, 0 * h);
		ctx.lineTo(0.5 * w, -0.4 * h);
		ctx.lineTo(0.3 * w, -1 * h);
		ctx.fillStyle = this.player.color;
		ctx.fill();

		/* cannon */
		ctx.beginPath();
		ctx.moveTo(0, Tank.cannonY);
		ctx.lineTo(Math.sin(this.cannonAngle) * Tank.cannonSize,
			Math.cos(this.cannonAngle) * -Tank.cannonSize + Tank.cannonY);
		ctx.strokeStyle = BattleJS.style("cannon", "color");
		ctx.lineWidth = parseInt(BattleJS.style("cannon", "width"), 10);
		ctx.lineCap = "round";
		ctx.stroke();

		ctx.restore();

		/* dirty rectangle */
		return [this.x - Tank.width * 1.2, this.y - Tank.height * 2.1,
			Tank.width * 2.4, Tank.height * 2.2];
	},

	/* updates tanks position */
	update: function(time) {
		if(this.falling) {
			this.vely += BattleJS.gravity * time;
			this.y += this.vely * time;
		}

		var rx = Math.round(this.x);
		var ry = Math.round(this.y);

		if(rx < Tank.width / 2) {
			this.x = Tank.width / 2;
		} else if(rx >= BattleJS.width - Tank.width / 2) {
			this.x = BattleJS.width - Tank.width / 2 - 1;
		}

		if(ry >= BattleJS.height) {
			this.explode();
		}

		/* y-movement (falling) */
		var terrainY = BattleJS.terrain[Math.round(this.x)];
		if(terrainY < this.y) {
			this.y = terrainY;

			if(this.falling) {
				this.falled();
				this.falling = false;
				this.vely = 0;
			}
		} else if(terrainY > this.y) {
			this.falling = true;
		}

		/* alive? */
		if(this.lives <= 0) {
			this.player.tankChanged();
			this.explode();
		}

		if(this.firePower >= this.maxFirePower) {
			this.firePower = this.maxFirePower;
			this.player.tankChanged();
		}

		/* moving is only enabled when player is on turn */
		if(this.player == BattleJS.playerOnTurn) {

			/* x-movement (moving)*/
			if(this.fuel > 0 && !this.falling && this.player.direction != 0) {
				var step = this.player.direction * this.speed * time;
				var newX = this.x + step;
				var newY = BattleJS.terrain[Math.round(newX)];

				this.fuel -= Math.abs(step);

				if(this.fuel < 0) {
					this.fuel = 0;
				}

				this.player.tankChanged();

				if(newY >= this.y) {
					this.x = newX;
					this.y = newY;
				} else {
					if((this.y - newY) <= (this.hillMove * time)) {
						/* can move (hill isn't too big */
						this.x = newX;
						this.y = newY;
					} else {
						/* cannot move */
					}
				}

			}

			/* cannon rotation */
			if(this.player.cannonRotation != 0) {
				this.cannonAngle += this.player.cannonRotation * Tank.cannonRotationSpeed * time;

				if(this.cannonAngle < -Math.PI / 2) {
					this.cannonAngle = -Math.PI / 2;
				} else if(this.cannonAngle > Math.PI / 2) {
					this.cannonAngle = Math.PI / 2;
				}

				this.player.tankChanged();
			}

			/* fire power change */
			if(this.player.firePowerChange != 0) {
				this.firePower += this.player.firePowerChange * Tank.firePowerChangeSpeed * time;

				if(this.firePower > this.maxFirePower) {
					this.firePower = this.maxFirePower;
				} else if(this.firePower < 0) {
					this.firePower = 0;
				}

				this.player.tankChanged();
			}

		}

	},

	/* called when tank falled to terrain */
	falled: function() {
		this.lives -= this.vely;
		this.player.tankChanged();
	},

	/* called when explosion hit the tank */
	hit: function(obj, force) {
		if(obj.tank && obj.tank != this) {
			obj.tank.player.money += force;
			obj.tank.player.score += force;
		}

		this.lives -= force;
		this.player.tankChanged();
	},

	/* destroy tank with explosion */
	explode: function() {
		this.alive = false;
		BattleJS.makeExplosion(this);
		BattleJS.playerKilled(this.player);
		this.player.tankChanged();
	},

	/* fires missile and finishes player's turn */
	fire: function() {
		if(this.missiles[this.player.missileNum] > 0 
				&& this.player == BattleJS.playerOnTurn) {

			var sin = Math.sin(this.cannonAngle);
			var cos = -Math.cos(this.cannonAngle);

			var x = sin * Tank.cannonSize + this.x;
			var y = Tank.cannonY + cos * Tank.cannonSize + this.y;
			var velx = sin * this.firePower;
			var vely = cos * this.firePower;

			if(this.player.missileNum != 0) {
				this.missiles[this.player.missileNum]--;
			}

			this.player.tankChanged();

			BattleJS.addMissile(Missile.classes[this.player.missileNum], x, y, velx, vely, this);
			BattleJS.playerFinished();
		}
	},

	/* repairs tank */
	repair: function() {
		if(this.player.money >= Tank.repairCost) {
			this.player.money -= Tank.repairCost;
			this.lives += Tank.repairAmount;
      Controls.change = true;
		}
	},

	/* buys fuel */
	buyFuel: function() {
		if(this.player.money >= Tank.fuelCost) {
			this.player.money -= Tank.fuelCost;
			this.fuel += Tank.fuelAmount;
      Controls.change = true;
		}
	}

};
