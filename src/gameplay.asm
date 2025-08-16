;===========================================================================================
;=================================    G A M E P L A Y    ===================================
;===========================================================================================

!gamebanklong        =   game&$ff0000
!gamebankword        =   !gamebanklong>>8
!gamebankshort       =   !gamebanklong>>16


game: {
    .play: {
        stz !batteryactive      ;find a better place to do this
        inc !roomcounter
        
        jsl oam_fillbuffer
        jsl oam_hightablejank
        jsl getinput
        
        jsl obj_handle
        jsl obj_collision
        
        jsl enemy_top
        
        jsr bands_handle
        
        jsr glider_handle
        jsl glider_draw
        jsr glider_checktrans
        
        jsl obj_collision
        
        ;jsl coolmode
        
        jsl iframecolormath
        jsl handlecolormath
        
        jsr handlehud
        

        
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



handlehud: {
    jsl hud_updatelives
    jsl hud_handleicons
    rts
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
            stz !coolmode
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
            pha
            
            lda !fireband
            bne +
            
            ldx #$0001
            stx !fireband
            
            ldx !kbandtimerlength
            stx !bandtimer
            
            +
            pla
        ..nox:
    }
    
    .b: {
        bit !kb
        beq ..nob
            ;if pressed go here
            ;ldx !kgliderstateturnaround
            ;stx !glidernextstate
            pha
            jsr glider_turnaround
            pla
        ..nob:
    }
    
    .y: {
        bit !ky
        beq ..noy
            pha
            jsr glider_battery
            pla
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