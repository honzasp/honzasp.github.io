var Fishy = function(element) {
	this.element = element;
	this.width = Fishy.width;
	this.height = Fishy.height;
	this.stepTime = 1 / Fishy.fps;
	this.fishPerSecond = Fishy.fishPerSecond;

	this.element.css("width", this.width);
	this.element.css("height", this.height);

	this.canvas = $("<canvas></canvas>");
	this.canvas.attr("width", this.width);
	this.canvas.attr("height", this.height);
	this.canvas.hide();
	this.element.append(this.canvas);

	this.backgroundColor = "#bfddff";

	if(this.canvas[0].getContext) {
		this.context = this.canvas[0].getContext('2d');
	}

	if(!this.context) {
		this.element.html("<div class='error'>Unable to get 2D drawing context</div>");
		return;
	}

	this.menuElement = $("<div class='menu'></div>");
	this.menuElement.appendTo(this.element);
};

Fishy.width = 700;
Fishy.height = 500;
Fishy.fps = 35;

Fishy.prototype = {

	createPlayer: function() {
		this.player = new Player(this);
		this.player.x = this.width / 2;
		this.player.y = this.height / 2;
		this.player.size = 30;
		this.player.force = 500;
	},

	createFish: function() {
		this.fishList = null;

		for(var i = 0; i <= 5; i++) {
			this.newFish();
		}
	},

	newFish: function() {
		if(!this.player) {
			return;
		}

		var size;
		if(this.player.size < Fish.maxSize) {
			size = Math.random() * (5 + this.player.size * 1.6) + Fish.minSize;

			if(size > Fish.maxSize) {
				size = Fish.maxSize;
			}
		} else {
			size = Math.random() * Fish.maxSize + 8;
		}

		var velX = Math.random() * (100 + this.player.size * 2.0) + 20;
		if(velX > Fish.maxSpeed) {
			velX = Fish.maxSpeed;
		}

		var y = Math.random() * this.height;
		var x;

		this.fishPerSecond = 0.6 + this.player.size / Fish.maxSize * 0.8;

		if(Math.random() > 0.5) {
			x = -size * Fish.width;
		} else {
			velX = -velX;
			x = this.width;
		}

		var fish = new Fish(this, x, y, velX, size);
		fish.next = this.fishList;
		this.fishList = fish;
	},

	randomFish: function() {
		this.newFish();

		if(this.player) {
			var ths = this;
			setTimeout(function() {
					ths.randomFish();
				}, (Math.random() * 1000) / this.fishPerSecond);
		}
	},

	showScore: function() {
		this.scoreElement = $("<div class='score'></div>");
		this.scoreElement.appendTo(this.element);
		this.playerSizeChanged();
	},

	playerSizeChanged: function() {
		this.scoreElement.text(Math.round(this.player.size * 100));

		if(this.player.size > Fish.maxSize * 10) {
			this.playerWon();
		}
	},

	start: function() {
		this.createPlayer();
		this.createFish();
		this.showScore();
		this.bindControls();
		this.canvas.show();

		var ths = this;
		this.timer = setInterval(function(){ths.step();}, this.stepTime * 1000);
		this.randomFish();
	},

	stop: function() {
		this.unbindControls();

		if(this.scoreElement) {
			this.scoreElement.remove();
		}

		if(this.timer) {
			clearInterval(this.timer);
		}
		this.fishList = undefined;
		this.player = undefined;
	},

	step: function() {
		this.update();
		this.draw();
	},

	update: function() {
		for(var fish = this.fishList; fish; fish = fish.next) {
			fish.update(this.stepTime);
			this.checkCollision(fish);
		}
		this.removeDead();

		this.player.update(this.stepTime);
		if(this.player.dead) {
			this.playerKilled();
		}
	},

	draw: function() {
		var ctx = this.context;
		ctx.fillStyle = this.backgroundColor;
		ctx.fillRect(0, 0, this.width, this.height);

		for(var fish = this.fishList; fish; fish = fish.next) {
			fish.draw(ctx);
		}

		if(this.player) {
			this.player.draw(ctx);
		}
	},

	removeDead: function() {
		var prev;
		var next;
		var fish = this.fishList;

		while(fish) {
			next = fish.next;
			if(fish.dead) {
				if(prev) {
					prev.next = next;
				} else {
					this.fishList = next;
				}
			}
			prev = fish;
			fish = next;
		}
	},

	checkCollision: function(fish) {
		var fx = fish.x;
		var fy = fish.y;
		var fw = fish.width();
		var fh = fish.height();

		var px = this.player.x;
		var py = this.player.y;
		var pw = this.player.width();
		var ph = this.player.height();

		if((
				(fx <= px && px <= fx + fw) ||
				(fx <= px + pw && px + pw <= fx + fw) ||
				(px <= fx && fx + fw <= px + pw)
			) && (
				(fy <= py && py <= fy + fh) ||
				(fy <= py + ph && py + ph <= fy + fh) ||
				(py <= fy && fy + fh <= py + ph)
			)) {
			this.player.collision(fish);
		}
	},

	bindControls: function() {
		var ths = this;

		$("body").keypress(function(evt) {
				evt.preventDefault();
			});

		$(document).bind("keydown keypress", function(evt) {
        var eat = false;
        switch(evt.which) {
        case 37:
          ths.player.accX = -1;
          eat = true;
          break;
        case 39:
          ths.player.accX = 1;
          eat = true;
          break;
        case 38:
          ths.player.accY = -1;
          eat = true;
          break;
        case 40:
          ths.player.accY = 1;
          eat = true;
          break;
        }

				if(eat) {
					evt.preventDefault();
					evt.stopPropagation();
				}
			});

		$(document).keyup(function(evt) {
        var eat = false;
        switch(evt.which) {
        case 37:
        case 39:
          ths.player.accX = 0;
          eat = true;
          break;
        case 38:
        case 40:
          ths.player.accY = 0;
          eat = true;
          break;
        }

				if(eat) {
					evt.preventDefault();
					evt.stopPropagation();
				}
			});

    this.canvas.bind("mousedown mousemove", function(evt) {
      if(evt.which == 1) {
        controlMove(evt.pageX, evt.pageY);
      }
    });

    this.canvas.bind("touchstart touchmove", function(evt) {
      controlMove(evt.pageX, evt.pageY);
      evt.preventDefault();
    });

    var controlMove = function(controlX, controlY) {
      if(ths.player) {
        var offset = ths.canvas.offset();
        var relX = (controlX - offset.left) - ths.player.x;
        var relY = (controlY - offset.top) - ths.player.y;

        var relSize = Math.sqrt(relX * relX + relY * relY);
        if(relSize != 0) {
          var acc = Math.min(relSize / 100.0, 1.0);
          ths.player.accX = acc * relX / relSize;
          ths.player.accY = acc * relY / relSize;
        }
      }
    };

    this.canvas.bind("mouseup", function(evt) {
      if(ths.player && evt.which == 1) {
        ths.player.accX = 0;
        ths.player.accY = 0;
      }
    });

    this.canvas.bind("touchend", function(evt) {
      if(ths.player) {
        ths.player.accX = 0;
        ths.player.accY = 0;
      }
    });

	},

	unbindControls: function() {
		$("body").unbind("keypress");
		$(document).unbind("keydown keypress");
		$(document).unbind("keyup");
    $(document).unbind("mousedown mousemove");
    $(document).unbind("mouseup");
	},

	showMenu: function() {
		this.stop();
		this.unbindControls();

		this.canvas.hide();
		this.menuElement.empty();

		this.menuElement.append("<h1>Fishy in Javascript</h1>");

		var startButton = $("<div class='clickable'>Start</div>");
		this.menuElement.append(startButton);
		var ths = this;
		startButton.click(function() {
				ths.hideMenu();
				ths.start();
			});
	},

	hideMenu: function() {
		this.menuElement.empty();
	},

	playerKilled: function() {
		this.showMessage("You were eaten");
		this.stop();
	},

	playerWon: function() {
		this.showMessage("You ate everything");
		this.stop();
	},

	showMessage: function(text) {
		this.canvas.hide();
		this.menuElement.empty();
		
		var textElement = $("<h1></h1>");
		textElement.text(text);
		textElement.appendTo(this.menuElement);

		var menuButton = $("<div class='clickable'>Back to the menu</div>");
		var ths = this;
		menuButton.click(function() {
				ths.hideMenu();
				ths.showMenu();
			});
		menuButton.appendTo(this.menuElement);
	},

};

$(document).ready(function() {
		var fishy = new Fishy($("#fishy"));
		fishy.showMenu();
	});
