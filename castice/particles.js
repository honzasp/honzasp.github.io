/**
 * Nova castice.
 * Castice je pritahovana studnami a pohybuje se v prostoru.
 */
function Particle(x, y, vx, vy) {
	this.posX = x;
	this.posY = y;
	this.velX = vx;
	this.velY = vy;
	this.color = Particle.colors[Particle.colorIndex++];
	Particle.colorIndex %= Particle.colors.length;
}

Particle.radius = 4;
Particle.colors = [
	"#e12323",
	"#2348e1",
	"#23e145",
	"#e1b823",
	"#d25658",
	"#d256c7",
	"#5667d2",
	"#56d257",
	"#d29d56",
	"#7a1613",
	"#7a136e",
	"#2d137a",
	"#2f799a",
	"#2f9a52",
	"#7b9a2f",
	"#9a542f",
	"#ff2713",
	"#bf05b2",
	"#2c00a9",
	"#005fa9",
	"#00a942",
	"#8ca900",
	"#e6ce36",
	"#e68736"
];
Particle.colorIndex = 0;

Particle.prototype = {

	/**
	 * Pohne se o urceny cas.
	 */
	move: function(time) {
		this.posX += this.velX * time;
		this.posY += this.velY * time;
	},

	/**
	 * Pokud presahuje hranice sveta, odrazi se.
	 */
	checkBounds: function(world) {
		if(this.posX < 0) {
			this.posX = 0;
			this.velX = -this.velX;
		} else if(this.posX > world.width) {
			this.posX = world.width;
			this.velX = -this.velX;
		}

		if(this.posY < 0) {
			this.posY = 0;
			this.velY = -this.velY;
		} else if(this.posY > world.height) {
			this.posY = world.height;
			this.velY = -this.velY;
		}
	},

	/**
	 * Nakresli se do canvasu.
	 */
	draw: function(ctx) {
		var speed = Math.sqrt(this.velX * this.velX + this.velY * this.velY);
		var width = Particle.radius * 2 + speed / 32;
		var height = Particle.radius * 2;

		ctx.save();
		ctx.strokeStyle = this.color;
		ctx.translate(this.posX, this.posY);
		ctx.rotate(Math.atan2(this.velY, this.velX));

		var x = width / -2,
			y = height / -2;

		/* kresleni elipsy */
		var hB = (width / 2) * .5522848,
			vB = (height / 2) * .5522848,
			eX = x + width,
			eY = y + height,
			mX = x + width / 2,
			mY = y + height / 2;

		ctx.beginPath();
		ctx.moveTo(x, mY);
		ctx.bezierCurveTo(x, mY - vB, mX - hB, y, mX, y);
		ctx.bezierCurveTo(mX + hB, y, eX, mY - vB, eX, mY);
		ctx.bezierCurveTo(eX, mY + vB, mX + hB, eY, mX, eY);
		ctx.bezierCurveTo(mX - hB, eY, x, mY + vB, x, mY);
		ctx.stroke();

		ctx.restore();
	},

};

/**
 * Nova studna.
 * Studna ma svou hmotnost (velikost) a pritahuje castice. Sama se nepohybuje.
 */
function Well(x, y, radius) {
	this.posX = x;
	this.posY = y;
	this.setRadius(radius);
}

Well.gravityForce = 3;
Well.antiGravityForce = 10;
Well.color = "#000";

Well.prototype = {

	/**
	 * Ovlivni rychlost castice svou pritazlivosti za nejaky cas.
	 */
	affect: function(particle, time) {
		var dX = this.posX - particle.posX;
		var dY = this.posY - particle.posY;
		var dist = Math.sqrt(dX * dX + dY * dY);

		if(dist > this.radius) {
			var f = this.mass / dist * Well.gravityForce;
		} else {
			var f = -this.mass / this.radius * Well.antiGravityForce;
		}

		particle.velX += (dX / dist) * f * time;
		particle.velY += (dY / dist) * f * time;
	},

	/**
	 * Nastavi polomer.
	 */
	setRadius: function(radius) {
		this.radius = radius;
		this.mass = radius * radius * Math.PI;
	},

	/**
	 * Nakresli se na canvas.
	 */
	draw: function(ctx) {
		ctx.save();
		ctx.strokeStyle = Well.color;
		ctx.lineWidth = 2;
		ctx.beginPath();
		ctx.arc(this.posX, this.posY, this.radius, 0, Math.PI * 2, true);
		ctx.stroke();
		ctx.restore();

	}

};

