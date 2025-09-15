lorom

org $888000

;===========================================================================================
;===============================   SPECIAL TILEMAPS   ======================================
;===========================================================================================


specialtilemaps: {
    .1: incbin "./data/tilemaps/special/1ending_roof.map"
    .2: incbin "./data/tilemaps/special/2ending_sky.map"
    .3: incbin "./data/tilemaps/special/3ending_stratosphere.map"
    .4: incbin "./data/tilemaps/special/4ending_stars.map"
    .5: incbin "./data/tilemaps/special/5ending_end.map"
    
    .6: incbin "./data/tilemaps/special/split_bg2_room.map"
    ;probably need to make a wall object to replace this
}

print "bank $88 end: ", pc