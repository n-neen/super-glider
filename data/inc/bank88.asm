lorom

org $888000

;===========================================================================================
;===============================   SPECIAL TILEMAPS   ======================================
;===========================================================================================

dw $6969
;have to do this so that the pointer to specialtilemaps_1
;doesn't end up being zero. because we store it without the msb

specialtilemaps: {
    
    .1:
        incbin "./data/tilemaps/special/1ending_roof.map"
    .2:
        incbin "./data/tilemaps/special/2ending_stratosphere.map"
    .3:
        incbin "./data/tilemaps/special/3ending_end.map"
    
}

print "bank $88 end: ", pc