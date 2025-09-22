
.enemylist: {
    ..0: {
        ;enemy type             x,        y,        property,  prop2,       property3
        dw enemy_ptr_duct,      $0020,    $0008,    $9021,      $8004,      $0000
        dw $ffff                                                 
    }                                                            
                                                                 
    ..1: {                                                       
        dw enemy_ptr_bandspack, $0040,    $0058,    $0000,      $0000,      $0001
        dw $ffff
    }
    
    ..2: {
        dw enemy_ptr_copter,    $0090,    $0040,    $00a0,      $0000,      $00a0
        dw enemy_ptr_copter,    $0090,    $0040,    $00a0,      $0100,      $00a0
        dw $ffff
    }
    
    ..3: {
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
        ;enemy type                 x,      y,      property,   prop2,  property3
        dw enemy_ptr_balloon,       $0070,  $00d0,  $191f,      $3002,  $0000
        dw enemy_ptr_dart,          $00c0,  $0020,  $0000,      $6000,  $1800
        dw $ffff
    }
    
    ..d: {
        dw enemy_ptr_copter,        $00a0,  $0020,  $00a0,      $0100,  $00a0
        dw enemy_ptr_balloon,       $0088,  $00d0,  $191f,      $3002,  $0000
        dw enemy_ptr_balloon,       $00a8,  $0048,  $0f1f,      $1002,  $0000
        dw $ffff
    }
    
    ..e: {
        dw enemy_ptr_drip,          $0050,  $0010,  $0141,      $0002,  $0800
        dw enemy_ptr_drip,          $0068,  $0010,  $0170,      $0002,  $2000
        dw enemy_ptr_drip,          $0089,  $0010,  $0079,      $0002,  $4000
        dw enemy_ptr_drip,          $0090,  $0010,  $017a,      $0002,  $7f00
        dw enemy_ptr_drip,          $0098,  $0010,  $00a3,      $0002,  $2900
        dw $ffff
    }
    
    ..f: {
        dw $ffff
    }
    
    ..10: {
        dw $ffff
    }
    
    ..11: {
        dw $ffff
    }
    
    ..12: {
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
    
    ..20: {
        ;enemy type                 x,        y,       property,    property2,         property3
        dw enemy_ptr_balloon,       $0058,    $0048,   $1234,       $f002,             $0000
        dw enemy_ptr_balloon,       $0038,    $0048,   $031f,       $1002,             $0000
        dw enemy_ptr_balloon,       $0018,    $0028,   $0cf0,       $1002,             $0000
        dw enemy_ptr_clock,         $0048,    $0060,   $01f4,       $0006,             $0001
        dw enemy_ptr_paper,         $0038,    $0070,   $0000,       $0006,             $0002
        dw enemy_ptr_lightswitch,   $0060,    $0060,   $0000,       $0004,             $0000
        dw enemy_ptr_switch,        $0060,    $0040,   $0013,       $0200,             $0030|$0001      ;room 0, object $30
        dw $ffff                                      
    }                                                 
                                                      
    ..21: {       
        dw enemy_ptr_copter,        $00a0,    $0040,   $01a0,       $0100,             $00a0
        dw enemy_ptr_balloon,       $0060,    $0028,   $0f80,       $3002,             $0000
        dw enemy_ptr_battery,       $0070,    $0070,   $0064,       $0006,             $0001
        dw enemy_ptr_duct,          $0090,    $0008,   $2000,       $8004,             $0000
        dw enemy_ptr_switch,        $0068,    $0060,   $4000,       $0200,             $2028
        dw $ffff
    }
    
    ..22: {
        dw enemy_ptr_drip,          $0060,    $0008,   $0070,       $0002,             $0000
        dw enemy_ptr_balloon,       $0060,    $0028,   $0f80,       $3002,             $0000
        dw enemy_ptr_copter,        $00a0,    $0020,   $00a0,       $0100,             $00a0
        ;dw enemy_ptr_foil,          $0050,    $0058,   $0070,       $0002,             $0000
        dw $ffff
    }
    
    ..23: {
        dw enemy_ptr_copter,        $0020,    $0028,   $00a0,       $0000,             $00a0
        dw $ffff
    }
    
    ..24: {
        ;enemy type                 x,        y,       property,    property2,         property3
        dw enemy_ptr_drip,          $0040,    $0010,   $0090,       $0002,             $f000
        dw enemy_ptr_drip,          $0068,    $0010,   $0020,       $0002,             $8000
        dw enemy_ptr_drip,          $0090,    $0010,   $0040,       $0002,             $4000
        dw enemy_ptr_drip,          $00c0,    $0010,   $0080,       $0002,             $0000
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
        dw $ffff
    }
    
    ..33: {
        dw $ffff
    }
    
    ..34: {
        dw $ffff
    }
    
    ..35: {
        dw $ffff
    }
    
    ..36: {
        dw $ffff
    }
    
    ..37: {
        dw $ffff
    }
    
    ..38: {
        dw $ffff
    }
    
    ..39: {
        dw $ffff
    }
    
    ..3a: {
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
    
    ..40: {
        dw $ffff
    }
    
    ..41: {
        dw $ffff
    }
    
    ..42: {
        dw enemy_ptr_paper,         $0024,    $0058,    $0000,  $0006,  $0001
        dw enemy_ptr_battery,       $0020,    $0078,    $0000,  $0006,  $0002
        ;these ducts are not yet linked!
        dw enemy_ptr_duct,          $0028,    $0008,    $0000,  $8004,  $0000
        dw enemy_ptr_duct,          $002a,    $00c8,    $0000,  $0004,  $0000
        dw $ffff
    }
    
    ..43: {
        dw $ffff
    }
    
    ..44: {
        dw $ffff
    }
    
    ..45: {
        ;dw enemy_ptr_bandspack,     $0040,    $0058,    $0000,  $0000,  $0001
        dw enemy_ptr_clock,         $007a,    $0048,    $01f4,  $0006,  $0002
        dw enemy_ptr_paper,         $0058,    $0058,    $0000,  $0006,  $0004
        dw enemy_ptr_paper,         $0098,    $0058,    $0000,  $0006,  $0008
        dw enemy_ptr_lightswitch,   $00d0,    $0048,    $0000,  $0004,  $0000
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
        dw $ffff
    }
    
    ..51: {
        dw $ffff
    }
    
    ..52: {
        dw $ffff
    }
    
    ..53: {
        dw $ffff
    }
    
    ..54: {
        dw $ffff
    }
    
    ..55: {
        dw $ffff
    }
    
    ..56: {
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
    
    ..60: {
        dw $ffff
    }
    
    ..61: {
        dw $ffff
    }
    
    ..62: {
        dw $ffff
    }
    
    ..63: {
        dw $ffff
    }
    
    ..64: {
        ;dw enemy_ptr_bandspack,        $0040,    $0058,     $0000,        $0000,           $0001
        dw $ffff
    }
    
    ..65: {
        dw $ffff
    }
    
    ..66: {
        dw $ffff
    }
    
    ..67: {
        dw $ffff
    }
    
    ..68: {
        dw $ffff
    }
    
    ..69: {
        dw $ffff
    }
    
    ..6a: {
        dw $ffff
    }
    
    ..6b: {
        dw $ffff
    }
    
    ..6c: {
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
    
    ..80: {
        dw $ffff
    }

    ..81: {
        ;enemy type             x,        y,        property,   prop2,      property3
        dw enemy_ptr_balloon,   $0018,    $0028,    $0cf0,      $1002,      $0000
        dw enemy_ptr_duct,      $00d0,    $00c8,    $200c,      $0004,      $0000
        dw $ffff
    }

    ..82: {
        dw $ffff
    }

    ..83: {
        dw $ffff
    }

    ..84: {
        dw $ffff
    }

    ..85: {
        dw $ffff
    }

    ..86: {
        dw $ffff
    }

    ..87: {
        dw $ffff
    }

    ..88: {
        dw $ffff
    }

    ..89: {
        dw $ffff
    }

    ..8a: {
        dw $ffff
    }

    ..8b: {
        dw $ffff
    }

    ..8c: {
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
        dw $ffff
    }

    ..d4: {
        ;cat room
        ;enemy type                    x,            y,     property,   property2,  property3
        dw enemy_ptr_catbody,          $0080+$28,    $0065, $0070,      $0000,      $0000
        dw enemy_ptr_catpaw,           $0050+$28,    $006d, $0070,      $0000,      $0000
        dw enemy_ptr_cattail,          $0088+$28,    $007d, $0070,      $0000,      $0000
        dw $ffff
    }
    
    ;ending section
    ..d5: {
        dw enemy_ptr_cutscenehandler,   $0000,      $0000,  $0000,      $0000,      $0000
        dw enemy_ptr_gfxloader,         $0000,      $0000,  $0000,      $0000,      $0000
        dw $ffff
    }

    ..d6: {
        dw enemy_ptr_cutscenehandler,   $0000,      $0000,  $0000,      $0000,      $0000
        dw $ffff
    }

    ..d7: {
        dw enemy_ptr_cutscenehandler,   $0000,      $0000,  $0000,      $0000,      $0000
        dw $ffff
    }

    ..d8: {
        dw enemy_ptr_cutscenehandler,   $0000,      $0000,  $0000,      $0000,      $0000
        dw $ffff
    }

    ..d9: {
        dw enemy_ptr_cutscenehandler,   $0000,      $0000,  $8000,      $0000,      $0000
        dw enemy_ptr_star,              $00a2,      $0011,  $0000,      $0000,      $0000
        
        ;dw enemy_ptr_teddy,             $0052,      $0011,  $0000,      $0000,      $0000
        dw enemy_ptr_samantha,          $0052,      $0011,  $0000,      $0000,      $0000
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
        dw $ffff
    }
}

