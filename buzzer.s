	.arch armv6
	.eabi_attribute 28, 1
	.eabi_attribute 20, 1
	.eabi_attribute 21, 1
	.eabi_attribute 23, 3
	.eabi_attribute 24, 1
	.eabi_attribute 25, 1
	.eabi_attribute 26, 2
	.eabi_attribute 30, 6
	.eabi_attribute 34, 1
	.eabi_attribute 18, 4
	.file	"buzzer.c"
	.text
	.global	__aeabi_idiv
	.align	2
	.global	playTone
	.arch armv6
	.syntax unified
	.arm
	.fpu vfp
	.type	playTone, %function
playTone:
	@ args = 0, pretend = 0, frame = 24
	@ frame_needed = 1, uses_anonymous_args = 0
	push	{fp, lr}
	add	fp, sp, #4
	sub	sp, sp, #24
	str	r0, [fp, #-24]
	str	r1, [fp, #-28]
	ldr	r1, [fp, #-24]
	ldr	r0, .L4
	bl	__aeabi_idiv
	mov	r3, r0
	str	r3, [fp, #-12]
	ldr	r3, [fp, #-24]
	ldr	r2, [fp, #-28]
	mul	r3, r2, r3
	ldr	r2, .L4+4
	smull	r1, r2, r2, r3
	asr	r2, r2, #6
	asr	r3, r3, #31
	sub	r3, r2, r3
	str	r3, [fp, #-16]
	mov	r3, #0
	str	r3, [fp, #-8]
	b	.L2
.L3:
	mov	r1, #1
	mov	r0, #23
	bl	digitalWrite
	ldr	r3, [fp, #-12]
	mov	r0, r3
	bl	usleep
	mov	r1, #0
	mov	r0, #23
	bl	digitalWrite
	ldr	r3, [fp, #-12]
	mov	r0, r3
	bl	usleep
	ldr	r3, [fp, #-8]
	add	r3, r3, #1
	str	r3, [fp, #-8]
.L2:
	ldr	r2, [fp, #-8]
	ldr	r3, [fp, #-16]
	cmp	r2, r3
	blt	.L3
	nop
	nop
	sub	sp, fp, #4
	@ sp needed
	pop	{fp, pc}
.L5:
	.align	2
.L4:
	.word	500000
	.word	274877907
	.size	playTone, .-playTone
	.align	2
	.global	playHappyChime
	.syntax unified
	.arm
	.fpu vfp
	.type	playHappyChime, %function
playHappyChime:
	@ args = 0, pretend = 0, frame = 0
	@ frame_needed = 1, uses_anonymous_args = 0
	push	{fp, lr}
	add	fp, sp, #4
	mov	r1, #150
	ldr	r0, .L7
	bl	playTone
	ldr	r0, .L7+4
	bl	usleep
	mov	r1, #150
	ldr	r0, .L7+8
	bl	playTone
	ldr	r0, .L7+4
	bl	usleep
	mov	r1, #150
	mov	r0, #392
	bl	playTone
	ldr	r0, .L7+4
	bl	usleep
	mov	r1, #300
	ldr	r0, .L7+12
	bl	playTone
	nop
	pop	{fp, pc}
.L8:
	.align	2
.L7:
	.word	262
	.word	50000
	.word	330
	.word	523
	.size	playHappyChime, .-playHappyChime
	.align	2
	.global	playSadChime
	.syntax unified
	.arm
	.fpu vfp
	.type	playSadChime, %function
playSadChime:
	@ args = 0, pretend = 0, frame = 0
	@ frame_needed = 1, uses_anonymous_args = 0
	push	{fp, lr}
	add	fp, sp, #4
	mov	r1, #300
	mov	r0, #440
	bl	playTone
	ldr	r0, .L10
	bl	usleep
	mov	r1, #300
	ldr	r0, .L10+4
	bl	playTone
	ldr	r0, .L10
	bl	usleep
	mov	r1, #300
	ldr	r0, .L10+8
	bl	playTone
	ldr	r0, .L10
	bl	usleep
	mov	r1, #400
	ldr	r0, .L10+12
	bl	playTone
	nop
	pop	{fp, pc}
.L11:
	.align	2
.L10:
	.word	50000
	.word	349
	.word	294
	.word	262
	.size	playSadChime, .-playSadChime
	.align	2
	.global	main
	.syntax unified
	.arm
	.fpu vfp
	.type	main, %function
main:
	@ args = 0, pretend = 0, frame = 16
	@ frame_needed = 1, uses_anonymous_args = 0
	push	{fp, lr}
	add	fp, sp, #4
	sub	sp, sp, #16
	bl	wiringPiSetupGpio
	mov	r1, #1
	mov	r0, #23
	bl	pinMode
	mov	r3, #0
	str	r3, [fp, #-16]
	mov	r3, #0
	str	r3, [fp, #-8]
	mov	r3, #0
	str	r3, [fp, #-12]
.L15:
	mov	r0, #0
	bl	time
	str	r0, [fp, #-20]
	ldr	r3, [fp, #-16]
	cmp	r3, #0
	beq	.L13
	ldr	r2, [fp, #-20]
	ldr	r3, [fp, #-8]
	sub	r3, r2, r3
	cmp	r3, #9
	ble	.L13
	bl	playHappyChime
	ldr	r3, [fp, #-20]
	str	r3, [fp, #-8]
.L13:
	ldr	r3, [fp, #-16]
	cmp	r3, #0
	bne	.L14
	ldr	r2, [fp, #-20]
	ldr	r3, [fp, #-12]
	sub	r3, r2, r3
	cmp	r3, #9
	ble	.L14
	bl	playSadChime
	ldr	r3, [fp, #-20]
	str	r3, [fp, #-12]
.L14:
	mov	r0, #1
	bl	sleep
	b	.L15
	.size	main, .-main
	.ident	"GCC: (Raspbian 10.2.1-6+rpi1) 10.2.1 20210110"
	.section	.note.GNU-stack,"",%progbits
