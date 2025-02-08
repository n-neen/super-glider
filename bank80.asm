lorom

org $808000

boot:
    sei
    clc
    xce             ;enable native mode
    jml setbank     ;set bank to $80
    setbank:
    
    sep #$20
    lda #$01
    sta $420d       ;enable fastrom
    rep #$30
    
    ldx #$1fff
    txs             ;set initial stack pointer
    lda #$0000
    tcd             ;clear dp register

clear7e:
    pea $7e7e
    plb : plb
    ldx #$fffe
-   stz $0000,x     ;loop to clear all of $7e
    dex : dex       ;definitely don't jsr to here or you'll obliterate your return address lol
    bne -
    phk
    plb
    
    
init:
    .registers:
        sep #$30            ;<-------
        lda #$8f
        sta $2100           ;enable forced blank
        lda #$01
        sta $4200           ;enable joypad autoread
        rep #$30            ;<-------
        
        
        ldx #$000a
-       stz $4200,x         ;clear registers $4200-$420b
        dex : dex
        bne - 
        
        ldx #$0084          ;clear registers $2101-2184
--      stz $2101,x
        dex : dex
        bne --
        
        sep #$20            ;<-------
        lda #%00010001      ;main screen = sprites, L1, L2
        sta $212c           ;main screen turn on
        
        lda #%00000000      ;sprite size: 8x8 + 16x16; base address 0000
        sta $2101
        rep #$20            ;<-------
        
    .graphics:
        jsl clearvram
        jsl gliderload      ;see bank $81
        jsl palettetest
        jsl bg1test
        jsl tilemaptest
        
        sep #$20            ;<-------
        lda #$0f
        sta $2100           ;turn screen brightness on and disable forced blank
        rep #$20            ;<-------
        
main:   {
    .loop:
    lda $4212               ;wait until v-blank
    bmi .loop
    
    
    ;rest of program goes here
    inc $20
    
    
    bra .loop
} ;
    
    
    
    
    
    
    
nmi:
    rti
    
errhandle:
    jml errhandle
    
irq:
    rti
    
