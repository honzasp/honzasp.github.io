/* html interface between human and instance of Player */
var Controls = {

	actualizesPerSecond: 10,

	/* initializes controls in BattleJS.element */
	init: function() {
		this.element = $("<form class='controls' action=''></form>");
		this.element.submit(function(e) { e.preventDefault(); });
		this.element.hide();
		this.element.css("position", "absolute");
		this.element.css("top", "0");
		this.element.css("left", "0");
		this.element.appendTo(BattleJS.element);

		var ths = this;

		var drivingElement = $("<div class='driving'></div>");

		/* change angle */
		this.angleElement = $(
			"<div class='angle'>" +
				"<label>Cannon angle</label>" +
				"<span></span>" +
				"<input type='button' value='&lt;'>" +
				"<input type='button' value='&gt;'>" +
			"</div>");
		this.angleElement.appendTo(drivingElement);

		$("input", this.angleElement).mousedown(function() {
				if(ths.active) {
					if($(this).attr("value") == ">") {
						ths.player.cannonRotation = 1;
					} else if($(this).attr("value") == "<") {
						ths.player.cannonRotation = -1;
					}
				}
			});

		this.angleElement.mouseup(function() {
				if(ths.active) {
					ths.player.cannonRotation = 0;
				}
			});

		/* move */
		this.moveElement = $(
			"<div class='move'>" +
				"<label>Fuel</label>" +
				"<span></span>" +
				"<input type='button' value='&lt;'>" +
				"<input type='button' value='&gt;'>" +
			"</div>");
		this.moveElement.appendTo(drivingElement);

		$("input", this.moveElement).mousedown(function() {
				if(ths.active) {
					if($(this).attr("value") == ">") {
						ths.player.direction = 1;
					} else if($(this).attr("value") == "<") {
						ths.player.direction = -1;
					}
				}
			});

		this.moveElement.mouseup(function() {
				if(ths.active) {
					ths.player.direction = 0;
				}
			});

		/* change fire power */
		this.firePowerElement = $(
			"<div class='firePower'>" +
				"<label>Fire power</label>" +
				"<span></span>" +
				"<input type='button' value='+'>" +
				"<input type='button' value='-'>" +
			"</div>");
		this.firePowerElement.appendTo(drivingElement);

		$("input", this.firePowerElement).mousedown(function() {
				if(ths.active) {
					if($(this).attr("value") == "+") {
						ths.player.firePowerChange = 1;
					} else if($(this).attr("value") == "-") {
						ths.player.firePowerChange = -1;
					}
				}
			});

		$("input", this.firePowerElement).mouseup(function() {
				if(ths.active) {
					ths.player.firePowerChange = 0;
				}
			});

		drivingElement.appendTo(this.element);

		var infoElement = $("<div class='info'></div>");

		/* name */
		this.nameElement = $(
			"<div class='name'>" +
				"<label>Name</label>" +
				"<span></span>" +
			"</div>");
		this.nameElement.appendTo(infoElement);

		/* lives */
		this.livesElement = $(
			"<div class='lives'>" +
				"<label>Lives</label>" +
				"<span></span>" +
			"</div>");
		this.livesElement.appendTo(infoElement);

		/* money */
		this.moneyElement = $(
			"<div class='money'>" +
				"<label>Money</label>" +
				"<span></span>" +
			"</div>");
		this.moneyElement.appendTo(infoElement);

		/* score */
		this.scoreElement = $(
			"<div class='score'>" +
				"<label>Score</label>" +
				"<span></span>" +
			"</div>");
		this.scoreElement.appendTo(infoElement);

		/* button "Fire" */
		this.fireButton = $(
			"<div class='fire'>" +
				"<input type='button' value='Fire!'>" +
			"</div>");
		this.fireButton.appendTo(infoElement);

		$("input", this.fireButton).click(function() {
				if(ths.active) {
					ths.player.tank.fire();
				}
			});

		infoElement.appendTo(this.element);

		var buyingElement = $("<div class='buying'></div>");

		/* missile type */
		this.missileElement = $(
			"<div class='activeMissile'>" +
				"<label>Missile</label>" +
				"<span></span>" +
				"<input type='button' value='&lt;'>" +
				"<input type='button' value='&gt;'>" +
			"</div>");
		this.missileElement.appendTo(buyingElement);

		$("input", this.missileElement).click(function() {
				if(ths.active) {
					ths.change = true;

					var num = ths.player.missileNum;
					var len = ths.player.tank.missiles.length;

					if($(this).attr("value") == "<") {
						do {
							--num;
						} while(num > 0 && ths.player.tank.missiles[num] <= 0);

						if(num >= 0) {
							ths.player.missileNum = num;
						}
					} else if($(this).attr("value") == ">") {
						do {
							++num;
						} while(num < ths.player.tank.missiles.length && ths.player.tank.missiles[num] <= 0);

						if(num < ths.player.tank.missiles.length) {
							ths.player.missileNum = num;
						}
					}
				}
			});

		/* button "Repair" */
		this.repairButton = $(
			"<div class='repair'>" +
				"<input type='button' value='Repair ($" + Tank.repairCost + ")'>" +
			"</div>");
		this.repairButton.appendTo(buyingElement);

		$("input", this.repairButton).click(function() {
				if(ths.active) {
					ths.player.tank.repair();
				}
			});

		/* button "Buy fuel" */
		this.fuelButton = $(
			"<div class='buyFuel'>" +
				"<input type='button' value='Buy fuel ($" + Tank.fuelCost + ")'>" +
			"</div>");
		this.fuelButton.appendTo(buyingElement);

		$("input", this.fuelButton).click(function() {
				if(ths.active) {
					ths.player.tank.buyFuel();
				}
			});

		buyingElement.appendTo(this.element);

		/* keyboard control */

		$(document).bind("keydown keypress", function(e) {
				if(ths.active) {
					switch(e.which) {

					case 37: /* left */
						ths.player.direction = -1;
						return false;
					case 39: /* right */
						ths.player.direction = 1;
						return false;

					case 38: /* up */
						ths.player.cannonRotation = -1;
						return false;
					case 40: /* down */
						ths.player.cannonRotation = 1;
						return false;

					case 33: /* pgup */
						ths.player.firePowerChange = 1;
						return false;
					case 34: /* pgdown */
						ths.player.firePowerChange = -1;
						return false;

					case 32: /* space */
						ths.player.tank.fire();
						return false;

					default:
						break;
					}
				}

				return true;
			});

		$(document).keyup(function(e) {
				if(ths.active) {
					switch(e.which) {
					case 37: /* left */
					case 39: /* right */
						ths.player.direction = 0;
						return false;

					case 38: /* up */
					case 40: /* down */
						ths.player.cannonRotation = 0;
						return false;

					case 33: /* pgup */
					case 34: /* pgdown */
						ths.player.firePowerChange = 0;
						return false;

					default:
						break;
					}
				}

				return true;
			});

		setInterval(function() { ths.actualize(); }, 1000 / this.actualizesPerSecond);
	},

	/* actualizes player's information */
	actualize: function() {
		if(this.active && this.change) {
			this.change = false;

			var angle = Math.round(this.player.tank.cannonAngle * 180 / Math.PI);
			$("span", this.angleElement).text(angle + "°");

			var firePower = Math.round(this.player.tank.firePower);
			$("span", this.firePowerElement).text(firePower);

			var fuel = Math.round(this.player.tank.fuel);
			$("span", this.moveElement).text(fuel);

			var missiles = this.player.tank.missiles[this.player.missileNum];
			if(missiles <= 0) {
				this.player.missileNum = 0;
				var missiles = this.player.tank.missiles[this.player.missileNum];
			}

			var missile = Missile.classes[this.player.missileNum].name 
				+ " (" + this.player.tank.missiles[this.player.missileNum] + ")";
			$("span", this.missileElement).text(missile);

			var name = this.player.name;
			$("span", this.nameElement).text(name);

			var lives = Math.round(this.player.tank.lives);
			$("span", this.livesElement).text(lives);

			var money = Math.round(this.player.money);
			$("span", this.moneyElement).text("$" + money);

			var score = Math.round(this.player.score);
			$("span", this.scoreElement).text(score);
		}

	},

	/* sets player */
	setPlayer: function(player) {
		this.player = player;
		if(this.player) {
			this.element.css("background-color", this.player.color);
		}
	},

	/* shows controls */
	show: function() {
		this.element.show();
	},

	/* hides controls */
	hide: function() {
		this.element.hide();
	}

};
