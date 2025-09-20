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
    
    .findslot: {
        ;returns empty enemy slot in Y
        ldy #!enemyarraysize
        -
        lda !enemyID,y
        beq +
        dey : dey
        bpl -
        bmi ++
        
        +
        rtl
        
        ++
        ldy #$ffff
        rtl
    }
    
    .dynamicspawn: {
        
        ;we already do this in a couple places but there's not really
        ;a routine to do it
        ;see candle flame, bands, glider being on fire, drip
        
        rts
    }
    
    
    .spawn: {
        ;spawn single enemy from enemy population
        ;write to enemy ram
        ;x = room's enemy list pointer
        ;y = enemy index
        
        phb
        phx
        
        phk
        plb
        
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
        rtl
        
        ..stop: {
            plx
            plb
            pla
            sep #$20
            pla
            rep #$20
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
        jsl enemy_spawn
        
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
        
        ;=====================================  DART  ======================================
        
        ..dart: {
            ...checklateral: {
                ;x = enemy index
                lda !enemyx,x
                cmp !kleftbound
                bmi +
                cmp !krightbound
                bpl +
                rts
                
                +
                lda !enemyvariable,x
                sta !enemyx,x
                
                rts
            }
            
            ...checkvertical: {
                lda !enemyy,x
                cmp !kceiling
                bmi +
                cmp !kfloor
                bpl +
                rts
                
                +
                lda !enemyrespawnpoint,x
                sta !enemyy,x
                
                lda !enemyvariable,x
                sta !enemyx,x
                rts
            }

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
                jsl enemy_spawn
                
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
                
                lda !roomcounter
                and #$0008
                lsr #2
                clc
                adc #spritemap_pointers_balloon
                sta !enemyspritemapptr,x

                +
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
                lda #$00ea
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
                lda #spritemap_pointers_null
                sta !enemyspritemapptr,x
                
                dec !enemytimer,x
                bpl +
                
                lda #enemy_main_balloon
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
        ..balloon:      dw enemy_headers_balloon                ;
        ..paper:        dw enemy_headers_paper                  ;
        ..clock:        dw enemy_headers_clock                  ;
        ..battery:      dw enemy_headers_battery                ;
        ..bandspack:    dw enemy_headers_bandspack              ;
        ..dart:         dw enemy_headers_dart                   ;
        ..duct:         dw enemy_headers_duct                   ;
        ..band:         dw enemy_headers_band                   ; all exist in this file
        ..lightswitch:  dw enemy_headers_lightswitch            ;
        ..switch:       dw enemy_headers_switch                 ;
        ..drip:         dw enemy_headers_drip                   ;
        ..drop:         dw enemy_headers_drop                   ;
        ..foil:         dw enemy_headers_foil                   ;
        ..fire:         dw enemy_headers_fire                   ;
        ..candleflame:  dw enemy_headers_candleflame            ;
        ..samantha:     dw enemy_headers_samantha               ;
        
        ..catbody:          dw cat_bodyheader                       ;
        ..catpaw:           dw cat_pawheader                        ;
        ..cattail:          dw cat_tailheader                       ;
        ..fish:             dw fish_header                          ;
        ..copter:           dw copter_header                        ; exist in their own files
        ..teddy:            dw teddy_header                         ;
        ..gfxloader:        dw gfxloader_header                     ;
        ..star:             dw star_header                          ;
        ..cutscenehandler:  dw cutscenehandler_header               ;
        
        ;todo: basketball
        ;todo: toaster
    }
    
    
    .headers: {
        ..balloon:
            dw  spritemap_pointers_balloon,      ;spritemap ptr
                $0030,                           ;xsize,
                $0030,                           ;ysize,
                $0000,                           ;init routine,
                enemy_main_balloon,              ;main routine,
                enemy_touch_kill,                ;touch,
                enemy_shot_balloon               ;shot
        ..paper:
            dw  spritemap_pointers_paper,
                $0048,
                $0028,
                enemy_init_prize,
                $0000,
                enemy_touch_paper,
                $0000
        ..clock:
            dw  spritemap_pointers_clock,
                $0040,
                $0020,
                enemy_init_prize,
                $0000,
                enemy_touch_clock,
                $0000
        ..battery:
            dw  spritemap_pointers_battery,
                $0040,
                $0028,
                enemy_init_prize,
                $0000,
                enemy_touch_battery,
                $0000
        ..bandspack:
            dw  spritemap_pointers_bandspack,
                $0030,
                $0030,
                enemy_init_prize,
                $0000,
                enemy_touch_bandspack,
                $0000
        ..dart:
            dw  spritemap_pointers_dart,
                $0040,
                $0020,
                enemy_init_dart,
                enemy_main_dart,
                enemy_touch_kill,
                enemy_shot_dart
        ..duct:
            dw  spritemap_pointers_duct,
                $0030,
                $0028,
                enemy_init_duct,
                $0000,
                enemy_touch_duct,
                $0000
        ..band:
            dw  spritemap_pointers_band,
                $0020,
                $0020,
                $0000,
                enemy_main_band,
                $0000,
                $0000
        ..lightswitch:
            dw  spritemap_pointers_lightswitch,
                $0030,
                $0020,
                $0000,
                enemy_main_switchcommon,
                enemy_touch_lightswitch,
                enemy_touch_lightswitch
        ..switch:
            dw  spritemap_pointers_switch,
                $0030,
                $0020,
                $0000,
                enemy_main_switch,
                enemy_touch_switch,
                enemy_touch_switch
        ..drip:
            dw  spritemap_pointers_drip,
                $0018,
                $0018,
                enemy_init_drip,
                enemy_main_drip,
                enemy_touch_drip,
                $0000
        ..drop:
            dw  spritemap_pointers_drip+8,
                $0028,
                $0020,
                $0000,
                enemy_main_drop,
                enemy_touch_drip,
                $0000
        ..foil:
            dw  spritemap_pointers_foil,
                $0048,
                $0020,
                $0000,
                $0000,
                enemy_touch_foil,
                $0000
        ..fire:
            dw  spritemap_pointers_fire,
                $0018,
                $0018,
                $0000,
                enemy_main_fire,
                $0000,
                $0000
        ..candleflame:
            dw  spritemap_pointers_candleflame,         ;spritemap ptr
                $0030,                                  ;xsize,
                $0020,                                  ;ysize,
                $0000,                                  ;init routine,
                enemy_main_candleflame,                 ;main routine,
                enemy_touch_candleflame,                ;touch,
                $0000                                   ;shot
        ..samantha:
            dw  spritemap_pointers_samantha,            ;spritemap ptr
                $0030,                                  ;xsize,
                $0030,                                  ;ysize,
                enemy_init_samantha,                    ;init routine,
                $0000,                                  ;main routine,
                $0000,                                  ;touch,
                $0000                                   ;shot
    }


;===========================================================================================
;=====================================    E N E M Y    =====================================
;====================================      I N I T      ====================================
;===================================   R O U T I N E S   ===================================
;===========================================================================================
    
    .init: {
        ..samantha: {
            lda #$000b
            jsl load_sprite         ;load sprite data b (samantha)
            rts
        }
        
        
        ..fire: {
            lda !kgliderstateonfire
            sta !glidernextstate
            sta !gliderstate
            
            lda #$0060
            sta !firetimer
            sta !iframecounter
            rts
        }
        
        
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
            lda !enemyy,x
            sta !enemyrespawnpoint,x
            
            lda !enemyx,x
            sta !enemyvariable,x
            
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
        ..candleflame: {
            lda !roomcounter
            and #$0008
            lsr #2
            clc
            adc #spritemap_pointers_candleflame
            sta !enemyspritemapptr,x
            
            rts
        }
        
        ..fire: {
            lda !firetimer
            beq ++
            
            lda !roomcounter
            and #$000c
            lsr
            clc
            adc #spritemap_pointers_fire
            sta !enemyspritemapptr,x
            
            lda !gliderdir
            dec
            bmi +
            inc
            +
            clc
            adc !gliderx
            sta !gliderx
            
            
            lda !gliderx
            sta !enemyx,x
            
            lda !glidery
            sec
            sbc #$0008
            sta !enemyy,x
            +++
            rts
            
            ++
            jsr enemy_clear
            rts
        }
        
        
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
            jsr enemy_instruction_balloon_checkheight
            jsr enemy_instruction_balloon_moveup
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
            !tempspeed      =   !localtempvar
            !tempsubspeed   =   !localtempvar2
            
            
            jsr enemy_instruction_dart_checklateral
            jsr enemy_instruction_dart_checkvertical
            
            ;vertical drop
            ;this is subspeed, but we only get the top byte
            ;so, it's ff00 max subspeed
            
            lda !enemyproperty2,x
            and #$ff00
            sta !tempsubspeed
            
            lda !enemysuby,x
            clc
            adc !tempsubspeed
            sta !enemysuby,x
            
            lda !enemyy,x
            adc #$0000              ;use carry from subspeed math
            sta !enemyy,x
            
            ;get enemy speed/subspeeds from property3
            ;and shift them into place
            ;this is the same x.yyy as balloovement
            
            lda !enemyproperty3,x
            and #$f000
            xba
            lsr #4
            sta !tempspeed
            
            lda !enemyproperty3,x
            and #$0fff
            asl #4
            sta !tempsubspeed
            
            lda !enemyproperty,x
            bmi +
            
            ;left movement
            
            lda !enemysubx,x
            sec
            sbc !tempsubspeed
            sta !enemysubx,x
            
            lda !enemyx,x
            sbc !tempspeed  ;use carry from previous math
            sta !enemyx,x
            
            rts
            
            ;right movement
            +
            
            lda !enemysubx,x
            clc
            adc !tempsubspeed
            sta !enemysubx,x
            
            lda !enemyx,x
            adc !tempspeed  ;use carry from previous math
            sta !enemyx,x
            
            rts
        }
    }
    
;===========================================================================================
;=====================================    E N E M Y    =====================================
;====================================     T O U C H     ====================================
;===================================   R O U T I N E S   ===================================
;===========================================================================================
    
    .touch: {
        ..candleflame: {
            lda !kgliderstatefirestarted
            sta !glidernextstate
            rts
        }
        
        ..drip: {
            ;todo: kill, or, if on fire, put out fire
            lda !gliderstate
            cmp !kgliderstateonfire
            beq +
            
            jsr enemy_touch_kill
            rts
            
            ;if on fire, put out fire and give iframes
            lda !kglideriframes
            sta !iframecounter
            
            lda !kgliderstateidle
            sta !gliderstate
            rts
        }
        
        ..foil: {
            ;add to foil amount
            ;change sprite palette 7:
                ;set !foilpalette, write nmi handler to dma one palette line
            
            lda !foilamount
            clc
            adc !kfoilpackamount
            sta !foilamount
            
            jsr enemy_clear
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
            lda !foilamount
            bne ...foil
            
            lda !kgliderstatelostlife
            sta !glidernextstate
            sta !gliderstate
            
            ...foilreturn:
            rts
            
            ...foil: {
                phx
                phb
                
                phk
                plb
                
                lda !foilamount
                beq +
                dec
                sta !foilamount
                ;beq +
                
                lda !kliftstateup
                sta !gliderliftstate
                
                lda !gliderdir
                asl
                tax
                lda enemy_touch_kill_foil_table,x
                clc
                adc !gliderx
                sta !gliderx
                
                ;play hit sound, some day
                
            +   plb
                plx
                bra enemy_touch_kill_foilreturn
        
                ....table: {
                    dw $fffe, $0002
                }
            }
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