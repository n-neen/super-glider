lorom

org $848000
    
;===========================================================================================
;===================================  D E F I N E S  =======================================
;===========================================================================================

;24 words, 24 objects = 24 words, 48 bytes per array ($30)
!objectarraystart       =       $1000
!objectarraysize        =       $0030
!objID                  =       !objectarraystart
!objsizex               =       !objID+!objectarraysize
!objsizey               =       !objsizex+!objectarraysize
!objtilemapointer       =       !objsizey+!objectarraysize
!objxcoord              =       !objtilemapointer+!objectarraysize
!objycoord              =       !objxcoord+!objectarraysize
;arrays' ends                   +!objectarraysize

!localtempvar           =       $10
!localtempvar2          =       $12
!localtempvar3          =       $14



!objtilemapbuffer       =       $7f6000



;===========================================================================================
;=========================    R O O M   O B J E C T S   ====================================
;===========================================================================================
    
;object header:
    ;pointer to tilemap in $84
    ;length of each row [x size]
    ;number of rows     [y size]
    
;object instance additionally has:
        ;origin coords in room (where to start writing tilemap update)
    
obj: {
    .handle: {
        ;debug: just do the vent thing
        
        lda !gliderx        ;30-50
        cmp #$0030
        bmi +
        cmp #$0050
        bpl +
        
        lda !kliftstateup
        sta !gliderliftstate
        
    +   rtl
    }
    
    
    .init: {
        ;creates instance of an object
        ;takes argument:
        ;a = object header pointer
        
        ;returns: next item slot in !nextobj
        
        phx
        phy
        phb
        
        phk                         ;db = $84
        plb
        
        pha
        ..findslot: {
            ldx #!objectarraysize+2     ;currently $0030
        -
            dex : dex                   ;we want the zero flag from lda
            lda !objID,x                ;so the loop starts at ammount+2 (dex would affect zero flag)
            bpl -
            ;after we exit this loop, x will be the first available slot
        }
        pla
        
        stx !nextobj
        
        sta !objID,x                ;store object ID
        tay
        
        lda $0000,y
        sta !objtilemapointer,x     ;store tilemap pointer
        
        lda $0002,y
        sta !objsizey,x             ;store object x size (length of rows)
        
        lda $0004,y
        sta !objsizex,x             ;store object y size (number of rows)
        
        ply
        plb
        plx
        rtl
    }
    
    
    .clear: {
        ;deals with an instance of an object. clears all array slots
        ;argument: x = obj id to clear
        
        stz !objID,x
        stz !objsizex,x
        stz !objsizey,x
        stz !objtilemapointer,x
        stz !objxcoord,x
        stz !objycoord,x
        
        rtl
    }
    
    
    .place: {
        ;deals with an instance of an object, called after it is init
        ;get position in room, from room object list, and write it in the array
        
        
        ;argument:
        ;x = object population entry
        ;y = what slot
        
        
        phb
        phx
        
        pea $8383                   ;db = 83
        plb : plb
        
        lda $0000,x                 ;the pointer object header
        tax
        lda $840000,x               ;tilemap pointer
        sta !objtilemapointer,y
        plx
        
        lda $0002,x
        sta !objxcoord,y
        
        lda $0004,x
        sta !objycoord,y
        
        plb
        rtl
    }
    
    
    .makedummy: {                   ;dummy vent
        ;x = obj population pointer
        txa
        jsl obj_init
        
        ldx #objlist_dummy
        ldy !nextobj
        jsl obj_place
        rtl
    }
    
    .debugmakevent: {
        phb
        
        phk
        plb
        
        ldx #$0008
        
        -
        lda obj_tilemaps_vent,x
        ora #$0400
        sta !objtilemapbuffer+(52*32)+12,x
        
        dex : dex
        bpl -
        
        plb
        
        rtl
    }
    
    
    .writetilemap: {
        ;deals with an instance of an object
        ;get object ID, get x and y pos, get tilemap pointer, draw
        ;argument: x=object id
        
        txy
        phk
        plb
        
        lda !objxcoord,x
        sta !localtempvar
        
        lda !objycoord,x
        sta !localtempvar2
        
        lda !objsizex,x
        sta !localtempvar3
        
        lda #$0000
        ldx !localtempvar2
        -
        clc
        adc #$0020
        dex
        bne -
        
        clc
        adc !localtempvar
        tax
        
        
        lda !objtilemapointer,y
        sta !localtempvar2
        
        ldy #$0000
        --
        lda [!localtempvar2],y
        sta !objtilemapbuffer,x
        iny : iny
        inx : inx
        cpy !localtempvar3
        bne --
        
        rtl
    }
    
    .copytowram: {
        ;copy from rom to wram to be dma'd to vram at a later time
        ;takes argument:
            ;x = object id (already loaded AND placed, previously)
            
        ;produces output:
            ;reads tilemap rectangle and its size
            ;write to the wram layer 1 tilemap buffer,
            ;a rectangle of the correct size and location
        phb
        phk
        plb
        phx
        phy
        
        
        
        ply
        plx
        plb
        rtl
    }
    
    .tilemap: {
        ..upload: {
            lda #$6000
            sta !dmasrcptr
            lda #$007f
            sta !dmasrcbank
            lda #$0800
            sta !dmasize
            lda #!bg1tilemap
            sta !dmabaseaddr
            
            jsl dma_vramtransfur
            rtl
        }
        
        ..init: {
            ;call from newgame
            ;clear 7f6000-6800 for obj tilemap
            phb
            
            pea $7f7f       ;#$7f7f
            plb : plb
            
            ldx #$0800
        -   stz $6000,x
            dex : dex
            bne -
            
            plb
            rtl
        }
    }
    
    
    .collision: {
        rtl
    }
    
    .pointers: {
        dw #obj_headers_vent,
           #obj_headers_candle,
           #obj_headers_fanR
    }
    
    .headers: {
        ;object types
        ..vent: {     ;tilemap pointer, xsize, ysize
            dw #obj_tilemaps_vent,      $0006, $0002
        }
        
        ..candle: {
            dw #obj_tilemaps_candle,    $0002, $0003
        }
        
        ..fanR: {
            dw #obj_tilemaps_fanR,      $0004, $0007
        }
    }
    
    .tilemaps: {
        ..vent: {
            incbin "./data/tilemaps/objects/floorvent.bin"
        }
        
        ..candle: {
            ;incbin "./data/tilemaps/objects/candle.bin"
        }
        
        ..fanR: {
            incbin "./data/tilemaps/objects/fanR.bin"
        }
        
    }
    
}