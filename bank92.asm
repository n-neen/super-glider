lorom

org $928000


;===========================================================================================
;===================================  P A L E T T E S  =====================================
;===========================================================================================


    bg2palette:
        incbin "./data/palettes/bg2.pal" 
    ;stairspalette:
        incbin "./data/palettes/stairs.pal"
    ;objpalette:
        incbin "./data/palettes/obj.pal"
        incbin "./data/palettes/obj2.pal" 
        incbin "./data/palettes/ozma.pal"
        incbin "./data/palettes/lamp.pal"
        
    splashpalette:
        incbin "./data/palettes/splash.pal"
    bg3palette:
        incbin "./data/palettes/bg3.pal"
    stairspalette2:
        incbin "./data/palettes/stairs.pal"
        incbin "./data/palettes/obj.pal"
        incbin "./data/palettes/obj2.pal"
        incbin "./data/palettes/ozma.pal"
        incbin "./data/palettes/lamp.pal"
    
;===========================================================================================
;===============================   S P R I T E   D A T A   =================================
;===========================================================================================


gliderdata:
    .header:
        dw #.graphics, #.palette, #.hitbox
        
    .hitbox:                ;radii
        db $0a, $05         ;x, y
        
    .graphics:
        incbin "./data/sprites/glider.gfx"
    
    .palette:
        ;incbin "./data/sprites/glider.pal"
        dw $2940, $0000, $6739, $7ec7, $2108, $5ef7, $39ac, $24a4,
           $2529, $39ce, $4e73, $44c4, $7fff, $5294, $3c3c, $643c

;===========================================================================================
;===============================    B A C K G R O U N D    =================================
;===============================      T I L E M A P S      =================================
;===========================================================================================

splashtilemap:
    incbin "./data/tilemaps/splash.bin"

bg2tilemap:
    incbin "./data/tilemaps/bg2.map"
    
bg3tilemap:
    incbin "./data/tilemaps/bg3.bin"
    
objtilemap:
    incbin "./data/tilemaps/obj_initial_tilemap.bin"
    
;warn pc