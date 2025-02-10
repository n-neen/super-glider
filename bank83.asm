lorom



;===========================================================================================
;=========================    H O U S E   F O R M A T   ====================================
;===========================================================================================
;currently sketching this out. tbd: everything


org $838000

    thehouse:                       ;house struct                   ;
        db $02                      ;number of rooms                ;1
        db $01                      ;starting room index            ;1
        dw #thehouse_roomlist       ;pointer to room list           ;2
        dw $0000                    ;reserved word                  ;2
        .roomlist:                  ;                               ;2*num
            dw #..room1
            dw #..room2
            ..room1:                    ;room struct                ;6
                db $00, $00             ;x, y                       ;2
                db $00                  ;background type            ;1
                db $00                  ;reserved byte              ;1
                dw #...objlist          ;pointer to object list     ;2
                    ...objlist:             ;object list            ;5*num
                        db $01              ;number of objects      ;1
                        db $01              ;object type            ;1
                        db $00,$00          ;object x,y             ;2
                        db $00              ;object reserved byte   ;1
            ..room2:                    ;room struct                ;6
                db $00, $00             ;x, y                       ;2
                db $00                  ;background type            ;1
                db $00                  ;reserved byte              ;1
                dw #...objlist          ;pointer to object list     ;2
                    ...objlist:             ;object list            ;5*num
                        db $01              ;number of objects      ;1
                        db $01              ;object type            ;1
                        db $00,$00          ;object x,y             ;2
                        db $00              ;object reserved byte   ;1