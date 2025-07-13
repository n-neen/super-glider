lorom


org $838000

;===========================================================================================
;=============================    R O O M    L O A D I N G    ==============================
;===========================================================================================



room: {
    .load: {
        ;takes input:
            ;room pointer
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
        
        
        
        
        rtl
    }


;room bounds:
;$0001   right bound
;$1000   left bound


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
            dw room_objlist_0, room_enemylist_0, $0000, $1000
        }
        
        ..1: {
            dw room_objlist_1, room_enemylist_1, $0001, $0000
        }
        
        ..2: {
            dw room_objlist_2, room_enemylist_2, $0000, $0001
        }
        
        ..3: {
            dw room_objlist_3, room_enemylist_3, $0000, $1001
        }
    }


    .objlist: { ;obj type        x      y
        ..0: {
            dw #obj_ptr_vent,    $0006, $001a
            dw #obj_ptr_table,   $0010, $0011
            dw #obj_ptr_vent,    $0018, $001a
            dw $ffff
        }
        
        ..1: {
            dw #obj_ptr_vent,    $0006, $001a
            dw #obj_ptr_fanR,    $0006, $001a
            dw $ffff
        }
        
        ..2: {
            dw #obj_ptr_vent,    $0006, $001a
            dw #obj_ptr_vent,    $0014, $001a
            dw $ffff
        }
        
        ..3: {
            dw #obj_ptr_vent,    $0014, $001a
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