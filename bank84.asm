lorom

org $848000
    
;===========================================================================================
;===================================  D E F I N E S  =======================================
;===========================================================================================

;24 words, 24 objects = 24 words, 48 bytes per array ($30)
;!objectarraystart       =       $1000
;!objectarraysize        =       $0030
;!objID                  =       !objectarraystart
;!objxsize               =       !objID+!objectarraysize
;!objysize               =       !objxsize+!objectarraysize
;!objtilemapointer       =       !objysize+!objectarraysize
;!objxpos                =       !objtilemapointer+!objectarraysize
;!objypos                =       !objxpos+!objectarraysize
;arrays' ends                   +!objectarraysize

;!localtempvar           =       $10
;!localtempvar2          =       $12
;!localtempvar3          =       $14



;!objtilemapbuffer       =       $7f6000

incsrc "./defines.asm"

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
        ..vent: {
            lda !gliderx            ;if gliderx is between $30-$50 [vent x +/- $10]
            cmp #$0030
            bmi +
            cmp #$0050
            bpl +
            
            
            
            lda !kliftstateup       ;then lift state = up
            sta !gliderliftstate
            
            lda !framecounter       ;if frame %8
            bit #$0008
            bne +
            
            lda !glidery            ;if glidery < ceiling
            cmp !kceiling+4
            bpl +
            
            lda !glidersuby
            clc
            adc #$4000
            sta !glidersuby         ;glidery +1.25
            
            inc !glidery
            
        +   rtl
        }
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
        sta !objysize,x             ;store object x size (length of rows)
        
        lda $0004,y
        sta !objxsize,x             ;store object y size (number of rows)
        
        ply
        plb
        plx
        rtl
    }
    
    
    .clear: {
        ;deals with an instance of an object. clears all array slots
        ;argument: x = obj id to clear
        
        stz !objID,x
        stz !objxsize,x
        stz !objysize,x
        stz !objtilemapointer,x
        stz !objxpos,x
        stz !objypos,x
        
        rtl
    }
    
    
    .debugobjmakefan: {
        phb
        
        phk
        plb
        
        ldx #$0000
        
        lda #obj_headers_fanR
        sta !objID,x
        
        lda obj_headers_fanR+2
        asl
        sta !objxsize,x
        
        lda obj_headers_fanR+4
        asl
        sta !objysize,x
        
        lda #obj_tilemaps_fanR
        sta !objtilemapointer,x
        
        lda #$0014
        dec
        asl
        sta !objxpos,x
        
        lda #$0007
        dec
        asl
        sta !objypos,x
        
        lda #$1800
        sta !objpal,x
        
        ldx #$0000
        jsr obj_draw
        
        plb
        rtl
    }
    
        .debugobjmakevent: {
        phb
        
        phk
        plb
        
        ldx #$0002
        
        lda #obj_headers_vent
        sta !objID,x
        
        lda obj_headers_vent+2
        asl
        sta !objxsize,x
        
        lda obj_headers_vent+4
        asl
        sta !objysize,x
        
        lda #obj_tilemaps_vent
        sta !objtilemapointer,x
        
        lda #$0006
        dec
        asl
        sta !objxpos,x
        
        lda #$001a
        dec
        asl
        sta !objypos,x
        
        lda #$1000
        sta !objpal,x
        
        ldx #$0002
        jsr obj_draw
        
        plb
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
        sta !objxpos,y
        
        lda $0004,x
        sta !objypos,y
        
        plb
        rtl
    }
    
    
    .makedummy: {                   ;dummy vent
        ;x = obj population pointer
        txa
        jsl obj_init
        
        ldx #objlist_dummy_list
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
    
    
    .draw: {
        ;deals with an instance of an object
        ;get object ID, get x and y pos, get tilemap pointer, draw
        ;argument: x=object id
        
        phy
        phb
        
        phk
        plb
        
        ;set up draw loop variables
        lda !objpal,x
        sta !objdrawpalette
        
        lda !objtilemapointer,x
        sta !objdrawpointer     ;backup the tilemap pointer
        
        lda !objysize,x
        asl
        sta !objdrawrows        ;backup number of rows to draw
        
        lda !objypos,x
        asl #5
        clc
        adc !objxpos,x          ;index into tilemap array to start writing
        
        sta !objdrawanchor      ;objypos*32+objxpos
        
        lda !objxsize,x         ;length of written portion of each row
        sta !objdrawrowlength
        
        ;32-objxsize = length of remaining row and start of next row
        
        lda #$0040
        sec
        sbc !objdrawrowlength
        sta !objdrawnextline    ;length to add to go from end of a row
                                ;to the start of the next row
        
        ;loop init
        ldx !objdrawanchor
        stz !rowcounter
        stz !rowlengthcounter
        
        ..loop: {       ;for each row
            lda (!objdrawpointer),y
            ora !objdrawpalette                 ;palette selection
            sta !objtilemapbuffer,x
            
            iny : iny
            inx : inx
            inc !rowlengthcounter
            inc !rowlengthcounter
            
            lda !rowlengthcounter
            cmp !objdrawrowlength
            beq ..newrow
            
            -
            
            inc !rowcounter
            lda !rowcounter
            cmp !objdrawrows
            beq .out
            
            jmp ..loop
        }
        
        ..newrow: {     ;next row
            txa
            clc
            adc !objdrawnextline
            tax
            
            stz !rowlengthcounter
            
            bra -
        }
        
        .out:
        
        
        
        plb
        ply
        rts
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
            dw #obj_tilemaps_vent,      $0006, $0003
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

;warn pc