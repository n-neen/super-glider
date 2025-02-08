lorom

org $818000

!oambuffer      =       $0500



;dma routines



dma:
    .vramtransfur: {
    

    ;for dma channel
                                            ;register width (bytes)
    !dma_control            =   $2115       ;1
    !dma_dest_baseaddr      =   $2116       ;2
    !dma_transfur_mode      =   $4300       ;1
    !dma_reg_destination    =   $4301       ;1
    !dma_source_address     =   $4302       ;2
    !dma_bank               =   $4304       ;1
    !dma_transfur_size      =   $4305       ;2
    !dma_enable             =   $430b       ;1      ;set to #%00000001 to enable transfer on channel 0
    
    sep #$20
    
    lda $03,s
    pha
    plb
    
                                ;width  register
    lda.b #$80                  ;1      dma control
    sta $2115
    rep #$20
    
    ldy #$0006
    
    lda ($01,s),y               ;2      dest base addr
    sta $2116
    
    sep #$20
    lda #$01                    ;1      transfur mode
    sta $4300
    
    lda #$18                    ;1      register dest (vram port)
    sta $4301
    rep #$20
    
    ldy #$0001                          ;y=0
    lda ($01,s),y               ;2      source addr
    sta $4302
    
    iny : iny                           ;y=2
    
    sep #$20
    lda ($01,s),y               ;1      source bank
    sta $4304
    rep #$20
    
    iny                                 ;y=3
    
    lda ($01,s),y               ;2      transfur size
    sta $4305
    
    sep #$20                    ;1      enable transfur on dma channel 0
    lda #$01                    
    sta $420b
    rep #$20
    
    lda $00,s
    clc
    adc #$0007
    sta $00,s
    
    rep #$30
    
    rtl
    

}

macro vramtransfur(gfxptr, size, vramdest)
    jsl dma_vramtransfur
    dl <gfxptr>
    dw <size>
    dw <vramdest>
endmacro


gliderload: {
    %vramtransfur(#glider_graphics, $0300, $0000)
    rtl
}




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
        