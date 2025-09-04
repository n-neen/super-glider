gfxloader: {
    .header:
        dw  spritemap_pointers_null,    ;spritemaps
            $0000,                      ;xsize
            $0000,                      ;ysize
            gfxloader_init,             ;init
            $0000,                      ;main
            $0000,                      ;touch
            $0000                       ;shot
            
    .init: {
        
        lda #$0009
        jsl load_sprite         ;load sprite data 8 (teddybear)
        
        lda #$000a
        jsl load_sprite         ;load sprite data 8 (star)
        
        ;lda #$000b
        ;jsl load_sprite         ;load sprite data 8 (cloud)
        
        jsr enemy_clear
        
        rts
    }

}