lorom

;===========================================================================================
;==============================  GLOBAL DEFINES  ===========================================
;===========================================================================================

;vram map
!bg1gfx             =           $0000
!bg1tilemap         =           $6000           ;vram offset for bg1tilemap
!spritestart        =           $c000



;cgram
!palettes           =           $0000


;===========================================================================================
;=================================  B A N K S  =============================================
;===========================================================================================

incsrc "./bank80.asm"
incsrc "./bank81.asm"
incsrc "./bank82.asm"
incsrc "./bank83.asm"
incsrc "./bank84.asm"
incsrc "./bank85.asm"
incsrc "./bank86.asm"


;===========================================================================================
;================================  H E A D E R  ============================================
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