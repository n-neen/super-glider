cutscenehandler: {
    .header:
        dw  spritemap_pointers_null,    ;spritemaps
            $0000,                      ;xsize
            $0000,                      ;ysize
            $0000,                      ;init
            cutscenehandler_main,       ;main
            $0000,                      ;touch
            $0000                       ;shot
    
    
    .main: {
        stz !gliderstairstimer
        
        lda !enemyproperty,x            ;set this if the last room
        bmi +
        -
        
        lda !glidersuby
        sec
        sbc #$9000
        sta !glidersuby
        
        lda !glidery
        sbc #$0001
        sta !glidery
        
        rts
        
        +
        lda !glidery
        cmp #$0030
        bpl -
        
        ;if at desired height
        ;uhhhhhhhhhhhhhhhhhhhhhhhhhhhhh
        lda !glidersuby
        clc
        adc #$f000
        sta !glidersuby
        lda !glidery
        adc #$0003
        sta !glidery
        ++
        rts
        
    }
    
}