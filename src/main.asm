lorom


;===========================================================================================
;======================================  DEFINES  ==========================================
;===========================================================================================

!localtempvar           =           $10
!localtempvar2          =           $12

!gamestate              =           $30
!debugstate             =           $32
!gamesubstate           =           $34
!maincounter            =           $20
!nmiflag                =           $22
!nmicounter             =           $24
!framecounter           =           $26
!lagcounter             =           $28

!bg1x                   =           $40
!bg1y                   =           $42
!bg1tilemapshifted      =           !bg1tilemap>>8

!bg2x                   =           $44
!bg2y                   =           $46
!bg2tilemapshifted      =           !bg2tilemap>>8

!bg3tilemapshifted      =           !bg3tilemap>>8


!backgroundupdateflag   =           $48
!backgroundtype         =           $4a

!spriteaddrshifted      =           !spritestart>>13

!dmaargstart    =                   $80
!dmasrcptr      =                   !dmaargstart+0          ;2
!dmasrcbank     =                   !dmaargstart+2          ;2
!dmasize        =                   !dmaargstart+4          ;2
!dmabaseaddr    =                   !dmaargstart+6          ;2
!dmaloadindex   =                   !dmaargstart+8          ;2


;===========================================================================================
;======================================  B O O T  ==========================================
;===========================================================================================

!showcpuflag  =   #$0000

debugflag:
    dw $0000


boot: {
    sei
    clc
    xce             ;enable native mode
    jml setbank     ;set bank to $80
    setbank:
    
    sep #$20
    lda #$01
    sta $420d       ;enable fastrom
    rep #$30
    
    ldx #$1fff
    txs             ;set initial stack pointer
    lda #$0000
    tcd             ;clear dp register
    
    ldy #$0000      ;lmaoooo
}

clear7e: {
    pea $7e7e
    plb : plb
    
    ldx #$1ffe
    
    -
    stz $0000,x
    stz $1000,x
    stz $2000,x
    stz $3000,x
    stz $4000,x
    stz $5000,x
    stz $6000,x
    stz $7000,x
    stz $8000,x
    stz $9000,x
    stz $a000,x
    stz $b000,x
    stz $c000,x
    stz $d000,x
    stz $e000,x
    
    dex : dex
    bpl -
}
    
clear7f: {
    pea $7f7f
    plb : plb
    
    ldx #$1ffe
    
    -
    stz $0000,x
    stz $1000,x
    stz $2000,x
    stz $3000,x
    stz $4000,x
    stz $5000,x
    stz $6000,x
    stz $7000,x
    stz $8000,x
    stz $9000,x
    stz $a000,x
    stz $b000,x
    stz $c000,x
    stz $d000,x
    stz $e000,x
    
    dex : dex
    bpl -
}

init: {
    .registers: {
        
        phk
        plb                 ;set db
        
        sep #$30
        lda #$8f
        sta $2100           ;enable forced blank
        lda #$01
        sta $4200           ;enable joypad autoread
        rep #$30
        
        
        ldx #$000a
-       stz $4200,x         ;clear registers $4200-$420b
        dex : dex
        bne - 
        
        ldx #$0082          ;clear registers $2101-2183
--      stz $2101,x
        dex : dex
        bne --
        
        sep #$20
        lda #$80            ;enable nmi
        sta $4200
    }
    
    
    .ppu: {                         ;set up ppu
        
        lda #%00010110              ;main screen = sprites, L2
        sta $212c
        
        lda.b #!spriteaddrshifted   ;sprite size: 8x8 + 16x16; base address c000
        sta $2101
        
        lda #$09                    ;drawing mode
        sta $2105
        
        lda.b #!bg1tilemapshifted   ;bg1 tilemap base address
        sta $2107
        
        lda #$02                    ;bg2/1 tiles base address (nibble apiece)
        sta $210b
        
        lda.b #!bg2tilemapshifted   ;bg2 tilemap base address
        sta $2108
        
        lda.b #!bg3tilemapshifted   ;bg3 tilemap base address
        sta $2109
        
        lda.b #!bg3start>>12        ;bg3 tiles base address
        sta $210c
        
        lda #$0f
        sta !ppubrightnessmirror
        
        lda #$ff                    ;gotta set the bg scroll
        sta $210e                   ;to -1 because of course we do
        sta $210e
        sta $2112
        sta $2112
        sta !bg1y
        sta !bg2y
        stz !bg2x
        stz !bg2x
        stz !bg1x
        stz !bg1x
        rep #$20
        
        jsl dma_clearvram
        jsl dma_clearcgram
        jsl oam_fillbuffer
        jsl oam_hightablejank
    }
}
    ;fall through to main


