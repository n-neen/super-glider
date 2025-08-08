;===========================================================================================
;===================================    E N E M I E S    ===================================
;===========================================================================================

!enemybanklong        =   enemy&$ff0000
!enemybankword        =   !enemybanklong<<8
!enemybankshort       =   !enemybanklong>>16

;====================================== ENEMY ROUTINES =====================================

enemy: {
    .top: {
        jsr enemy_handle
        jsl enemy_drawall
        jsr enemy_collision_calchitbox
        jsr enemy_collision
        
        rtl
    }
    
    
    .collision: {
        phx
        
        lda !iframecounter
        bne ++
        
        ldx #!enemyarraysize
        -
        lda !enemyID,x
        beq +
        jsr enemy_collision_check       ;must preserve x
        bcc +                           ;carry clear = no collision
        jsr (!enemytouchptr,x)
        +
        dex : dex
        bpl -
        
        ++
        plx
        rts
        
        ..calchitbox: {
            ;!hitboxleft   ;glider x position - hitbox size
            ;!hitboxright  ;glider x position + hitbox size
            ;!hitboxtop    ;glider y position - hitbox size
            ;!hitboxbottom ;glider y position + hitbox size
            
            lda !gliderx            ;hitbox left edge
            clc
            adc !kgliderleftbound-!kgliderenemybox
            sta !hitboxleft
            
            lda !gliderx            ;hitbox right edge
            clc
            adc !kgliderrightbound+!kgliderenemybox
            sta !hitboxright
            
            lda !glidery            ;hitbox top edge
            clc
            adc !kgliderupbound-!kgliderenemybox
            sta !hitboxtop
            
            lda !glidery            ;hitbox bottom edge
            clc
            adc !kgliderdownbound+!kgliderenemybox
            sta !hitboxbottom
            
            rts
        }
        
        
        ..check: {
            ;x = enemy index
            ;x must be preserved for the outer loop
            ;enemyx and y are radii
            
            
            lda !enemyx,x           ;right bound: xpos+xsize
            clc
            adc !enemyxsize,x
            cmp !hitboxright
            bmi ++
            
            lda !enemyx,x           ;left bound: xpos-xsize
            sec
            sbc !enemyxsize,x
            cmp !hitboxleft
            bpl ++
            
            lda !enemyy,x           ;up bound: ypos-ysize
            sec
            sbc !enemyysize,x
            cmp !hitboxtop
            bpl ++
            
            lda !enemyy,x           ;down bound: ypos+ysize
            clc
            adc !enemyysize,x
            cmp !hitboxbottom
            bmi ++
            
            
            +
            sec     ;collision
            rts
            
            ++
            clc     ;no collision
            rts
        }
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
    
    
    .dynamicspawn: {
        
        
        
        rtl
    }
    
    
    .spawn: {
        ;spawn single enemy from enemy population
        ;write to enemy ram
        ;x = room's enemy list pointer
        ;y = enemy index
        
        phb
        phx
        
        phk
        plb     ;db = $82
        
        ;enemy data that's per instance
        ;comes from room's enemy list
        
        lda.l !roombanklong,x
        cmp #$ffff          ;if enemy type = ffff, exit this entire process (up a level)
        beq ..stop
        sta !enemyID,y
        
        lda.l !roombanklong+2,x
        sta !enemyx,y
        
        lda.l !roombanklong+4,x
        sta !enemyy,y
        
        lda.l !roombanklong+6,x
        sta !enemypal,y
        
        lda.l !roombanklong+8,x
        sta !enemyproperty,y
        
        ;enemy data that is based on its definition
        ;enemyID is a pointer to its header
        ;db = $82
        
        lda !enemyID,y
        tax
        lda.l !enemybanklong,x
        tax
        
        lda $0000,x
        sta !enemyspritemapptr,y
        
        lda $0002,x
        sta !enemyxsize,y
        
        lda $0004,x
        sta !enemyysize,y
        
        lda $0006,x
        sta !enemyinitptr,y
        
        lda $0008,x
        sta !enemymainptr,y
        
        lda $000a,x
        sta !enemytouchptr,y
        
        lda $000c,x
        sta !enemyshotptr,y
        
        +
        plx
        plb
        rts
        
        ..stop: {
            plx
            plb
            pla
            jmp enemy_spawnall_out
        }
    }
    
    
    .spawnall: {
        phb
        phx
        phy
        
        ldx !roomptr
        lda.l !roombanklong+2,x
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
        bpl -
        
        plx
        rts
    }
    
    
    .drawall: {
        phx
        phy
        
        ldx #!enemyarraysize
        -
        lda !enemyx,x
        cmp #$0100
        bpl +
        
        lda !enemyy,x
        cmp #$0100
        bpl +
        
        jsr enemy_draw
        +
        dex : dex
        bpl -
        
        ply
        plx
        rtl
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
        sta !oambuffer,x                ;x
        
        lda $0001,y
        clc
        adc !localenemyy
        sta !oambuffer+1,x              ;y
        
        lda $0002,y
        sta !oambuffer+2,x              ;tile
        
        lda $0003,y
        ora !localenemypal
        sta !oambuffer+3,x              ;properties
        
        ..nextsprite:
            ;x=x+4
            ;y=y+5
            
            inx #4
            iny #5
            
            dec !numberofsprites
            bne enemy_draw_loop
        
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
        stz !enemyshotptr,x
        stz !enemytimer,x

        rts
    }
    
    
    .instruction: {
        ..balloon: {
            ...moveup: {
                ;x = enemy index
                
                !speed      =   !localtempvar
                !subspeed   =   !localtempvar2
                
                lda !enemyproperty,x        ;top nibble = left of decimal
                and #$f000
                xba
                lsr #4
                sta !speed
                
                lda !enemyproperty,x        ;bottom 3 nibbles = right of decimal
                and #$0fff
                asl #4
                sta !subspeed
                
                ;enemy y - s.bbb0
                
                lda !enemysuby,x
                sec
                sbc !subspeed
                sta !enemysuby,x
                
                lda !enemyy,x
                sbc !speed
                sta !enemyy,x
                
                rts
            }
            
            ...checkheight: {
                ;x = enemy index
                
                lda !enemyy,x
                cmp !kceiling-5
                bmi +
                rts
                +
                lda !kfloor+32
                sta !enemyy,x
                
                lda !enemypal,x
                and #$ff00
                xba
                sta !enemytimer,x
                
                lda #enemy_instruction_balloon_wait
                sta !enemymainptr,x
                
                rts
            }
            
            ...wait: {
                dec !enemytimer,x
                bpl +
                
                lda #enemy_main_balloon
                sta !enemymainptr,x
                
            +   rts
            }
        }
        
        ..band: {
            ...move: {
                ;called from enemy's main routine
                ;in enemies.asm
                ;for moving a single instance of rubber band
                ;x = enemy index
                
                ....left: {
                    lda !enemysubx,x
                    sec
                    sbc !kbandxsubspeed
                    sta !enemysubx,x
                    
                    lda !enemyx,x
                    sbc !kbandxspeed
                    sta !enemyx,x
                    rts
                }
                
                ....right: {
                    lda !enemysubx,x
                    clc
                    adc !kbandxsubspeed
                    sta !enemysubx,x
                    
                    lda !enemyx,x
                    adc !kbandxspeed
                    sta !enemyx,x
                    rts
                }
            }
            
            
            ...checkbounds: {
                lda !enemyx,x
                cmp !kleftbound-5
                bmi +
                
                lda !enemyx,x
                cmp !krightbound+5
                bpl +
                
                lda !enemyy,x
                cmp !kceiling-5
                bmi +
                
                lda !enemyy,x
                cmp !kfloor+5
                bpl +
                
                rts
                
                +
                jsr enemy_clear
                rts
            }
            
            ...drop: {
                lda !enemysuby,x
                clc
                adc !kbandysubspeed
                sta !enemysuby,x
                
                lda !enemyy,x
                adc !kbandyspeed
                sta !enemyy,x
                
                
                rts
            }
            
            
            ...animate: {
                phx
                phb
                
                phk
                plb
                
                lda !framecounter
                bit #$0002
                bne +
                
                lda !enemyx,x
                and #$0002
                
                tay
                lda enemy_instruction_band_animate_table,y
                sta !enemyspritemapptr,x
                
            +   plb
                plx
                rts
                
                ....table: {
                    dw spritemap_pointers_band,
                       spritemap_pointers_band+2,
                       spritemap_pointers_band+4
                }
            }
        }
    }
    
    ;====================================== ENEMY DEFINITIONS =====================================
    
    .ptr: {
        ..balloon:      dw enemy_headers_balloon
        ..paper:        dw enemy_headers_paper
        ..clock:        dw enemy_headers_clock
        ..battery:      dw enemy_headers_battery
        ..bandspack:    dw enemy_headers_bandspack
        ..dart:         dw enemy_headers_dart
        ..duct:         dw enemy_headers_duct
        ..band:         dw enemy_headers_band
    }
    
    
    .headers: {
               ;spritemap ptr                   xsize,      ysize,      init routine,               main routine,           touch,                      shot
        ..balloon:
            dw spritemap_pointers_balloon,      $0030,      $0028,      enemy_init_none,            enemy_main_balloon,     enemy_touch_kill,           enemy_shot_balloon
        ..paper:
            dw spritemap_pointers_paper,        $0048,      $0028,      enemy_init_none,            enemy_main_none,        enemy_touch_paper,          $0000
        ..clock:
            dw spritemap_pointers_clock,        $0040,      $0020,      enemy_init_none,            enemy_main_none,        enemy_touch_clock,          $0000
        ..battery:
            dw spritemap_pointers_battery,      $0040,      $0028,      enemy_init_none,            enemy_main_none,        enemy_touch_battery,        $0000
        ..bandspack:
            dw spritemap_pointers_bandspack,    $0030,      $0030,      enemy_init_none,            enemy_main_none,        enemy_touch_bandspack,      $0000
        ..dart:
            dw spritemap_pointers_dart,         $0040,      $0020,      enemy_init_dart,            enemy_main_dart,        enemy_touch_kill,           enemy_shot_dart
        ..duct:
            dw spritemap_pointers_duct,         $0030,      $0028,      enemy_init_duct,            enemy_main_none,        enemy_touch_duct,           $0000
        ..band:
            dw spritemap_pointers_band,         $0020,      $0020,      enemy_init_band,            enemy_main_band,        enemy_touch_none,           $0000
            
    }
    
    
    .init: {
        ..none: {
            rts
        }
        
        ..band: {
            ;use glider direction to determine band direction
            ;at the time it is spawned
            ;uhh actually this won't run because it's not during room load
            rts
        }
        
        ..duct: {
            ;the enemy palette bitmask needs to be renamed
            ;the top byte isn't used by the spritemap loading routine at all,
            ;so can be used for any purpose
            ;here we only use the top bit
            
            lda !enemypal,x
            bmi +
            ;if not $8000 bit, it's a floor duct
            lda #spritemap_pointers_duct+0
            sta !enemyspritemapptr,x
            rts
            
            +
            ;if $8000 bit, it's a ceiling duct
            lda #spritemap_pointers_duct+2
            sta !enemyspritemapptr,x
            
            rts
        }
        
        ..dart: {
            lda !enemyproperty,x
            bmi +
            ; if not $8000 bit, it's a left dart
            lda #spritemap_pointers_dart+0
            sta !enemyspritemapptr,x
            
            rts
            
            +
            ;if $8000 bit, it's a right dart
            lda #spritemap_pointers_dart+2
            sta !enemyspritemapptr,x
            
            rts
        }
    }
    
    
    .shot: {
        ..balloon: {
            ;todo: change spritemap to punctured balloon
            ;set ai to fall to ground
            jsr enemy_clear
            rts
        }
        
        ..dart: {
            ;todo: change spritemap to crumpled dart
            ;set ai to fall to ground
            jsr enemy_clear
            rts
        }
    }
    
    
    .main: {
        ..balloon: {
            jsr enemy_instruction_balloon_moveup
            jsr enemy_instruction_balloon_checkheight
            rts
        }
        
        ..band: {
            jsr enemy_instruction_band_checkbounds
            jsr enemy_instruction_band_drop
            jsr enemy_instruction_band_animate
            
            
            lda !enemyproperty,x
            bpl +
            
            ;$8000 bit = left band
            lda !kbandxspeed
            jsr enemy_instruction_band_move_left
            rts
            
            ;no $8000 bit = right band
            +
            lda !kbandxspeed
            jsr enemy_instruction_band_move_right
            rts
        }
        
        ..none: {
            rts
        }
        
        ..dart: {
            lda !enemyproperty,x
            bmi +
            
            ;left dart
            
            lda !enemyx,x
            dec : dec
            and #$00ff
            sta !enemyx,x
            
            ;lda !kdartsubspeed         ;do somethin like that eventually
            ;jsr enemy_inst_moveleft
            
            rts
            
            ;right dart
            +
            
            lda !enemyx,x
            inc : inc
            and #$00ff
            sta !enemyx,x
            
            ;lda !kdartsubspeed
            ;jsr enemy_inst_moveright
            
            rts
        }
    }
    
    
    .touch: {
        ..none: {
            rts
        }
        
        ..kill: {
            lda !kgliderstatelostlife
            sta !glidernextstate
            rts
        }
        
        ..duct: {
            lda !enemyproperty,x        ;low byte = room index to go to
            and #$00ff
            asl
            sta !roomindex
            
            lda !enemyproperty,x        ;high byte = x output position
            and #$ff00                  ;(y will always be near ceiling)
            xba
            sta !ductoutputxpos
            
            lda !kroomtranstypeduct
            sta !roomtranstype
            
            lda !kstateroomtrans
            sta !gamestate
            rts
        }
        
        ..clock: {
            lda !enemyproperty,x
            clc
            adc !points
            sta !points
            jsr enemy_clear
            rts
        }
        
        ..paper: {
            sed
            lda !gliderlives
            clc
            adc #$0001
            sta !gliderlives
            cld
            
            jsr enemy_clear
            rts
        }
        
        
        ..battery: {
            lda !enemyproperty,x
            clc
            adc !gliderbatterytime
            sta !gliderbatterytime
            
            jsr enemy_clear
            rts
        }
        
        ..bandspack: {
            lda !bandsammo
            clc
            adc !kbandammoamount
            sta !bandsammo
            
            jsr enemy_clear
            rts
        }
    }
}