openwall: {

    .header:
        dw  $0000,                      ;tilemap ptr, set in init
            $0000,                      ;x size, set in init
            $0020,                      ;y size
            openwall_init,              ;routine ptr
            $8000                       ;properties
            
    .init: {
        phy
        phb
        
        phk
        plb
        
        lda !roombg
        asl
        tay
        
        lda openwall_tilemaplist,y
        sta !objtilemapointer,x
        
        lda openwall_widthlist,y
        sta !objxsize,x
        
        jsr obj_draw
        jsr obj_clear
        plb
        ply
        rts
    }
    
    .tilemaplist: {
        dw $0000,                   ;bg type 0 is object layer, skip
           $0000,                   ;bg type 1 is splash screen, skip
           openwall_tilemaps_bg2,
           openwall_tilemaps_bg3,
           openwall_tilemaps_bg4,
           openwall_tilemaps_bg5
    }
    
    .widthlist: {
        dw $0000,       ;0 obj layer
           $0000,       ;1 splash screen
           $0005,       ;bg2
           $0005,       ;bg3
           $0005,       ;bg4
           $0005        ;bg5
    }
    
    .tilemaps: {
        ..bg2:
            %objtilemapentry(openwall/openwall_bg2)
        ..bg3:
            %objtilemapentry(openwall/openwall_bg2) ;todo: new tilemap
        ..bg4:
            %objtilemapentry(openwall/openwall_bg2) ;todo: new tilemap
        ..bg5:
            %objtilemapentry(openwall/openwall_bg2) ;todo: new tilemap
    }
}