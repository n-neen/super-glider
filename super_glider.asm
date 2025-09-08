lorom

;'-~,.__.,~-''-~,.__.,~-''-~,.__.,~-''-~,.__.,~-''-~,.__.,~-''-~,.__.,~-''-~,.__.,~-''-~,._;
;    ___________      ___      ___      __________    __________     __________            ;
;    \   _______\     \  \     \  \    \    ____  \   \   ______\    \   ____  \           ;
;     \  \             \  \     \  \    \   \___\  \   \  \           \  \   \  \          ;
;      \  \________     \  \     \  \    \   _______\   \  \_______    \  \   \__\         ;
;       \_________ \     \  \     \  \    \  \           \  _______\    \  \               ;
;                 \ \     \  \     \  \    \  \           \  \           \  \              ;
;         _________\ \     \  \_____\  \    \  \           \  \_______    \  \             ;
;         \___________\     \___________\    \__\           \_________\    \__\            ;
;                                                                                          ;
;                                                                                          ;
;           __________       ___             ___      __             ______      _______   ;
;         /  ________/      /  /            /  /     /\ \           / ____/     /  ___  \  ;
;        /  /              /  /            /  /     / /\ \         / /         /  /   \  \ ;
;       /  /              /  /            /  /     / /  \ \       / /___      /  /    /  / ;
;      /  /     ___      /  /            /  /     / /    \ \     / ____/     /  /____/  /  ;
;     /  /      \  \    /  /            /  /     / /     / /    / /         /   _    __/   ;
;    /  /       /  /   /  /            /  /     / /     / /    / /         /  /  \  \      ;
;   /  /_______/  /   /  /________    /  /     / /_____/ /    / /____     /  /    \  \     ;
;  /_____________/   /___________/   /__/     /_________/    /______/    /__/      \__\    ;
;                                                                                          ;
;                                                                                          ;
;'-~,.__.,~-''-~,.__.,~-''-~,.__.,~-''-~,.__.,~-''-~,.__.,~-''-~,.__.,~-''-~,.__.,~-''-~,._;

incsrc "./src/defines.asm"

;===========================================================================================
;===================================               =========================================
;===================================   B A N K S   =========================================
;===================================               =========================================
;===========================================================================================


org $808000
    incsrc "./src/main.asm"
    incsrc "./src/loading.asm"
    incsrc "./src/hud.asm"
    print "bank $80 end: ", pc
    
org $818000
    incsrc "./src/room/room.asm"
    print "bank $81 end: ", pc
    
org $828000
    incsrc "./src/gameplay.asm"
    incsrc "./src/glider.asm"
    incsrc "./src/bands.asm"
    
    incsrc "./src/enemies.asm"
    
    incsrc "./src/enemies/cat.asm"
    incsrc "./src/enemies/fish.asm"
    incsrc "./src/enemies/copter.asm"
    incsrc "./src/enemies/teddybear.asm"
    incsrc "./src/enemies/gfxloader.asm"
    incsrc "./src/enemies/star.asm"
    incsrc "./src/enemies/cutscenehandler.asm"
    
    incsrc "./src/enemies/instructionlisthandler.asm"       ;unfinished
    
    incsrc "./data/sprites/spritemaps.asm"
    incsrc "./src/roomroutines.asm"
    incsrc "./src/specialtilemaps.asm"
    print "bank $82 end: ", pc
    
org $838000
    incsrc "./src/objects.asm"
    incsrc "./src/openwall.asm"
    incsrc "./src/roomlink.asm"
    print "bank $83 end: ", pc
    

    
;data
incsrc "./data/inc/bank84.asm"          ;hud data, background graphics, enemy data
incsrc "./data/inc/bank85.asm"          ;sprite data: balloon, prizes, dart
incsrc "./data/inc/bank86.asm"          ;cat data
incsrc "./data/inc/bank87.asm"          ;background graphics
incsrc "./data/inc/bank88.asm"          ;special tilemaps
incsrc "./data/inc/bank89.asm"          ;enemy data
incsrc "./data/inc/bank8a.asm"          ;splash screen graphics
incsrc "./data/inc/bank8b.asm"          ;palettes, enemy data, background tilemaps
incsrc "./data/inc/bank8c.asm"          ;background graphics
incsrc "./data/inc/bank8d.asm"          ;background graphics
incsrc "./data/inc/bank8e.asm"          ;tile object graphics, background graphics
incsrc "./data/inc/bank8f.asm"          ;background graphics




;===========================================================================================
;==================================               ==========================================
;==================================  H E A D E R  ==========================================
;==================================               ==========================================
;===========================================================================================


org $80ffc0                             ;game header
    db "super glider         "          ;cartridge name
    db $30                              ;fastrom, lorom
    db $02                              ;rom + ram + sram
    db $09                              ;rom size = 512k
    db $00                              ;sram size 0
    db $00                              ;country code
    db $ff                              ;developer code
    db $00                              ;rom version
    dw $FFFF                            ;checksum complement
    dw $FFFF                            ;checksum
    
    ;interrupt vectors
    
    ;native mode
    dw #errhandle, #errhandle, #errhandle, #errhandle, #errhandle, #nmi, #errhandle, #irq
    
    ;emulation mode
    dw #errhandle, #errhandle, #errhandle, #errhandle, #errhandle, #errhandle, #boot, #errhandle