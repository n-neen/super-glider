specialtilemaploading: {
    ;endingtilemaps_1  , etc is where these are stored
    ;room info has a pointer to the tilemap to load, with the MSB chopped off

    phb
    
    pea.w !specialtilemapbankword
    plb : plb           ;db = bank where special tilemaps are stored
        
    lda !roomspecialptr
    ;cmp #$ffff          ;ffff is marker for null, can't use 0000
    ;beq +               ;because $8000&$7fff = 0 and we need to store
    bmi +                ;a tilemap at $8000. wooooops
                         ;oh also we don't need to do both checks haha
        
    ora #$8000
    sta !localtempvar
    ;y = special tilemap pointer in bank $88 (currently)
    
    
    ldx #$0800
    ldy #$0800
    -
    lda (!localtempvar),y
    sta.l !layer2tilemap,x
    dex : dex
    dey : dey
    bpl -
    
    stz !roomspecialptr
    
+   plb
    rtl
}
