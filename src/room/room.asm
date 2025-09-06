room: {
    incsrc "./src/room/roomloading.asm"
    incsrc "./src/room/roomlist.asm"
    incsrc "./src/room/roomentries.asm"
    incsrc "./src/room/roomobjlists.asm"
    incsrc "./src/room/roomenemylists.asm"
}




;specialtilemaps_1&$7fff
;specialtilemaps_2&$7fff
;specialtilemaps_3&$7fff
;specialtilemaps_4&$7fff
;specialtilemaps_5&$7fff




;===========================================================================================
;=========================    H O U S E   F O R M A T   ====================================
;===========================================================================================

;the maximum room index supported is $ff. room link table entries would have to be changed
;in order to support more than that.
;todo: document what would need to be changed 

;room list: just a big list of rooms
    ;we do this so we can easily crawl through it with +1 or +$20

;room entries:
    
    ;pointer to object list in roomobjectlists.asm
    ;pointer to enemy list in roomenemylists.asm
    
    ;bounds, background field:
    ;#%ude000lrgggggggg
    ;g = background type
    ;l = left bound
    ;r = right bound
    ;u = up bound
    ;d = down bound
    ;e = ending room special vertical transition
        ;does an up transition but increments the roomindex by 1 instead of $20
        ;this also is the inverse of the other bounds bits!
        ;setting it /enables/ the transition type, not disables
    
    ;background types are defined in loading.asm
    
    ;special ptr:
    ;dw pointer         = pointer to routine in roomroutines.asm
    ;dw pointer&$7fff   = pointer to special tilemap in bank88.asm (label specialtilemaps)
    
;object lists:
    ;dw #obj_ptr_OBJNAME,   $xxxx, $yyyy, $pppp, $vvvv
     
    ;x = x position, in 8x8 pixel tiles
    ;y = y position, in same
    ;p = palette bitmask.
        ;more specifically, this is OR'd with the tilemap tile value when drawing
    ;v = variable. depends on the object what this is used for. for vents, it's height
    
    ;terminate the list with $ffff!
    
;enemy lists:
    ;dw enemy_ptr_TYPE, $xxxx, $yyyy, $1111, $22pp, $3333
    
    ;x = x position, in pixels
    ;y = y position, in same
    ;1 = property1
    ;2 = property 2 (one byte)
    ;p = palette bitmask
        ;OR'd with spritemap entry when drawing
    ;3 = property3
    
    ;for more info on enemy setup, see enemy_setup.txt
    
    ;terminate list with $ffff!