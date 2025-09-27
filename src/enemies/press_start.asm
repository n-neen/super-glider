pressstart: {
    .header:
        dw  spritemap_pointers_pressstart,  ;spritemaps
            $0000,                          ;xsize
            $0000,                          ;ysize
            $0000,                          ;init
            pressstart_main,                ;main
            $0000,                          ;touch
            $0000                           ;shot
            
    .main: {
        ;maybe it can do something
        rts
    }
}