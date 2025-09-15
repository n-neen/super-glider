lorom

org $868000

;===========================================================================================
;=============================   E N E M Y   D A T A   =====================================
;===========================================================================================

catdata: {
    .graphics:
        incbin "./data/sprites/cat.gfx"
    .palette:
        incbin "./data/sprites/cat.pal"
}

samanthadata: {
    .palette:
        incbin "./data/sprites/samantha.pal"
    .gfx:
        incbin "./data/sprites/samantha.gfx"
}


print "bank $86 end: ", pc