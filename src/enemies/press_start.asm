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
        
        
        sep #$20
        
        lda !enemyx,x
        and #%00011111
        sta !subscreenbackdropred
        
        lda !enemyy,x
        and #%00011111
        sta !subscreenbackdropblue
        
        lda !nmicounter
        and #%00011111
        sta !subscreenbackdropgreen
        
        rep #$20
        
        
        rts
    }
}