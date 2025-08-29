lorom


;===========================================================================================
;=========================    R O O M   O B J E C T S   ====================================
;===========================================================================================
    
!objbanklong        =   obj&$ff0000
!objbankword        =   !objbanklong>>8
!objbankshort       =   !objbanklong>>16
    

obj: {
    .handle: {
        phx
        
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
        
        plx
        rtl
    }
    
    .drawall: {
        phx
        
        ldx #!objectarraysize
        -
        lda !objID,x
        beq +
        phx
        jsr obj_draw
        plx
        
        +
        dex : dex
        bpl -
        
        plx
        rtl
    }
    
    
    .init: {
        ;creates instance of an object
        ;takes argument:
        ;a = object header pointer
        
        ;returns: next item slot in !nextobj
        
        ;this hasn't been used yet, so is untested!
        
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
            bmi -
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
        stz !objpal,x
        stz !objroutineptr,x
        stz !objproperty,x
        stz !objvariable,x
        
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
        ldx #$0800
        --
        stz $6000,x
        dex : dex
        bpl --
        
        plb
        rtl
    }
    
    
    .draw: {
        ;deals with an instance of an object
        ;get object ID, get x and y pos, get tilemap pointer, draw
        ;argument: x=object index
        
        phy
        phx
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
        ldy #$0000
        
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
        plx
        ply
        rts
    }
    
    .tilemap: {
        ..requestupdate: {
            lda #$0001
            sta !objupdateflag
        }
        
        ..upload: {
            lda !objupdateflag
            beq +
            
            lda #$6000
            sta !dmasrcptr
            lda #$007f
            sta !dmasrcbank
            lda #$0800
            sta !dmasize
            lda #!bg1tilemap
            sta !dmabaseaddr
            
            jsl dma_vramtransfur
            stz !objupdateflag
        +   rtl
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
            ;because it draws tiles on layer 1
            ;which kill you
            ;lol
            
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
    
    .spawn: {
        phb
        phx
        phy
        
        phk
        plb
        
        ;x = object list entry
        ;y = object index
        
        ;from object definition:
        ;tilemap ptr, xsize, ysize, routine, properties
        
        phx
        
        lda.l !roombanklong,x
        tax
        lda.l !objbanklong,x
        tax                 ;x = object type ptr
        
        lda.l !objbanklong+2,x
        sta !objxsize,y
        
        lda.l !objbanklong+4,x
        asl
        sta !objysize,y
        
        lda.l !objbanklong+6,x
        sta !objroutineptr,y
        
        lda.l !objbanklong+8,x
        sta !objproperty,y
        
        lda.l !objbanklong,x
        sta !objtilemapointer,y
        
        plx
        
        ;from object instance:
        ;obj ID, xpos, ypos, palette
        
        lda.l !roombanklong,x
        sta !objID,y
        
        lda.l !roombanklong+2,x
        dec
        asl
        sta !objxpos,y
        
        lda.l !roombanklong+4,x
        dec
        asl
        sta !objypos,y
        
        lda.l !roombanklong+6,x
        sta !objpal,y
        
        lda.l !roombanklong+8,x
        sta !objvariable,y
        
        ply
        plx
        plb
        rts
    }
    
    .spawnall: {
        
        ;now only takes argument in !roomobjlistptr
        
        phx
        phy
        phb
        
        phk
        plb
        
        ldx !roomobjlistptr
        
        ..loop:
        lda.l !roombanklong,x       ;object
        cmp #$ffff
        beq ..out                   ;if object type = $ffff then we are done
        
        ldy #!objectarraysize+2
        ;loop to check which slots are occupied
        -
        dey : dey
        bmi ..out           ;if y goes negative we have no slots
        lda !objID,y
        bne -               ;if current objID is 0, we have an empty slot
        
        ;slot found:
        
        jsr obj_spawn   ;with y = object index
                        ;and x = object list entry pointer
        
        ;phx
        ;tyx
        ;jsr obj_draw    ;draw object (oops gotta switch y to x here)
        ;plx             ;because x = obj index in that routine
        
        txa
        clc                         ;x=x+entrylength
        adc !kobjectentrylength     ;to get next entry
        tax
        
        jmp ..loop
        
        ..out:
        
        plb
        ply
        plx
        rtl
    }
    
    ;===========================================================================================
    ;===============================  OBJECT DEFINITIONS  ======================================
    ;===========================================================================================
    
    ;object property:
    ;$8000 bit = draw on layer 2
    ;$4000     = dynamic size
    
    .ptr: {
        ..vent:         dw obj_headers_vent
        ..candle:       dw obj_headers_candle
        ..fanR:         dw obj_headers_fanR
        ..fanL:         dw obj_headers_fanL
        ..shelf:        dw obj_headers_shelf
        ..upstairs:     dw obj_headers_upstairs
        ..dnstairs:     dw obj_headers_dnstairs
        ..openwall:     dw obj_headers_openwall
        ..window:       dw obj_headers_window
        ..ozma:         dw obj_headers_ozma
        ..lamp:         dw obj_headers_lamp
        
        ..table:        dw obj_headers_table
        ..table2:       dw obj_headers_table2
        
        ..tabletop:     dw obj_headers_tabletop
        ..tablepole:    dw obj_headers_tablepole
        
        ..fishbowl:     dw obj_headers_fishbowl
    }
    
    
    
    .headers: {
        ;object types
        ..vent:       ;tilemap pointer,     xsize, ysize, routine,                  properties
            dw #obj_tilemaps_vent,          $0006, $0003, obj_routines_vent,        $8000
        
        ..candle:
            dw #obj_tilemaps_candle,        $0004, $0004, obj_routines_candle,      $0000
        
        ..fanR:
            dw #obj_tilemaps_fanR,          $0004, $0007, obj_routines_none,        $0000
        
        ..fanL:
            dw #obj_tilemaps_fanL,          $0005, $0007, obj_routines_none,        $0000
        
        ..tallcandle:
            dw #obj_tilemaps_tallcandle,    $0002, $0008, obj_routines_none,        $0000
        
        ..shelf:
            dw !objdyntilemap,              $0030, $0001, obj_routines_shelf,       $0000
        
        ..upstairs:
            dw #obj_tilemaps_upstairs,      $000c, $0014, obj_routines_upstairs,    $8000
        
        ..dnstairs
            dw #obj_tilemaps_dnstairs,      $000c, $0014, obj_routines_dnstairs,    $8000
        
        ..openwall:
            dw #obj_tilemaps_openwall,      $0005, $0020, obj_routines_delete,      $8000
        
        ..window:
            dw #obj_tilemaps_window,        $0006, $0008, obj_routines_delete,      $8000
        
        ..ozma:
            dw #obj_tilemaps_ozma,          $000c, $000b, obj_routines_delete,      $8000
        
        ..lamp:
            dw #obj_tilemaps_lamp,          $0004, $0005, obj_routines_delete,      $0000
        
        ..table:
            dw #obj_tilemaps_table,         $0009, $000d, obj_routines_none,        $0000
        
        ..table2:
            dw #obj_tilemaps_table2,        $000b, $0008, obj_routines_none,        $0000
        
        ..tabletop:
            dw !objdyntilemap,              $0000, $0000, obj_routines_none,        $4000
        
        ..tablepole:
            dw !objdyntilemap,              $0000, $0000, obj_routines_none,        $c000
        
        ..tablebase:
            dw #obj_tilemaps_tablebase,     $0000, $0000, obj_routines_none,        $4000
        
        ..fishbowl:
            dw #obj_tilemaps_fishbowl,      $0005, $0004, obj_routines_fishbowl,    $0000
    }
    
    ;===========================================================================================
    ;=====================================   O B J E C T    ====================================
    ;===================================   R O U T I N E S   ===================================
    ;===========================================================================================
    
    .routines: {
    
        ..fishbowl: {
            ;spawn fish
            phy
            
            lda #enemy_ptr_fish
            sta !enemydynamicspawnslot          ;enemy type
            
            lda !objxpos,x
            asl #2
            clc
            adc #$000d
            sta !enemydynamicspawnslot+2        ;x
            
            lda !objypos,x
            asl #2
            clc
            adc #$0008
            sta !enemydynamicspawnslot+4        ;y
            
            lda !objvariable,x                  ;object's variable gets passed to fish enemy
            xba
            sta !enemydynamicspawnslot+8        ;properties 2
                                                ;jump height (low byte)
                                                ;palette (high byte) (unlikely to be used)
            
            phx
            jsl enemy_findslot                  ;y = available slot
            ldx #!enemydynamicspawnslot         ;x = enemy population entry ptr
            jsl enemy_spawn                     ;spawn enemy
            plx
            
            
            ;clear routine
            stz !objroutineptr,x
            
            ply
            rts
        }
    
        ..candle: {
            
            ;spawn flame enemy
            phx
            phy
            
            lda !objvariable,x                  ;for some reason, this only works
            inc                                 ;on the third time this routine runs
            sta !objvariable,x
            cmp #$0003
            beq +
            
            
            lda #enemy_ptr_candleflame
            sta !enemydynamicspawnslot          ;enemy type
            
            lda !objxpos,x
            asl #2
            clc
            adc #$0005
            sta !enemydynamicspawnslot+2        ;x
            
            lda !objypos,x
            asl #2
            sec
            sbc #$0005
            sta !enemydynamicspawnslot+4        ;y
            
            stz !enemydynamicspawnslot+8        ;properties 2 (palette)
            
            phx
            jsl enemy_findslot                  ;y = available slot
            ldx #!enemydynamicspawnslot         ;x = enemy population entry ptr
            jsl enemy_spawn                     ;spawn enemy
            plx
            
            ply
            plx
            rts
            
            +
            stz !objroutineptr,x
            ply
            plx
            rts
        }
        
        ..shelf: {
            ;x = obj index
            ;variable:
            ;00aa
            ;aa = x size
            phb
            phy
            
            phk
            plb
            
            ldy #$0000
            
            ;lda #!objdyntilemap
            ;sta !objtilemapointer,x
            
            lda !objvariable,x
            and #$001f
            pha
            asl
            clc
            adc #$0004
            sta !objxsize,x
            pla
            
            asl
            sta !localtempvar
            
            lda #$0002
            sta !objdyntilemap
            
            lda #$0003
            sta !objdyntilemap+2
            
            
            lda #$0004
            -
            sta !objdyntilemap+4,y
            iny : iny
            cpy !localtempvar
            bne -
            
            lda #$0003
            sta !objdyntilemap+4,y
            
            lda #$4002
            sta !objdyntilemap+6,y
            
            lda #$ffff
            sta !objdyntilemap+8,y
            
            jsr obj_draw
            jsr obj_clear
            
            ply
            plb
            rts
        }
            
        ..tablebase: {
            lda obj_ptr_tabletop
            jsl obj_init
            jsl obj_spawn
            
            lda obj_ptr_tablepole
            jsl obj_init
            jsl obj_spawn
            rts
        }
        
        ..tabletop: {
            rts
        }
            
        ..upstairs {
            ;x = obj index
            
            lda !objxpos,x
            asl #2
            
            sta !localtempvar
            clc
            adc #$0008
            sta !stairleft
            
            lda !localtempvar
            clc
            adc #$0050
            sta !stairright
            
            lda !gliderx
            cmp !stairleft
            bmi +
            cmp !stairright
            bpl +
            
            lda !glidery
            cmp !kceiling+$a
            bpl +
            
            lda !kroomtranstypeup
            sta !roomtranstype
            lda !kstateroomtrans
            sta !gamestate
            
        +   rts
        }
        
        ..dnstairs {
            ;x = obj index
            
            lda !objxpos,x
            asl #2
            
            sta !localtempvar
            clc
            adc #$0008
            sta !stairleft
            
            lda !localtempvar
            clc
            adc #$0050
            sta !stairright
            
            lda !gliderx
            cmp !stairleft
            bmi +
            cmp !stairright
            bpl +
            
            lda !glidery
            cmp !kfloor-$28
            bmi +
            
            lda !kroomtranstypedown
            sta !roomtranstype
            lda !kstateroomtrans
            sta !gamestate
            
        +   rts
        }
        
        ..delete: {
            
            rts
        }
        
        ..vent: {
            ;x = object index
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
            
            lda !glidery            ;if glidery < vent height
            cmp !objvariable,x
            bmi +
            
            lda !kliftstateup       ;then lift state = up
            sta !gliderliftstate
            
            lda !glidersuby
            sec
            sbc #$9000
            sta !glidersuby
            lda !glidery
            sbc #$0000
            sta !glidery
            
            lda !maincounter
            bit #$0002
            beq +
            
            lda !glidersuby
            sec
            sbc #$8000
            sta !glidersuby
            
        +   rts
        }
        
        
        ..none: rts
        
    }
    
    .tilemaps: {
        ..vent: {
            incbin "./data/tilemaps/objects/floorvent.map"
            dw $ffff
        }
        
        ..table2: {
            incbin "./data/tilemaps/objects/table2.map"
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
        
        ..fanL: {
            incbin "./data/tilemaps/objects/fanL.map"
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
        
        ;..shelf: {
        ;    incbin "./data/tilemaps/objects/shelf.map"
        ;    dw $ffff
        ;}
        
        ..upstairs: {
            incbin "./data/tilemaps/objects/up_stairs.map"
            dw $ffff
        }
        
        ..dnstairs: {
            incbin "./data/tilemaps/objects/down_stairs.map"
            dw $ffff
        }
        
        ..openwall: {
            incbin "./data/tilemaps/objects/openwall.map"
            dw $ffff
        }
        
        ..window: {
            incbin "./data/tilemaps/objects/window.map"
            dw $ffff
        }
        
        ..ozma: {
            incbin "./data/tilemaps/objects/ozma.map"
            dw $ffff
        }
        
        ..lamp: {
            incbin "./data/tilemaps/objects/lamp.map"
            dw $ffff
        }
        
        ..tablebase: {
            ;incbin "./data/tilemaps/objects/tablebase.map"
            dw $ffff
        }
        
        ..fishbowl: {
            incbin "./data/tilemaps/objects/fishbowl.map"
            dw $ffff
        }
        
    }
    
}
