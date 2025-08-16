;===========================================================================================
;===================================    E N E M I E S    ===================================
;===========================================================================================

!enemybanklong        =   enemy&$ff0000
!enemybankword        =   !enemybanklong>>8
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
        lda !enemytouchptr,x
        beq +
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
        sta !enemyproperty,y
        
        lda.l !roombanklong+8,x
        sta !enemyproperty2,y
        
        lda.l !roombanklong+10,x
        sta !enemyproperty3,y
        
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
        adc !kenemyentrylength          ;advance to next enemy entry: x = x + 10
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
        !localenemyproperty2      =   !localtempvar4
        
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
        
        lda !enemyproperty2,x
        sta !localenemyproperty2
        
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
        ora !localenemyproperty2
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
        stz !enemyproperty2,x
        stz !enemyspritemapptr,x
        stz !enemyxsize,x
        stz !enemyysize,x
        stz !enemyshotptr,x
        stz !enemytimer,x
        stz !enemyvariable,x
        stz !enemyproperty3,x

        rts
    }
    
;===========================================================================================
;=====================================    E N E M Y    =====================================
;================================== I N S T R U C T I O N S ================================
;===========================================================================================
    
    .instruction: {
        ..off: {
            ;do something like wait to be reactivated
            rts
        }
        
        ;=====================================  DRIP  ======================================
        
        ..drip: {
            ...wait: {
                lda !enemytimer,x
                beq +
                dec !enemytimer,x
                rts
                
                +
                lda #enemy_instruction_drip_prepare
                sta !enemymainptr,x
                rts
            }
            
            ...prepare: {
                lda !roomcounter
                inc                             ;lol
                bit #$0002
                beq ++
                
                
                and #$000c
                lsr
                beq +
                clc
                adc #spritemap_pointers_drip
                sta !enemyspritemapptr,x
                
                ++
                rts
                
                +
                
                lda #spritemap_pointers_drip
                sta !enemyspritemapptr,x
                
                lda #enemy_instruction_drip_drop
                sta !enemymainptr,x
                rts
            }
            
            ...drop: {
                phy
                
                lda #enemy_instruction_drip_wait
                sta !enemymainptr,x
                
                lda !enemyproperty,x
                sta !enemytimer,x
                
                lda #enemy_ptr_drop
                sta !enemydynamicspawnslot
                
                lda !enemyx,x
                sta !enemydynamicspawnslot+2
                
                lda !enemyy,x
                sta !enemydynamicspawnslot+4
                
                lda #$0002
                sta !enemydynamicspawnslot+8
                
                ldy #!enemyarraysize
                -
                lda !enemyID,y
                beq +
                
                dey : dey
                bpl -
                bmi ++
                
                +
                
                ldx #!enemydynamicspawnslot
                jsr enemy_spawn
                
                ++
                ply
                rts
            }
        }
        
        ;===================================  BALLOON  =====================================
        
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
            
            ...falling: {
                lda !enemyy,x
                inc
                sta !enemyy,x
                cmp !kfloor+32
                bpl +
                
                rts
                
                +
                
                lda !enemyproperty2,x
                and #$ff00
                xba
                sta !enemytimer,x
                
                lda #enemy_instruction_balloon_wait
                sta !enemymainptr,x
                
                lda #spritemap_pointers_balloon+0
                sta !enemyspritemapptr,x
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
                
                lda !enemyproperty2,x
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
                
                lda #enemy_instruction_balloon_moveup
                sta !enemymainptr,x
                
            +   rts
            }
        }
        
        ;=====================================  BAND  ======================================
        
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
    
    
    .shutoff: {
        ;x = enemy index
        
        ;lda #enemy_instruction_off
        stz !enemyinitptr,x
        stz !enemymainptr,x
        stz !enemytouchptr,x
        stz !enemyshotptr,x
        
        rts
    }
    
