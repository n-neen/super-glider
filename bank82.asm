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
        rtl
    }
    
    
    .end: {
        ;todo
        rtl
    }
}

get: {
    .input: {
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
            bit !up                             ;1 = up, 2 = down, 4 = left, 8 = right
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
            pha
            %gliderpositionsub(!gliderx)
            pla
            ...nolf:
        }
        
        ..rt: {
            bit !rt
            beq ...nort
            pha
            %gliderpositionadd(!gliderx)
            pla
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
            ;go here if l pressed
            ...nol:
        }
        
        ..r: {
            bit !r
            beq ...nor
            ;if pressed go here
            ...nor:
        }
        rts
    }
}

player: {
    .update: {
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
    
    .move: {
        ;currently unimplemented (see above for what we do right now)
        
        bit #$0001
        beq ..noup
        %gliderpositionsub(!glidery)
        ..noup:
        
        bit #$0002
        beq ..nodown
        %gliderpositionadd(!glidery)
        ..nodown:
        
        bit #$0004
        beq ..noleft
        %gliderpositionsub(!gliderx)
        ..noleft:
        
        bit #$0008
        beq ..noright
        %gliderpositionadd(!gliderx)
        ..noright:
        rts
    }
}