;===========================================================================================
;======================================  M A I N  ==========================================
;===========================================================================================



main: {
    .stateinit: {
        stz !gamestate
        stz !gamefadecounter
    }
        
    .statehandle: {
        inc !maincounter
        lda !gamestate
        asl
        tax
        jsr (main_statetable,x)
        
        jsr waitfornmi
        
        jmp .statehandle
    }
        
    .statetable: {
        dw splashsetup     ;0
        dw splash          ;1
        dw newgame         ;2
        dw playgame        ;3
        dw gameover        ;4
        dw debug           ;5
        dw loadroom        ;6
        dw pause           ;7
        dw transition      ;8
        dw fade_out        ;9
        dw fade_in         ;a
        
        dw fadetoending    ;b
        dw setupending     ;c
        dw ending          ;d
    }
}


;===========================================================================================
;================================ STATE 0:  SPLASHSETUP  ===================================
;===========================================================================================

splashsetup: {
    jsr waitfornmi
    jsr screenoff           ;enable forced blank to do dmas
    
    jsr disablenmi
    
    sep #$20
    lda #%00010010
    sta !mainscreenlayers
    
    sta !subscreenbackdropblue
    sta !subscreenbackdropred
    sta !subscreenbackdropgreen
    rep #$20
    
    lda !kcolormathcolorfade
    sta !colormathmode
    
    lda #$0001              ;load gfx, tilemap, and palettes
    jsl load_background     ;for background 01 (splash screen)
    
    lda #$000c
    jsl load_sprite         ;"press start" sprite graphics
    
    lda #room_entry_title
    sta !roomptr
    
    jsl enemy_clearall
    jsl enemy_spawnall
    jsl enemy_runinit
    jsl enemy_drawall
    
    jsr enablenmi
    jsr waitfornmi
    
    jsr screenon
    lda #$0001
    sta !gamestate          ;advance to game state 1 (splash screen)
    rts
}


;===========================================================================================
;=================================== STATE 1:  SPLASH  =====================================
;===========================================================================================


splash: {
    
    waitforstart: {
        stz !oamentrypoint
        jsl oam_fillbuffer
        jsl oam_hightablejank
        jsl enemy_title
        jsl handlecolormath
        
        lda !controller
        bit !kst
        bne proceed
        rts
    }
    proceed:                ;proceed to
    lda !kstatenewgame
    sta !gamestate          ;advance to game state 2 (newgame)
    rts
}


;===========================================================================================
;================================== STATE 2:  NEWGAME  =====================================
;===========================================================================================


newgame: {
    
    jsr waitfornmi
    jsr screenoff           ;enable forced blank to do the following loading
    
    jsr disablenmi
    
    jsr hud_copytilemaptobuffer
    jsr hud_uploadgfx
    jsr hud_uploadtilemap
    
    lda #$0000
    jsl load_background     ;load data for layer 1 (object layer)
    
    ;this whole thing sucks but i don't want to rewrite it right now
    
    lda #$0000
    jsl load_sprite         ;load sprite data 0 (glider)
    
    lda #$0001
    jsl load_sprite         ;load sprite data 1 (balloon)
    
    lda #$0002
    jsl load_sprite         ;load sprite data 2 (prizes)
    
    lda #$0003
    jsl load_sprite         ;load sprite data 3 (dart)
    
    lda #$0004
    jsl load_sprite         ;load sprite data 4 (drip)
    
    lda #$0007
    jsl load_sprite         ;load sprite data 7 (fish)
    
    lda #$0008
    jsl load_sprite         ;load sprite data 8 (copter)
    
    lda #$0095              
    sta !gliderrespawnx
    
    lda #$0030
    sta !gliderrespawny
    
    jsl glider_init
    jsl hud_updatelives
    
    stz !colormathmode
    stz !colormathmodebackup
    jsl handlecolormath
    
    sep #$20
    lda #$01
    sta !ppubrightnessmirror
    rep #$20
    
    jsr fixlayerscroll
    
    lda #$0020              ;real starting room
    ;lda #$0051
    ;lda #$00d3             ;temp for testing ending
    ;lda #$0087             ;other temp
    ;lda #$0012
    ;lda #$0055
    sta !roomindex
    asl
    tax
    lda.l room_list,x
    sta !roomptr
    
    jsl obj_clearall
    jsl link_clearall
    jsl enemy_clearall
    
    jsr enablenmi
    jsr waitfornmi
    
    lda !kstateloadroom
    sta !gamestate
    
    rts
}


