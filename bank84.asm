lorom

org $848000

incsrc "./defines.asm"

;===========================================================================================
;=========================    R O O M   O B J E C T S   ====================================
;===========================================================================================
    

obj: {
    .handle: {
        ldx #!objectarraysize
        -
        lda !objroutineptr,x
        beq +
        phx
        jsr (!objroutineptr,x)
        plx
        +
        dex : dex
        bpl -
        rtl
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
        ;argument: x = obj index
        
        stz !objID,x
        stz !objxsize,x
        stz !objysize,x
        stz !objtilemapointer,x
        stz !objxpos,x
        stz !objypos,x
        
        rts
    }
    
    .clearall: {
        phb
        
        ldx #!objectarraysize
        -
        jsr obj_clear
        dex : dex
        bpl -
        
        pea $7f7f
        plb : plb
        ldx #$2000
        --
        stz $6000,x
        dex : dex
        bpl --
        
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
    
    
    .draw: {
        ;deals with an instance of an object
        ;get object ID, get x and y pos, get tilemap pointer, draw
        ;argument: x=object index
        
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
        asl : asl
        sta !objdrawrows        ;backup number of rows to draw
        
        lda !objypos,x
        asl #5
        clc
        adc !objxpos,x          ;index into tilemap array to start writing
        
        sta !objdrawanchor      ;objypos*32+objxpos
        
        lda !objxsize,x         ;length of written portion of each row
        asl
        sta !objdrawrowlength
        
        ;32-objxsize = length of remaining row and start of next row
        
        lda #$0040
        sec
        sbc !objdrawrowlength
        sta !objdrawnextline    ;length to add to go from end of a row
                                ;to the start of the next row
        
        ;loop init
        
        lda !objproperty,x      ;the $8000 bit of property is layer 2 select bit
        bmi +
        
        lda !objdrawanchor      ;so if property word is negative (msb set)
        clc                     ;so index starts at $7f0000 for layer 2
        adc #$6000              ;or $7f6000 for layer 1
        tax
        bra ++
        
        +
        
        ldx !objdrawanchor
        ++
        stz !rowcounter
        stz !rowlengthcounter
        
        ..loop: {       ;for each row
            lda (!objdrawpointer),y
            cmp #$ffff
            beq .out
            ora !objdrawpalette                 ;palette selection
            sta $7f0000,x                       ;either $7f0000 or $7f6000 based on if the layer 2 select bit is on
            
            iny : iny
            inx : inx
            inc !rowlengthcounter
            inc !rowlengthcounter
            
            lda !rowlengthcounter
            cmp !objdrawrowlength
            beq ..newrow
            
            -
            
            ;inc !rowcounter
            ;lda !rowcounter
            ;cmp !objdrawrows
            ;beq .out
            
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
        
        ;see defines.asm for hitbox bounds
        
        phx
        phy
        
        ldx !gliderx
        lda !glidery
        clc
        adc !kgliderupbound
        tay
        jsr obj_checktile       ;y up
        
        ldx !gliderx
        lda !glidery
        clc
        adc !kgliderdownbound
        tay
        jsr obj_checktile       ;y down
        
        lda !gliderx
        clc
        adc !kgliderrightbound
        tax
        ldy !glidery
        jsr obj_checktile       ;x right
        
        lda !gliderx
        clc
        adc !kgliderleftbound
        tax
        ldy !glidery
        jsr obj_checktile       ;x left
        
        
        ply
        plx
        rtl
    }
    
    .checktile: {
        !tilemapx   =   !localtempvar
        !tilemapy   =   !localtempvar2
        
        
        txa
        lsr #3
        sta !tilemapx
        
        tya
        lsr #3
        sta !tilemapy
        
        lda !tilemapy
        asl #5
        clc
        adc !tilemapx
        asl
        
        tax
        lda !objtilemap,x
        and #$e3ff                      ;remove palette bits
        bne +
        
        
        ++
        
        ;jsr ..hitboxdraw                ;debug routine to visualize
        
        
        rts
        
        +
        
        lda !kgliderstatelostlife
        sta !gliderstate
        sta !glidernextstate
        rts
        
        ..hitboxdraw: {
            ;this doesnt work anymore
            lda !objtilemap-2,x       ;hitbox draw
            ora #$0008
            sta !objtilemap-2,x
        
            lda !objtilemap,x         ;hitbox draw
            ora #$0008
            sta !objtilemap,x
            
            lda !objtilemap+2,x       ;hitbox draw
            ora #$0008
            sta !objtilemap+2,x
            
            lda !objtilemap+4,x       ;hitbox draw
            ora #$0008
            sta !objtilemap+4,x
            rts
        }
    }
    
    ;===========================================================================================
    ;===============================  OBJECT DEFINITIONS  ======================================
    ;===========================================================================================
    
    ;object property:
    ;$8000 bit = draw on layer 2
    
    .ptr: {
        ..vent:         dw obj_headers_vent
        ..candle:       dw obj_headers_candle
        ..fanR:         dw obj_headers_fanR
        ..table:        dw obj_headers_table
        ..shelf:        dw obj_headers_shelf
        ..upstairs:     dw obj_headers_upstairs
        ..openwall:     dw obj_headers_openwall
    }
    
    .headers: {
        ;object types
        ..vent: {     ;tilemap pointer,     xsize, ysize, routine,           properties
            dw #obj_tilemaps_vent,          $0006, $0003, obj_routines_vent, $0000
        }
        
        ..candle: {
            dw #obj_tilemaps_candle,        $0004, $0004, obj_routines_none, $0000
        }
        
        ..fanR: {
            dw #obj_tilemaps_fanR,          $0004, $0007, obj_routines_none, $0000
        }
        
        ..table: {
            dw #obj_tilemaps_table,         $0009, $000d, obj_routines_none, $0000
        }
        
        ..tallcandle: {
            dw #obj_tilemaps_tallcandle,    $0002, $0008, obj_routines_none, $0000
        }
        
        ..shelf: {
            dw #obj_tilemaps_shelf,         $0008, $0002, obj_routines_none, $0000
        }
        
        ..upstairs: {
            dw #obj_tilemaps_upstairs,      $000c, $0014, obj_routines_none, $8000
        }
        
        ..openwall: {
            dw #obj_tilemaps_openwall,      $0004, $0020, obj_routines_none, $8000
        }
    }
    
    
    .routines: {
        ;used for vent handling
        ;and  TODO: 
            ;tile animations on candles
            ;anything else an object might want to do
            
        ..vent: {
            ;x = object id
            !ventleft       =       !localtempvar2
            !ventright      =       !localtempvar3
            
            lda !objxpos,x
            asl #2
            
            sta !localtempvar
            clc
            adc #$0002
            sta !ventleft
            
            lda !localtempvar
            clc
            adc #$001e
            sta !ventright
            
            lda !gliderx            ;if gliderx is between $30-$50 [vent x +/- $10]
            cmp !ventleft           ;left lift bound
            bmi +
            cmp !ventright          ;right lift bound
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
            adc #$ff00
            sta !glidersuby         ;glidery +almost2
            
            inc !glidery
            
        +   rts
        }
        
        
        ..none: rts
        
    }
    
    .tilemaps: {
        ..vent: {
            incbin "./data/tilemaps/objects/floorvent.map"
            dw $ffff
        }
        
        ..candle: {
            incbin "./data/tilemaps/objects/candle.map"
            dw $ffff
        }
        
        ..fanR: {
            incbin "./data/tilemaps/objects/fanR.map"
            dw $ffff
        }
        
        ..table: {
            incbin "./data/tilemaps/objects/table.map"
            dw $ffff
        }
        
        ..tallcandle: {
            incbin "./data/tilemaps/objects/tallcandle.map"
            dw $ffff
        }
        
        ..shelf: {
            incbin "./data/tilemaps/objects/shelf.map"
            dw $ffff
        }
        
        ..upstairs: {
            incbin "./data/tilemaps/objects/up_stairs.map"
            dw $ffff
        }
        
        ..openwall: {
            incbin "./data/tilemaps/objects/openwall.map"
            dw $ffff
        }
        
    }
    
}

objdebug:
    .makeall: {                     ;obj index
        ;jsr objdebug_makeshelf       ;0
        jsr objdebug_makevent        ;2
        jsr objdebug_maketable       ;4
        jsr objdebug_makevent2       ;6
        jsr objdebug_makestairs      ;8
        jsr objdebug_makefan         ;a
        jsr objdebug_makeopenwall    ;c
        
        rtl
    }
    
        .makefan: {
        phb
        
        phk
        plb
        
        ldx #$000a
        
        lda #obj_headers_fanR
        sta !objID,x
        
        lda obj_headers_fanR+2
        ;asl
        sta !objxsize,x
        
        lda obj_headers_fanR+4
        asl
        sta !objysize,x
        
        lda #obj_tilemaps_fanR
        sta !objtilemapointer,x
        
        lda #$0016
        dec
        asl
        sta !objxpos,x
        
        lda #$0013
        dec
        asl
        sta !objypos,x
        
        lda #$0800
        sta !objpal,x
        
        lda obj_headers_fanR+8
        sta !objproperty,x
        
        ldx #$000a
        jsr obj_draw
        
        plb
        rts
    }
    
    .makeopenwall: {
        phb
        
        phk
        plb
        
        ldx #$000c
        
        lda #obj_headers_openwall
        sta !objID,x
        
        lda obj_headers_openwall+2
        ;asl
        sta !objxsize,x
        
        lda obj_headers_openwall+4
        asl
        sta !objysize,x
        
        lda #obj_tilemaps_openwall
        sta !objtilemapointer,x
        
        lda #$001d
        dec
        asl
        sta !objxpos,x
        
        lda #$0001
        dec
        asl
        sta !objypos,x
        
        lda #$0000
        sta !objpal,x
        
        lda obj_headers_openwall+8
        sta !objproperty,x
        
        ldx #$000c
        jsr obj_draw
        
        plb
        rts
    }
    
    .makestairs: {
        phb
        
        phk
        plb
        
        ldx #$0000
        
        lda #obj_headers_upstairs
        sta !objID,x
        
        lda obj_headers_upstairs+2
        ;asl
        sta !objxsize,x
        
        lda obj_headers_upstairs+4
        asl
        sta !objysize,x
        
        lda #obj_tilemaps_upstairs
        sta !objtilemapointer,x
        
        lda #$0010
        dec
        asl
        sta !objxpos,x
        
        lda #$0005
        dec
        asl
        sta !objypos,x
        
        lda #$0400
        sta !objpal,x
        
        lda obj_headers_upstairs+8
        sta !objproperty,x
        
        ldx #$0000
        jsr obj_draw
        
        plb
        rts
    }
    
    .makeshelf: {
        phb
        
        phk
        plb
        
        ldx #$0000
        
        lda #obj_headers_shelf
        sta !objID,x
        
        lda obj_headers_shelf+2
        ;asl
        sta !objxsize,x
        
        lda obj_headers_shelf+4
        asl
        sta !objysize,x
        
        lda #obj_tilemaps_shelf
        sta !objtilemapointer,x
        
        lda #$000c
        dec
        asl
        sta !objxpos,x
        
        lda #$0004
        dec
        asl
        sta !objypos,x
        
        lda #$0800
        sta !objpal,x
        
        ldx #$0000
        jsr obj_draw
        
        plb
        rts
    }
    
    .makevent: {
        phb
        
        phk
        plb
        
        ldx #$0002
        
        lda #obj_headers_vent
        sta !objID,x
        
        lda obj_headers_vent+2
        ;asl
        sta !objxsize,x
        
        lda obj_headers_vent+4
        asl
        sta !objysize,x
        
        lda obj_headers_vent
        sta !objtilemapointer,x
        
        lda obj_headers_vent+6
        sta !objroutineptr,x
        
        lda #$0015
        dec
        asl
        sta !objxpos,x
        
        lda #$001a
        dec
        asl
        sta !objypos,x
        
        lda #$0800
        sta !objpal,x
        
        ldx #$0002
        jsr obj_draw
        
        plb
        rts
    }
    
    .makevent2: {
        phb
        
        phk
        plb
        
        ldx #$0006
        
        lda #obj_headers_vent
        sta !objID,x
        
        lda obj_headers_vent+2
        ;asl
        sta !objxsize,x
        
        lda obj_headers_vent+4
        asl
        sta !objysize,x
        
        lda obj_headers_vent
        sta !objtilemapointer,x
        
        lda obj_headers_vent+6
        sta !objroutineptr,x
        
        lda #$0004
        dec
        asl
        sta !objxpos,x
        
        lda #$001a
        dec
        asl
        sta !objypos,x
        
        lda #$0800
        sta !objpal,x
        
        ldx #$0006
        jsr obj_draw
        
        plb
        rts
    }
    
    .maketable: {
        phb
        
        phk
        plb
        
        ldx #$0004
        
        lda #obj_headers_table
        sta !objID,x
        
        lda obj_headers_table+2
        ;asl
        sta !objxsize,x
        
        lda obj_headers_table+4
        asl
        sta !objysize,x
        
        lda #obj_tilemaps_table
        sta !objtilemapointer,x
        
        lda #$000c
        dec
        asl
        sta !objxpos,x
        
        lda #$0011
        dec
        asl
        sta !objypos,x
        
        lda #$0800
        sta !objpal,x
        
        ldx #$0004
        jsr obj_draw
        
        plb
        rts
    }
    
}







;warn pc