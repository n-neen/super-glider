

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
        dw .glider_right,   ;since we switched from state to dir, 0 is no longer possible
           .glider_left,
           .glider_right,           
           .glider_tipleft,         
           .glider_tipright,        
           .glider_turnaround,      
           .glider_lostlife         
    }
    
    .glider: {
        ..idle: {
            db $00
        }
        
        ..right: {
            db $03
            ;  x,   y,   tile,  properties, high table bits (size select) (unused)
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
}