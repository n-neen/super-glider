lorom

org $828000

;=================================palettes=================================
    
    testpalette:
        dw $14c4, $0000, $6739, $7ec7, $2108, $5ef7, $39ac, $24a4,
           $2529, $39ce, $4e73, $44c4, $7fff, $5294, $3c3c, $643c
        ;incbin "./data/palettes/palette.bin"
        
;===============================sprite data===============================

glider:
    .header:
        dw #.graphics, #.spritemap, #.palette, #.hitbox
        
    .hitbox:                ;radii
        db $0a, $05         ;x, y
        
    .graphics:
        incbin "./data/sprites/glider.gfx"
    
    .spritemap:
        incsrc "./data/sprites/glider_spritemap.asm"
    
    .palette:
        incbin "./data/sprites/glider.pal"

;===============================tilemaps===============================

bg1tilemap:
    incsrc "./data/tilemaps/bg1.asm"