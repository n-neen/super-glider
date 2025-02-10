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


;===========================================================================================
;====================================                 ======================================
;====================================  GLOBAL DEFINES ======================================
;====================================                 ======================================
;===========================================================================================

;todo: this:
;incsrc "./headers/globals.asm"

;vram map
!bg1gfx             =           $0000
!bg1tilemap         =           $6000           ;vram offset for bg1tilemap
!spritestart        =           $c000


;cgram
!palettes           =           $0000


;wram
!controller         =           $100


;===========================================================================================
;===================================               =========================================
;===================================   B A N K S   =========================================
;===================================               =========================================
;===========================================================================================


incsrc "./bank80.asm"           ;main
incsrc "./bank81.asm"           ;dma, graphics and palette loading
incsrc "./bank82.asm"           ;palettes, graphics data
incsrc "./bank83.asm"           ;house, rooms
incsrc "./bank84.asm"           ;reserved for objects
incsrc "./bank85.asm"           ;splash screen graphics
incsrc "./bank86.asm"           ;splash screen tilemap


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