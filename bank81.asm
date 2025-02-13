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

!oambuffer      =                   $500                    ;start of oam table to dma at nmi

;arguments for passing info between dma related routines
    ;(i.e. from loading routines to the dma ones)
!dmaargstart    =                   $80
!dmasrcptr      =                   !dmaargstart+0          ;2
!dmasrcbank     =                   !dmaargstart+2          ;2
!dmasize        =                   !dmaargstart+4          ;2
!dmabaseaddr    =                   !dmaargstart+6          ;2
!dmaloadindex   =                   !dmaargstart+8          ;2


;===========================================================================================
;================================  D M A    R O U T I N E S  ===============================
;===========================================================================================

;initiates up a dma to
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
                            
                            
                            
        !dmaargstart    =                   $80                     ;start of dma arguments
        !dmasrcptr      =                   !dmaargstart+0          ;2
        !dmasrcbank     =                   !dmaargstart+2          ;2
        !dmasize        =                   !dmaargstart+4          ;2
        !dmabaseaddr    =                   !dmaargstart+6          ;2
        !dmaloadindex   =                   !dmaargstart+8          ;2
        
        
        sep #$20                    ;width  register
        lda.b #$80                  ;1      dma control
        sta $2115
        rep #$20
        
        
        lda !dmabaseaddr            ;2      dest base addr
        sta $2116
        
        sep #$20
        lda #$01                    ;1      transfur mode
        sta $4300
        
        lda #$18                    ;1      register dest (vram port)
        sta $4301
        rep #$20
        
        lda !dmasrcptr              ;2      source addr
        sta $4302
        
        sep #$20
        lda !dmasrcbank             ;1      source bank
        sta $4304
        rep #$20
        
        lda !dmasize                ;2      transfur size
        sta $4305
        
        sep #$20                    ;1      enable transfur on dma channel 0
        lda #$01                    
        sta $420b
        
        rep #$30
        
        rtl
    }


    .cgramtransfur: {
        sep #$20                    ;width  register
        
        lda.b !dmabaseaddr          ;1      cgadd
        sta $2121
        
        rep #$20
        
        ;lda !dmabaseaddr           ;2      dest base addr
        ;sta $2116
        
        sep #$20
        lda #$02                    ;1      transfur mode: write twice
        sta $4300
        
        lda #$22                    ;1      register dest (cgram write)
        sta $4301
        rep #$20
        
        lda !dmasrcptr              ;2      source addr
        sta $4302
        
        sep #$20
        lda !dmasrcbank             ;1      source bank
        sta $4304
        rep #$20
        
        lda !dmasize                ;2      transfur size
        sta $4305
        
        sep #$20                    ;1      enable transfur on dma channel 0
        lda #$01                    
        sta $420b
        
        rep #$30
        
        rtl
    }
    
    .clearvram: {
        sep #$20                    ;width  register
        lda.b #$80                  ;1      dma control
        sta $2115
        rep #$20
        
        lda #$0000                  ;2      dest base addr
        sta $2116
        
        sep #$20
        lda #%00011001              ;1      transfur mode
        sta $4300
        
        lda #$18                    ;1      register dest (vram port)
        sta $4301
        rep #$20
        
        lda #..fillword             ;2      source addr
        sta $4302
        
        lda #$fffe                  ;2      transfur size
        sta $4305
        
        sep #$20
        lda #$81                    ;1      source bank
        sta $4304

        
        lda #$01                    ;1      enable transfur on dma channel 0    
        sta $420b
        
        rep #$20
        
        rtl
    
        ..fillword: {
            dw $0000
        }
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
;five copypasted routines [sowweee]

macro loadtablentry(pointer, size, baseaddr, index)
    dl <pointer>
    dw <size>
    dw <baseaddr>
    db <index>          ;unused byte just makes the table entries 8 bytes long
endmacro


load: {
    ;label 'load' is just here for scope/logical reasons
    
    ;defined above, here for refernece
    ;!dmaargstart    =                   $80                     ;start of dma arguments
    ;!dmasrcptr      =                   !dmaargstart+0          ;2
    ;!dmasrcbank     =                   !dmaargstart+2          ;2
    ;!dmasize        =                   !dmaargstart+4          ;2
    ;!dmabaseaddr    =                   !dmaargstart+6          ;2
    ;!dmaloadindex   =                   !dmaargstart+8          ;2
    
    
    .background: {
        ;initiates 3 vram transfers:
        ;gfx, palette, tilemap
        ;takes arguments:
        ;a = background index
        phb
        php
        phx
        
        phk
        plb             ;bank = $81
        
        rep #$30
        asl #3          ;a = a * 8 (table entries are 8 bytes long)
        sta !dmaloadindex
        jsr load_background_gfx
        jsr load_background_tilemap
        jsr load_background_palette
        
        plx
        plp
        plb
        rtl
        
        ..gfx: {
            ldx !dmaloadindex
            
            lda.w loadingtable_bg_gfx,x
            sta !dmasrcptr
            inx : inx
            
            lda.w loadingtable_bg_gfx,x
            and #$00ff
            sta !dmasrcbank
            inx
            
            lda.w loadingtable_bg_gfx,x
            sta !dmasize
            inx : inx
            
            lda.w loadingtable_bg_gfx,x
            sta !dmabaseaddr
            
            jsl dma_vramtransfur
            
            rts
        }
    
        ..tilemap: {
            ldx !dmaloadindex
            
            lda.w loadingtable_bg_tilemaps,x
            sta !dmasrcptr
            inx : inx
            
            lda.w loadingtable_bg_tilemaps,x
            and #$00ff
            sta !dmasrcbank
            inx
            
            lda.w loadingtable_bg_tilemaps,x
            sta !dmasize
            inx : inx
            
            lda.w loadingtable_bg_tilemaps,x
            sta !dmabaseaddr
            
            jsl dma_vramtransfur
            
            rts
        }
    
        ..palette: {
            ldx !dmaloadindex
            
            lda.w loadingtable_bg_palettes,x
            sta !dmasrcptr
            inx : inx
            
            lda.w loadingtable_bg_palettes,x
            and #$00ff
            sta !dmasrcbank
            inx
            
            lda.w loadingtable_bg_palettes,x
            sta !dmasize
            inx : inx
            
            lda.w loadingtable_bg_palettes,x
            sta !dmabaseaddr
            
            jsl dma_cgramtransfur
            
            rts
        }
    }
    
    .sprite: {
    ;initiates s vram transfers:
    ;gfx, palette
    ;takes arguments:
    ;a = sprite index
    
        phb
        php
        phx
        
        phk
        plb             ;bank = $81
    
        rep #$30
        asl #3          ;a = a * 8 (table entries are 8 bytes long
        sta !dmaloadindex
    
        jsr load_sprite_gfx
        jsr load_sprite_palette
        
        plx
        plp
        plb
        rtl
    
        ..gfx: {
            ldx !dmaloadindex
            
            lda.w loadingtable_sprites_gfx,x
            sta !dmasrcptr
            inx : inx
            
            lda.w loadingtable_sprites_gfx,x
            and #$00ff
            sta !dmasrcbank
            inx
            
            lda.w loadingtable_sprites_gfx,x
            sta !dmasize
            inx : inx
            
            lda.w loadingtable_sprites_gfx,x
            sta !dmabaseaddr
            
            jsl dma_vramtransfur
            
            rts
        }
    
        ..palette: {
            ldx !dmaloadindex
            
            lda.w loadingtable_sprites_palettes,x
            sta !dmasrcptr
            inx : inx
            
            lda.w loadingtable_sprites_palettes,x
            and #$00ff
            sta !dmasrcbank
            inx
            
            lda.w loadingtable_sprites_palettes,x
            sta !dmasize
            inx : inx
            
            lda.w loadingtable_sprites_palettes,x
            sta !dmabaseaddr
            
            jsl dma_cgramtransfur
            
            rts
        }
    }
}


tablepointers: {            ;not actually used in this refactored routine
    dw #loadingtable_sprites_gfx
    dw #loadingtable_sprites_palettes

    dw #loadingtable_bg_gfx
    dw #loadingtable_bg_tilemaps
    dw #loadingtable_bg_palettes
}


loadingtable: {
    .sprites: {
        ..gfx: {          ;long pointer,       size,  baseaddr,         unused
            %loadtablentry(#glider_graphics,   $1000, !spritestart,     $00)     ;glider = 00
        }
        
        ..palettes: {
           %loadtablentry(#glider_palette,     $0080, !spritepalette,   $00)     ;glider = 00
        }
    }
    
    .bg: {
        ..gfx: {
            %loadtablentry(#splashgfx,         $8000, !bg1start,        $00)     ;splash = 00
            %loadtablentry(#bg1gfx,            $8000, !bg1start,        $01)     ;bg1    = 01
            %loadtablentry(#bg2gfx,            $8000, !bg1start,        $02)     ;bg2    = 02
        }
        
        ..tilemaps: {
            %loadtablentry(#splashtilemap,     $0800, !bg1tilemap,      $00)     ;splash = 00
            %loadtablentry(#bg1tilemap,        $0800, !bg1tilemap,      $01)     ;bg1    = 01
            %loadtablentry(#bg2tilemap,        $0800, !bg1tilemap,      $02)     ;bg1    = 01
        }
        
        ..palettes: {
            %loadtablentry(#splashpalette,     $0100, !palettes,        $00)     ;splash = 00
            %loadtablentry(#testpalette,       $0100, !palettes,        $01)     ;bg1    = 01
            %loadtablentry(#bg2palette,        $0100, !palettes,        $02)     ;bg1    = 01
        }
    }
}