;===========================================================================================
;===========================================================================================
;===========================================================================================
;=====================================    E N E M Y    =====================================
;==================================  D E F I N I T I O N S  ================================
;===========================================================================================
;===========================================================================================
;===========================================================================================
    
    .ptr: {
        ..balloon:      dw enemy_headers_balloon
        ..paper:        dw enemy_headers_paper
        ..clock:        dw enemy_headers_clock
        ..battery:      dw enemy_headers_battery
        ..bandspack:    dw enemy_headers_bandspack
        ..dart:         dw enemy_headers_dart
        ..duct:         dw enemy_headers_duct
        ..band:         dw enemy_headers_band
        ..lightswitch:  dw enemy_headers_lightswitch
        ..switch:       dw enemy_headers_switch
        ..drip:         dw enemy_headers_drip
        ..drop:         dw enemy_headers_drop
        ;todo: drip
        ;todo: basketball
        ;todo: foil
        ;todo: toaster
    }
    
    
    .headers: {
               ;spritemap ptr                   xsize,      ysize,      init routine,       main routine,               touch,                      shot
        ..balloon:
            dw spritemap_pointers_balloon,      $0030,      $0028,      $0000,              enemy_main_balloon,         enemy_touch_kill,           enemy_shot_balloon
        ..paper:
            dw spritemap_pointers_paper,        $0048,      $0028,      enemy_init_prize,   $0000,                      enemy_touch_paper,          $0000
        ..clock:
            dw spritemap_pointers_clock,        $0040,      $0020,      enemy_init_prize,   $0000,                      enemy_touch_clock,          $0000
        ..battery:
            dw spritemap_pointers_battery,      $0040,      $0028,      enemy_init_prize,   $0000,                      enemy_touch_battery,        $0000
        ..bandspack:
            dw spritemap_pointers_bandspack,    $0030,      $0030,      enemy_init_prize,   $0000,                      enemy_touch_bandspack,      $0000
        ..dart:
            dw spritemap_pointers_dart,         $0040,      $0020,      enemy_init_dart,    enemy_main_dart,            enemy_touch_kill,           enemy_shot_dart
        ..duct:
            dw spritemap_pointers_duct,         $0030,      $0028,      enemy_init_duct,    $0000,                      enemy_touch_duct,           $0000
        ..band:
            dw spritemap_pointers_band,         $0020,      $0020,      $0000,              enemy_main_band,            $0000,                      $0000
        ..lightswitch:
            dw spritemap_pointers_lightswitch,  $0030,      $0020,      $0000,              enemy_main_switchcommon,    enemy_touch_lightswitch,    enemy_touch_lightswitch
        ..switch:
            dw spritemap_pointers_switch,       $0030,      $0020,      $0000,              enemy_main_switch,          enemy_touch_switch,         enemy_touch_switch
        ..drip:
            dw spritemap_pointers_drip,         $0018,      $0018,      enemy_init_drip,    enemy_main_drip,            enemy_touch_drip,           $0000
        ..drop:
            dw spritemap_pointers_drip+8,       $0028,      $0020,      $0000,              enemy_main_drop,            enemy_touch_drip,           $0000
            
    }


