section "Entry Point", rom0 [$0100]
  nop
  jp main

section "Cartridge Header (CHECKSUM)", rom0[$0104]
  ds $0150 - @, 0

section "Main Code", rom0 [$0150]
main:
.wait_vblank:
  ld a, [$ff44]
  cp 144
  jr c, .wait_vblank
 
  xor a
  ld [$ff40], a

  ld de, PressATiles.File
  ld hl, $8000
  ld bc, PressATiles.End - PressATiles.File

.copy_tiles:
  ld a, [de]
  ld [hli], a
  inc de
  dec bc
  ld a, b
  or a, c
  jp nz, .copy_tiles

  ld de, PressATilemap.File
  ld hl, $9800
  ld c, 18

.copy_tilemap:
.row:
  ld b, 20
.col:
  ld a, [de]
  ld [hli], a
  inc de
  dec b
  jp nz, .col

  ld a, l
  add a, 12
  ld l, a
  adc a, h
  sub l
  ld h, a

  dec c
  jr nz, .row

  ld a, (1 << 7) | (1 << 4) | (1 << 0)
  ld [$ff40], a

  ld a, %11100100
  ld [$ff47], a

;------------------------------------------------------
; Controle: https://gbdev.io/pandocs/Joypad_Input.html
;------------------------------------------------------
joypad:
.wait_vblank:
  ld a, [$ff44]
  cp 144
  jr c, .wait_vblank

.rot_p1:
  ld a, $10                 ; botões (A, B, Select, Start)
  ld [$ff00], a
  nop
  
  ld a, [$ff00]             ; leitura de estado
  and %00000001             ; isolar bit 0 (Botão 'A')
  jr z, .rot_print          ; É '0'? Sim, salte para '.rot_print'

  jp .wait_vblank           ; Aguarde, até eu pressionar

.rot_print:
.wait2_vblank:
  ld a, [$ff44]
  cp 144
  jr c, .wait2_vblank

  xor a
  ld [$FF40], a

  ld de, SuccessTile.File
  ld hl, $8000
  ld bc, SuccessTile.End - SuccessTile.File

.copy2_tiles:
  ld a, [de]
  ld [hli], a
  inc de
  dec bc
  ld a, b
  or a, c
  jr nz, .copy2_tiles

  ld de, SuccessTilemap.File
  ld hl, $9800
  ld c, 18

.copy2_tilemap:
.row2:
  ld b, 20
.col2:
  ld a, [de]
  ld [hli], a
  inc de
  dec b
  jp nz, .col2

  ld a, l 
  add a, 12
  ld l, a
  adc a, h
  sub l
  ld h, a 

  dec c
  jr nz, .row2

  ld a, (1 << 7) | (1 << 4) | (1 << 0)
  ld [$ff40], a

  ld a, %11100100
  ld [$ff47], a

end:
  jr end

section "Main Tile(map)s", rom0
PressATiles:
.File: incbin "tiles/controle.2bpp"
.End:
PressATilemap:
.File: incbin "tiles/controle.tilemap"
.End:
SuccessTile:
.File: incbin "tiles/sucesso.2bpp"
.End:
SuccessTilemap:
.File: incbin "tiles/sucesso.tilemap"
.End:
