lorom

org $818000

;===================================macros====================================

macro vramtransfur(gfxptr, size, vramdest)
    jsl dma_vramtransfur
    dl <gfxptr>
    dw <size>
    dw <vramdest>
endmacro

macro cgramtransfur(palptr, size, dest)
    jsl dma_loadpalettes
    dl <palptr>
    dw <size>
    dw <dest>
endmacro


;=================================dma routines=================================



dma:
    .vramtransfur: {        ;for dma channel 0
    
                                                ;register width (bytes)
        !dma_control            =   $2115       ;1
        !dma_dest_baseaddr      =   $2116       ;2
        !dma_transfur_mode      =   $4300       ;1
        !dma_reg_destination    =   $4301       ;1
        !dma_source_address     =   $4302       ;2
        !dma_bank               =   $4304       ;1
        !dma_transfur_size      =   $4305       ;2
        !dma_enable             =   $430b       ;1
                            ;set to #%00000001 to enable transfer on channel 0
        
        sep #$20
        
        lda $03,s                   ;db = caller bank
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
        
        ldy #$0001                          ;y=1
        lda ($01,s),y               ;2      source addr
        sta $4302
        
        iny : iny                           ;y=3
        
        sep #$20
        lda ($01,s),y               ;1      source bank
        sta $4304
        rep #$20
        
        iny                                 ;y=4
        
        lda ($01,s),y               ;2      transfur size
        sta $4305
        
        sep #$20                    ;1      enable transfur on dma channel 0
        lda #$01                    
        sta $420b
        
        lda $01,s
        clc                         ;adjust return address
        adc #$07
        sta $01,s
        
        rep #$30
        
        rtl
        
}

    .loadpalettes: {        ;copypaste of above vram routine
        sep #$20
        
        lda $03,s                   ;db = caller bank
        pha
        plb
        
                                    ;width  register
        lda.b #$00                  ;1      cgadd
        sta $2121
        rep #$20
        
        ldy #$0006
        
        lda ($01,s),y               ;2      dest base addr
        sta $2116
        
        sep #$20
        lda #$02                    ;1      transfur mode: write twice
        sta $4300
        
        lda #$22                    ;1      register dest (cgram write)
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
        
        lda $01,s
        clc                         ;adjust return address
        adc #$07
        sta $01,s
        
        rep #$30
        
        rtl
        
}

gliderload: {
    %vramtransfur(#glider_graphics, $1000, $c000)   ;sprites base address: $c000
    rtl
}

clearvram: {
    %vramtransfur($7e2000, $ffff, $0000)
    rtl
}

loadpalettes: {
    %cgramtransfur(#testpalette, $0100, $0000)
    rtl
}


;===============================background layers================================

splash_loadgfx: {
    %vramtransfur(#splashgfx, $8000, $0000)         ;bg1 grx base address: $0000
    rtl
}


splash_loadtilemap: {
     %vramtransfur(#splashtilemap, $0800, $2000)    ;bg1 tilemap base address: $2000
                  ;pointer,     size,  destination
    rtl
}


splash_loadpalettes: {
    %cgramtransfur(#splashpalette, $0100, $0000)
    rtl
}


bg1: {
    .loadtilemap: {
    
        %vramtransfur(#bg1tilemap, $0800, $2000)    ;bg1 tilemap base address: $2000
                     ;pointer,     size,  destination
    
        rtl
    }

    .loadgfx: {      ;gfx
        %vramtransfur(#bg1gfx, $4000, $0000)        ;bg1 grx base address: $0000
        rtl
    }
}