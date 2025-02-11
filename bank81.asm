lorom

org $818000


;===========================================================================================
;====================================  M A C R O S  ========================================
;===========================================================================================


macro vramtransfur(gfxptr, size, vramdest)
    jsl dma_vramtransfur
    dl <gfxptr>
    dw <size>
    dw <vramdest>
endmacro

macro cgramtransfur(palptr, size, dest)
    jsl dma_cgramtransfur
    dl <palptr>
    dw <size>
    dw <dest>
endmacro


;===========================================================================================
;===================================  D E F I N E S  =======================================
;===========================================================================================
;moved v_v
!oambuffer      =                   $500                    ;start of oam table to dma at nmi


;===========================================================================================
;================================  D M A    R O U T I N E S  ===============================
;===========================================================================================

;set up a dma to
    ;vram or cgram
    
    ;dma_vramtransfur
    ;dma_loadpalettes
    
    
    
    ;===========================================================================================
    ;===========================================================================================
    ;both dma routines need to be rewritten to use new arguments (no more stack relative stuff phew)
    ;after that we can change all the callsites
    ;===========================================================================================
    ;===========================================================================================
    
    
    
dma: {
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
        
        rep #$30
        
        lda $01,s
        clc                         ;adjust return address
        adc #$0007
        sta $01,s
        
        
        rtl
    }


    .cgramtransfur: {        ;copypaste of above vram routine
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
        
        rep #$30
        
        lda $01,s
        clc                         ;adjust return address
        adc #$0007
        sta $01,s

        rtl
    }
}

oam: {
    .clear: {
        phx
        phy
        php
        
        ;todo
        
        plp
        ply
        plx
        rtl
    }
    
    .update: {
        ;todo: all of this
        rtl
    }
}


;===========================================================================================
;===================================  L O A D I N G  =======================================
;===========================================================================================
;set up a dma for a specific purpose

macro loadtablentry(index, pointer, size, baseaddr)
    db <index>
    dl <pointer>
    dw <size>
    dw <baseaddr>
endmacro


consult: {
    !dmaargs        =                   $60                     ;start of dma routine arguments
    !dmatype        =                   !dmaargs+0
    !dmasrcptr      =                   !dmaargs+2
    !dmatrsize      =                   !dmaargs+4
    !dmabaseaddr    =                   !dmaargs+6
    
    
    ;takes arguments:
    ;a = type of item
    ;    0 = sprite
    ;    1 = background
    ;x = item index
    ;
    
    rep #$30
    
    asl                                     ;a*4
    asl                                     ;
    tay
    lda #tablepointers,y                    ;if sprite: grab ptr #loadingtable_sprites_gfx
                                            ;if bkg, grab ptr #loadingtable_bg_gfx
    sta $10         ;$10 = pointer to table
    txa         
    asl #3      
    tax             ;x*8
    
    lda ($10),x     ;grab first table item (dma type)
    sta !dmatype
    inx
    
    lda ($10),x     ;grab first table item (dma source long pointer)
    sta !dmasrcptr
    inx : inx : inx
    
    lda ($10),x     ;grab first table item (dma transfur size)
    sta !dmatrsize
    inx : inx
    
    lda ($10),x
    sta !dmabaseaddr
    
    lda !dmatype
    beq gotovramtransfur
    ;else
    jsl dma_cgramtransfur
    rtl
    
    gotovramtransfur:
    jsl dma_vramtransfur
    rtl
}


tablepointers: {                                        ;y=0 or 1 before shift
    dw #loadingtable_sprites_gfx            ;2      0   0         after shift
    dw #loadingtable_sprites_palettes       ;2      2
    
    dw #loadingtable_bg_gfx                 ;2      4   4         after shift
    dw #loadingtable_bg_tilemaps            ;2      6
    dw #loadingtable_bg_palettes            ;2      8
}


loadingtable: {          ;type: 00 = vram, 01 = cgram
    .sprites: {
        ..gfx: {         ;type, long pointer,       size,  baseaddr
            %loadtablentry($00, #glider_graphics,   $1000, !spritestart)     ;glider = 00
        }
        
        ..palettes: {
           ;%loadtablentry($00, #glider_palette,    $1000, !spritestart)     ;glider = 00            ;todo: this
        }
    }
    
    .bg: {
        ..gfx: {
            %loadtablentry($00, #splashgfx,         $8000, !bg1gfx)           ;splash = 00
            %loadtablentry($00, #bg1gfx,            $4000, $0000)             ;bg1    = 01
        }
        
        ..tilemaps: {
            %loadtablentry($00, #splashtilemap,     $0800, !bg1tilemap)       ;splash = 00
            %loadtablentry($00, #bg1tilemap,        $0800, !bg1tilemap)       ;bg1    = 01
        }
        
        ..palettes: {
            %loadtablentry($01, #splashpalette,     $0100, !palettes)         ;splash = 00
            %loadtablentry($01, #testpalette,       $0100, !palettes)         ;bg1    = 01
        }
    }
}

;THIS IS THE LINE====================================
;below this is currently implemented. above it is not

gliderload: {
    %vramtransfur(#glider_graphics, $1000, !spritestart)   ;sprites base address: $c000         ;xxxxxxxxxxxxx
    rtl
}


clearvram: {
    %vramtransfur($7e2000, $ffff, $0000)                                                       ;xxxxxxxxxxxxx
    rtl
}


loadpalettes: {
    %cgramtransfur(#testpalette, $0100, !palettes)                                             ;xxxxxxxxxxx
    rtl
}


splashload: {
    .gfx: {
        %vramtransfur(#splashgfx, $8000, !bg1gfx)             ;bg1 grx base address: $0000      xxxxxxxxxxxxxxxxxxxx     
        rtl
    }
    
    .tilemap: {
         %vramtransfur(#splashtilemap, $0800, !bg1tilemap)    ;bg1 tilemap base address             xxxxxxxxxxxx
                      ;pointer,     size,  destination
        rtl
    }
    
    .palettes: {
        %cgramtransfur(#splashpalette, $0100, !palettes)                                       ; xxxxxxxxxxxxxx
        rtl
    }
}


bg1: {
    .loadtilemap: {
    
        %vramtransfur(#bg1tilemap, $0800, !bg1tilemap)      ;bg1 tilemap base address            xxxxxxxxxxx       
                     ;pointer,     size,  destination
        rtl
    }

    .loadgfx: {
        %vramtransfur(#bg1gfx, $4000, $0000)                ;bg1 grx base address: $0000                 xxxxxxxxxxxxxxxxx   
        rtl
    }
}
