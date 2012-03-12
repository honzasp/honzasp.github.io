var Board = {
	width: 15,
	height: 15,

	/* hraci deska (dvourozmerne pole [y][x]). 0 - nic, 1 - krizek, 2 - kolecko */
	board: [],

	/* hrac na tahu (1 - krizek, 2 - kolecko) */
	onTurn: 0,

	/* zakladni <div> desky */
	element: null,

	/* odstavec se zpravou */
	messageBox: null,

	/* hraje se porad (nevyhral jeste nekdo)? */
	isActive: true,

	/** inicializace **/
	init: function() {
		this.element = $("#board");
		this.element.text("");

		/* deska je ulozena jako tabulka */
		this.board = [];
		var htmlTable = "<table><tbody>";
		var x, y;

		for(y = 0; y != this.height; y++) {
			this.board[y] = [];
			htmlTable += "<tr>";
			for(x = 0; x != this.width; x++) {
				this.board[y][x] = 0;
				htmlTable += "<td></td>";
			}
			htmlTable += "</tr>";
		}
		htmlTable += "</tbody></table>";

		this.element.html(htmlTable);
		this.rows = $("tr", this.element);

		/* odstavec se zpravou */
		this.element.append("<p id='messageBox'></p>");
		this.messageBox = $("#messageBox");

		/* priradit kazdemu td souradnice do promennych _x a _y DOM objektu */
		for(y = 0; y != this.height; y++) {
			for(x = 0; x != this.height; x++) {
				var td = this.getTd(x, y);
				td._x = x;
				td._y = y;
			}
		}

		/* zachytavani click-u */
		this.element.click(this.clicked);

		/* zacina krizek */
		this.turns(1);
		this.active(true);
	},

	/** posluchac kliku **/
	clicked: function(e){
		if(typeof(e.target._x) != "undefined") {
			Board.move(e.target._x, e.target._y);
		}
	},

	/** deinicializace **/
	deinit: function() {
		this.element.unbind("click", this.clicked);
		this.element.html("");
	},

	/** ziska policko desky (jako bunku tabulky) **/
	getTd: function(x, y) {
		var row = this.rows[y];
		var td = $("td", row)[x];
		return td;
	},

	/** nastavi jestli je hra aktivni nebo ne (isActive) **/
	active: function(a) {
		if(this.isActive = a) {
			this.element.addClass("active");
			this.element.removeClass("inactive");
		} else {
			this.element.removeClass("active");
			this.element.addClass("inactive");
		}
	},

	/** hrac tahne na pole x, y **/
	move: function(x, y) {
		if(this.isActive) {
			if(this.board[y][x] == 0) {
				this.board[y][x] = this.onTurn;
				if(this.onTurn == 1) {
					$(this.getTd(x, y)).text("X");
					this.turns(2);
				} else {
					$(this.getTd(x, y)).text("O");
					this.turns(1);
				}

				var row = this.checkWin(x, y);
				if(row.length != 0) {
					this.highlightRow(row);
					if(this.onTurn == 1) {
						this.message("Kolečko vyhrálo");
					} else {
						this.message("Křížek vyhrál");
					}
					this.active(false);
					this.addResetButton();
				}
			} else {
				this.message("Tam už někdo je");
			}
		}
	},

	/** zvyrazni radu (prida tridu highlighted) **/
	highlightRow: function(row) {
		var i;
		for(i = 0; i != row.length; i++) {
			$(this.getTd(row[i][0], row[i][1])).addClass('highlighted');
		}
	},

	/** zkontroluje jestli nahodou hrac tahem na x, y nevyhral. pokud ano, vrati
	 * pole se souradnicemi na kterych je vitezna rada, pokud ne tak prazdne pole **/
	checkWin: function(x, y) {
		var player = this.board[y][x];
		var a, b;
		var row; // pole souradnic bunek v rade

		/* vodorovne */
		row = [[x, y]];
		for(a = x + 1; a - x < 5 && a < this.width; a++) {
			if(this.board[y][a] == player) {
				row[row.length] = [a, y];
			} else {
				break;
			}
		}

		for(a = x - 1; x - a < 5 && a >= 0; a--) {
			if(this.board[y][a] == player) {
				row[row.length] = [a, y];
			} else {
				break;
			}
		}

		if(row.length >= 5) {
			return row;
		}

		/* svisle */
		row = [[x, y]];
		for(a = y + 1; a - y < 5 && a < this.height; a++) {
			if(this.board[a][x] == player) {
				row[row.length] = [x, a];
			} else {
				break;
			}
		}

		for(a = y - 1; y - a < 5 && a >= 0; a--) {
			if(this.board[a][x] == player) {
				row[row.length] = [x, a];
			} else {
				break;
			}
		}

		if(row.length >= 5) {
			return row;
		}

		/* sikmo / */
		row = [[x, y]];
		for(a = x + 1, b = y - 1; x - a < 5 && b >= 0 && a < this.width; a++, b--) {
			if(this.board[b][a] == player) {
				row[row.length] = [a, b];
			} else {
				break;
			}
		}

		for(a = x - 1, b = y + 1; a - x < 5 && a >= 0 && b < this.height; a--, b++) {
			if(this.board[b][a] == player) {
				row[row.length] = [a, b];
			} else {
				break;
			}
		}

		if(row.length >= 5) {
			return row;
		}

		/* sikmo \ */
		row = [[x, y]];
		for(a = x - 1, b = y - 1; y - b < 5 && a >= 0 && b >= 0; a--, b--) {
			if(this.board[b][a] == player) {
				row[row.length] = [a, b];
			} else {
				break;
			}
		}

		for(a = x + 1, b = y + 1; b - y < 5 && a < this.width && b < this.height; a++, b++) {
			if(this.board[b][a] == player) {
				row[row.length] = [a, b];
			} else {
				break;
			}
		}

		if(row.length >= 5) {
			return row;
		}

		return [];
	},

	/** prida cudlik na resetovani hry **/
	addResetButton: function() {
		var button = $("<button>Začít znovu</button>");
		button.hide();
		this.element.append(button);
		button.fadeIn("slow");

		var board = this;
		button.click(function() {
				board.element.slideUp("slow", function() {
						board.deinit();
						board.init();
						board.element.slideDown("slow");
					});
			});
	},

	/** nastavi hrace ktery tahne a da o tom zpravu **/
	turns: function(who) {
		this.onTurn = who;
		if(who == 1) {
			this.message("Křížek je na tahu");
		} else {
			this.message("Kolečko je na tahu");
		}
	},

	/** nastavi zpravu **/
	message: function(msg) {
		this.messageBox.text(msg);
	}
};

$(document).ready(function() { 
		Board.init();
	});
