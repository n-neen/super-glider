lorom

org $818000

!oambuffer      =       $0500

;oam routines
oam:
    .test:
    rtl
    
    .transferbuffer:
    ;todo: dma buffer starts at !oambuffer
    rtl

    
load:
    .spritetiles:
    phk             ;\
    plb             ;db = $81
    php
    
    sep #$10        ;x/y = 8-bit
    rep #$20        ;a  = 16 bit
    
    ldx #%10000000
    stx $2115       ;dma control
    
    lda #$0000      ;destination base address
    sta $2116
    
    ldx.b #$81
    stx $4204       ;set dma source bank = $81
    
    lda.w #glider_graphics
    sta $4202       ;set dma source pointer
    
    lda.w #$0300
    sta $4305       ;dma size = $300
    
    ldx.b #$18      ;destination is $2118 (vram port)
    stx $4301
    
    ldx.b #$01      ;transfer mode 1 (two byte mode)
    stx $4300
    
    ldx.b #$01
    sta $420b       ;enable transfur
    
    plp
    rtl
    
    .palette:
    ;jsr setup_dma
    rtl



;===============================sprite data===============================

glider:
    .header:
        dw #.graphics, #.spritemap, #.palette, #.hitbox
        
    .graphics:
        incbin "./data/sprites/glider.gfx"
    
    .spritemap:
        incsrc "./data/sprites/glider_spritemap.asm"
    
    .palette:
        incbin "./data/sprites/glider.pal"
        
    .hitbox:                ;radii
        db $0a, $05         ;x, y