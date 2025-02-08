lorom

org $818000

!oambuffer      =       $0500



;dma routines



dma:
    .setup: {
    
    !dma_args_start         =   $50
                                                            ;register to be written to
    !dma_channel            =   !dma_args_start             ;none [determines register set]
                                                                        ;register width (bytes)
    !dma_control            =   !dma_args_start+$2          ;$2115      ;1
    !dma_dest_baseaddr      =   !dma_args_start+$4          ;$2116      ;2
    !dma_transfur_mode      =   !dma_args_start+$6          ;$43x0      ;1              ;x=dma channel
    !dma_reg_destination    =   !dma_args_start+$8          ;$43x1      ;1
    !dma_source_address     =   !dma_args_start+$a          ;$43x2      ;2
    !dma_bank               =   !dma_args_start+$c          ;$43x4      ;1
    !dma_transfur_size      =   !dma_args_start+$e          ;$43x5      ;2
    !dma_enable             =   !dma_args_start+$10         ;$430b      ;1
    
    
    phk             ;\
    plb             ;db = $81
    php
    
    rep #$30
    
    lda !dma_channel
    asl #4
    ora #$4300
    tay
    
    sep #$20
    lda !dma_control            ;1
    sta $2115
    rep #$20
    
    lda !dma_dest_baseaddr      ;2
    sta $2116
    
    sep #$20
    lda !dma_transfur_mode      ;1
    sta $0000,y                 ;$43x0
    iny
    
    lda !dma_reg_destination    ;1
    sta $0000,y                 ;$43x1
    iny
    rep #$20
    
    lda !dma_source_address     ;2
    sta $0000,y                 ;$43x2
    iny : iny
    
    sep #$20
    lda !dma_bank               ;1
    sta $0000,y                 ;$43x4
    iny
    rep #$20
    
    lda !dma_transfur_size      ;2
    sta $0000,y                 ;$43x5
    
    sep #$20                    ;1
    lda !dma_enable             ;caller needs to set correct bit!
    sta $420b
    rep #$20
    
    
    plp
    rtl
    

}

gliderload: {
    php
    
    rep #$30
    
    lda.w #$0080
    sta !dma_control
    
    lda.w #$0000                    ;destination base address
    sta !dma_dest_baseaddr
    
    lda.w #$0081
    sta !dma_bank                   ;set dma source bank = $81
    
    lda.w #glider_graphics
    sta !dma_source_address         ;set dma source address pointer
    
    lda.w #$0600
    sta !dma_transfur_size          ;dma size = $300
    
    lda.w #$0018                    ;destination is $2118 (vram port)
    sta !dma_reg_destination
    
    lda.w #$0001                    ;transfer mode 1 (two byte mode)
    sta !dma_transfur_mode
    
    lda.w #$0001
    sta !dma_enable                 ;enable transfur
    
    jsl dma_setup
    
    plp
    rtl
}
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