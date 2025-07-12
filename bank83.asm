lorom



;===========================================================================================
;=========================    H O U S E   F O R M A T   ====================================
;===========================================================================================
;tbd: everything


org $838000

room: {
    .load: {
    ;takes input:
        ;room pointer
    ;produces output:
        ;load object list
        ;write object tilemap buffer (layer 1)
        ;load background (layer 2)
        ;load enemies
        ;load prize sprites
    
    rtl
    }
}

roompopulation: {
    
}

objlist: {
    .dummy: {
        ;type                 x      y
        dw #obj_headers_vent, $0005, $0005
    }
}