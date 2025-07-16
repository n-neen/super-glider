lorom

org $828000

;===========================================================================================
;=================================    G A M E P L A Y    ===================================
;===========================================================================================

hightablejank: {
    phx
    ldx #$0020
-   lda !oamhightable,x
    ora #$aaaa
    sta !oamhightable,x
    dex : dex
    bpl -
    plx
    rts
}

    
game: {
    .play: {
        jsl getinput
        
        jsl obj_collision
        jsl obj_handle
        
        jsr glider_handle
        jsr glider_newdraw
        
        jsr hightablejank       ;fills oam buffer high table
        rtl
    }
    
    
    .end: {
        ;todo
        rtl
    }
    
    .pause: {
        pha
        
        lda !kpausewait
        sta !pausecounter
        
        lda !kstatepause
        sta !gamestate
        
        pla
        rts
    }
}

noinput: {
    stz !gliderstate
    rts
}


getinput: {
    phx
    ;use x for general stores here to preserve A
    lda !controller
    ;beq noinput
    
    .st: {
        bit !kst
        beq ..nost
            ;jsr game_pause
        ..nost:
    }
    
    .sl: {
        bit !ksl
        beq ..nosl
            ;if select pressed go here
        ..nosl:
    }
    
    .up: {                                      ;dpad start
        bit !kup
        beq ..noup
            ;pha
            ;%gliderpositionsub(!glidery)       ;debug only!
            ;pla
        ..noup:
    }
    
    .dn: {
        bit !kdn
        beq ..nodn
            ;pha
            ;%gliderpositionadd(!glidery)       ;debug only!
            ;pla
        ..nodn:
    }
    
    .lf: {
        bit !klf
        beq ..nolf
        
            ldx !kgliderstateleft
            stx !glidernextstate
            
            ;ldx !kgliderdirleft
            ;stx !gliderdir
        
            ldx #$0002
            stx !glidermovetimer
        ..nolf:
    }
    
    .rt: {
        bit !krt
        beq ..nort
        
            ldx !kgliderstateright
            stx !glidernextstate
            
            ;ldx !kgliderdirright
            ;stx !gliderdir
        
            ldx #$0002
            stx !glidermovetimer
        ..nort:
    }                                           ;dpad end
    
    .a: {
        bit !ka
        beq ..noa
            stz !gliderliftstate
        ..noa:
    }
    
    .x: {
        bit !kx
        beq ..nox
            ;if pressed go here
            ;current plan: fire bands
        ..nox:
    }
    
    .b: {
        bit !kb
        beq ..nob
            ;if pressed go here
            ldx !kgliderstateturnaround
            stx !glidernextstate
        ..nob:
    }
    
    .y: {
        bit !ky
        beq ..noy
            ;if pressed go here
            ;current plan: use battery
        ..noy:
    }
    
    .l: {
        bit !kl
        beq ..nol
            ldx !kliftstatedown
            stx !gliderliftstate
        ..nol:
    }
    
    .r: {
        bit !kr
        beq ..nor
            ldx !kliftstateup
            stx !gliderliftstate
        ..nor:
    }
    plx
    rtl
}

