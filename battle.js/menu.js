var Menu = {

	colors: {
		"red": "#ff282d",
		"green": "#439b43",
		"blue": "#2264d0",
		"orange": "#d5971e",
		"gray": "#888888",
		"brown": "#823311"
	},

	defaultColor: "blue",

	/* creates menu */
	init: function() {
		this.element = $(
			"<form class='menu'>" +
				"<h1>Players</h1>" +
			"</form>");
		this.element.appendTo(BattleJS.element);

		var ths = this;

		/* table with players */
		this.playersTable = $(
			"<table class='players'>" +
				"<thead>" +
					"<tr> <th>Name</th> <th>Color</th> </tr>" +
				"</thead>" +
				"<tbody>" +
				"</tbody>" +
			"</table>"
		);
		this.playersTable.hide();
		this.playersTable.appendTo(this.element);

		this.addPlayer(Human, "Strawberry", "red", true);
		this.addPlayer(Human, "Lime", "green", true);
		this.addPlayer(Human, "Blueberry", "blue", true);
		this.addPlayer(Human, "Orange", "orange", true);

		/* "add" and "remove" buttons */
		this.addButton = $("<input type='button' name='add' value='Add player'>");
		this.addButton.click(function() {
				ths.addPlayer(Human, "Player name", this.defaultColor);
			});
		this.addButton.appendTo(this.element);

		this.removeButton = $("<input type='button' name='remove' value='Remove player'>");
		this.removeButton.click(function() {
				ths.removePlayer(Human, "", "");
			});
		this.removeButton.appendTo(this.element);

		$("input[type=button]", this.element).wrapAll("<div></div>");

		/* button "run" */
		this.runButton = $("<input class='run' type='submit' value='Run'>");
		this.runButton.appendTo(this.element);

		this.element.submit(function(e) {
				e.preventDefault();
				ths.run();
				return false;
			});

		this.active = true;
		this.playersTable.slideDown(500);
	},

	/* adds new player to players table */
	addPlayer: function(klass, name, playerColor, isDefault) {
		var row = $("<tr class='player'></tr>");

		var nameInput = $("<input type='text' value='" + name + "'>");
		nameInput.appendTo(row);
		nameInput.wrap("<td class='name'></td>");

		/*
		var colorSelect = $("<select></select>");
		for(colorName in this.colors) {
			var option = $("<option value='" + this.colors[colorName] + "'>" + colorName + "</select>");
			option.css("background-color", this.colors[colorName]);
			option.appendTo(colorSelect);
		}
		colorSelect.appendTo(row);
		*/

		var inputName = "playerColor" + $("tr", this.playersTable).size();

		var colorElm = $("<td class='color'></td>");
		for(colorName in this.colors) {
			var input = $("<input type='radio' name='" + inputName + "' value='" + this.colors[colorName] +
				"'>");
			var label = $("<label>" + colorName + "</label>");

			if(colorName == playerColor) {
				input.attr("checked", "checked");
			}
			
			input.appendTo(colorElm);
			label.appendTo(colorElm);
			label.css("color", this.colors[colorName]);
		}
		colorElm.appendTo(row);

		row.hide();
		row.appendTo(this.playersTable);

		nameInput[0].focus();
		nameInput[0].select();

		if(isDefault) {
			row.show();
		} else {
			row.fadeIn(200);
		}
	},

	/* removes last player from players table */
	removePlayer: function() {
		var rows = $("tbody tr", this.playersTable);

		if(rows.size() > 2) {
			var last = $(rows[rows.size() - 1]);
			last.fadeOut(200, function() {
					last.remove();
				});
		}
	},

	/* runs game */
	run: function() {
		if(this.active) {
			this.active = false;

			//this.element.hide();
			this.element.fadeOut(500, function() {
				$("tbody tr", this.playersTable).each(function(i, e) {
						var row = $(e);
						var name = $("td.name input", row).val();
						var color = $("td.color input:checked", row).val();

						BattleJS.addTank(new Human(name, color), Math.random() * BattleJS.width);
					});

					BattleJS.start();
				});
		}
	}

};
