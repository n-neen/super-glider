Glider for snes

based on Glider (PRO) by john calhoun

build with asar 1.90pre, thedopefish fork (metconst)


status:

still establishing structure. very early in game engine writing.

program displays a background, and you can press start to enter a test environment. use dpad to move; L and R buttons set glider lift state to falling or rising, A button clears this state. enable debug mode (at the very start of bank $80) to see background loading and scrolling routines. use dpad to move layer 2, and use Y, B, and X to load backgrounds. currently loads garbage tilemap for layer 1? woops. todo: fix that
