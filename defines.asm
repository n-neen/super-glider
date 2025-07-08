;===========================================================================================
;====================================                 ======================================
;====================================      DEFINES    ======================================
;====================================                 ======================================
;===========================================================================================


;======================================   V  R A M   =======================================
;vram map
!bg1start           =       $2000
!bg1tilemap         =       $6000           ;vram offset for bg1tilemap
!spritestart        =       $c000           ;sprite gfx

!bg2start           =       $0000
!bg2tilemap         =       $7000


;=====================================   C G  R A M   ======================================
;cgram map: start of palette chunk
!palettes           =       $0000
!spritepalette      =       $0080


;=====================================   W  R A M   ========================================
!localtempvar       =       $10
!localtempvar2      =       $12

!oamentrypointbckp  =       $ec
!oamentrypoint      =       $ee
!numberofsprites    =       $f0                     ;used by oam routine
!spritemappointer   =       $f2
!oamhightableindex  =       $f4
!spriteindex        =       $f6

!controller         =       $100
!multresult         =       $102

;glider ram
!gliderramstart     =       $0200                   ;base address
!gliderx            =       !gliderramstart         ;x coord
!glidery            =       !gliderramstart+2       ;y coord
!gliderstate        =       !gliderramstart+4       ;movement state
!gliderdir          =       !gliderramstart+6       ;left or right (1 or 2)
!glidermovetimer    =       !gliderramstart+8       ;for moving left and right
!gliderliftstate    =       !gliderramstart+10      ;vent state: up down or the mysterious neither
!gliderturntimer    =       !gliderramstart+12      ;unimplemented
!gliderhitbound     =       !gliderramstart+14      ;boolean (zero or nonzero)
!gliderlives        =       !gliderramstart+16      ;int
!glidernextstate    =       !gliderramstart+18      ;next movement state
!glidersubx         =       !gliderramstart+20      ;subpixel x
!glidersuby         =       !gliderramstart+22      ;subpixel y
!gliderturntimer    =       !gliderramstart+24


;start of oam table to dma at nmi. 544 bytes long
!oambuffer          =       $500
!oamhightable       =       !oambuffer+$200
;end: $720


;object ram
!objectarraystart   =       $1000
!objectarraysize    =       $0030
!objID              =       !objectarraystart
!objsizex           =       !objID+!objectarraysize
!objsizey           =       !objsizex+!objectarraysize
!objtilemapointer   =       !objsizey+!objectarraysize
!objxcoord          =       !objtilemapointer+!objectarraysize
!objycoord          =       !objxcoord+!objectarraysize

;arrays' ends                   +!objectarraysize for total size




!objtilemapbuffer       =       $7f6000


;====================================   CONSTANTS   =======================================

;glider constants
!kgliderstateidle           =       #$0000
!kgliderstateleft           =       #$0001
!kgliderstateright          =       #$0002
!kgliderstatetipleft        =       #$0003
!kgliderstatetipright       =       #$0004
!kgliderstateturnaround     =       #$0005
!kgliderstatelostlife       =       #$0006
!kgliderxsubspeed           =       #$ff00      ;subpixel speed
!kgliderysubspeed           =       #$9c00

!kgliderdirleft             =       #$0001      ;i guess dir = 0 isn't a thing huh
!kgliderdirright            =       #$0002

!kliftstateidle             =       #$0000
!kliftstateup               =       #$0001
!kliftstatedown             =       #$0002

!kgliderturnamount          =       #$0008
!khitboundleft              =       #$0001
!khitboundright             =       #$0002
!kturnaroundcooldown        =       #$0010

;room constants
!kceiling                   =       #$0010
!kfloor                     =       #$00c8
!kleftbound                 =       #$0012
!krightbound                =       #$00d8

;controller bit constants
!kb                         =       #$8000
!ky                         =       #$4000
!kst                        =       #$2000
!ksl                        =       #$1000
!kup                        =       #$0800
!kdn                        =       #$0400
!klf                        =       #$0200
!krt                        =       #$0100
!ka                         =       #$0080
!kx                         =       #$0040
!kl                         =       #$0020
!kr                         =       #$0010
