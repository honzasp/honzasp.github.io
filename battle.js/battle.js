var BattleJS = {

	width: 700,
	height: 500,
	stepTime: 1 / 25,
	gravity: 30,

	/* game initialization: initializes HTML elements, hides them and creates world  */
	init: function(element) {
		this.element = element;
		this.element.css("width", this.width + "px");
		this.element.css("height", this.height + "px");

		/* main canvas */
		var canvas = $("canvas", this.element);

		if(canvas[0].getContext) {
			this.context = canvas[0].getContext('2d');
			if(!this.context) {
				this.showError(canvas.text());
				return false;
			}
		} else {
			this.showError(canvas.text());
			return false;
		}

		/* terrain canvas is used to draw terrain */
		var terrainCanvas = $("<canvas></canvas>");
		terrainCanvas.appendTo(this.element);
		this.terrainContext = terrainCanvas[0].getContext('2d');

		if(!this.terrainContext) {
			this.showError("Unable to get drawing context for terrain canvas!");
			return false;
		}

		this.styleElement = $("<div></div>");
		this.styleElement.hide();
		this.styleElement.appendTo(this.element);

		this.styleElements = {};
		this.styles = {};
		this.addStyle("terrain");
		this.addStyle("missile");
		this.addStyle("cannon");

		canvas[0].width = this.width;
		canvas[0].height = this.height;
		canvas.css("z-index", "1");
		canvas.css("position", "absolute");
		canvas.css("top", "0");
		canvas.css("left", "0");

		terrainCanvas[0].width = this.width;
		terrainCanvas[0].height = this.height;
		terrainCanvas.css("z-index", "0");
		terrainCanvas.css("position", "absolute");
		terrainCanvas.css("top", "0");
		terrainCanvas.css("left", "0");

		this.createWorld();

		/* hides everything in this.element */
		this.hidden = $("*", this.element);
		this.hidden.hide();
	},

	/* starts game */
	start: function() {
		this.hidden.show();

		this.dirtyRects = [ [0, 0, this.width, this.height ] ];
		this.drawTerrain();

		var ths = this;
		this.timer = setInterval(function() { ths.step(); }, this.stepTime * 1000);
	},

	/* stops game */
	stop: function() {
		clearInterval(this.timer);
	},

	/* adds element with class named style and saves it to this.styles[style] */
	addStyle: function(style) {
		var elem = $("<div></div>");
		elem.addClass(style);
		elem.appendTo(this.styleElement);
		this.styleElements[style] = elem;
		this.styles[style] = {};
	},

	/* gets style */
	style: function(htmlClass, name) {
		if(this.styles[htmlClass][name]) {
			return this.styles[htmlClass][name];
		} else {
			return this.styles[htmlClass][name] = this.styleElements[htmlClass].css(name);
		}
	},

	/* shows error message */
	showError: function(message) {
		this.element.html("");
		var elem = $("<div class='error'></div>");
		elem.html(message);
		elem.appendTo(this.element);
	},

	/* creates game world */
	createWorld: function() {
		this.terrain = []; // array of terrain top levels

		/* TODO: random terrain generator */
		for(var i = 0; i != this.width; i++) {
			this.terrain.push(this.height - (Math.sin(i / 100) * 50 + 100));
		}

		this.tanks = [];
		this.missiles = [];
		this.explosions = [];

		/* who is on turn */
		this.playerOnTurn = null;
		this.waitingForMissiles = false;

		/* game results */
		this.results = [];
	},

	/* called when game finished (only one tank survived) */
	gameFinished: function() {
		if(this.tanks.length != 0) {
			this.playerKilled(this.tanks[0].player);
		}

		Controls.active = false;
		Controls.hide();
		this.stop();
		Results.init();
	},

	/* creates a tank on x with player */
	addTank: function(player, x) {
		var y = this.terrain[Math.round(x)];
		var tank = new Tank(x, y, player);
		this.tanks.push(tank);

		/* make loop */
		player._next = this.tanks[0].player;
		this.tanks[0].player._prev = player;

		/* connect player after last player in chain */
		if(this.tanks.length > 1) {
			this.tanks[this.tanks.length - 2].player._next = player;
			player._prev = this.tanks[this.tanks.length - 2].player;
		}

		this.setPlayerOnTurn(player);
		return tank;
	},

	/* creates a missile */
	addMissile: function(klass, x, y, velx, vely, tank) {
		var missile = new Missile(klass, x, y, velx, vely, tank);
		this.missiles.push(missile);
		return missile;
	},

	/* sets player on turn */
	setPlayerOnTurn: function(player) {
		if(this.playerOnTurn) {
			this.playerOnTurn.inactive();
		}

		this.playerOnTurn = player;

		if(this.playerOnTurn) {
			this.playerOnTurn.active();
		}
	},

	/* player on turn finished (next player is on turn) */
	playerFinished: function() {
		/* now wait for missiles. when all missiles will be destroyed, nextPlayer
		 * becomes playerOnTurn */
		this.nextPlayer = this.playerOnTurn._next;
		this.setPlayerOnTurn(null);
		this.waitingForMissiles = true;
	},

	/* called when tank was destroyed (player killed) */
	playerKilled: function(player) {
		if(!player._killed) {
			this.results.push({
					"name": player.name,
					"color": player.color,
					"score": player.score
				});

			player._killed = true;
			player.killed();
			player._next._prev = player._prev;
			player._prev._next = player._next;

			if(this.nextPlayer == player) {
				this.nextPlayer = player._next;
			}

			if(this.playerOnTurn == player) {
				this.setPlayerOnTurn(this.nextPlayer);
			}
		}
	},
	
	/* draws terrain to terrain canvas */
	drawTerrain: function() {
		var ctx = this.terrainContext;
		ctx.save();
		ctx.clearRect(0, 0, this.width, this.height);
		ctx.fillStyle = this.style("terrain", "background-color");

		for(var i = 0; i != this.width; i++) {
			ctx.fillRect(i, this.terrain[i], 1, this.height - this.terrain[i]);
		}

		ctx.restore();
	},

	/* one game step */
	step: function() {
		this.update();
		this.draw();
	},

	/* updates world */
	update: function() {
		if(this.waitingForMissiles) {
			if(this.missiles.length == 0) {
				/* all missiles were destroyed! */
				this.waitingForMissiles = false;
				this.setPlayerOnTurn(this.nextPlayer);
			}
		}

		if(this.tanks.length <= 1) {
			this.gameFinished();
		}

		/* updates tanks */
		for(var i = 0; i != this.tanks.length; i++) {
			this.tanks[i].update(this.stepTime);
		}

		/* missiles */
		for(var i = 0; i != this.missiles.length; i++) {
			this.missiles[i].update(this.stepTime);
		}

		/* explosions */
		for(var i = 0; i != this.explosions.length; i++) {
			this.explosions[i].update(this.stepTime);
		}

		/* delete what should be deleted */
		var newMissiles = []
		for(var i = 0; i != this.missiles.length; i++) {
			if(this.missiles[i].alive) {
				newMissiles.push(this.missiles[i]);
			}
		}
		this.missiles = newMissiles;

		var newTanks = []
		for(var i = 0; i != this.tanks.length; i++) {
			if(this.tanks[i].alive) {
				newTanks.push(this.tanks[i]);
			}
		}
		this.tanks = newTanks;

		var newExplosions = []
		for(var i = 0; i != this.explosions.length; i++) {
			if(this.explosions[i].alive) {
				newExplosions.push(this.explosions[i]);
			}
		}
		this.explosions = newExplosions;

	},

	/* draws world */
	draw: function() {
		var ctx = this.context;
		ctx.save();

		/* clears all dirty rectangles */
		for(var i = 0; i != this.dirtyRects.length; i++) {
			var rect = this.dirtyRects[i];
			ctx.clearRect(rect[0], rect[1], rect[2], rect[3]);
		}
		this.dirtyRects = [];

		/* draws tanks */
		for(var i = 0; i != this.tanks.length; i++) {
			this.dirtyRects.push(this.tanks[i].draw(this.context));
		}

		/* missiles */
		for(var i = 0; i != this.missiles.length; i++) {
			this.dirtyRects.push(this.missiles[i].draw(this.context));
		}

		/* and explosions */
		for(var i = 0; i != this.explosions.length; i++) {
			this.dirtyRects.push(this.explosions[i].draw(this.context));
		}

		ctx.restore();
	},

	/* makes an explosion (obj is Missile or Tank) */
	makeExplosion: function(obj) {
		this.explosions.push(new Explosion(obj));
	}

};

$(document).ready(function() {
		var element = $("#battlejs");
		BattleJS.init(element);
		Controls.init();
		Menu.init();

		$(".loading").hide();
	});
