;===========================================================================================
;====================================                 ======================================
;====================================  GLOBAL DEFINES ======================================
;====================================                 ======================================
;===========================================================================================

;todo: this:
;incsrc "./headers/globals.asm"

;vram map
!bg1start           =           $2000
!bg1tilemap         =           $6000           ;vram offset for bg1tilemap
!spritestart        =           $c000           ;sprite gfx

!bg2start           =           $0000
!bg2tilemap         =           $7000


;cgram map: start of palette chunk
!palettes           =           $0000
!spritepalette      =           $0080


;wram
!controller         =           $100


;start of oam table to dma at nmi
!oambuffer          =           $500


;glider ram
!gliderramstart     =       $0200
!gliderx            =       !gliderramstart
!glidery            =       !gliderramstart+2
!gliderstate        =       !gliderramstart+4
!gliderdir          =       !gliderramstart+6
!glidermovetimer    =       !gliderramstart+8
!gliderliftstate    =       !gliderramstart+10

;constants!!!!
!gliderstateidle    =       $0000
!gliderstateleft    =       $0001
!gliderstateright   =       $0002
!floor              =       $00d0
