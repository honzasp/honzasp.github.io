---
layout: page
title: Krt
menu: krt
---

One of the largest JavaScript-based games I have made.  Players engage in a
battle of circular tanks, shooting both the opponents to receive points and the
blocky surroundings to supply them with energy and mass vital for survival.

The game makes use of many cutting-edge Web APIs, notably Audio API and Web
Workers, to get as much as possible from modern browsers.

Of possible interest is also the game physics, detecting and solving the
collisions of the grid and the objects, and the noise algorithm used to generate
unlimited amount of random maps. This algorithm can be executed in a background
thread, speeding up the game initialization.

{: .crossroad}
- [Play Krt](/krt/play.html)
