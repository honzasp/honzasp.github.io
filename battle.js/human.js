/* human controls tank using keys */
var Human = function(name, color) {
	Human.superclass.call(this, name, color);
};
extend(Human, Player);

Human.prototype.active = function() {
	if(this.tank.alive) {
		Controls.setPlayer(this);
		Controls.active = true;
		Controls.actualize();
		Controls.show();
	}
};

Human.prototype.inactive = function() {
	Controls.hide();
	Controls.active = false;
};

Human.prototype.tankChanged = function() {
	Controls.change = true;
}

Human.prototype.killed = function() {
	if(this == Controls.player) {
		Controls.hide();
		Controls.active = false;
		Controls.setPlayer(null);
	}
};

