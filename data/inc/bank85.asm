lorom

;===========================================================================================
;===============================    E N E M Y   D A T A   ==================================
;===========================================================================================

org $858000

balloondata: {
    .graphics:
        incbin "./data/sprites/balloon.gfx"
    .palette:
        incbin "./data/sprites/balloon.pal"
}

prizedata: {
    .graphics:
        incbin "./data/sprites/prizes.gfx"
    .palette:
        incbin "./data/sprites/prizes.pal"
}

dartdata: {
    .graphics:
        incbin "./data/sprites/dart.gfx"
    .palette:
        dw $7fff
        ;null. indicate size as 0 in loadingtable entry
            ;yeah don't do 0, that's dma of size $10000
        ;or 1 i guess? lol
        ;ok so here's what you do:
        ;loading table entry has a size of 1
        ;and you target a sprite palette's transparent color
}

dripdata: {
    .graphics:
        incbin "./data/sprites/drip.gfx"
    .palette:
        incbin "./data/sprites/drip.pal"
}

teddydata: {
    .graphics:
        incbin "./data/sprites/teddy.gfx"
    .palette:
        incbin "./data/sprites/teddy.pal"
}


print "bank $85 end: ", pc
