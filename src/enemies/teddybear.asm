teddy: {
    .header:
        dw  spritemap_pointers_teddy,  ;spritemaps
            $0000,                      ;xsize
            $0000,                      ;ysize
            $0000,                      ;init
            teddy_main,                 ;main
            teddy_touch,                ;touch
            teddy_shot                  ;shot
            
            
    .main: {
        rts
    }
    
    
    .touch: {
        rts
    }
    
    .shot: {
        rts
    }

}