/**
 * Svet.
 * Svet ma sve hranice a obsahuje castice a studny. Umi se kreslit do canvasu.
 */
function World(w, h, ctx) {
	this.width = w;
	this.height = h;
	this.context = ctx;

	this.particles = [];
	this.wells = [];

	this.checkBounds = true;
};

World.prototype = {

	/**
	 * Prida castici.
	 */
	addParticle: function(particle) {
		this.particles.push(particle);
	},

	/**
	 * Prida studnu.
	 */
	addWell: function(well) {
		this.wells.push(well);
	},

	/**
	 * Pokud to jde tak smaze posledni castici.
	 */
	deleteParticle: function() {
		this.particles.pop();
	},

	/**
	 * Pokud to jde tak smaze posledni studnu.
	 */
	deleteWell: function() {
		this.wells.pop();
	},

	/**
	 * Prida nahodnou castici.
	 */
	randomParticle: function() {
		var x = Math.random() * this.width;
		var y = Math.random() * this.height;
		var velx = (Math.random() - 0.5) * 50;
		var vely = (Math.random() - 0.5) * 50;
		this.addParticle(new Particle(x, y, velx, vely));
	},

	/**
	 * Prida nahodnou studnu.
	 */
	randomWell: function() {
		var x = Math.random() * this.width;
		var y = Math.random() * this.height;
		var rad = 10 + Math.random() * 30;
		this.addWell(new Well(x, y, rad));
	},

	/**
	 * Smaze vse.
	 */
	clear: function() {
		this.particles = [];
		this.wells = [];
	},

	/**
	 * Jeden krok simulace.
	 */
	step: function(time) {
		var i, j;

		for(i = 0; i != this.particles.length; i++) {

			for(j = 0; j != this.wells.length; j++) {
				this.wells[j].affect(this.particles[i], time);
			}

			this.particles[i].move(time);
			if(this.checkBounds) {
				this.particles[i].checkBounds(this);
			}
		}

		this.draw();
	},

	/**
	 * Nakresli svet.
	 */
	draw: function() {
		var ctx = this.context;
		ctx.clearRect(0, 0, this.width, this.height);
		ctx.save();

		var i;

		/* castice */
		for(i = 0; i != this.particles.length; i++) {
			this.particles[i].draw(ctx);
		}

		/* studny */
		for(i = 0; i != this.wells.length; i++) {
			this.wells[i].draw(ctx);
		}

		/* pridavana castice/studna */
		if(this.isMouseDown) {
			if(this.whatAdd == "well") {
				this.mouseWell.draw(ctx);
			} else {
				this.mouseParticle.draw(ctx);
				ctx.beginPath();
				ctx.moveTo(this.mouseParticle.posX, this.mouseParticle.posY);
				ctx.lineTo(this.mouseParticle.posX - this.mouseParticle.velX,
					this.mouseParticle.posY - this.mouseParticle.velY);
				ctx.stroke();
			}
		}

		ctx.restore();
	},

	/**
	 * Zmacknuti mysi.
	 */
	initPosX: 0,
	initPosY: 0,
	lastPosX: 0,
	lastPosY: 0,
	isMouseDown: false,
	mouseParticle: null, /* pridavana castice */
	mouseWell: null, /* pridavana studna */

	/** Co se pridava ("well" - studna, "particle" - castice. **/
	whatAdd: null, 

	/**
	 * Zmacknuti mysi.
	 */
	mousedown: function(x, y) {
		this.isMouseDown = true;

		if(this.whatAdd == "particle") {
			this.mouseParticle = new Particle(x, y, 0, 0);
		} else {
			this.mouseWell = new Well(x, y, 5);
		}

		return true;
	},

	/**
	 * Pohyb mysi.
	 */
	mousemove: function(x, y) {
		if(this.isMouseDown) {
			if(this.whatAdd == "particle") {
				this.mouseParticle.velX = this.mouseParticle.posX - x;
				this.mouseParticle.velY = this.mouseParticle.posY - y;
			} else {
				var dx = x - this.mouseWell.posX;
				var dy = y - this.mouseWell.posY;
				var dist = Math.sqrt(dx * dx + dy * dy);

				if(dist < 2) {
					dist = 5;
				}

				this.mouseWell.setRadius(dist);
			}

			return true;
		} else {
			return false;
		}

	},

	/**
	 * Uvolneni mysi.
	 */
	mouseup: function(x, y) {
		if(this.isMouseDown) {
			this.isMouseDown = false;

			if(this.whatAdd == "well") {
				this.addWell(this.mouseWell);
			} else {
				this.addParticle(this.mouseParticle);
			}

			return true;
		} else {
			return false;
		}
	}

};

