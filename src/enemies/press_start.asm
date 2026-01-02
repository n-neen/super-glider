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
        ;!kup                        =       #$0800
        ;!kdn                        =       #$0400
        ;!klf                        =       #$0200
        ;!krt                        =       #$0100
        
        lda !gamestate
        cmp !kstatesplash       ;this gets used in title screen and credits
        bne ..noa               ;don't want to move the THE END sprite with controller
        
        lda !controller
        
        ;need to preserve A in all branches here
        bit !kup
        beq ..noup
        {
            ;if up pressed go here
            pha
            lda !enemyy,x
            cmp !kceiling-$18
            bmi +
            
            dec
            dec
            sta !enemyy,x
            
            +
            pla
        }
        ..noup:
        
        bit !kdn
        beq ..nodown
        {
            ;if down pressed go here
            pha
            lda !enemyy,x
            cmp !kfloor-$20
            bpl +
            
            inc
            inc
            sta !enemyy,x
            
            +
            pla
        }
        ..nodown:
        
        bit !klf
        beq ..noleft
        {
            ;if left pressed go here
            pha
            lda !enemyx,x
            cmp !kleftbound-$16
            bmi +
            
            dec
            dec
            sta !enemyx,x
            
            +
            pla
        }
        ..noleft:
        
        bit !krt
        beq ..noright
        {
            ;if right pressed go here
            pha
            lda !enemyx,x
            cmp !krightbound-$45
            bpl +
            
            inc
            inc
            sta !enemyx,x
            
            +
            pla
        }
        ..noright:
        
        bit !ka
        beq ..noa
        {
            ;if A pressed go here
            
        }
        ..noa:
        
        lda !nmicounter
        bit #$0003
        bne ..end
        
        phx
        
        sep #$30
        
        lda !nmicounter
        ora !enemyx,x
        and #$3e
        tax
        lda.l pressstart_triangletable+9,x
        sta !subscreenbackdropred
        +
        
        lda !nmicounter
        eor !enemyy,x
        beq ++
        and #$3e
        tax
        lda.l pressstart_triangletable+3,x
        sta !subscreenbackdropblue
        ++
        
        lda !nmicounter
        bit #$01
        beq +++
        and #$3e
        tax
        lda.l pressstart_triangletable,x
        sta !subscreenbackdropgreen
        +++
        
        rep #$30
        plx
        
        ..end:
        rts
    }
    
    .triangletable: {   ;$3e entries... plus some 0 cause i'm off by one i guess
                        ;oh and then double it, too, why not
        db $01,$02,$03,$04,$05,$06,$07,$08,$09,$0a,$0b,$0c,$0d,$0e,$0f,
           $11,$12,$13,$14,$15,$16,$17,$18,$19,$1a,$1b,$1c,$1d,$1e,$1f,
           $1f,$1e,$1d,$1c,$1b,$1a,$19,$18,$17,$16,$15,$14,$13,$12,$11,
           $0f,$0e,$0d,$0c,$0b,$0a,$09,$08,$07,$06,$05,$04,$03,$02,$01
        db $00, $00, $00
        
        db $01,$02,$03,$04,$05,$06,$07,$08,$09,$0a,$0b,$0c,$0d,$0e,$0f,
           $11,$12,$13,$14,$15,$16,$17,$18,$19,$1a,$1b,$1c,$1d,$1e,$1f,
           $1f,$1e,$1d,$1c,$1b,$1a,$19,$18,$17,$16,$15,$14,$13,$12,$11,
           $0f,$0e,$0d,$0c,$0b,$0a,$09,$08,$07,$06,$05,$04,$03,$02,$01
        db $00, $00, $00
           
    }
}