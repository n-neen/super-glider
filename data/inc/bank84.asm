lorom

org $848000

;===========================================================================================
;===============================   H U D   D A T A   =======================================
;===========================================================================================

;this has hardcoded bank pointers!
;in main.asm, at:
;   hud_copytilemaptobuffer
;   hud_uploadgfx


hud_data: {
    .gfx:
        incbin "./data/tiles/hud.gfx"
    .tilemap:
        incbin "./data/tilemaps/hud.map"
}

fishdata: {
    .gfx:
        incbin "./data/sprites/fish.gfx"
    .palette:
        dw $0000
}

copterdata: {
    .gfx:
        incbin "./data/sprites/copter.gfx"
    .palette:
        dw $0000
}

print "bank $84 end: ", pc