;===========================================================================================
;=====================================    E N E M Y    =====================================
;====================================      I N I T      ====================================
;===================================   R O U T I N E S   ===================================
;===========================================================================================
    
    .init: {
        ..drip: {
            lda !enemyproperty,x
            sta !enemytimer,x
            rts
        }
        
        ..band: {
            ;use glider direction to determine band direction
            ;at the time it is spawned
            ;uhh actually this won't run because it's not during room load
            rts
        }
        
        ..prize: {
            lda !enemyproperty3,x
            jsl itembit_check
            bcc +
            
            jsr enemy_clear
            
        +   rts
        }
        
        ..duct: {
            ;the enemy palette bitmask needs to be renamed
            ;the top byte isn't used by the spritemap loading routine at all,
            ;so can be used for any purpose
            ;here we only use the top bit
            
            lda !enemyproperty2,x
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
    
;===========================================================================================
;=====================================    E N E M Y    =====================================
;====================================      S H O T      ====================================
;===================================   R O U T I N E S   ===================================
;===========================================================================================
    
    .shot: {
        
        ..balloon: {
            ;todo: change spritemap to punctured balloon
            ;set ai to fall to ground
            lda #spritemap_pointers_balloon+6
            sta !enemyspritemapptr,x
            
            lda #enemy_instruction_balloon_falling
            sta !enemymainptr,x
            rts
        }
        
        ..dart: {
            ;todo: change spritemap to crumpled dart
            ;set ai to fall to ground
            jsr enemy_clear
            rts
        }
    }
    
;===========================================================================================
;=====================================    E N E M Y    =====================================
;====================================      M A I N      ====================================
;===================================   R O U T I N E S   ===================================
;===========================================================================================
    
    .main: {
        ..drop: {
            
            lda !enemyproperty,x
            bne +
            
            lda !enemytimer,x
            inc
            sta !enemytimer,x
            cmp #$000a
            bmi +++
            
            sta !enemyproperty,x
            lda #spritemap_pointers_drip+10
            sta !enemyspritemapptr,x
            
            +
            
            lda !framecounter
            and #$0008
            lsr #2
            clc
            adc #spritemap_pointers_drip+10
            sta !enemyspritemapptr,x
            
            lda !enemysuby,x
            
            clc
            adc #$8000
            sta !enemysuby,x
            
            lda !enemyy,x
            adc #$0002
            sta !enemyy,x
            
            cmp !kfloor
            bpl ++
            
            +++
            rts
            
            ++
            jsr enemy_clear
            
            rts
            
            ...frames: {
                dw #spritemap_pointers_drip+8
                dw #spritemap_pointers_drip+10
                dw #spritemap_pointers_drip+12
            }
        }
        
        
        ..drip: {
            lda #enemy_instruction_drip_wait
            sta !enemymainptr,x
            rts
        }
        
        ..switchcommon: {
            lda !enemytimer,x
            beq +
            dec !enemytimer,x
        +   rts
        }
        
        ..switch: {
            phb
            
            pea.w !spritemapbankword
            plb : plb
            
            lda !enemyproperty2,x
            and #$0f00
            xba
            clc
            adc #spritemap_pointers_switch
            
            sta !enemyspritemapptr,x
            
            jsr enemy_main_switchcommon
            
            plb
            rts
        }
        
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
    
;===========================================================================================
;=====================================    E N E M Y    =====================================
;====================================     T O U C H     ====================================
;===================================   R O U T I N E S   ===================================
;===========================================================================================
    
    .touch: {
        ..drip: {
            ;todo: kill, or, if on fire, put out fire
            
            jsr enemy_touch_kill
            rts
        }
        
        
        ..lightswitch: {
            ;turn off or on the lights
            lda !enemytimer,x
            bne +
            
            lda #$0030
            sta !enemytimer,x
            
            lda !colormathmode
            eor #$0001
            sta !colormathmode
            
        +   rts
        }
        
        ..kill: {
            lda !kgliderstatelostlife
            sta !glidernextstate
            rts
        }
        
        ..switch: {
            ;x = enemy index
            lda !enemytimer,x
            bne +
            lda #$0030
            sta !enemytimer,x
            
            lda !enemyproperty3,x
            tay                         ;y = room/enemy index target for link data
            lda !enemyproperty,x        ;a = enemy data for target
            jsl link_make
            
            lda !enemyproperty2,x
            eor #$0200                  ;spritemap selection
            sta !enemyproperty2,x
            
            ;make table entry which keeps switch switched
            stx !localtempvar
            lda !roomindex
            ;asl
            xba
            ora !localtempvar           ;y = target for this room, this enemy
            ora #$0040
            tay
            
            lda !enemyproperty2,x
            jsl link_make
            
        +   rts
        }
        
        ..duct: {
            lda !enemyproperty,x        ;low byte = room index to go to
            and #$00ff
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
            
            lda !enemyproperty3,x
            jsl itembit_set
            
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
            
            lda !enemyproperty3,x
            jsl itembit_set
            
            jsr enemy_clear
            rts
        }
        
        
        ..battery: {
            lda !enemyproperty,x
            clc
            adc !gliderbatterytime
            sta !gliderbatterytime
            
            lda !enemyproperty3,x
            jsl itembit_set
            
            jsr enemy_clear
            rts
        }
        
        ..bandspack: {
            lda !bandsammo
            clc
            adc !kbandammoamount
            sta !bandsammo
            
            lda !enemyproperty3,x
            jsl itembit_set
            
            jsr enemy_clear
            rts
        }
    }
}