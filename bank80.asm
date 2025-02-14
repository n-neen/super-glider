lorom

org $808000

;===========================================================================================
;======================================  DEFINES  ==========================================
;===========================================================================================


!gamestate              =           $30
!debugstate             =           $32
!maincounter            =           $20
!nmiflag                =           $22
!nmicounter             =           $24
!framecounter           =           $26
!bg1x                   =           $40
!bg1y                   =           $42

!bg1tilemapshifted      =           !bg1tilemap>>8
!spriteaddrshifted      =           !spritestart>>13

!backgroundupdateflag   =           $6fe
!backgroundtype         =           $700


;===========================================================================================
;======================================  B O O T  ==========================================
;===========================================================================================

debugflag:
    dw $0001


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
    

clear7e:
    pea $7e7e
    plb : plb
    ldx #$fffe
-   stz $0000,x     ;loop to clear all of $7e
    dex : dex       ;definitely don't jsr to here or you'll obliterate your return address lol
    bne -
    

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
        lda #%00010001      ;main screen = sprites, L1, L2
        sta $212c
        
        lda.b #!spriteaddrshifted   ;sprite size: 8x8 + 16x16; base address c000
        sta $2101
        
        lda #$01                    ;drawing mode
        sta $2105
        
        lda.b #!bg1tilemapshifted   ;bg1 tilemap base address
        sta $2107
        
        lda #$ff                    ;gotta set the bg1 scroll
        sta $210e                   ;to -1 because of course we do
        sta $210e
        
        lda #$00                    ;bg1 tiles base address
        sta $210b
        rep #$20
        
        jsl dma_clearvram
}   ;fall through to main


;===========================================================================================
;======================================  M A I N  ==========================================
;===========================================================================================


main: {
    .stateinit: {
        stz !gamestate
    }
        
    .statehandle: {
        inc !maincounter                ;main switch case jump table loop
        lda !gamestate                  ;usually, state handler will 
        asl                             ;return after running once, like newgame
        tax                             ;or itself has a loop, like playgame
        jsr (main_statetable,x)
        
        jmp .statehandle
    }
        
    .statetable: {           ;program modes, game states, etc
        dw #splash          ;0
        dw #newgame         ;1
        dw #playgame        ;2
        dw #gameover        ;3
        dw #debug           ;4
    }
}




;===========================================================================================
;=================================== STATE 0:  SPLASH  =====================================
;===========================================================================================


splash: {
    jsr waitfornmi
    jsr screenoff           ;enable forced blank to to the following dmas
    
    lda #$0000              ;load gfx, tilemap, and palettes
    jsl load_background     ;for background 00 (splash screen)
    
    jsr screenon
    
    waitforstart: {
        jsr waitfornmi
        lda !controller
        cmp #$1000
        beq proceed
    } : jmp waitforstart
    proceed:                ;proceed to
    inc !gamestate          ;advance to game state 1 (newgame)
    rts
}


;===========================================================================================
;================================== STATE 1:  NEWGAME  =====================================
;===========================================================================================


newgame: {
;prospective outline of newgame
    ;load house data
    ;identify starting room
    ;load starting room's data
        ;starting room informs the following:
        ;background palettes,
        ;background graphics,
        ;background tilemap
    ;load sprite graphics
    ;load sprite palettes
    ;place glider
    ;jsl gliderinit
    
    jsr waitfornmi
    jsr screenoff           ;enable forced blank to do the following dmas
    
    lda #$0002
    jsl load_background     ;load background 2 (panneled room)
    
    lda #$0000
    jsl load_sprite         ;load sprite data 0 (glider)
    
    jsr screenon

    inc !gamestate          ;advance to game state 2
    
    lda debugflag
    beq +
    lda #$0004
    sta !gamestate          ;if [debug], goto debug game mode
+   rts
}


;===========================================================================================
;================================== STATE 2:  PLAYGAME  ====================================
;===========================================================================================


