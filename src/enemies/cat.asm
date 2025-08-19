
cat: {
    .bodyheader:                        ;xsize      ysize       init            main             touch          shot
        dw cat_bodyspritemaps_ptr,      $0060,      $0030,      cat_init,       cat_main,        cat_touch,     cat_shot
    .pawheader:
        dw cat_pawspritemaps_ptr,       $0030,      $0030,      $0000,          $0000,           $0000,         $0000
    .tailheader:
        dw cat_tailspritemaps_ptr,      $0020,      $0020,      $0000,          $0000,           $0000,         $0000
    
    .init: {
        ;load graphics
        ;cat will get the entire second page of oam vram space
        ;init gets run during forced blank so this will work
        
        ;todo: make something replace the graphics this overwrites, in the room before cat
        lda #$0006
        jsl load_sprite
        rts
    }
    
    .main: {
        lda !catmode
        asl
        tax
        jsr (cat_modetable,x)
        rts
    }
    
    .modetable: {
        dw cat_mode_idle
    }
    
    .mode: {
        ..idle: {
            rts
        }
    }
    
    .touch: {
        ;probably just death?
        rts
    }
    
    .shot: {
        ;nothing?
        ;or delete band?
        rts
    }
    
    .bodyspritemaps: {
        ..ptr: {
            dw cat_bodyspritemaps_1
        }
        
        ..1: {
            ;number of sprites
            db $0f
               ;x   y    tile   properties  unused high table bits
            db $00, $00, $26,   %00110001,  %00000010
            db $f0, $00, $24,   %00110001,  %00000010
            db $e0, $f0, $02,   %00110001,  %00000010
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
    
    
    .pawspritemaps: {
        ..ptr: {
            dw cat_pawspritemaps_1,
               cat_pawspritemaps_2,
               cat_pawspritemaps_3
        }
        
        ..1: {
            db $04
            db $d0, $00, $20,   %00110001,  %00000010
            db $d0, $08, $30,   %00110001,  %00000010
            db $e0, $00, $22,   %00110001,  %00000010
            db $e0, $08, $32,   %00110001,  %00000010
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
    
    
    .tailspritemaps: {
        ..ptr: {
            dw cat_tailspritemaps_1,
               cat_tailspritemaps_2,
               cat_tailspritemaps_3
        }
        
        ..1: {
            db $05
            db $28, $10, $4b,   %00110001,  %00000010
            db $28, $18, $5b,   %00110001,  %00000010
            db $18, $18, $59,   %00110001,  %00000010
            db $08, $18, $57,   %00110001,  %00000010
            db $08, $20, $67,   %00110001,  %00000010
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