fixlayerscroll: {
    sep #$20
    lda #$ff                ;set layer y scrolls to -1
    sta !bg1y               ;because of course lol
    sta !bg1y               ;because of course lol
    sta !bg2y
    sta !bg2y
    rep #$20
    rts
}


;===========================================================================================
;============================== STATE 8:  ROOM TRANSITION  =================================
;===========================================================================================

transition: {
    jsr waitfornmi
    jsr screenoff
    ;leave force blank on
    
    jsr disablenmi
    jsl room_transition
    jsr enablenmi
    
    lda !kstateloadroom
    sta !gamestate
    
    rts
}

;===========================================================================================
;===============================  STATE 9/A:  FADE IN/OUT  =================================
;===========================================================================================

fade: {

    .in:
    .out: {
        
        inc !gamefadecounter
        
        lda !gamestate
        cmp !kstatefadeout
        sep #$20
        beq +                           ;if fading out
        
        ldx !gamefadecounter            ;else, use fading in table
        lda.l fade_intable,x
        bmi ..end
        sta !ppubrightnessmirror
        bra ..return
        
        +
        ldx !gamefadecounter            ;if fading out, use fading out table
        lda.l fade_outtable,x
        bmi ..end
        sta !ppubrightnessmirror


        ..return:
        rep #$20
        ;jsr waitfornmi
        rts
        
        ..end:
        rep #$20
        
        stz !gamefadecounter
        
        lda !gamestate
        cmp !kstatefadein       ;if fading in,
        beq +
        
        lda !kstateroomtrans            ;else (fading out), proceed to room transition game state
        sta !gamestate
        bra ..return
        
        +
        
        lda !kstateplaygame     ;go to gameplay
        sta !gamestate
        bra ..return
        
    }
    
    .outtable: {
     db $0f,
        $0c,
        $08,
        $05,
        $03,
        $01,
        $80
    }
    
    .intable: {
     db $01,
        $03,
        $07,
        $0f,
        $80
    }
}

;===========================================================================================
;================================== STATE 3:  PLAYGAME  ====================================
;===========================================================================================


playgame: {
    .loop: {
        inc !framecounter
        jsl game_play       ;one iteration (frame) of handling gameplay happens here
        rts
    }
    
    .out:
        lda #$0004
        sta !gamestate  ;unimplemented, old
        rts
}


handlecolormath: {
    lda !colormathmode
    asl
    tax
    
    sep #$20
    jsr (colormathmode_table,x)
    rep #$20
    
    rtl
}


