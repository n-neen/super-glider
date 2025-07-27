lorom

;'-~,.__.,~-''-~,.__.,~-''-~,.__.,~-''-~,.__.,~-''-~,.__.,~-''-~,.__.,~-''-~,.__.,~-''-~,._;
;              XXXXXXXXX   X           X   XXXXXXXX     XXXXXXX    XXXXXX                  ;
;              X           X           X   X       X    X          X     X                 ;
;              X           X           X   X        X   X          X     X                 ;   
;              X           X           X   X        X   X          X   X                   ;
;              X           X           X   X        X   XXXXXX     XXXX                    ;
;              X    XXXX   X           X   X        X   X          X   X                   ;
;              X       X   X           X   X        X   X          X    X                  ;
;              X       X   X           X   X       X    X          X     X                 ;
;              XXXXXXXXX   XXXXXXXXX   X   XXXXXXXX     XXXXXXX    X      X                ;
;'-~,.__.,~-''-~,.__.,~-''-~,.__.,~-''-~,.__.,~-''-~,.__.,~-''-~,.__.,~-''-~,.__.,~-''-~,._;

incsrc "./defines.asm"

;===========================================================================================
;===================================               =========================================
;===================================   B A N K S   =========================================
;===================================               =========================================
;===========================================================================================

;code
incsrc "./bank80.asm"           ;boot, main, interrupts, top level routines
incsrc "./bank81.asm"           ;dma, graphics and palette loading
incsrc "./bank82.asm"           ;gameplay, enemies, spritemaps
incsrc "./bank83.asm"           ;house, rooms definitions, room transitions
incsrc "./bank84.asm"           ;tile objects

;data

incsrc "./bank85.asm"           ;sprite data: balloon, prizes, dart
incsrc "./bank86.asm"           ;
incsrc "./bank87.asm"           ;
incsrc "./bank88.asm"           ;
incsrc "./bank89.asm"           ;
incsrc "./bank8a.asm"           ;splash screen graphics
incsrc "./bank8b.asm"           ;palettes, sprite data, background tilemaps
incsrc "./bank8c.asm"           ;background graphics
incsrc "./bank8d.asm"           ;background graphics
incsrc "./bank8e.asm"           ;tile object graphics
incsrc "./bank8f.asm"           ;background graphics




;===========================================================================================
;==================================               ==========================================
;==================================  H E A D E R  ==========================================
;==================================               ==========================================
;===========================================================================================


org $80ffc0                             ;game header
    db "glider pro           "          ;cartridge name
    db $30                              ;fastrom, lorom
    db $02                              ;rom + ram + sram
    db $12                              ;rom size = 4mb
    db $03                              ;sram size 4kb
    db $00                              ;country code
    db $69                              ;developer code
    db $00                              ;rom version
    dw $FFFF                            ;checksum complement
    dw $FFFF                            ;checksum
    
    ;interrupt vectors
    
    ;native mode
    dw #errhandle, #errhandle, #errhandle, #errhandle, #errhandle, #nmi, #errhandle, #irq
    
    ;emulation mode
    dw #errhandle, #errhandle, #errhandle, #errhandle, #errhandle, #errhandle, #boot, #errhandle