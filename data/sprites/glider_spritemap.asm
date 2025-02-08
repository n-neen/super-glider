        DW $000B                        ;number of entries
        DW $01E8 : DB $F8 : DW $0000
        DW $01E8 : DB $00 : DW $0010
        DW $01F0 : DB $F8 : DW $0001
        DW $01F0 : DB $00 : DW $0011
        DW $01F8 : DB $F8 : DW $0002
        DW $01F8 : DB $00 : DW $0012
        DW $0000 : DB $F8 : DW $0003
        DW $0000 : DB $00 : DW $0013
        DW $0008 : DB $F8 : DW $0004
        DW $0008 : DB $00 : DW $0014
        DW $0010 : DB $FC : DW $0005
        DW $FFFF

; a spritemap entry is:
;     s000000xxxxxxxxx yyyyyyyy YXppPPPttttttttt
; Where:
;     s = size bit
;     x = X offset of sprite from centre
;     y = Y offset of sprite from centre
;     Y = Y flip
;     X = X flip
;     P = palette
;     p = priority (relative to background)
;     t = tile number