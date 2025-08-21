
cat: {
    .bodyheader:                        ;xsize      ysize       init            main            touch          shot
        dw cat_bodyspritemaps_ptr,      $0040,      $002e,      cat_init,       cat_bodymain,   cat_pet,       cat_shot
    .pawheader:
        dw cat_pawspritemaps_ptr,       $0030,      $0020,      $0000,          cat_pawmain,    cat_touch,     cat_shot
    .tailheader:
        dw cat_tailspritemaps_ptr,      $0020,      $0020,      $0000,          cat_tailmain,   cat_tailpush,  cat_shot
    
    
    ;=======================================================================================
    ;========================================= INIT ========================================
    ;=======================================================================================
    
    .init: {
        ;load graphics
        ;cat will get the entire second page of oam vram space
        ;init gets run during forced blank so this will work
        
        ;todo: make something replace the graphics this overwrites, in the room before cat
        
        stz !catstate
        stz !tailstate
        stz !pawstate
        
        lda #$0006
        jsl load_sprite
        rts
    }
    
    ;=======================================================================================
    ;========================================= BODY ========================================
    ;========================================= MAIN ========================================
    ;=======================================================================================
    
    .bodymain: {
        jsr cat_calculatedistancetoglider
        
        lda !catstate
        asl
        tax
        jsr (cat_bodystatetable,x)
        rts
    }
    
    .bodystatetable: {
        !kcatstateidle              =       #$0000
        !kcatstatebegintobat        =       #$0001
        !kcatstatebegintostrike     =       #$0002
        
        !kpawstateidle              =       #$0000
        !kpawstateraising           =       #$0001
        !kpawstatepeak              =       #$0002
        !kpawstatelowering          =       #$0003
        
        
        dw cat_bodystate_idle,              ;0
           cat_bodystate_begintobat,        ;1
           cat_bodystate_begintostrike,     ;2
           cat_bodystate_begintoswirl       ;3
    }
    
    .bodystate: {
        ..idle: {
            ;idly move tail
            ;check glider position
            ;react to glider being nearby
            ;carry out actions and return to idle
            
            lda !catdistancetogliderx
            cmp #$0040
            bpl ++
            
            cmp #$0020
            bmi +

            lda !kcatstatebegintobat        ;if glider is within $40 and $20 pixels
            sta !catstate
            rts
            
            +
            lda !kcatstatebegintostrike     ;if glider is closer than $20 pixels
            sta !catstate
            rts
            
            ++                              ;if glider is neither
            ;chance to swish tail
            stz !pawstate
            rts
        }
        
        ..begintobat: {
            ;glider is kind of near,
            ;short threatening batting at the air
            lda !kpawstateraising
            sta !pawstate
            
            ;yadda, yadda?
            
            stz !catstate
            rts
        }
        
        ..begintostrike: {
            ;glider was close enough,
            ;set paw state to fully strike
            rts
        }
        
        ..begintoswirl: {
            ;move tail around a bit in anticipation
            rts
        }
        
    }
    
    
    ;=======================================================================================
    ;======================================= PAW ===========================================
    ;=======================================================================================
    
    .pawmain: {
        lda !pawstate
        asl
        tax
        jsr (cat_pawstatetable,x)
        rts
    }
    
    .pawstatetable: {
        dw cat_pawstate_idle,
           cat_pawstate_raising,
           cat_pawstate_peak,
           cat_pawstate_lowering
    }
    
    .pawstate: {
        ..idle: {
            rts
        }
        
        ..raising: {
            ;move paw, animate spritemaps
            ;when peak is reached, do a wiggle?
            rts
        }
        
        ..peak: {
            ;wiggle a tad
            rts
        }
        
        ..lowering: {
            ;move paw, animate spritemaps
            ;then return to idle
            rts
        }
    }
    
    ;=======================================================================================
    ;========================================= TAIL ========================================
    ;=======================================================================================
    
    .tailmain: {
        lda !tailstate
        asl
        tax
        jsr (cat_tailstatetable,x)
        rts
    }
    
    .tailstatetable: {
        dw cat_tailstate_idle
    }
    
    .tailstate: {
        ..idle: {
            rts
        }
        
        
    }
    
    
    ;=======================================================================================
    ;==================================== CAT ROUTINES =====================================
    ;=======================================================================================
    
    .calculatedistancetoglider: {
        ;i think we want to |distancetogliderx|
        
        lda !enemyx,x
        sec
        sbc !gliderx
        bpl +
        eor #$ffff
        inc
        +
        sta !catdistancetogliderx
        
        lda !enemyy,x
        sec
        sbc !glidery
        bpl ++
        eor #$ffff
        inc
        ++
        sta !catdistancetoglidery
        
        
        rts
    }
    
    .touch: {
        ;probably just death?
        jsr enemy_touch_kill
        rts
    }
    
    .tailpush: {
        ;move glider slightly
        dec !glidery
        inc !gliderx
        rts
    }
    
    .shot: {
        ;y = enemy index of rubber band that hit the cat
        phx
        tyx
        jsr enemy_clear
        plx
        rts
    }
    
    .pet: {
        lda !gliderx
        cmp !enemyx,x
        bmi +
        
        inc !gliderx
        rts
        
        +
        dec !gliderx
        rts
        
        jsr enemy_touch_kill
        rts
    }
    
    ;=======================================================================================
    ;================================ CAT BODY SPRITEMAPS ==================================
    ;=======================================================================================
    
    .bodyspritemaps: {
        ..ptr: {
            dw cat_bodyspritemaps_1
        }
        
        ..1: {
            ;number of sprites
            db $0e
               ;x   y    tile   properties  unused high table bits
            db $00, $00, $26,   %00110001,  %00000010
            db $f0, $00, $24,   %00110001,  %00000010
            db $f0, $f0, $04,   %00110001,  %00000010
            db $00, $f0, $06,   %00110001,  %00000010
            db $10, $f0, $08,   %00110001,  %00000010
            db $20, $f0, $0a,   %00110001,  %00000010
            db $28, $f0, $0b,   %00110001,  %00000010
            db $10, $00, $28,   %00110001,  %00000010
            db $20, $00, $2a,   %00110001,  %00000010
            db $28, $00, $2b,   %00110001,  %00000010
            db $f0, $08, $34,   %00110001,  %00000010
            db $00, $08, $36,   %00110001,  %00000010
            db $10, $08, $38,   %00110001,  %00000010
            db $20, $08, $3a,   %00110001,  %00000010
        }
        
    }
    
    ;=======================================================================================
    ;================================= CAT PAW SPRITEMAPS ==================================
    ;=======================================================================================
    
    .pawspritemaps: {
        ..ptr: {
            dw cat_pawspritemaps_1,
               cat_pawspritemaps_2,
               cat_pawspritemaps_3
        }
        
        ..1: {
            db $05
            db $00, $00, $30,   %00110001,  %00000010
            db $00, $f8, $20,   %00110001,  %00000010
            db $10, $00, $32,   %00110001,  %00000010
            db $10, $e8, $02,   %00110001,  %00000010
            db $10, $f8, $22,   %00110001,  %00000010
        }
        
        ..2: {
            db $01
            db $00, $00, $00,   %00110001,  %00000010
        }
        
        ..3: {
            db $01
            db $00, $00, $00,   %00110001,  %00000010
        }
    }
    
    ;=======================================================================================
    ;================================ CAT TAIL SPRITEMAPS ==================================
    ;=======================================================================================
    
    .tailspritemaps: {
        ..ptr: {
            dw cat_tailspritemaps_1,
               cat_tailspritemaps_2,
               cat_tailspritemaps_3
        }
        
        ..1: {
            db $05
            db $00, $00, $57,   %00110001,  %00000010
            db $00, $08, $67,   %00110001,  %00000010
            db $10, $00, $59,   %00110001,  %00000010
            db $20, $00, $5b,   %00110001,  %00000010
            db $20, $f8, $4b,   %00110001,  %00000010

        }
        
        ..2: {
            db $01
            db $00, $00, $00,   %00110001,  %00000010
        }
        
        ..3: {
            db $01
            db $00, $00, $00,   %00110001,  %00000010
        }
    }
}