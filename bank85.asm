lorom

;===========================================================================================
;===============================    E N E M Y   D A T A   ==================================
;===========================================================================================

org $858000

balloondata:
    .graphics:
        incbin "./data/sprites/balloon.gfx"
    .palette:
        incbin "./data/sprites/balloon.pal"


prizedata:
    .graphics:
        incbin "./data/sprites/prizes.gfx"
    .palette:
        incbin "./data/sprites/prizes.pal"


dartdata:
    .graphics:
        incbin "./data/sprites/dart.gfx"
    .palette:
        ;null. indicate size as 0 in loadingtable entry
        ;or 1 i guess? lol

print "bank $85 end: ", pc
