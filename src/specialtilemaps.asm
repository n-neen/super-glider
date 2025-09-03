specialtilemaploading: {
    ;endingtilemaps_1  , etc is where these are stored
    ;room info has a pointer to the tilemap to load, with the MSB chopped off

    phb
    
    ;print pc
    pea.w !specialtilemapbankword
    plb : plb           ;db = bank where special tilemaps are stored
        
    lda !roomspecialptr
    bmi +
    beq +
    ;if contents of roomspecialptr is zero or negative, exit
    ;else, it's a pointer to a special tilemap
        
    ora #$8000
    sta !localtempvar
    ;y = special tilemap pointer in bank $88 (currently)
    
    
    ldx #$0802
    ldy #$0802
    -
    lda (!localtempvar),y
    sta.l !layer2tilemap,x
    dex : dex
    dey : dey
    bne -
    
    stz !roomspecialptr
    
+   plb
    rtl
}
