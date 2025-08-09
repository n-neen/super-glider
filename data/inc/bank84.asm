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

print "bank $84 end: ", pc