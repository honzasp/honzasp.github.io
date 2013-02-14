var Missile = function(klass, x, y, velx, vely, tank) {
	this.klass = klass;
	this.x = x;
	this.y = y;
	this.velx = velx;
	this.vely = vely;
	this.tank = tank;
	this.alive = true;
}

Missile.prototype = {
	/* draws missile to canvas and returns rectangle [x, y, w, h] where missile
	 * was drawed */
	draw: function(ctx) {
		var radius = parseInt(BattleJS.style("missile", "width"), 10) / 2;
		ctx.beginPath();
		ctx.arc(this.x, this.y, radius, 0, Math.PI * 2, true);
		ctx.fillStyle = BattleJS.style("missile", "color");
		ctx.fill();

		return [this.x - 3, this.y - 3, 6, 6];
	},

	/* updates missiles position */
	update: function(time) {
		this.vely += BattleJS.gravity * time;
		this.x += this.velx * time;
		this.y += this.vely * time;

		if(this.x < 0 ||this.x >= BattleJS.width) {
			this.alive = false;
		} else if(BattleJS.terrain[Math.round(this.x)] <= this.y) {
			this.explode();
		}
	},

	/* destroy missile and make explosion */
	explode: function() {
		this.alive = false;
		BattleJS.makeExplosion(this);
	}

};

/* missile class (holds missile information) */
var MissileClass = function(name, obj) {
	this.name = name;

	this.explosionForce = obj.force || 20;
	this.explosionSize = obj.size || 40;
	this.craterSize = obj.crater || 10;
	this.explosionColor = obj.color || "red";

	//this.price = obj.price || 10; // $ per item
	this.defaultAmount = obj.def || 5;
};

(function(MC) {
	Missile.classes = [
		new MC("Small missile", 
			{ force: 20, size: 35, crater: 20, price: 5, def: 100, color: "#f00" } ),

		new MC("Medium missile", 
			{ force: 30, size: 50, crater: 30, price: 12, def: 20, color: "#f40" } ),

		new MC("Huge missile", 
			{ force: 40, size: 75, crater: 40, price: 25, def: 5, color: "#f80" } ),

		new MC("Flammable bomb",
			{ force: 30, size: 120, crater: 20, price: 20, def: 2, color: "#fa0" } ),

		new MC("Destructive bomb",
			{ force: 10, size: 50, crater: 100, price: 30, def: 2, color: "#888" } ),

		new MC("Atom bomb",
			{ force: 150, size: 80, crater: 40, price: 150, def: 1, color: "#8f8" } )

	];
})(MissileClass);
