var Results = {

	init: function() {
		BattleJS.results.sort(function(a, b) {
				return b.score - a.score;
			});

		this.resultsTable = $(
			"<div class='results'>" +
				"<h1>Results</h1>" +
				"<table>" +
					"<thead>" +
						"<tr> <th>Name</th> <th>Score</th> </tr>" +
					"</thead>" +
					"<tbody>" +
					"</tbody>" +
				"</table>" +
				"<button type='button'>Restart</button>" +
			"</div>");

		$("button", this.resultsTable).click(function() {
				location.reload();
			});

		var tbody = $("tbody", this.resultsTable);

		for(i in BattleJS.results) {
			var row = $(
				"<tr>" +
					"<td>" + BattleJS.results[i].name + "</td>" +
					"<td>" + Math.round(BattleJS.results[i].score) + "</td>" +
				"</tr>");
			row.css("background-color", BattleJS.results[i].color);
			row.appendTo(tbody);
		}

		this.resultsTable.appendTo(BattleJS.element);
	}

}
