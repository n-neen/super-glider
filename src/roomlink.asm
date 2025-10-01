!linkbanklong        =   obj&$ff0000
!linkbankword        =   !objbanklong>>8
!linkbankshort       =   !objbanklong>>16

;!roomlinktablelong      =       $7ea000
;!roomlinktableshort     =       $a000
;!roomlinktablebank      =       $7e

;entry:

;        %rrrrrrrrssiiiiit, $dddd
;         8421842184218421
;         
;        r = room index of target
;        s = property select of target
;        t = type select: enemy (0) or object (1)
;        i = index of target
;
;        d = data for target


;in room loading, after enemies are loaded, do:
;jsl link_handler

;enemies which use this will:

;lda !enemyproperty,x
;tay                        ;y = room/enemy index target for link data
;lda #$data                 ;a = >enemy< data for target
;   or
;lda #$data|#$0001          ;a = >object< data for target
;jsl link_make
;and then
;jsl link_process if it is in the same room (currently buggy)



link: {
    .process: {
        ;y = table entry index
        ;processes a single entry
        
        phx
        tyx
        
        lda.l !linktargetlong,x
        jsr link_handle_checkroom
        bcc ++
        
        bit #$0001                     ;if #$0001 bit, this is for a room object
        bne +
        jsr link_handle_checkenemy     ;if not, it's for an enemy
        bra ++
        +
        jsr link_handle_checkobject
        ++
        plx
        rtl
    }
    
    
    .handle: {
        ;processes all entries
        phb
        phx
        phy
        
        pea.w !roomlinktablebank
        plb : plb
        
        ldx #!kroomlinkarraylength
        -
        lda !linktargetshort,x
        beq ++
        jsr link_handle_checkroom
        bcc ++
        
        ..slotfound: {
            ;if carry set, we found an entry that pertains to this room
            lda !linktargetshort,x
            bit #$0001                     ;if #$0001 bit, this is for a room object
            bne +
            jsr link_handle_checkenemy     ;if not, it's for an enemy
            bra ++
            +
            jsr link_handle_checkobject
        }
        
        ++
        dex : dex
        bpl -
        
        ply
        plx
        plb
        rtl
        
        ..checkroom: {
            pha
            
            and #$ff00
            xba
            cmp !roomindex
            beq +
            
            clc
            pla
            rts
            
            +
            sec
            pla
            rts
        }
        
        ..checkenemy: {
            !enemypropertypointer       =       !localtempvar
            
            ;x = index into room link table
            phx
            phy
            phb
            
            phk
            plb
            
            lda !linktargetlong,x
            and #$003e                  ;y = enemy index in this room
            tay
            
            phx
            lda !linktargetlong,x
            and #$00c0
            lsr #5
            tax
            lda link_handle_checkenemy_table,x
            sta !enemypropertypointer
            plx
            
            lda !linkdatalong,x         ;if link data is different, use that instead
            cmp (!enemypropertypointer),y
            beq +
            cmp #$ffff                  ;if link data = $ffff, delete
            beq +
            
            sta (!enemypropertypointer),y
            
            plb
            ply
            plx
            rts
            
        +   plb
            ply
            plx
            jsr link_clear              ;if they are the same, link is not necessary
            
            rts
            
            
            ...table: {
                dw !enemyproperty,
                   !enemyproperty2,
                   !enemyproperty3
            }
        }
        
        ..checkobject: {
            ;x = index into room link table
            !objpropertypointer     =   !localtempvar
            
            phx
            phy
            phb
            
            phk
            plb
            
            lda !linktargetlong,x
            and #$003e
            tay
            
            phx
            lda !linktargetlong,x
            and #$00c0
            lsr #5
            tax
            lda link_handle_checkobject_table,x
            sta !objpropertypointer
            plx
            
            lda !linkdatalong,x
            cmp (!objpropertypointer),y
            beq +
            
            sta (!objpropertypointer),y
            
            plb
            ply
            plx
            rts
            
            
        +   plb
            ply
            plx
            jsr link_clear
            rts
            
            ...table: {
                dw !objvariable,
                   !objproperty,
                   !objpal
            }
        }
        
    }
    
    .clearall: {
        ;call during newgame
        phb
        phx
        
        pea.w !roomlinktablebank
        plb : plb
        
        ldx #!kroomlinkarraylength
        -
        stz !linktargetshort,x
        stz !linkdatashort,x
        dex : dex
        bpl -
        
        plx
        plb
        rtl
    }
    
    
    .clear: {
        ;x = link index
        
        lda #$0000
        sta !linktargetlong,x
        sta !linkdatalong,x

        rts
    }
    
    .make: {
        ;y = room/enemy link target
        ;a = enemy data for link (property field)
        
        !linkdataargument     =       !localtempvar
        
        phb
        phx
        
        pea.w !roomlinktablebank
        plb : plb
        
        sta !linkdataargument

        jsr link_make_checkfordupes
        
        ldx #!kroomlinkarraylength
        -
        lda !linktargetshort,x
        bne +
        
        ;slot found
        lda !linkdataargument
        sta !linkdatashort,x
        
        tya
        sta !linktargetshort,x
        
        bra ..return
        
        +
        dex : dex
        bpl -
        bmi ++
        
        
        ..return:
        ;returns with y = index of slot created
        txy
        plx
        plb
        rtl
        
        ++
        ;ran out of slots
        ;i guess we do something about that
        plx
        plb
        rtl
        
        ..checkfordupes: {
            ;check table for any target entries which have this value
            ;if we one, delete it and abort back a level
            ;y = link target
            
            !linktargetargument     =   !localtempvar2
            
            sty !linktargetargument
            
            ldx #!kroomlinkarraylength
            -
            lda !linktargetshort,x
            cmp !linktargetargument
            bne +
            jsr link_clear
            pla : jmp link_make_return
            +
            dex : dex
            bpl -
            
            rts
        }
    }
}


itembit: {
    !itembit        =       !localtempvar
    
    .check: {
        ;argument:
        ;a = item index bit
        
        ;returns:
        ;carry set = item collected
        ;carry clear = item not collected
        phx
        
        sta !itembit
        
        lda !roomindex
        asl
        tax
        
        lda.l !itembitarraylong,x
        bit !itembit
        bne +
        
        clc
        plx
        rtl
        
        +
        sec
        plx
        rtl
    }
    
    .set: {
        ;argument:
        ;a = item index bit
        phx
        
        sta !itembit
        
        lda !roomindex
        asl
        tax
        lda.l !itembitarraylong,x
        ora !itembit
        sta.l !itembitarraylong,x
        
        plx
        rtl
    }
}