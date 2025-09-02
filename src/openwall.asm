openwall: {
    ;this is an object type. see "objects.asm" for the system that it interacts with
    ;by default, a room's layer 2 tilemap contains both left and right walls
    ;this object removes the wall, but does not change the room bounds
    ;the $0001 (right) and $0002 (left) bits of !roombounds do that
    ;see room.asm for the room's bounds field to make the player able to exit the room
    ;in the desire direction
    
    
    .header:
        dw  $0000,              ;tilemap ptr, set in init
            $0000,              ;x size, set in init
            $0020,              ;y size
            openwall_init,      ;routine ptr
            $8000               ;properties
            
    .init: {
        phy
        phb
        
        phk
        plb
        
        lda !roombg
        asl
        tay
        
        lda openwall_widthlist,y
        beq +++                 ;if width = 0, stop (delete object)
        sta !objxsize,x
        
        lda openwall_tilemaplist,y
        sta !objtilemapointer,x
        
        
        lda !objvariable,x      ;left openwall  = $8000 variable
        bmi +                   ;right openwall = $0000
        
        lda #$0040
        sec
        sbc !objxsize,x         ;set x position of right openwall object
        sbc !objxsize,x         ;to $40-(width*2) to align with screen edge
        sta !objxpos,x
        lda #$0000
        bra ++
        
        +
        stz !objxpos,x          ;left openwall position
        
        ++
        stz !objypos,x          ;both kinds always y position = 0
        jsr obj_draw
    +++ jsr obj_clear
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
           openwall_tilemaps_bg5,
           openwall_tilemaps_bg6,
           openwall_tilemaps_bg7
    }
    
    .widthlist: {
        dw $0000,       ;0 obj layer
           $0000,       ;1 splash screen
           $0005,       ;bg2
           $0006,       ;bg3
           $0004,       ;bg4
           $0006,       ;bg5
           $0004,       ;bg6
           $0006        ;bg7
    }
    
    .tilemaps: {
        ..bg2:
            %objtilemapentry(openwall/openwall_bg2)
        ..bg3:
            %objtilemapentry(openwall/openwall_bg3)
        ..bg4:
            %objtilemapentry(openwall/openwall_bg4)
        ..bg5:
            %objtilemapentry(openwall/openwall_bg5)
        ..bg6:
            %objtilemapentry(openwall/openwall_bg6)
        ..bg7:
            %objtilemapentry(openwall/openwall_bg7)
    }
    
    .spawner: {
        ;todo:
        ;this will run during room loading
        ;after basic room information is loaded
        ;after objects are all empty
        ;but before any other objects spawn
        
        lda !roombounds
        beq ..return
        bit #$0001          ;right bound
        bne ..rightbound
        
        ..rightreturn:
        bit #$0002          ;left bound
        bne ..leftbound
        
        ..return:
        rtl
        
        ..leftbound: {
            ;spawn left openwall object
            bra openwall_spawner_return
        }
        
        
        ..rightbound: {
            ;spawn right openwall object
            
            ;then check left bound bit
            bra openwall_spawner_rightreturn
        }
    }
}