colormathmode: {
    .table: {
        dw  .normal,             ;0
            .lightsout,          ;1
            .iframes,            ;2
            .coolmode,           ;3
            .colorfade,          ;4
            .evencooler          ;5
    }
    
    ;these routines all have sep #$20!
    
    .evencooler: {
        lda #%00000010          ;main screen
        sta !mainscreenlayers
        
        lda #%00010101          ;sub screen
        sta !subscreenlayers
        
        lda #%10111111          ;color math layers
        sta !colormathlayers
        
        lda #%00000011
        sta !colormathenable
        
        rts
    }
    
    .colorfade: {
        ;broken nonsense
        
        
        ;!subscreenbackdropblue
        ;!subscreenbackdropred
        ;!subscreenbackdropgreen
        
        ;lda.b !nmicounter
        ;bit #$11
        ;bne +
        
        ;lda !subscreenbackdropblue
        ;ror
        ;inc
        ;sta !subscreenbackdropblue
        ; 
        ;lda !subscreenbackdropred
        ;rol
        ;inc
        ;sta !subscreenbackdropred
        ; 
        ;ror !subscreenbackdropgreen
        
        lda #%00010000          ;color math on sprites, 2
        sta !colormathlayers
        ;+
        rts
    }
    
    
    .normal: {
        lda #%00010111          ;main screen = sprites, L2,1
        sta !mainscreenlayers
        
        lda #%00000000          ;sub screen = nothing
        sta !subscreenlayers
        
        lda #%00000000          ;color math off
        sta !colormathlayers
        
        lda #%00000000
        sta !colormathenable

        rts
    }
    
    
    .coolmode: {
        lda #%00000100          ;main screen
        sta !mainscreenlayers
        
        lda #%00010011          ;sub screen
        sta !subscreenlayers
        
        lda #%10111111          ;color math layers
        sta !colormathlayers
        
        lda #%00000011
        sta !colormathenable
        
        ;0-1f
        lda #$09
        sta !subscreenbackdropblue
        
        lda #$05
        sta !subscreenbackdropred
        
        lda #$10
        sta !subscreenbackdropgreen
        
        rts
    }
    
    
    .lightsout: {
        lda #%00010111          ;main screen
        sta !mainscreenlayers
        
        lda #%00000000          ;sub screen
        sta !subscreenlayers
        
        lda #%10100011          ;color math layers
        sta !colormathlayers
        
        lda #%00000011
        sta !colormathenable
        
        ;0-1f
        lda #$11
        sta !subscreenbackdropblue
        
        lda #$14
        sta !subscreenbackdropred
        
        lda #$11
        sta !subscreenbackdropgreen
        
        rts
    }
    

    .iframes: {
        lda #%00010111          ;main screen = sprites, 2, 1
        sta !mainscreenlayers
        
        lda #%00000011          ;sub screen = sprites
        sta !subscreenlayers
        
        lda #%00110000          ;color math layers = sprites
        sta !colormathlayers
        
        lda #%00000011
        sta !colormathenable
        
        
        lda #$10
        sta !subscreenbackdropblue
        
        lda #$08
        sta !subscreenbackdropred
        
        lda #$00
        sta !subscreenbackdropgreen
        
        rts
    }
}

coolmode: {
    lda !coolmode
    beq +
    
    lda !kcolormathcoolmode
    sta !colormathmode
    
    lda #$ffff
    sta !glideryspeed
    
    lda #$2000
    sta !gliderysubspeed
    
    rtl
    
+   stz !colormathmode
    
    lda !kglideryspeeddefault
    sta !glideryspeed
    
    lda !kgliderysubspeeddefault
    sta !gliderysubspeed
    
    rtl
}


iframecolormath: {
    ;todo: implement an option
    ;to have either style of iframes
    rtl
    
    
    lda !iframecounter
    beq +
    
    lda !kcolormathiframes
    sta !colormathmode
    rtl
    
    +
    lda !colormathmodebackup
    sta !colormathmode
    rtl
}

;===========================================================================================
;================================== STATE 4:  GAMEOVER  ====================================
;===========================================================================================


gameover: {
    jsl game_end
    rts
}


;===========================================================================================
;==================================   STATE 5:  DEBUG   ====================================
;===========================================================================================


