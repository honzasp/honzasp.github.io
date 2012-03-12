var Clock = {
	/** 2d kreslici kontext **/
	context: null,

	/** sirka canvasu **/
	width: 0,

	/** vyska canvasu **/
	height: 0,

	/** velikost hodin (mensi rozmer canvasu) **/
	size: 0,

	/** inicializace hodin **/
	init: function() {
		var element = $("#clock");
		var canvas = $("canvas", element)[0];

		if(canvas.getContext) {
			this.context = canvas.getContext("2d");
			if(!this.context) {
				this.element.text("Nepovedlo se získat 2D kreslící kontext");
				return;
			}

			this.timer = setInterval(function(){Clock.step();}, 1000);
			this.width = parseInt($(canvas).css("width"), 10);
			this.height = parseInt($(canvas).css("height"), 10);
			this.size = Math.min(this.width, this.height);

		} else {
			this.element.text($(canvas).text());
			return;
		}

	},

	/** deinicializace hodin **/
	deinit: function() {
		if(this.timer) {
			clearInterval(this.timer);
		}
	},
	
	/** aktualizuje hodiny **/
	step: function() {
		var c = this.context;
		c.clearRect(0, 0, this.width, this.height);

		var now = new Date();
		var i;

		c.save();
		c.translate(this.size / 2.0, this.size / 2.0);
		c.scale(this.size / 2.0, this.size / 2.0);
		c.fillStyle = "#4980cb";
		c.strokeStyle = "#000";
		c.lineCap = "round";
		c.lineWidth = 0.01;

		/* cifernik */
		c.beginPath();
		c.arc(0, 0, 1, 0.0, Math.PI * 2.0, true);
		c.fill();

		c.globalCompositeOperation = "destination-out";
		c.beginPath();
		c.arc(0, 0, 0.9, 0.0, Math.PI * 2.0, true);
		c.fill();

		c.globalCompositeOperation = "source-over";

		/* znacky minut */
		c.save()
		c.lineWidth = 0.03;
		c.strokeStyle = "#333";
		for(i = 0; i != 60; i++) {
			c.beginPath();
			c.moveTo(0.0, 0.85);
			c.lineTo(0.0, 0.8);
			c.rotate(Math.PI * 2 / 60);
			c.stroke();
		}
		c.restore();

		/* znacky hodin */
		c.save();
		c.lineWidth = 0.05;
		for(i = 0; i != 12; i++) {
			c.beginPath();
			c.moveTo(0.0, 0.85);
			c.lineTo(0.0, 0.75);
			c.rotate(Math.PI * 2 / 12);
			c.stroke();
		}
		c.restore();

		var hours = now.getHours();
		var mins = now.getMinutes();
		var secs = now.getSeconds();

		/* hodinova rucicka */
		c.save();
		c.lineWidth = 0.06;
		c.strokeStyle = c.fillStyle = "#000";
		{
			c.beginPath();
			c.rotate((hours / 12 + mins / (12 * 60) + secs / (12 * 60 * 60)) * Math.PI * 2);
			c.moveTo(0.0, -0.5);
			c.lineTo(0.0, 0.1);
			c.stroke();
		}
		c.restore();

		/* minutova rucicka */
		c.save();
		c.lineWidth = 0.04;
		c.strokeStyle = c.fillStyle = "#000";
		{
			c.beginPath();
			c.rotate((mins / 60 + secs / (60 * 60)) * Math.PI * 2);
			c.moveTo(0.0, -0.83);
			c.lineTo(0.0, 0.1);
			c.stroke();
		}
		c.restore();

		/* sekundova rucicka */
		c.save()
		c.lineWidth = 0.035;
		c.strokeStyle = c.fillStyle = "#275a99";
		{
			c.beginPath();
			c.rotate((secs / 60) * Math.PI * 2);
			c.moveTo(0.0, -0.85);
			c.lineTo(0.0, 0.1);
			c.stroke();

			/*
			c.beginPath();
			c.arc(0, 0, 0.01, 0, Math.PI * 2);
			c.fill();
			*/
		}
		c.restore();

		c.restore();
	}

};

$(document).ready(function(){ Clock.init(); });

