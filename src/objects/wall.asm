wall: {
    ;this is an object type. see "objects.asm" for the system that it interacts with
    ;this is for placing walls in the middle of a room
    
    ;objvariable:
    ;$8000 bit = left wall
    ;any other nonzero value = right wall
    ;zero = delete
    
    .header:
        dw  $0000,              ;tilemap ptr, set in init
            $0000,              ;x size, set in init
            $001f,              ;y size
            wall_init,          ;routine ptr
            $8000               ;properties
    
    .init: {
        ;x = object index
        phy
        phb
        
        phk
        plb
        
        lda !roombg
        asl
        tay
        
        lda wall_widthlist,y
        beq ..return
        sta !objxsize,x
        
        
        lda !objvariable,x
        bmi ..left          ;if negative, left
        bne ..right         ;other nonzero, it's right
        ;else:
        
        ..return:
        ;delete regardless of what occurs
        jsr obj_clear
        plb
        ply
        rts
        
        ..left:
        lda wall_lefttilemaplist,y
        sta !objtilemapointer,x
        jsr obj_draw
        bra ..return
        
        ..right:
        lda wall_righttilemaplist,y
        sta !objtilemapointer,x
        jsr obj_draw
        bra ..return
    }
    
    .lefttilemaplist: {
        dw $0000,                   ;0 = object layer
           $0000,                   ;1 = splash screen
           wall_lefttilemaps_bg2,   ;2
           wall_lefttilemaps_bg3,   ;3
           wall_lefttilemaps_bg4,   ;4
           wall_lefttilemaps_bg5,   ;5
           $0000,                   ;6 has no wall
           wall_lefttilemaps_bg7,   ;7
           $0000,                   ;8 = ending scene
           wall_lefttilemaps_bg9,   ;9
           wall_lefttilemaps_bga    ;a
    }
    
    .righttilemaplist: {
        dw $0000,                   ;0 = object layer
           $0000,                   ;1 = splash screen
           wall_righttilemaps_bg2,  ;2
           wall_righttilemaps_bg3,  ;3
           wall_righttilemaps_bg4,  ;4
           wall_righttilemaps_bg5,  ;5
           $0000,                   ;6 has no wall
           wall_righttilemaps_bg7,  ;7
           $0000,                   ;8 = ending scene
           wall_righttilemaps_bg9,  ;9
           wall_righttilemaps_bga   ;a
    }
    
    .widthlist: {
        dw $0000,       ;0 obj layer
           $0000,       ;1 splash screen
           $0005,       ;bg2 x
           $0006,       ;bg3
           $0004,       ;bg4
           $0006,       ;bg5
           $0000,       ;bg6 does not really have a wall? skip
           $0006,       ;bg7
           $0000,       ;bg8 is ending scene, do not use
           $0006,       ;bg9
           $0004        ;bga
    }
    
    .lefttilemaps: {
        ;see objects.asm for macro definition
        ..bg2:
            %objtilemapentry(wall/wall_bg2_left)
        ..bg3:
            %objtilemapentry(wall/wall_bg3_left)
        ..bg4:
            %objtilemapentry(wall/wall_bg4_left)
        ..bg5:
            %objtilemapentry(wall/wall_bg5_left)
        ..bg7:
            %objtilemapentry(wall/wall_bg7_left)
        ..bg9:
            %objtilemapentry(wall/wall_bg9_left)
        ..bga:
            %objtilemapentry(wall/wall_bga_left)
    }
    
    .righttilemaps: {
        ;see objects.asm for macro definition
        ..bg2:
            %objtilemapentry(wall/wall_bg2_right)
        ..bg3:
            %objtilemapentry(wall/wall_bg3_right)
        ..bg4:
            %objtilemapentry(wall/wall_bg4_right)
        ..bg5:
            %objtilemapentry(wall/wall_bg5_right)
        ..bg7:
            %objtilemapentry(wall/wall_bg7_right)
        ..bg9:
            %objtilemapentry(wall/wall_bg9_right)
        ..bga:
            %objtilemapentry(wall/wall_bga_right)
    }
}