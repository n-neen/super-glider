star: {
    .header:
        dw  spritemap_pointers_star,    ;spritemaps
            $0040,                      ;xsize
            $0040,                      ;ysize
            $0000,                      ;init
            star_main,                  ;main
            star_touch,                 ;touch
            $0000                       ;shot
    
    
    .main: {
        phx
        phb
        
        phk
        plb
        
        inc !enemyvariable,x            ;time to delay touch reaction for a bit
        
        lda !enemytimer,x
        inc
        sta !enemytimer,x
        -
        asl
        tay
        lda star_animationtable,y
        sta $00     ;debug
        
        bmi +
        asl
        clc
        adc #spritemap_pointers_star
        sta !enemyspritemapptr,x
        
        ++
        plb
        plx
        rts
        
        +
        stz !enemytimer,x
        bra -
    }
    
    .touch: {
        lda !enemyvariable,x
        cmp !kendingscenedelay      ;wait for a bit to allow the player to
        bmi +                       ;appreciate hangin out on a cloud
        
        lda !kstatefadetoending
        sta !gamestate
        
        +
        rts
    }
    
    .animationtable: {
        ;this sucks
        dw  $0000, $0000, $0000, $0000, $0000, $0000, $0000, $0000, $0000, $0000,
            $0001, $0001, $0001, $0001, $0001, $0001, $0001, $0001, $0001, $0001,
            $0002, $0002, $0002, $0002, $0002, $0002, $0002, $0002, $0002, $0002,
            $0003, $0003, $0003, $0003, $0003, $0003, $0003, $0003, $0003, $0003,
            $0004, $0004, $0004, $0004, $0004, $0004, $0004, $0004, $0004, $0004,
            $0005, $0005, $0005, $0005, $0005, $0005, $0005, $0005, $0005, $0005,
            ;mirrored
            $0006, $0006, $0006, $0006, $0006, $0006, $0006, $0006, $0006, $0006,
            $0007, $0007, $0007, $0007, $0007, $0007, $0007, $0007, $0007, $0007,
            $0008, $0008, $0008, $0008, $0008, $0008, $0008, $0008, $0008, $0008,
            $0009, $0009, $0009, $0009, $0009, $0009, $0009, $0009, $0009, $0009,
            $000a, $000a, $000a, $000a, $000a, $000a, $000a, $000a, $000a, $000a,
            $000b, $000b, $000b, $000b, $000b, $000b, $000b, $000b, $000b, $000b,
           
           
            ;$000b, $000b, $000b, $000b, $000b, $000b, $000b, $000b, $000b, $000b,
            ;$000a, $000a, $000a, $000a, $000a, $000a, $000a, $000a, $000a, $000a,
            ;$0009, $0009, $0009, $0009, $0009, $0009, $0009, $0009, $0009, $0009,
            ;$0008, $0008, $0008, $0008, $0008, $0008, $0008, $0008, $0008, $0008,
            ;$0007, $0007, $0007, $0007, $0007, $0007, $0007, $0007, $0007, $0007,
            ;$0006, $0006, $0006, $0006, $0006, $0006, $0006, $0006, $0006, $0006,
           
            $8000
    }
}