debug: {
    .showcpu: {
        jsr screenoff
        nop #80
        jsr screenon
        rts
    }
    

    ;todo: write whatever routines here that you want
    ;to be useful for whatever
    
    .statehandle: {
        jsr screenoff
        jsr updatebackground
        lda !debugstate
        asl
        tax
        jsr (debug_statetable,x)
        jsr screenon
    }
    rts
    
    .statetable: {
        dw #debug_controller
    }
    
    .controller: {
        lda !controller
        
        ..st: {
            bit !kst
            beq ...nost
            ;if start pressed go here
            ...nost:
        }
        
        ..sl: {
            bit !ksl
            beq ...nosl
            ;if select pressed go here
            ...nosl:
        }
        
        ..up: {
            bit !kup
            beq ...noup
            sep #$20
            dec !bg2y
            rep #$20
            ...noup:
        }
        
        ..dn: {
            bit !kdn
            beq ...nodn
            sep #$20
            inc !bg2y
            rep #$20
            ...nodn:
        }
        
        ..lf: {
            bit !klf
            beq ...nolf
            sep #$20
            dec !bg2x
            rep #$20
            ...nolf:
        }
        
        ..rt: {
            bit !krt
            beq ...nort
            sep #$20
            inc !bg2x
            rep #$20
            ...nort:
        }
        
        ..a: {
            bit !ka
            beq ...noa
            ;if a pressed go here
            ...noa:
        }
        
        ..x: {
            bit !kx
            beq ...nox
            lda !backgroundupdateflag
            bne ...noupdate
            lda #$0002
            sta !backgroundtype
            sta !backgroundupdateflag
            ...nox:
            ...noupdate:
        }
        
        ..b: {
            bit !kb
            beq ...nob
            lda !backgroundupdateflag
            bne ...noupdate
            stz !backgroundtype
            lda #$0001
            sta !backgroundupdateflag
            ...nob:
            ...noupdate:
        }
        
        ..y: {
            bit !ky
            beq ...noy
            lda !backgroundupdateflag
            bne ...noupdate
            lda #$0001
            sta !backgroundtype
            sta !backgroundupdateflag
            ...noy:
            ...noupdate:
        }
        
        ..l: {
            bit !kl
            beq ...nol
            ;go here if l pressed
            ...nol:
        }
        
        ..r: {
            bit !kr
            beq ...nor
            inc !oambuffer
            ...nor:
        }
        rts
    }
}

scroll: {
    ;takes argument for direction
    L1: {
        rts
    }
    L2: {
        rts
    }
}

;===========================================================================================
;================================   STATE 6:  LOAD ROOM   ==================================
;===========================================================================================

loadroom: {
    jsr waitfornmi
    jsr screenoff
    jsr disablenmi
    
    stz !roomcounter
    jsl room_load
    
    jsr enablenmi
    jsr waitfornmi
    jsr screenon
    
    jsl game_play      ;not sure if this is a good idea or not
    
    lda !kstatefadein
    ;lda !kstateplaygame
    sta !gamestate
    rts
}


;===========================================================================================
;================================   STATE 7:  P A U S E   ==================================
;===========================================================================================

;unimplemented

pause: {
    jsl getinput
    
    
    dec !pausecounter
    bmi ++
    
    lda !controller
    cmp !kst
    beq +
    rts
    
    +
    lda !kpausewait
    sta !pausecounter
    lda #$0003
    sta !gamestate
    ++
    stz !controller
    rts
}


;===========================================================================================
;=============================   STATE B:  FADE TO ENDING   ================================
;===========================================================================================

fadetoending: {
    ;fade screen out slowly
    ;this state returns with forced blank enabled and screen brightness at 0
    
    lda !nmicounter
    bit #$0005
    bne +
    inc !gamefadecounter
    +
    
    sep #$20
    ldx !gamefadecounter
    lda.l fadetoending_outlist,x
    sta !ppubrightnessmirror
    beq .done
    rep #$20
    
    rts
    
    .done: {
        rep #$20
        jsr screenoff
        
        stz !gamefadecounter
        
        lda !kstatesetupending
        sta !gamestate
        rts
    }
    
    .outlist: {
        db 15, 15, 15, 15
        db 14, 14, 14, 14
        db 13, 13, 13, 13
        db 12, 12, 12, 12
        db 11, 11, 11, 11
        db 10, 10, 10, 10
        db 09, 09, 09, 09
        db 08, 08, 08, 08
        db 07, 07, 07, 07
        db 06, 06, 06, 06
        db 05, 05, 05, 05
        db 04, 04, 04, 04
        db 03, 03, 03, 03
        db 02, 02, 02, 02
        db 01, 01, 01, 01
        db 00
    }
}


;===========================================================================================
;=============================   STATE C:  SET UP ENDING   =================================
;===========================================================================================

