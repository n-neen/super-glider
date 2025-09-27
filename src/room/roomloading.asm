lorom


;org $838000

;===========================================================================================
;=============================    R O O M    L O A D I N G    ==============================
;===========================================================================================

!roombanklong        =   room&$ff0000
!roombankword        =   !roombanklong>>8
!roombankshort       =   !roombanklong>>16

.load: {
    ;number of bytes into the room header the thing is
    ;roomobjlist               =       $0000
    ;roomenemylist             =       $0002
    ;roombgtypebounds          =       $0004   ;bg is low byte, bounds is high byte
    ;roomspecialptr            =       $0006
    
    ;argument:
        ;room pointer in !roomptr

    
    phb
    phx
    phy
    
    phk
    plb
    
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
    sta !roomspecialptr
    
    lda $0004,x
    and #$00ff
    sta !roombg
    jsl load_background     ;relies on contents of A
    
    jsl specialtilemaploading
    
    jsl obj_spawnall
    jsl enemy_spawnall
    jsl link_handle
    
    jsl obj_handle
    
    ;dynamically spawned objects need another round of processing to actually run
    lda !objdynamicprocessingflag
    beq +
    jsl obj_handle
    stz !objdynamicprocessingflag
    +
    
    jsl obj_drawall
    jsl obj_tilemap_requestupdate
    jsl layer2draw          ;make sure to update layer 2 tilemap
                            ;since nmi does not
    
    jsl oam_fillbuffer
    
    jsl glider_draw         ;drawing must happen in this order
    jsl enemy_runinit
    jsl enemy_drawall       ;since glider always starts at oam 0
    jsl game_runroomroutine
    
    
    jsl oam_write
    
    
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
    
    ;if roomindex > maxroomindex, then roomindex = maxroomindex
    lda !roomindex
    cmp !kmaxroomindex      
    bcc +
    lda !kmaxroomindex
    sta !roomindex
    +
    asl
    tax
    lda room_list,x
    sta !roomptr
    
    jsl obj_clearall
    jsl enemy_clearall
    jsl enemy_cleardynamicspawn
    
    plb
    rtl
    
    ..table: {
        dw room_transition_right,       ;0
           room_transition_left,        ;1
           room_transition_up,          ;2
           room_transition_down,        ;3
           room_transition_duct,        ;4
           room_transition_ending,      ;5  ;special vertical that only +1 roomindex
           room_transition_window       ;6  ;special duct that has lower glider y output pos
    }
    
    ..ending: {
        inc !roomindex      ;same as up but room index only goes up by 1
        bra ..up_ending
    }
    
    ..up: {
        lda !roomindex
        clc
        adc #$0020
        sta !roomindex
        
        ...ending:
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
    
    ..window: {
        lda !kfloor-5
        bra ..duct_window
    }
    
    ..duct: {
        lda !kceiling+$10
        sta !glidery
        
        ...window:
        
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
