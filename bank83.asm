lorom


org $838000

;===========================================================================================
;=============================    R O O M    L O A D I N G    ==============================
;===========================================================================================



room: {
    .load: {
        ;number of bytes into the room header the thing is
        ;basically just a fancy lda $0000,x
        !kroomobjlist               =       $0000
        !kroomenemylist             =       $0002
        !kroombgtype                =       $0004
        !kroombounds                =       $0006

        ;argument:
            ;room pointer in !roomptr
        ;produces output:
            ;load object list
                ;draw objects (obj_draw)
            ;load background (layer 2)
            ;load enemies [also prizes]
        
            ;load room ptr
            ;load obj list
            ;load objects [loop]
            ;load enemy list
            ;load enemies [loop]
        
        phb
        phx
        phy
        
        phk
        plb
        
        jsl obj_clearall
        jsl obj_tilemap_init
        
        ldx !roomptr
        
        lda !kroombgtype,x
        jsl load_background     ;load background type from room header
        
        lda !kroomobjlist,x
        jsl obj_spawnall        ;make all objects from object list
        
        jsl layer2draw          ;make sure to update layer 2 tilemap
                                ;since nmi does not
        
        ply
        plx
        plb
        rtl
    }


;room bounds:
;$1000      left bound
;$0001      right bound
;$0100      up bound
;$0010      down bound

;===========================================================================================
;=========================    H O U S E   F O R M A T   ====================================
;===========================================================================================
    
    
    
    .list: {    ;room list
        dw room_entry_0,
           room_entry_1,
           room_entry_2,
           room_entry_3
    }


    .entry: {    ;objs         enemies           bg     bounds
        ..0: {
            dw room_objlist_0, room_enemylist_0, $0003, $1000
        }
        
        ..1: {
            dw room_objlist_1, room_enemylist_1, $0002, $0000
        }
        
        ..2: {
            dw room_objlist_2, room_enemylist_2, $0003, $0001
        }
        
        ..3: {
            dw room_objlist_3, room_enemylist_3, $0002, $1001
        }
    }

                ;!kobjectentrylength in defines.asm!
    .objlist: { ;obj type           x      y       palette  variable
        ..0: {                                              ;like room ptr for stairs, or vent height
            dw #obj_ptr_vent,       $0006, $001a,  $0800,   $0050
            ;dw #obj_ptr_table,      $0010, $0011,  $0800,   $0000
            dw #obj_ptr_vent,       $0018, $001a,  $0800,   $0020
            dw #obj_ptr_upstairs,   $0010, $0005,  $0400,   $0000
            dw $ffff
        }
        
        ..1: {
            dw #obj_ptr_vent,       $0006, $001a,  $0800,   $0000
            dw #obj_ptr_fanR,       $0010, $0014,  $0800,   $0000
            dw $ffff
        }
        
        ..2: {
            dw #obj_ptr_vent,       $0006, $001a,  $0400,   $0000
            dw #obj_ptr_vent,       $0014, $001a,  $0800,   $0000
            dw $ffff
        }
        
        ..3: {
            dw #obj_ptr_vent,       $0014, $001a,  $0800,   $0000
            dw $ffff
        }
    }


    .enemylist: {
        ..0: dw $ffff
        ..1: dw $ffff
        ..2: dw $ffff
        ..3: dw $ffff
    }
}