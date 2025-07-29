

;todo:
;idle having its own sprite entries maybe doesn't make sense?
;since it will just retain whatever sprite (left or right)
;that was used during left or right movement previously
;so maybe we check for 0 at the handler and do something special then?

;i think the above is done
;todo: confirm the above, and above the above

spritemap: {
    .pointers: {
        ;see glider constants in defines.asm
        ;these correspond to !gliderdir
        ;todo: make pose
        ..glider:
            dw spritemap_glider_right,   ;since we switched from state to dir, 0 is no longer possible
               spritemap_glider_left,
               spritemap_glider_right,
               spritemap_glider_tipleft,
               spritemap_glider_tipright,
               spritemap_glider_turnaround,
               spritemap_glider_lostlife
           
        ..balloon:
            dw spritemap_balloon_1,
               spritemap_balloon_2,
               spritemap_balloon_3,
               spritemap_balloon_pop1,
               spritemap_balloon_pop2
               
        ..paper:
            dw spritemap_paper
            
        ..clock:
            dw spritemap_clock
            
        ..battery:
            dw spritemap_battery
            
        ..bands:
            dw spritemap_bands
            
        ..dart: {
            dw spritemap_dart_left,
               spritemap_dart_right,
               spritemap_dart_lefthit,
               spritemap_dart_righthit
        }
        
        ..null: {
            dw spritemap_null
        }
    }
    
    
                ;starting tile in vram
    .glider: {  ;$00
        ..idle: {
            db $00
        }
        
        ..right: {
            ;number of entries
            db $03
            ;  x,   y,   tile,  properties, high table bits (size select) (unused)
            ;                           1 <-- that bit is for selecting the second page
            db $f0, $00, $00,   %00110000,  %00000010
            db $00, $00, $02,   %00110000,  %00001000
            db $10, $00, $04,   %00110000,  %00100000
        }
        
        ..left: {
            db $03
            db $f0, $00, $06,   %00110000,  %00000010
            db $00, $00, $08,   %00110000,  %00001000
            db $10, $00, $0a,   %00110000,  %00100000
        }
        
        ..tipleft: {
            db $06
            db $f0, $00, $20,   %00110000,  %00000010
            db $00, $00, $22,   %00110000,  %00001000
            db $00, $00, $24,   %00110000,  %00100000
            db $f8, $10, $41,   %00110000,  %00000000
            db $00, $10, $42,   %00110000,  %00000000
            db $08, $10, $42,   %00110000,  %00000000
        }
        
        ..tipright: {
            db $07
            db $f0, $00, $26,   %00110000,  %00000010
            db $00, $00, $28,   %00110000,  %00001000
            db $10, $00, $2a,   %00110000,  %00100000
            db $00, $08, $48,   %00110000,  %00000000
            db $08, $08, $49,   %00110000,  %00000000
            db $10, $08, $4a,   %00110000,  %00000000
            db $18, $08, $4b,   %00110000,  %00000000
        }
        
        ..turnaround: {
            db $00
        }
        
        ..lostlife: {
            db $00
        }
    }
    
    .balloon: { ;$50
        ..1: {
            db $04
            db $f8, $f8, $50,   %00110000,  %00000010
            db $00, $f8, $51,   %00110000,  %00001000
            db $f8, $08, $70,   %00110000,  %00100000
            db $00, $08, $71,   %00110000,  %10000000
        }
        
        ..2: {
            db $04
            db $f8, $f8, $53,   %00110000,  %00000010
            db $00, $f8, $54,   %00110000,  %00001000
            db $f8, $08, $73,   %00110000,  %00100000
            db $00, $08, $74,   %00110000,  %10000000
        }
        
        ..3: {
            db $04
            db $f8, $f8, $56,   %00110000,  %00000010
            db $00, $f8, $57,   %00110000,  %00001000
            db $f8, $08, $76,   %00110000,  %00100000
            db $00, $08, $77,   %00110000,  %10000000
        }
        
        ..pop1: {
            db $04
            db $f8, $f8, $59,   %00110000,  %00000010
            db $00, $f8, $5a,   %00110000,  %00001000
            db $f8, $08, $79,   %00110000,  %00100000
            db $00, $08, $7a,   %00110000,  %10000000
        }
        
        ..pop2: {
            db $04
            db $f8, $f8, $5c,   %00110000,  %00000010
            db $00, $f8, $5d,   %00110000,  %00001000
            db $f8, $08, $7c,   %00110000,  %00100000
            db $00, $08, $7d,   %00110000,  %10000000
        }
    }
    
    
    .paper: {   ;$90
        db $06
        ;  x    y    tile   properties
        db $f0, $f8, $90,   %00110000,  %00000010
        db $00, $f8, $92,   %00110000,  %00000010
        db $10, $f8, $94,   %00110000,  %00000010
        db $f0, $00, $a0,   %00110000,  %00000010
        db $00, $00, $a2,   %00110000,  %00000010
        db $10, $00, $a4,   %00110000,  %00000010
    }
    
    .clock: {
        db $04
        db $f8, $00, $98,   %00110000,  %00000010
        db $08, $00, $9a,   %00110000,  %00000010
        db $f8, $10, $b8,   %00110000,  %00000010
        db $08, $10, $ba,   %00110000,  %00000010
    }
    
    .battery: {
        db $02
        db $08, $00, $96,   %00110000,  %00000010
        db $08, $08, $a6,   %00110000,  %00000010
    }
    
    .bands: {
        db $04
        db $f8, $00, $9c,   %00110000,  %00000010
        db $08, $00, $9e,   %00110000,  %00000010
        db $f8, $08, $ac,   %00110000,  %00000010
        db $08, $08, $ae,   %00110000,  %00000010

    }
    
    .dart: {
        ..left: {                      ;v --  the 1 bit here is for name select
            db $08
            db $f0, $00, $00,   %00110001,  %00000010
            db $00, $00, $02,   %00110001,  %00000010
            db $10, $00, $04,   %00110001,  %00000010
            db $20, $00, $06,   %00110001,  %00000010
            
            db $f0, $08, $10,   %00110001,  %00000010
            db $00, $08, $12,   %00110001,  %00000010
            db $10, $08, $14,   %00110001,  %00000010
            db $20, $08, $16,   %00110001,  %00000010
        }
        
        ..right: {
            ;right spritemap
        }
        
        ..lefthit: {
            ;after being hit by rubber band
        }
        
        ..righthit: {
            ;after being hit by rubber band
        }
    }
    
    .null: {
        db $01
        db $00, $00, $00,   %00110001,  %00000010
    }
}