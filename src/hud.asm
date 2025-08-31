
hud: {
    .copytilemaptobuffer: {
        ;copy the initial hud tilemap to the wram buffer
        phx
        phb
        
        pea $8484       ;todo: fix hardcoded data bank
        plb : plb
        
        ldx #$0800
        
        -
        lda.w hud_data_tilemap,x
        sta.l !hudtilemaplong,x
        dex : dex
        bpl -
        
        plb
        plx
        rts
    }
    
    .uploadgfx: {
        ;load graphics from rom to vram
        
        lda.w #hud_data_gfx
        sta !dmasrcptr
        
        lda #$0084              ;hardcoded bank
        sta !dmasrcbank
        
        lda #$0500
        sta !dmasize
        
        lda.w #!bg3start
        sta !dmabaseaddr
        
        jsl dma_vramtransfur
        rts
    }
    
    .uploadtilemap: {
        ;upload tilemap from wram buffer to vram
        
        lda.w #!hudtilemapshort
        sta !dmasrcptr
        
        lda #$007f
        sta !dmasrcbank
        
        lda #$0800
        sta !dmasize
        
        lda.w #!bg3tilemap
        sta !dmabaseaddr
        
        jsl dma_vramtransfur
        rts
    }
    
    .requestupdate: {
        lda #$0001
        sta !hudupdateflag
        rts
    }
    
    .uploadtilemappartial: {
        ;upload tilemap from wram buffer to vram
        ;during gameplay we only want to do a few rows
        ;to save on cpu
        
        lda !hudupdateflag
        beq +
        
        lda.w #!hudtilemapshort
        sta !dmasrcptr
        
        lda #$007f
        sta !dmasrcbank
        
        lda #$0100
        sta !dmasize
        
        lda.w #!bg3tilemap
        sta !dmabaseaddr
        
        jsl dma_vramtransfur
        stz !hudupdateflag
        
    +   rts
    }
    
    
    .updatelives: {
        lda !gliderlives
        ldx #$007a
        jsl hud_drawthreedigitnumber
        rtl
    }
    
    
    .drawthreedigitnumber: {
        ;x = index into hud tilemap (one word per tile)
        ;a = number to draw
        ;number must be bcd
        
        phb
        
        phk
        plb
        
        pha
        pha
        and #$000f
        asl
        tay
        
        lda hud_charactertable,y
        sta !hudtilemaplong,x
        
        pla
        and #$00f0
        lsr #3
        tay
        
        lda hud_charactertable,y
        sta !hudtilemaplong-2,x
        
        pla
        and #$0f00
        xba
        asl
        tay
        
        lda hud_charactertable,y
        sta !hudtilemaplong-4,x
        
        lda #$0001
        sta !hudupdateflag
        
        plb
        rtl
    }
    
    
    .drawbattery: {
        ;battery $382a
        ;$74
        lda #$3c2a
        sta !hudtilemaplong+!kbatteryhudiconspot
        rts
    }
    
    
    .drawbands: {
        ;band $382b
        ;$76
        lda #$3c2b
        sta !hudtilemaplong+!kbandshudiconspot
        rts
    }
    
    
    .cleartile: {
        ;x=tile index
        lda #$3c0a
        sta !hudtilemaplong,x
        rts
    }
    
    
    .handleicons: {
        lda !gliderbatterytime
        bne +
        ;if 0:
        ldx #!kbatteryhudiconspot
        jsr hud_cleartile
        bra ++
        
        ;else:
    +   jsr hud_drawbattery
    
        ++
        lda !bandsammo
        bne +
        ;if 0:
        ldx #!kbandshudiconspot
        jsr hud_cleartile
        bra ++
        
        ;else:
    +   jsr hud_drawbands
    
        ++
        rtl
    }
    
    
    .charactertable: {
        dw $3c00,       ;0
           $3c01,       ;1
           $3c02,       ;2
           $3c03,       ;3
           $3c04,       ;4
           $3c05,       ;5
           $3c06,       ;6
           $3c07,       ;7
           $3c08,       ;8
           $3c09        ;9
           ;blank tile $3c0a
    }
}