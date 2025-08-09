!linkbanklong        =   obj&$ff0000
!linkbankword        =   !objbanklong>>8
!linkbankshort       =   !objbanklong>>16

;!roomlinktablelong      =       $7ea000
;!roomlinktableshort     =       $a000
;!roomlinktablebank      =       $7e

;entry:
;aabb, cccc

;aa     = link target room
;bb     = link target enemy index
;cccc   = enemy property

;in room loading, after enemies are loaded, do:
jsl link_handler



link: {
    .handler: {
        phb
        
        pea.w !roomlinktablebank
        plb : plb
        
        ldx #!kroomlinkarraylength
        -
        lda !linktargetshort,x
        beq +
        jsr link_handler_checkroom
        bcc +
        ;if carry set, we found an entry that pertains to this room
        jsr link_handler_checkenemy
        +
        dex : dex
        bpl -
        
        
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
            ;x = index into room link table
            phx
            
            lda !linktargetlong,x
            and #$00ff                  ;y = enemy index in this room
            tay
            
            lda !linkdatalong,x         ;if link data is different, use that instead
            cmp !enemyproperty,y
            beq +
            
            sta !enemyproperty,y
            
            plx
            rts
            
        +   plx
            jsr link_clear              ;if they are the same, link is not necessary
            
            rts
        }
    }
    
    .clearall: {
        phb
        
        pea.w !roomlinktablebank
        plb : plb
        
        ldx #!kroomlinkarraylength
        -
        stz !linktargetshort,x
        stz !linkdatashort,x
        dex : dex
        bpl -
        
        plb
        rtl
    }
    
    
    .clear: {
        ;x = link index
        
        phb
        
        pea.w !roomlinktablebank
        plb : plb
        
        stz !linktargetshort,x
        stz !linkdatashort,x
        
        plb
        rts
    }
    
    .make: {
        
        ;y = room/enemy link target
        ;a = enemy data for link (property field)
        
        phb
        phx
        
        pea.w !roomlinktablebank
        plb : plb
        
        sta !localtempvar
        
        ldx #!kroomlinkarraylength
        -
        lda !linktargetshort,x
        beq +
        
        ;slot found
        lda !localtempvar
        sta !linkdatashort,x
        
        tya
        sta !linktargetshort,x
        
        bra ++
        
        +
        dex : dex
        bpl -
        
        ++
        plx
        plb
        rtl
    }
}