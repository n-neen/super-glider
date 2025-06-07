lorom

org $828000

;===========================================================================================
;===================================  D E F I N E S  =======================================
;===========================================================================================

;moved to defines.asm


;===========================================================================================
;====================================  M A C R O S  ========================================
;===========================================================================================

;local constant
!kgliderspeed        =       #$0002

macro gliderpositionadd(axis)
    lda <axis>
    clc
    adc !kgliderspeed
    sta <axis>
endmacro

macro gliderpositionsub(axis)
    lda <axis>
    sec
    sbc !kgliderspeed
    sta <axis>
endmacro


;===========================================================================================
;=================================    G A M E P L A Y    ===================================
;===========================================================================================

    
game: {
    .play: {
        jsr getinput
        jsr glider_handle
        jsr glider_draw
        rtl
    }
    
    
    .end: {
        ;todo
        rtl
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
            ;if start pressed go here
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
            
            ldx !kgliderdirleft
            stx !gliderdir
        
            ldx #$0002
            stx !glidermovetimer
        ..nolf:
    }
    
    .rt: {
        bit !krt
        beq ..nort
        
            ldx !kgliderstateright
            stx !glidernextstate
            
            ldx !kgliderdirright
            stx !gliderdir
        
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
            ;current plan: turn glider around
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
    rts
}

glider: {

    .init: {
        ;this is laid out like this so we can:
        ;call glider_init on newgame
        ;call glider_init_spawn on death to reset
        
        lda #$0004
        sta !gliderlives
        
        ..spawn: {
            lda #$0010
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
        %oambufferwrite(0,2)
        
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
    
    .newdraw: {
        ;todo: read from spritemaps_glider in spritemaps.asm
        phx
        phb
        
        phk
        plb
        
        
        lda !gliderdir                  ;uses same left = 1, right = 2 convention
        asl
        tax
        lda spritemap_pointers,x
        
        sta !spritemappointer           ;!spritemappointer = pointer to spritemap
        lda (!spritemappointer)         ;number of sprites to write
        and #$00ff
        sta !numberofsprites
        
        
        ldx #$0000                      ;x = 0
        ;x should eventually be set to an oam index value here
        inc !spritemappointer
        
        ;low table loop:
        -
        lda (!spritemappointer)
        sta !oambuffer,x
        inx : inx                       ;x = 2
        inc !spritemappointer
        inc !spritemappointer
        lda (!spritemappointer)
        sta !oambuffer,x
        
        dec !numberofsprites
        bpl -
        
        
        ;todo: the rest of this. time to sleep
        
        plb
        plx
        rts
    }
    
    .gameover: {
        jml boot
    }
    
    .handle: {
        ;high level checks that need to be done regardless of glider state go here
        ;like falling (happens always unless on a vent)
        ;or room bounds (always needs to be checked)
        ;then go to state handler
        
        lda !gliderlives
        beq glider_gameover
        
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
                dec !glidery        ;else, go up like normal
                bra ..bounds
            ...down:
                lda !glidery
                cmp !kfloor
                bpl ...hitfloor
                inc !glidery
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
        stz !gliderstate
        jsl glider_init_spawn
        rts
    }
    
    .movingleft: {
        lda !gliderhitbound
        cmp !khitboundleft      ;left bound = 1
        beq ++
        
        lda !glidermovetimer
        beq +
        %gliderpositionsub(!gliderx)
        
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
        %gliderpositionadd(!gliderx)
        
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
        lda !gliderdir
        eor #$0001
        sta !gliderdir
        rts
    }
    
}

incsrc "./data/sprites/spritemaps.asm"

;warn pc