setupending: {
    ;turn on forced blank, disaable nmi, load graphics
    ;build oam and display ending card
    
    jsr disablenmi
    
    sep #$20
    {
        lda #%00010101
        sta !mainscreenlayers       ;main screen = bg3, sprites
        
        lda #%00000001
        sta !subscreenlayers        ;subscreen = nothing
        
        lda.b #!spriteaddrshifted   
        ora.b #%01100000            ;sprite sizes = 16x16 and 32x32 (we only use large sprites)
        sta $2101
        
        lda #%00010100              ;color math layers
        sta !colormathlayers
        
        lda #%00000011
        sta !colormathenable
    }
    rep #$20
    
    jsr clearoambuffer
    jsr loadcreditsdata
    
    lda #room_entry_credits
    sta !roomptr
    
    jsl enemy_clearall
    jsl enemy_spawnall
    jsl enemy_runinit
    jsl enemy_drawall
    
    
    jsr enablenmi
    jsr waitfornmi
    
    ;and then we fade in clumsily
    
    sep #$20
    {
        -
        jsr waitfornmi
        
        lda !nmicounter
        bit #$07
        bne -
        
        lda !gamefadecounter
        inc
        sta !gamefadecounter
        sta !ppubrightnessmirror
        cmp #$0f
        bne -
        
    }
    rep #$20
    
    jsr waitfornmi
    jsr screenon
    
    lda !kstateendingcard
    sta !gamestate
    
    rts
}

clearoambuffer: {
    php
    rep #$30
    
    ldx #$0200
    
    -
    lda #$e0e0
    sta !oambuffer,x        ;"do we really need to unroll this loop?
    dex : dex               ;i domnt care"
    bpl -                   ; -me
    
    plp
    rts
}

loadcreditsdata: {
    php
    rep #$30
    
    lda #$000d
    jsl load_sprite         ;load graphics and palette for "THE END" sprite
    
    
    lda #creditstilemap
    sta !dmasrcptr
    
    lda #$0085
    sta !dmasrcbank
    
    lda #$0700
    sta !dmasize
    
    lda.w #!bg3tilemap
    sta !dmabaseaddr
    
    jsl dma_vramtransfur    ;bg3 tilemap with credits
    
    plp
    rts
}


;===========================================================================================
;==============================   STATE D:  ENDING CARD  ===================================
;===========================================================================================

ending: {
    ;handle whatever events might need to happen
    ;like reset game if start is pressed
    ;maybe do some animation
    stz !oamentrypoint
    
    jsl oam_fillbuffer
    jsl oam_hightablejank
    jsl enemy_title
    
    lda !controller
    cmp !kst|$8000
    bne +
    jml boot
    
    +
    rts
}


;===========================================================================================
;===================================                   =====================================
;===================================    N    M    I    =====================================
;===================================                   =====================================
;===========================================================================================


nmi: {
    phb
    pha
    phx
    phy
    
    jml .fastrom
    .fastrom:
    
    phk
    plb
    
    sep #$10
    ldx $4210
    ldx !nmiflag
    rep #$10
    beq .lag
    
    jsl oam_write               ;dma from wram buffer to oam
    jsl obj_tilemap_upload
    jsr updateppuregisters      ;read wram buffer and write register
    jsr readcontroller
    jsr hud_uploadtilemappartial
    jsr foilpalette
    
    lda !gamestate
    cmp !kstateplaygame
    bne +
    jsr glidergraphicsupdate
    +
    
    stz !nmiflag
    
    .return
    ply
    plx
    pla
    plb
    inc !nmicounter
    rti
    
    .lag
    inc !lagcounter
    bra .return
}


glidergraphicsupdate: {
    php
    
    lda !glidergraphicsindex
    asl
    tax
    lda glidergraphicsupdate_list,x
    sta !dmasrcptr
    
    
    rep #$20
    sep #$10
                                            ;width  register
    ldx.b #$80                              ;1      dma control
    stx $2115
    
    lda #!spritestart                       ;2      dest base addr
    sta $2116
    
    ldx #$01                                ;1      transfur mode
    stx $4300
    
    ldx #$18                                ;1      register dest (vram port)
    stx $4301
    
    lda !dmasrcptr                          ;2      source addr
    sta $4302
    
    ldx.b #((gliderdata&$ff0000)>>16)+0     ;1      source bank
    stx $4304
    
    lda #$0400                              ;2      transfur size
    sta $4305
    
    ldx #$01                                ;1      enable transfur on dma channel 0
    stx $420b
    
    
    plp
    rts
    
    .list: {
        dw gliderdata_graphics, gliderdata_greasegraphics
    }
}