glider: {

    .init: {
        ;this is laid out like this so we can:
        ;call glider_init on newgame
        ;call glider_init_spawn on death to reset
        
        lda #$0004
        sta !gliderlives
        
        ..spawn: {
            lda #$0030
            sta !gliderx            ;glider initial position
            sta !glidery
            lda !kliftstatedown
            sta !gliderliftstate
        }
        rtl
    }

    .draw: {
        ;todo: high table macro like this
       
        macro oambufferwrite(spriteindex,spritebyte)
            !kspriteentrylength     =   $0004
            sta !oambuffer+(!kspriteentrylength*<spriteindex>)+<spritebyte>
        endmacro
        
        
        
        sep #$20
        
        ;=========================================================glider sprite 1
        
        lda !gliderx                    ;x position
        clc
        adc #$f0
        %oambufferwrite(0, 0)
        
        lda !glidery                    ;y position
        %oambufferwrite(0, 1)
        
        lda #$00                        ;tile index
        %oambufferwrite(0, 2)
        
        lda #%00110000                  ;properties (tile flip, priority, palette)
        %oambufferwrite(0, 3)
        
        lda !oambuffer+$200
        ora #%00000010                  ;high table (size select)
        sta !oambuffer+$200
        
        ;=========================================================glider sprite 2
        
        lda !gliderx
        %oambufferwrite(1, 0)
        
        lda !glidery
        %oambufferwrite(1, 1)
        
        lda #$02
        %oambufferwrite(1, 2)
        
        lda #%00110000
        %oambufferwrite(1, 3)
        
        lda !oambuffer+$200
        ora #%00001000
        sta !oambuffer+$200
        
        ;=========================================================glider sprite 3
        
        lda !gliderx
        clc
        adc #$10
        %oambufferwrite(2, 0)
        
        lda !glidery
        %oambufferwrite(2, 1)
        
        lda #$04
        %oambufferwrite(2, 2)
        
        lda #%00110000
        %oambufferwrite(2, 3)
        
        lda !oambuffer+$200
        ora #%00100000
        sta !oambuffer+$200
        
        rep #$20
        rts
    }
    
    .nodraw: {
        lda !oamentrypointbckp
        sta !oamentrypoint
        rep #$20
        plp
        plb
        plx
        rts
    }
    
    .newdraw: {
        ;todo: read from spritemaps_glider in spritemaps.asm
        ;prospective outline:
        ;y = oam entry index
        ;actually no, this drawing routine happens first
        ;so we draw glider then save the starting index for the next objects drawn
        
        phx
        phb
        php
        
        phk
        plb
        
        ldy #$0000
        
        stz !oamhightableindex
        stz !oamentrypoint
        stz !spriteindex
        
        lda !gliderdir                ;see glider constants in defines.asm
        
        asl
        tax
        lda spritemap_pointers,x
        tax                             ;x = spritemap pointer
        
        sep #$20
        
        lda $0000,x                     ;number of sprites in spritemap
        sta !numberofsprites
        beq +
        
        inx
        
        -
        lda $0000,x                     ;x position
        clc
        adc !gliderx
        sta !oambuffer,y
        iny
        
        lda $0001,x                     ;y position
        clc
        adc !glidery
        sta !oambuffer,y
        iny
        
        lda $0002,x                     ;tile number
        sta !oambuffer,y
        iny
        
        lda $0003,x                     ;properties
        sta !oambuffer,y
        iny
        
        ;jsr .newdraw_hightablebitwrite
        
        txa
        clc
        adc #$05                        ;x = x + 5 (next sprite entry)
        tax
        
        inc !spriteindex
        dec !numberofsprites
        bne -
        
        sty !oamentrypoint              ;glider gets drawn first, then the other sprites
        sty !oamentrypointbckp          ;so we need to keep track of oam entry point after each drawing stage
        
    +   rep #$20
        plp
        plb
        plx
        rts
        
        
        ..hightablebitwrite: {
            ;parameters:
            ;x = spritemap pointer
            ;y = oam index
            ;sep #$20
            
            ;returns:
            ;a = oam high table bitmaks to write
            
            php
            phy
            phx
            rep #$30
            
            lda oamhighbytes,y
            and #$00ff
            
            
            tay
            lda !oamhightable,y
            ora #$aaaa
            sta !oamhightable,y
            
        +   plx
            ply
            plp
            rts
        }
    }
    
    
    .gameover: {
        jml boot
    }
    
    .handle: {
        ;high level checks that need to be done regardless of glider state go here
        ;like falling (happens always unless on a vent)
        ;or room bounds (always needs to be checked)
        ;or pose update
        ;then go to state handler
        
        lda !gliderlives
        beq glider_gameover
        
        jsr glider_turnaround_handletimer
        
        ..lift: {
            lda !gliderliftstate
            beq ..bounds            ;if 0, exit (like we hit the ceiling)
            
            cmp !kliftstateup       ;if 1, go up
            beq ...up
            
            cmp !kliftstatedown     ;if 2, go down
            beq ...down
            
            bra +                   ;else (should not be reachable!)
            
            ...up:
                lda !glidery
                cmp !kceiling       ;if hit ceiling, exit (do not go up or down)
                bmi +
                ;else, go up:
                
                ;the actual going of up:
                lda !glidersuby
                sec
                sbc !kgliderysubspeed
                sta !glidersuby
                lda !glidery
                sbc #$0000
                sta !glidery
                
                
                bra ..bounds
            ...down:
                lda !glidery
                cmp !kfloor
                bpl ...hitfloor
                ;else, go down:
                
                lda !glidersuby
                clc
                adc !kgliderysubspeed
                sta !glidersuby
                lda !glidery
                adc #$0000
                sta !glidery
                
                bra ..bounds
                
            +  
            stz !gliderliftstate    ;we only end up here if we hit the ceiling
            bra ..bounds
            
            ...hitfloor:
            stz !gliderliftstate
            lda !kgliderstatelostlife
            sta !gliderstate
            
        }   ;fall through to ..bounds
        
        
        ..bounds: {
            lda !gliderx            ;hit left bound = 1
            cmp !kleftbound
            bne ++
            lda !khitboundleft
            sta !gliderhitbound
            bra +++
        ++
            cmp !krightbound        ;hit right bound = 2
            bne +++
            lda !khitboundright
            sta !gliderhitbound
        +++
        
        }
        
        
        ..state: {
            
            lda !gliderstate
            cmp !glidernextstate
            bne ..state_changestate
            ...resume:
            lda !gliderstate
            asl
            tax
            jsr (glider_handle_state_table,x)
            jsr glider_resetliftstate               ;the actual falling of down
            rts
            
            ...changestate: {
                ;todo: something
                lda !glidernextstate
                sta !gliderstate
                jmp ..state_resume
            }
            
            ...table: {
                dw #.idle,              ;0
                   #.movingleft,        ;1
                   #.movingright,       ;2
                   #.tipleft,           ;3
                   #.tipright,          ;4
                   #.turnaround,        ;5
                   #.lostlife           ;6
            }
        }
    }
    
    
    .idle: {
        stz !gliderhitbound     ;i cant believe this works
        rts
    }
    
    .lostlife: {
        dec !gliderlives
        ;stz !gliderstate
        stz !glidernextstate
        jsl glider_init_spawn
        rts
    }
    
    .movingleft: {
        lda !gliderhitbound
        cmp !khitboundleft      ;left bound = 1
        beq ++
        
        lda !glidermovetimer
        beq +
        
        ;the actual moving of left:
        lda !glidersubx
        sec
        sbc !kgliderxsubspeed
        sta !glidersubx
        
        lda !gliderx
        sbc #$0000
        sta !gliderx
        
        dec !glidermovetimer
        beq ++
    +   
        rts
    
    ++  stz !glidernextstate
        stz !glidermovetimer
        rts
    }
    
    .movingright: {
        lda !gliderhitbound
        cmp !khitboundright     ;right bound = 2
        beq ++
        
        lda !glidermovetimer
        beq +
        
        ;the actual moving of right:
        lda !glidersubx
        clc
        adc !kgliderxsubspeed
        sta !glidersubx
        lda !gliderx
        adc #$0000
        sta !gliderx
        
        dec !glidermovetimer
        beq ++
    +   
        rts
    
    ++  stz !glidernextstate
        
        stz !glidermovetimer
        rts
    }
    
    .tipleft: {
        ;
        rts
    }
    
    .tipright: {
        ;
        rts
    }
    
    .bounceoffbound: {
        ;todo
        rts
    }
    
    .turnaround: {
        lda !gliderturntimer            ;if timer = 0, exit
        bne +
        
        lda !gliderdir
        eor !kgliderdirleft             ;direction switch
        sta !gliderdir
        
        lda !kturnaroundcooldown
        sta !gliderturntimer
        
        +
        stz !gliderstate
        stz !glidernextstate
        rts
        
        ..handletimer: {
            lda !gliderturntimer
            beq +
            dec
            sta !gliderturntimer
            
        +   rts
        }
    }
    
    .resetliftstate: {
        lda !kliftstatedown
        sta !gliderliftstate
        rts
    }
}

