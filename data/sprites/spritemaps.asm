

;todo:
;idle having its own sprite entries maybe doesn't make sense?
;since it will just retain whatever sprite (left or right)
;that was used during left or right movement previously
;so maybe we check for 0 at the handler and do something special then?

;i think the above is done
;todo: confirm the above, and above the above

;print "spritemaps: ", pc

!spritemapbanklong        =   spritemap&$ff0000
!spritemapbankword        =   !spritemapbanklong>>8
!spritemapbankshort       =   !spritemapbanklong>>16


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
            
        ..bandspack:
            dw spritemap_bandspack
            
        ..dart: {
            dw spritemap_dart_left,
               spritemap_dart_right,
               spritemap_dart_lefthit,
               spritemap_dart_righthit
        }
        
        ..null: {
            dw spritemap_null
        }
        
        ..duct: {
            dw spritemap_duct_floor,
               spritemap_duct_ceiling
        }
        
        ..band: {
            dw spritemap_band_1,
               spritemap_band_2,
               spritemap_band_3
        }
        
        ..lightswitch: {
            dw spritemap_lightswitch
        }
        
        ..switch: {
            dw spritemap_switch_on,
               spritemap_switch_off
        }
        
        ..drip: {
            dw spritemap_drip_0,
               spritemap_drip_1,
               spritemap_drip_2,
               spritemap_drip_3,
               spritemap_drip_4,
               spritemap_drip_5,
               spritemap_drip_6
        }
    }
    
    
    .glider: {
        ..idle: {
            db $00
        }
        
        ..right: {
            ;number of entries
            db $03
            ;  x,   y,   tile,  properties, high table bits (size select) (unused)
            ;                           1 <-- that bit is for selecting the second page
            db $f0, $00, $00,   %00111110,  %00000010
            db $00, $00, $02,   %00111110,  %00001000
            db $10, $00, $04,   %00111110,  %00100000
        }
        
        ..left: {
            db $03
            db $f0, $00, $06,   %00111110,  %00000010
            db $00, $00, $08,   %00111110,  %00001000
            db $10, $00, $0a,   %00111110,  %00100000
        }
        
        ..tipleft: {
            db $06
            db $f0, $00, $20,   %00111110,  %00000010
            db $00, $00, $22,   %00111110,  %00001000
            db $00, $00, $24,   %00111110,  %00100000
            db $f8, $10, $41,   %00111110,  %00000000
            db $00, $10, $42,   %00111110,  %00000000
            db $08, $10, $42,   %00111110,  %00000000
        }
        
        ..tipright: {
            db $07
            db $f0, $00, $26,   %00111110,  %00000010
            db $00, $00, $28,   %00111110,  %00001000
            db $10, $00, $2a,   %00111110,  %00100000
            db $00, $08, $48,   %00111110,  %00000000
            db $08, $08, $49,   %00111110,  %00000000
            db $10, $08, $4a,   %00111110,  %00000000
            db $18, $08, $4b,   %00111110,  %00000000
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
        db $00, $f8, $96,   %00110000,  %00000010
        db $00, $00, $a6,   %00110000,  %00000010
    }
    
    .bandspack: {
        db $04
        db $f8, $00, $9c,   %00110000,  %00000010
        db $08, $00, $9e,   %00110000,  %00000010
        db $f8, $08, $ac,   %00110000,  %00000010
        db $08, $08, $ae,   %00110000,  %00000010

    }
    
    .dart: {
        ..left: {                      ;v --  the 1 bit here is for name select
            db $08  ;todo redo this to use 6 like the right one
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
            ;right
            db $06
            db $f0, $08, $06,   %01110001,  %00000010
            db $00, $08, $04,   %01110001,  %00000010
            db $10, $08, $02,   %01110001,  %00000010
            db $20, $08, $00,   %01110001,  %00000010
            db $f0, $10, $16,   %01110001,  %00000010
            db $00, $10, $14,   %01110001,  %00000010
            
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
    
    .duct: {
        ..floor: {
            db $03
            db $f0, $00, $e0,   %10110000,  %00000010
            db $00, $00, $e2,   %10110000,  %00000010
            db $10, $00, $e4,   %10110000,  %00000010
        }
        
        ..ceiling: {
            db $03
            db $f0, $00, $e0,   %00110000,  %00000010
            db $00, $00, $e2,   %00110000,  %00000010
            db $10, $00, $e4,   %00110000,  %00000010
        }
    }
    
    .band: {
        ..1: {
            db $01
            db $00, $00, $0c,   %00110000,  %00000010
        }
        
        ..2: {
            db $01
            db $00, $00, $0e,   %00110000,  %00000010
        }
        
        ..3: {
            db $01
            db $00, $00, $2c,   %00110000,  %00000010
        }
    }
    
    .lightswitch: {
        db $02
        db $00, $00, $cc,   %00110000,  %00000010
        db $00, $08, $dc,   %00110000,  %00000010
    }
    
    .switch: {
        ..on: {
            db $02
            db $00, $fb, $d7,   %00111000,  %00000010
            db $00, $04, $e7,   %00111000,  %00000010
        }
        
        ..off: {
            db $02
            db $00, $fb, $d9,   %00111000,  %00000010
            db $00, $04, $e9,   %00111000,  %00000010
        }
        
    }
    
    .drip: {
        ..0: {
            db $01
            db $00, $00, $30,   %00111001,  %00000010
        }
        
        ..1: {
            db $01
            db $00, $00, $32,   %00111001,  %00000010
        }
        
        ..2: {
            db $01
            db $00, $00, $34,   %00111001,  %00000010
        }
        
        ..3: {
            db $01
            db $00, $00, $36,   %00111001,  %00000010
        }
        
        ..4: {
            db $01
            db $00, $00, $38,   %00111001,  %00000010
        }
        
        ..5: {
            db $01
            db $00, $00, $3a,   %00111001,  %00000010
        }
        
        ..6: {
            db $01
            db $00, $00, $3c,   %00111001,  %00000010
        }
    }
}