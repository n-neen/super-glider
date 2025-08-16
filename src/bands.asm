
;===========================================================================================
;=====================================  B A N D S  =========================================
;===========================================================================================


!bandsbanklong        =   bands&$ff0000
!bandsbankword        =   !bandsbanklong>>8
!bandsbankshort       =   !bandsbanklong>>16

bands: {
    ;these are the generic rubber band routines
    ;for the movment and logic, etc of an individual
    ;rubber band, see enemy_instruction_band label
    
    .handle: {
        ;identify which enemy slots have bands in them
        ;handle enemy->band collision
        ;movement is handled in the enemy's main routine
        phx
        
        jsr bands_dotimer
        jsr bands_fire
        jsr bands_find
        
        ;collision happens like this:
        ;find band enemies in enemy array
        ;for each band found, calculate its hitbox and do collision
        ;for each collision check, check enemy array for nonempty, nonband slots
        ;then perform collision checks on each found
        
        plx
        rts
    }
    
    
    .dotimer: {
        lda !bandtimer
        beq +
        
        dec !bandtimer
        
        +
        rts
    }
    
    .find: {
        ldx #!enemyarraysize
        -
        lda !enemyID,x
        cmp #enemy_ptr_band
        bne +                   ;if enemy is a rubber band
        jsr bands_calchitbox
        jsr bands_collision     ;do collision checks on all other enemies
        +
        dex : dex
        bpl -
        rts
    }
    
    
    .fire: {
        phy
        phx
        
        lda !bandsammo
        beq +
        lda !fireband                   ;todo: make firing them not bad
        beq +
        lda !bandtimer
        bne +
        
        stz !fireband
        dec !bandsammo
        
        lda #enemy_ptr_band
        sta !enemydynamicspawnslot              ;0 = ptr
        
        lda !gliderx
        sta !enemydynamicspawnslot+2            ;2 = x
        
        lda !glidery
        sta !enemydynamicspawnslot+4            ;4 = y
        
        lda !gliderdir
        xba
        asl #7
        sta !enemydynamicspawnslot+6            ;6 = direction (property)
        
        lda !kbandspalette
        sta !enemydynamicspawnslot+8            ;8 = palette (property 2)
        
        ldy #!enemyarraysize
        -
        lda !enemyID,y
        beq ++
        
        dey : dey
        bpl -
        
        
        ++
        ldx #!enemydynamicspawnslot     ;x = pointer to enemy population entry in ram
        jsr enemy_spawn                 ;y = enemy index of open slot
        
    +   plx
        ply
        rts
    }
    
    
    .calchitbox: {
        ;x = enemy id of rubber band
        
        lda !enemyx,x           ;hitbox left edge
        clc
        adc #$ffe0
        sta !hitboxleft
        
        lda !enemyx,x           ;hitbox right edge
        clc
        adc #$0020
        sta !hitboxright
        
        lda !enemyy,x           ;hitbox top edge
        clc
        adc #$ffe0
        sta !hitboxtop
        
        lda !enemyy,x           ;hitbox bottom edge
        clc
        adc #$0018
        sta !hitboxbottom
        
        rts
    }
    
    .collision: {
        ;x = id of band, but we don't need it here, because the
        ;band's hitbox is now in !hitboxleft,right,up,down variables
        ;so we call enemy_collision_check
        ;with x = non-band enemy to check
        ;and hitbox variables set for the band
        phx
        
        ldx #!enemyarraysize
        -
        lda !enemyID,x
        beq +                       ;if enemy slot used
        cmp #enemy_ptr_band         ;and if it is not a band
        beq +
        jsr enemy_collision_check   ;do collision checks
        bcc +
        lda !enemyshotptr,x
        beq +
        jsr (!enemyshotptr,x)       ;if carry set, collision happened
        +                           ;run enemy shot routine
        dex : dex
        bpl -
        
        plx
        rts

    }
    
    
}