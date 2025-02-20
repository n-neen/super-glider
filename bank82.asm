lorom

org $828000

;===========================================================================================
;===================================  D E F I N E S  =======================================
;===========================================================================================

;glider ram
!gliderramstart     =       $0200
!gliderx            =       !gliderramstart
!glidery            =       !gliderramstart+2
!gliderstate        =       !gliderramstart+4
!gliderdir          =       !gliderramstart+6
!glidermovetimer    =       !gliderramstart+8
!gliderliftstate    =       !gliderramstart+10

;constants!!!!
!gliderstateidle    =       $0000
!gliderstateleft    =       $0001
!gliderstateright   =       $0002
!floor              =       $00d0


;===========================================================================================
;====================================  M A C R O S  ========================================
;===========================================================================================

!gliderspeed        =       #$0002

macro gliderpositionadd(axis)
    lda <axis>
    clc
    adc !gliderspeed
    sta <axis>
endmacro

macro gliderpositionsub(axis)
    lda <axis>
    sec
    sbc !gliderspeed
    sta <axis>
endmacro


;===========================================================================================
;=================================    G A M E P L A Y    ===================================
;===========================================================================================

db "currently reserved for gameplay"
    
game: {
    .play: {
        jsr get_input
        jsr player_update
        jsr player_handle
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
        lda !controller
        
        ..st: {
            bit !st
            beq ...nost
            ;if start pressed go here
            ...nost:
        }
        
        ..sl: {
            bit !sl
            beq ...nosl
            ;if select pressed go here
            ...nosl:
        }
        
        ..up: {                                 ;dpad start
            bit !up
            beq ...noup
            pha
            %gliderpositionsub(!glidery)
            pla
            ...noup:
        }
        
        ..dn: {
            bit !dn
            beq ...nodn
            pha
            %gliderpositionadd(!glidery)
            pla
            ...nodn:
        }
        
        ..lf: {
            bit !lf
            beq ...nolf
            ldx #!gliderstateleft
            stx !gliderstate
            ldx #$0002
            stx !glidermovetimer
            ...nolf:
        }
        
        ..rt: {
            bit !rt
            beq ...nort
            ldx #!gliderstateright
            stx !gliderstate
            ldx #$0002
            stx !glidermovetimer
            ...nort:
        }                                       ;dpad end
        
        ..a: {
            bit !a
            beq ...noa
            ;if a pressed go here
            ...noa:
        }
        
        ..x: {
            bit !x
            beq ...nox
            ;if pressed go here
            ...nox:
        }
        
        ..b: {
            bit !b
            beq ...nob
            ;if pressed go here
            ...nob:
        }
        
        ..y: {
            bit !y
            beq ...noy
            ;if pressed go here
            ...noy:
        }
        
        ..l: {
            bit !l
            beq ...nol
            stz !glidermovetimer
            ...nol:
        }
        
        ..r: {
            bit !r
            beq ...nor
            stz !glidermovetimer
            ...nor:
        }
        plx
        rts
    }
}

player: {
    .update: {
        ;write to oam table
        ;todo: use spritemaps
        sep #$20
        lda !gliderx
        sta !oamwramtable           ;update glider position
        
        lda !glidery
        sta !oamwramtable+1
        
        lda !oamwramtable+3
        ora #%00110000
        sta !oamwramtable+3
        
        rep #$20
        rts
    }
    
    .handle: {
        lda !gliderliftstate
        beq +
        lda !glidery
        cmp #!floor
        bpl +
        inc !glidery
    +   
    
    
        lda !gliderstate
        asl
        tax
        jsr (.gliderstatetable,x)
        rts
    }
    
    .gliderstatetable: {
        dw #.idle, #.movingleft, #.movingright
    }
    
    ;idle        = 0
    ;movingleft  = 1
    ;movingright = 3
    
    .idle: {
        rts
    }
    
    .movingleft: {
        lda !glidermovetimer
        beq +
        %gliderpositionsub(!gliderx)
        dec !glidermovetimer
        beq ++
    +   rts
    ++  stz !gliderstate
        rts
    }
    
    .movingright: {
        lda !glidermovetimer
        beq +
        %gliderpositionadd(!gliderx)
        dec !glidermovetimer
        beq ++
    +   rts
    ++  stz !gliderstate
        rts
    }
    
}
