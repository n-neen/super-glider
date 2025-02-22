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
            pha
            %gliderpositionsub(!glidery)
            pla
            ...noup:
        }
        
        ..dn: {
            bit !kdn
            beq ...nodn
            pha
            %gliderpositionadd(!glidery)
            pla
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
            ldx !kliftstatedown
            stx !gliderliftstate
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
            stz !gliderliftstate
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
    
    .handle: {
        ;high level checks that need to be done regardless of glider state go here
        ;like falling (happens always unless on a vent)
        ;or room bounds (always needs to be checked)
        
        ..falling: {
            lda !gliderliftstate
            beq +
            
            cmp !kliftstateup   ;up=1
            beq ...up
            
            cmp !kliftstatedown ;down=2
            beq ...down
            
            bra +   ;else (should not be reachable!)
            
            ...up:
                dec !glidery
                bra +
            ...down:
                inc !glidery
        +   ;actually now that i think about it, what would lift state 0 even mean
        }
        
    
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
        
            lda !glidery
            cmp !kfloor
            beq ...hitfloor
            bra ++++
            ...hitfloor:
            lda !kgliderstatelostlife
            sta !gliderstate
        }
        ++++
        
        lda !gliderstate
        asl
        tax
        jsr (.gliderstatetable,x)
        rts
    }
    
    .gliderstatetable: {
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
    
    
    .idle: {
        stz !gliderhitbound     ;i cant believe this works
        lda !kliftstatedown
        sta !gliderliftstate
        rts
    }
    
    .lostlife: {
        dec !gliderlives
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