$(document).ready(function() {
		var element = $("#particles");
		element.html("");

		var canvas = $("<canvas></canvas>");
		element.append(canvas);

		if(!canvas[0].getContext) {
			element.html("Tvůj prohlížeč bohužel nepodporuje značku canvas");
			return;
		}

		var div = $(".app");
		var width = parseInt(div.css("width")) 
			- parseInt(div.css("marginLeft"))
			- parseInt(div.css("marginRight"));
		var height = width * 3/5;

		canvas[0].width = width;
		canvas[0].height = height;
		canvas.css("display", "block");

		var ctx = canvas[0].getContext('2d');
		if(!ctx) {
			element.html("Nepovedlo se získat 2D kreslící kontext canvasu");
			return;
		}

		var world = new World(width, height, ctx);
		world.addWell(new Well(width / 2, height / 2, 10));
		world.addParticle(new Particle(width / 2 - 50, height / 2, 0, 30));
		world.addParticle(new Particle(width / 2 + 50, height / 2, 0, -30));

		/* formular pod canvasem */
		var htmlForm = $("<form>" +
			"<div>" +
			"<label for='whatAdd'>Přidává se</label>" +
			"<select id='whatAdd'>" + 
			"<option value='particle'>Částice</option>" +
			"<option value='well'>Studna</option>" +
			"</select>" +
			"</div>" +

			"<div>" +
			"<button type='button' id='deleteParticle'>Smazat částici</button>" +
			"<button type='button' id='deleteWell'>Smazat studnu</button>" +
			"</div>" +

			"<div>" +
			"<button type='button' id='randomParticle'>Náhodná částice</button>" +
			"<button type='button' id='randomWell'>Náhodná studna</button>" +
			"</div>" +

			"<div>" +
			"<button type='button' id='clear'>Vyčistit</button>" +
			"</div>" +

			"<div>" + 
			"<label for='checkBounds'>Držet částice uvnitř světa?</label>" +
			"<input type='checkbox' id='checkBounds' checked='checked'>" +
			"</div>" +

			"</form>"
		);
		element.append(htmlForm);

		/* nabidka co se pridava */
		world.whatAdd = "particle";
		$("#whatAdd", htmlForm).change(function(e) {
				world.whatAdd = $(this).val();
			});

		/* tlacitko na mazani castice */
		$("#deleteParticle", htmlForm).click(function() {
				world.deleteParticle();
			});

		/* tlacitko na mazani studny */
		$("#deleteWell", htmlForm).click(function() {
				world.deleteWell();
			});

		/* nahodna castice */
		$("#randomParticle", htmlForm).click(function() {
				world.randomParticle();
			});

		/* nahodna studna */
		$("#randomWell", htmlForm).click(function() {
				world.randomWell();
			});

		/* cudlik na vycisteni */
		$("#clear", htmlForm).click(function() {
				world.clear();
			});

		/* zatrzitko na drzeni castic uvnitr sveta */
		$("#checkBounds", htmlForm).change(function(e) {
				world.checkBounds = this.checked;
			});


		world.checkBounds = true;

		canvas.bind("mousedown touchstart", function(e) {
			var offset = $(element).offset();
			var x = e.pageX - offset.left;
			var y = e.pageY - offset.top;

			if(world.mousedown(x, y)) {
				e.preventDefault();
			}
		});

		$(document).bind("mouseup touchend", function(e) {
			var offset = $(element).offset();
			var x = e.pageX - offset.left;
			var y = e.pageY - offset.top;
			world.mouseup(x, y);
			e.preventDefault();

			if(world.mouseup(x, y)) {
				e.preventDefault();
			}
		});

		$(document).bind("mousemove touchmove", function(e) {
			var offset = $(element).offset();
			var x = e.pageX - offset.left;
			var y = e.pageY - offset.top;

			if(world.mousemove(x, y)) {
				e.preventDefault();
			}
		});


		var stepTime = 1 / 25;

		setInterval(function() {
				world.step(stepTime);
			}, stepTime * 1000);
	});
