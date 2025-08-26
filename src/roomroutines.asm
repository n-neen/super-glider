roomroutines: {
    ;this routine runs once during room loading, which has forced blank
    ;and so can be used to load graphics
    ;but it also runs every frame during gameplay
    ;so if you use it in that way, you need to 
    ;stz !roomroutineptr
    ;so that it only runs once
    
    .precat: {
        
        ;any sprite graphics on second page
        
        lda #$0003
        jsl load_sprite         ;load sprite data 3 (dart)
        
        lda #$0004
        jsl load_sprite         ;load sprite data 3 (drip)
        
        stz !roomroutineptr
        rtl
    }
}