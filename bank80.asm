lorom

org $808000

;===========================================================================================
;===================================  DEFINES  =============================================
;===========================================================================================

!gamestate              =           $30
!maincounter            =           $20
!nmiflag                =           $22
!nmicounter             =           $24
!framecounter           =           $26

!oambuffer              =           $500                       ;start of oam table to dma at nmi

!bg1tilemapshifted  =           !bg1tilemap>>8

;===========================================================================================
;===================================  B O O T  =============================================
;===========================================================================================

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
    phk
    plb
    ;fall through

init:
    .registers:
        sep #$30            ;<-------
        lda #$8f
        sta $2100           ;enable forced blank
        lda #$01
        sta $4200           ;enable joypad autoread
        rep #$30            ;<-------
        
        
        ldx #$000a
-       stz $4200,x         ;clear registers $4200-$420b
        dex : dex
        bne - 
        
        ldx #$0084          ;clear registers $2101-2184
--      stz $2101,x
        dex : dex
        bne --
        
        jsl clearvram
        
        sep #$20        ;<------------
        lda #$80            ;enable nmi
        sta $4200
        lda #%00010001      ;main screen = sprites, L1, L2
        sta $212c
        
        lda #%00000000      ;sprite size: 8x8 + 16x16; base address 0000
        sta $2101
        
        lda #$01                    ;drawing mode
        sta $2105
        lda.b #!bg1tilemapshifted   ;bg1 tilemap base address
        sta $2107
        lda #$00                    ;bg1 tiles base address
        sta $210b
        rep #$20        ;<------------
}   ;fall through to main

;===========================================================================================
;===================================  M A I N  =============================================
;===========================================================================================

main: {
        .stateinit: {
            lda #$0000
            sta !gamestate
        }
        
        .statehandle: {
            inc !maincounter                ;main switch case jump table loop
            lda !gamestate                  ;usually, state handler will 
            asl                             ;return after running once, like newgame
            tax                             ;or itself has a loop, like playgame
            jsr (statetable,x)
            
            jmp .statehandle
        }
}


statetable:             ;program modes, game states, etc
    dw #splash          ;0
    dw #newgame         ;1
    dw #playgame        ;2
    dw #gameover        ;3

;===========================================================================================
;=================================== STATE 0:  SPLASH  =====================================
;===========================================================================================

splash: {
    !backgroundtype         =       $700
    
    jsr screenoff
    
    lda #$0000              ;not currently implemented
    sta !backgroundtype     ;we will eventually use this to determine a set of:
    jsl splashload_gfx                                      ;bg1 gfx
    jsl splashload_tilemap                                  ;bg1 tilemaps
    jsl splashload_palettes                                 ;and palettes
    
    jsr screenon
    
    waitforstart: {
        ;todo
    } : jmp waitforstart
    
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
    
    jsr screenoff
    
    lda #$0001              ;not currently implemented
    sta !backgroundtype     ;we will eventually use this to determine a set of:
    jsl bg1_loadgfx                                     ;bg1 gfx
    jsl bg1_loadtilemap                                 ;bg1 tilemaps
    jsl loadpalettes                                    ;and palettes
    
    jsl gliderload      ;exists
    
    jsr screenon
    
    
    
    inc !gamestate      ;advance to game state 2
    rts
}

;===========================================================================================
;================================== STATE 2:  PLAYGAME  ====================================
;===========================================================================================

playgame: {
    jsr screenon
    .loop: {
        inc !framecounter
        ;jsl getinput
        ;jsl handle_objects
        ;jsl handle_interaction
        ;jsl handle_switches
        ;jsl handle_bands
        ;jsl handle_glider
        ;jsl handle_background
        
        ;if [you died]: jmp .out
        jsr waitfornmi
        jmp .loop
    }
    
    .out:
        inc !gamestate   ;advance gamestate from 2 (playgame) to 3 (endgame)
        rts
}

waitfornmi: {
    php
    phb
    
    sep #$20
    lda $01
    sta !nmiflag
    rep #$20
    lda !nmiflag
    bne waitfornmi
    
    plb
    plp
    rts
}


gameover: {
    ;todo
    rts
}

;===========================================================================================
;===================================  N  M  I  =============================================
;===========================================================================================

nmi: {
    rep #$30
    php
    phb
    phd
    pha
    phx
    phy
    
    phk
    plb
    lda #$0000
    tcd
    
    sep #$10
    ldx $4210
    ldx !nmiflag
    beq .return
    
    jsr updateoam               ;dma from wram buffer to oam
    jsr updateppuregisters      ;dma from wram buffer to a whole bunch of stuff
    
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


screenon: {
    sep #$30
    lda #$0f
    sta $2100           ;turn screen brightness on and disable forced blank
    rep #$30            ;<-------
    rts
}


screenoff: {
    sep #$20
    lda #$8f
    sta $2100           ;enable f-blank
    rep #$20
}









updateoam: {
    ;todo
    rts
}


updateppuregisters: {
    ;todo
    rts
}


errhandle:
    jml errhandle


irq:
    rti
    
