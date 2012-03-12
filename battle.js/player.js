/* player has got tank and controls it */
var Player = function(name, color) {
	this.name = name;
	this.color = color;
	this.money = 100;
	this.score = 0;

	/* tank driving */
	this.direction = 0;
	this.cannonRotation = 0;
	this.firePowerChange = 0;
	this.missileNum = 0; // index in Missile.classes

	this.tank = null;
};

Player.prototype = {

	/* player is now active (on turn) */
	active: function() {

	},

	/* player is now inactive */
	inactive: function() {

	},

	/* called when some tank properties (NOT position) were changed */
	tankChanged: function() {

	},

	/* called when tank was killed */
	killed: function() {

	}

};