foilpalette: {
    lda !foilamount
    beq +
    
    lda #$0005*8                ;sprite 5
    sta !dmaloadindex
    jsr load_sprite_palette
    rts
    
+   stz !dmaloadindex           ;if no foil, upload normal palette
    jsr load_sprite_palette
    rts
}



waitfornmi: {
    php
    sep #$20
    lda #$01
    sta !nmiflag
    rep #$20
    
    lda !showcpuflag
    beq +
    jsr debug_showcpu
    +
    
    .waitloop: {
        lda !nmiflag
    } : bne .waitloop
    plp
    rts
}


screenon: {         ;turn screen brightness on and disable forced blank
    pha
    sep #$20
    lda !ppubrightnessmirror
    and #$7f
    sta $2100
    rep #$20
    pla
    rts
}


screenoff: {        ;enable forced blank
    pha
    sep #$20
    lda !ppubrightnessmirror
    ora #$80
    sta $2100
    rep #$20
    pla
    rts
}

disablenmi: {
    sep #$20
    stz $4200
    rep #$20
    rts
}

enablenmi: {
    sep #$20
    lda #$80
    sta $4200
    rep #$20
    rts
}

halfbrightness: {
    php
    sep #$20
    lda #$02
    sta $2100
    plp
    rts
}


readcontroller: {
    php
    sep #$20
    lda #$81            ;enable controller read
    sta $4200
    waitforread:
    lda $4212
    bit #$01
    bne waitforread
    rep #$20
    
    lda $4218           ;store to wram
    sta !controller
    plp
    rts
}


updateppuregisters: { ;transfer wram mirrors to their registers
    ;!mainscreenlayers   =       $b0     ;$212c
    ;!subscreenlayers    =       $b1     ;$212d
    ;!colormathlayers    =       $b2     ;$2131
    ;!colormathbackdrop  =       $b3     ;$2132
    ;!colormathenable    =       $b4     ;$2130
    
    sep #$20
    
    ;these scroll updates are probably unnecessary
    ;ugh
    ;no wait they are needed
    ;i have done this thing where i comment this out
    ;and then the scroll values of the background layers is wrong
    ;so please just leave this here, okay?
    
    lda !bg1x
    sta $210d           ;update bg1 x scroll
    sta $210d
    lda !bg1y           ;update bg1 y scroll
    sta $210e
    sta $210e
    
    lda !bg2x
    sta $210f
    sta $210f
    lda !bg2y
    sta $2110
    sta $2110
    
    lda !gamefadecounter
    beq .nofade
    lda !ppubrightnessmirror
    sta $2100
    .nofade:
    
    ;lda !gamestate
    ;cmp !kstateplaygame8
    ;bne +
    
    lda !mainscreenlayers
    sta $212c
    
    lda !subscreenlayers
    sta $212d
    
    lda !colormathlayers
    sta $2131
    
    ;lda !colormathbackdrop
    ;sta $2132
    
    lda !colormathenable
    sta $2130
    
    ;lda #$00
    lda !subscreenbackdropred
    ora #%00100000
    sta $2132
    
    ;lda #$00
    lda !subscreenbackdropgreen
    ora #%01000000
    sta $2132
    
    ;lda #$00
    lda !subscreenbackdropblue
    ora #%10000000
    sta $2132
    
    
    +
    
    rep #$20
    rts
}


updatebackground: {
    lda !backgroundupdateflag
    beq +
    
    jsr screenoff
    lda !backgroundtype
    jsl load_background
    stz !backgroundupdateflag
+   rts
}



errhandle: {
    jml errhandle
}


irq: {
    rti
}

hightablefill: {
    lda #$aaaa
    ldx #$0080
    -
    sta !oambuffer,x
    dex : dex
    bpl -
    rts
}
