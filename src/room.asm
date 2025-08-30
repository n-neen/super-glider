lorom


;org $838000

;===========================================================================================
;=============================    R O O M    L O A D I N G    ==============================
;===========================================================================================

!roombanklong        =   room&$ff0000
!roombankword        =   !roombanklong>>8
!roombankshort       =   !roombanklong>>16

room: {
    .load: {
        ;number of bytes into the room header the thing is
        ;roomobjlist               =       $0000
        ;roomenemylist             =       $0002
        ;roombgtypebounds          =       $0004   ;bg is low byte, bounds is high byte
        ;roomroutineptr            =       $0006
        
        ;argument:
            ;room pointer in !roomptr

        
        phb
        phx
        phy
        
        phk
        plb
        
        sep #$20
        stz $4200               ;disable interrupts
        rep #$20
        
        jsl obj_clearall
        ;jsl obj_tilemap_init
        
        ldx !roomptr
        
        lda $0000,x
        sta !roomobjlistptr
        
        lda $0002,x
        sta !roomenemylistptr
        
        lda $0004,x
        and #$ff00
        xba
        sta !roombounds
        
        lda $0006,x
        sta !roomroutineptr
        
        lda $0004,x
        and #$00ff
        sta !roombg
        jsl load_background     ;relies on contents of A
        
        
        jsl obj_spawnall
        jsl obj_handle
        jsl obj_drawall
        jsl obj_tilemap_requestupdate
        jsl layer2draw          ;make sure to update layer 2 tilemap
                                ;since nmi does not
                                
        jsl oam_fillbuffer
        jsl glider_draw
        jsl enemy_spawnall
        jsl enemy_runinit
        
        jsl link_handle
                
        sep #$20
        lda #$80
        sta $4200               ;enable interrupts
        rep #$20
        
        ply
        plx
        plb
        rtl
    }
    
    .transition: {
        phb
        
        phk
        plb
        
        lda !roomtranstype
        sta !gliderstairstype           ;save this
        asl
        tax
        jsr (room_transition_table,x)
        
        lda !roomindex
        asl
        tax
        lda room_list,x
        sta !roomptr
        
        jsl enemy_clearall
        stz !oamentrypoint
        ;jsl oam_cleantable
        jsl oam_fillbuffer
        
        plb
        rtl
        
        ..table: {
            dw room_transition_right,
               room_transition_left,
               room_transition_up,
               room_transition_down,
               room_transition_duct
        }
        
        ..duct: {
            lda !kceiling+$10
            sta !glidery
            
            lda !ductoutputxpos
            sta !gliderx
            
            lda !gliderx
            sta !gliderrespawnx
            
            lda #$0020
            sta !gliderrespawny
            
            lda !ktranstimer
            sta !glidertranstimer
            sta !gliderstairstimer
            rts
        }
        
        ..right: {
            ;also this will determine output position
            lda !roomindex
            clc
            adc #$0001
            sta !roomindex
            
            lda !kleftbound+7
            sta !gliderx
            
            lda !glidery
            sta !gliderrespawny
            
            lda !gliderx
            sta !gliderrespawnx
            
            lda !ktranstimer
            sta !glidertranstimer
            
            rts
        }
        
        ..left: {
            lda !roomindex
            sec
            sbc #$0001
            sta !roomindex
            
            lda !krightbound-7
            sta !gliderx
            
            lda !glidery
            sta !gliderrespawny
            
            lda !gliderx
            sta !gliderrespawnx
            
            lda !ktranstimer
            sta !glidertranstimer
            
            rts
        }
        
        ..up: {
            lda !roomindex
            clc
            adc #$0020
            sta !roomindex
            
            lda !kfloor-$40
            sta !glidery
            
            lda !gliderx
            sta !gliderrespawnx
            
            lda #$0040
            sta !gliderrespawny
            
            lda !ktranstimer
            sta !glidertranstimer
            sta !gliderstairstimer
            
            rts
        }
        
        ..down: {
            lda !roomindex
            sec
            sbc #$0020
            sta !roomindex
            
            lda !kceiling+$28
            sta !glidery
            
            lda !gliderx
            sta !gliderrespawnx
            
            lda #$0040
            sta !gliderrespawny
            
            lda !ktranstimer
            sta !glidertranstimer
            sta !gliderstairstimer
            
            rts
        }

    }
    



;bounds, background field:
;#%000000lrgggggggg
;g = background type
;l = left bound
;r = right bound

;===========================================================================================
;=========================    H O U S E   F O R M A T   ====================================
;===========================================================================================

;the maximum room index supported is $ff. room link table entries would have to be changed
;in order to support more than that.
;todo: document what would need to be changed 
    

    .list: {    ;room list
        
        ;todo: macro this?
        
        dw room_entry_0,        ;first floor
           room_entry_1,
           room_entry_2,
           room_entry_3,
           room_entry_4,
           room_entry_5,
           room_entry_6,
           room_entry_7,
           room_entry_8,
           room_entry_9,
           room_entry_a,
           room_entry_b,
           room_entry_c,
           room_entry_d,
           room_entry_e,
           room_entry_f,
           room_entry_10,
           room_entry_11,
           room_entry_12,
           room_entry_13,
           room_entry_14,
           room_entry_15,
           room_entry_16,
           room_entry_17,
           room_entry_18,
           room_entry_19,
           room_entry_1a,
           room_entry_1b,
           room_entry_1c,
           room_entry_1d,
           room_entry_1e,
           room_entry_1f
           
        dw room_entry_20,       ;second floor
           room_entry_21,
           room_entry_22,
           room_entry_23,
           room_entry_24,
           room_entry_25,
           room_entry_26,
           room_entry_27,
           room_entry_28,
           room_entry_29,
           room_entry_2a,
           room_entry_2b,
           room_entry_2c,
           room_entry_2d,
           room_entry_2e,
           room_entry_2f,
           room_entry_30,
           room_entry_31,
           room_entry_32,
           room_entry_33,
           room_entry_34,
           room_entry_35,
           room_entry_36,
           room_entry_37,
           room_entry_38,
           room_entry_39,
           room_entry_3a,
           room_entry_3b,
           room_entry_3c,
           room_entry_3d,
           room_entry_3e,
           room_entry_3f
           
        dw room_entry_40,       ;third floor
           room_entry_41,
           room_entry_42,
           room_entry_43,
           room_entry_44,
           room_entry_45,
           room_entry_46,
           room_entry_47,
           room_entry_48,
           room_entry_49,
           room_entry_4a,
           room_entry_4b,
           room_entry_4c,
           room_entry_4d,
           room_entry_4e,
           room_entry_4f,
           room_entry_50,
           room_entry_51,
           room_entry_52,
           room_entry_53,
           room_entry_54,
           room_entry_55,
           room_entry_56,
           room_entry_57,
           room_entry_58,
           room_entry_59,
           room_entry_5a,
           room_entry_5b,
           room_entry_5c,
           room_entry_5d,
           room_entry_5e,
           room_entry_5f
           
        dw room_entry_60,       ;fourth floor
           room_entry_61,
           room_entry_62,
           room_entry_63,
           room_entry_64,
           room_entry_65,
           room_entry_66,
           room_entry_67,
           room_entry_68,
           room_entry_69,
           room_entry_6a,
           room_entry_6b,
           room_entry_6c,
           room_entry_6d,
           room_entry_6e,
           room_entry_6f,
           room_entry_70,
           room_entry_71,
           room_entry_72,
           room_entry_73,
           room_entry_74,
           room_entry_75,
           room_entry_76,
           room_entry_77,
           room_entry_78,
           room_entry_79,
           room_entry_7a,
           room_entry_7b,
           room_entry_7c,
           room_entry_7d,
           room_entry_7e,
           room_entry_7f

    }


    .entry: {    ;objs            enemies          bounds,bg;   routine ptr
        ..0:  dw room_objlist_0,  room_enemylist_0,  $0204,     $0000
        ..1:  dw room_objlist_1,  room_enemylist_1,  $0004,     $0000
        ..2:  dw room_objlist_2,  room_enemylist_2,  $0104,     $0000
        ..3:  dw room_objlist_3,  room_enemylist_3,  $0102,     $0000
        ..4:  dw room_objlist_4,  room_enemylist_4,  $0102,     $0000
        ..5:  dw room_objlist_5,  room_enemylist_5,  $0102,     $0000
        ..6:  dw room_objlist_6,  room_enemylist_6,  $0102,     $0000
        ..7:  dw room_objlist_7,  room_enemylist_7,  $0102,     $0000
        ..8:  dw room_objlist_8,  room_enemylist_8,  $0102,     $0000
        ..9:  dw room_objlist_9,  room_enemylist_9,  $0102,     $0000
        ..a:  dw room_objlist_a,  room_enemylist_a,  $0102,     $0000
        ..b:  dw room_objlist_b,  room_enemylist_b,  $0102,     $0000
        ..c:  dw room_objlist_c,  room_enemylist_c,  $0102,     $0000
        ..d:  dw room_objlist_d,  room_enemylist_d,  $0102,     $0000
        ..e:  dw room_objlist_e,  room_enemylist_e,  $0102,     $0000
        ..f:  dw room_objlist_f,  room_enemylist_f,  $0102,     $0000
        ..10: dw room_objlist_10, room_enemylist_10, $0203,     $0000
        ..11: dw room_objlist_11, room_enemylist_11, $0003,     $0000
        ..12: dw room_objlist_12, room_enemylist_12, $0103,     $0000
        ..13: dw room_objlist_13, room_enemylist_13, $0102,     $0000
        ..14: dw room_objlist_14, room_enemylist_14, $0102,     $0000
        ..15: dw room_objlist_15, room_enemylist_15, $0102,     $0000
        ..16: dw room_objlist_16, room_enemylist_16, $0102,     $0000
        ..17: dw room_objlist_17, room_enemylist_17, $0102,     $0000
        ..18: dw room_objlist_18, room_enemylist_18, $0102,     $0000
        ..19: dw room_objlist_19, room_enemylist_19, $0102,     $0000
        ..1a: dw room_objlist_1a, room_enemylist_1a, $0102,     $0000
        ..1b: dw room_objlist_1b, room_enemylist_1b, $0102,     $0000
        ..1c: dw room_objlist_1c, room_enemylist_1c, $0102,     $0000
        ..1d: dw room_objlist_1d, room_enemylist_1d, $0102,     $0000
        ..1e: dw room_objlist_1e, room_enemylist_1e, $0102,     $0000
        ..1f: dw room_objlist_1f, room_enemylist_1f, $0102,     $0000
        ..20: dw room_objlist_20, room_enemylist_20, $0202,     $0000
        ..21: dw room_objlist_21, room_enemylist_21, $0003,     $0000
        ..22: dw room_objlist_22, room_enemylist_22, $0003,     $0000
        ..23: dw room_objlist_23, room_enemylist_23, $0003,     $0000
        ..24: dw room_objlist_24, room_enemylist_24, $0102,     $0000
        ..25: dw room_objlist_25, room_enemylist_25, $0102,     $0000
        ..26: dw room_objlist_26, room_enemylist_26, $0102,     $0000
        ..27: dw room_objlist_27, room_enemylist_27, $0102,     $0000
        ..28: dw room_objlist_28, room_enemylist_28, $0102,     $0000
        ..29: dw room_objlist_29, room_enemylist_29, $0102,     $0000
        ..2a: dw room_objlist_2a, room_enemylist_2a, $0102,     $0000
        ..2b: dw room_objlist_2b, room_enemylist_2b, $0102,     $0000
        ..2c: dw room_objlist_2c, room_enemylist_2c, $0102,     $0000
        ..2d: dw room_objlist_2d, room_enemylist_2d, $0102,     $0000
        ..2e: dw room_objlist_2e, room_enemylist_2e, $0102,     $0000
        ..2f: dw room_objlist_2f, room_enemylist_2f, $0102,     $0000
        ..30: dw room_objlist_30, room_enemylist_30, $0203,     $0000
        ..31: dw room_objlist_31, room_enemylist_31, $0003,     $0000
        ..32: dw room_objlist_32, room_enemylist_32, $0103,     $0000
        ..33: dw room_objlist_33, room_enemylist_33, $0102,     $0000
        ..34: dw room_objlist_34, room_enemylist_34, $0102,     $0000
        ..35: dw room_objlist_35, room_enemylist_35, $0102,     $0000
        ..36: dw room_objlist_36, room_enemylist_36, $0102,     $0000
        ..37: dw room_objlist_37, room_enemylist_37, $0102,     $0000
        ..38: dw room_objlist_38, room_enemylist_38, $0102,     $0000
        ..39: dw room_objlist_39, room_enemylist_39, $0102,     $0000
        ..3a: dw room_objlist_3a, room_enemylist_3a, $0102,     $0000
        ..3b: dw room_objlist_3b, room_enemylist_3b, $0102,     $0000
        ..3c: dw room_objlist_3c, room_enemylist_3c, $0102,     $0000
        ..3d: dw room_objlist_3d, room_enemylist_3d, $0102,     $0000
        ..3e: dw room_objlist_3e, room_enemylist_3e, $0102,     $0000
        ..3f: dw room_objlist_3f, room_enemylist_3f, $0102,     $0000
        ..40: dw room_objlist_40, room_enemylist_40, $0203,     $0000
        ..41: dw room_objlist_41, room_enemylist_41, $0003,     $0000
        ..42: dw room_objlist_42, room_enemylist_42, $0103,     $0000
        ..43: dw room_objlist_43, room_enemylist_43, $0002,     $0000
        ..44: dw room_objlist_44, room_enemylist_44, $0002,     $0000
        ..45: dw room_objlist_45, room_enemylist_45, $0002,     $0000
        ..46: dw room_objlist_46, room_enemylist_46, $0102,     $0000
        ..47: dw room_objlist_47, room_enemylist_47, $0102,     $0000
        ..48: dw room_objlist_48, room_enemylist_48, $0102,     $0000
        ..49: dw room_objlist_49, room_enemylist_49, $0102,     $0000
        ..4a: dw room_objlist_4a, room_enemylist_4a, $0102,     $0000
        ..4b: dw room_objlist_4b, room_enemylist_4b, $0102,     $0000
        ..4c: dw room_objlist_4c, room_enemylist_4c, $0102,     $0000
        ..4d: dw room_objlist_4d, room_enemylist_4d, $0102,     $0000
        ..4e: dw room_objlist_4e, room_enemylist_4e, $0102,     $0000
        ..4f: dw room_objlist_4f, room_enemylist_4f, $0102,     $0000
        ..50: dw room_objlist_50, room_enemylist_50, $0203,     $0000
        ..51: dw room_objlist_51, room_enemylist_51, $0003,     $0000
        ..52: dw room_objlist_52, room_enemylist_52, $0103,     $0000
        ..53: dw room_objlist_53, room_enemylist_53, $0102,     $0000
        ..54: dw room_objlist_54, room_enemylist_54, $0102,     $0000
        ..55: dw room_objlist_55, room_enemylist_55, $0102,     $0000
        ..56: dw room_objlist_56, room_enemylist_56, $0102,     $0000
        ..57: dw room_objlist_57, room_enemylist_57, $0102,     $0000
        ..58: dw room_objlist_58, room_enemylist_58, $0102,     $0000
        ..59: dw room_objlist_59, room_enemylist_59, $0102,     $0000
        ..5a: dw room_objlist_5a, room_enemylist_5a, $0102,     $0000
        ..5b: dw room_objlist_5b, room_enemylist_5b, $0102,     $0000
        ..5c: dw room_objlist_5c, room_enemylist_5c, $0102,     $0000
        ..5d: dw room_objlist_5d, room_enemylist_5d, $0102,     $0000
        ..5e: dw room_objlist_5e, room_enemylist_5e, $0102,     $0000
        ..5f: dw room_objlist_5f, room_enemylist_5f, $0102,     $0000
        ..60: dw room_objlist_60, room_enemylist_60, $0203,     $0000
        ..61: dw room_objlist_61, room_enemylist_61, $0003,     $0000
        ..62: dw room_objlist_62, room_enemylist_62, $0103,     $0000
        ..63: dw room_objlist_63, room_enemylist_63, $0102,     $0000
        ..64: dw room_objlist_64, room_enemylist_64, $0003,     roomroutines_precat
        ..65: dw room_objlist_65, room_enemylist_65, $0103,     $0000
        ..66: dw room_objlist_66, room_enemylist_66, $0102,     $0000
        ..67: dw room_objlist_67, room_enemylist_67, $0102,     $0000
        ..68: dw room_objlist_68, room_enemylist_68, $0102,     $0000
        ..69: dw room_objlist_69, room_enemylist_69, $0102,     $0000
        ..6a: dw room_objlist_6a, room_enemylist_6a, $0102,     $0000
        ..6b: dw room_objlist_6b, room_enemylist_6b, $0102,     $0000
        ..6c: dw room_objlist_6c, room_enemylist_6c, $0102,     $0000
        ..6d: dw room_objlist_6d, room_enemylist_6d, $0102,     $0000
        ..6e: dw room_objlist_6e, room_enemylist_6e, $0102,     $0000
        ..6f: dw room_objlist_6f, room_enemylist_6f, $0102,     $0000
        ..70: dw room_objlist_70, room_enemylist_70, $0203,     $0000
        ..71: dw room_objlist_71, room_enemylist_71, $0003,     $0000
        ..72: dw room_objlist_72, room_enemylist_72, $0103,     $0000
        ..73: dw room_objlist_73, room_enemylist_73, $0102,     $0000
        ..74: dw room_objlist_74, room_enemylist_74, $0102,     $0000
        ..75: dw room_objlist_75, room_enemylist_75, $0102,     $0000
        ..76: dw room_objlist_76, room_enemylist_76, $0102,     $0000
        ..77: dw room_objlist_77, room_enemylist_77, $0102,     $0000
        ..78: dw room_objlist_78, room_enemylist_78, $0102,     $0000
        ..79: dw room_objlist_79, room_enemylist_79, $0102,     $0000
        ..7a: dw room_objlist_7a, room_enemylist_7a, $0102,     $0000
        ..7b: dw room_objlist_7b, room_enemylist_7b, $0102,     $0000
        ..7c: dw room_objlist_7c, room_enemylist_7c, $0102,     $0000
        ..7d: dw room_objlist_7d, room_enemylist_7d, $0102,     $0000
        ..7e: dw room_objlist_7e, room_enemylist_7e, $0102,     $0000
        ..7f: dw room_objlist_7f, room_enemylist_7f, $0102,     $0000


    }

                ;!kobjectentrylength in defines.asm!
    .objlist: { ;obj type           x      y       palette  variable
        ..0: {                                              ;like room ptr for stairs, or vent height
            dw #obj_ptr_vent,       $0006, $001a,  $0000,   $0050           ;30
            dw #obj_ptr_openwall,   $001c, $0001,  $0000,   $0000           ;2e
            dw #obj_ptr_vent,       $0012, $001a,  $0000,   $0020           ;2c
            dw #obj_ptr_vent,       $001a, $001a,  $0000,   $0020           ;2a
            dw #obj_ptr_upstairs,   $000e, $0005,  $0400,   $0000           ;28
            dw $ffff
        }
        
        ..1: {
            dw #obj_ptr_openwall,   $0001, $0001,  $0000,   $0000
            dw #obj_ptr_openwall,   $001c, $0001,  $0000,   $0000
            dw #obj_ptr_fanL,       $0011, $000e,  $0800,   $0013
            dw #obj_ptr_table2,     $000b, $0015,  $0800,   $0000
            dw #obj_ptr_vent,       $0005, $001a,  $0000,   $0013
            dw #obj_ptr_vent,       $0016, $001a,  $0000,   $0013
            dw #obj_ptr_lamp,       $000b, $000f,  $1400,   $0000
            dw $ffff
        }
        
        ..2: {
            dw #obj_ptr_openwall,   $0001, $0001,  $0000,   $0000
            dw #obj_ptr_vent,       $0006, $001a,  $0000,   $0013
            dw #obj_ptr_vent,       $0014, $001a,  $0000,   $0033
            dw $ffff
        }
        
        ..3: {
            dw #obj_ptr_vent,       $0014, $001a,  $0000,   $0000
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
            dw $ffff
        }

        ..d: {
            dw $ffff
        }

        ..e: {
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

        ..20: {     ;second floor
            dw #obj_ptr_openwall,   $001c, $0001,  $0000,   $0000
            dw #obj_ptr_dnstairs,   $0010, $0005,  $0400,   $0000
            dw #obj_ptr_vent,       $0011, $001a,  $0000,   $0013
            dw #obj_ptr_table,      $0004, $0011,  $0800,   $0000
            dw #obj_ptr_candle,     $0004, $000d,  $0800,   $0000
            dw $ffff
        }

        ..21: {
            dw #obj_ptr_shelf,      $0010, $0011,  $0800,   $0008
            dw #obj_ptr_openwall,   $0001, $0001,  $0000,   $0000
            dw #obj_ptr_openwall,   $001c, $0001,  $0000,   $0000
            ;dw #obj_ptr_shelf,      $0010, $0013,  $0800,   $0006
            ;dw #obj_ptr_shelf,      $0010, $0015,  $0800,   $0004
            ;dw #obj_ptr_shelf,      $0010, $0017,  $0800,   $0002
            
            dw #obj_ptr_vent,       $0008, $001a,  $0000,   $0013
            dw #obj_ptr_vent,       $0013, $001a,  $0000,   $0013
            dw #obj_ptr_window,     $0008, $0008,  $0c00,   $0033
            dw #obj_ptr_ozma,       $0010, $0005,  $1000,   $0000
            dw $ffff
        }

        ..22: {
            dw #obj_ptr_openwall,   $0001, $0001,  $0000,   $0000
            dw #obj_ptr_openwall,   $001c, $0001,  $0000,   $0000
            dw #obj_ptr_vent,       $0008, $001a,  $0000,   $0013
            dw #obj_ptr_window,     $0010, $0008,  $0c00,   $0033
            dw #obj_ptr_candle,     $000f, $000f,  $0800,   $0000
            dw $ffff
        }

        ..23: {
            ;obj type               x      y       palette  variable
            dw #obj_ptr_openwall,   $0001, $0001,  $0000,   $0000
            dw #obj_ptr_openwall,   $001c, $0001,  $0000,   $0000
            dw #obj_ptr_upstairs,   $000e, $0005,  $0400,   $0000
            dw #obj_ptr_vent,       $0010, $001a,  $0000,   $0013
            dw #obj_ptr_fishbowl,   $0018, $0016,  $0800,   $0010
            dw $ffff
        }

        ..24: {
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
            dw $ffff
        }

        ..43: {
            dw #obj_ptr_dnstairs,   $000e, $0005,  $0400,   $0000
            dw #obj_ptr_vent,       $000a, $001a,  $0000,   $0013
            dw #obj_ptr_openwall,   $0001, $0001,  $0000,   $0000
            dw #obj_ptr_openwall,   $001c, $0001,  $0000,   $0000
            dw $ffff
        }

        ..44: {
            dw #obj_ptr_openwall,   $0001, $0001,  $0000,   $0000
            dw #obj_ptr_openwall,   $001c, $0001,  $0000,   $0000
            dw #obj_ptr_upstairs,   $000e, $0005,  $0400,   $0000
            dw #obj_ptr_vent,       $0010, $001a,  $0000,   $0043
            dw $ffff
        }

        ..45: {
            dw #obj_ptr_openwall,   $0001, $0001,  $0000,   $0000
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
            dw #obj_ptr_vent,       $000a, $001a,  $0000,   $0013
            dw #obj_ptr_openwall,   $0001, $0001,  $0000,   $0000
            dw #obj_ptr_openwall,   $001c, $0001,  $0000,   $0000
            dw #obj_ptr_dnstairs,   $000e, $0005,  $0400,   $0000
            dw $ffff
        }

        ..65: {
            dw #obj_ptr_openwall,   $0001, $0001,  $0000,   $0000
            dw #obj_ptr_vent,       $0018, $001a,  $0000,   $0013
            dw #obj_ptr_vent,       $0003, $001a,  $0000,   $0013
            ;dw #obj_ptr_table,      $000d, $0010,  $0800,   $0000
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
    }


    .enemylist: {
        ..0: {
            ;enemy type             x,        y,         property,     prop2,           property3
            dw enemy_ptr_duct,      $0020,    $0008,     $9021,        $8004,           $0000
            dw $ffff                                                 
        }                                                            
                                                                     
        ..1: {                                                       
            dw enemy_ptr_bandspack, $0040,    $0058,     $0000,        $0000,           $0001
            dw $ffff
        }
        
        ..2: {
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
            dw $ffff
        }
        
        ..d: {
            dw $ffff
        }
        
        ..e: {
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
            dw enemy_ptr_copter,        $0080,    $0040,   $0130,       $2000,             $01a0
            dw enemy_ptr_balloon,       $0060,    $0028,   $0f80,       $3002,             $0000
            dw enemy_ptr_battery,       $0070,    $0070,   $0064,       $0006,             $0001
            dw enemy_ptr_duct,          $0090,    $0008,   $2000,       $8004,             $0000
            dw enemy_ptr_switch,        $0068,    $0060,   $4000,       $0200,             $2028
            dw $ffff
        }
        
        ..22: {
            dw enemy_ptr_drip,          $0060,    $0008,   $0070,       $0002,             $0000
            ;dw enemy_ptr_foil,          $0050,    $0058,   $0070,       $0002,             $0000
            dw $ffff
        }
        
        ..23: {
            dw $ffff
        }
        
        ..24: {
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
            dw $ffff
        }
        
        ..43: {
            dw $ffff
        }
        
        ..44: {
            dw $ffff
        }
        
        ..45: {
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
            dw enemy_ptr_bandspack,        $0040,    $0058,     $0000,        $0000,           $0001
            dw $ffff
        }
        
        ..65: {
            ;enemy type                    x,        y,         property,      property2,         property3
            dw enemy_ptr_catbody,          $0080,    $0065,     $0070,         $0000,             $0000
            dw enemy_ptr_catpaw,           $0050,    $006d,     $0070,         $0000,             $0000
            dw enemy_ptr_cattail,          $0088,    $007d,     $0070,         $0000,             $0000
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
    }
}
