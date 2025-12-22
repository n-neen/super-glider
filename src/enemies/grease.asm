grease: {
    .header: {
        dw  spritemap_pointers_grease,      ;spritemap ptr
            $0028,                          ;xsize,
            $0017,                          ;ysize,
            grease_init,                    ;init routine,
            grease_main,                    ;main routine,
            grease_touch,                   ;touch,
            grease_shot                     ;shot
    }
    
    
    .init: {
        ;property1 = spritemap selection
        ;grease jar left  = 0
        ;grease jar right = 2
        ;grease grease    = 4
        
        lda !enemyspritemapptr,x
        clc
        adc !enemyproperty,x
        sta !enemyspritemapptr,x
        rts
    }
    
    
    .main: {
        rts
    }
    
    
    .touch: {
        ;warn pc
        stz !gliderliftstate
        stz !glidertranstimer
        stz !gliderstairstimer
        
        ;stz !glidersuby
        
        lda !kglidergraphicsindexgreased
        sta !glidergraphicsindex
        
        rts
    }
    
    
    .shot: {
        rts
    }
}