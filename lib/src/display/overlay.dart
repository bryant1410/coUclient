part of couclient;

class Overlay {
	Overlay(String id) {
		overlay = querySelector("#" + id);

		// closing
		if (overlay.querySelector(".close") != null) {
			overlay.querySelector(".close").onClick.listen((_) {
				this.close();
			});
		}
		document.onKeyUp.listen((KeyboardEvent e) {
			if (!overlay.hidden && e.keyCode == 27) {
				this.close();
			}
		});
	}

	Element overlay;

	open() {
		overlay.hidden = false;
	}

	close() {
		overlay.hidden = true;
	}
}

// SET UP OVERLAYS //

Overlay newDay;
Overlay imgMenu;

void setUpOverlays() {
	newDay = new NewDayOverlay("newday");
	imgMenu = new ImgOverlay("pauseMenu");
}

class ImgOverlay extends Overlay {
	Element bar, levelNum;
	ImgOverlay(String id):super(id) {
		bar = querySelector("#pm-level-bar");
		levelNum = querySelector("#pm-level-num");
	}

	open() {
//		// Calculate level/img stats
//		int currimg = metabolics.img;
//		int allimg = metabolics.lifetime_img;
//		int level = metabolics.level;
//		int levelimg = metabolics.img_current;
//		int nextimg = metabolics.img_next;
//		int imgtonext = nextimg - allimg;
//		num pcToNext = ((100 / nextimg) * levelimg);
//
//		// Display img bar
//		bar.style.height = pcToNext.toString() + '%';
//		levelNum.text = level.toString();

		// Show
		overlay.hidden = false;
	}
}

class NewDayOverlay extends Overlay {
	NewDayOverlay(String id):super(id) {
		new Service(['newDay', 'newDayFake'], (event) {
			open();
		});
	}

	open() {
		String maxenergy = metabolics.maxEnergy.toString();
		overlay.querySelector("#newday-date").text = clock.dayofweek + ", the " + clock.day + " of " + clock.month;
		overlay.querySelector("#newday-refill-1").text = maxenergy;
		overlay.querySelector("#newday-refill-2").text = maxenergy;
		overlay.hidden = false;
		new Timer(new Duration (milliseconds: 100), () {
			overlay.querySelector("#newday-sun").classes.add("up");
			overlay.querySelector("#newday-refill-disc").classes.add("full");
		});
		overlay.querySelector("#newday-button").onClick.first.then((_) => close());
		// TODO: new day screen sound
	}

	close() {
		overlay.hidden = true;
		overlay.querySelector("#newday-sun").classes.remove("up");
		overlay.querySelector("#newday-refill-disc").classes.remove("full");
	}
}