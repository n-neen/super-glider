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


boot:
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

clear7e:
    pea $7e7e
    plb : plb
    ldx #$fffe
-   stz $0000,x     ;loop to clear all of $7e
    dex : dex       ;definitely don't jsr to here or you'll obliterate your return address lol
    bne -
    
clear7f:
    pea $7f7f
    plb : plb
    ldx #$7ffe
--  stz $0000,x
    stz $8000,x
    dex : dex
    bpl --
    

init:
    .registers:
        
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
        
        ;set up ppu
        
        lda #%00010110      ;main screen = sprites, L2
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
        jsl oam_fillbuffer
        jsl dma_clearcgram
        
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
        inc !maincounter                ;main switch case jump table loop
        lda !gamestate
        asl
        tax
        jsr (main_statetable,x)
        
        jsr waitfornmi
        
        jmp .statehandle
    }
        
    .statetable: {
        dw #splashsetup     ;0
        dw #splash          ;1
        dw #newgame         ;2
        dw #playgame        ;3
        dw #gameover        ;4
        dw #debug           ;5
        dw #loadroom        ;6
        dw #pause           ;7
        dw #transition      ;8
        dw #fade_out        ;9
        dw #fade_in         ;a
    }
}


;===========================================================================================
;================================ STATE 0:  SPLASHSETUP  ===================================
;===========================================================================================

splashsetup: {
    jsr waitfornmi
    jsr screenoff           ;enable forced blank to to the following dmas
    
    lda #$0001              ;load gfx, tilemap, and palettes
    jsl load_background     ;for background 01 (splash screen)
    
    lda #$000c
    jsl load_sprite         ;"press start" sprite graphics
    
    lda #$0001
    jsl load_sprite         ;load sprite data 1 (balloon)
    
    lda #room_entry_title
    sta !roomptr
    
    jsl enemy_clearall
    jsl enemy_spawnall
    jsl enemy_runinit
    jsl enemy_drawall
    
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
        
        jsr waitfornmi
        lda !controller
        cmp #$1000
        beq proceed
        rts
    }
    proceed:                ;proceed to
    lda #$0002
    sta !gamestate          ;advance to game state 2 (newgame)
    rts
}


;===========================================================================================
;================================== STATE 2:  NEWGAME  =====================================
;===========================================================================================


newgame: {
    
    jsr waitfornmi
    jsr screenoff           ;enable forced blank to do the following loading
    
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
    
    jsr fixlayerscroll
    
    lda #$0020             ;real starting room
    ;lda #$00d3             ;temp for testing ending
    ;lda #$0082             ;other temp
    sta !roomindex
    asl
    tax
    lda.l room_list,x
    sta !roomptr
    
    jsl obj_clearall
    
    jsl link_clearall
    
    lda #$0006
    sta !gamestate          ;advance to game state 6 (load room)
    
    lda debugflag
    beq +
    lda #$0005
    sta !gamestate          ;if [debug], goto debug setup mode
+   rts
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

;unimplemented

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
        ldx !gamefadecounter            ;use fading out table
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
        $03,
        $80
    }
    
    .intable: {
     db $01,
        $02,
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
            .coolmode            ;3
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
        lda #$13
        sta !subscreenbackdropblue
        
        lda #$16
        sta !subscreenbackdropred
        
        lda #$15
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
        nop #40
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
    
    ;lda !kstatefadein
    lda !kstateplaygame
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
;===================================                   =====================================
;===================================    N    M    I    =====================================
;===================================                   =====================================
;===========================================================================================


nmi: {
    phb
    pha
    phx
    phy
    
    phk         ;db=80
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
    lda #$0f
    sta $2100
    rep #$20
    pla
    rts
}


screenoff: {        ;enable forced blank
    pha
    sep #$20
    lda #$80
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
    ;i have done this thing where i comment this shit out
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
    
    lda !gamestate
    cmp !kstateplaygame8
    bne +
    
    lda !mainscreenlayers
    sta $212c
    
    lda !subscreenlayers
    sta $212d
    
    lda !colormathlayers
    sta $2131
    
    lda !colormathbackdrop
    sta $2132
    
    lda !colormathenable
    sta $2130
    
    lda #$00
    ora !subscreenbackdropred
    ora #%00100000
    sta $2132
    
    lda #$00
    ora !subscreenbackdropgreen
    ora #%01000000
    sta $2132
    
    lda #$00
    ora !subscreenbackdropblue
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
