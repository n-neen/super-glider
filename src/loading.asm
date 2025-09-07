lorom

;===========================================================================================
;===================================  D E F I N E S  =======================================
;===========================================================================================

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
    
    
!dmabanklong        =   dma&$ff0000
!dmabankword        =   !dmabanklong>>8
!dmabankshort       =   !dmabanklong>>16
      

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
        lda.b #!dmabankshort        ;1      source bank
        sta $4304

        
        lda #$01                    ;1      enable transfur on dma channel 0    
        sta $420b
        
        rep #$20
        
        rtl
    
        ..fillword: {
            dw $0000
        }
    }
    
    
    .clearcgram: {
        phx
        
        sep #$10                    ;width  register
        
        ldx.b #$00                  ;1      cgadd
        stx $2121

        ldx #%00011001              ;1      transfur mode: write twice
        stx $4300
        
        ldx #$22                    ;1      register dest (cgram write)
        stx $4301
        
        lda.w #..fillword           ;2      source addr
        sta $4302
        
        ldx.b #!dmabankshort        ;1      source bank
        stx $4304
        
        lda #$0400                  ;2      transfur size
        sta $4305
        
        ldx #$01                    ;1      enable transfur on dma channel 0
        stx $420b
        
        rep #$10
        
        plx
        rtl
        
        ..fillword: {
            dw $3800
        }
    }
}



oam: {
    
    .write: {
        phx
        php
        
        sep #$10                    ;8 bit x/y mode
        rep #$20                    ;16 bit A
        
                                    ;width  register
        ;ldx #$80                    ;1      dma control
        ;stx $2104
        
        ;stz $2102                   ;1      oam high starting addr = 0
        
        ldx #$00                    ;1      transfur mode
        stx $4300
        
        ldx #$04                    ;1      register dest (oam add)
        stx $4301
        
        ldx #$00                    ;1      source bank
        stx $4304
        
        lda #!oambuffer             ;2      source addr
        sta $4302
        
        lda #$0220                  ;2      transfur size = 544 bytes (oam table size)
        sta $4305
        
        ldx #$01                    ;1      enable transfur on dma channel 0             
        stx $420b
        
        plp
        plx
        rtl
    }
    
    
    ;i really need to get a handle on the following three routines
    ;and what the hell i mean to do with them
    ;ideally, we:
    ;clear oam
    ;write oam buffer in this order:
    ;   -glider
    ;   -enemies, in list order
    ;then, the remainder of the table is cleared
    
    ;the above was written in desperation
    ;the bug i was chasing was the
    ;txa : adc #$05 : tax
    ;in the glider draw routine
    ;X/Y were in 16 bit mode and A in 8 bit mode
    ;so the upper byte of A corrupted X
    ;the solution was to inx #5
    
    .fillbuffer: {
    
        ;ok i guess
        phx
        
        lda #$e0e0
        ldx #$0200
        
        -
        sta !oambuffer,x
        dex : dex
        bpl -
        
        plx
        rtl
    }    

    .hightablejank: {
        phx
        ldx #$0020
        lda #$aaaa
    -   sta !oamhightable,x
        dex : dex
        bpl -
        plx
        rtl
    }
    
    .cleantable: {
        ;lda #$0220
        ;sec
        ;sbc !oamentrypoint
        ;tax
        
        ldx !oamentrypoint
        
        -
        lda #$e0e0
        sta !oambuffer,x
        inx : inx
        cpx #$0220
        bne -
        
        rtl
    }

}









;===========================================================================================
;===================================  L O A D I N G  =======================================
;===========================================================================================
;set up a dma for a specific purpose
;five copypasted routines [sowweee]


