
;======================================================= FIRST FLOOR =======================================================
                ;!kobjectentrylength in defines.asm!
.objlist: { ;obj type           x      y       palette  variable
    ..0: {                                              ;like room ptr for stairs, or vent height
        dw #obj_ptr_vent,       $0006, $001a,  $0000,   $0050           ;30
        dw #obj_ptr_openwall,   $0000, $0000,  $0000,   $0000           ;2e
        dw #obj_ptr_vent,       $0012, $001a,  $0000,   $0020           ;2c
        dw #obj_ptr_vent,       $001a, $001a,  $0000,   $0020           ;2a
        dw #obj_ptr_upstairs,   $000e, $0005,  $0400,   $0000           ;28
        dw $ffff
    }
    
    ..1: {
        dw #obj_ptr_openwall,   $0000, $0000,  $0000,   $8000
        dw #obj_ptr_openwall,   $0000, $0000,  $0000,   $0000
        dw #obj_ptr_fanL,       $0011, $000d,  $0800,   $0013
        dw #obj_ptr_varitable,  $0006, $000b,  $0800,   $0803
        dw #obj_ptr_vent,       $0005, $001a,  $0000,   $0013
        dw #obj_ptr_vent,       $0016, $001a,  $0000,   $0013
        dw #obj_ptr_lamp,       $000b, $000e,  $1400,   $0000
        dw $ffff
    }
    
    ..2: {
        dw #obj_ptr_openwall,   $0000, $0000,  $0000,   $8000
        dw #obj_ptr_vent,       $0006, $001a,  $0000,   $0013
        dw #obj_ptr_vent,       $0014, $001a,  $0000,   $0033
        dw #obj_ptr_bigwindow,  $000a, $0006,  $0c00,   $0033
        dw $ffff
    }
    
    ..3: {
        ;dw #obj_ptr_manholetop,     $0008, $0001,  $0000,   $0000
        ;dw #obj_ptr_manholebottom,  $0008, $001a,  $0000,   $0000
        dw #obj_ptr_openwall,       $0000, $0000,  $0000,   $8000
        dw $ffff
    }
    
    ..4: {
        dw $ffff
    }

    ..5: {
        dw $ffff
    }

    ..6: {
        dw $ffff
    }

    ..7: {
        dw $ffff
    }

    ..8: {
        dw $ffff
    }

    ..9: {
        dw $ffff
    }

    ..a: {
        dw $ffff
    }

    ..b: {
        dw $ffff
    }

    ..c: {
        dw #obj_ptr_openwall,   $0000, $0000,  $0000,   $0000
        dw #obj_ptr_sewergrate, $0004, $001a,  $0800,   $0028
        dw #obj_ptr_sewergrate, $0018, $001a,  $0800,   $0050
        ;dw #obj_ptr_candle,     $0010, $0017,  $0000,   $0000
        ;dw #obj_ptr_liftrect,   $0010, $0008,  $0000,   $0007
        
        dw #obj_ptr_shelf,      $000c, $0011,  $0800,   $0001
        dw #obj_ptr_shelf,      $000d, $0012,  $0800,   $0002
        dw #obj_ptr_shelf,      $000e, $0013,  $0800,   $0003
        dw #obj_ptr_shelf,      $000f, $0014,  $0800,   $0004
        dw #obj_ptr_shelf,      $0010, $0015,  $0800,   $0005
        dw #obj_ptr_shelf,      $0011, $0016,  $0800,   $0006
        dw #obj_ptr_shelf,      $0012, $0017,  $0800,   $0007
        
        dw #obj_ptr_shelf,      $000c, $000a,  $0800,   $0001
        dw #obj_ptr_shelf,      $000d, $0009,  $0800,   $0002
        dw #obj_ptr_shelf,      $000e, $0008,  $0800,   $0003
        dw #obj_ptr_shelf,      $000f, $0007,  $0800,   $0004
        dw #obj_ptr_shelf,      $0010, $0006,  $0800,   $0005
        dw #obj_ptr_shelf,      $0011, $0005,  $0800,   $0006
        dw #obj_ptr_shelf,      $0012, $0004,  $0800,   $0007
        dw $ffff
    }

    ..d: {
        dw #obj_ptr_openwall,   $0000, $0000,  $0000,   $0000
        dw #obj_ptr_openwall,   $0000, $0000,  $0000,   $8000
        dw #obj_ptr_candle,     $000a, $0017,  $0800,   $0000
        dw #obj_ptr_liftrect,   $000a, $0014,  $0000,   $0003
        dw #obj_ptr_sewergrate, $0003, $001a,  $0800,   $0028
        dw #obj_ptr_sewergrate, $0013, $001a,  $0800,   $00a0
        dw #obj_ptr_sewergrate, $0018, $001a,  $0800,   $00a0
        dw #obj_ptr_cabinet,    $0010, $0003,  $0800,   $0003
        dw $ffff
    }

    ..e: {
        dw #obj_ptr_openwall,   $0000, $0000,  $0000,   $0000
        dw #obj_ptr_openwall,   $0000, $0000,  $0000,   $8000
        dw #obj_ptr_sewergrate, $0004, $001a,  $0800,   $0028
        dw #obj_ptr_sewergrate, $0018, $001a,  $0800,   $0028
        dw #obj_ptr_sewergrate, $0011, $001a,  $0800,   $0090
        dw #obj_ptr_cabinet,    $000d, $0003,  $0800,   $0003
        ;dw #obj_ptr_cabinet,    $0018, $0003,  $0800,   $0002
        ;dw #obj_ptr_candle,     $0010, $0017,  $0000,   $0000
        ;dw #obj_ptr_liftrect,   $0010, $0008,  $0000,   $0007
        dw $ffff
    }

    ..f: {
        dw #obj_ptr_openwall,   $0000, $0000,  $0000,   $0000
        dw #obj_ptr_openwall,   $0000, $0000,  $0000,   $8000
        dw #obj_ptr_candle,     $0010, $0017,  $0000,   $0000
        dw #obj_ptr_liftrect,   $0010, $0008,  $0000,   $0007
        dw $ffff
    }

    ..10: {
        dw #obj_ptr_openwall,   $0000, $0000,  $0000,   $0000
        dw #obj_ptr_openwall,   $0000, $0000,  $0000,   $8000
        dw #obj_ptr_candle,     $0010, $0017,  $0000,   $0000
        dw #obj_ptr_liftrect,   $0010, $0008,  $0000,   $0007
        dw $ffff
    }

    ..11: {
        dw #obj_ptr_openwall,   $0000, $0000,  $0000,   $0000
        dw #obj_ptr_openwall,   $0000, $0000,  $0000,   $8000
        dw #obj_ptr_candle,     $0010, $0017,  $0000,   $0000
        dw #obj_ptr_liftrect,   $0010, $0008,  $0000,   $0007
        dw $ffff
    }

    ..12: {
        dw #obj_ptr_openwall,   $0000, $0000,  $0000,   $0000
        dw #obj_ptr_openwall,   $0000, $0000,  $0000,   $8000
        dw #obj_ptr_manholetop, $0008, $0001,  $0000,   $0000
        dw #obj_ptr_candle,     $0010, $0017,  $0000,   $0000
        dw #obj_ptr_liftrect,   $0010, $0004,  $0000,   $000c
        dw $ffff
    }

    ..13: {
        dw $ffff
    }

    ..14: {
        dw $ffff
    }

    ..15: {
        dw $ffff
    }

    ..16: {
        dw $ffff
    }

    ..17: {
        dw $ffff
    }

    ..18: {
        dw $ffff
    }

    ..19: {
        dw $ffff
    }

    ..1a: {
        dw $ffff
    }

    ..1b: {
        dw $ffff
    }

    ..1c: {
        dw $ffff
    }

    ..1d: {
        dw $ffff
    }

    ..1e: {
        dw $ffff
    }

    ..1f: {
        dw $ffff
    }
    
;==================================================== SECOND FLOOR =======================================================

    ..20: {
        dw #obj_ptr_openwall,   $0000, $0000,  $0000,   $0000   ;30
        dw #obj_ptr_table,      $0004, $0011,  $0800,   $0000   ;2e
        dw #obj_ptr_dnstairs,   $0010, $0005,  $0400,   $0000   ;2c
        dw #obj_ptr_vent,       $0011, $001a,  $0000,   $0013   ;2a
        dw #obj_ptr_candle,     $0004, $000d,  $0800,   $0000   ;28
        dw $ffff
    }

    ..21: {
        ;dw #obj_ptr_shelf,      $0010, $0011,  $0800,   $0008
        dw #obj_ptr_openwall,   $0000, $0000,  $0000,   $8000
        dw #obj_ptr_openwall,   $0000, $0000,  $0000,   $0000
        
        dw #obj_ptr_cabinet,    $0010, $0010,  $0800,   $0002
        
        dw #obj_ptr_vent,       $0008, $001a,  $0000,   $0013
        dw #obj_ptr_vent,       $0013, $001a,  $0000,   $0013
        dw #obj_ptr_window,     $0008, $0008,  $0c00,   $0033
        dw #obj_ptr_ozma,       $0010, $0005,  $1000,   $0000
        dw $ffff
    }

    ..22: {
        dw #obj_ptr_openwall,   $0000, $0000,  $0000,   $0000
        dw #obj_ptr_openwall,   $0000, $0000,  $0000,   $8000
        dw #obj_ptr_vent,       $0008, $001a,  $0000,   $0013
        dw #obj_ptr_window,     $0010, $0008,  $0c00,   $0033
        dw #obj_ptr_candle,     $000f, $000f,  $0800,   $0000
        dw #obj_ptr_trashcan,   $000c, $0013,  $0800,   $0000
        dw #obj_ptr_cabinet,    $001a, $0004,  $0800,   $0001
        dw $ffff
    }

    ..23: {
        ;obj type               x      y       palette  variable
        dw #obj_ptr_openwall,   $0000, $0001,  $0000,   $0000
        dw #obj_ptr_openwall,   $0000, $0001,  $0000,   $8000
        dw #obj_ptr_upstairs,   $000e, $0005,  $0400,   $0000
        dw #obj_ptr_vent,       $0010, $001a,  $0000,   $0013
        dw #obj_ptr_vent,       $0003, $001a,  $0000,   $0078
        dw #obj_ptr_varitable,  $000d, $000b,  $0800,   $0402
        dw #obj_ptr_fishbowl,   $0018, $0010,  $0800,   $0010
        dw #obj_ptr_cabinet,    $0002, $0004,  $0800,   $0001
        dw $ffff
    }

    ..24: {
        dw #obj_ptr_openwall,   $0000, $0001,  $0000,   $0000
        dw #obj_ptr_openwall,   $0000, $0001,  $0000,   $8000
        dw #obj_ptr_vent,       $0010, $001a,  $0000,   $0028
        dw #obj_ptr_vent,       $0003, $001a,  $0000,   $0028
        dw #obj_ptr_varitable,  $0002, $000b,  $0800,   $0f02
        
        dw #obj_ptr_fishbowl,   $0006, $0010,  $0800,   $0010
        dw #obj_ptr_fishbowl,   $000d, $0010,  $0800,   $0010
        dw #obj_ptr_fishbowl,   $0012, $0010,  $0800,   $0010
        dw #obj_ptr_fishbowl,   $0018, $0010,  $0800,   $0010
        dw $ffff
    }

    ..25: {
        dw $ffff
    }

    ..26: {
        dw $ffff
    }

    ..27: {
        dw $ffff
    }

    ..28: {
        dw $ffff
    }

    ..29: {
        dw $ffff
    }

    ..2a: {
        dw $ffff
    }

    ..2b: {
        dw $ffff
    }

    ..2c: {
        dw $ffff
    }

    ..2d: {
        dw $ffff
    }

    ..2e: {
        dw $ffff
    }

    ..2f: {
        dw $ffff
    }

    ..30: {
        dw $ffff
    }

    ..31: {
        dw $ffff
    }

    ..32: {
        dw #obj_ptr_openwall,       $0000, $0001,  $0000,   $0000
        dw #obj_ptr_manholebottom,  $0008, $001a,  $0000,   $0000
        dw #obj_ptr_liftrect,       $0010, $0006,  $0000,   $000f
        dw $ffff
    }

    ..33: {
        dw #obj_ptr_openwall,       $0000, $0001,  $0000,   $0000
        dw #obj_ptr_openwall,       $0000, $0001,  $0000,   $8000
        dw $ffff
    }

    ..34: {
        dw #obj_ptr_openwall,       $0000, $0001,  $0000,   $0000
        dw #obj_ptr_openwall,       $0000, $0001,  $0000,   $8000
        dw $ffff
    }

    ..35: {
        dw #obj_ptr_openwall,       $0000, $0001,  $0000,   $0000
        dw #obj_ptr_openwall,       $0000, $0001,  $0000,   $8000
        dw $ffff
    }

    ..36: {
        dw #obj_ptr_openwall,       $0000, $0001,  $0000,   $0000
        dw #obj_ptr_openwall,       $0000, $0001,  $0000,   $8000
        dw #obj_ptr_upstairs,       $000e, $0005,  $0400,   $0000
        dw $ffff
    }

    ..37: {
        dw #obj_ptr_openwall,       $0000, $0001,  $0000,   $0000
        dw #obj_ptr_openwall,       $0000, $0001,  $0000,   $8000
        dw $ffff
    }

    ..38: {
        dw #obj_ptr_openwall,       $0000, $0001,  $0000,   $0000
        dw #obj_ptr_openwall,       $0000, $0001,  $0000,   $8000
        dw $ffff
    }

    ..39: {
        dw #obj_ptr_openwall,       $0000, $0001,  $0000,   $0000
        dw #obj_ptr_openwall,       $0000, $0001,  $0000,   $8000

        dw $ffff
    }

    ..3a: {
        dw #obj_ptr_openwall,       $0000, $0001,  $0000,   $8000
        dw $ffff
    }

    ..3b: {
        dw $ffff
    }

    ..3c: {
        dw $ffff
    }

    ..3d: {
        dw $ffff
    }

    ..3e: {
        dw $ffff
    }

    ..3f: {
        dw $ffff
    }
    
;==================================================== THIRD FLOOR =======================================================
    
    ..40: {
        dw $ffff
    }

    ..41: {
        dw $ffff
    }

    ..42: {
        dw #obj_ptr_openwall,   $0000, $0000,  $0000,   $0000
        dw #obj_ptr_upstairs,   $0014, $0005,  $0400,   $0000
        dw #obj_ptr_vent,       $0014, $001a,  $0000,   $0013
        dw #obj_ptr_shelf,      $0002, $000e,  $0800,   $0001
        
        dw #obj_ptr_solidrect,  $000d, $0000,  $0000,   $021f
        dw #obj_ptr_wall,       $000f, $0001,  $0000,   $8000   ;left
        dw #obj_ptr_wall,       $000a, $0001,  $0000,   $0008   ;right
        dw $ffff
    }

    ..43: {
        dw #obj_ptr_dnstairs,   $000e, $0005,  $0400,   $0000
        dw #obj_ptr_vent,       $000a, $001a,  $0000,   $0013
        dw #obj_ptr_openwall,   $0000, $0000,  $0000,   $8000
        dw #obj_ptr_openwall,   $0000, $0000,  $0000,   $0000
        dw $ffff
    }

    ..44: {
        dw #obj_ptr_openwall,   $0000, $0000,  $0000,   $8000   ;30
        dw #obj_ptr_openwall,   $0000, $0000,  $0000,   $0000   ;2e
        dw #obj_ptr_upstairs,   $000e, $0005,  $0400,   $0000   ;2c
        dw #obj_ptr_vent,       $0010, $001a,  $0000,   $0043   ;2a
        dw $ffff
    }

    ..45: {
        dw #obj_ptr_openwall,   $0001, $0001,  $0000,   $8000
        dw #obj_ptr_vent,       $0016, $001a,  $0000,   $0043
        dw #obj_ptr_vent,       $0003, $001a,  $0000,   $0018
        dw #obj_ptr_fireplace,  $0007, $000e,  $1000,   $0000
        ;dw #obj_ptr_liftrect,   $0007, $000e,  $0000,   $0b06
        dw $ffff
    }

    ..46: {
        dw $ffff
    }

    ..47: {
        dw $ffff
    }

    ..48: {
        dw $ffff
    }

    ..49: {
        dw $ffff
    }

    ..4a: {
        dw $ffff
    }

    ..4b: {
        dw $ffff
    }

    ..4c: {
        dw $ffff
    }

    ..4d: {
        dw $ffff
    }

    ..4e: {
        dw $ffff
    }

    ..4f: {
        dw $ffff
    }

    ..50: {
        ;dw #obj_ptr_openwall,       $0000, $0000,  $0000,   $8000
        dw #obj_ptr_openwall,       $0000, $0000,  $0000,   $0000
        dw $ffff
    }

    ..51: {
        dw #obj_ptr_openwall,       $0000, $0000,  $0000,   $8000
        dw #obj_ptr_openwall,       $0000, $0000,  $0000,   $0000
        dw $ffff
    }

    ..52: {
        dw #obj_ptr_openwall,       $0000, $0000,  $0000,   $8000
        dw #obj_ptr_openwall,       $0000, $0000,  $0000,   $0000
        dw $ffff
    }

    ..53: {
        dw #obj_ptr_openwall,       $0000, $0000,  $0000,   $8000
        dw #obj_ptr_openwall,       $0000, $0000,  $0000,   $0000
        dw $ffff
    }

    ..54: {
        dw #obj_ptr_openwall,       $0000, $0000,  $0000,   $8000
        dw #obj_ptr_openwall,       $0000, $0000,  $0000,   $0000
        dw #obj_ptr_bigwindow,      $0003, $0005,  $0c00,   $0000
        dw #obj_ptr_shelf,          $000e, $0013,  $0800,   $0002
        dw #obj_ptr_vent,           $0004, $001a,  $0000,   $0013
        dw #obj_ptr_vent,           $0017, $001a,  $0000,   $0013
        dw #obj_ptr_shelf,          $000e, $0008,  $0800,   $0002
        dw #obj_ptr_bigwindow,      $0014, $0005,  $0c00,   $0000
        dw $ffff
    }

    ..55: {
        dw #obj_ptr_openwall,       $0000, $0000,  $0000,   $8000
        dw #obj_ptr_openwall,       $0000, $0000,  $0000,   $0000
        
        dw #obj_ptr_ozma,           $0002, $0004,  $0400,   $0000
        dw #obj_ptr_ozma,           $0010, $0004,  $0800,   $0000
        dw #obj_ptr_ozma,           $0002, $000f,  $0c00,   $0000
        dw #obj_ptr_ozma,           $0010, $000f,  $1400,   $0000
        
        dw #obj_ptr_vent,           $000f, $001a,  $0000,   $0033
        dw $ffff
    }

    ..56: {
        dw #obj_ptr_openwall,       $0000, $0000,  $0000,   $8000
        dw #obj_ptr_dnstairs,       $000e, $0005,  $0400,   $0000
        dw #obj_ptr_vent,           $0006, $001a,  $0000,   $0013
        dw $ffff
    }

    ..57: {
        dw $ffff
    }

    ..58: {
        dw $ffff
    }

    ..59: {
        dw $ffff
    }

    ..5a: {
        dw $ffff
    }

    ..5b: {
        dw $ffff
    }

    ..5c: {
        dw $ffff
    }

    ..5d: {
        dw $ffff
    }

    ..5e: {
        dw $ffff
    }

    ..5f: {
        dw $ffff
    }
    
;==================================================== FOURTH FLOOR =======================================================
    
    ..60: {
        dw $ffff
    }

    ..61: {
        dw $ffff
    }

    ..62: {
        dw #obj_ptr_dnstairs,   $0012, $0005,  $0400,   $0000
        dw #obj_ptr_upstairs,   $0005, $0005,  $0400,   $0000
        dw #obj_ptr_vent,       $000e, $001a,  $0000,   $0013
        dw #obj_ptr_vent,       $0006, $001a,  $0000,   $0013
        dw $ffff
    }

    ..63: {
        dw #obj_ptr_openwall,   $0000, $0000,  $0000,   $0000
        dw #obj_ptr_vent,       $0008, $001a,  $0000,   $0013
        dw #obj_ptr_ozma,       $0006, $0005,  $1000,   $0000
        dw #obj_ptr_cabinet,    $0013, $0014,  $0800,   $0002
        dw $ffff
    }

    ..64: {
        dw #obj_ptr_vent,       $000c, $001a,  $0000,   $0013
        dw #obj_ptr_openwall,   $0000, $0000,  $0000,   $8000
        dw #obj_ptr_openwall,   $0000, $0000,  $0000,   $0000
        dw #obj_ptr_dnstairs,   $000c, $0005,  $0400,   $0000
        
        dw #obj_ptr_lamp,       $0007, $000e,  $1400,   $0000
        dw #obj_ptr_varitable,  $0002, $000b,  $0800,   $0603

        dw $ffff
    }

    ..65: {
        dw #obj_ptr_openwall,   $0000, $0000,  $0000,   $8000
        dw #obj_ptr_varitable,  $000b, $000b,  $0800,   $0402
        dw #obj_ptr_vent,       $0018, $001a,  $0000,   $0013
        dw #obj_ptr_vent,       $0003, $001a,  $0000,   $0013
        dw #obj_ptr_ozma,       $0010, $0005,  $1000,   $0000
        ;dw #obj_ptr_table,      $000d, $0010,  $0800,   $0000
        dw $ffff
    }

    ..66: {
        dw #obj_ptr_openwall,   $0000, $0000,  $0000,   $0000
        dw #obj_ptr_vent,       $0018, $001a,  $0000,   $0013
        dw #obj_ptr_dnstairs,   $0005, $0005,  $0800,   $0000
        dw $ffff
    }

    ..67: {
        dw #obj_ptr_openwall,   $0000, $0000,  $0000,   $8000
        dw #obj_ptr_openwall,   $0000, $0000,  $0000,   $0000
        dw #obj_ptr_vent,       $0018, $001a,  $0000,   $0013
        dw $ffff
    }

    ..68: {
        dw #obj_ptr_openwall,   $0000, $0000,  $0000,   $8000
        dw #obj_ptr_openwall,   $0000, $0000,  $0000,   $0000
        dw #obj_ptr_vent,       $0018, $001a,  $0000,   $0013
        dw #obj_ptr_bigwindow,  $0006, $0006,  $0000,   $0002
        dw $ffff
    }

    ..69: {
        dw #obj_ptr_openwall,   $0000, $0000,  $0000,   $8000
        dw #obj_ptr_openwall,   $0000, $0000,  $0000,   $0000
        dw #obj_ptr_vent,       $0010, $001a,  $0000,   $0013
        dw #obj_ptr_ozma,       $0006, $0006,  $0400,   $0000
        dw #obj_ptr_varitable,  $0006, $000b,  $0000,   $0804
        dw #obj_ptr_trashcan,   $0006, $0015,  $0000,   $0000
        dw $ffff
    }

    ..6a: {
        dw #obj_ptr_openwall,   $0000, $0000,  $0000,   $8000
        dw #obj_ptr_openwall,   $0000, $0000,  $0000,   $0000
        dw #obj_ptr_vent,       $0016, $001a,  $0000,   $0013
        dw #obj_ptr_candle,     $0010, $000b,  $0000,   $0000
        dw $ffff
    }

    ..6b: {
        dw #obj_ptr_openwall,   $0000, $0000,  $0000,   $8000
        dw #obj_ptr_openwall,   $0000, $0000,  $0000,   $0000
        dw #obj_ptr_vent,       $0014, $001a,  $0000,   $0023
        dw #obj_ptr_vent,       $0004, $001a,  $0000,   $0023
        dw #obj_ptr_cabinet,    $000d, $0003,  $0400,   $0001
        dw #obj_ptr_cabinet,    $000c, $0004,  $0800,   $0001
        dw #obj_ptr_cabinet,    $000b, $0005,  $0c00,   $0001
        dw #obj_ptr_cabinet,    $000a, $0006,  $1000,   $0001
        dw #obj_ptr_bigwindow,  $000a, $0006,  $0000,   $0002
        dw #obj_ptr_bigwindow,  $000c, $0008,  $0c00,   $0002
        
        dw $ffff
    }

    ..6c: {
        dw #obj_ptr_openwall,   $0000, $0000,  $0000,   $8000
        dw #obj_ptr_upstairs,   $0005, $0005,  $0c00,   $0000
        dw #obj_ptr_vent,       $0008, $001a,  $0000,   $0013
        dw #obj_ptr_varitable,  $001a, $000a,  $0800,   $0503
        dw $ffff
    }

    ..6d: {
        dw $ffff
    }

    ..6e: {
        dw $ffff
    }

    ..6f: {
        dw $ffff
    }
    
    ..70: {
        dw $ffff
    }

    ..71: {
        dw $ffff
    }

    ..72: {
        dw $ffff
    }

    ..73: {
        dw $ffff
    }

    ..74: {
        dw $ffff
    }

    ..75: {
        dw $ffff
    }

    ..76: {
        dw $ffff
    }

    ..77: {
        dw $ffff
    }

    ..78: {
        dw $ffff
    }

    ..79: {
        dw $ffff
    }

    ..7a: {
        dw $ffff
    }

    ..7b: {
        dw $ffff
    }

    ..7c: {
        dw $ffff
    }

    ..7d: {
        dw $ffff
    }

    ..7e: {
        dw $ffff
    }

    ..7f: {
        dw $ffff
    }
    
;==================================================== FIFTH FLOOR =======================================================
    
    ..80: {
        dw $ffff
    }

    ..81: {
        dw #obj_ptr_openwall,   $0000, $0001,  $0000,   $0000
        dw #obj_ptr_vent,       $0013, $001a,  $0000,   $0013
        dw #obj_ptr_solidrect,  $000d, $0000,  $0000,   $021f
        dw $ffff
    }

    ..82: {
        dw #obj_ptr_openwall,   $0000, $0001,  $0000,   $8000
        dw #obj_ptr_dnstairs,   $0005, $0005,  $0400,   $0000
        dw #obj_ptr_openwall,   $0000, $0000,  $0000,   $0000
        dw #obj_ptr_vent,       $0003, $001a,  $0000,   $0013
        dw #obj_ptr_vent,       $0013, $001a,  $0000,   $0023
        dw #obj_ptr_vent,       $0019, $001a,  $0000,   $0023
        dw #obj_ptr_cabinet,    $0015, $000c,  $0800,   $0003
        ;dw #obj_ptr_varitable,  $0006, $000b,  $0800,   $0803
        dw $ffff
    }

    ..83: {
        dw #obj_ptr_vent,       $0009, $001a,  $0000,   $0013
        dw #obj_ptr_openwall,   $0000, $0000,  $0000,   $0000
        dw #obj_ptr_varitable,  $0002, $0007,  $0800,   $040a
        ;dw #obj_ptr_cabinet,    $0002, $000c,  $0800,   $0003
        dw $ffff
    }

    ..84: {
        dw #obj_ptr_vent,       $0008, $001a,  $0000,   $0013
        dw #obj_ptr_openwall,   $0000, $0000,  $0000,   $0000
        dw #obj_ptr_openwall,   $0000, $0000,  $0000,   $8000
        dw $ffff
    }

    ..85: {
        dw #obj_ptr_openwall,   $0000, $0000,  $0000,   $8000
        dw #obj_ptr_openwall,   $0000, $0000,  $0000,   $0000
        dw #obj_ptr_vent,       $000a, $001a,  $0000,   $0013
        dw #obj_ptr_shelf,      $0012, $0013,  $0800,   $0007
        dw #obj_ptr_shelf,      $0012, $0017,  $0800,   $0007
        dw $ffff
    }

    ..86: {
        dw #obj_ptr_openwall,   $0000, $0000,  $0000,   $8000
        dw #obj_ptr_vent,       $000d, $001a,  $0000,   $0018
        dw $ffff
    }

    ..87: {
        dw #obj_ptr_openwall,   $0000, $0000,  $0000,   $8000
        dw #obj_ptr_openwall,   $0000, $0000,  $0000,   $0000
        dw #obj_ptr_vent,       $0005, $001a,  $0000,   $0018
        dw #obj_ptr_vent,       $0012, $001a,  $0000,   $0018
        dw $ffff
    }

    ..88: {
        dw #obj_ptr_openwall,   $0000, $0000,  $0000,   $8000
        dw #obj_ptr_openwall,   $0000, $0000,  $0000,   $0000
        dw #obj_ptr_vent,       $0005, $001a,  $0000,   $0018
        dw #obj_ptr_vent,       $0012, $001a,  $0000,   $0018
        dw $ffff
    }

    ..89: {
        dw #obj_ptr_openwall,   $0000, $0000,  $0000,   $8000
        dw #obj_ptr_openwall,   $0000, $0000,  $0000,   $0000
        dw #obj_ptr_vent,       $0005, $001a,  $0000,   $0018
        dw #obj_ptr_vent,       $0012, $001a,  $0000,   $0018
        dw $ffff
    }

    ..8a: {
        dw #obj_ptr_openwall,   $0000, $0000,  $0000,   $8000
        dw #obj_ptr_openwall,   $0000, $0000,  $0000,   $0000
        dw #obj_ptr_vent,       $0005, $001a,  $0000,   $0018
        dw #obj_ptr_vent,       $0012, $001a,  $0000,   $0018
        dw $ffff
    }

    ..8b: {
        dw #obj_ptr_openwall,   $0000, $0000,  $0000,   $8000
        dw #obj_ptr_openwall,   $0000, $0000,  $0000,   $0000
        dw #obj_ptr_vent,       $0005, $001a,  $0000,   $0018
        dw #obj_ptr_vent,       $0012, $001a,  $0000,   $0018
        dw $ffff
    }

    ..8c: {
        dw #obj_ptr_openwall,   $0000, $0000,  $0000,   $8000
        dw #obj_ptr_dnstairs,   $0005, $0005,  $0c00,   $0000
        dw #obj_ptr_bigwindow,  $0012, $0006,  $0c00,   $0000
        dw #obj_ptr_vent,       $0005, $001a,  $0000,   $0018
        dw #obj_ptr_vent,       $0012, $001a,  $0000,   $0018
        dw $ffff
    }

    ..8d: {
        dw $ffff
    }

    ..8e: {
        dw $ffff
    }

    ..8f: {
        dw $ffff
    }
    
    ..90: {
        dw $ffff
    }

    ..91: {
        dw $ffff
    }

    ..92: {
        dw $ffff
    }

    ..93: {
        dw $ffff
    }

    ..94: {
        dw $ffff
    }

    ..95: {
        dw $ffff
    }

    ..96: {
        dw $ffff
    }

    ..97: {
        dw $ffff
    }

    ..98: {
        dw $ffff
    }

    ..99: {
        dw $ffff
    }

    ..9a: {
        dw $ffff
    }

    ..9b: {
        dw $ffff
    }

    ..9c: {
        dw $ffff
    }

    ..9d: {
        dw $ffff
    }

    ..9e: {
        dw $ffff
    }

    ..9f: {
        dw $ffff
    }
    
    ..a0: {
        dw $ffff
    }

    ..a1: {
        dw $ffff
    }

    ..a2: {
        dw $ffff
    }

    ..a3: {
        dw $ffff
    }

    ..a4: {
        dw $ffff
    }

    ..a5: {
        dw $ffff
    }

    ..a6: {
        dw $ffff
    }

    ..a7: {
        dw $ffff
    }

    ..a8: {
        dw $ffff
    }

    ..a9: {
        dw $ffff
    }

    ..aa: {
        dw $ffff
    }

    ..ab: {
        dw $ffff
    }

    ..ac: {
        dw $ffff
    }

    ..ad: {
        dw $ffff
    }

    ..ae: {
        dw $ffff
    }

    ..af: {
        dw $ffff
    }
    
    ..b0: {
        dw $ffff
    }

    ..b1: {
        dw $ffff
    }

    ..b2: {
        dw $ffff
    }

    ..b3: {
        dw $ffff
    }

    ..b4: {
        dw $ffff
    }

    ..b5: {
        dw $ffff
    }

    ..b6: {
        dw $ffff
    }

    ..b7: {
        dw $ffff
    }

    ..b8: {
        dw $ffff
    }

    ..b9: {
        dw $ffff
    }

    ..ba: {
        dw $ffff
    }

    ..bb: {
        dw $ffff
    }

    ..bc: {
        dw $ffff
    }

    ..bd: {
        dw $ffff
    }

    ..be: {
        dw $ffff
    }

    ..bf: {
        dw $ffff
    }
    
    ..c0: {
        dw $ffff
    }

    ..c1: {
        dw $ffff
    }

    ..c2: {
        dw $ffff
    }

    ..c3: {
        dw $ffff
    }

    ..c4: {
        dw $ffff
    }

    ..c5: {
        dw $ffff
    }

    ..c6: {
        dw $ffff
    }

    ..c7: {
        dw $ffff
    }

    ..c8: {
        dw $ffff
    }

    ..c9: {
        dw $ffff
    }

    ..ca: {
        dw $ffff
    }

    ..cb: {
        dw $ffff
    }

    ..cc: {
        dw $ffff
    }

    ..cd: {
        dw $ffff
    }

    ..ce: {
        dw $ffff
    }

    ..cf: {
        dw $ffff
    }
    
    ..d0: {
        dw $ffff
    }

    ..d1: {
        dw $ffff
    }

    ..d2: {
        dw $ffff
    }

    ..d3: {
        dw #obj_ptr_dnstairs,   $0006, $0005,  $0400,   $0000
        dw #obj_ptr_vent,       $0005, $001a,  $0000,   $0018
        dw #obj_ptr_openwall,   $0000, $0000,  $0000,   $0000
        dw $ffff
    }

    ..d4: {
        dw #obj_ptr_openwall,       $0000, $0000,  $0000,   $8000
        dw #obj_ptr_vent,           $0005, $001a,  $0000,   $0018
        dw #obj_ptr_openwindow,     $000c, $0005,  $0c00,   $0000
        dw #obj_ptr_windowtouchbox, $000d, $000e,  $0000,   $0000
        dw #obj_ptr_table,          $0012, $0010,  $0800,   $0000
        dw $ffff
    }

    ..d5: {
        dw $ffff
    }

    ..d6: {
        dw $ffff
    }

    ..d7: {
        dw $ffff
    }

    ..d8: {
        dw $ffff
    }

    ..d9: {
        dw $ffff
    }

    ..da: {
        dw $ffff
    }

    ..db: {
        dw $ffff
    }

    ..dc: {
        dw $ffff
    }

    ..dd: {
        dw $ffff
    }

    ..de: {
        dw $ffff
    }

    ..df: {
        dw $ffff
    }
    
    ..e0: {
        dw $ffff
    }

    ..e1: {
        dw $ffff
    }

    ..e2: {
        dw $ffff
    }

    ..e3: {
        dw $ffff
    }

    ..e4: {
        dw $ffff
    }

    ..e5: {
        dw $ffff
    }

    ..e6: {
        dw $ffff
    }

    ..e7: {
        dw $ffff
    }

    ..e8: {
        dw $ffff
    }

    ..e9: {
        dw $ffff
    }

    ..ea: {
        dw $ffff
    }

    ..eb: {
        dw $ffff
    }

    ..ec: {
        dw $ffff
    }

    ..ed: {
        dw $ffff
    }

    ..ee: {
        dw $ffff
    }

    ..ef: {
        dw $ffff
    }
    
    ..f0: {
        dw $ffff
    }

    ..f1: {
        dw $ffff
    }

    ..f2: {
        dw $ffff
    }

    ..f3: {
        dw $ffff
    }

    ..f4: {
        dw $ffff
    }

    ..f5: {
        dw $ffff
    }

    ..f6: {
        dw $ffff
    }

    ..f7: {
        dw $ffff
    }

    ..f8: {
        dw $ffff
    }

    ..f9: {
        dw $ffff
    }

    ..fa: {
        dw $ffff
    }

    ..fb: {
        dw $ffff
    }

    ..fc: {
        dw $ffff
    }

    ..fd: {
        dw $ffff
    }

    ..fe: {
        dw $ffff
    }

    ..ff: {
        dw #obj_ptr_liftrect,   $0000, $000e,  $0000,   $1f06
        dw $ffff
    }
}