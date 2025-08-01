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

;one byte color math ppu register mirrors
!mainscreenlayers   =       $b0     ;$212c
!subscreenlayers    =       $b1     ;$212d
!colormathlayers    =       $b2     ;$2131
!colormathbackdrop  =       $b3     ;$2132
!colormathenable    =       $b4     ;$2130

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
!gliderturntimer    =       !gliderramstart+24      ;unimplemented
!gliderstairstimer  =       !gliderramstart+26      
!gliderstairstype   =       !gliderramstart+28      
!glidertranstimer   =       !gliderramstart+30      
!gliderhitboxleft   =       !gliderramstart+32      ;glider x position - hitbox size
!gliderhitboxright  =       !gliderramstart+34      ;glider x position + hitbox size
!gliderhitboxtop    =       !gliderramstart+36      ;glider y position - hitbox size
!gliderhitboxbottom =       !gliderramstart+38      ;glider y position + hitbox size
!points             =       !gliderramstart+40
!gliderbatterytime  =       !gliderramstart+42
!batterybool        =       !gliderramstart+44      ;boolean: zero or nonzero
!iframecounter      =       !gliderramstart+46


;enemy ram
!enemystart         =       $280
!enemyarraysize     =       $0028                   ;half of this is the number of enemy slots. initially this was $20 ($10 slots)
!enemyID            =       !enemystart             ;expanding to $30 runs into the oam table
!enemyx             =       !enemyID+!enemyarraysize+2
!enemyy             =       !enemyx+!enemyarraysize+2
!enemysubx          =       !enemyy+!enemyarraysize+2
!enemysuby          =       !enemysubx+!enemyarraysize+2
!enemyinitptr       =       !enemysuby+!enemyarraysize+2
!enemymainptr       =       !enemyinitptr+!enemyarraysize+2
!enemytouchptr      =       !enemymainptr+!enemyarraysize+2
!enemyproperty      =       !enemytouchptr+!enemyarraysize+2
!enemypal           =       !enemyproperty+!enemyarraysize+2
!enemyspritemapptr  =       !enemypal+!enemyarraysize+2
!enemyxsize         =       !enemyspritemapptr+!enemyarraysize+2
!enemyysize         =       !enemyxsize+!enemyarraysize+2

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
!roomtranstype      =       !housestart+12
!roomx              =       !housestart+14
!roomy              =       !housestart+16
!roomindex          =       !housestart+18
!ductoutputxpos     =       !housestart+20

;object ram
!rowcounter         =       $06
!objdrawpointer     =       $08

!stairleft          =       $0f00
!stairright         =       $0f02

!objdrawpalette     =       $0ff2
!rowlengthcounter   =       $0ff4
!objdrawnextline    =       $0ff6
!objdrawrows        =       $0ff8
!objdrawrowlength   =       $0ffa
!objdrawanchor      =       $0ffc
!nextobj            =       $0ffe

!objectarraystart   =       $1000
!objectarraysize    =       $0030
!objID              =       !objectarraystart+2
!objxsize           =       !objID+!objectarraysize+2
!objysize           =       !objxsize+!objectarraysize+2
!objtilemapointer   =       !objysize+!objectarraysize+2
!objxpos            =       !objtilemapointer+!objectarraysize+2
!objypos            =       !objxpos+!objectarraysize+2
!objpal             =       !objypos+!objectarraysize+2
!objroutineptr      =       !objpal+!objectarraysize+2
!objproperty        =       !objroutineptr+!objectarraysize+2
!objvariable        =       !objproperty+!objectarraysize+2

!objdyntilemap      =       $730

;arrays' ends       last define + !objectarraysize for total size





;if you ever want to change these, be prepared to change
;all the non-automatic stuff like the object draw routine
!objtilemap             =       $7f6000
!layer2tilemap          =       $7f0000


;====================================   CONSTANTS   =======================================

;glider constants
!kgliderstateidle           =       #$0000
!kgliderstateleft           =       #$0001
!kgliderstateright          =       #$0002
!kgliderstatetipleft        =       #$0003
!kgliderstatetipright       =       #$0004
!kgliderstateturnaround     =       #$0005
!kgliderstatelostlife       =       #$0006
!kgliderxsubspeed           =       #$7f00      ;subpixel speed
!kgliderysubspeed           =       #$a000

!kglideriframes             =       #$0060

!kbatteryon                 =       #$0001
!kbatteryoff                =       #$0000

!kgliderupbound             =       #$fff8      ;for object collision
!kgliderdownbound           =       #$0010
!kgliderleftbound           =       #$fff0
!kgliderrightbound          =       #$0010

!kgliderenemybox            =       $0008      ;amount to increase for enemy-glider collision only

!kgliderdirleft             =       #$0001     ;i guess dir = 0 isn't a thing huh
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
!kleftbound                 =       #$0018      ;18
!krightbound                =       #$00d8      ;d8

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
!kstateplaygame8            =       #$03
!kstategameover             =       #$0004
!kstatedebug                =       #$0005
!kstateloadroom             =       #$0006
!kstatepause                =       #$0007
!kstateroomtrans            =       #$0008

!kpausewait                 =       #$0030

;room loading constants:
;how far into the room header are these things:

!kroomobjlist               =       $0000
!kroomenemylist             =       $0002
!kroombgtype                =       $0004
!kroombounds                =       $0006

!kroomtranstyperight        =       #$0000
!kroomtranstypeleft         =       #$0001
!kroomtranstypeup           =       #$0002
!kroomtranstypedown         =       #$0003
!kroomtranstypeduct         =       #$0004
!ktranstimer                =       #$0030

;object constants

!kobjectentrylength         =       #$000a
;length of one object list entry


;enemy constants

!kdartsubspeed              =       #$8000
!kdartspeed                 =       #$0001
