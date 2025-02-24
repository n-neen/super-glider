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
        jsr get_input
        jsr glider_update
        jsr glider_handle
        rtl
    }
    
    
    .end: {
        ;todo
        rtl
    }
}

get: {
    .input: {
        phx
        ;use x for general stores here to preserve A without needing to push
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
        
        ..up: {                                 ;dpad start
            bit !kup
            beq ...noup
            ;pha
            ;%gliderpositionsub(!glidery)       ;debug only!
            ;pla
            ...noup:
        }
        
        ..dn: {
            bit !kdn
            beq ...nodn
            ;pha
            ;%gliderpositionadd(!glidery)       ;debug only!
            ;pla
            ...nodn:
        }
        
        ..lf: {
            bit !klf
            beq ...nolf
            ldx !kgliderstateleft
            stx !gliderstate
            ldx #$0002
            stx !glidermovetimer
            ...nolf:
        }
        
        ..rt: {
            bit !krt
            beq ...nort
            ldx !kgliderstateright
            stx !gliderstate
            ldx #$0002
            stx !glidermovetimer
            ...nort:
        }                                       ;dpad end
        
        ..a: {
            bit !ka
            beq ...noa
            stz !gliderliftstate
            ...noa:
        }
        
        ..x: {
            bit !kx
            beq ...nox
            ;if pressed go here
            ;current plan: fire bands
            ...nox:
        }
        
        ..b: {
            bit !kb
            beq ...nob
            ;if pressed go here
            ;current plan: turn glider around
            ;
            ...nob:
        }
        
        ..y: {
            bit !ky
            beq ...noy
            ;if pressed go here
            ;current plan: use battery
            ...noy:
        }
        
        ..l: {
            bit !kl
            beq ...nol
            ldx !kliftstatedown
            stx !gliderliftstate
            ...nol:
        }
        
        ..r: {
            bit !kr
            beq ...nor
            ldx !kliftstateup
            stx !gliderliftstate
            ...nor:
        }
        plx
        rts
    }
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

    .update: {
        ;write to oam table
        ;todo: use spritemaps
        ;this thing is all temp badness
        sep #$20
        
        lda !gliderx
        sta !oamwramtable           ;update glider position
        
        lda !glidery
        sta !oamwramtable+1
        
        lda !oamwramtable+3
        ora #%00110000
        sta !oamwramtable+3
        
        lda !oamwramtable+$200
        ora #%00000010
        sta !oamwramtable+$200
        
        
        rep #$20
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
            bpl ++
            lda !khitboundleft
            sta !gliderhitbound
        ++
            cmp !krightbound        ;hit right bound = 2
            bmi +++
            lda !khitboundright
            sta !gliderhitbound
        +++
        
        }
        
        
        ..state: {
            lda !gliderstate
            asl
            tax
            jsr (glider_handle_state_table,x)
            rts
            
            ...table: {
                ;idle        = 0
                ;movingleft  = 1
                ;movingright = 2
                ;turnaround  = 3
                ;lostlife    = 4
        
                dw #.idle,
                   #.movingleft,
                   #.movingright,
                   #.turnaround,
                   #.lostlife
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
        beq +
        
        lda !glidermovetimer
        beq +
        %gliderpositionsub(!gliderx)
        dec !glidermovetimer
        beq ++
    +   
        rts
    
    ++  stz !gliderstate
        rts
    }
    
    .movingright: {
        lda !gliderhitbound
        cmp !khitboundright     ;right bound = 2
        beq +
        
        lda !glidermovetimer
        beq +
        %gliderpositionadd(!gliderx)
        dec !glidermovetimer
        beq ++
    +   
        rts
    
    ++  stz !gliderstate
        rts
    }
    
    .bounceoffbound: {
        ;todo
        rts
    }
    
    .turnaround: {
        lda !gliderturntimer
        beq +
        lda !kgliderturnamount
        
    +   stz !gliderstate
        rts
    }
    
}
