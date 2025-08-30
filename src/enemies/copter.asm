copter: {
    .header:
        dw  spritemap_pointers_copter,  ;spritemaps
            $0030,                      ;xsize
            $0030,                      ;ysize
            $0000,                      ;init
            copter_main,                ;main
            enemy_touch_kill,           ;touch
            copter_shot                 ;shot
            
            
    .main: {
        jsr copter_movedown
        jsr copter_checkheight
        
        jsr copter_movelaterally
        jsr copter_checklateral
        
        lda !roomcounter
        bit #$0001
        bne +
        
        lda !enemytimer,x
        inc
        sta !enemytimer,x
        cmp #$0010
        beq ++
        
        -
        jsr copter_animate
    +   rts
    
    ++  stz !enemytimer,x
        bra -
    }
    
    .checklateral: {
        lda !enemyx,x
        cmp !kleftbound
        bmi ++
        
        lda !enemyx,x
        cmp !krightbound
        bpl +
        
        rts
        
        +
        lda !kleftbound+4
        sta !enemyx,x
        stz !enemyy,x
        rts
        
        ++
        lda !krightbound-4
        sta !enemyx,x
        stz !enemyy,x
        rts
        
    }
    
    .movelaterally: {
        !tempspeed      =   !localtempvar
        !tempsubspeed   =   !localtempvar2
        
        lda !enemyproperty,x
        and #$ff00
        xba
        sta !tempspeed
        
        lda !enemyproperty,x
        and #$00ff
        xba
        sta !tempsubspeed
        
        lda !enemysubx,x
        clc
        adc !tempsubspeed
        sta !enemysubx,x
        
        lda !enemyx,x
        adc !tempspeed
        sta !enemyx,x
        
        rts
    }
    
    .movedown: {
        !tempspeed      =   !localtempvar
        !tempsubspeed   =   !localtempvar2
        
        lda !enemyproperty3,x
        and #$ff00
        xba
        sta !tempspeed
        
        lda !enemyproperty3,x
        and #$00ff
        xba
        sta !tempsubspeed
        
        lda !enemysuby,x
        clc
        adc !tempsubspeed
        sta !enemysuby,x
        
        lda !enemyy,x
        adc !tempspeed
        sta !enemyy,x
        
        rts
    }
    
    .startwaiting: {
        lda !enemyproperty,x
        and #$ff00
        xba
        sta !enemytimer,x
        
        lda #copter_wait
        sta !enemymainptr,x
        
        rts
    }
    
    .wait: {
        dec !enemytimer,x
        beq +
        rts
        
        +
        stz !enemyy,x
        
        lda #copter_main
        sta !enemymainptr,x
        rts
    }
    
    .checkheight: {
        lda !enemyy,x
        cmp !kfloor
        bpl +
        rts
        
        +
        lda #$00e8
        sta !enemyy,x
        
        lda #copter_startwaiting
        sta !enemymainptr,x
        
        rts
    }
    
    .animate: {
        phy
        phb
        
        phk
        plb
        
        lda !enemytimer,x
        asl
        tay
        
        lda copter_animate_table,y
        clc
        adc #spritemap_pointers_copter
        sta !enemyspritemapptr,x
        
        plb
        ply
        rts
        
        
        ..table: {
            dw $0000,
               $0000,
               $0002,
               $0002,
               $0004,
               $0004,
               $0004,
               $0006,
               $0006,
               $0006,
               $0006,
               $0004,
               $0004,
               $0004,
               $0004,
               $0002,
               $0002,
               $0002
        }
    }
    
    .touch: {
        rts
    }
    
    .shot: {
        rts
    }

}