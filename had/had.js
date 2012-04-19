var Snake = {
	/** 2d kreslici kontext **/
	context: null,

	/** element hry **/
	element: null,

	/** cudlik na restartovani hry **/
	resetButton: null,

	/** delka kroku v sekundach **/
	stepTime: 1 / 10,

	/** sirka hraciho planu **/
	width: 40,

	/** vyska hraciho planu **/
	height: 30,

	/** velikost policka **/
	squareSize: 12,

	/** hraci plan[x][y].
	 * 0 - nic
	 * 1 - zed
	 * 2 - had
	 * 3 - zradlo
	 */
	map: [[]],

	/** barvy jednotlivych policek mapy **/
	squareColors: ["#fff", "#888", "#008", "#800"],

	/** barva mrizky **/
	gridColor: "#ddd",

	/** had (pole souradnic [x, y]) **/
	snake: null,

	/** smer hada **/
	direction: null,

	/** fronta zmen smeru hada **/
	dirChangeQueue: [],

	/** delka hada **/
	snakeLength: 0,

	/** je had nazivu? **/
	alive: true,

	/** inicializace hada **/
	init: function() {
		/* inicalizace canvasu */
		if(!this.context) {
			this.element = $("#snake");
			var canvasWidth = this.width * this.squareSize;
			var canvasHeight = this.height * this.squareSize;
			this.element.html("<canvas width='" + canvasWidth + "' height='"  + canvasHeight + "'></canvas>");
			var canvas = $("canvas", this.element)[0];

			if(canvas.getContext) {
				this.context = canvas.getContext("2d");
				if(!this.context) {
					this.element.text("Nepovedlo se získat 2D kreslící kontext");
					return;
				}

			} else {
				canvas.html("Váš prohlížeč bohužel nemá podporu značky canvas");
			}
		}

		$(document).bind("keydown keypress", function(e){Snake.keypress(e);});
		this.element.bind("mousedown touchstart", function(e){Snake.mousedown(e);});
		
		/* a html */
		this.scoreElement = $("<div></div>");
		this.scoreElement.appendTo(this.element);
		this.score(5);

		this.resetButton = $("<button>Restartovat</button>");
		this.resetButton.hide();
		this.resetButton.click(function() { Snake.reset(); });
		this.resetButton.appendTo(this.element);

		this.snake = [[5, 5]];
		this.direction = [1, 0];
		this.dirChangeQueue = [];
		this.alive = true;

		this.pause();

		var i, j;
		/* inicializace mapy */
		this.map = [];
		for(i = 0; i != this.width; i++) {
			this.map[i] = [];
			for(j = 0; j != this.height; j++) {
				this.map[i][j] = 0;
			}
		}

		/* zdi kolem dokola */
		for(i = 0; i != this.width; i++) {
			this.map[i][0] = 1;
			this.map[i][this.height - 1] = 1;
		}

		for(i = 0; i != this.height; i++) {
			this.map[0][i] = 1;
			this.map[this.width - 1][i] = 1;
		}

		/* zradlo */
		this.generateMeal();
		this.generateMeal();

		/* nakresleni mapy */
		this.drawMap();

		this.start();
	},

	/** klavesa zmacknuta **/
	keypress: function(evt) {

		switch(evt.keyCode) {
    case 83: /* s */
    case 40: /* dolu */
      this.goDown();
			evt.preventDefault();
			break;

    case 87: /* w */
		case 38: /* nahoru */
      this.goUp();
			evt.preventDefault();
			break;

    case 65: /* a */
		case 37: /* doleva */
      this.goLeft();
			evt.preventDefault();
			break;

    case 68: /* d */
		case 39: /* doprava */
      this.goRight();
			evt.preventDefault();
			break;

		case 19: /* pause */
		case 80: /* p */
			if(this.paused) {
				this.start();
			} else {
				this.pause();
			}
			break;

		}
	},

  mousedown: function(evt) {
    if(!this.alive) {
      return;
    }

    var snakeHead = {
      top: this.snake[0][1],
      left: this.snake[0][0]
    };
    var headX = (snakeHead.left + 0.5) * this.squareSize;
    var headY = (snakeHead.top + 0.5) * this.squareSize;

    var offset = this.element.offset();
    var clickX = evt.pageX - offset.left;
    var clickY = evt.pageY - offset.top;

    if(this.direction[0] == 0) {
      /* doleva/doprava */
      if(clickX > headX) {
        this.goRight();
      } else {
        this.goLeft();
      }
    } else {
      /* nahoru/dolu */
      if(clickY > headY) {
        this.goDown();
      } else {
        this.goUp();
      }
    }

    evt.preventDefault();
  },

  goDown: function() {
    this.dirChangeQueue.push([0, 1]);
  },

  goUp: function() {
    this.dirChangeQueue.push([0, -1]);
  },

  goLeft: function() {
    this.dirChangeQueue.push([-1, 0]);
  },

  goRight: function() {
    this.dirChangeQueue.push([1, 0]);
  },

	pause: function() {
		if(this.timer) {
			clearInterval(this.timer);
			this.timer = null;
		}

		this.paused = true;
	},

	start: function() {
		this.pause();
		this.timer = setInterval(function(){Snake.step();}, this.stepTime * 1000);
		this.paused = false;
	},

	/** zacne od zacatku **/
	reset: function() {
		this.pause();

		this.scoreElement = null;
		this.resetButton = null;
		this.context = null;

		this.element.slideUp("slow", function() {
				Snake.element.html("");
				Snake.init();
				Snake.element.slideDown("slow");
			});
	},

	/** nakresli mapu **/
	drawMap: function() {
		var x, y;
		for(x = 0; x != this.width; x++) {
			for(y = 0; y != this.height; y++) {
				this.drawSquare(x, y);
			}
		}
	},

	/** nakresli ctverecek mapy **/
	drawSquare: function(x, y) {
		var c = this.context;
		var size = this.squareSize;

		c.fillStyle = this.squareColors[this.map[x][y]];
		c.strokeStyle = this.gridColor;

		c.fillRect(x * size, y * size, size, size);
		//c.strokeRect(x * size + 0.5, y * size, size, size);
	},

	/** had narazil **/
	hit: function() {
		this.alive = false;
		this.scoreElement.text("Had zemřel a byl " + this.snakeLength + " políček dlouhý");
		this.resetButton.fadeIn("slow");
	},

	/** zmeni obsah ctverecku mapy **/
	square: function(x, y, val) {
		this.map[x][y] = val;
		this.drawSquare(x, y);
	},

	/** zmeni skore (delku hada) **/
	score: function(val) {
		this.snakeLength = val;
		if(val != 0) {
			this.scoreElement.text("Had je " + val + " políček dlouhý");
		} 
	},

	/** udela nahodne zradlo **/
	generateMeal: function() {
		var x, y;

		do {
			x = Math.round(Math.random() * this.width);
			y = Math.round(Math.random() * this.height);
		} while(this.map[x][y] != 0);

		this.map[x][y] = 3;
		this.drawSquare(x, y);
	},
	
	/** herni krok **/
	step: function() {
		if(!this.alive) {
			return;
		}

		var c = this.context;
		c.save();

		while(this.dirChangeQueue.length != 0) {
			var newDir = this.dirChangeQueue.shift();
      var oldDir = this.direction;

      /* pouzijou se jen ty zmeny, ktere toci hadem doprava nebo doleva (z
       * pohledu jeho hlavy), ostatni se zahodi */
      if(newDir[0] != -oldDir[0] || newDir[1] != -oldDir[1]) {
        this.direction = newDir;
        break;
      }
		}

		var x = this.snake[0][0] + this.direction[0];
		var y = this.snake[0][1] + this.direction[1];
		var sq = this.map[x][y];

		if(sq == 1 || sq == 2) {
			this.hit();
		} else {
			if(sq == 3) {
				this.score(this.snakeLength + 5);
				this.generateMeal();
			}

			this.square(x, y, 2);
			this.drawSquare(x, y);
			this.snake.unshift([x, y]);

			if(this.snake.length > this.snakeLength) {
				var end = this.snake.pop();
				this.square(end[0], end[1], 0);
				this.drawSquare(end[0],end[1]);
			}
		}

		c.restore();
	}

};

$(document).ready(function(){ Snake.init(); });
