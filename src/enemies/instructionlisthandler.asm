!instramstart           =       $1400
!instarraysize          =       !enemyarraysize         ;$0028 currently (and probably forever)
!instlistptr            =       !instramstart
!instptr                =       !instlistptr+!instarraysize
!insttimer              =       !instptr+!instarraysize




list: {
    .handler: {
        ;x = enemy index
        ;y = instruction list pointer
        
        ;when calling instructions, a = argument (previous in list)
        
        phb
        
        phk
        plb
        
        ldy !instlistptr,x
        
        lda !insttimer,x
        bne +
        
        ..nextentry:
        lda $0000,y
        bmi ..ptrtoinst         ;if negative, it's a pointer to an instruction
                                ;otherwise, it's a value for number of frames
        sta !insttimer,x
        iny : iny
        bra ..nextentry
        
        
        ..ptrtoinst:
        pha
        tya
        sta !instptr,x
        pla
        
        jsr (!instptr,x)
        iny : iny
        
        pha
        tya
        sta !instlistptr,x
        pla
        
        +
        plb
        rts
    }
    
    .dummy: {
        dw cat_pause
        dw $0008, #cat_pawspritemaps+0
        dw $0008, #cat_pawspritemaps+2
        dw $0008, #cat_pawspritemaps+4
        dw list_inst_goto, list_dummy
    }
    
    .inst: {
        ;common instructions
        ..goto: {
            lda $0002,y
            tay
            rts
        }
        
        ..setspritemap: {
            lda $0002,y
            sta !enemyspritemapptr,x
            iny : iny
            rts
        }
    }
}