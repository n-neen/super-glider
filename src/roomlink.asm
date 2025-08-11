!linkbanklong        =   obj&$ff0000
!linkbankword        =   !objbanklong>>8
!linkbankshort       =   !objbanklong>>16

;!roomlinktablelong      =       $7ea000
;!roomlinktableshort     =       $a000
;!roomlinktablebank      =       $7e

;entry:
;aabb, cccc

;aa     = link target room
;bb     = link target index
;       $01 bit of bb = select enemy (00) or object (01)

;enemy and object slot indices are always even numbers
;so just mask this bit out at the time you use that byte

;cccc   = enemy/object property

;in room loading, after enemies are loaded, do:
;jsl link_handler

;enemies which use this will:

;lda !enemyproperty,x
;tay                         ;y = room/enemy index target for link data
;lda #$data                 ;a = enemy data for target
;lda #$data|#$0001          ;a = room object data for target
;jsl link_make
;
;rts


link: {
    .handle: {
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
            bit #$0001                      ;if #$0001 bit, this is for a room object
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
            asl
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
            ;x = index into room link table
            phx
            phy
            
            lda !linktargetlong,x
            and #$00ff                  ;y = enemy index in this room
            tay
            
            lda !linkdatalong,x         ;if link data is different, use that instead
            cmp !enemyproperty,y
            beq +
            cmp #$ffff                  ;if link data = $ffff, delete
            beq +
            
            sta !enemyproperty,y
            
            ply
            plx
            rts
            
        +   ply
            plx
            jsr link_clear              ;if they are the same, link is not necessary
            
            rts
        }
        
        ..checkobject: {
            ;x = index into room link table
            phx
            phy
            
            lda !linktargetlong,x
            and #$00fe
            tay
            
            lda !linkdatalong,x
            cmp !objproperty,y
            beq +
            
            sta !objproperty,y
            
            ply
            plx
            rts
            
            
        +   ply
            plx
            jsr link_clear
            rts
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