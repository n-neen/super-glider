lorom

org $828000

;===========================================================================================
;=================================    G A M E P L A Y    ===================================
;===========================================================================================
    
game: {
    .play: {
        stz !batteryactive      ;find a better place to do this
        
        jsl oam_fillbuffer
        jsl getinput
        
        jsl obj_handle
        jsl obj_collision
        
        jsl enemy_top
        
        jsr bands_handle
        
        jsr glider_handle
        jsr glider_draw
        jsr glider_checktrans
        
        jsl obj_collision
        
        jsl coolmode
        
        jsl iframecolormath
        jsl handlecolormath
        
        
        jsl oam_hightablejank
        
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

glider: {

    .init: {
        ;this is laid out like this so we can:
        ;call glider_init on newgame
        ;call glider_init_spawn on death to reset
        
        lda #$0004
        sta !gliderlives
        
        lda !kgliderysubspeeddefault
        sta !gliderysubspeed
        
        lda !kglideryspeeddefault
        sta !glideryspeed
        
        lda !kgliderxsubspeeddefault
        sta !gliderxsubspeed
        
        lda !kgliderxspeeddefault
        sta !gliderxspeed
        
        
        ..spawn: {
            lda #$0095
            sta !gliderx            ;glider initial position
            lda #$0030
            sta !glidery
            
            lda !kliftstatedown
            sta !gliderliftstate
        }
        rtl
    }

    .battery: {
        lda !gliderbatterytime
        beq +
        
        lda !kbatteryon
        sta !batteryactive
        
        ;dec !gliderbatterytime
        bmi ++
        
        rts
        
    ++  stz !gliderbatterytime
    +   stz !batteryactive
        rts
    }
    
    
    .checktrans: {
        ;i guess this also does bounds now, probably want to remove the
        ;original one in glider_handle?
        
        lda !gliderx
        cmp !krightbound-2
        bpl ..right
        
        lda !gliderx
        cmp !kleftbound+2
        bmi ..left
        
        rts
        
        ..right: {
            lda !ktranstimer
            beq .checktrans_ignore
            
            lda !roombounds
            bit #$0001
            bne +
            
            lda !kroomtranstyperight
            sta !roomtranstype
            jsr roomtransitionstart
            rts
            
            +
            lda !khitboundright
            sta !gliderhitbound
            rts
        }
        
        ..left:
            lda !ktranstimer
            beq .checktrans_ignore
            
            lda !roombounds
            bit #$1000
            bne +
            
            lda !kroomtranstypeleft
            sta !roomtranstype
            jsr roomtransitionstart
            rts
            
            +
            lda !khitboundleft
            sta !gliderhitbound
            rts
        }
        
        ..ignore: {
            stz !glidernextstate
            rts
        }
    }
    
    .nodraw: {
        stz !oamentrypoint
        stz !oamentrypointbckp
        rep #$20
        plp
        plb
        plx
        rts
    }
    
    .draw: {
        ;we draw glider then save the starting index for the next objects drawn
        ;saved in !oamentrypoint for the next drawing routine to use
        ;this is the raw index, not number of entries, so /4 to get number of entries
        
        phy
        phx
        phb
        php
        
        phk
        plb
        
        lda !iframecounter             ;traditional iframes
        bit #$0001
        bne +
        
        ldy #$0000
        
        stz !oamhightableindex
        stz !oamentrypoint
        stz !spriteindex
        stz !numberofsprites
        
        lda !gliderdir                ;see glider constants in defines.asm
        
        asl
        tax
        lda spritemap_pointers_glider,x
        tax                             ;x = spritemap pointer
        
        sep #$20
        
        lda $0000,x                     ;number of sprites in spritemap
        sta !numberofsprites
        beq glider_nodraw
        
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
        ;ora !gliderpalette             ;to be used in future, for foil powerup
        sta !oambuffer,y
        iny

        inx #5                          ;x = x + 5 (next sprite entry)
        
        
        inc !spriteindex
        dec !numberofsprites
        bne -
        
        sty !oamentrypoint              ;glider gets drawn first, then the other sprites
        sty !oamentrypointbckp          ;so we need to keep track of oam entry point after each drawing stage
        
    +   rep #$20
        plp
        plb
        plx
        ply
        rts
        
        ..cleartable: {
            stz !oamentrypoint
            jsl oam_cleantable
            rts
        }
    }
    
    
    .gameover: {
        jml boot
    }
    
    .stairslift: {
        phb
        
        phk
        plb
        
        dec !glidertranstimer
        bmi +
        
        lda !gliderstairstype
        asl
        tax
        
        lda !glidery
        clc
        adc .stairslift_table,x
        sta !glidery
        
        lda !gliderstairstype       ;if duct, skip the horizontal
        cmp !kroomtranstypeduct     ;so we go straight down
        beq ++
        
        lda !gliderdir
        asl
        tax
        lda .stairslift_htable,x
        clc
        adc !gliderx
        sta !gliderx
        ++
        
        -
        plb
        rts
        
        +
        stz !gliderstairstimer
        bra -
        
        ..table: {
            ;according to:
            ;!kroomtranstyperight        =       #$0000
            ;!kroomtranstypeleft         =       #$0001
            ;!kroomtranstypeup           =       #$0002
            ;!kroomtranstypedown         =       #$0003
            ;!kroomtranstypeduct         =       #$0004
            dw $0000, $0000, $fffe, $0002, $0001
        }
        
        ..htable: {
               ;right  left
            dw $ffff, $ffff
        }
    }
    
    .handle: {
        ;high level checks that need to be done regardless of glider state go here
        ;like falling (happens always unless on a vent)
        ;or room bounds (always needs to be checked)
        ;or pose update
        ;then go to state handler
        
        lda !iframecounter
        beq ..nodec
        
        dec
        sta !iframecounter
        
        ..nodec:
        
        lda !gliderlives
        beq glider_gameover
        
        jsr glider_turnaround_handletimer
        
        lda !glidertranstimer
        beq +
        dec !glidertranstimer
        +
        
        lda !gliderstairstimer
        beq ++
        jsr glider_stairslift
        ++
        
        
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
                sbc !gliderysubspeed
                sta !glidersuby
                lda !glidery
                sbc !glideryspeed
                sta !glidery
                
                
                bra ..bounds
            ...down:
                lda !glidery
                cmp !kfloor
                bpl ...hitfloor
                ;else, go down:
                
                lda !glidersuby
                clc
                adc !gliderysubspeed
                sta !glidersuby
                lda !glidery
                adc !glideryspeed
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
            bpl ++
            lda !khitboundleft
            sta !gliderhitbound
            bra +++
        ++
            cmp !krightbound        ;hit right bound = 2
            bmi +++
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
        
        lda !kglideriframes
        sta !iframecounter
        
        dec !gliderlives
        stz !glidernextstate
        jsl glider_init_spawn
        rts
    }
    
    .movingleft: {
        lda !gliderhitbound
        cmp !khitboundleft      ;left bound = 1
        beq ++
        
        ;lda !glidermovetimer
        ;beq +
        
        ;the actual moving of left:
        lda !glidersubx
        sec
        sbc !gliderxsubspeed
        sta !glidersubx
        
        lda !gliderx
        sbc !gliderxspeed
        sta !gliderx
        
        lda !batteryactive
        beq +++
        ;if battery being used:
        
        dec !gliderx
        dec !gliderx                ;todo: make this not bad
        dec !gliderx
        dec !gliderbatterytime
        
        +++
        dec !glidermovetimer
        beq ++
    +   
        rts
    
        ;if hit left bound:
    ++  stz !glidernextstate
        stz !gliderstate
        stz !glidermovetimer
        rts
    }
    
    .movingright: {
        lda !gliderhitbound
        cmp !khitboundright     ;right bound = 2
        beq ++
        
        ;lda !glidermovetimer
        ;beq +
        
        ;the actual moving of right:
        lda !glidersubx
        clc
        adc !gliderxsubspeed
        sta !glidersubx
        lda !gliderx
        adc !gliderxspeed
        sta !gliderx
        
        lda !batteryactive
        beq +++
        ;if battery being used:
        
        inc !gliderx
        inc !gliderx                ;todo: make this not bad
        inc !gliderx
        dec !gliderbatterytime
        
        +++
        dec !glidermovetimer
        beq ++
    +   
        rts
    
        ;if hit right bound:
    ++  stz !glidernextstate
        stz !gliderstate
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
        ;sta !glidernextstate
        
        lda !kturnaroundcooldown
        sta !gliderturntimer
        
        +
        ;stz !gliderstate
        ;lda !gliderdir
        ;sta !gliderstate
        ;stz !glidernextstate
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


roomtransitionstart: {
    lda !kstateroomtrans
    sta !gamestate
    rts
}


bands: {
    ;these are the generic rubber band routines
    ;for the movment and logic, etc of an individual
    ;rubber band, see enemy_instruction_band label
    
    .handle: {
        ;identify which enemy slots have bands in them
        ;handle enemy->band collision
        ;movement is handled in the enemy's main routine
        phx
        
        jsr bands_dotimer
        jsr bands_fire
        
        ldx #!enemyarraysize
        -
        lda !enemyID,x
        cmp #enemy_ptr_band
        bne +                   ;if enemy is a rubber band
        jsr bands_calchitbox
        jsr bands_collision     ;do collision checks on all other enemies
        +
        dex : dex
        bpl -
        
        plx
        rts
    }
    
    
    .dotimer: {
        lda !bandtimer
        beq +
        
        dec !bandtimer
        
        +
        rts
    }
    
    
    .fire: {
        phy
        phx
        
        lda !fireband
        beq +
        lda !bandtimer
        bne +
        
        stz !fireband
        
        lda #enemy_ptr_band
        sta !enemydynamicspawnslot
        
        lda !gliderx
        sta !enemydynamicspawnslot+2
        
        lda !glidery
        sta !enemydynamicspawnslot+4
        
        lda !kbandspalette
        sta !enemydynamicspawnslot+6
        
        lda !gliderdir
        xba
        asl #7
        sta !enemydynamicspawnslot+8
        
        ldy #!enemyarraysize
        -
        lda !enemyID,y
        beq ++
        
        dey : dey
        bpl -
        
        
        ++
        ldx #!enemydynamicspawnslot
        jsr enemy_spawn                 ;y = enemy index of open slot
        
    +   plx
        ply
        rts
    }
    
    
    .calchitbox: {
        ;x = enemy id of rubber band
        
        lda !enemyx,x           ;hitbox left edge
        clc
        adc #$ffe0
        sta !hitboxleft
        
        lda !enemyx,x           ;hitbox right edge
        clc
        adc #$0020
        sta !hitboxright
        
        lda !enemyy,x           ;hitbox top edge
        clc
        adc #$ffe0
        sta !hitboxtop
        
        lda !enemyy,x           ;hitbox bottom edge
        clc
        adc #$0018
        sta !hitboxbottom
        
        rts
    }
    
    .collision: {
        ;x = id of band, but we don't need it here, because the
        ;band's hitbox is now in !hitboxleft,right,up,down variables
        ;so we call enemy_collision_check
        ;with x = non-band enemy to check
        ;and hitbox variables set for the band
        phx
        
        ldx #!enemyarraysize
        -
        lda !enemyID,x
        beq +                       ;if enemy slot used
        cmp #enemy_ptr_band         ;and if it is not a band
        beq +
        jsr enemy_collision_check   ;do collision checks
        bcc +
        lda !enemyshotptr,x
        beq +
        jsr (!enemyshotptr,x)       ;if carry set, collision happened
        +                           ;run enemy shot routine
        dex : dex
        bpl -
        
        plx
        rts

    }
    
    
    
    
}


incsrc "./enemies.asm"

incsrc "./data/sprites/spritemaps.asm"

print "bank $82 end: ", pc