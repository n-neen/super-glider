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

!controller         =       $100


;start of oam table to dma at nmi. 544 bytes long
!oambuffer          =       $500
;end: $720

;glider ram
!gliderramstart     =       $0200
!gliderx            =       !gliderramstart
!glidery            =       !gliderramstart+2
!gliderstate        =       !gliderramstart+4
!gliderdir          =       !gliderramstart+6
!glidermovetimer    =       !gliderramstart+8
!gliderliftstate    =       !gliderramstart+10
!gliderturntimer    =       !gliderramstart+12
!gliderhitbound     =       !gliderramstart+14


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

!objtilemap         =       $7f6000



;====================================   CONSTANTS   =======================================
!kgliderstateidle   =       #$0000
!kgliderstateleft   =       #$0001
!kgliderstateright  =       #$0002
!kfloor             =       #$00d0
!kgliderturnamount  =       #$0008
!kleftbound         =       #$0010
!krightbound        =       #$00d8
!khitboundleft      =       #$0001
!khitboundright     =       #$0002

;controller bits
!kb                 =       #$8000
!ky                 =       #$4000
!kst                =       #$2000
!ksl                =       #$1000
!kup                =       #$0800
!kdn                =       #$0400
!klf                =       #$0200
!krt                =       #$0100
!ka                 =       #$0080
!kx                 =       #$0040
!kl                 =       #$0020
!kr                 =       #$0010
