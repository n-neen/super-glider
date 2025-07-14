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
!localtempvar3      =       $14
!localtempvar4      =       $16
!pausecounter       =       $18

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

!housestart         =       $800
!houseptr           =       !housestart
!roomptr            =       !housestart+2
!roomobjlistptr     =       !housestart+4
!roomenemylistptr   =       !housestart+6
!roombounds         =       !housestart+8
!roombg             =       !housestart+10



;object ram
!rowcounter         =       $06
!objdrawpointer     =       $08
!objdrawpalette     =       $0ff2
!rowlengthcounter   =       $0ff4
!objdrawnextline    =       $0ff6
!objdrawrows        =       $0ff8
!objdrawrowlength   =       $0ffa
!objdrawanchor      =       $0ffc
!nextobj            =       $0ffe

!objectarraystart   =       $1000
!objectarraysize    =       $0030
!objID              =       !objectarraystart
!objxsize           =       !objID+!objectarraysize
!objysize           =       !objxsize+!objectarraysize
!objtilemapointer   =       !objysize+!objectarraysize
!objxpos            =       !objtilemapointer+!objectarraysize
!objypos            =       !objxpos+!objectarraysize
!objpal             =       !objypos+!objectarraysize
!objroutineptr      =       !objpal+!objectarraysize


;arrays' ends       last define + !objectarraysize for total size






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
!kgliderxsubspeed           =       #$ffff      ;subpixel speed
!kgliderysubspeed           =       #$b000

!kgliderupbound             =       #$fff8
!kgliderdownbound           =       #$0010
!kgliderleftbound           =       #$fff8
!kgliderrightbound          =       #$0010

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
!kceiling                   =       #$0016
!kfloor                     =       #$00c9
!kleftbound                 =       #$0016
!krightbound                =       #$00d8

;controller bit constants
!kb                         =       #$8000
!ky                         =       #$4000
!ksl                        =       #$2000
!kst                        =       #$1000
!kup                        =       #$0800
!kdn                        =       #$0400
!klf                        =       #$0200
!krt                        =       #$0100
!ka                         =       #$0080
!kx                         =       #$0040
!kl                         =       #$0020
!kr                         =       #$0010

;game state constants

!kstatesplashsetup          =       #$0000
!kstatesplash               =       #$0001
!kstatenewgame              =       #$0002
!kstateplaygame             =       #$0003
!kstategameover             =       #$0004
!kstatedebug                =       #$0005
!kstateloadroom             =       #$0006
!kstatepause                =       #$0007

!kpausewait                 =       #$0030
