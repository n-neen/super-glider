lorom

org $828000

;===========================================================================================
;=================================    G A M E P L A Y    ===================================
;===========================================================================================
    
game: {
    .play: {
        jsl getinput
        
        jsl obj_collision
        jsl obj_handle
        
        jsr glider_handle
        jsr glider_checktrans
        jsr glider_draw
        
        jsl enemy_top
        
        jsl oam_hightablejank
        ;jsl oam_cleantable
        
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
            lda #$0095
            sta !gliderx            ;glider initial position
            lda #$0030
            sta !glidery
            lda !kliftstatedown
            sta !gliderliftstate
        }
        rtl
    }

    .olddraw: {
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
        
        phx
        phb
        php
        
        phk
        plb
        
        jsr ..cleartable
        
        ldy #$0000
        
        stz !oamhightableindex
        ;stz !oamentrypoint
        stz !spriteindex
        
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
        
        ..cleartable: {
            stz !oamentrypoint
            jsl oam_fillbuffer
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
        
        lda !gliderdir
        asl
        tax
        lda .stairslift_htable,x
        clc
        adc !gliderx
        sta !gliderx
        
        
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
            dw $0000, $0000, $fffe, $0002
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
        
        ;lda !glidermovetimer
        ;beq +
        
        ;the actual moving of left:
        lda !glidersubx
        sec
        sbc !kgliderxsubspeed
        sta !glidersubx
        
        lda !gliderx
        sbc #$0001
        sta !gliderx
        
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
        adc !kgliderxsubspeed
        sta !glidersubx
        lda !gliderx
        adc #$0001
        sta !gliderx
        
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


;===========================================================================================
;===================================    E N E M I E S    ===================================
;===========================================================================================


;====================================== ENEMY ROUTINES =====================================

enemy: {
    .top: {
        jsr enemy_handle
        jsr enemy_drawall
        jsr enemy_collision
        
        rtl
    }
    
    
    .runinit: {
        phx
        
        ldx #!enemyarraysize
        -
        lda !enemyinitptr,x
        beq +
        phx
        jsr (!enemyinitptr,x)
        plx
        +
        dex : dex
        bpl -
        
        plx
        rtl
    }
    
    
    .spawn: {
        ;spawn single enemy from enemy population
        ;write to enemy ram
        ;x = room's enemy list pointer
        ;y = enemy index
        
        phb
        phx
        phy     ;no point in this is there? uhhhhhh
                ;oh, the outer loop will need to retain enemy index (in spawnall)
        
        phk
        plb
        
        ;enemy data that's per instance
        ;comes from room's enemy list
        
        lda $830000,x
        cmp #$ffff          ;if enemy type = ffff, exit
        beq +
        sta !enemyID,y
        
        lda $830002,x
        sta !enemyx,y
        
        lda $830004,x
        sta !enemyy,y
        
        lda $830006,x
        sta !enemypal,y
        
        lda $830008,x
        sta !enemyproperty,y
        
        ;enemy data that is based on its definition
        ;enemyID is a pointer to its header
        
        lda !enemyID,y
        tax
        
        lda $0000,x
        sta !enemyspritemapptr,y
        
        lda $0002,x
        sta !enemyxsize,y
        
        lda $0004,x
        sta !enemyysize,y
        
        lda $0006,x                 ;this shit is broke
        sta !enemyinitptr,y
        
        lda $0008,x
        sta !enemymainptr,y
        
        lda $000a,x
        sta !enemytouchptr,y
        
        +
        ply
        plx
        plb
        rts
    }
    
    
    .spawnall: {
        phb
        phx
        phy
        
        ;pea $8383
        ;plb : plb
        
        ldx !roomptr
        lda $830002,x
        tax
        
        ldy #!enemyarraysize+2
        -
        dey : dey
        bmi ..out                       ;if y goes negative we are out of slots
        jsr enemy_spawn
        
        txa
        clc
        adc #$000a                      ;advance to next enemy entry: x = x + 10
        tax
        
        jmp -
        
        ..out:
        ply
        plx
        plb
        rtl
    }
    
    
    .handle: {
        phx
        
        ldx #!enemyarraysize
        -
        lda !enemymainptr,x
        beq +
        phx
        jsr (!enemymainptr,x)
        plx
        +
        dex : dex
        bne -
        
        plx
        rts
    }
    
    
    .drawall: {
        phx
        phy
        
        ldx #!enemyarraysize
        -
        jsr enemy_draw
        +
        dex : dex
        bpl -
        
        ply
        plx
        rts
    }
    
    
    .draw: {
        ;x = enemy index
        !numberofsprites    =   !localtempvar
        !localenemyx        =   !localtempvar2
        !localenemyy        =   !localtempvar3
        !localenemypal      =   !localtempvar4
        
        phb
        phy
        
        phk         ;db = $82
        plb
        
        stz !numberofsprites
        
        lda !enemyID,x
        beq +
        lda !enemyspritemapptr,x
        beq +
        tay
        
        ;this is actually going to always render the first spritemap
        ;in the list unless the enemy does a
        ;lda !enemyspritemapptr,x
        ;inc : inc
        ;sta !enemyspritemapptr,x
        ;to advance animation frames
        ;maybe this is fine?
        ;we'd need to set initial spritemap list index in enemy init i guess
        ;if you don't want to use the first one first
        ;so maybe put the first one first?
        ;ok buddy
        
        ;back these up because we need x and y for the oam table write
        lda !enemyx,x
        sta !localenemyx
        
        lda !enemyy,x
        sta !localenemyy
        
        lda !enemypal,x
        sta !localenemypal
        
        ;grab number of sprites
        lda $0000,y
        tay
        lda $0000,y
        tay
        
        sep #$20
        lda $0000,y
        sta !numberofsprites
        beq +                       ;if no sprites to draw, exit
        iny
        
        phx
        ldx !oamentrypoint
        
        ;write oam table
        ;y now lines up with spritemap bytes
        ;y=spritemap pointer
        ;x=oam buffer index
        
        ..loop:
        
        lda $0000,y
        clc
        adc !localenemyx
        sta !oambuffer,x
        
        lda $0001,y
        clc
        adc !localenemyy
        sta !oambuffer+1,x
        
        lda $0002,y
        sta !oambuffer+2,x
        
        lda $0003,y
        ora !localenemypal
        sta !oambuffer+3,x
        
        ..nextsprite:
            ;x=x+4
            ;y=y+5
            
            inx #4
            iny #5
            
            dec !numberofsprites
            bpl enemy_draw_loop
        
        stx !oamentrypoint
        plx
        +
        rep #$20
        ply
        plb
        rts
    }
    
    
    .clearall: {
        ldx #!enemyarraysize
        
        -
        jsr enemy_clear
        dex : dex
        bpl -
        
        rtl
    }
    
    
    .clear: {
        ;x = enemy index
        
        stz !enemyID,x
        stz !enemyx,x
        stz !enemyy,x
        stz !enemysubx,x
        stz !enemysuby,x
        stz !enemyinitptr,x
        stz !enemymainptr,x
        stz !enemytouchptr,x
        stz !enemyproperty,x
        stz !enemypal,x
        stz !enemyspritemapptr,x
        stz !enemyxsize,x
        stz !enemyysize,x

        rts
    }
    
    
    .collision: {
        ;read from xsize and ysize below in enemy_headers
        ;determine if hit occured
        rts
    }
    
    ;====================================== ENEMY DEFINITIONS =====================================
    
    .ptr: {
        ..balloon: dw enemy_headers_balloon
    }
    
    
    .headers: {
        ..balloon: {
            ;spritemap ptr                      xsize,      ysize,      init routine,               main routine,           touch
            dw spritemap_pointers_balloon,      $0008,      $0008,      enemy_init_balloon,         enemy_main_balloon,     enemy_touch_kill
        }
    }
    
    
    .init: {
        ..balloon: {
            dec !enemyy,x
            rts
        }
    }
    
    
    .main: {
        ..balloon: {
            ;brk #$00
            rts
        }
    }
    
    
    .touch: {
        ..kill: {
            ;kill glider
            rts
        }
        
        ..points: {
            ;for clock sprites:
            ;give points, delete sprite
            rts
        }
        
        ..battery: {
            ;for battery sprite:
            ;add to battery ammo, delete sprite
            rts
        }
        
        ..bands: {
            ;for rubber band ammo sprite:
            ;add to band ammo, delete sprite
            rts
        }
    }
}

incsrc "./data/sprites/spritemaps.asm"

print "bank $82 end: ", pc