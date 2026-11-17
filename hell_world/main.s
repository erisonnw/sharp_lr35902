;------------------------------------------------------------------
; Cabeçalhos: https://gbdev.io/pandocs/The_Cartridge_Header.html
;------------------------------------------------------------------
section "Entry Point", rom0[$0100]
    nop
    jp main

section "Cartridge Header (CHECKSUM)", rom0[$0104]
    ds $0150 - @, 0

section "Main Code", rom0[$0150]
main:
;--------------------------------------------------------------------
; V-Blank: https://gbdev.io/pandocs/Reducing_Power_Consumption.html
;--------------------------------------------------------------------
.wait_vblank:
      ld a, [$ff44]         ; LY
      cp 144                ; compare com 144
      jr c, .wait_vblank    ; menor? continue esperando

      ;--------------------------------------------------
      ; Desligar LCD: https://gbdev.io/pandocs/LCDC.html
      ;--------------------------------------------------
      xor a
      ld [$ff40], a         ; LCDC zerado

      ;---------------------------------------------------;
      ; TileData: https://gbdev.io/pandocs/Tile_Data.html ;
      ;---------------------------------------------------;

      ; Copia Tiles para a VRAM
      ld de, TileData.File
      ld hl, $9000          ; Bloco 2 (background)
      ld bc, TileData.End - TileData.File

.copy_tiles:
      ld a, [de]
      ld [hli], a
      inc de
      dec bc
      ld a, b
      or a, c
      jp nz, .copy_tiles

      ;---------------------------------------------------
      ; Tile Map: https://gbdev.io/pandocs/Tile_Maps.html
      ;---------------------------------------------------
      ld de, TileMap.File
      ld hl, $9800              ; Início do Tile Map
      ld c, 18                  ; contador de 18 linhas

; 160 x 144 pixels
.copy_tilemap:
.row:
      ld b, 20                  ; contador de 20 colunas
.col:
      ; Faz leitura por colunas
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

      ;------------------------------------------------;
      ; Ligar LCD: https://gbdev.io/pandocs/LCDC.html  ;
      ;------------------------------------------------;
      ld a, (1 << 7) | (1 << 0)   ; Bit 7: Ligar LCD & Bit 0: Ativar BG
      ld [$ff40], a               ; Guardar no LCDC

      ;-------------------------------------------------;
      ; Palette: https://gbdev.io/pandocs/Palettes.html ;
      ;-------------------------------------------------;
      ld a, %11100100
      ld [$ff47], a               ; BGP (Background Palette)
end:
      jr end

section "Data Tile(map)", rom0
TileData:
.File:
  incbin "olamundo.2bpp"
.End:

TileMap:
.File:
  incbin "olamundo.tilemap"
.End:

