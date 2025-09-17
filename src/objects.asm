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
    
    
    .touch: {
        ;x = object index
        ;call from enemy routine, then branch based on carry
        ;special collision reaction based on hitbox
        
        jsr obj_calchitbox

        lda !gliderx
        clc
        adc !kgliderleftbound
        cmp !hitboxright
        bpl ++
        
        lda !gliderx
        clc
        adc !kgliderrightbound
        cmp !hitboxleft
        bmi ++
        
        lda !glidery
        clc
        adc !kgliderdownbound
        cmp !hitboxtop
        bmi ++
        
        lda !glidery
        clc
        adc !kgliderupbound
        cmp !hitboxbottom
        bpl ++
        
        
        +
        sec     ;collision
        rts
        
        ++
        clc     ;no collision
        rts
    }
    
    
    .calchitbox: {
        !xsizepixels    =   !localtempvar
        !ysizepixels    =   !localtempvar2
        !xpospixels     =   !localtempvar3
        !ypospixels     =   !localtempvar4
        
        
        
        ;called from obj_touch
        
        ;x = object index
        
            ;!hitboxleft   
            ;!hitboxright  
            ;!hitboxtop    
            ;!hitboxbottom 
        lda !objxsize,x
        asl #3
        sta !xsizepixels
        
        lda !objysize,x
        asl #3
        sta !ysizepixels
        
        lda !objxpos,x
        lsr
        inc
        asl #3
        sta !xpospixels
        
        lda !objypos,x
        lsr
        inc
        asl #3
        sta !ypospixels
        
        lda !xpospixels
        sta !hitboxleft         ;left edge
        
        clc
        adc !xsizepixels
        sta !hitboxright        ;+ x size = right edge
        
        lda !ypospixels         ;top edge
        sta !hitboxtop
        
        clc
        adc !ysizepixels        ;+ y size = bottom edge
        sta !hitboxbottom
        
        rts
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
    
    .findslot: {
        ;returns x = object slot
        ldx #!objectarraysize
        -
        lda !objID,x
        beq +               ;slot found
        dex : dex
        bpl -               ;next slot
        bmi ..noslot        ;no slots at all
        
        +
        ;x = open slot
        rts
        
        ..noslot:
        ;todo: care about this
        ldx #$ffff
        rts
    }
    
    .dynamicspawn: {
        ;expects a filled out !objectdynamicspawnslot
        ;returns y = object slot (from findslot and spawn)
        
        phx
        
        jsr obj_findslot        ;returns x = object slot
        txy
        ldx.w #!objectdynamicspawnslot
        jsr obj_spawn           ;needs y = object slot, x = object list entry
        
        plx
        rts
    }
    
    .spawn: {
        phb
        ;phx
        ;phy        ;this routine is called with y as a parameter, duh
        
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
        ;asl                     ;why on earth did i do this
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
        
        ;ply
        ;plx
        plb
        rts
    }
    
    .cleardynamictilemap: {
        phx
        
        ldx.w #!objdyntilemapsize
        
        lda #$ffff
        -
        sta !objdyntilemap,x
        dex : dex
        bpl -
        
        plx
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
    
    .dynamicdraw: {
        jsr obj_draw
        jsr obj_cleardynamictilemap
        
        lda #$0001
        sta !objupdateflag
        
        rts
    }
    
    ;===========================================================================================
    ;===============================  OBJECT DEFINITIONS  ======================================
    ;===========================================================================================
    
    ;object property:
    ;$8000 bit = draw on layer 2
    ;$4000     = dynamic size
    
    .ptr: {
        ..vent:             dw obj_headers_vent
        ..candle:           dw obj_headers_candle
        ..fanR:             dw obj_headers_fanR
        ..fanL:             dw obj_headers_fanL
        ..shelf:            dw obj_headers_shelf
        ..upstairs:         dw obj_headers_upstairs
        ..dnstairs:         dw obj_headers_dnstairs
        ..window:           dw obj_headers_window
        ..ozma:             dw obj_headers_ozma
        ..lamp:             dw obj_headers_lamp
        ..table:            dw obj_headers_table
        ..fishbowl:         dw obj_headers_fishbowl
        ..openwindow:       dw obj_headers_openwindow
        ..trashcan:         dw obj_headers_trashcan
        ..manholetop:       dw obj_headers_manholetop
        ..manholebottom:    dw obj_headers_manholebottom
        ..fireplace:        dw obj_headers_fireplace
        
        ;variable size table related objects
        ..varitable:        dw obj_headers_varitable
        ..tabletop:         dw obj_headers_tabletop
        ..tablepole:        dw obj_headers_tablepole
        ..tablebase:        dw obj_headers_tablebase 
        
        ;utility objects
        ..windowtouchbox:   dw obj_headers_windowtouchbox
        ..solidrect:        dw obj_headers_solidrect
        ..killrect:         dw obj_headers_killrect
        ..liftrect:         dw obj_headers_liftrect
        ..openwall:         dw openwall_header
        ..wall:             dw wall_header
    }
    
    
    
    .headers: {
        ;object types
        ..vent:       ;tilemap pointer,     xsize, ysize, routine,                  properties
            dw #obj_tilemaps_vent,          $0006, $0003, obj_routines_vent,        $8000
        
        ..candle:
            dw #obj_tilemaps_candle,        $0004, $0004, obj_routines_candle,      $0000
        
        ..fanR:
            dw #obj_tilemaps_fanR,          $0004, $0007, $0000,                    $0000
        
        ..fanL:
            dw #obj_tilemaps_fanL,          $0005, $0007, $0000,                    $0000
        
        ..tallcandle:   ;unfinished
            dw #obj_tilemaps_tallcandle,    $0002, $0008, $0000,                    $0000
        
        ..shelf:
            dw !objdyntilemap,              $0030, $0001, obj_routines_shelf,       $0000
        
        ..upstairs:
            dw #obj_tilemaps_upstairs,      $000c, $0014, obj_routines_upstairs,    $8000
        
        ..dnstairs
            dw #obj_tilemaps_dnstairs,      $000c, $0014, obj_routines_dnstairs,    $8000
        
        ..window:
            dw #obj_tilemaps_window,        $0006, $0008, obj_routines_delete,      $8000
        
        ..ozma:
            dw #obj_tilemaps_ozma,          $000c, $000b, obj_routines_delete,      $8000
        
        ..lamp:
            dw #obj_tilemaps_lamp,          $0004, $0005, obj_routines_delete,      $0000
        
        ..table:
            dw #obj_tilemaps_table,         $0009, $000d, obj_routines_delete,      $0000
        
        ..varitable:    ;unimpl
            dw #obj_tilemaps_null,          $0000, $0000, obj_routines_varitable,   $0000
        
        ..tabletop:     ;unimpl
            dw !objdyntilemap,              $0000, $0001, obj_routines_tabletop,    $0000
        
        ..tablepole:    ;uniplm
            dw !objdyntilemap,              $0001, $0008, obj_routines_tablepole,   $0000
        
        ..tablebase:    ;unimpl
            dw #obj_tilemaps_tablebase,     $0009, $0003, obj_routines_none,        $0000
        
        ..fishbowl:
            dw #obj_tilemaps_fishbowl,      $0005, $0004, obj_routines_fishbowl,    $0000
            
        ..openwindow:
            dw #obj_tilemaps_openwindow,    $000c, $000d, obj_routines_delete,      $8000
            
        ..windowtouchbox:
            dw #obj_tilemaps_null,          $000b, $0005, obj_routines_openwindow,  $8000
            
        ..trashcan:
            dw #obj_tilemaps_trashcan,      $0007, $0008, obj_routines_delete,      $0000
            
        ..manholebottom:
            dw #obj_tilemaps_manholebottom, $000f, $0003, obj_routines_delete,      $8000
            
        ..manholetop:
            dw #obj_tilemaps_manholetop,    $000f, $0003, obj_routines_delete,      $8000
            
        ..fireplace:
            dw #obj_tilemaps_fireplace,     $0011, $0008, obj_routines_delete,      $8000
            
        ..solidrect:
            dw #obj_tilemaps_null,          $0000, $0000, obj_routines_solidrect,   $8000
        
        ..killrect:
            dw #obj_tilemaps_null,          $0000, $0000, obj_routines_killrect,    $8000
            
        ..liftrect:
            dw #obj_tilemaps_null,          $0000, $0000, obj_routines_liftrect,    $8000
    }
    
    ;===========================================================================================
    ;=====================================   O B J E C T    ====================================
    ;===================================   R O U T I N E S   ===================================
    ;===========================================================================================
    
    .routines: {
        ..liftrect: {
            lda !objvariable,x
            beq +
            and #$00ff
            sta !objysize,x
            
            lda !objvariable,x
            and #$ff00
            xba
            sta !objxsize,x
            
            stz !objvariable,x      ;clear this so we don't keep repeatedly
                                    ;transferring variable to x/y size
            +
            jsr obj_touch
            
            bcc ++
            ;if hit:
            lda !kliftstateup
            sta !gliderliftstate
            
            ++
            rts
        }
        
        ..killrect: {
            lda !objvariable,x
            beq +
            and #$00ff
            sta !objysize,x
            
            lda !objvariable,x
            and #$ff00
            xba
            sta !objxsize,x
            
            stz !objvariable,x      ;clear this so we don't keep repeatedly
                                    ;transferring variable to x/y size
            +
            jsr obj_touch
            
            bcc ++
            ;if hit:
            lda !kgliderstatelostlife
            sta !glidernextstate
            
            ++
            rts
        }
        
        
        ..solidrect: {
            lda !objvariable,x
            beq +
            and #$00ff
            sta !objysize,x
            
            lda !objvariable,x
            and #$ff00
            xba
            sta !objxsize,x
            
            stz !objvariable,x      ;clear this so we don't keep repeatedly
                                    ;transferring variable to x/y size
            
            +
            
            jsr obj_touch
            bcc ++
            
            ;if hit:
            
            lda !gliderstate
            cmp !kgliderstateright
            beq ...right
            cmp !kgliderstateleft
            beq ...left
            cmp !kgliderstateonfire
            beq ...fire
            
            jsl glider_eject
            
            ++
            rts
            
            ...right:
                lda !kgliderstateleft
                sta !gliderstate
                sta !glidernextstate
                lda !khitboundright

                bra +
            ...left:
                lda !kgliderstateright
                ;sta !gliderstate
                sta !glidernextstate
                
                lda !khitboundleft
                
                +
                sta !gliderhitbound
                rts
                
            ...fire:
                lda !kgliderstatelostlife
                sta !glidernextstate
                rts
                
        }
            
            
        
        
        ..tablepole: {
            phy
            lda !objysize,x
            asl
            tay
            
            lda #$ffff
            sta !objdyntilemap+2,y
            
            lda #$0022
            -
            sta !objdyntilemap,y
            dey : dey
            bpl -
            ply
            
            jsr obj_dynamicdraw
            jsr obj_clear
            
            rts
        }
        
        ..tabletop: {
            phy
            
            lda #$0023
            sta !objdyntilemap      ;left edge of table
            
            lda !objxsize,x
            sec
            sbc #$0004
            asl
            tay
            
            lda #$0025
            sta !objdyntilemap+4,y  ;right edge of table
            
            lda #$ffff
            sta !objdyntilemap+6,y  ;terminator
            
            lda #$0024
            -
            sta !objdyntilemap+2,y
            dey : dey
            bpl -
            
            ply
            
            jsr obj_dynamicdraw
            jsr obj_clear
            
            rts
        }
        
        ..varitable: {
            ;!objectdynamicspawnslot    =   $08a0
            ;
            ;
            ;variable = xxyy
            ;xx = x size (tabletop width)
            ;yy = y size (table pole length)
            
            jsr obj_routines_varitable_spawntop
            jsr obj_routines_varitable_spawnpole
            jsr obj_routines_varitable_spawnbase
            
            jsr obj_clear
            
            rts
            
            ...spawntop: {
                ;0              2       4       6           8
                ;dw objtype,    xxxx,   yyyy,   palette,    variable
                ;variable = xxyy
                ;xx = x size (table top width)
                ;yy = y size (table pole height)
                
                lda #obj_ptr_tabletop
                sta !objectdynamicspawnslot
                
                lda !objxpos,x
                sta !objectdynamicspawnslot+2
                
                lda !objypos,x
                sta !objectdynamicspawnslot+4
                
                lda #$0800
                sta !objectdynamicspawnslot+6
                
                ;write !objdynamictilemap before calling
                
                phx
                jsr obj_dynamicspawn
                plx
                
                ;y = object slot for newly spawn object when we return from this
                ;pull restores x = this object slot
                
                lda !objvariable,x
                and #$ff00
                xba
                asl
                sta !objxsize,y
                
                phx
                tyx
                ;for the spawned object
                jsr (!objroutineptr,x)
                plx
                
                rts
            }
            
            ...spawnpole: {
                ;0              2       4       6           8
                ;dw objtype,    xxxx,   yyyy,   palette,    variable
                ;variable = xxyy
                ;xx = x size (table top width)
                ;yy = y size (table pole height)
                
                lda #obj_ptr_tablepole
                sta !objectdynamicspawnslot
                
                lda !objvariable,x
                and #$ff00
                xba
                dec
                sta !localtempvar
                
                lda !objxsize,x
                lsr
                clc
                adc !objxpos,x
                clc
                adc !localtempvar
                sta !objectdynamicspawnslot+2
                
                lda !objypos,x
                inc
                sta !objectdynamicspawnslot+4
                
                lda #$0800
                sta !objectdynamicspawnslot+6
                
                ;write !objdynamictilemap before calling
                
                phx
                jsr obj_dynamicspawn
                ;tyx
                ;jsr obj_draw
                plx
                ;y = object slot for newly spawn object when we return from this
                ;pull restores x = this object slot
                
                lda !objvariable,x
                and #$00ff
                sta !objysize,y
                
                lda #$0001
                sta !objxsize,y
                
                
                rts
            }
            
            ...spawnbase: {
                ;0              2       4       6           8
                ;dw objtype,    xxxx,   yyyy,   palette,    variable
                
                lda #obj_ptr_tablebase
                sta !objectdynamicspawnslot
                
                lda !objvariable,x
                and #$ff00
                xba
                ;lsr
                adc !objxpos,x
                sec
                sbc #$0005
                sta !objectdynamicspawnslot+2
                
                lda !objvariable,x
                and #$00ff
                adc !objypos,x
                inc
                sta !objectdynamicspawnslot+4
                
                lda #$0800
                sta !objectdynamicspawnslot+6
                
                stz !objectdynamicspawnslot+8
                
                phx
                jsr obj_dynamicspawn
                ;tyx
                ;jsr obj_draw
                plx
                
                
                rts
            }
        }
        
        ..openwindow: {
            jsr obj_touch
            
            bcc +
            
            ;todo: make this take the object's room parameter
            lda #$00d5              ;first room of ending scene
            sta !roomindex
            
            lda #$0080
            sta !ductoutputxpos
            
            lda !kroomtranstypewindow
            sta !roomtranstype
            
            lda !kstateroomtrans
            sta !gamestate
            
        +   rts
        }
        
        
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
    
    ;print "object tilemaps start: ", pc
    .tilemaps: {
        macro objtilemapentry(filename)
            incbin "./data/tilemaps/objects/<filename>.map"
            dw $ffff
        endmacro
        
        ..null:             dw $ffff
        ..vent:             %objtilemapentry(floorvent)
        ..table2:           %objtilemapentry(table2)
        ..candle:           %objtilemapentry(candle)
        ..fanR:             %objtilemapentry(fanR)
        ..fanL:             %objtilemapentry(fanL)
        ..table:            %objtilemapentry(table)
        ..tallcandle:       %objtilemapentry(tallcandle)
        ..upstairs:         %objtilemapentry(up_stairs)
        ..dnstairs:         %objtilemapentry(down_stairs)
        ..window:           %objtilemapentry(window)
        ..ozma:             %objtilemapentry(ozma)
        ..lamp:             %objtilemapentry(lamp)
        ..tablebase:        %objtilemapentry(tablebase)
        ..fishbowl:         %objtilemapentry(fishbowl)
        ..openwindow:       %objtilemapentry(openwindow)
        ..trashcan:         %objtilemapentry(trashcan)
        ..manholetop:       %objtilemapentry(manhole_top)
        ..manholebottom:    %objtilemapentry(manhole_bottom)
        ..fireplace:        %objtilemapentry(fireplace)
    }
    ;print "object tilemaps end:   ", pc
}