load: {
    ;label 'load' is just here for scope/logical reasons
    
    .background: {
        ;initiates 3 vram transfers:
        ;gfx, palette, tilemap
        ;takes arguments:
        ;a = background index
        phb
        php
        phx
        
        phk
        plb
        
        rep #$30
        asl #3          ;a = a * 8 (table entries are 8 bytes long)
        sta !dmaloadindex
        jsr load_background_gfx
        jsr load_background_palette
        jsr load_background_tilemap
        
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
            
            jsr load_layertilemap_writebuffer

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
    ;initiates 2 vram transfers:
    ;gfx, palette
    ;takes arguments:
    ;a = sprite index
    
        phb
        php
        phx
        
        phk
        plb
    
        rep #$30
        asl #3          ;a = a * 8 (table entries are 8 bytes long)
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
    
    .layertilemap: {
        ..writebuffer: {
            ;we still have the arguments:
            ;!dmaargstart    =                   $80                     ;start of dma arguments
            ;!dmasrcptr      =                   !dmaargstart+0          ;2
            ;!dmasrcbank     =                   !dmaargstart+2          ;2
            ;!dmasize        =                   !dmaargstart+4          ;2
            ;!dmabaseaddr    =                   !dmaargstart+6          ;2
            ;!dmaloadindex   =                   !dmaargstart+8          ;2
            
            !pushbank       =                   !localtempvar
            !loadptr        =                   !localtempvar2
            
            phx
            phy
            phb
            
            pea.w !dmabankshort
            plb : plb
            
            lda !dmaloadindex                       ;if background type = 0, exit
            beq +
            lsr                                     ;(index is normally *8 but it's *4 here
            tax
            
            lda loadingtable_layertilemaps,x
            sta !loadptr
            
            lda loadingtable_layertilemaps+2,x      ;set db to bank from table
            xba
            sta !pushbank
            pei (!pushbank)
            plb : plb
            
            ldy !loadptr
            ldx #$0000
            
            -
            lda $0000,y
            sta !layer2tilemap,x
            inx : inx
            iny : iny
            cpx #$0800
            bne -
            
            jsl dma_vramtransfur
            
        +   plb
            ply
            plx
            rts
        }
    }
}

layer2draw: {
    lda #$0000
    sta !dmasrcptr
    lda #$007f
    sta !dmasrcbank
    lda #$0800
    sta !dmasize
    lda #!bg2tilemap
    sta !dmabaseaddr
    
    jsl dma_vramtransfur
    rtl
}



tablepointers: {            ;not actually used in this refactored routine
    dw #loadingtable_sprites_gfx
    dw #loadingtable_sprites_palettes

    dw #loadingtable_bg_gfx
    dw #loadingtable_bg_tilemaps
    dw #loadingtable_bg_palettes
}

;in order to add a background type, you must add an entry in each corresponding table
;the tilemap long pointers exist in 'layertilemaps' because of the layer tilemap buffer
;so 'loadingtable' has a reference to the buffer, and we load the buffer elsewhere
;at 'layertilemap_writebuffer'
;loading "background 00" loads the first entry of .bg_gfx, .bg_tilemaps (indirectly) and .bg_palettes
;table format:

macro loadtablentry(pointer, size, baseaddr, index)
    dl <pointer>
    dw <size>
    dw <baseaddr>
    db <index>          ;unused byte just makes the table entries 8 bytes long
endmacro


loadingtable: {
    .sprites: {
        ..gfx: {          ;long pointer,            size,  baseaddr,                unused
            %loadtablentry(#gliderdata_graphics,    $0a00, !spritestart,            $00)     ;glider        = 00
            %loadtablentry(#balloondata_graphics,   $0800, !spritestart+$0500,      $01)     ;balloon       = 01
            %loadtablentry(#prizedata_graphics,     $0e00, !spritestart+$0900,      $02)     ;prizes        = 02
            %loadtablentry(#dartdata_graphics,      $0700, !spritestart+$1000,      $03)     ;dart          = 03
            %loadtablentry(#dripdata_graphics,      $0400, !spritestart+$1300,      $04)     ;drip          = 04
            %loadtablentry(#gliderdata_graphics,    $0400, !spritestart+$1300,      $05)     ;foil glider   = 05
            %loadtablentry(#catdata_graphics,       $1000, !spritestart+$1000,      $06)     ;cat           = 06    ;overwrites entire second page
            %loadtablentry(#fishdata_gfx,           $0400, !spritestart+$1500,      $07)     ;fish          = 07
            %loadtablentry(#copterdata_gfx,         $0800, !spritestart+$1700,      $08)     ;copter        = 08
            %loadtablentry(#teddydata_graphics,     $0800, !spritestart+$0500,      $09)     ;teddy         = 09
            %loadtablentry(#stardata_gfx,           $1000, !spritestart+$1000,      $0a)     ;star          = 0a
            
        }
        
        ..palettes: {
           %loadtablentry(#gliderdata_palette,      $0020, !spritepalette+$0070,    $00)     ;glider        = 00      ;sprite line 7
           %loadtablentry(#balloondata_palette,     $0020, !spritepalette+$0010,    $01)     ;balloon       = 01      ;sprite line 1
           %loadtablentry(#prizedata_palette,       $0060, !spritepalette+$0020,    $02)     ;prizes        = 02      ;sprite line 2
           %loadtablentry(#gliderdata_palette,      $0020, !spritepalette+$0000,    $03)     ;dart          = 03      ;sprite line 0
           %loadtablentry(#dripdata_palette,        $0040, !spritepalette+$0050,    $04)     ;drip          = 04      ;sprite line 5 + 6 also contains fire AND fish colors
           %loadtablentry(#gliderdata_foilpalette,  $0020, !spritepalette+$0070,    $05)     ;foil glider   = 05      ;sprite line 7
           %loadtablentry(#catdata_palette,         $0020, !spritepalette+$0000,    $06)     ;cat           = 06      ;sprite line 0
           %loadtablentry(#fishdata_palette,        $0001, !spritepalette+$0000,    $07)     ;dummy palette 
           %loadtablentry(#copterdata_palette,      $0001, !spritepalette+$0000,    $08)     ;dummy palette 
           %loadtablentry(#teddydata_palette,       $0020, !spritepalette+$0000,    $09)     ;teddy         = 09
           %loadtablentry(#stardata_palette,        $0010, !spritepalette+$0010,    $0a)     ;star          = 0a
           
        }
    }
    
    .bg: {
        ..gfx: {
            %loadtablentry(#objgfx,                 $4000, !bg1start,               $00)     ;object layer      = 00
            %loadtablentry(#splashgfx,              $8000, !bg2start,               $01)     ;splash            = 01
            %loadtablentry(#bg2gfx,                 $4000, !bg2start,               $02)     ;simple room       = 02
            %loadtablentry(#bg3gfx,                 $4000, !bg2start,               $03)     ;panneled room     = 03
            %loadtablentry(#bg4gfx,                 $4000, !bg2start,               $04)     ;basement          = 04
            %loadtablentry(#bg5gfx,                 $4000, !bg2start,               $05)     ;tiled room        = 05
            %loadtablentry(#bg6gfx,                 $4000, !bg2start,               $06)     ;skywalk           = 06
            %loadtablentry(#bg7gfx,                 $4000, !bg2start,               $07)     ;swingers room ;]  = 07
            %loadtablentry(#bg8gfx,                 $8000, !bg2start,               $08)     ;ending            = 08
            %loadtablentry(#bg9gfx,                 $4000, !bg2start,               $09)     ;unfinished room   = 09
            %loadtablentry(#bgagfx,                 $4000, !bg2start,               $0a)     ;sewer             = 0a
        }
        
        ..tilemaps: {
            %loadtablentry(#objtilemap,             $0800, !objtilemap,             $00)     ;obj    = 00              ;object layer
            %loadtablentry(!layer2tilemap,          $0800, !bg2tilemap,             $01)     ;splash = 01
            %loadtablentry(!layer2tilemap,          $0800, !bg2tilemap,             $02)     ;bg2    = 02
            %loadtablentry(!layer2tilemap,          $0800, !bg2tilemap,             $03)     ;bg3    = 03
            %loadtablentry(!layer2tilemap,          $0800, !bg2tilemap,             $04)     ;bg4    = 04
            %loadtablentry(!layer2tilemap,          $0800, !bg2tilemap,             $05)     ;bg5    = 05
            %loadtablentry(!layer2tilemap,          $0800, !bg2tilemap,             $06)     ;bg6    = 06
            %loadtablentry(!layer2tilemap,          $0800, !bg2tilemap,             $07)     ;bg7    = 07
            %loadtablentry(!layer2tilemap,          $0001, !bg2tilemap,             $08)     ;bg8    = 08 [ending, uses special tilemaps]
            %loadtablentry(!layer2tilemap,          $0800, !bg2tilemap,             $09)     ;bg9    = 09
            %loadtablentry(!layer2tilemap,          $0800, !bg2tilemap,             $0a)     ;bga    = 0a
        }       
                
        ..palettes: {
            %loadtablentry(#bg3palette,             $0100, !palettes,               $00)     ;obj    = 00              ;object layer
            %loadtablentry(#splashpalette,          $0100, !palettes,               $01)     ;splash = 01
            %loadtablentry(#bg2palette,             $0100, !palettes,               $02)     ;bg2    = 02
            %loadtablentry(#bg3palette,             $0100, !palettes,               $03)     ;bg3    = 03
            %loadtablentry(#bg4palette,             $0100, !palettes,               $04)     ;bg4    = 04
            %loadtablentry(#bg5palette,             $0100, !palettes,               $05)     ;bg5    = 05
            %loadtablentry(#bg6palette,             $0100, !palettes,               $06)     ;bg6    = 06
            %loadtablentry(#bg7palette,             $0100, !palettes,               $07)     ;bg7    = 07
            %loadtablentry(#bg8palette,             $0040, !palettes,               $08)     ;bg8    = 08
            %loadtablentry(#bg9palette,             $0100, !palettes,               $09)     ;bg9    = 09
            %loadtablentry(#bgapalette,             $0100, !palettes,               $0a)     ;bga    = 0a
        }
    }
    
    .layertilemaps: {
        ;inelegant kludge table
        dl !objtilemap                  : db $00
        dl #splashtilemap               : db $01
        dl #bg2tilemap                  : db $02
        dl #bg3tilemap                  : db $03
        dl #bg4tilemap                  : db $04
        dl #bg5tilemap                  : db $05
        dl #bg6tilemap                  : db $06
        dl #bg7tilemap                  : db $07
        dl $000000                      : db $08
        dl #bg9tilemap                  : db $09
        dl #bgatilemap                  : db $0a
    }
}