oamhighbytes: {
    db $00, $00, $00, $00
    db $01, $01, $01, $01
    db $02, $02, $02, $02
    db $03, $03, $03, $03
    db $04, $04, $04, $04
    db $05, $05, $05, $05
    db $06, $06, $06, $06
    db $07, $07, $07, $07
    db $08, $08, $08, $08
    db $09, $09, $09, $09
    db $0a, $0a, $0a, $0a
    db $0b, $0b, $0b, $0b
    db $0c, $0c, $0c, $0c
    db $0d, $0d, $0d, $0d
    db $0e, $0e, $0e, $0e
    db $0f, $0f, $0f, $0f
    db $10, $10, $10, $10
    db $11, $11, $11, $11
    db $12, $12, $12, $12
    db $13, $13, $13, $13
    db $14, $14, $14, $14
    db $15, $15, $15, $15
    db $16, $16, $16, $16
    db $17, $17, $17, $17
    db $18, $18, $18, $18
    db $19, $19, $19, $19
    db $1a, $1a, $1a, $1a
    db $1b, $1b, $1b, $1b
    db $1c, $1c, $1c, $1c
    db $1d, $1d, $1d, $1d
    db $1e, $1e, $1e, $1e
    db $1f, $1f, $1f, $1f
}

oamhighbits: {
    db $02, $08, $20, $80
    db $02, $08, $20, $80
    db $02, $08, $20, $80
    db $02, $08, $20, $80
    db $02, $08, $20, $80
    db $02, $08, $20, $80
    db $02, $08, $20, $80
    db $02, $08, $20, $80
    db $02, $08, $20, $80
    db $02, $08, $20, $80
    db $02, $08, $20, $80
    db $02, $08, $20, $80
    db $02, $08, $20, $80
    db $02, $08, $20, $80
    db $02, $08, $20, $80
    db $02, $08, $20, $80
    db $02, $08, $20, $80
    db $02, $08, $20, $80
    db $02, $08, $20, $80
    db $02, $08, $20, $80
    db $02, $08, $20, $80
    db $02, $08, $20, $80
    db $02, $08, $20, $80
    db $02, $08, $20, $80
    db $02, $08, $20, $80
    db $02, $08, $20, $80
    db $02, $08, $20, $80
    db $02, $08, $20, $80
    db $02, $08, $20, $80
    db $02, $08, $20, $80
    db $02, $08, $20, $80
    db $02, $08, $20, $80
}

incsrc "./data/sprites/spritemaps.asm"