playgame: {
    jsr screenon
    
    stz !nmiflag
    sep #$20
    lda #$80
    sta $4200
    rep #$20
    
    .loop: {
        inc !framecounter
        jsl game_play       ;one iteration (frame) of handling gameplay happens here
        jsr waitfornmi
        
        ;if [youdied]: jmp .out
        jmp .loop
    }
    
    .out:
        inc !gamestate      ;advance gamestate from 2 (playgame) to 3 (endgame)
        rts
}


;===========================================================================================
;================================== STATE 3:  GAMEOVER  ====================================
;===========================================================================================


gameover: {
    jsl game_end
    rts
}


;===========================================================================================
;==================================   STATE 4:  DEBUG   ====================================
;===========================================================================================

;controller bits
!b                      =           #$8000
!y                      =           #$4000
!st                     =           #$2000
!sl                     =           #$1000
!up                     =           #$0800
!dn                     =           #$0400
!lf                     =           #$0200
!rt                     =           #$0100
!a                      =           #$0080
!x                      =           #$0040
!l                      =           #$0020
!r                      =           #$0010


debug: {
    .init: {
        lda #$0000
        sta !debugstate
        sep #$20
        lda #$ff
        sta $210e           ;set bg1 scroll to -1
        sta $210e
        sta !bg1y
        rep #$20
    }
    ;todo: write whatever routines here that you want
    ;to be useful for whatever
    
    .statehandle: {
        jsr waitfornmi
        jsr screenoff
        stz !nmiflag
        jsr updatebackground
        lda !debugstate
        asl
        tax
        jsr (debug_statetable,x)
        jsr screenon
        jmp .statehandle
    }
    rts

    .statetable: {
        dw #debug_controller
    }
    
    .controller: {
        lda !controller
        
        ..st: {
            bit !st
            beq ...nost
            ...nost:
        }
        
        ..sl: {
            bit !sl
            beq ...nosl
            ...nosl:
        }
        
        ..up: {
            bit !up
            beq ...noup
            sep #$20
            dec !bg1y
            rep #$20
            ...noup:
        }
        
        ..dn: {
            bit !dn
            beq ...nodn
            sep #$20
            inc !bg1y
            rep #$20
            ...nodn:
        }
        
        ..lf: {
            bit !lf
            beq ...nolf
            sep #$20
            dec !bg1x
            rep #$20
            ...nolf:
        }
        
        ..rt: {
            bit !rt
            beq ...nort
            sep #$20
            inc !bg1x
            rep #$20
            ...nort:
        }
        
        ..a: {
            bit !a
            beq ...noa
            ...noa:
        }
        
        ..x: {
            bit !x
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
            bit !b
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
            bit !y
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
            bit !l
            beq ...nol
            ...nol:
        }
        
        ..r: {
            bit !r
            beq ...nor
            ...nor:
        }
        rts
    }
}

;===========================================================================================
;===================================                   =====================================
;===================================    N    M    I    =====================================
;===================================                   =====================================
;===========================================================================================


nmi: {
    rep #$30
    php
    phb
    phd
    pha
    phx
    phy
    
    phk         ;db=80
    plb
    lda #$0000
    tcd
    
    sep #$10
    ldx $4210
    ldx !nmiflag
    beq .return
    
    jsl oam_update              ;dma from wram buffer to oam
    jsr updateppuregisters      ;dma from wram buffer to a whole bunch of stuff
    jsr readcontroller
    stz !nmiflag
    
    .return
    rep #$30
    ply
    plx
    pla
    pld
    plb
    plp
    inc !nmicounter
    rti
}


waitfornmi: {
    php
    sep #$20
    lda #$01
    sta !nmiflag
    rep #$20
    
    .waitloop: {
        lda !nmiflag
    } : bne .waitloop
    plp
    rts
}


screenon: {
    pha
    sep #$20
    lda #$0f
    sta $2100           ;turn screen brightness on and disable forced blank
    rep #$20
    pla
    rts
}


screenoff: {
    pha
    sep #$20
    lda #$8f
    sta $2100           ;enable forced blank
    rep #$20
    pla
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
    sep #$20
    lda !bg1x
    sta $210d           ;update bg1 x scroll
    sta $210d
    lda !bg1y           ;update bg1 y scroll
    sta $210e
    sta $210e
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


errhandle:
    jml errhandle


irq:
    rti
    