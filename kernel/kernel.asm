
kernel/kernel:     file format elf64-littleriscv


Disassembly of section .text:

0000000080000000 <_entry>:
    80000000:	00009117          	auipc	sp,0x9
    80000004:	8a013103          	ld	sp,-1888(sp) # 800088a0 <_GLOBAL_OFFSET_TABLE_+0x8>
    80000008:	6505                	lui	a0,0x1
    8000000a:	f14025f3          	csrr	a1,mhartid
    8000000e:	0585                	addi	a1,a1,1
    80000010:	02b50533          	mul	a0,a0,a1
    80000014:	912a                	add	sp,sp,a0
    80000016:	076000ef          	jal	ra,8000008c <start>

000000008000001a <spin>:
    8000001a:	a001                	j	8000001a <spin>

000000008000001c <timerinit>:
// at timervec in kernelvec.S,
// which turns them into software interrupts for
// devintr() in trap.c.
void
timerinit()
{
    8000001c:	1141                	addi	sp,sp,-16
    8000001e:	e422                	sd	s0,8(sp)
    80000020:	0800                	addi	s0,sp,16
// which hart (core) is this?
static inline uint64
r_mhartid()
{
  uint64 x;
  asm volatile("csrr %0, mhartid" : "=r" (x) );
    80000022:	f14027f3          	csrr	a5,mhartid
  // each CPU has a separate source of timer interrupts.
  int id = r_mhartid();
    80000026:	0007859b          	sext.w	a1,a5

  // ask the CLINT for a timer interrupt.
  int interval = 1000000; // cycles; about 1/10th second in qemu.
  *(uint64*)CLINT_MTIMECMP(id) = *(uint64*)CLINT_MTIME + interval;
    8000002a:	0037979b          	slliw	a5,a5,0x3
    8000002e:	02004737          	lui	a4,0x2004
    80000032:	97ba                	add	a5,a5,a4
    80000034:	0200c737          	lui	a4,0x200c
    80000038:	ff873703          	ld	a4,-8(a4) # 200bff8 <_entry-0x7dff4008>
    8000003c:	000f4637          	lui	a2,0xf4
    80000040:	24060613          	addi	a2,a2,576 # f4240 <_entry-0x7ff0bdc0>
    80000044:	9732                	add	a4,a4,a2
    80000046:	e398                	sd	a4,0(a5)

  // prepare information in scratch[] for timervec.
  // scratch[0..2] : space for timervec to save registers.
  // scratch[3] : address of CLINT MTIMECMP register.
  // scratch[4] : desired interval (in cycles) between timer interrupts.
  uint64 *scratch = &timer_scratch[id][0];
    80000048:	00259693          	slli	a3,a1,0x2
    8000004c:	96ae                	add	a3,a3,a1
    8000004e:	068e                	slli	a3,a3,0x3
    80000050:	00009717          	auipc	a4,0x9
    80000054:	8b070713          	addi	a4,a4,-1872 # 80008900 <timer_scratch>
    80000058:	9736                	add	a4,a4,a3
  scratch[3] = CLINT_MTIMECMP(id);
    8000005a:	ef1c                	sd	a5,24(a4)
  scratch[4] = interval;
    8000005c:	f310                	sd	a2,32(a4)
}

static inline void 
w_mscratch(uint64 x)
{
  asm volatile("csrw mscratch, %0" : : "r" (x));
    8000005e:	34071073          	csrw	mscratch,a4
  asm volatile("csrw mtvec, %0" : : "r" (x));
    80000062:	00006797          	auipc	a5,0x6
    80000066:	dfe78793          	addi	a5,a5,-514 # 80005e60 <timervec>
    8000006a:	30579073          	csrw	mtvec,a5
  asm volatile("csrr %0, mstatus" : "=r" (x) );
    8000006e:	300027f3          	csrr	a5,mstatus

  // set the machine-mode trap handler.
  w_mtvec((uint64)timervec);

  // enable machine-mode interrupts.
  w_mstatus(r_mstatus() | MSTATUS_MIE);
    80000072:	0087e793          	ori	a5,a5,8
  asm volatile("csrw mstatus, %0" : : "r" (x));
    80000076:	30079073          	csrw	mstatus,a5
  asm volatile("csrr %0, mie" : "=r" (x) );
    8000007a:	304027f3          	csrr	a5,mie

  // enable machine-mode timer interrupts.
  w_mie(r_mie() | MIE_MTIE);
    8000007e:	0807e793          	ori	a5,a5,128
  asm volatile("csrw mie, %0" : : "r" (x));
    80000082:	30479073          	csrw	mie,a5
}
    80000086:	6422                	ld	s0,8(sp)
    80000088:	0141                	addi	sp,sp,16
    8000008a:	8082                	ret

000000008000008c <start>:
{
    8000008c:	1141                	addi	sp,sp,-16
    8000008e:	e406                	sd	ra,8(sp)
    80000090:	e022                	sd	s0,0(sp)
    80000092:	0800                	addi	s0,sp,16
  asm volatile("csrr %0, mstatus" : "=r" (x) );
    80000094:	300027f3          	csrr	a5,mstatus
  x &= ~MSTATUS_MPP_MASK;
    80000098:	7779                	lui	a4,0xffffe
    8000009a:	7ff70713          	addi	a4,a4,2047 # ffffffffffffe7ff <end+0xffffffff7ffdc877>
    8000009e:	8ff9                	and	a5,a5,a4
  x |= MSTATUS_MPP_S;
    800000a0:	6705                	lui	a4,0x1
    800000a2:	80070713          	addi	a4,a4,-2048 # 800 <_entry-0x7ffff800>
    800000a6:	8fd9                	or	a5,a5,a4
  asm volatile("csrw mstatus, %0" : : "r" (x));
    800000a8:	30079073          	csrw	mstatus,a5
  asm volatile("csrw mepc, %0" : : "r" (x));
    800000ac:	00001797          	auipc	a5,0x1
    800000b0:	dcc78793          	addi	a5,a5,-564 # 80000e78 <main>
    800000b4:	34179073          	csrw	mepc,a5
  asm volatile("csrw satp, %0" : : "r" (x));
    800000b8:	4781                	li	a5,0
    800000ba:	18079073          	csrw	satp,a5
  asm volatile("csrw medeleg, %0" : : "r" (x));
    800000be:	67c1                	lui	a5,0x10
    800000c0:	17fd                	addi	a5,a5,-1 # ffff <_entry-0x7fff0001>
    800000c2:	30279073          	csrw	medeleg,a5
  asm volatile("csrw mideleg, %0" : : "r" (x));
    800000c6:	30379073          	csrw	mideleg,a5
  asm volatile("csrr %0, sie" : "=r" (x) );
    800000ca:	104027f3          	csrr	a5,sie
  w_sie(r_sie() | SIE_SEIE | SIE_STIE | SIE_SSIE);
    800000ce:	2227e793          	ori	a5,a5,546
  asm volatile("csrw sie, %0" : : "r" (x));
    800000d2:	10479073          	csrw	sie,a5
  asm volatile("csrw pmpaddr0, %0" : : "r" (x));
    800000d6:	57fd                	li	a5,-1
    800000d8:	83a9                	srli	a5,a5,0xa
    800000da:	3b079073          	csrw	pmpaddr0,a5
  asm volatile("csrw pmpcfg0, %0" : : "r" (x));
    800000de:	47bd                	li	a5,15
    800000e0:	3a079073          	csrw	pmpcfg0,a5
  timerinit();
    800000e4:	00000097          	auipc	ra,0x0
    800000e8:	f38080e7          	jalr	-200(ra) # 8000001c <timerinit>
  asm volatile("csrr %0, mhartid" : "=r" (x) );
    800000ec:	f14027f3          	csrr	a5,mhartid
  w_tp(id);
    800000f0:	2781                	sext.w	a5,a5
}

static inline void 
w_tp(uint64 x)
{
  asm volatile("mv tp, %0" : : "r" (x));
    800000f2:	823e                	mv	tp,a5
  asm volatile("mret");
    800000f4:	30200073          	mret
}
    800000f8:	60a2                	ld	ra,8(sp)
    800000fa:	6402                	ld	s0,0(sp)
    800000fc:	0141                	addi	sp,sp,16
    800000fe:	8082                	ret

0000000080000100 <consolewrite>:
//
// user write()s to the console go here.
//
int
consolewrite(int user_src, uint64 src, int n)
{
    80000100:	715d                	addi	sp,sp,-80
    80000102:	e486                	sd	ra,72(sp)
    80000104:	e0a2                	sd	s0,64(sp)
    80000106:	fc26                	sd	s1,56(sp)
    80000108:	f84a                	sd	s2,48(sp)
    8000010a:	f44e                	sd	s3,40(sp)
    8000010c:	f052                	sd	s4,32(sp)
    8000010e:	ec56                	sd	s5,24(sp)
    80000110:	0880                	addi	s0,sp,80
  int i;

  for(i = 0; i < n; i++){
    80000112:	04c05763          	blez	a2,80000160 <consolewrite+0x60>
    80000116:	8a2a                	mv	s4,a0
    80000118:	84ae                	mv	s1,a1
    8000011a:	89b2                	mv	s3,a2
    8000011c:	4901                	li	s2,0
    char c;
    if(either_copyin(&c, user_src, src+i, 1) == -1)
    8000011e:	5afd                	li	s5,-1
    80000120:	4685                	li	a3,1
    80000122:	8626                	mv	a2,s1
    80000124:	85d2                	mv	a1,s4
    80000126:	fbf40513          	addi	a0,s0,-65
    8000012a:	00002097          	auipc	ra,0x2
    8000012e:	3fe080e7          	jalr	1022(ra) # 80002528 <either_copyin>
    80000132:	01550d63          	beq	a0,s5,8000014c <consolewrite+0x4c>
      break;
    uartputc(c);
    80000136:	fbf44503          	lbu	a0,-65(s0)
    8000013a:	00000097          	auipc	ra,0x0
    8000013e:	784080e7          	jalr	1924(ra) # 800008be <uartputc>
  for(i = 0; i < n; i++){
    80000142:	2905                	addiw	s2,s2,1
    80000144:	0485                	addi	s1,s1,1
    80000146:	fd299de3          	bne	s3,s2,80000120 <consolewrite+0x20>
    8000014a:	894e                	mv	s2,s3
  }

  return i;
}
    8000014c:	854a                	mv	a0,s2
    8000014e:	60a6                	ld	ra,72(sp)
    80000150:	6406                	ld	s0,64(sp)
    80000152:	74e2                	ld	s1,56(sp)
    80000154:	7942                	ld	s2,48(sp)
    80000156:	79a2                	ld	s3,40(sp)
    80000158:	7a02                	ld	s4,32(sp)
    8000015a:	6ae2                	ld	s5,24(sp)
    8000015c:	6161                	addi	sp,sp,80
    8000015e:	8082                	ret
  for(i = 0; i < n; i++){
    80000160:	4901                	li	s2,0
    80000162:	b7ed                	j	8000014c <consolewrite+0x4c>

0000000080000164 <consoleread>:
// user_dist indicates whether dst is a user
// or kernel address.
//
int
consoleread(int user_dst, uint64 dst, int n)
{
    80000164:	7159                	addi	sp,sp,-112
    80000166:	f486                	sd	ra,104(sp)
    80000168:	f0a2                	sd	s0,96(sp)
    8000016a:	eca6                	sd	s1,88(sp)
    8000016c:	e8ca                	sd	s2,80(sp)
    8000016e:	e4ce                	sd	s3,72(sp)
    80000170:	e0d2                	sd	s4,64(sp)
    80000172:	fc56                	sd	s5,56(sp)
    80000174:	f85a                	sd	s6,48(sp)
    80000176:	f45e                	sd	s7,40(sp)
    80000178:	f062                	sd	s8,32(sp)
    8000017a:	ec66                	sd	s9,24(sp)
    8000017c:	e86a                	sd	s10,16(sp)
    8000017e:	1880                	addi	s0,sp,112
    80000180:	8aaa                	mv	s5,a0
    80000182:	8a2e                	mv	s4,a1
    80000184:	89b2                	mv	s3,a2
  uint target;
  int c;
  char cbuf;

  target = n;
    80000186:	00060b1b          	sext.w	s6,a2
  acquire(&cons.lock);
    8000018a:	00011517          	auipc	a0,0x11
    8000018e:	8b650513          	addi	a0,a0,-1866 # 80010a40 <cons>
    80000192:	00001097          	auipc	ra,0x1
    80000196:	a44080e7          	jalr	-1468(ra) # 80000bd6 <acquire>
  while(n > 0){
    // wait until interrupt handler has put some
    // input into cons.buffer.
    while(cons.r == cons.w){
    8000019a:	00011497          	auipc	s1,0x11
    8000019e:	8a648493          	addi	s1,s1,-1882 # 80010a40 <cons>
      if(killed(myproc())){
        release(&cons.lock);
        return -1;
      }
      sleep(&cons.r, &cons.lock);
    800001a2:	00011917          	auipc	s2,0x11
    800001a6:	93690913          	addi	s2,s2,-1738 # 80010ad8 <cons+0x98>
    }

    c = cons.buf[cons.r++ % INPUT_BUF_SIZE];

    if(c == C('D')){  // end-of-file
    800001aa:	4b91                	li	s7,4
      break;
    }

    // copy the input byte to the user-space buffer.
    cbuf = c;
    if(either_copyout(user_dst, dst, &cbuf, 1) == -1)
    800001ac:	5c7d                	li	s8,-1
      break;

    dst++;
    --n;

    if(c == '\n'){
    800001ae:	4ca9                	li	s9,10
  while(n > 0){
    800001b0:	07305b63          	blez	s3,80000226 <consoleread+0xc2>
    while(cons.r == cons.w){
    800001b4:	0984a783          	lw	a5,152(s1)
    800001b8:	09c4a703          	lw	a4,156(s1)
    800001bc:	02f71763          	bne	a4,a5,800001ea <consoleread+0x86>
      if(killed(myproc())){
    800001c0:	00001097          	auipc	ra,0x1
    800001c4:	7ec080e7          	jalr	2028(ra) # 800019ac <myproc>
    800001c8:	00002097          	auipc	ra,0x2
    800001cc:	1aa080e7          	jalr	426(ra) # 80002372 <killed>
    800001d0:	e535                	bnez	a0,8000023c <consoleread+0xd8>
      sleep(&cons.r, &cons.lock);
    800001d2:	85a6                	mv	a1,s1
    800001d4:	854a                	mv	a0,s2
    800001d6:	00002097          	auipc	ra,0x2
    800001da:	eec080e7          	jalr	-276(ra) # 800020c2 <sleep>
    while(cons.r == cons.w){
    800001de:	0984a783          	lw	a5,152(s1)
    800001e2:	09c4a703          	lw	a4,156(s1)
    800001e6:	fcf70de3          	beq	a4,a5,800001c0 <consoleread+0x5c>
    c = cons.buf[cons.r++ % INPUT_BUF_SIZE];
    800001ea:	0017871b          	addiw	a4,a5,1
    800001ee:	08e4ac23          	sw	a4,152(s1)
    800001f2:	07f7f713          	andi	a4,a5,127
    800001f6:	9726                	add	a4,a4,s1
    800001f8:	01874703          	lbu	a4,24(a4)
    800001fc:	00070d1b          	sext.w	s10,a4
    if(c == C('D')){  // end-of-file
    80000200:	077d0563          	beq	s10,s7,8000026a <consoleread+0x106>
    cbuf = c;
    80000204:	f8e40fa3          	sb	a4,-97(s0)
    if(either_copyout(user_dst, dst, &cbuf, 1) == -1)
    80000208:	4685                	li	a3,1
    8000020a:	f9f40613          	addi	a2,s0,-97
    8000020e:	85d2                	mv	a1,s4
    80000210:	8556                	mv	a0,s5
    80000212:	00002097          	auipc	ra,0x2
    80000216:	2c0080e7          	jalr	704(ra) # 800024d2 <either_copyout>
    8000021a:	01850663          	beq	a0,s8,80000226 <consoleread+0xc2>
    dst++;
    8000021e:	0a05                	addi	s4,s4,1
    --n;
    80000220:	39fd                	addiw	s3,s3,-1
    if(c == '\n'){
    80000222:	f99d17e3          	bne	s10,s9,800001b0 <consoleread+0x4c>
      // a whole line has arrived, return to
      // the user-level read().
      break;
    }
  }
  release(&cons.lock);
    80000226:	00011517          	auipc	a0,0x11
    8000022a:	81a50513          	addi	a0,a0,-2022 # 80010a40 <cons>
    8000022e:	00001097          	auipc	ra,0x1
    80000232:	a5c080e7          	jalr	-1444(ra) # 80000c8a <release>

  return target - n;
    80000236:	413b053b          	subw	a0,s6,s3
    8000023a:	a811                	j	8000024e <consoleread+0xea>
        release(&cons.lock);
    8000023c:	00011517          	auipc	a0,0x11
    80000240:	80450513          	addi	a0,a0,-2044 # 80010a40 <cons>
    80000244:	00001097          	auipc	ra,0x1
    80000248:	a46080e7          	jalr	-1466(ra) # 80000c8a <release>
        return -1;
    8000024c:	557d                	li	a0,-1
}
    8000024e:	70a6                	ld	ra,104(sp)
    80000250:	7406                	ld	s0,96(sp)
    80000252:	64e6                	ld	s1,88(sp)
    80000254:	6946                	ld	s2,80(sp)
    80000256:	69a6                	ld	s3,72(sp)
    80000258:	6a06                	ld	s4,64(sp)
    8000025a:	7ae2                	ld	s5,56(sp)
    8000025c:	7b42                	ld	s6,48(sp)
    8000025e:	7ba2                	ld	s7,40(sp)
    80000260:	7c02                	ld	s8,32(sp)
    80000262:	6ce2                	ld	s9,24(sp)
    80000264:	6d42                	ld	s10,16(sp)
    80000266:	6165                	addi	sp,sp,112
    80000268:	8082                	ret
      if(n < target){
    8000026a:	0009871b          	sext.w	a4,s3
    8000026e:	fb677ce3          	bgeu	a4,s6,80000226 <consoleread+0xc2>
        cons.r--;
    80000272:	00011717          	auipc	a4,0x11
    80000276:	86f72323          	sw	a5,-1946(a4) # 80010ad8 <cons+0x98>
    8000027a:	b775                	j	80000226 <consoleread+0xc2>

000000008000027c <consputc>:
{
    8000027c:	1141                	addi	sp,sp,-16
    8000027e:	e406                	sd	ra,8(sp)
    80000280:	e022                	sd	s0,0(sp)
    80000282:	0800                	addi	s0,sp,16
  if(c == BACKSPACE){
    80000284:	10000793          	li	a5,256
    80000288:	00f50a63          	beq	a0,a5,8000029c <consputc+0x20>
    uartputc_sync(c);
    8000028c:	00000097          	auipc	ra,0x0
    80000290:	560080e7          	jalr	1376(ra) # 800007ec <uartputc_sync>
}
    80000294:	60a2                	ld	ra,8(sp)
    80000296:	6402                	ld	s0,0(sp)
    80000298:	0141                	addi	sp,sp,16
    8000029a:	8082                	ret
    uartputc_sync('\b'); uartputc_sync(' '); uartputc_sync('\b');
    8000029c:	4521                	li	a0,8
    8000029e:	00000097          	auipc	ra,0x0
    800002a2:	54e080e7          	jalr	1358(ra) # 800007ec <uartputc_sync>
    800002a6:	02000513          	li	a0,32
    800002aa:	00000097          	auipc	ra,0x0
    800002ae:	542080e7          	jalr	1346(ra) # 800007ec <uartputc_sync>
    800002b2:	4521                	li	a0,8
    800002b4:	00000097          	auipc	ra,0x0
    800002b8:	538080e7          	jalr	1336(ra) # 800007ec <uartputc_sync>
    800002bc:	bfe1                	j	80000294 <consputc+0x18>

00000000800002be <consoleintr>:
// do erase/kill processing, append to cons.buf,
// wake up consoleread() if a whole line has arrived.
//
void
consoleintr(int c)
{
    800002be:	1101                	addi	sp,sp,-32
    800002c0:	ec06                	sd	ra,24(sp)
    800002c2:	e822                	sd	s0,16(sp)
    800002c4:	e426                	sd	s1,8(sp)
    800002c6:	e04a                	sd	s2,0(sp)
    800002c8:	1000                	addi	s0,sp,32
    800002ca:	84aa                	mv	s1,a0
  acquire(&cons.lock);
    800002cc:	00010517          	auipc	a0,0x10
    800002d0:	77450513          	addi	a0,a0,1908 # 80010a40 <cons>
    800002d4:	00001097          	auipc	ra,0x1
    800002d8:	902080e7          	jalr	-1790(ra) # 80000bd6 <acquire>

  switch(c){
    800002dc:	47d5                	li	a5,21
    800002de:	0af48663          	beq	s1,a5,8000038a <consoleintr+0xcc>
    800002e2:	0297ca63          	blt	a5,s1,80000316 <consoleintr+0x58>
    800002e6:	47a1                	li	a5,8
    800002e8:	0ef48763          	beq	s1,a5,800003d6 <consoleintr+0x118>
    800002ec:	47c1                	li	a5,16
    800002ee:	10f49a63          	bne	s1,a5,80000402 <consoleintr+0x144>
  case C('P'):  // Print process list.
    procdump();
    800002f2:	00002097          	auipc	ra,0x2
    800002f6:	28c080e7          	jalr	652(ra) # 8000257e <procdump>
      }
    }
    break;
  }
  
  release(&cons.lock);
    800002fa:	00010517          	auipc	a0,0x10
    800002fe:	74650513          	addi	a0,a0,1862 # 80010a40 <cons>
    80000302:	00001097          	auipc	ra,0x1
    80000306:	988080e7          	jalr	-1656(ra) # 80000c8a <release>
}
    8000030a:	60e2                	ld	ra,24(sp)
    8000030c:	6442                	ld	s0,16(sp)
    8000030e:	64a2                	ld	s1,8(sp)
    80000310:	6902                	ld	s2,0(sp)
    80000312:	6105                	addi	sp,sp,32
    80000314:	8082                	ret
  switch(c){
    80000316:	07f00793          	li	a5,127
    8000031a:	0af48e63          	beq	s1,a5,800003d6 <consoleintr+0x118>
    if(c != 0 && cons.e-cons.r < INPUT_BUF_SIZE){
    8000031e:	00010717          	auipc	a4,0x10
    80000322:	72270713          	addi	a4,a4,1826 # 80010a40 <cons>
    80000326:	0a072783          	lw	a5,160(a4)
    8000032a:	09872703          	lw	a4,152(a4)
    8000032e:	9f99                	subw	a5,a5,a4
    80000330:	07f00713          	li	a4,127
    80000334:	fcf763e3          	bltu	a4,a5,800002fa <consoleintr+0x3c>
      c = (c == '\r') ? '\n' : c;
    80000338:	47b5                	li	a5,13
    8000033a:	0cf48763          	beq	s1,a5,80000408 <consoleintr+0x14a>
      consputc(c);
    8000033e:	8526                	mv	a0,s1
    80000340:	00000097          	auipc	ra,0x0
    80000344:	f3c080e7          	jalr	-196(ra) # 8000027c <consputc>
      cons.buf[cons.e++ % INPUT_BUF_SIZE] = c;
    80000348:	00010797          	auipc	a5,0x10
    8000034c:	6f878793          	addi	a5,a5,1784 # 80010a40 <cons>
    80000350:	0a07a683          	lw	a3,160(a5)
    80000354:	0016871b          	addiw	a4,a3,1
    80000358:	0007061b          	sext.w	a2,a4
    8000035c:	0ae7a023          	sw	a4,160(a5)
    80000360:	07f6f693          	andi	a3,a3,127
    80000364:	97b6                	add	a5,a5,a3
    80000366:	00978c23          	sb	s1,24(a5)
      if(c == '\n' || c == C('D') || cons.e-cons.r == INPUT_BUF_SIZE){
    8000036a:	47a9                	li	a5,10
    8000036c:	0cf48563          	beq	s1,a5,80000436 <consoleintr+0x178>
    80000370:	4791                	li	a5,4
    80000372:	0cf48263          	beq	s1,a5,80000436 <consoleintr+0x178>
    80000376:	00010797          	auipc	a5,0x10
    8000037a:	7627a783          	lw	a5,1890(a5) # 80010ad8 <cons+0x98>
    8000037e:	9f1d                	subw	a4,a4,a5
    80000380:	08000793          	li	a5,128
    80000384:	f6f71be3          	bne	a4,a5,800002fa <consoleintr+0x3c>
    80000388:	a07d                	j	80000436 <consoleintr+0x178>
    while(cons.e != cons.w &&
    8000038a:	00010717          	auipc	a4,0x10
    8000038e:	6b670713          	addi	a4,a4,1718 # 80010a40 <cons>
    80000392:	0a072783          	lw	a5,160(a4)
    80000396:	09c72703          	lw	a4,156(a4)
          cons.buf[(cons.e-1) % INPUT_BUF_SIZE] != '\n'){
    8000039a:	00010497          	auipc	s1,0x10
    8000039e:	6a648493          	addi	s1,s1,1702 # 80010a40 <cons>
    while(cons.e != cons.w &&
    800003a2:	4929                	li	s2,10
    800003a4:	f4f70be3          	beq	a4,a5,800002fa <consoleintr+0x3c>
          cons.buf[(cons.e-1) % INPUT_BUF_SIZE] != '\n'){
    800003a8:	37fd                	addiw	a5,a5,-1
    800003aa:	07f7f713          	andi	a4,a5,127
    800003ae:	9726                	add	a4,a4,s1
    while(cons.e != cons.w &&
    800003b0:	01874703          	lbu	a4,24(a4)
    800003b4:	f52703e3          	beq	a4,s2,800002fa <consoleintr+0x3c>
      cons.e--;
    800003b8:	0af4a023          	sw	a5,160(s1)
      consputc(BACKSPACE);
    800003bc:	10000513          	li	a0,256
    800003c0:	00000097          	auipc	ra,0x0
    800003c4:	ebc080e7          	jalr	-324(ra) # 8000027c <consputc>
    while(cons.e != cons.w &&
    800003c8:	0a04a783          	lw	a5,160(s1)
    800003cc:	09c4a703          	lw	a4,156(s1)
    800003d0:	fcf71ce3          	bne	a4,a5,800003a8 <consoleintr+0xea>
    800003d4:	b71d                	j	800002fa <consoleintr+0x3c>
    if(cons.e != cons.w){
    800003d6:	00010717          	auipc	a4,0x10
    800003da:	66a70713          	addi	a4,a4,1642 # 80010a40 <cons>
    800003de:	0a072783          	lw	a5,160(a4)
    800003e2:	09c72703          	lw	a4,156(a4)
    800003e6:	f0f70ae3          	beq	a4,a5,800002fa <consoleintr+0x3c>
      cons.e--;
    800003ea:	37fd                	addiw	a5,a5,-1
    800003ec:	00010717          	auipc	a4,0x10
    800003f0:	6ef72a23          	sw	a5,1780(a4) # 80010ae0 <cons+0xa0>
      consputc(BACKSPACE);
    800003f4:	10000513          	li	a0,256
    800003f8:	00000097          	auipc	ra,0x0
    800003fc:	e84080e7          	jalr	-380(ra) # 8000027c <consputc>
    80000400:	bded                	j	800002fa <consoleintr+0x3c>
    if(c != 0 && cons.e-cons.r < INPUT_BUF_SIZE){
    80000402:	ee048ce3          	beqz	s1,800002fa <consoleintr+0x3c>
    80000406:	bf21                	j	8000031e <consoleintr+0x60>
      consputc(c);
    80000408:	4529                	li	a0,10
    8000040a:	00000097          	auipc	ra,0x0
    8000040e:	e72080e7          	jalr	-398(ra) # 8000027c <consputc>
      cons.buf[cons.e++ % INPUT_BUF_SIZE] = c;
    80000412:	00010797          	auipc	a5,0x10
    80000416:	62e78793          	addi	a5,a5,1582 # 80010a40 <cons>
    8000041a:	0a07a703          	lw	a4,160(a5)
    8000041e:	0017069b          	addiw	a3,a4,1
    80000422:	0006861b          	sext.w	a2,a3
    80000426:	0ad7a023          	sw	a3,160(a5)
    8000042a:	07f77713          	andi	a4,a4,127
    8000042e:	97ba                	add	a5,a5,a4
    80000430:	4729                	li	a4,10
    80000432:	00e78c23          	sb	a4,24(a5)
        cons.w = cons.e;
    80000436:	00010797          	auipc	a5,0x10
    8000043a:	6ac7a323          	sw	a2,1702(a5) # 80010adc <cons+0x9c>
        wakeup(&cons.r);
    8000043e:	00010517          	auipc	a0,0x10
    80000442:	69a50513          	addi	a0,a0,1690 # 80010ad8 <cons+0x98>
    80000446:	00002097          	auipc	ra,0x2
    8000044a:	ce0080e7          	jalr	-800(ra) # 80002126 <wakeup>
    8000044e:	b575                	j	800002fa <consoleintr+0x3c>

0000000080000450 <consoleinit>:

void
consoleinit(void)
{
    80000450:	1141                	addi	sp,sp,-16
    80000452:	e406                	sd	ra,8(sp)
    80000454:	e022                	sd	s0,0(sp)
    80000456:	0800                	addi	s0,sp,16
  initlock(&cons.lock, "cons");
    80000458:	00008597          	auipc	a1,0x8
    8000045c:	bb858593          	addi	a1,a1,-1096 # 80008010 <etext+0x10>
    80000460:	00010517          	auipc	a0,0x10
    80000464:	5e050513          	addi	a0,a0,1504 # 80010a40 <cons>
    80000468:	00000097          	auipc	ra,0x0
    8000046c:	6de080e7          	jalr	1758(ra) # 80000b46 <initlock>

  uartinit();
    80000470:	00000097          	auipc	ra,0x0
    80000474:	32c080e7          	jalr	812(ra) # 8000079c <uartinit>

  // connect read and write system calls
  // to consoleread and consolewrite.
  devsw[CONSOLE].read = consoleread;
    80000478:	00021797          	auipc	a5,0x21
    8000047c:	97878793          	addi	a5,a5,-1672 # 80020df0 <devsw>
    80000480:	00000717          	auipc	a4,0x0
    80000484:	ce470713          	addi	a4,a4,-796 # 80000164 <consoleread>
    80000488:	eb98                	sd	a4,16(a5)
  devsw[CONSOLE].write = consolewrite;
    8000048a:	00000717          	auipc	a4,0x0
    8000048e:	c7670713          	addi	a4,a4,-906 # 80000100 <consolewrite>
    80000492:	ef98                	sd	a4,24(a5)
}
    80000494:	60a2                	ld	ra,8(sp)
    80000496:	6402                	ld	s0,0(sp)
    80000498:	0141                	addi	sp,sp,16
    8000049a:	8082                	ret

000000008000049c <printint>:

static char digits[] = "0123456789abcdef";

static void
printint(int xx, int base, int sign)
{
    8000049c:	7179                	addi	sp,sp,-48
    8000049e:	f406                	sd	ra,40(sp)
    800004a0:	f022                	sd	s0,32(sp)
    800004a2:	ec26                	sd	s1,24(sp)
    800004a4:	e84a                	sd	s2,16(sp)
    800004a6:	1800                	addi	s0,sp,48
  char buf[16];
  int i;
  uint x;

  if(sign && (sign = xx < 0))
    800004a8:	c219                	beqz	a2,800004ae <printint+0x12>
    800004aa:	08054763          	bltz	a0,80000538 <printint+0x9c>
    x = -xx;
  else
    x = xx;
    800004ae:	2501                	sext.w	a0,a0
    800004b0:	4881                	li	a7,0
    800004b2:	fd040693          	addi	a3,s0,-48

  i = 0;
    800004b6:	4701                	li	a4,0
  do {
    buf[i++] = digits[x % base];
    800004b8:	2581                	sext.w	a1,a1
    800004ba:	00008617          	auipc	a2,0x8
    800004be:	b8660613          	addi	a2,a2,-1146 # 80008040 <digits>
    800004c2:	883a                	mv	a6,a4
    800004c4:	2705                	addiw	a4,a4,1
    800004c6:	02b577bb          	remuw	a5,a0,a1
    800004ca:	1782                	slli	a5,a5,0x20
    800004cc:	9381                	srli	a5,a5,0x20
    800004ce:	97b2                	add	a5,a5,a2
    800004d0:	0007c783          	lbu	a5,0(a5)
    800004d4:	00f68023          	sb	a5,0(a3)
  } while((x /= base) != 0);
    800004d8:	0005079b          	sext.w	a5,a0
    800004dc:	02b5553b          	divuw	a0,a0,a1
    800004e0:	0685                	addi	a3,a3,1
    800004e2:	feb7f0e3          	bgeu	a5,a1,800004c2 <printint+0x26>

  if(sign)
    800004e6:	00088c63          	beqz	a7,800004fe <printint+0x62>
    buf[i++] = '-';
    800004ea:	fe070793          	addi	a5,a4,-32
    800004ee:	00878733          	add	a4,a5,s0
    800004f2:	02d00793          	li	a5,45
    800004f6:	fef70823          	sb	a5,-16(a4)
    800004fa:	0028071b          	addiw	a4,a6,2

  while(--i >= 0)
    800004fe:	02e05763          	blez	a4,8000052c <printint+0x90>
    80000502:	fd040793          	addi	a5,s0,-48
    80000506:	00e784b3          	add	s1,a5,a4
    8000050a:	fff78913          	addi	s2,a5,-1
    8000050e:	993a                	add	s2,s2,a4
    80000510:	377d                	addiw	a4,a4,-1
    80000512:	1702                	slli	a4,a4,0x20
    80000514:	9301                	srli	a4,a4,0x20
    80000516:	40e90933          	sub	s2,s2,a4
    consputc(buf[i]);
    8000051a:	fff4c503          	lbu	a0,-1(s1)
    8000051e:	00000097          	auipc	ra,0x0
    80000522:	d5e080e7          	jalr	-674(ra) # 8000027c <consputc>
  while(--i >= 0)
    80000526:	14fd                	addi	s1,s1,-1
    80000528:	ff2499e3          	bne	s1,s2,8000051a <printint+0x7e>
}
    8000052c:	70a2                	ld	ra,40(sp)
    8000052e:	7402                	ld	s0,32(sp)
    80000530:	64e2                	ld	s1,24(sp)
    80000532:	6942                	ld	s2,16(sp)
    80000534:	6145                	addi	sp,sp,48
    80000536:	8082                	ret
    x = -xx;
    80000538:	40a0053b          	negw	a0,a0
  if(sign && (sign = xx < 0))
    8000053c:	4885                	li	a7,1
    x = -xx;
    8000053e:	bf95                	j	800004b2 <printint+0x16>

0000000080000540 <panic>:
    release(&pr.lock);
}

void
panic(char *s)
{
    80000540:	1101                	addi	sp,sp,-32
    80000542:	ec06                	sd	ra,24(sp)
    80000544:	e822                	sd	s0,16(sp)
    80000546:	e426                	sd	s1,8(sp)
    80000548:	1000                	addi	s0,sp,32
    8000054a:	84aa                	mv	s1,a0
  pr.locking = 0;
    8000054c:	00010797          	auipc	a5,0x10
    80000550:	5a07aa23          	sw	zero,1460(a5) # 80010b00 <pr+0x18>
  printf("panic: ");
    80000554:	00008517          	auipc	a0,0x8
    80000558:	ac450513          	addi	a0,a0,-1340 # 80008018 <etext+0x18>
    8000055c:	00000097          	auipc	ra,0x0
    80000560:	02e080e7          	jalr	46(ra) # 8000058a <printf>
  printf(s);
    80000564:	8526                	mv	a0,s1
    80000566:	00000097          	auipc	ra,0x0
    8000056a:	024080e7          	jalr	36(ra) # 8000058a <printf>
  printf("\n");
    8000056e:	00008517          	auipc	a0,0x8
    80000572:	b5a50513          	addi	a0,a0,-1190 # 800080c8 <digits+0x88>
    80000576:	00000097          	auipc	ra,0x0
    8000057a:	014080e7          	jalr	20(ra) # 8000058a <printf>
  panicked = 1; // freeze uart output from other CPUs
    8000057e:	4785                	li	a5,1
    80000580:	00008717          	auipc	a4,0x8
    80000584:	34f72023          	sw	a5,832(a4) # 800088c0 <panicked>
  for(;;)
    80000588:	a001                	j	80000588 <panic+0x48>

000000008000058a <printf>:
{
    8000058a:	7131                	addi	sp,sp,-192
    8000058c:	fc86                	sd	ra,120(sp)
    8000058e:	f8a2                	sd	s0,112(sp)
    80000590:	f4a6                	sd	s1,104(sp)
    80000592:	f0ca                	sd	s2,96(sp)
    80000594:	ecce                	sd	s3,88(sp)
    80000596:	e8d2                	sd	s4,80(sp)
    80000598:	e4d6                	sd	s5,72(sp)
    8000059a:	e0da                	sd	s6,64(sp)
    8000059c:	fc5e                	sd	s7,56(sp)
    8000059e:	f862                	sd	s8,48(sp)
    800005a0:	f466                	sd	s9,40(sp)
    800005a2:	f06a                	sd	s10,32(sp)
    800005a4:	ec6e                	sd	s11,24(sp)
    800005a6:	0100                	addi	s0,sp,128
    800005a8:	8a2a                	mv	s4,a0
    800005aa:	e40c                	sd	a1,8(s0)
    800005ac:	e810                	sd	a2,16(s0)
    800005ae:	ec14                	sd	a3,24(s0)
    800005b0:	f018                	sd	a4,32(s0)
    800005b2:	f41c                	sd	a5,40(s0)
    800005b4:	03043823          	sd	a6,48(s0)
    800005b8:	03143c23          	sd	a7,56(s0)
  locking = pr.locking;
    800005bc:	00010d97          	auipc	s11,0x10
    800005c0:	544dad83          	lw	s11,1348(s11) # 80010b00 <pr+0x18>
  if(locking)
    800005c4:	020d9b63          	bnez	s11,800005fa <printf+0x70>
  if (fmt == 0)
    800005c8:	040a0263          	beqz	s4,8000060c <printf+0x82>
  va_start(ap, fmt);
    800005cc:	00840793          	addi	a5,s0,8
    800005d0:	f8f43423          	sd	a5,-120(s0)
  for(i = 0; (c = fmt[i] & 0xff) != 0; i++){
    800005d4:	000a4503          	lbu	a0,0(s4)
    800005d8:	14050f63          	beqz	a0,80000736 <printf+0x1ac>
    800005dc:	4981                	li	s3,0
    if(c != '%'){
    800005de:	02500a93          	li	s5,37
    switch(c){
    800005e2:	07000b93          	li	s7,112
  consputc('x');
    800005e6:	4d41                	li	s10,16
    consputc(digits[x >> (sizeof(uint64) * 8 - 4)]);
    800005e8:	00008b17          	auipc	s6,0x8
    800005ec:	a58b0b13          	addi	s6,s6,-1448 # 80008040 <digits>
    switch(c){
    800005f0:	07300c93          	li	s9,115
    800005f4:	06400c13          	li	s8,100
    800005f8:	a82d                	j	80000632 <printf+0xa8>
    acquire(&pr.lock);
    800005fa:	00010517          	auipc	a0,0x10
    800005fe:	4ee50513          	addi	a0,a0,1262 # 80010ae8 <pr>
    80000602:	00000097          	auipc	ra,0x0
    80000606:	5d4080e7          	jalr	1492(ra) # 80000bd6 <acquire>
    8000060a:	bf7d                	j	800005c8 <printf+0x3e>
    panic("null fmt");
    8000060c:	00008517          	auipc	a0,0x8
    80000610:	a1c50513          	addi	a0,a0,-1508 # 80008028 <etext+0x28>
    80000614:	00000097          	auipc	ra,0x0
    80000618:	f2c080e7          	jalr	-212(ra) # 80000540 <panic>
      consputc(c);
    8000061c:	00000097          	auipc	ra,0x0
    80000620:	c60080e7          	jalr	-928(ra) # 8000027c <consputc>
  for(i = 0; (c = fmt[i] & 0xff) != 0; i++){
    80000624:	2985                	addiw	s3,s3,1
    80000626:	013a07b3          	add	a5,s4,s3
    8000062a:	0007c503          	lbu	a0,0(a5)
    8000062e:	10050463          	beqz	a0,80000736 <printf+0x1ac>
    if(c != '%'){
    80000632:	ff5515e3          	bne	a0,s5,8000061c <printf+0x92>
    c = fmt[++i] & 0xff;
    80000636:	2985                	addiw	s3,s3,1
    80000638:	013a07b3          	add	a5,s4,s3
    8000063c:	0007c783          	lbu	a5,0(a5)
    80000640:	0007849b          	sext.w	s1,a5
    if(c == 0)
    80000644:	cbed                	beqz	a5,80000736 <printf+0x1ac>
    switch(c){
    80000646:	05778a63          	beq	a5,s7,8000069a <printf+0x110>
    8000064a:	02fbf663          	bgeu	s7,a5,80000676 <printf+0xec>
    8000064e:	09978863          	beq	a5,s9,800006de <printf+0x154>
    80000652:	07800713          	li	a4,120
    80000656:	0ce79563          	bne	a5,a4,80000720 <printf+0x196>
      printint(va_arg(ap, int), 16, 1);
    8000065a:	f8843783          	ld	a5,-120(s0)
    8000065e:	00878713          	addi	a4,a5,8
    80000662:	f8e43423          	sd	a4,-120(s0)
    80000666:	4605                	li	a2,1
    80000668:	85ea                	mv	a1,s10
    8000066a:	4388                	lw	a0,0(a5)
    8000066c:	00000097          	auipc	ra,0x0
    80000670:	e30080e7          	jalr	-464(ra) # 8000049c <printint>
      break;
    80000674:	bf45                	j	80000624 <printf+0x9a>
    switch(c){
    80000676:	09578f63          	beq	a5,s5,80000714 <printf+0x18a>
    8000067a:	0b879363          	bne	a5,s8,80000720 <printf+0x196>
      printint(va_arg(ap, int), 10, 1);
    8000067e:	f8843783          	ld	a5,-120(s0)
    80000682:	00878713          	addi	a4,a5,8
    80000686:	f8e43423          	sd	a4,-120(s0)
    8000068a:	4605                	li	a2,1
    8000068c:	45a9                	li	a1,10
    8000068e:	4388                	lw	a0,0(a5)
    80000690:	00000097          	auipc	ra,0x0
    80000694:	e0c080e7          	jalr	-500(ra) # 8000049c <printint>
      break;
    80000698:	b771                	j	80000624 <printf+0x9a>
      printptr(va_arg(ap, uint64));
    8000069a:	f8843783          	ld	a5,-120(s0)
    8000069e:	00878713          	addi	a4,a5,8
    800006a2:	f8e43423          	sd	a4,-120(s0)
    800006a6:	0007b903          	ld	s2,0(a5)
  consputc('0');
    800006aa:	03000513          	li	a0,48
    800006ae:	00000097          	auipc	ra,0x0
    800006b2:	bce080e7          	jalr	-1074(ra) # 8000027c <consputc>
  consputc('x');
    800006b6:	07800513          	li	a0,120
    800006ba:	00000097          	auipc	ra,0x0
    800006be:	bc2080e7          	jalr	-1086(ra) # 8000027c <consputc>
    800006c2:	84ea                	mv	s1,s10
    consputc(digits[x >> (sizeof(uint64) * 8 - 4)]);
    800006c4:	03c95793          	srli	a5,s2,0x3c
    800006c8:	97da                	add	a5,a5,s6
    800006ca:	0007c503          	lbu	a0,0(a5)
    800006ce:	00000097          	auipc	ra,0x0
    800006d2:	bae080e7          	jalr	-1106(ra) # 8000027c <consputc>
  for (i = 0; i < (sizeof(uint64) * 2); i++, x <<= 4)
    800006d6:	0912                	slli	s2,s2,0x4
    800006d8:	34fd                	addiw	s1,s1,-1
    800006da:	f4ed                	bnez	s1,800006c4 <printf+0x13a>
    800006dc:	b7a1                	j	80000624 <printf+0x9a>
      if((s = va_arg(ap, char*)) == 0)
    800006de:	f8843783          	ld	a5,-120(s0)
    800006e2:	00878713          	addi	a4,a5,8
    800006e6:	f8e43423          	sd	a4,-120(s0)
    800006ea:	6384                	ld	s1,0(a5)
    800006ec:	cc89                	beqz	s1,80000706 <printf+0x17c>
      for(; *s; s++)
    800006ee:	0004c503          	lbu	a0,0(s1)
    800006f2:	d90d                	beqz	a0,80000624 <printf+0x9a>
        consputc(*s);
    800006f4:	00000097          	auipc	ra,0x0
    800006f8:	b88080e7          	jalr	-1144(ra) # 8000027c <consputc>
      for(; *s; s++)
    800006fc:	0485                	addi	s1,s1,1
    800006fe:	0004c503          	lbu	a0,0(s1)
    80000702:	f96d                	bnez	a0,800006f4 <printf+0x16a>
    80000704:	b705                	j	80000624 <printf+0x9a>
        s = "(null)";
    80000706:	00008497          	auipc	s1,0x8
    8000070a:	91a48493          	addi	s1,s1,-1766 # 80008020 <etext+0x20>
      for(; *s; s++)
    8000070e:	02800513          	li	a0,40
    80000712:	b7cd                	j	800006f4 <printf+0x16a>
      consputc('%');
    80000714:	8556                	mv	a0,s5
    80000716:	00000097          	auipc	ra,0x0
    8000071a:	b66080e7          	jalr	-1178(ra) # 8000027c <consputc>
      break;
    8000071e:	b719                	j	80000624 <printf+0x9a>
      consputc('%');
    80000720:	8556                	mv	a0,s5
    80000722:	00000097          	auipc	ra,0x0
    80000726:	b5a080e7          	jalr	-1190(ra) # 8000027c <consputc>
      consputc(c);
    8000072a:	8526                	mv	a0,s1
    8000072c:	00000097          	auipc	ra,0x0
    80000730:	b50080e7          	jalr	-1200(ra) # 8000027c <consputc>
      break;
    80000734:	bdc5                	j	80000624 <printf+0x9a>
  if(locking)
    80000736:	020d9163          	bnez	s11,80000758 <printf+0x1ce>
}
    8000073a:	70e6                	ld	ra,120(sp)
    8000073c:	7446                	ld	s0,112(sp)
    8000073e:	74a6                	ld	s1,104(sp)
    80000740:	7906                	ld	s2,96(sp)
    80000742:	69e6                	ld	s3,88(sp)
    80000744:	6a46                	ld	s4,80(sp)
    80000746:	6aa6                	ld	s5,72(sp)
    80000748:	6b06                	ld	s6,64(sp)
    8000074a:	7be2                	ld	s7,56(sp)
    8000074c:	7c42                	ld	s8,48(sp)
    8000074e:	7ca2                	ld	s9,40(sp)
    80000750:	7d02                	ld	s10,32(sp)
    80000752:	6de2                	ld	s11,24(sp)
    80000754:	6129                	addi	sp,sp,192
    80000756:	8082                	ret
    release(&pr.lock);
    80000758:	00010517          	auipc	a0,0x10
    8000075c:	39050513          	addi	a0,a0,912 # 80010ae8 <pr>
    80000760:	00000097          	auipc	ra,0x0
    80000764:	52a080e7          	jalr	1322(ra) # 80000c8a <release>
}
    80000768:	bfc9                	j	8000073a <printf+0x1b0>

000000008000076a <printfinit>:
    ;
}

void
printfinit(void)
{
    8000076a:	1101                	addi	sp,sp,-32
    8000076c:	ec06                	sd	ra,24(sp)
    8000076e:	e822                	sd	s0,16(sp)
    80000770:	e426                	sd	s1,8(sp)
    80000772:	1000                	addi	s0,sp,32
  initlock(&pr.lock, "pr");
    80000774:	00010497          	auipc	s1,0x10
    80000778:	37448493          	addi	s1,s1,884 # 80010ae8 <pr>
    8000077c:	00008597          	auipc	a1,0x8
    80000780:	8bc58593          	addi	a1,a1,-1860 # 80008038 <etext+0x38>
    80000784:	8526                	mv	a0,s1
    80000786:	00000097          	auipc	ra,0x0
    8000078a:	3c0080e7          	jalr	960(ra) # 80000b46 <initlock>
  pr.locking = 1;
    8000078e:	4785                	li	a5,1
    80000790:	cc9c                	sw	a5,24(s1)
}
    80000792:	60e2                	ld	ra,24(sp)
    80000794:	6442                	ld	s0,16(sp)
    80000796:	64a2                	ld	s1,8(sp)
    80000798:	6105                	addi	sp,sp,32
    8000079a:	8082                	ret

000000008000079c <uartinit>:

void uartstart();

void
uartinit(void)
{
    8000079c:	1141                	addi	sp,sp,-16
    8000079e:	e406                	sd	ra,8(sp)
    800007a0:	e022                	sd	s0,0(sp)
    800007a2:	0800                	addi	s0,sp,16
  // disable interrupts.
  WriteReg(IER, 0x00);
    800007a4:	100007b7          	lui	a5,0x10000
    800007a8:	000780a3          	sb	zero,1(a5) # 10000001 <_entry-0x6fffffff>

  // special mode to set baud rate.
  WriteReg(LCR, LCR_BAUD_LATCH);
    800007ac:	f8000713          	li	a4,-128
    800007b0:	00e781a3          	sb	a4,3(a5)

  // LSB for baud rate of 38.4K.
  WriteReg(0, 0x03);
    800007b4:	470d                	li	a4,3
    800007b6:	00e78023          	sb	a4,0(a5)

  // MSB for baud rate of 38.4K.
  WriteReg(1, 0x00);
    800007ba:	000780a3          	sb	zero,1(a5)

  // leave set-baud mode,
  // and set word length to 8 bits, no parity.
  WriteReg(LCR, LCR_EIGHT_BITS);
    800007be:	00e781a3          	sb	a4,3(a5)

  // reset and enable FIFOs.
  WriteReg(FCR, FCR_FIFO_ENABLE | FCR_FIFO_CLEAR);
    800007c2:	469d                	li	a3,7
    800007c4:	00d78123          	sb	a3,2(a5)

  // enable transmit and receive interrupts.
  WriteReg(IER, IER_TX_ENABLE | IER_RX_ENABLE);
    800007c8:	00e780a3          	sb	a4,1(a5)

  initlock(&uart_tx_lock, "uart");
    800007cc:	00008597          	auipc	a1,0x8
    800007d0:	88c58593          	addi	a1,a1,-1908 # 80008058 <digits+0x18>
    800007d4:	00010517          	auipc	a0,0x10
    800007d8:	33450513          	addi	a0,a0,820 # 80010b08 <uart_tx_lock>
    800007dc:	00000097          	auipc	ra,0x0
    800007e0:	36a080e7          	jalr	874(ra) # 80000b46 <initlock>
}
    800007e4:	60a2                	ld	ra,8(sp)
    800007e6:	6402                	ld	s0,0(sp)
    800007e8:	0141                	addi	sp,sp,16
    800007ea:	8082                	ret

00000000800007ec <uartputc_sync>:
// use interrupts, for use by kernel printf() and
// to echo characters. it spins waiting for the uart's
// output register to be empty.
void
uartputc_sync(int c)
{
    800007ec:	1101                	addi	sp,sp,-32
    800007ee:	ec06                	sd	ra,24(sp)
    800007f0:	e822                	sd	s0,16(sp)
    800007f2:	e426                	sd	s1,8(sp)
    800007f4:	1000                	addi	s0,sp,32
    800007f6:	84aa                	mv	s1,a0
  push_off();
    800007f8:	00000097          	auipc	ra,0x0
    800007fc:	392080e7          	jalr	914(ra) # 80000b8a <push_off>

  if(panicked){
    80000800:	00008797          	auipc	a5,0x8
    80000804:	0c07a783          	lw	a5,192(a5) # 800088c0 <panicked>
    for(;;)
      ;
  }

  // wait for Transmit Holding Empty to be set in LSR.
  while((ReadReg(LSR) & LSR_TX_IDLE) == 0)
    80000808:	10000737          	lui	a4,0x10000
  if(panicked){
    8000080c:	c391                	beqz	a5,80000810 <uartputc_sync+0x24>
    for(;;)
    8000080e:	a001                	j	8000080e <uartputc_sync+0x22>
  while((ReadReg(LSR) & LSR_TX_IDLE) == 0)
    80000810:	00574783          	lbu	a5,5(a4) # 10000005 <_entry-0x6ffffffb>
    80000814:	0207f793          	andi	a5,a5,32
    80000818:	dfe5                	beqz	a5,80000810 <uartputc_sync+0x24>
    ;
  WriteReg(THR, c);
    8000081a:	0ff4f513          	zext.b	a0,s1
    8000081e:	100007b7          	lui	a5,0x10000
    80000822:	00a78023          	sb	a0,0(a5) # 10000000 <_entry-0x70000000>

  pop_off();
    80000826:	00000097          	auipc	ra,0x0
    8000082a:	404080e7          	jalr	1028(ra) # 80000c2a <pop_off>
}
    8000082e:	60e2                	ld	ra,24(sp)
    80000830:	6442                	ld	s0,16(sp)
    80000832:	64a2                	ld	s1,8(sp)
    80000834:	6105                	addi	sp,sp,32
    80000836:	8082                	ret

0000000080000838 <uartstart>:
// called from both the top- and bottom-half.
void
uartstart()
{
  while(1){
    if(uart_tx_w == uart_tx_r){
    80000838:	00008797          	auipc	a5,0x8
    8000083c:	0907b783          	ld	a5,144(a5) # 800088c8 <uart_tx_r>
    80000840:	00008717          	auipc	a4,0x8
    80000844:	09073703          	ld	a4,144(a4) # 800088d0 <uart_tx_w>
    80000848:	06f70a63          	beq	a4,a5,800008bc <uartstart+0x84>
{
    8000084c:	7139                	addi	sp,sp,-64
    8000084e:	fc06                	sd	ra,56(sp)
    80000850:	f822                	sd	s0,48(sp)
    80000852:	f426                	sd	s1,40(sp)
    80000854:	f04a                	sd	s2,32(sp)
    80000856:	ec4e                	sd	s3,24(sp)
    80000858:	e852                	sd	s4,16(sp)
    8000085a:	e456                	sd	s5,8(sp)
    8000085c:	0080                	addi	s0,sp,64
      // transmit buffer is empty.
      return;
    }
    
    if((ReadReg(LSR) & LSR_TX_IDLE) == 0){
    8000085e:	10000937          	lui	s2,0x10000
      // so we cannot give it another byte.
      // it will interrupt when it's ready for a new byte.
      return;
    }
    
    int c = uart_tx_buf[uart_tx_r % UART_TX_BUF_SIZE];
    80000862:	00010a17          	auipc	s4,0x10
    80000866:	2a6a0a13          	addi	s4,s4,678 # 80010b08 <uart_tx_lock>
    uart_tx_r += 1;
    8000086a:	00008497          	auipc	s1,0x8
    8000086e:	05e48493          	addi	s1,s1,94 # 800088c8 <uart_tx_r>
    if(uart_tx_w == uart_tx_r){
    80000872:	00008997          	auipc	s3,0x8
    80000876:	05e98993          	addi	s3,s3,94 # 800088d0 <uart_tx_w>
    if((ReadReg(LSR) & LSR_TX_IDLE) == 0){
    8000087a:	00594703          	lbu	a4,5(s2) # 10000005 <_entry-0x6ffffffb>
    8000087e:	02077713          	andi	a4,a4,32
    80000882:	c705                	beqz	a4,800008aa <uartstart+0x72>
    int c = uart_tx_buf[uart_tx_r % UART_TX_BUF_SIZE];
    80000884:	01f7f713          	andi	a4,a5,31
    80000888:	9752                	add	a4,a4,s4
    8000088a:	01874a83          	lbu	s5,24(a4)
    uart_tx_r += 1;
    8000088e:	0785                	addi	a5,a5,1
    80000890:	e09c                	sd	a5,0(s1)
    
    // maybe uartputc() is waiting for space in the buffer.
    wakeup(&uart_tx_r);
    80000892:	8526                	mv	a0,s1
    80000894:	00002097          	auipc	ra,0x2
    80000898:	892080e7          	jalr	-1902(ra) # 80002126 <wakeup>
    
    WriteReg(THR, c);
    8000089c:	01590023          	sb	s5,0(s2)
    if(uart_tx_w == uart_tx_r){
    800008a0:	609c                	ld	a5,0(s1)
    800008a2:	0009b703          	ld	a4,0(s3)
    800008a6:	fcf71ae3          	bne	a4,a5,8000087a <uartstart+0x42>
  }
}
    800008aa:	70e2                	ld	ra,56(sp)
    800008ac:	7442                	ld	s0,48(sp)
    800008ae:	74a2                	ld	s1,40(sp)
    800008b0:	7902                	ld	s2,32(sp)
    800008b2:	69e2                	ld	s3,24(sp)
    800008b4:	6a42                	ld	s4,16(sp)
    800008b6:	6aa2                	ld	s5,8(sp)
    800008b8:	6121                	addi	sp,sp,64
    800008ba:	8082                	ret
    800008bc:	8082                	ret

00000000800008be <uartputc>:
{
    800008be:	7179                	addi	sp,sp,-48
    800008c0:	f406                	sd	ra,40(sp)
    800008c2:	f022                	sd	s0,32(sp)
    800008c4:	ec26                	sd	s1,24(sp)
    800008c6:	e84a                	sd	s2,16(sp)
    800008c8:	e44e                	sd	s3,8(sp)
    800008ca:	e052                	sd	s4,0(sp)
    800008cc:	1800                	addi	s0,sp,48
    800008ce:	8a2a                	mv	s4,a0
  acquire(&uart_tx_lock);
    800008d0:	00010517          	auipc	a0,0x10
    800008d4:	23850513          	addi	a0,a0,568 # 80010b08 <uart_tx_lock>
    800008d8:	00000097          	auipc	ra,0x0
    800008dc:	2fe080e7          	jalr	766(ra) # 80000bd6 <acquire>
  if(panicked){
    800008e0:	00008797          	auipc	a5,0x8
    800008e4:	fe07a783          	lw	a5,-32(a5) # 800088c0 <panicked>
    800008e8:	e7c9                	bnez	a5,80000972 <uartputc+0xb4>
  while(uart_tx_w == uart_tx_r + UART_TX_BUF_SIZE){
    800008ea:	00008717          	auipc	a4,0x8
    800008ee:	fe673703          	ld	a4,-26(a4) # 800088d0 <uart_tx_w>
    800008f2:	00008797          	auipc	a5,0x8
    800008f6:	fd67b783          	ld	a5,-42(a5) # 800088c8 <uart_tx_r>
    800008fa:	02078793          	addi	a5,a5,32
    sleep(&uart_tx_r, &uart_tx_lock);
    800008fe:	00010997          	auipc	s3,0x10
    80000902:	20a98993          	addi	s3,s3,522 # 80010b08 <uart_tx_lock>
    80000906:	00008497          	auipc	s1,0x8
    8000090a:	fc248493          	addi	s1,s1,-62 # 800088c8 <uart_tx_r>
  while(uart_tx_w == uart_tx_r + UART_TX_BUF_SIZE){
    8000090e:	00008917          	auipc	s2,0x8
    80000912:	fc290913          	addi	s2,s2,-62 # 800088d0 <uart_tx_w>
    80000916:	00e79f63          	bne	a5,a4,80000934 <uartputc+0x76>
    sleep(&uart_tx_r, &uart_tx_lock);
    8000091a:	85ce                	mv	a1,s3
    8000091c:	8526                	mv	a0,s1
    8000091e:	00001097          	auipc	ra,0x1
    80000922:	7a4080e7          	jalr	1956(ra) # 800020c2 <sleep>
  while(uart_tx_w == uart_tx_r + UART_TX_BUF_SIZE){
    80000926:	00093703          	ld	a4,0(s2)
    8000092a:	609c                	ld	a5,0(s1)
    8000092c:	02078793          	addi	a5,a5,32
    80000930:	fee785e3          	beq	a5,a4,8000091a <uartputc+0x5c>
  uart_tx_buf[uart_tx_w % UART_TX_BUF_SIZE] = c;
    80000934:	00010497          	auipc	s1,0x10
    80000938:	1d448493          	addi	s1,s1,468 # 80010b08 <uart_tx_lock>
    8000093c:	01f77793          	andi	a5,a4,31
    80000940:	97a6                	add	a5,a5,s1
    80000942:	01478c23          	sb	s4,24(a5)
  uart_tx_w += 1;
    80000946:	0705                	addi	a4,a4,1
    80000948:	00008797          	auipc	a5,0x8
    8000094c:	f8e7b423          	sd	a4,-120(a5) # 800088d0 <uart_tx_w>
  uartstart();
    80000950:	00000097          	auipc	ra,0x0
    80000954:	ee8080e7          	jalr	-280(ra) # 80000838 <uartstart>
  release(&uart_tx_lock);
    80000958:	8526                	mv	a0,s1
    8000095a:	00000097          	auipc	ra,0x0
    8000095e:	330080e7          	jalr	816(ra) # 80000c8a <release>
}
    80000962:	70a2                	ld	ra,40(sp)
    80000964:	7402                	ld	s0,32(sp)
    80000966:	64e2                	ld	s1,24(sp)
    80000968:	6942                	ld	s2,16(sp)
    8000096a:	69a2                	ld	s3,8(sp)
    8000096c:	6a02                	ld	s4,0(sp)
    8000096e:	6145                	addi	sp,sp,48
    80000970:	8082                	ret
    for(;;)
    80000972:	a001                	j	80000972 <uartputc+0xb4>

0000000080000974 <uartgetc>:

// read one input character from the UART.
// return -1 if none is waiting.
int
uartgetc(void)
{
    80000974:	1141                	addi	sp,sp,-16
    80000976:	e422                	sd	s0,8(sp)
    80000978:	0800                	addi	s0,sp,16
  if(ReadReg(LSR) & 0x01){
    8000097a:	100007b7          	lui	a5,0x10000
    8000097e:	0057c783          	lbu	a5,5(a5) # 10000005 <_entry-0x6ffffffb>
    80000982:	8b85                	andi	a5,a5,1
    80000984:	cb81                	beqz	a5,80000994 <uartgetc+0x20>
    // input data is ready.
    return ReadReg(RHR);
    80000986:	100007b7          	lui	a5,0x10000
    8000098a:	0007c503          	lbu	a0,0(a5) # 10000000 <_entry-0x70000000>
  } else {
    return -1;
  }
}
    8000098e:	6422                	ld	s0,8(sp)
    80000990:	0141                	addi	sp,sp,16
    80000992:	8082                	ret
    return -1;
    80000994:	557d                	li	a0,-1
    80000996:	bfe5                	j	8000098e <uartgetc+0x1a>

0000000080000998 <uartintr>:
// handle a uart interrupt, raised because input has
// arrived, or the uart is ready for more output, or
// both. called from devintr().
void
uartintr(void)
{
    80000998:	1101                	addi	sp,sp,-32
    8000099a:	ec06                	sd	ra,24(sp)
    8000099c:	e822                	sd	s0,16(sp)
    8000099e:	e426                	sd	s1,8(sp)
    800009a0:	1000                	addi	s0,sp,32
  // read and process incoming characters.
  while(1){
    int c = uartgetc();
    if(c == -1)
    800009a2:	54fd                	li	s1,-1
    800009a4:	a029                	j	800009ae <uartintr+0x16>
      break;
    consoleintr(c);
    800009a6:	00000097          	auipc	ra,0x0
    800009aa:	918080e7          	jalr	-1768(ra) # 800002be <consoleintr>
    int c = uartgetc();
    800009ae:	00000097          	auipc	ra,0x0
    800009b2:	fc6080e7          	jalr	-58(ra) # 80000974 <uartgetc>
    if(c == -1)
    800009b6:	fe9518e3          	bne	a0,s1,800009a6 <uartintr+0xe>
  }

  // send buffered characters.
  acquire(&uart_tx_lock);
    800009ba:	00010497          	auipc	s1,0x10
    800009be:	14e48493          	addi	s1,s1,334 # 80010b08 <uart_tx_lock>
    800009c2:	8526                	mv	a0,s1
    800009c4:	00000097          	auipc	ra,0x0
    800009c8:	212080e7          	jalr	530(ra) # 80000bd6 <acquire>
  uartstart();
    800009cc:	00000097          	auipc	ra,0x0
    800009d0:	e6c080e7          	jalr	-404(ra) # 80000838 <uartstart>
  release(&uart_tx_lock);
    800009d4:	8526                	mv	a0,s1
    800009d6:	00000097          	auipc	ra,0x0
    800009da:	2b4080e7          	jalr	692(ra) # 80000c8a <release>
}
    800009de:	60e2                	ld	ra,24(sp)
    800009e0:	6442                	ld	s0,16(sp)
    800009e2:	64a2                	ld	s1,8(sp)
    800009e4:	6105                	addi	sp,sp,32
    800009e6:	8082                	ret

00000000800009e8 <kfree>:
// which normally should have been returned by a
// call to kalloc().  (The exception is when
// initializing the allocator; see kinit above.)
void
kfree(void *pa)
{
    800009e8:	1101                	addi	sp,sp,-32
    800009ea:	ec06                	sd	ra,24(sp)
    800009ec:	e822                	sd	s0,16(sp)
    800009ee:	e426                	sd	s1,8(sp)
    800009f0:	e04a                	sd	s2,0(sp)
    800009f2:	1000                	addi	s0,sp,32
  struct run *r;

  if(((uint64)pa % PGSIZE) != 0 || (char*)pa < end || (uint64)pa >= PHYSTOP)
    800009f4:	03451793          	slli	a5,a0,0x34
    800009f8:	ebb9                	bnez	a5,80000a4e <kfree+0x66>
    800009fa:	84aa                	mv	s1,a0
    800009fc:	00021797          	auipc	a5,0x21
    80000a00:	58c78793          	addi	a5,a5,1420 # 80021f88 <end>
    80000a04:	04f56563          	bltu	a0,a5,80000a4e <kfree+0x66>
    80000a08:	47c5                	li	a5,17
    80000a0a:	07ee                	slli	a5,a5,0x1b
    80000a0c:	04f57163          	bgeu	a0,a5,80000a4e <kfree+0x66>
    panic("kfree");

  // Fill with junk to catch dangling refs.
  memset(pa, 1, PGSIZE);
    80000a10:	6605                	lui	a2,0x1
    80000a12:	4585                	li	a1,1
    80000a14:	00000097          	auipc	ra,0x0
    80000a18:	2be080e7          	jalr	702(ra) # 80000cd2 <memset>

  r = (struct run*)pa;

  acquire(&kmem.lock);
    80000a1c:	00010917          	auipc	s2,0x10
    80000a20:	12490913          	addi	s2,s2,292 # 80010b40 <kmem>
    80000a24:	854a                	mv	a0,s2
    80000a26:	00000097          	auipc	ra,0x0
    80000a2a:	1b0080e7          	jalr	432(ra) # 80000bd6 <acquire>
  r->next = kmem.freelist;
    80000a2e:	01893783          	ld	a5,24(s2)
    80000a32:	e09c                	sd	a5,0(s1)
  kmem.freelist = r;
    80000a34:	00993c23          	sd	s1,24(s2)
  release(&kmem.lock);
    80000a38:	854a                	mv	a0,s2
    80000a3a:	00000097          	auipc	ra,0x0
    80000a3e:	250080e7          	jalr	592(ra) # 80000c8a <release>
}
    80000a42:	60e2                	ld	ra,24(sp)
    80000a44:	6442                	ld	s0,16(sp)
    80000a46:	64a2                	ld	s1,8(sp)
    80000a48:	6902                	ld	s2,0(sp)
    80000a4a:	6105                	addi	sp,sp,32
    80000a4c:	8082                	ret
    panic("kfree");
    80000a4e:	00007517          	auipc	a0,0x7
    80000a52:	61250513          	addi	a0,a0,1554 # 80008060 <digits+0x20>
    80000a56:	00000097          	auipc	ra,0x0
    80000a5a:	aea080e7          	jalr	-1302(ra) # 80000540 <panic>

0000000080000a5e <freerange>:
{
    80000a5e:	7179                	addi	sp,sp,-48
    80000a60:	f406                	sd	ra,40(sp)
    80000a62:	f022                	sd	s0,32(sp)
    80000a64:	ec26                	sd	s1,24(sp)
    80000a66:	e84a                	sd	s2,16(sp)
    80000a68:	e44e                	sd	s3,8(sp)
    80000a6a:	e052                	sd	s4,0(sp)
    80000a6c:	1800                	addi	s0,sp,48
  p = (char*)PGROUNDUP((uint64)pa_start);
    80000a6e:	6785                	lui	a5,0x1
    80000a70:	fff78713          	addi	a4,a5,-1 # fff <_entry-0x7ffff001>
    80000a74:	00e504b3          	add	s1,a0,a4
    80000a78:	777d                	lui	a4,0xfffff
    80000a7a:	8cf9                	and	s1,s1,a4
  for(; p + PGSIZE <= (char*)pa_end; p += PGSIZE)
    80000a7c:	94be                	add	s1,s1,a5
    80000a7e:	0095ee63          	bltu	a1,s1,80000a9a <freerange+0x3c>
    80000a82:	892e                	mv	s2,a1
    kfree(p);
    80000a84:	7a7d                	lui	s4,0xfffff
  for(; p + PGSIZE <= (char*)pa_end; p += PGSIZE)
    80000a86:	6985                	lui	s3,0x1
    kfree(p);
    80000a88:	01448533          	add	a0,s1,s4
    80000a8c:	00000097          	auipc	ra,0x0
    80000a90:	f5c080e7          	jalr	-164(ra) # 800009e8 <kfree>
  for(; p + PGSIZE <= (char*)pa_end; p += PGSIZE)
    80000a94:	94ce                	add	s1,s1,s3
    80000a96:	fe9979e3          	bgeu	s2,s1,80000a88 <freerange+0x2a>
}
    80000a9a:	70a2                	ld	ra,40(sp)
    80000a9c:	7402                	ld	s0,32(sp)
    80000a9e:	64e2                	ld	s1,24(sp)
    80000aa0:	6942                	ld	s2,16(sp)
    80000aa2:	69a2                	ld	s3,8(sp)
    80000aa4:	6a02                	ld	s4,0(sp)
    80000aa6:	6145                	addi	sp,sp,48
    80000aa8:	8082                	ret

0000000080000aaa <kinit>:
{
    80000aaa:	1141                	addi	sp,sp,-16
    80000aac:	e406                	sd	ra,8(sp)
    80000aae:	e022                	sd	s0,0(sp)
    80000ab0:	0800                	addi	s0,sp,16
  initlock(&kmem.lock, "kmem");
    80000ab2:	00007597          	auipc	a1,0x7
    80000ab6:	5b658593          	addi	a1,a1,1462 # 80008068 <digits+0x28>
    80000aba:	00010517          	auipc	a0,0x10
    80000abe:	08650513          	addi	a0,a0,134 # 80010b40 <kmem>
    80000ac2:	00000097          	auipc	ra,0x0
    80000ac6:	084080e7          	jalr	132(ra) # 80000b46 <initlock>
  freerange(end, (void*)PHYSTOP);
    80000aca:	45c5                	li	a1,17
    80000acc:	05ee                	slli	a1,a1,0x1b
    80000ace:	00021517          	auipc	a0,0x21
    80000ad2:	4ba50513          	addi	a0,a0,1210 # 80021f88 <end>
    80000ad6:	00000097          	auipc	ra,0x0
    80000ada:	f88080e7          	jalr	-120(ra) # 80000a5e <freerange>
}
    80000ade:	60a2                	ld	ra,8(sp)
    80000ae0:	6402                	ld	s0,0(sp)
    80000ae2:	0141                	addi	sp,sp,16
    80000ae4:	8082                	ret

0000000080000ae6 <kalloc>:
// Allocate one 4096-byte page of physical memory.
// Returns a pointer that the kernel can use.
// Returns 0 if the memory cannot be allocated.
void *
kalloc(void)
{
    80000ae6:	1101                	addi	sp,sp,-32
    80000ae8:	ec06                	sd	ra,24(sp)
    80000aea:	e822                	sd	s0,16(sp)
    80000aec:	e426                	sd	s1,8(sp)
    80000aee:	1000                	addi	s0,sp,32
  struct run *r;

  acquire(&kmem.lock);
    80000af0:	00010497          	auipc	s1,0x10
    80000af4:	05048493          	addi	s1,s1,80 # 80010b40 <kmem>
    80000af8:	8526                	mv	a0,s1
    80000afa:	00000097          	auipc	ra,0x0
    80000afe:	0dc080e7          	jalr	220(ra) # 80000bd6 <acquire>
  r = kmem.freelist;
    80000b02:	6c84                	ld	s1,24(s1)
  if(r)
    80000b04:	c885                	beqz	s1,80000b34 <kalloc+0x4e>
    kmem.freelist = r->next;
    80000b06:	609c                	ld	a5,0(s1)
    80000b08:	00010517          	auipc	a0,0x10
    80000b0c:	03850513          	addi	a0,a0,56 # 80010b40 <kmem>
    80000b10:	ed1c                	sd	a5,24(a0)
  release(&kmem.lock);
    80000b12:	00000097          	auipc	ra,0x0
    80000b16:	178080e7          	jalr	376(ra) # 80000c8a <release>

  if(r)
    memset((char*)r, 5, PGSIZE); // fill with junk
    80000b1a:	6605                	lui	a2,0x1
    80000b1c:	4595                	li	a1,5
    80000b1e:	8526                	mv	a0,s1
    80000b20:	00000097          	auipc	ra,0x0
    80000b24:	1b2080e7          	jalr	434(ra) # 80000cd2 <memset>
  return (void*)r;
}
    80000b28:	8526                	mv	a0,s1
    80000b2a:	60e2                	ld	ra,24(sp)
    80000b2c:	6442                	ld	s0,16(sp)
    80000b2e:	64a2                	ld	s1,8(sp)
    80000b30:	6105                	addi	sp,sp,32
    80000b32:	8082                	ret
  release(&kmem.lock);
    80000b34:	00010517          	auipc	a0,0x10
    80000b38:	00c50513          	addi	a0,a0,12 # 80010b40 <kmem>
    80000b3c:	00000097          	auipc	ra,0x0
    80000b40:	14e080e7          	jalr	334(ra) # 80000c8a <release>
  if(r)
    80000b44:	b7d5                	j	80000b28 <kalloc+0x42>

0000000080000b46 <initlock>:
#include "proc.h"
#include "defs.h"

void
initlock(struct spinlock *lk, char *name)
{
    80000b46:	1141                	addi	sp,sp,-16
    80000b48:	e422                	sd	s0,8(sp)
    80000b4a:	0800                	addi	s0,sp,16
  lk->name = name;
    80000b4c:	e50c                	sd	a1,8(a0)
  lk->locked = 0;
    80000b4e:	00052023          	sw	zero,0(a0)
  lk->cpu = 0;
    80000b52:	00053823          	sd	zero,16(a0)
}
    80000b56:	6422                	ld	s0,8(sp)
    80000b58:	0141                	addi	sp,sp,16
    80000b5a:	8082                	ret

0000000080000b5c <holding>:
// Interrupts must be off.
int
holding(struct spinlock *lk)
{
  int r;
  r = (lk->locked && lk->cpu == mycpu());
    80000b5c:	411c                	lw	a5,0(a0)
    80000b5e:	e399                	bnez	a5,80000b64 <holding+0x8>
    80000b60:	4501                	li	a0,0
  return r;
}
    80000b62:	8082                	ret
{
    80000b64:	1101                	addi	sp,sp,-32
    80000b66:	ec06                	sd	ra,24(sp)
    80000b68:	e822                	sd	s0,16(sp)
    80000b6a:	e426                	sd	s1,8(sp)
    80000b6c:	1000                	addi	s0,sp,32
  r = (lk->locked && lk->cpu == mycpu());
    80000b6e:	6904                	ld	s1,16(a0)
    80000b70:	00001097          	auipc	ra,0x1
    80000b74:	e20080e7          	jalr	-480(ra) # 80001990 <mycpu>
    80000b78:	40a48533          	sub	a0,s1,a0
    80000b7c:	00153513          	seqz	a0,a0
}
    80000b80:	60e2                	ld	ra,24(sp)
    80000b82:	6442                	ld	s0,16(sp)
    80000b84:	64a2                	ld	s1,8(sp)
    80000b86:	6105                	addi	sp,sp,32
    80000b88:	8082                	ret

0000000080000b8a <push_off>:
// it takes two pop_off()s to undo two push_off()s.  Also, if interrupts
// are initially off, then push_off, pop_off leaves them off.

void
push_off(void)
{
    80000b8a:	1101                	addi	sp,sp,-32
    80000b8c:	ec06                	sd	ra,24(sp)
    80000b8e:	e822                	sd	s0,16(sp)
    80000b90:	e426                	sd	s1,8(sp)
    80000b92:	1000                	addi	s0,sp,32
  asm volatile("csrr %0, sstatus" : "=r" (x) );
    80000b94:	100024f3          	csrr	s1,sstatus
    80000b98:	100027f3          	csrr	a5,sstatus
  w_sstatus(r_sstatus() & ~SSTATUS_SIE);
    80000b9c:	9bf5                	andi	a5,a5,-3
  asm volatile("csrw sstatus, %0" : : "r" (x));
    80000b9e:	10079073          	csrw	sstatus,a5
  int old = intr_get();

  intr_off();
  if(mycpu()->noff == 0)
    80000ba2:	00001097          	auipc	ra,0x1
    80000ba6:	dee080e7          	jalr	-530(ra) # 80001990 <mycpu>
    80000baa:	5d3c                	lw	a5,120(a0)
    80000bac:	cf89                	beqz	a5,80000bc6 <push_off+0x3c>
    mycpu()->intena = old;
  mycpu()->noff += 1;
    80000bae:	00001097          	auipc	ra,0x1
    80000bb2:	de2080e7          	jalr	-542(ra) # 80001990 <mycpu>
    80000bb6:	5d3c                	lw	a5,120(a0)
    80000bb8:	2785                	addiw	a5,a5,1
    80000bba:	dd3c                	sw	a5,120(a0)
}
    80000bbc:	60e2                	ld	ra,24(sp)
    80000bbe:	6442                	ld	s0,16(sp)
    80000bc0:	64a2                	ld	s1,8(sp)
    80000bc2:	6105                	addi	sp,sp,32
    80000bc4:	8082                	ret
    mycpu()->intena = old;
    80000bc6:	00001097          	auipc	ra,0x1
    80000bca:	dca080e7          	jalr	-566(ra) # 80001990 <mycpu>
  return (x & SSTATUS_SIE) != 0;
    80000bce:	8085                	srli	s1,s1,0x1
    80000bd0:	8885                	andi	s1,s1,1
    80000bd2:	dd64                	sw	s1,124(a0)
    80000bd4:	bfe9                	j	80000bae <push_off+0x24>

0000000080000bd6 <acquire>:
{
    80000bd6:	1101                	addi	sp,sp,-32
    80000bd8:	ec06                	sd	ra,24(sp)
    80000bda:	e822                	sd	s0,16(sp)
    80000bdc:	e426                	sd	s1,8(sp)
    80000bde:	1000                	addi	s0,sp,32
    80000be0:	84aa                	mv	s1,a0
  push_off(); // disable interrupts to avoid deadlock.
    80000be2:	00000097          	auipc	ra,0x0
    80000be6:	fa8080e7          	jalr	-88(ra) # 80000b8a <push_off>
  if(holding(lk))
    80000bea:	8526                	mv	a0,s1
    80000bec:	00000097          	auipc	ra,0x0
    80000bf0:	f70080e7          	jalr	-144(ra) # 80000b5c <holding>
  while(__sync_lock_test_and_set(&lk->locked, 1) != 0)
    80000bf4:	4705                	li	a4,1
  if(holding(lk))
    80000bf6:	e115                	bnez	a0,80000c1a <acquire+0x44>
  while(__sync_lock_test_and_set(&lk->locked, 1) != 0)
    80000bf8:	87ba                	mv	a5,a4
    80000bfa:	0cf4a7af          	amoswap.w.aq	a5,a5,(s1)
    80000bfe:	2781                	sext.w	a5,a5
    80000c00:	ffe5                	bnez	a5,80000bf8 <acquire+0x22>
  __sync_synchronize();
    80000c02:	0ff0000f          	fence
  lk->cpu = mycpu();
    80000c06:	00001097          	auipc	ra,0x1
    80000c0a:	d8a080e7          	jalr	-630(ra) # 80001990 <mycpu>
    80000c0e:	e888                	sd	a0,16(s1)
}
    80000c10:	60e2                	ld	ra,24(sp)
    80000c12:	6442                	ld	s0,16(sp)
    80000c14:	64a2                	ld	s1,8(sp)
    80000c16:	6105                	addi	sp,sp,32
    80000c18:	8082                	ret
    panic("acquire");
    80000c1a:	00007517          	auipc	a0,0x7
    80000c1e:	45650513          	addi	a0,a0,1110 # 80008070 <digits+0x30>
    80000c22:	00000097          	auipc	ra,0x0
    80000c26:	91e080e7          	jalr	-1762(ra) # 80000540 <panic>

0000000080000c2a <pop_off>:

void
pop_off(void)
{
    80000c2a:	1141                	addi	sp,sp,-16
    80000c2c:	e406                	sd	ra,8(sp)
    80000c2e:	e022                	sd	s0,0(sp)
    80000c30:	0800                	addi	s0,sp,16
  struct cpu *c = mycpu();
    80000c32:	00001097          	auipc	ra,0x1
    80000c36:	d5e080e7          	jalr	-674(ra) # 80001990 <mycpu>
  asm volatile("csrr %0, sstatus" : "=r" (x) );
    80000c3a:	100027f3          	csrr	a5,sstatus
  return (x & SSTATUS_SIE) != 0;
    80000c3e:	8b89                	andi	a5,a5,2
  if(intr_get())
    80000c40:	e78d                	bnez	a5,80000c6a <pop_off+0x40>
    panic("pop_off - interruptible");
  if(c->noff < 1)
    80000c42:	5d3c                	lw	a5,120(a0)
    80000c44:	02f05b63          	blez	a5,80000c7a <pop_off+0x50>
    panic("pop_off");
  c->noff -= 1;
    80000c48:	37fd                	addiw	a5,a5,-1
    80000c4a:	0007871b          	sext.w	a4,a5
    80000c4e:	dd3c                	sw	a5,120(a0)
  if(c->noff == 0 && c->intena)
    80000c50:	eb09                	bnez	a4,80000c62 <pop_off+0x38>
    80000c52:	5d7c                	lw	a5,124(a0)
    80000c54:	c799                	beqz	a5,80000c62 <pop_off+0x38>
  asm volatile("csrr %0, sstatus" : "=r" (x) );
    80000c56:	100027f3          	csrr	a5,sstatus
  w_sstatus(r_sstatus() | SSTATUS_SIE);
    80000c5a:	0027e793          	ori	a5,a5,2
  asm volatile("csrw sstatus, %0" : : "r" (x));
    80000c5e:	10079073          	csrw	sstatus,a5
    intr_on();
}
    80000c62:	60a2                	ld	ra,8(sp)
    80000c64:	6402                	ld	s0,0(sp)
    80000c66:	0141                	addi	sp,sp,16
    80000c68:	8082                	ret
    panic("pop_off - interruptible");
    80000c6a:	00007517          	auipc	a0,0x7
    80000c6e:	40e50513          	addi	a0,a0,1038 # 80008078 <digits+0x38>
    80000c72:	00000097          	auipc	ra,0x0
    80000c76:	8ce080e7          	jalr	-1842(ra) # 80000540 <panic>
    panic("pop_off");
    80000c7a:	00007517          	auipc	a0,0x7
    80000c7e:	41650513          	addi	a0,a0,1046 # 80008090 <digits+0x50>
    80000c82:	00000097          	auipc	ra,0x0
    80000c86:	8be080e7          	jalr	-1858(ra) # 80000540 <panic>

0000000080000c8a <release>:
{
    80000c8a:	1101                	addi	sp,sp,-32
    80000c8c:	ec06                	sd	ra,24(sp)
    80000c8e:	e822                	sd	s0,16(sp)
    80000c90:	e426                	sd	s1,8(sp)
    80000c92:	1000                	addi	s0,sp,32
    80000c94:	84aa                	mv	s1,a0
  if(!holding(lk))
    80000c96:	00000097          	auipc	ra,0x0
    80000c9a:	ec6080e7          	jalr	-314(ra) # 80000b5c <holding>
    80000c9e:	c115                	beqz	a0,80000cc2 <release+0x38>
  lk->cpu = 0;
    80000ca0:	0004b823          	sd	zero,16(s1)
  __sync_synchronize();
    80000ca4:	0ff0000f          	fence
  __sync_lock_release(&lk->locked);
    80000ca8:	0f50000f          	fence	iorw,ow
    80000cac:	0804a02f          	amoswap.w	zero,zero,(s1)
  pop_off();
    80000cb0:	00000097          	auipc	ra,0x0
    80000cb4:	f7a080e7          	jalr	-134(ra) # 80000c2a <pop_off>
}
    80000cb8:	60e2                	ld	ra,24(sp)
    80000cba:	6442                	ld	s0,16(sp)
    80000cbc:	64a2                	ld	s1,8(sp)
    80000cbe:	6105                	addi	sp,sp,32
    80000cc0:	8082                	ret
    panic("release");
    80000cc2:	00007517          	auipc	a0,0x7
    80000cc6:	3d650513          	addi	a0,a0,982 # 80008098 <digits+0x58>
    80000cca:	00000097          	auipc	ra,0x0
    80000cce:	876080e7          	jalr	-1930(ra) # 80000540 <panic>

0000000080000cd2 <memset>:
#include "types.h"

void*
memset(void *dst, int c, uint n)
{
    80000cd2:	1141                	addi	sp,sp,-16
    80000cd4:	e422                	sd	s0,8(sp)
    80000cd6:	0800                	addi	s0,sp,16
  char *cdst = (char *) dst;
  int i;
  for(i = 0; i < n; i++){
    80000cd8:	ca19                	beqz	a2,80000cee <memset+0x1c>
    80000cda:	87aa                	mv	a5,a0
    80000cdc:	1602                	slli	a2,a2,0x20
    80000cde:	9201                	srli	a2,a2,0x20
    80000ce0:	00a60733          	add	a4,a2,a0
    cdst[i] = c;
    80000ce4:	00b78023          	sb	a1,0(a5)
  for(i = 0; i < n; i++){
    80000ce8:	0785                	addi	a5,a5,1
    80000cea:	fee79de3          	bne	a5,a4,80000ce4 <memset+0x12>
  }
  return dst;
}
    80000cee:	6422                	ld	s0,8(sp)
    80000cf0:	0141                	addi	sp,sp,16
    80000cf2:	8082                	ret

0000000080000cf4 <memcmp>:

int
memcmp(const void *v1, const void *v2, uint n)
{
    80000cf4:	1141                	addi	sp,sp,-16
    80000cf6:	e422                	sd	s0,8(sp)
    80000cf8:	0800                	addi	s0,sp,16
  const uchar *s1, *s2;

  s1 = v1;
  s2 = v2;
  while(n-- > 0){
    80000cfa:	ca05                	beqz	a2,80000d2a <memcmp+0x36>
    80000cfc:	fff6069b          	addiw	a3,a2,-1 # fff <_entry-0x7ffff001>
    80000d00:	1682                	slli	a3,a3,0x20
    80000d02:	9281                	srli	a3,a3,0x20
    80000d04:	0685                	addi	a3,a3,1
    80000d06:	96aa                	add	a3,a3,a0
    if(*s1 != *s2)
    80000d08:	00054783          	lbu	a5,0(a0)
    80000d0c:	0005c703          	lbu	a4,0(a1)
    80000d10:	00e79863          	bne	a5,a4,80000d20 <memcmp+0x2c>
      return *s1 - *s2;
    s1++, s2++;
    80000d14:	0505                	addi	a0,a0,1
    80000d16:	0585                	addi	a1,a1,1
  while(n-- > 0){
    80000d18:	fed518e3          	bne	a0,a3,80000d08 <memcmp+0x14>
  }

  return 0;
    80000d1c:	4501                	li	a0,0
    80000d1e:	a019                	j	80000d24 <memcmp+0x30>
      return *s1 - *s2;
    80000d20:	40e7853b          	subw	a0,a5,a4
}
    80000d24:	6422                	ld	s0,8(sp)
    80000d26:	0141                	addi	sp,sp,16
    80000d28:	8082                	ret
  return 0;
    80000d2a:	4501                	li	a0,0
    80000d2c:	bfe5                	j	80000d24 <memcmp+0x30>

0000000080000d2e <memmove>:

void*
memmove(void *dst, const void *src, uint n)
{
    80000d2e:	1141                	addi	sp,sp,-16
    80000d30:	e422                	sd	s0,8(sp)
    80000d32:	0800                	addi	s0,sp,16
  const char *s;
  char *d;

  if(n == 0)
    80000d34:	c205                	beqz	a2,80000d54 <memmove+0x26>
    return dst;
  
  s = src;
  d = dst;
  if(s < d && s + n > d){
    80000d36:	02a5e263          	bltu	a1,a0,80000d5a <memmove+0x2c>
    s += n;
    d += n;
    while(n-- > 0)
      *--d = *--s;
  } else
    while(n-- > 0)
    80000d3a:	1602                	slli	a2,a2,0x20
    80000d3c:	9201                	srli	a2,a2,0x20
    80000d3e:	00c587b3          	add	a5,a1,a2
{
    80000d42:	872a                	mv	a4,a0
      *d++ = *s++;
    80000d44:	0585                	addi	a1,a1,1
    80000d46:	0705                	addi	a4,a4,1 # fffffffffffff001 <end+0xffffffff7ffdd079>
    80000d48:	fff5c683          	lbu	a3,-1(a1)
    80000d4c:	fed70fa3          	sb	a3,-1(a4)
    while(n-- > 0)
    80000d50:	fef59ae3          	bne	a1,a5,80000d44 <memmove+0x16>

  return dst;
}
    80000d54:	6422                	ld	s0,8(sp)
    80000d56:	0141                	addi	sp,sp,16
    80000d58:	8082                	ret
  if(s < d && s + n > d){
    80000d5a:	02061693          	slli	a3,a2,0x20
    80000d5e:	9281                	srli	a3,a3,0x20
    80000d60:	00d58733          	add	a4,a1,a3
    80000d64:	fce57be3          	bgeu	a0,a4,80000d3a <memmove+0xc>
    d += n;
    80000d68:	96aa                	add	a3,a3,a0
    while(n-- > 0)
    80000d6a:	fff6079b          	addiw	a5,a2,-1
    80000d6e:	1782                	slli	a5,a5,0x20
    80000d70:	9381                	srli	a5,a5,0x20
    80000d72:	fff7c793          	not	a5,a5
    80000d76:	97ba                	add	a5,a5,a4
      *--d = *--s;
    80000d78:	177d                	addi	a4,a4,-1
    80000d7a:	16fd                	addi	a3,a3,-1
    80000d7c:	00074603          	lbu	a2,0(a4)
    80000d80:	00c68023          	sb	a2,0(a3)
    while(n-- > 0)
    80000d84:	fee79ae3          	bne	a5,a4,80000d78 <memmove+0x4a>
    80000d88:	b7f1                	j	80000d54 <memmove+0x26>

0000000080000d8a <memcpy>:

// memcpy exists to placate GCC.  Use memmove.
void*
memcpy(void *dst, const void *src, uint n)
{
    80000d8a:	1141                	addi	sp,sp,-16
    80000d8c:	e406                	sd	ra,8(sp)
    80000d8e:	e022                	sd	s0,0(sp)
    80000d90:	0800                	addi	s0,sp,16
  return memmove(dst, src, n);
    80000d92:	00000097          	auipc	ra,0x0
    80000d96:	f9c080e7          	jalr	-100(ra) # 80000d2e <memmove>
}
    80000d9a:	60a2                	ld	ra,8(sp)
    80000d9c:	6402                	ld	s0,0(sp)
    80000d9e:	0141                	addi	sp,sp,16
    80000da0:	8082                	ret

0000000080000da2 <strncmp>:

int
strncmp(const char *p, const char *q, uint n)
{
    80000da2:	1141                	addi	sp,sp,-16
    80000da4:	e422                	sd	s0,8(sp)
    80000da6:	0800                	addi	s0,sp,16
  while(n > 0 && *p && *p == *q)
    80000da8:	ce11                	beqz	a2,80000dc4 <strncmp+0x22>
    80000daa:	00054783          	lbu	a5,0(a0)
    80000dae:	cf89                	beqz	a5,80000dc8 <strncmp+0x26>
    80000db0:	0005c703          	lbu	a4,0(a1)
    80000db4:	00f71a63          	bne	a4,a5,80000dc8 <strncmp+0x26>
    n--, p++, q++;
    80000db8:	367d                	addiw	a2,a2,-1
    80000dba:	0505                	addi	a0,a0,1
    80000dbc:	0585                	addi	a1,a1,1
  while(n > 0 && *p && *p == *q)
    80000dbe:	f675                	bnez	a2,80000daa <strncmp+0x8>
  if(n == 0)
    return 0;
    80000dc0:	4501                	li	a0,0
    80000dc2:	a809                	j	80000dd4 <strncmp+0x32>
    80000dc4:	4501                	li	a0,0
    80000dc6:	a039                	j	80000dd4 <strncmp+0x32>
  if(n == 0)
    80000dc8:	ca09                	beqz	a2,80000dda <strncmp+0x38>
  return (uchar)*p - (uchar)*q;
    80000dca:	00054503          	lbu	a0,0(a0)
    80000dce:	0005c783          	lbu	a5,0(a1)
    80000dd2:	9d1d                	subw	a0,a0,a5
}
    80000dd4:	6422                	ld	s0,8(sp)
    80000dd6:	0141                	addi	sp,sp,16
    80000dd8:	8082                	ret
    return 0;
    80000dda:	4501                	li	a0,0
    80000ddc:	bfe5                	j	80000dd4 <strncmp+0x32>

0000000080000dde <strncpy>:

char*
strncpy(char *s, const char *t, int n)
{
    80000dde:	1141                	addi	sp,sp,-16
    80000de0:	e422                	sd	s0,8(sp)
    80000de2:	0800                	addi	s0,sp,16
  char *os;

  os = s;
  while(n-- > 0 && (*s++ = *t++) != 0)
    80000de4:	872a                	mv	a4,a0
    80000de6:	8832                	mv	a6,a2
    80000de8:	367d                	addiw	a2,a2,-1
    80000dea:	01005963          	blez	a6,80000dfc <strncpy+0x1e>
    80000dee:	0705                	addi	a4,a4,1
    80000df0:	0005c783          	lbu	a5,0(a1)
    80000df4:	fef70fa3          	sb	a5,-1(a4)
    80000df8:	0585                	addi	a1,a1,1
    80000dfa:	f7f5                	bnez	a5,80000de6 <strncpy+0x8>
    ;
  while(n-- > 0)
    80000dfc:	86ba                	mv	a3,a4
    80000dfe:	00c05c63          	blez	a2,80000e16 <strncpy+0x38>
    *s++ = 0;
    80000e02:	0685                	addi	a3,a3,1
    80000e04:	fe068fa3          	sb	zero,-1(a3)
  while(n-- > 0)
    80000e08:	40d707bb          	subw	a5,a4,a3
    80000e0c:	37fd                	addiw	a5,a5,-1
    80000e0e:	010787bb          	addw	a5,a5,a6
    80000e12:	fef048e3          	bgtz	a5,80000e02 <strncpy+0x24>
  return os;
}
    80000e16:	6422                	ld	s0,8(sp)
    80000e18:	0141                	addi	sp,sp,16
    80000e1a:	8082                	ret

0000000080000e1c <safestrcpy>:

// Like strncpy but guaranteed to NUL-terminate.
char*
safestrcpy(char *s, const char *t, int n)
{
    80000e1c:	1141                	addi	sp,sp,-16
    80000e1e:	e422                	sd	s0,8(sp)
    80000e20:	0800                	addi	s0,sp,16
  char *os;

  os = s;
  if(n <= 0)
    80000e22:	02c05363          	blez	a2,80000e48 <safestrcpy+0x2c>
    80000e26:	fff6069b          	addiw	a3,a2,-1
    80000e2a:	1682                	slli	a3,a3,0x20
    80000e2c:	9281                	srli	a3,a3,0x20
    80000e2e:	96ae                	add	a3,a3,a1
    80000e30:	87aa                	mv	a5,a0
    return os;
  while(--n > 0 && (*s++ = *t++) != 0)
    80000e32:	00d58963          	beq	a1,a3,80000e44 <safestrcpy+0x28>
    80000e36:	0585                	addi	a1,a1,1
    80000e38:	0785                	addi	a5,a5,1
    80000e3a:	fff5c703          	lbu	a4,-1(a1)
    80000e3e:	fee78fa3          	sb	a4,-1(a5)
    80000e42:	fb65                	bnez	a4,80000e32 <safestrcpy+0x16>
    ;
  *s = 0;
    80000e44:	00078023          	sb	zero,0(a5)
  return os;
}
    80000e48:	6422                	ld	s0,8(sp)
    80000e4a:	0141                	addi	sp,sp,16
    80000e4c:	8082                	ret

0000000080000e4e <strlen>:

int
strlen(const char *s)
{
    80000e4e:	1141                	addi	sp,sp,-16
    80000e50:	e422                	sd	s0,8(sp)
    80000e52:	0800                	addi	s0,sp,16
  int n;

  for(n = 0; s[n]; n++)
    80000e54:	00054783          	lbu	a5,0(a0)
    80000e58:	cf91                	beqz	a5,80000e74 <strlen+0x26>
    80000e5a:	0505                	addi	a0,a0,1
    80000e5c:	87aa                	mv	a5,a0
    80000e5e:	4685                	li	a3,1
    80000e60:	9e89                	subw	a3,a3,a0
    80000e62:	00f6853b          	addw	a0,a3,a5
    80000e66:	0785                	addi	a5,a5,1
    80000e68:	fff7c703          	lbu	a4,-1(a5)
    80000e6c:	fb7d                	bnez	a4,80000e62 <strlen+0x14>
    ;
  return n;
}
    80000e6e:	6422                	ld	s0,8(sp)
    80000e70:	0141                	addi	sp,sp,16
    80000e72:	8082                	ret
  for(n = 0; s[n]; n++)
    80000e74:	4501                	li	a0,0
    80000e76:	bfe5                	j	80000e6e <strlen+0x20>

0000000080000e78 <main>:
volatile static int started = 0;

// start() jumps here in supervisor mode on all CPUs.
void
main()
{
    80000e78:	1141                	addi	sp,sp,-16
    80000e7a:	e406                	sd	ra,8(sp)
    80000e7c:	e022                	sd	s0,0(sp)
    80000e7e:	0800                	addi	s0,sp,16
  if(cpuid() == 0){
    80000e80:	00001097          	auipc	ra,0x1
    80000e84:	b00080e7          	jalr	-1280(ra) # 80001980 <cpuid>
    virtio_disk_init(); // emulated hard disk
    userinit();      // first user process
    __sync_synchronize();
    started = 1;
  } else {
    while(started == 0)
    80000e88:	00008717          	auipc	a4,0x8
    80000e8c:	a5070713          	addi	a4,a4,-1456 # 800088d8 <started>
  if(cpuid() == 0){
    80000e90:	c139                	beqz	a0,80000ed6 <main+0x5e>
    while(started == 0)
    80000e92:	431c                	lw	a5,0(a4)
    80000e94:	2781                	sext.w	a5,a5
    80000e96:	dff5                	beqz	a5,80000e92 <main+0x1a>
      ;
    __sync_synchronize();
    80000e98:	0ff0000f          	fence
    printf("hart %d starting\n", cpuid());
    80000e9c:	00001097          	auipc	ra,0x1
    80000ea0:	ae4080e7          	jalr	-1308(ra) # 80001980 <cpuid>
    80000ea4:	85aa                	mv	a1,a0
    80000ea6:	00007517          	auipc	a0,0x7
    80000eaa:	21250513          	addi	a0,a0,530 # 800080b8 <digits+0x78>
    80000eae:	fffff097          	auipc	ra,0xfffff
    80000eb2:	6dc080e7          	jalr	1756(ra) # 8000058a <printf>
    kvminithart();    // turn on paging
    80000eb6:	00000097          	auipc	ra,0x0
    80000eba:	0d8080e7          	jalr	216(ra) # 80000f8e <kvminithart>
    trapinithart();   // install kernel trap vector
    80000ebe:	00002097          	auipc	ra,0x2
    80000ec2:	9f6080e7          	jalr	-1546(ra) # 800028b4 <trapinithart>
    plicinithart();   // ask PLIC for device interrupts
    80000ec6:	00005097          	auipc	ra,0x5
    80000eca:	fda080e7          	jalr	-38(ra) # 80005ea0 <plicinithart>
  }

  scheduler();        
    80000ece:	00001097          	auipc	ra,0x1
    80000ed2:	042080e7          	jalr	66(ra) # 80001f10 <scheduler>
    consoleinit();
    80000ed6:	fffff097          	auipc	ra,0xfffff
    80000eda:	57a080e7          	jalr	1402(ra) # 80000450 <consoleinit>
    printfinit();
    80000ede:	00000097          	auipc	ra,0x0
    80000ee2:	88c080e7          	jalr	-1908(ra) # 8000076a <printfinit>
    printf("\n");
    80000ee6:	00007517          	auipc	a0,0x7
    80000eea:	1e250513          	addi	a0,a0,482 # 800080c8 <digits+0x88>
    80000eee:	fffff097          	auipc	ra,0xfffff
    80000ef2:	69c080e7          	jalr	1692(ra) # 8000058a <printf>
    printf("xv6 kernel is booting\n");
    80000ef6:	00007517          	auipc	a0,0x7
    80000efa:	1aa50513          	addi	a0,a0,426 # 800080a0 <digits+0x60>
    80000efe:	fffff097          	auipc	ra,0xfffff
    80000f02:	68c080e7          	jalr	1676(ra) # 8000058a <printf>
    printf("\n");
    80000f06:	00007517          	auipc	a0,0x7
    80000f0a:	1c250513          	addi	a0,a0,450 # 800080c8 <digits+0x88>
    80000f0e:	fffff097          	auipc	ra,0xfffff
    80000f12:	67c080e7          	jalr	1660(ra) # 8000058a <printf>
    kinit();         // physical page allocator
    80000f16:	00000097          	auipc	ra,0x0
    80000f1a:	b94080e7          	jalr	-1132(ra) # 80000aaa <kinit>
    kvminit();       // create kernel page table
    80000f1e:	00000097          	auipc	ra,0x0
    80000f22:	326080e7          	jalr	806(ra) # 80001244 <kvminit>
    kvminithart();   // turn on paging
    80000f26:	00000097          	auipc	ra,0x0
    80000f2a:	068080e7          	jalr	104(ra) # 80000f8e <kvminithart>
    procinit();      // process table
    80000f2e:	00001097          	auipc	ra,0x1
    80000f32:	99e080e7          	jalr	-1634(ra) # 800018cc <procinit>
    trapinit();      // trap vectors
    80000f36:	00002097          	auipc	ra,0x2
    80000f3a:	956080e7          	jalr	-1706(ra) # 8000288c <trapinit>
    trapinithart();  // install kernel trap vector
    80000f3e:	00002097          	auipc	ra,0x2
    80000f42:	976080e7          	jalr	-1674(ra) # 800028b4 <trapinithart>
    plicinit();      // set up interrupt controller
    80000f46:	00005097          	auipc	ra,0x5
    80000f4a:	f44080e7          	jalr	-188(ra) # 80005e8a <plicinit>
    plicinithart();  // ask PLIC for device interrupts
    80000f4e:	00005097          	auipc	ra,0x5
    80000f52:	f52080e7          	jalr	-174(ra) # 80005ea0 <plicinithart>
    binit();         // buffer cache
    80000f56:	00002097          	auipc	ra,0x2
    80000f5a:	0ea080e7          	jalr	234(ra) # 80003040 <binit>
    iinit();         // inode table
    80000f5e:	00002097          	auipc	ra,0x2
    80000f62:	78a080e7          	jalr	1930(ra) # 800036e8 <iinit>
    fileinit();      // file table
    80000f66:	00003097          	auipc	ra,0x3
    80000f6a:	730080e7          	jalr	1840(ra) # 80004696 <fileinit>
    virtio_disk_init(); // emulated hard disk
    80000f6e:	00005097          	auipc	ra,0x5
    80000f72:	03a080e7          	jalr	58(ra) # 80005fa8 <virtio_disk_init>
    userinit();      // first user process
    80000f76:	00001097          	auipc	ra,0x1
    80000f7a:	d7c080e7          	jalr	-644(ra) # 80001cf2 <userinit>
    __sync_synchronize();
    80000f7e:	0ff0000f          	fence
    started = 1;
    80000f82:	4785                	li	a5,1
    80000f84:	00008717          	auipc	a4,0x8
    80000f88:	94f72a23          	sw	a5,-1708(a4) # 800088d8 <started>
    80000f8c:	b789                	j	80000ece <main+0x56>

0000000080000f8e <kvminithart>:

// Switch h/w page table register to the kernel's page table,
// and enable paging.
void
kvminithart()
{
    80000f8e:	1141                	addi	sp,sp,-16
    80000f90:	e422                	sd	s0,8(sp)
    80000f92:	0800                	addi	s0,sp,16
// flush the TLB.
static inline void
sfence_vma()
{
  // the zero, zero means flush all TLB entries.
  asm volatile("sfence.vma zero, zero");
    80000f94:	12000073          	sfence.vma
  // wait for any previous writes to the page table memory to finish.
  sfence_vma();

  w_satp(MAKE_SATP(kernel_pagetable));
    80000f98:	00008797          	auipc	a5,0x8
    80000f9c:	9487b783          	ld	a5,-1720(a5) # 800088e0 <kernel_pagetable>
    80000fa0:	83b1                	srli	a5,a5,0xc
    80000fa2:	577d                	li	a4,-1
    80000fa4:	177e                	slli	a4,a4,0x3f
    80000fa6:	8fd9                	or	a5,a5,a4
  asm volatile("csrw satp, %0" : : "r" (x));
    80000fa8:	18079073          	csrw	satp,a5
  asm volatile("sfence.vma zero, zero");
    80000fac:	12000073          	sfence.vma

  // flush stale entries from the TLB.
  sfence_vma();
}
    80000fb0:	6422                	ld	s0,8(sp)
    80000fb2:	0141                	addi	sp,sp,16
    80000fb4:	8082                	ret

0000000080000fb6 <walk>:
//   21..29 -- 9 bits of level-1 index.
//   12..20 -- 9 bits of level-0 index.
//    0..11 -- 12 bits of byte offset within the page.
pte_t *
walk(pagetable_t pagetable, uint64 va, int alloc)
{
    80000fb6:	7139                	addi	sp,sp,-64
    80000fb8:	fc06                	sd	ra,56(sp)
    80000fba:	f822                	sd	s0,48(sp)
    80000fbc:	f426                	sd	s1,40(sp)
    80000fbe:	f04a                	sd	s2,32(sp)
    80000fc0:	ec4e                	sd	s3,24(sp)
    80000fc2:	e852                	sd	s4,16(sp)
    80000fc4:	e456                	sd	s5,8(sp)
    80000fc6:	e05a                	sd	s6,0(sp)
    80000fc8:	0080                	addi	s0,sp,64
    80000fca:	84aa                	mv	s1,a0
    80000fcc:	89ae                	mv	s3,a1
    80000fce:	8ab2                	mv	s5,a2
  if(va >= MAXVA)
    80000fd0:	57fd                	li	a5,-1
    80000fd2:	83e9                	srli	a5,a5,0x1a
    80000fd4:	4a79                	li	s4,30
    panic("walk");

  for(int level = 2; level > 0; level--) {
    80000fd6:	4b31                	li	s6,12
  if(va >= MAXVA)
    80000fd8:	04b7f263          	bgeu	a5,a1,8000101c <walk+0x66>
    panic("walk");
    80000fdc:	00007517          	auipc	a0,0x7
    80000fe0:	0f450513          	addi	a0,a0,244 # 800080d0 <digits+0x90>
    80000fe4:	fffff097          	auipc	ra,0xfffff
    80000fe8:	55c080e7          	jalr	1372(ra) # 80000540 <panic>
    pte_t *pte = &pagetable[PX(level, va)];
    if(*pte & PTE_V) {
      pagetable = (pagetable_t)PTE2PA(*pte);
    } else {
      if(!alloc || (pagetable = (pde_t*)kalloc()) == 0)
    80000fec:	060a8663          	beqz	s5,80001058 <walk+0xa2>
    80000ff0:	00000097          	auipc	ra,0x0
    80000ff4:	af6080e7          	jalr	-1290(ra) # 80000ae6 <kalloc>
    80000ff8:	84aa                	mv	s1,a0
    80000ffa:	c529                	beqz	a0,80001044 <walk+0x8e>
        return 0;
      memset(pagetable, 0, PGSIZE);
    80000ffc:	6605                	lui	a2,0x1
    80000ffe:	4581                	li	a1,0
    80001000:	00000097          	auipc	ra,0x0
    80001004:	cd2080e7          	jalr	-814(ra) # 80000cd2 <memset>
      *pte = PA2PTE(pagetable) | PTE_V;
    80001008:	00c4d793          	srli	a5,s1,0xc
    8000100c:	07aa                	slli	a5,a5,0xa
    8000100e:	0017e793          	ori	a5,a5,1
    80001012:	00f93023          	sd	a5,0(s2)
  for(int level = 2; level > 0; level--) {
    80001016:	3a5d                	addiw	s4,s4,-9 # ffffffffffffeff7 <end+0xffffffff7ffdd06f>
    80001018:	036a0063          	beq	s4,s6,80001038 <walk+0x82>
    pte_t *pte = &pagetable[PX(level, va)];
    8000101c:	0149d933          	srl	s2,s3,s4
    80001020:	1ff97913          	andi	s2,s2,511
    80001024:	090e                	slli	s2,s2,0x3
    80001026:	9926                	add	s2,s2,s1
    if(*pte & PTE_V) {
    80001028:	00093483          	ld	s1,0(s2)
    8000102c:	0014f793          	andi	a5,s1,1
    80001030:	dfd5                	beqz	a5,80000fec <walk+0x36>
      pagetable = (pagetable_t)PTE2PA(*pte);
    80001032:	80a9                	srli	s1,s1,0xa
    80001034:	04b2                	slli	s1,s1,0xc
    80001036:	b7c5                	j	80001016 <walk+0x60>
    }
  }
  return &pagetable[PX(0, va)];
    80001038:	00c9d513          	srli	a0,s3,0xc
    8000103c:	1ff57513          	andi	a0,a0,511
    80001040:	050e                	slli	a0,a0,0x3
    80001042:	9526                	add	a0,a0,s1
}
    80001044:	70e2                	ld	ra,56(sp)
    80001046:	7442                	ld	s0,48(sp)
    80001048:	74a2                	ld	s1,40(sp)
    8000104a:	7902                	ld	s2,32(sp)
    8000104c:	69e2                	ld	s3,24(sp)
    8000104e:	6a42                	ld	s4,16(sp)
    80001050:	6aa2                	ld	s5,8(sp)
    80001052:	6b02                	ld	s6,0(sp)
    80001054:	6121                	addi	sp,sp,64
    80001056:	8082                	ret
        return 0;
    80001058:	4501                	li	a0,0
    8000105a:	b7ed                	j	80001044 <walk+0x8e>

000000008000105c <walkaddr>:
walkaddr(pagetable_t pagetable, uint64 va)
{
  pte_t *pte;
  uint64 pa;

  if(va >= MAXVA)
    8000105c:	57fd                	li	a5,-1
    8000105e:	83e9                	srli	a5,a5,0x1a
    80001060:	00b7f463          	bgeu	a5,a1,80001068 <walkaddr+0xc>
    return 0;
    80001064:	4501                	li	a0,0
    return 0;
  if((*pte & PTE_U) == 0)
    return 0;
  pa = PTE2PA(*pte);
  return pa;
}
    80001066:	8082                	ret
{
    80001068:	1141                	addi	sp,sp,-16
    8000106a:	e406                	sd	ra,8(sp)
    8000106c:	e022                	sd	s0,0(sp)
    8000106e:	0800                	addi	s0,sp,16
  pte = walk(pagetable, va, 0);
    80001070:	4601                	li	a2,0
    80001072:	00000097          	auipc	ra,0x0
    80001076:	f44080e7          	jalr	-188(ra) # 80000fb6 <walk>
  if(pte == 0)
    8000107a:	c105                	beqz	a0,8000109a <walkaddr+0x3e>
  if((*pte & PTE_V) == 0)
    8000107c:	611c                	ld	a5,0(a0)
  if((*pte & PTE_U) == 0)
    8000107e:	0117f693          	andi	a3,a5,17
    80001082:	4745                	li	a4,17
    return 0;
    80001084:	4501                	li	a0,0
  if((*pte & PTE_U) == 0)
    80001086:	00e68663          	beq	a3,a4,80001092 <walkaddr+0x36>
}
    8000108a:	60a2                	ld	ra,8(sp)
    8000108c:	6402                	ld	s0,0(sp)
    8000108e:	0141                	addi	sp,sp,16
    80001090:	8082                	ret
  pa = PTE2PA(*pte);
    80001092:	83a9                	srli	a5,a5,0xa
    80001094:	00c79513          	slli	a0,a5,0xc
  return pa;
    80001098:	bfcd                	j	8000108a <walkaddr+0x2e>
    return 0;
    8000109a:	4501                	li	a0,0
    8000109c:	b7fd                	j	8000108a <walkaddr+0x2e>

000000008000109e <mappages>:
// physical addresses starting at pa. va and size might not
// be page-aligned. Returns 0 on success, -1 if walk() couldn't
// allocate a needed page-table page.
int
mappages(pagetable_t pagetable, uint64 va, uint64 size, uint64 pa, int perm)
{
    8000109e:	715d                	addi	sp,sp,-80
    800010a0:	e486                	sd	ra,72(sp)
    800010a2:	e0a2                	sd	s0,64(sp)
    800010a4:	fc26                	sd	s1,56(sp)
    800010a6:	f84a                	sd	s2,48(sp)
    800010a8:	f44e                	sd	s3,40(sp)
    800010aa:	f052                	sd	s4,32(sp)
    800010ac:	ec56                	sd	s5,24(sp)
    800010ae:	e85a                	sd	s6,16(sp)
    800010b0:	e45e                	sd	s7,8(sp)
    800010b2:	0880                	addi	s0,sp,80
  uint64 a, last;
  pte_t *pte;

  if(size == 0)
    800010b4:	c639                	beqz	a2,80001102 <mappages+0x64>
    800010b6:	8aaa                	mv	s5,a0
    800010b8:	8b3a                	mv	s6,a4
    panic("mappages: size");
  
  a = PGROUNDDOWN(va);
    800010ba:	777d                	lui	a4,0xfffff
    800010bc:	00e5f7b3          	and	a5,a1,a4
  last = PGROUNDDOWN(va + size - 1);
    800010c0:	fff58993          	addi	s3,a1,-1
    800010c4:	99b2                	add	s3,s3,a2
    800010c6:	00e9f9b3          	and	s3,s3,a4
  a = PGROUNDDOWN(va);
    800010ca:	893e                	mv	s2,a5
    800010cc:	40f68a33          	sub	s4,a3,a5
    if(*pte & PTE_V)
      panic("mappages: remap");
    *pte = PA2PTE(pa) | perm | PTE_V;
    if(a == last)
      break;
    a += PGSIZE;
    800010d0:	6b85                	lui	s7,0x1
    800010d2:	012a04b3          	add	s1,s4,s2
    if((pte = walk(pagetable, a, 1)) == 0)
    800010d6:	4605                	li	a2,1
    800010d8:	85ca                	mv	a1,s2
    800010da:	8556                	mv	a0,s5
    800010dc:	00000097          	auipc	ra,0x0
    800010e0:	eda080e7          	jalr	-294(ra) # 80000fb6 <walk>
    800010e4:	cd1d                	beqz	a0,80001122 <mappages+0x84>
    if(*pte & PTE_V)
    800010e6:	611c                	ld	a5,0(a0)
    800010e8:	8b85                	andi	a5,a5,1
    800010ea:	e785                	bnez	a5,80001112 <mappages+0x74>
    *pte = PA2PTE(pa) | perm | PTE_V;
    800010ec:	80b1                	srli	s1,s1,0xc
    800010ee:	04aa                	slli	s1,s1,0xa
    800010f0:	0164e4b3          	or	s1,s1,s6
    800010f4:	0014e493          	ori	s1,s1,1
    800010f8:	e104                	sd	s1,0(a0)
    if(a == last)
    800010fa:	05390063          	beq	s2,s3,8000113a <mappages+0x9c>
    a += PGSIZE;
    800010fe:	995e                	add	s2,s2,s7
    if((pte = walk(pagetable, a, 1)) == 0)
    80001100:	bfc9                	j	800010d2 <mappages+0x34>
    panic("mappages: size");
    80001102:	00007517          	auipc	a0,0x7
    80001106:	fd650513          	addi	a0,a0,-42 # 800080d8 <digits+0x98>
    8000110a:	fffff097          	auipc	ra,0xfffff
    8000110e:	436080e7          	jalr	1078(ra) # 80000540 <panic>
      panic("mappages: remap");
    80001112:	00007517          	auipc	a0,0x7
    80001116:	fd650513          	addi	a0,a0,-42 # 800080e8 <digits+0xa8>
    8000111a:	fffff097          	auipc	ra,0xfffff
    8000111e:	426080e7          	jalr	1062(ra) # 80000540 <panic>
      return -1;
    80001122:	557d                	li	a0,-1
    pa += PGSIZE;
  }
  return 0;
}
    80001124:	60a6                	ld	ra,72(sp)
    80001126:	6406                	ld	s0,64(sp)
    80001128:	74e2                	ld	s1,56(sp)
    8000112a:	7942                	ld	s2,48(sp)
    8000112c:	79a2                	ld	s3,40(sp)
    8000112e:	7a02                	ld	s4,32(sp)
    80001130:	6ae2                	ld	s5,24(sp)
    80001132:	6b42                	ld	s6,16(sp)
    80001134:	6ba2                	ld	s7,8(sp)
    80001136:	6161                	addi	sp,sp,80
    80001138:	8082                	ret
  return 0;
    8000113a:	4501                	li	a0,0
    8000113c:	b7e5                	j	80001124 <mappages+0x86>

000000008000113e <kvmmap>:
{
    8000113e:	1141                	addi	sp,sp,-16
    80001140:	e406                	sd	ra,8(sp)
    80001142:	e022                	sd	s0,0(sp)
    80001144:	0800                	addi	s0,sp,16
    80001146:	87b6                	mv	a5,a3
  if(mappages(kpgtbl, va, sz, pa, perm) != 0)
    80001148:	86b2                	mv	a3,a2
    8000114a:	863e                	mv	a2,a5
    8000114c:	00000097          	auipc	ra,0x0
    80001150:	f52080e7          	jalr	-174(ra) # 8000109e <mappages>
    80001154:	e509                	bnez	a0,8000115e <kvmmap+0x20>
}
    80001156:	60a2                	ld	ra,8(sp)
    80001158:	6402                	ld	s0,0(sp)
    8000115a:	0141                	addi	sp,sp,16
    8000115c:	8082                	ret
    panic("kvmmap");
    8000115e:	00007517          	auipc	a0,0x7
    80001162:	f9a50513          	addi	a0,a0,-102 # 800080f8 <digits+0xb8>
    80001166:	fffff097          	auipc	ra,0xfffff
    8000116a:	3da080e7          	jalr	986(ra) # 80000540 <panic>

000000008000116e <kvmmake>:
{
    8000116e:	1101                	addi	sp,sp,-32
    80001170:	ec06                	sd	ra,24(sp)
    80001172:	e822                	sd	s0,16(sp)
    80001174:	e426                	sd	s1,8(sp)
    80001176:	e04a                	sd	s2,0(sp)
    80001178:	1000                	addi	s0,sp,32
  kpgtbl = (pagetable_t) kalloc();
    8000117a:	00000097          	auipc	ra,0x0
    8000117e:	96c080e7          	jalr	-1684(ra) # 80000ae6 <kalloc>
    80001182:	84aa                	mv	s1,a0
  memset(kpgtbl, 0, PGSIZE);
    80001184:	6605                	lui	a2,0x1
    80001186:	4581                	li	a1,0
    80001188:	00000097          	auipc	ra,0x0
    8000118c:	b4a080e7          	jalr	-1206(ra) # 80000cd2 <memset>
  kvmmap(kpgtbl, UART0, UART0, PGSIZE, PTE_R | PTE_W);
    80001190:	4719                	li	a4,6
    80001192:	6685                	lui	a3,0x1
    80001194:	10000637          	lui	a2,0x10000
    80001198:	100005b7          	lui	a1,0x10000
    8000119c:	8526                	mv	a0,s1
    8000119e:	00000097          	auipc	ra,0x0
    800011a2:	fa0080e7          	jalr	-96(ra) # 8000113e <kvmmap>
  kvmmap(kpgtbl, VIRTIO0, VIRTIO0, PGSIZE, PTE_R | PTE_W);
    800011a6:	4719                	li	a4,6
    800011a8:	6685                	lui	a3,0x1
    800011aa:	10001637          	lui	a2,0x10001
    800011ae:	100015b7          	lui	a1,0x10001
    800011b2:	8526                	mv	a0,s1
    800011b4:	00000097          	auipc	ra,0x0
    800011b8:	f8a080e7          	jalr	-118(ra) # 8000113e <kvmmap>
  kvmmap(kpgtbl, PLIC, PLIC, 0x400000, PTE_R | PTE_W);
    800011bc:	4719                	li	a4,6
    800011be:	004006b7          	lui	a3,0x400
    800011c2:	0c000637          	lui	a2,0xc000
    800011c6:	0c0005b7          	lui	a1,0xc000
    800011ca:	8526                	mv	a0,s1
    800011cc:	00000097          	auipc	ra,0x0
    800011d0:	f72080e7          	jalr	-142(ra) # 8000113e <kvmmap>
  kvmmap(kpgtbl, KERNBASE, KERNBASE, (uint64)etext-KERNBASE, PTE_R | PTE_X);
    800011d4:	00007917          	auipc	s2,0x7
    800011d8:	e2c90913          	addi	s2,s2,-468 # 80008000 <etext>
    800011dc:	4729                	li	a4,10
    800011de:	80007697          	auipc	a3,0x80007
    800011e2:	e2268693          	addi	a3,a3,-478 # 8000 <_entry-0x7fff8000>
    800011e6:	4605                	li	a2,1
    800011e8:	067e                	slli	a2,a2,0x1f
    800011ea:	85b2                	mv	a1,a2
    800011ec:	8526                	mv	a0,s1
    800011ee:	00000097          	auipc	ra,0x0
    800011f2:	f50080e7          	jalr	-176(ra) # 8000113e <kvmmap>
  kvmmap(kpgtbl, (uint64)etext, (uint64)etext, PHYSTOP-(uint64)etext, PTE_R | PTE_W);
    800011f6:	4719                	li	a4,6
    800011f8:	46c5                	li	a3,17
    800011fa:	06ee                	slli	a3,a3,0x1b
    800011fc:	412686b3          	sub	a3,a3,s2
    80001200:	864a                	mv	a2,s2
    80001202:	85ca                	mv	a1,s2
    80001204:	8526                	mv	a0,s1
    80001206:	00000097          	auipc	ra,0x0
    8000120a:	f38080e7          	jalr	-200(ra) # 8000113e <kvmmap>
  kvmmap(kpgtbl, TRAMPOLINE, (uint64)trampoline, PGSIZE, PTE_R | PTE_X);
    8000120e:	4729                	li	a4,10
    80001210:	6685                	lui	a3,0x1
    80001212:	00006617          	auipc	a2,0x6
    80001216:	dee60613          	addi	a2,a2,-530 # 80007000 <_trampoline>
    8000121a:	040005b7          	lui	a1,0x4000
    8000121e:	15fd                	addi	a1,a1,-1 # 3ffffff <_entry-0x7c000001>
    80001220:	05b2                	slli	a1,a1,0xc
    80001222:	8526                	mv	a0,s1
    80001224:	00000097          	auipc	ra,0x0
    80001228:	f1a080e7          	jalr	-230(ra) # 8000113e <kvmmap>
  proc_mapstacks(kpgtbl);
    8000122c:	8526                	mv	a0,s1
    8000122e:	00000097          	auipc	ra,0x0
    80001232:	608080e7          	jalr	1544(ra) # 80001836 <proc_mapstacks>
}
    80001236:	8526                	mv	a0,s1
    80001238:	60e2                	ld	ra,24(sp)
    8000123a:	6442                	ld	s0,16(sp)
    8000123c:	64a2                	ld	s1,8(sp)
    8000123e:	6902                	ld	s2,0(sp)
    80001240:	6105                	addi	sp,sp,32
    80001242:	8082                	ret

0000000080001244 <kvminit>:
{
    80001244:	1141                	addi	sp,sp,-16
    80001246:	e406                	sd	ra,8(sp)
    80001248:	e022                	sd	s0,0(sp)
    8000124a:	0800                	addi	s0,sp,16
  kernel_pagetable = kvmmake();
    8000124c:	00000097          	auipc	ra,0x0
    80001250:	f22080e7          	jalr	-222(ra) # 8000116e <kvmmake>
    80001254:	00007797          	auipc	a5,0x7
    80001258:	68a7b623          	sd	a0,1676(a5) # 800088e0 <kernel_pagetable>
}
    8000125c:	60a2                	ld	ra,8(sp)
    8000125e:	6402                	ld	s0,0(sp)
    80001260:	0141                	addi	sp,sp,16
    80001262:	8082                	ret

0000000080001264 <uvmunmap>:
// Remove npages of mappings starting from va. va must be
// page-aligned. The mappings must exist.
// Optionally free the physical memory.
void
uvmunmap(pagetable_t pagetable, uint64 va, uint64 npages, int do_free)
{
    80001264:	715d                	addi	sp,sp,-80
    80001266:	e486                	sd	ra,72(sp)
    80001268:	e0a2                	sd	s0,64(sp)
    8000126a:	fc26                	sd	s1,56(sp)
    8000126c:	f84a                	sd	s2,48(sp)
    8000126e:	f44e                	sd	s3,40(sp)
    80001270:	f052                	sd	s4,32(sp)
    80001272:	ec56                	sd	s5,24(sp)
    80001274:	e85a                	sd	s6,16(sp)
    80001276:	e45e                	sd	s7,8(sp)
    80001278:	0880                	addi	s0,sp,80
  uint64 a;
  pte_t *pte;

  if((va % PGSIZE) != 0)
    8000127a:	03459793          	slli	a5,a1,0x34
    8000127e:	e795                	bnez	a5,800012aa <uvmunmap+0x46>
    80001280:	8a2a                	mv	s4,a0
    80001282:	892e                	mv	s2,a1
    80001284:	8ab6                	mv	s5,a3
    panic("uvmunmap: not aligned");

  for(a = va; a < va + npages*PGSIZE; a += PGSIZE){
    80001286:	0632                	slli	a2,a2,0xc
    80001288:	00b609b3          	add	s3,a2,a1
    if((pte = walk(pagetable, a, 0)) == 0)
      panic("uvmunmap: walk");
    if((*pte & PTE_V) == 0)
      panic("uvmunmap: not mapped");
    if(PTE_FLAGS(*pte) == PTE_V)
    8000128c:	4b85                	li	s7,1
  for(a = va; a < va + npages*PGSIZE; a += PGSIZE){
    8000128e:	6b05                	lui	s6,0x1
    80001290:	0735e263          	bltu	a1,s3,800012f4 <uvmunmap+0x90>
      uint64 pa = PTE2PA(*pte);
      kfree((void*)pa);
    }
    *pte = 0;
  }
}
    80001294:	60a6                	ld	ra,72(sp)
    80001296:	6406                	ld	s0,64(sp)
    80001298:	74e2                	ld	s1,56(sp)
    8000129a:	7942                	ld	s2,48(sp)
    8000129c:	79a2                	ld	s3,40(sp)
    8000129e:	7a02                	ld	s4,32(sp)
    800012a0:	6ae2                	ld	s5,24(sp)
    800012a2:	6b42                	ld	s6,16(sp)
    800012a4:	6ba2                	ld	s7,8(sp)
    800012a6:	6161                	addi	sp,sp,80
    800012a8:	8082                	ret
    panic("uvmunmap: not aligned");
    800012aa:	00007517          	auipc	a0,0x7
    800012ae:	e5650513          	addi	a0,a0,-426 # 80008100 <digits+0xc0>
    800012b2:	fffff097          	auipc	ra,0xfffff
    800012b6:	28e080e7          	jalr	654(ra) # 80000540 <panic>
      panic("uvmunmap: walk");
    800012ba:	00007517          	auipc	a0,0x7
    800012be:	e5e50513          	addi	a0,a0,-418 # 80008118 <digits+0xd8>
    800012c2:	fffff097          	auipc	ra,0xfffff
    800012c6:	27e080e7          	jalr	638(ra) # 80000540 <panic>
      panic("uvmunmap: not mapped");
    800012ca:	00007517          	auipc	a0,0x7
    800012ce:	e5e50513          	addi	a0,a0,-418 # 80008128 <digits+0xe8>
    800012d2:	fffff097          	auipc	ra,0xfffff
    800012d6:	26e080e7          	jalr	622(ra) # 80000540 <panic>
      panic("uvmunmap: not a leaf");
    800012da:	00007517          	auipc	a0,0x7
    800012de:	e6650513          	addi	a0,a0,-410 # 80008140 <digits+0x100>
    800012e2:	fffff097          	auipc	ra,0xfffff
    800012e6:	25e080e7          	jalr	606(ra) # 80000540 <panic>
    *pte = 0;
    800012ea:	0004b023          	sd	zero,0(s1)
  for(a = va; a < va + npages*PGSIZE; a += PGSIZE){
    800012ee:	995a                	add	s2,s2,s6
    800012f0:	fb3972e3          	bgeu	s2,s3,80001294 <uvmunmap+0x30>
    if((pte = walk(pagetable, a, 0)) == 0)
    800012f4:	4601                	li	a2,0
    800012f6:	85ca                	mv	a1,s2
    800012f8:	8552                	mv	a0,s4
    800012fa:	00000097          	auipc	ra,0x0
    800012fe:	cbc080e7          	jalr	-836(ra) # 80000fb6 <walk>
    80001302:	84aa                	mv	s1,a0
    80001304:	d95d                	beqz	a0,800012ba <uvmunmap+0x56>
    if((*pte & PTE_V) == 0)
    80001306:	6108                	ld	a0,0(a0)
    80001308:	00157793          	andi	a5,a0,1
    8000130c:	dfdd                	beqz	a5,800012ca <uvmunmap+0x66>
    if(PTE_FLAGS(*pte) == PTE_V)
    8000130e:	3ff57793          	andi	a5,a0,1023
    80001312:	fd7784e3          	beq	a5,s7,800012da <uvmunmap+0x76>
    if(do_free){
    80001316:	fc0a8ae3          	beqz	s5,800012ea <uvmunmap+0x86>
      uint64 pa = PTE2PA(*pte);
    8000131a:	8129                	srli	a0,a0,0xa
      kfree((void*)pa);
    8000131c:	0532                	slli	a0,a0,0xc
    8000131e:	fffff097          	auipc	ra,0xfffff
    80001322:	6ca080e7          	jalr	1738(ra) # 800009e8 <kfree>
    80001326:	b7d1                	j	800012ea <uvmunmap+0x86>

0000000080001328 <uvmcreate>:

// create an empty user page table.
// returns 0 if out of memory.
pagetable_t
uvmcreate()
{
    80001328:	1101                	addi	sp,sp,-32
    8000132a:	ec06                	sd	ra,24(sp)
    8000132c:	e822                	sd	s0,16(sp)
    8000132e:	e426                	sd	s1,8(sp)
    80001330:	1000                	addi	s0,sp,32
  pagetable_t pagetable;
  pagetable = (pagetable_t) kalloc();
    80001332:	fffff097          	auipc	ra,0xfffff
    80001336:	7b4080e7          	jalr	1972(ra) # 80000ae6 <kalloc>
    8000133a:	84aa                	mv	s1,a0
  if(pagetable == 0)
    8000133c:	c519                	beqz	a0,8000134a <uvmcreate+0x22>
    return 0;
  memset(pagetable, 0, PGSIZE);
    8000133e:	6605                	lui	a2,0x1
    80001340:	4581                	li	a1,0
    80001342:	00000097          	auipc	ra,0x0
    80001346:	990080e7          	jalr	-1648(ra) # 80000cd2 <memset>
  return pagetable;
}
    8000134a:	8526                	mv	a0,s1
    8000134c:	60e2                	ld	ra,24(sp)
    8000134e:	6442                	ld	s0,16(sp)
    80001350:	64a2                	ld	s1,8(sp)
    80001352:	6105                	addi	sp,sp,32
    80001354:	8082                	ret

0000000080001356 <uvmfirst>:
// Load the user initcode into address 0 of pagetable,
// for the very first process.
// sz must be less than a page.
void
uvmfirst(pagetable_t pagetable, uchar *src, uint sz)
{
    80001356:	7179                	addi	sp,sp,-48
    80001358:	f406                	sd	ra,40(sp)
    8000135a:	f022                	sd	s0,32(sp)
    8000135c:	ec26                	sd	s1,24(sp)
    8000135e:	e84a                	sd	s2,16(sp)
    80001360:	e44e                	sd	s3,8(sp)
    80001362:	e052                	sd	s4,0(sp)
    80001364:	1800                	addi	s0,sp,48
  char *mem;

  if(sz >= PGSIZE)
    80001366:	6785                	lui	a5,0x1
    80001368:	04f67863          	bgeu	a2,a5,800013b8 <uvmfirst+0x62>
    8000136c:	8a2a                	mv	s4,a0
    8000136e:	89ae                	mv	s3,a1
    80001370:	84b2                	mv	s1,a2
    panic("uvmfirst: more than a page");
  mem = kalloc();
    80001372:	fffff097          	auipc	ra,0xfffff
    80001376:	774080e7          	jalr	1908(ra) # 80000ae6 <kalloc>
    8000137a:	892a                	mv	s2,a0
  memset(mem, 0, PGSIZE);
    8000137c:	6605                	lui	a2,0x1
    8000137e:	4581                	li	a1,0
    80001380:	00000097          	auipc	ra,0x0
    80001384:	952080e7          	jalr	-1710(ra) # 80000cd2 <memset>
  mappages(pagetable, 0, PGSIZE, (uint64)mem, PTE_W|PTE_R|PTE_X|PTE_U);
    80001388:	4779                	li	a4,30
    8000138a:	86ca                	mv	a3,s2
    8000138c:	6605                	lui	a2,0x1
    8000138e:	4581                	li	a1,0
    80001390:	8552                	mv	a0,s4
    80001392:	00000097          	auipc	ra,0x0
    80001396:	d0c080e7          	jalr	-756(ra) # 8000109e <mappages>
  memmove(mem, src, sz);
    8000139a:	8626                	mv	a2,s1
    8000139c:	85ce                	mv	a1,s3
    8000139e:	854a                	mv	a0,s2
    800013a0:	00000097          	auipc	ra,0x0
    800013a4:	98e080e7          	jalr	-1650(ra) # 80000d2e <memmove>
}
    800013a8:	70a2                	ld	ra,40(sp)
    800013aa:	7402                	ld	s0,32(sp)
    800013ac:	64e2                	ld	s1,24(sp)
    800013ae:	6942                	ld	s2,16(sp)
    800013b0:	69a2                	ld	s3,8(sp)
    800013b2:	6a02                	ld	s4,0(sp)
    800013b4:	6145                	addi	sp,sp,48
    800013b6:	8082                	ret
    panic("uvmfirst: more than a page");
    800013b8:	00007517          	auipc	a0,0x7
    800013bc:	da050513          	addi	a0,a0,-608 # 80008158 <digits+0x118>
    800013c0:	fffff097          	auipc	ra,0xfffff
    800013c4:	180080e7          	jalr	384(ra) # 80000540 <panic>

00000000800013c8 <uvmdealloc>:
// newsz.  oldsz and newsz need not be page-aligned, nor does newsz
// need to be less than oldsz.  oldsz can be larger than the actual
// process size.  Returns the new process size.
uint64
uvmdealloc(pagetable_t pagetable, uint64 oldsz, uint64 newsz)
{
    800013c8:	1101                	addi	sp,sp,-32
    800013ca:	ec06                	sd	ra,24(sp)
    800013cc:	e822                	sd	s0,16(sp)
    800013ce:	e426                	sd	s1,8(sp)
    800013d0:	1000                	addi	s0,sp,32
  if(newsz >= oldsz)
    return oldsz;
    800013d2:	84ae                	mv	s1,a1
  if(newsz >= oldsz)
    800013d4:	00b67d63          	bgeu	a2,a1,800013ee <uvmdealloc+0x26>
    800013d8:	84b2                	mv	s1,a2

  if(PGROUNDUP(newsz) < PGROUNDUP(oldsz)){
    800013da:	6785                	lui	a5,0x1
    800013dc:	17fd                	addi	a5,a5,-1 # fff <_entry-0x7ffff001>
    800013de:	00f60733          	add	a4,a2,a5
    800013e2:	76fd                	lui	a3,0xfffff
    800013e4:	8f75                	and	a4,a4,a3
    800013e6:	97ae                	add	a5,a5,a1
    800013e8:	8ff5                	and	a5,a5,a3
    800013ea:	00f76863          	bltu	a4,a5,800013fa <uvmdealloc+0x32>
    int npages = (PGROUNDUP(oldsz) - PGROUNDUP(newsz)) / PGSIZE;
    uvmunmap(pagetable, PGROUNDUP(newsz), npages, 1);
  }

  return newsz;
}
    800013ee:	8526                	mv	a0,s1
    800013f0:	60e2                	ld	ra,24(sp)
    800013f2:	6442                	ld	s0,16(sp)
    800013f4:	64a2                	ld	s1,8(sp)
    800013f6:	6105                	addi	sp,sp,32
    800013f8:	8082                	ret
    int npages = (PGROUNDUP(oldsz) - PGROUNDUP(newsz)) / PGSIZE;
    800013fa:	8f99                	sub	a5,a5,a4
    800013fc:	83b1                	srli	a5,a5,0xc
    uvmunmap(pagetable, PGROUNDUP(newsz), npages, 1);
    800013fe:	4685                	li	a3,1
    80001400:	0007861b          	sext.w	a2,a5
    80001404:	85ba                	mv	a1,a4
    80001406:	00000097          	auipc	ra,0x0
    8000140a:	e5e080e7          	jalr	-418(ra) # 80001264 <uvmunmap>
    8000140e:	b7c5                	j	800013ee <uvmdealloc+0x26>

0000000080001410 <uvmalloc>:
  if(newsz < oldsz)
    80001410:	0ab66563          	bltu	a2,a1,800014ba <uvmalloc+0xaa>
{
    80001414:	7139                	addi	sp,sp,-64
    80001416:	fc06                	sd	ra,56(sp)
    80001418:	f822                	sd	s0,48(sp)
    8000141a:	f426                	sd	s1,40(sp)
    8000141c:	f04a                	sd	s2,32(sp)
    8000141e:	ec4e                	sd	s3,24(sp)
    80001420:	e852                	sd	s4,16(sp)
    80001422:	e456                	sd	s5,8(sp)
    80001424:	e05a                	sd	s6,0(sp)
    80001426:	0080                	addi	s0,sp,64
    80001428:	8aaa                	mv	s5,a0
    8000142a:	8a32                	mv	s4,a2
  oldsz = PGROUNDUP(oldsz);
    8000142c:	6785                	lui	a5,0x1
    8000142e:	17fd                	addi	a5,a5,-1 # fff <_entry-0x7ffff001>
    80001430:	95be                	add	a1,a1,a5
    80001432:	77fd                	lui	a5,0xfffff
    80001434:	00f5f9b3          	and	s3,a1,a5
  for(a = oldsz; a < newsz; a += PGSIZE){
    80001438:	08c9f363          	bgeu	s3,a2,800014be <uvmalloc+0xae>
    8000143c:	894e                	mv	s2,s3
    if(mappages(pagetable, a, PGSIZE, (uint64)mem, PTE_R|PTE_U|xperm) != 0){
    8000143e:	0126eb13          	ori	s6,a3,18
    mem = kalloc();
    80001442:	fffff097          	auipc	ra,0xfffff
    80001446:	6a4080e7          	jalr	1700(ra) # 80000ae6 <kalloc>
    8000144a:	84aa                	mv	s1,a0
    if(mem == 0){
    8000144c:	c51d                	beqz	a0,8000147a <uvmalloc+0x6a>
    memset(mem, 0, PGSIZE);
    8000144e:	6605                	lui	a2,0x1
    80001450:	4581                	li	a1,0
    80001452:	00000097          	auipc	ra,0x0
    80001456:	880080e7          	jalr	-1920(ra) # 80000cd2 <memset>
    if(mappages(pagetable, a, PGSIZE, (uint64)mem, PTE_R|PTE_U|xperm) != 0){
    8000145a:	875a                	mv	a4,s6
    8000145c:	86a6                	mv	a3,s1
    8000145e:	6605                	lui	a2,0x1
    80001460:	85ca                	mv	a1,s2
    80001462:	8556                	mv	a0,s5
    80001464:	00000097          	auipc	ra,0x0
    80001468:	c3a080e7          	jalr	-966(ra) # 8000109e <mappages>
    8000146c:	e90d                	bnez	a0,8000149e <uvmalloc+0x8e>
  for(a = oldsz; a < newsz; a += PGSIZE){
    8000146e:	6785                	lui	a5,0x1
    80001470:	993e                	add	s2,s2,a5
    80001472:	fd4968e3          	bltu	s2,s4,80001442 <uvmalloc+0x32>
  return newsz;
    80001476:	8552                	mv	a0,s4
    80001478:	a809                	j	8000148a <uvmalloc+0x7a>
      uvmdealloc(pagetable, a, oldsz);
    8000147a:	864e                	mv	a2,s3
    8000147c:	85ca                	mv	a1,s2
    8000147e:	8556                	mv	a0,s5
    80001480:	00000097          	auipc	ra,0x0
    80001484:	f48080e7          	jalr	-184(ra) # 800013c8 <uvmdealloc>
      return 0;
    80001488:	4501                	li	a0,0
}
    8000148a:	70e2                	ld	ra,56(sp)
    8000148c:	7442                	ld	s0,48(sp)
    8000148e:	74a2                	ld	s1,40(sp)
    80001490:	7902                	ld	s2,32(sp)
    80001492:	69e2                	ld	s3,24(sp)
    80001494:	6a42                	ld	s4,16(sp)
    80001496:	6aa2                	ld	s5,8(sp)
    80001498:	6b02                	ld	s6,0(sp)
    8000149a:	6121                	addi	sp,sp,64
    8000149c:	8082                	ret
      kfree(mem);
    8000149e:	8526                	mv	a0,s1
    800014a0:	fffff097          	auipc	ra,0xfffff
    800014a4:	548080e7          	jalr	1352(ra) # 800009e8 <kfree>
      uvmdealloc(pagetable, a, oldsz);
    800014a8:	864e                	mv	a2,s3
    800014aa:	85ca                	mv	a1,s2
    800014ac:	8556                	mv	a0,s5
    800014ae:	00000097          	auipc	ra,0x0
    800014b2:	f1a080e7          	jalr	-230(ra) # 800013c8 <uvmdealloc>
      return 0;
    800014b6:	4501                	li	a0,0
    800014b8:	bfc9                	j	8000148a <uvmalloc+0x7a>
    return oldsz;
    800014ba:	852e                	mv	a0,a1
}
    800014bc:	8082                	ret
  return newsz;
    800014be:	8532                	mv	a0,a2
    800014c0:	b7e9                	j	8000148a <uvmalloc+0x7a>

00000000800014c2 <freewalk>:

// Recursively free page-table pages.
// All leaf mappings must already have been removed.
void
freewalk(pagetable_t pagetable)
{
    800014c2:	7179                	addi	sp,sp,-48
    800014c4:	f406                	sd	ra,40(sp)
    800014c6:	f022                	sd	s0,32(sp)
    800014c8:	ec26                	sd	s1,24(sp)
    800014ca:	e84a                	sd	s2,16(sp)
    800014cc:	e44e                	sd	s3,8(sp)
    800014ce:	e052                	sd	s4,0(sp)
    800014d0:	1800                	addi	s0,sp,48
    800014d2:	8a2a                	mv	s4,a0
  // there are 2^9 = 512 PTEs in a page table.
  for(int i = 0; i < 512; i++){
    800014d4:	84aa                	mv	s1,a0
    800014d6:	6905                	lui	s2,0x1
    800014d8:	992a                	add	s2,s2,a0
    pte_t pte = pagetable[i];
    if((pte & PTE_V) && (pte & (PTE_R|PTE_W|PTE_X)) == 0){
    800014da:	4985                	li	s3,1
    800014dc:	a829                	j	800014f6 <freewalk+0x34>
      // this PTE points to a lower-level page table.
      uint64 child = PTE2PA(pte);
    800014de:	83a9                	srli	a5,a5,0xa
      freewalk((pagetable_t)child);
    800014e0:	00c79513          	slli	a0,a5,0xc
    800014e4:	00000097          	auipc	ra,0x0
    800014e8:	fde080e7          	jalr	-34(ra) # 800014c2 <freewalk>
      pagetable[i] = 0;
    800014ec:	0004b023          	sd	zero,0(s1)
  for(int i = 0; i < 512; i++){
    800014f0:	04a1                	addi	s1,s1,8
    800014f2:	03248163          	beq	s1,s2,80001514 <freewalk+0x52>
    pte_t pte = pagetable[i];
    800014f6:	609c                	ld	a5,0(s1)
    if((pte & PTE_V) && (pte & (PTE_R|PTE_W|PTE_X)) == 0){
    800014f8:	00f7f713          	andi	a4,a5,15
    800014fc:	ff3701e3          	beq	a4,s3,800014de <freewalk+0x1c>
    } else if(pte & PTE_V){
    80001500:	8b85                	andi	a5,a5,1
    80001502:	d7fd                	beqz	a5,800014f0 <freewalk+0x2e>
      panic("freewalk: leaf");
    80001504:	00007517          	auipc	a0,0x7
    80001508:	c7450513          	addi	a0,a0,-908 # 80008178 <digits+0x138>
    8000150c:	fffff097          	auipc	ra,0xfffff
    80001510:	034080e7          	jalr	52(ra) # 80000540 <panic>
    }
  }
  kfree((void*)pagetable);
    80001514:	8552                	mv	a0,s4
    80001516:	fffff097          	auipc	ra,0xfffff
    8000151a:	4d2080e7          	jalr	1234(ra) # 800009e8 <kfree>
}
    8000151e:	70a2                	ld	ra,40(sp)
    80001520:	7402                	ld	s0,32(sp)
    80001522:	64e2                	ld	s1,24(sp)
    80001524:	6942                	ld	s2,16(sp)
    80001526:	69a2                	ld	s3,8(sp)
    80001528:	6a02                	ld	s4,0(sp)
    8000152a:	6145                	addi	sp,sp,48
    8000152c:	8082                	ret

000000008000152e <uvmfree>:

// Free user memory pages,
// then free page-table pages.
void
uvmfree(pagetable_t pagetable, uint64 sz)
{
    8000152e:	1101                	addi	sp,sp,-32
    80001530:	ec06                	sd	ra,24(sp)
    80001532:	e822                	sd	s0,16(sp)
    80001534:	e426                	sd	s1,8(sp)
    80001536:	1000                	addi	s0,sp,32
    80001538:	84aa                	mv	s1,a0
  if(sz > 0)
    8000153a:	e999                	bnez	a1,80001550 <uvmfree+0x22>
    uvmunmap(pagetable, 0, PGROUNDUP(sz)/PGSIZE, 1);
  freewalk(pagetable);
    8000153c:	8526                	mv	a0,s1
    8000153e:	00000097          	auipc	ra,0x0
    80001542:	f84080e7          	jalr	-124(ra) # 800014c2 <freewalk>
}
    80001546:	60e2                	ld	ra,24(sp)
    80001548:	6442                	ld	s0,16(sp)
    8000154a:	64a2                	ld	s1,8(sp)
    8000154c:	6105                	addi	sp,sp,32
    8000154e:	8082                	ret
    uvmunmap(pagetable, 0, PGROUNDUP(sz)/PGSIZE, 1);
    80001550:	6785                	lui	a5,0x1
    80001552:	17fd                	addi	a5,a5,-1 # fff <_entry-0x7ffff001>
    80001554:	95be                	add	a1,a1,a5
    80001556:	4685                	li	a3,1
    80001558:	00c5d613          	srli	a2,a1,0xc
    8000155c:	4581                	li	a1,0
    8000155e:	00000097          	auipc	ra,0x0
    80001562:	d06080e7          	jalr	-762(ra) # 80001264 <uvmunmap>
    80001566:	bfd9                	j	8000153c <uvmfree+0xe>

0000000080001568 <uvmcopy>:
  pte_t *pte;
  uint64 pa, i;
  uint flags;
  char *mem;

  for(i = 0; i < sz; i += PGSIZE){
    80001568:	c679                	beqz	a2,80001636 <uvmcopy+0xce>
{
    8000156a:	715d                	addi	sp,sp,-80
    8000156c:	e486                	sd	ra,72(sp)
    8000156e:	e0a2                	sd	s0,64(sp)
    80001570:	fc26                	sd	s1,56(sp)
    80001572:	f84a                	sd	s2,48(sp)
    80001574:	f44e                	sd	s3,40(sp)
    80001576:	f052                	sd	s4,32(sp)
    80001578:	ec56                	sd	s5,24(sp)
    8000157a:	e85a                	sd	s6,16(sp)
    8000157c:	e45e                	sd	s7,8(sp)
    8000157e:	0880                	addi	s0,sp,80
    80001580:	8b2a                	mv	s6,a0
    80001582:	8aae                	mv	s5,a1
    80001584:	8a32                	mv	s4,a2
  for(i = 0; i < sz; i += PGSIZE){
    80001586:	4981                	li	s3,0
    if((pte = walk(old, i, 0)) == 0)
    80001588:	4601                	li	a2,0
    8000158a:	85ce                	mv	a1,s3
    8000158c:	855a                	mv	a0,s6
    8000158e:	00000097          	auipc	ra,0x0
    80001592:	a28080e7          	jalr	-1496(ra) # 80000fb6 <walk>
    80001596:	c531                	beqz	a0,800015e2 <uvmcopy+0x7a>
      panic("uvmcopy: pte should exist");
    if((*pte & PTE_V) == 0)
    80001598:	6118                	ld	a4,0(a0)
    8000159a:	00177793          	andi	a5,a4,1
    8000159e:	cbb1                	beqz	a5,800015f2 <uvmcopy+0x8a>
      panic("uvmcopy: page not present");
    pa = PTE2PA(*pte);
    800015a0:	00a75593          	srli	a1,a4,0xa
    800015a4:	00c59b93          	slli	s7,a1,0xc
    flags = PTE_FLAGS(*pte);
    800015a8:	3ff77493          	andi	s1,a4,1023
    if((mem = kalloc()) == 0)
    800015ac:	fffff097          	auipc	ra,0xfffff
    800015b0:	53a080e7          	jalr	1338(ra) # 80000ae6 <kalloc>
    800015b4:	892a                	mv	s2,a0
    800015b6:	c939                	beqz	a0,8000160c <uvmcopy+0xa4>
      goto err;
    memmove(mem, (char*)pa, PGSIZE);
    800015b8:	6605                	lui	a2,0x1
    800015ba:	85de                	mv	a1,s7
    800015bc:	fffff097          	auipc	ra,0xfffff
    800015c0:	772080e7          	jalr	1906(ra) # 80000d2e <memmove>
    if(mappages(new, i, PGSIZE, (uint64)mem, flags) != 0){
    800015c4:	8726                	mv	a4,s1
    800015c6:	86ca                	mv	a3,s2
    800015c8:	6605                	lui	a2,0x1
    800015ca:	85ce                	mv	a1,s3
    800015cc:	8556                	mv	a0,s5
    800015ce:	00000097          	auipc	ra,0x0
    800015d2:	ad0080e7          	jalr	-1328(ra) # 8000109e <mappages>
    800015d6:	e515                	bnez	a0,80001602 <uvmcopy+0x9a>
  for(i = 0; i < sz; i += PGSIZE){
    800015d8:	6785                	lui	a5,0x1
    800015da:	99be                	add	s3,s3,a5
    800015dc:	fb49e6e3          	bltu	s3,s4,80001588 <uvmcopy+0x20>
    800015e0:	a081                	j	80001620 <uvmcopy+0xb8>
      panic("uvmcopy: pte should exist");
    800015e2:	00007517          	auipc	a0,0x7
    800015e6:	ba650513          	addi	a0,a0,-1114 # 80008188 <digits+0x148>
    800015ea:	fffff097          	auipc	ra,0xfffff
    800015ee:	f56080e7          	jalr	-170(ra) # 80000540 <panic>
      panic("uvmcopy: page not present");
    800015f2:	00007517          	auipc	a0,0x7
    800015f6:	bb650513          	addi	a0,a0,-1098 # 800081a8 <digits+0x168>
    800015fa:	fffff097          	auipc	ra,0xfffff
    800015fe:	f46080e7          	jalr	-186(ra) # 80000540 <panic>
      kfree(mem);
    80001602:	854a                	mv	a0,s2
    80001604:	fffff097          	auipc	ra,0xfffff
    80001608:	3e4080e7          	jalr	996(ra) # 800009e8 <kfree>
    }
  }
  return 0;

 err:
  uvmunmap(new, 0, i / PGSIZE, 1);
    8000160c:	4685                	li	a3,1
    8000160e:	00c9d613          	srli	a2,s3,0xc
    80001612:	4581                	li	a1,0
    80001614:	8556                	mv	a0,s5
    80001616:	00000097          	auipc	ra,0x0
    8000161a:	c4e080e7          	jalr	-946(ra) # 80001264 <uvmunmap>
  return -1;
    8000161e:	557d                	li	a0,-1
}
    80001620:	60a6                	ld	ra,72(sp)
    80001622:	6406                	ld	s0,64(sp)
    80001624:	74e2                	ld	s1,56(sp)
    80001626:	7942                	ld	s2,48(sp)
    80001628:	79a2                	ld	s3,40(sp)
    8000162a:	7a02                	ld	s4,32(sp)
    8000162c:	6ae2                	ld	s5,24(sp)
    8000162e:	6b42                	ld	s6,16(sp)
    80001630:	6ba2                	ld	s7,8(sp)
    80001632:	6161                	addi	sp,sp,80
    80001634:	8082                	ret
  return 0;
    80001636:	4501                	li	a0,0
}
    80001638:	8082                	ret

000000008000163a <uvmclear>:

// mark a PTE invalid for user access.
// used by exec for the user stack guard page.
void
uvmclear(pagetable_t pagetable, uint64 va)
{
    8000163a:	1141                	addi	sp,sp,-16
    8000163c:	e406                	sd	ra,8(sp)
    8000163e:	e022                	sd	s0,0(sp)
    80001640:	0800                	addi	s0,sp,16
  pte_t *pte;
  
  pte = walk(pagetable, va, 0);
    80001642:	4601                	li	a2,0
    80001644:	00000097          	auipc	ra,0x0
    80001648:	972080e7          	jalr	-1678(ra) # 80000fb6 <walk>
  if(pte == 0)
    8000164c:	c901                	beqz	a0,8000165c <uvmclear+0x22>
    panic("uvmclear");
  *pte &= ~PTE_U;
    8000164e:	611c                	ld	a5,0(a0)
    80001650:	9bbd                	andi	a5,a5,-17
    80001652:	e11c                	sd	a5,0(a0)
}
    80001654:	60a2                	ld	ra,8(sp)
    80001656:	6402                	ld	s0,0(sp)
    80001658:	0141                	addi	sp,sp,16
    8000165a:	8082                	ret
    panic("uvmclear");
    8000165c:	00007517          	auipc	a0,0x7
    80001660:	b6c50513          	addi	a0,a0,-1172 # 800081c8 <digits+0x188>
    80001664:	fffff097          	auipc	ra,0xfffff
    80001668:	edc080e7          	jalr	-292(ra) # 80000540 <panic>

000000008000166c <copyout>:
int
copyout(pagetable_t pagetable, uint64 dstva, char *src, uint64 len)
{
  uint64 n, va0, pa0;

  while(len > 0){
    8000166c:	c6bd                	beqz	a3,800016da <copyout+0x6e>
{
    8000166e:	715d                	addi	sp,sp,-80
    80001670:	e486                	sd	ra,72(sp)
    80001672:	e0a2                	sd	s0,64(sp)
    80001674:	fc26                	sd	s1,56(sp)
    80001676:	f84a                	sd	s2,48(sp)
    80001678:	f44e                	sd	s3,40(sp)
    8000167a:	f052                	sd	s4,32(sp)
    8000167c:	ec56                	sd	s5,24(sp)
    8000167e:	e85a                	sd	s6,16(sp)
    80001680:	e45e                	sd	s7,8(sp)
    80001682:	e062                	sd	s8,0(sp)
    80001684:	0880                	addi	s0,sp,80
    80001686:	8b2a                	mv	s6,a0
    80001688:	8c2e                	mv	s8,a1
    8000168a:	8a32                	mv	s4,a2
    8000168c:	89b6                	mv	s3,a3
    va0 = PGROUNDDOWN(dstva);
    8000168e:	7bfd                	lui	s7,0xfffff
    pa0 = walkaddr(pagetable, va0);
    if(pa0 == 0)
      return -1;
    n = PGSIZE - (dstva - va0);
    80001690:	6a85                	lui	s5,0x1
    80001692:	a015                	j	800016b6 <copyout+0x4a>
    if(n > len)
      n = len;
    memmove((void *)(pa0 + (dstva - va0)), src, n);
    80001694:	9562                	add	a0,a0,s8
    80001696:	0004861b          	sext.w	a2,s1
    8000169a:	85d2                	mv	a1,s4
    8000169c:	41250533          	sub	a0,a0,s2
    800016a0:	fffff097          	auipc	ra,0xfffff
    800016a4:	68e080e7          	jalr	1678(ra) # 80000d2e <memmove>

    len -= n;
    800016a8:	409989b3          	sub	s3,s3,s1
    src += n;
    800016ac:	9a26                	add	s4,s4,s1
    dstva = va0 + PGSIZE;
    800016ae:	01590c33          	add	s8,s2,s5
  while(len > 0){
    800016b2:	02098263          	beqz	s3,800016d6 <copyout+0x6a>
    va0 = PGROUNDDOWN(dstva);
    800016b6:	017c7933          	and	s2,s8,s7
    pa0 = walkaddr(pagetable, va0);
    800016ba:	85ca                	mv	a1,s2
    800016bc:	855a                	mv	a0,s6
    800016be:	00000097          	auipc	ra,0x0
    800016c2:	99e080e7          	jalr	-1634(ra) # 8000105c <walkaddr>
    if(pa0 == 0)
    800016c6:	cd01                	beqz	a0,800016de <copyout+0x72>
    n = PGSIZE - (dstva - va0);
    800016c8:	418904b3          	sub	s1,s2,s8
    800016cc:	94d6                	add	s1,s1,s5
    800016ce:	fc99f3e3          	bgeu	s3,s1,80001694 <copyout+0x28>
    800016d2:	84ce                	mv	s1,s3
    800016d4:	b7c1                	j	80001694 <copyout+0x28>
  }
  return 0;
    800016d6:	4501                	li	a0,0
    800016d8:	a021                	j	800016e0 <copyout+0x74>
    800016da:	4501                	li	a0,0
}
    800016dc:	8082                	ret
      return -1;
    800016de:	557d                	li	a0,-1
}
    800016e0:	60a6                	ld	ra,72(sp)
    800016e2:	6406                	ld	s0,64(sp)
    800016e4:	74e2                	ld	s1,56(sp)
    800016e6:	7942                	ld	s2,48(sp)
    800016e8:	79a2                	ld	s3,40(sp)
    800016ea:	7a02                	ld	s4,32(sp)
    800016ec:	6ae2                	ld	s5,24(sp)
    800016ee:	6b42                	ld	s6,16(sp)
    800016f0:	6ba2                	ld	s7,8(sp)
    800016f2:	6c02                	ld	s8,0(sp)
    800016f4:	6161                	addi	sp,sp,80
    800016f6:	8082                	ret

00000000800016f8 <copyin>:
int
copyin(pagetable_t pagetable, char *dst, uint64 srcva, uint64 len)
{
  uint64 n, va0, pa0;

  while(len > 0){
    800016f8:	caa5                	beqz	a3,80001768 <copyin+0x70>
{
    800016fa:	715d                	addi	sp,sp,-80
    800016fc:	e486                	sd	ra,72(sp)
    800016fe:	e0a2                	sd	s0,64(sp)
    80001700:	fc26                	sd	s1,56(sp)
    80001702:	f84a                	sd	s2,48(sp)
    80001704:	f44e                	sd	s3,40(sp)
    80001706:	f052                	sd	s4,32(sp)
    80001708:	ec56                	sd	s5,24(sp)
    8000170a:	e85a                	sd	s6,16(sp)
    8000170c:	e45e                	sd	s7,8(sp)
    8000170e:	e062                	sd	s8,0(sp)
    80001710:	0880                	addi	s0,sp,80
    80001712:	8b2a                	mv	s6,a0
    80001714:	8a2e                	mv	s4,a1
    80001716:	8c32                	mv	s8,a2
    80001718:	89b6                	mv	s3,a3
    va0 = PGROUNDDOWN(srcva);
    8000171a:	7bfd                	lui	s7,0xfffff
    pa0 = walkaddr(pagetable, va0);
    if(pa0 == 0)
      return -1;
    n = PGSIZE - (srcva - va0);
    8000171c:	6a85                	lui	s5,0x1
    8000171e:	a01d                	j	80001744 <copyin+0x4c>
    if(n > len)
      n = len;
    memmove(dst, (void *)(pa0 + (srcva - va0)), n);
    80001720:	018505b3          	add	a1,a0,s8
    80001724:	0004861b          	sext.w	a2,s1
    80001728:	412585b3          	sub	a1,a1,s2
    8000172c:	8552                	mv	a0,s4
    8000172e:	fffff097          	auipc	ra,0xfffff
    80001732:	600080e7          	jalr	1536(ra) # 80000d2e <memmove>

    len -= n;
    80001736:	409989b3          	sub	s3,s3,s1
    dst += n;
    8000173a:	9a26                	add	s4,s4,s1
    srcva = va0 + PGSIZE;
    8000173c:	01590c33          	add	s8,s2,s5
  while(len > 0){
    80001740:	02098263          	beqz	s3,80001764 <copyin+0x6c>
    va0 = PGROUNDDOWN(srcva);
    80001744:	017c7933          	and	s2,s8,s7
    pa0 = walkaddr(pagetable, va0);
    80001748:	85ca                	mv	a1,s2
    8000174a:	855a                	mv	a0,s6
    8000174c:	00000097          	auipc	ra,0x0
    80001750:	910080e7          	jalr	-1776(ra) # 8000105c <walkaddr>
    if(pa0 == 0)
    80001754:	cd01                	beqz	a0,8000176c <copyin+0x74>
    n = PGSIZE - (srcva - va0);
    80001756:	418904b3          	sub	s1,s2,s8
    8000175a:	94d6                	add	s1,s1,s5
    8000175c:	fc99f2e3          	bgeu	s3,s1,80001720 <copyin+0x28>
    80001760:	84ce                	mv	s1,s3
    80001762:	bf7d                	j	80001720 <copyin+0x28>
  }
  return 0;
    80001764:	4501                	li	a0,0
    80001766:	a021                	j	8000176e <copyin+0x76>
    80001768:	4501                	li	a0,0
}
    8000176a:	8082                	ret
      return -1;
    8000176c:	557d                	li	a0,-1
}
    8000176e:	60a6                	ld	ra,72(sp)
    80001770:	6406                	ld	s0,64(sp)
    80001772:	74e2                	ld	s1,56(sp)
    80001774:	7942                	ld	s2,48(sp)
    80001776:	79a2                	ld	s3,40(sp)
    80001778:	7a02                	ld	s4,32(sp)
    8000177a:	6ae2                	ld	s5,24(sp)
    8000177c:	6b42                	ld	s6,16(sp)
    8000177e:	6ba2                	ld	s7,8(sp)
    80001780:	6c02                	ld	s8,0(sp)
    80001782:	6161                	addi	sp,sp,80
    80001784:	8082                	ret

0000000080001786 <copyinstr>:
copyinstr(pagetable_t pagetable, char *dst, uint64 srcva, uint64 max)
{
  uint64 n, va0, pa0;
  int got_null = 0;

  while(got_null == 0 && max > 0){
    80001786:	c2dd                	beqz	a3,8000182c <copyinstr+0xa6>
{
    80001788:	715d                	addi	sp,sp,-80
    8000178a:	e486                	sd	ra,72(sp)
    8000178c:	e0a2                	sd	s0,64(sp)
    8000178e:	fc26                	sd	s1,56(sp)
    80001790:	f84a                	sd	s2,48(sp)
    80001792:	f44e                	sd	s3,40(sp)
    80001794:	f052                	sd	s4,32(sp)
    80001796:	ec56                	sd	s5,24(sp)
    80001798:	e85a                	sd	s6,16(sp)
    8000179a:	e45e                	sd	s7,8(sp)
    8000179c:	0880                	addi	s0,sp,80
    8000179e:	8a2a                	mv	s4,a0
    800017a0:	8b2e                	mv	s6,a1
    800017a2:	8bb2                	mv	s7,a2
    800017a4:	84b6                	mv	s1,a3
    va0 = PGROUNDDOWN(srcva);
    800017a6:	7afd                	lui	s5,0xfffff
    pa0 = walkaddr(pagetable, va0);
    if(pa0 == 0)
      return -1;
    n = PGSIZE - (srcva - va0);
    800017a8:	6985                	lui	s3,0x1
    800017aa:	a02d                	j	800017d4 <copyinstr+0x4e>
      n = max;

    char *p = (char *) (pa0 + (srcva - va0));
    while(n > 0){
      if(*p == '\0'){
        *dst = '\0';
    800017ac:	00078023          	sb	zero,0(a5) # 1000 <_entry-0x7ffff000>
    800017b0:	4785                	li	a5,1
      dst++;
    }

    srcva = va0 + PGSIZE;
  }
  if(got_null){
    800017b2:	37fd                	addiw	a5,a5,-1
    800017b4:	0007851b          	sext.w	a0,a5
    return 0;
  } else {
    return -1;
  }
}
    800017b8:	60a6                	ld	ra,72(sp)
    800017ba:	6406                	ld	s0,64(sp)
    800017bc:	74e2                	ld	s1,56(sp)
    800017be:	7942                	ld	s2,48(sp)
    800017c0:	79a2                	ld	s3,40(sp)
    800017c2:	7a02                	ld	s4,32(sp)
    800017c4:	6ae2                	ld	s5,24(sp)
    800017c6:	6b42                	ld	s6,16(sp)
    800017c8:	6ba2                	ld	s7,8(sp)
    800017ca:	6161                	addi	sp,sp,80
    800017cc:	8082                	ret
    srcva = va0 + PGSIZE;
    800017ce:	01390bb3          	add	s7,s2,s3
  while(got_null == 0 && max > 0){
    800017d2:	c8a9                	beqz	s1,80001824 <copyinstr+0x9e>
    va0 = PGROUNDDOWN(srcva);
    800017d4:	015bf933          	and	s2,s7,s5
    pa0 = walkaddr(pagetable, va0);
    800017d8:	85ca                	mv	a1,s2
    800017da:	8552                	mv	a0,s4
    800017dc:	00000097          	auipc	ra,0x0
    800017e0:	880080e7          	jalr	-1920(ra) # 8000105c <walkaddr>
    if(pa0 == 0)
    800017e4:	c131                	beqz	a0,80001828 <copyinstr+0xa2>
    n = PGSIZE - (srcva - va0);
    800017e6:	417906b3          	sub	a3,s2,s7
    800017ea:	96ce                	add	a3,a3,s3
    800017ec:	00d4f363          	bgeu	s1,a3,800017f2 <copyinstr+0x6c>
    800017f0:	86a6                	mv	a3,s1
    char *p = (char *) (pa0 + (srcva - va0));
    800017f2:	955e                	add	a0,a0,s7
    800017f4:	41250533          	sub	a0,a0,s2
    while(n > 0){
    800017f8:	daf9                	beqz	a3,800017ce <copyinstr+0x48>
    800017fa:	87da                	mv	a5,s6
      if(*p == '\0'){
    800017fc:	41650633          	sub	a2,a0,s6
    80001800:	fff48593          	addi	a1,s1,-1
    80001804:	95da                	add	a1,a1,s6
    while(n > 0){
    80001806:	96da                	add	a3,a3,s6
      if(*p == '\0'){
    80001808:	00f60733          	add	a4,a2,a5
    8000180c:	00074703          	lbu	a4,0(a4) # fffffffffffff000 <end+0xffffffff7ffdd078>
    80001810:	df51                	beqz	a4,800017ac <copyinstr+0x26>
        *dst = *p;
    80001812:	00e78023          	sb	a4,0(a5)
      --max;
    80001816:	40f584b3          	sub	s1,a1,a5
      dst++;
    8000181a:	0785                	addi	a5,a5,1
    while(n > 0){
    8000181c:	fed796e3          	bne	a5,a3,80001808 <copyinstr+0x82>
      dst++;
    80001820:	8b3e                	mv	s6,a5
    80001822:	b775                	j	800017ce <copyinstr+0x48>
    80001824:	4781                	li	a5,0
    80001826:	b771                	j	800017b2 <copyinstr+0x2c>
      return -1;
    80001828:	557d                	li	a0,-1
    8000182a:	b779                	j	800017b8 <copyinstr+0x32>
  int got_null = 0;
    8000182c:	4781                	li	a5,0
  if(got_null){
    8000182e:	37fd                	addiw	a5,a5,-1
    80001830:	0007851b          	sext.w	a0,a5
}
    80001834:	8082                	ret

0000000080001836 <proc_mapstacks>:
// Allocate a page for each process's kernel stack.
// Map it high in memory, followed by an invalid
// guard page.
void
proc_mapstacks(pagetable_t kpgtbl)
{
    80001836:	7139                	addi	sp,sp,-64
    80001838:	fc06                	sd	ra,56(sp)
    8000183a:	f822                	sd	s0,48(sp)
    8000183c:	f426                	sd	s1,40(sp)
    8000183e:	f04a                	sd	s2,32(sp)
    80001840:	ec4e                	sd	s3,24(sp)
    80001842:	e852                	sd	s4,16(sp)
    80001844:	e456                	sd	s5,8(sp)
    80001846:	e05a                	sd	s6,0(sp)
    80001848:	0080                	addi	s0,sp,64
    8000184a:	89aa                	mv	s3,a0
  struct proc *p;
  
  for(p = proc; p < &proc[NPROC]; p++) {
    8000184c:	0000f497          	auipc	s1,0xf
    80001850:	75c48493          	addi	s1,s1,1884 # 80010fa8 <proc>
    char *pa = kalloc();
    if(pa == 0)
      panic("kalloc");
    uint64 va = KSTACK((int) (p - proc));
    80001854:	8b26                	mv	s6,s1
    80001856:	00006a97          	auipc	s5,0x6
    8000185a:	7aaa8a93          	addi	s5,s5,1962 # 80008000 <etext>
    8000185e:	04000937          	lui	s2,0x4000
    80001862:	197d                	addi	s2,s2,-1 # 3ffffff <_entry-0x7c000001>
    80001864:	0932                	slli	s2,s2,0xc
  for(p = proc; p < &proc[NPROC]; p++) {
    80001866:	00015a17          	auipc	s4,0x15
    8000186a:	342a0a13          	addi	s4,s4,834 # 80016ba8 <tickslock>
    char *pa = kalloc();
    8000186e:	fffff097          	auipc	ra,0xfffff
    80001872:	278080e7          	jalr	632(ra) # 80000ae6 <kalloc>
    80001876:	862a                	mv	a2,a0
    if(pa == 0)
    80001878:	c131                	beqz	a0,800018bc <proc_mapstacks+0x86>
    uint64 va = KSTACK((int) (p - proc));
    8000187a:	416485b3          	sub	a1,s1,s6
    8000187e:	8591                	srai	a1,a1,0x4
    80001880:	000ab783          	ld	a5,0(s5)
    80001884:	02f585b3          	mul	a1,a1,a5
    80001888:	2585                	addiw	a1,a1,1
    8000188a:	00d5959b          	slliw	a1,a1,0xd
    kvmmap(kpgtbl, va, (uint64)pa, PGSIZE, PTE_R | PTE_W);
    8000188e:	4719                	li	a4,6
    80001890:	6685                	lui	a3,0x1
    80001892:	40b905b3          	sub	a1,s2,a1
    80001896:	854e                	mv	a0,s3
    80001898:	00000097          	auipc	ra,0x0
    8000189c:	8a6080e7          	jalr	-1882(ra) # 8000113e <kvmmap>
  for(p = proc; p < &proc[NPROC]; p++) {
    800018a0:	17048493          	addi	s1,s1,368
    800018a4:	fd4495e3          	bne	s1,s4,8000186e <proc_mapstacks+0x38>
  }
}
    800018a8:	70e2                	ld	ra,56(sp)
    800018aa:	7442                	ld	s0,48(sp)
    800018ac:	74a2                	ld	s1,40(sp)
    800018ae:	7902                	ld	s2,32(sp)
    800018b0:	69e2                	ld	s3,24(sp)
    800018b2:	6a42                	ld	s4,16(sp)
    800018b4:	6aa2                	ld	s5,8(sp)
    800018b6:	6b02                	ld	s6,0(sp)
    800018b8:	6121                	addi	sp,sp,64
    800018ba:	8082                	ret
      panic("kalloc");
    800018bc:	00007517          	auipc	a0,0x7
    800018c0:	91c50513          	addi	a0,a0,-1764 # 800081d8 <digits+0x198>
    800018c4:	fffff097          	auipc	ra,0xfffff
    800018c8:	c7c080e7          	jalr	-900(ra) # 80000540 <panic>

00000000800018cc <procinit>:

// initialize the proc table.
void
procinit(void)
{
    800018cc:	7139                	addi	sp,sp,-64
    800018ce:	fc06                	sd	ra,56(sp)
    800018d0:	f822                	sd	s0,48(sp)
    800018d2:	f426                	sd	s1,40(sp)
    800018d4:	f04a                	sd	s2,32(sp)
    800018d6:	ec4e                	sd	s3,24(sp)
    800018d8:	e852                	sd	s4,16(sp)
    800018da:	e456                	sd	s5,8(sp)
    800018dc:	e05a                	sd	s6,0(sp)
    800018de:	0080                	addi	s0,sp,64
  struct proc *p;
  
  initlock(&pid_lock, "nextpid");
    800018e0:	00007597          	auipc	a1,0x7
    800018e4:	90058593          	addi	a1,a1,-1792 # 800081e0 <digits+0x1a0>
    800018e8:	0000f517          	auipc	a0,0xf
    800018ec:	27850513          	addi	a0,a0,632 # 80010b60 <pid_lock>
    800018f0:	fffff097          	auipc	ra,0xfffff
    800018f4:	256080e7          	jalr	598(ra) # 80000b46 <initlock>
  initlock(&wait_lock, "wait_lock");
    800018f8:	00007597          	auipc	a1,0x7
    800018fc:	8f058593          	addi	a1,a1,-1808 # 800081e8 <digits+0x1a8>
    80001900:	0000f517          	auipc	a0,0xf
    80001904:	27850513          	addi	a0,a0,632 # 80010b78 <wait_lock>
    80001908:	fffff097          	auipc	ra,0xfffff
    8000190c:	23e080e7          	jalr	574(ra) # 80000b46 <initlock>
  for(p = proc; p < &proc[NPROC]; p++) {
    80001910:	0000f497          	auipc	s1,0xf
    80001914:	69848493          	addi	s1,s1,1688 # 80010fa8 <proc>
      initlock(&p->lock, "proc");
    80001918:	00007b17          	auipc	s6,0x7
    8000191c:	8e0b0b13          	addi	s6,s6,-1824 # 800081f8 <digits+0x1b8>
      p->state = UNUSED;
      p->kstack = KSTACK((int) (p - proc));
    80001920:	8aa6                	mv	s5,s1
    80001922:	00006a17          	auipc	s4,0x6
    80001926:	6dea0a13          	addi	s4,s4,1758 # 80008000 <etext>
    8000192a:	04000937          	lui	s2,0x4000
    8000192e:	197d                	addi	s2,s2,-1 # 3ffffff <_entry-0x7c000001>
    80001930:	0932                	slli	s2,s2,0xc
  for(p = proc; p < &proc[NPROC]; p++) {
    80001932:	00015997          	auipc	s3,0x15
    80001936:	27698993          	addi	s3,s3,630 # 80016ba8 <tickslock>
      initlock(&p->lock, "proc");
    8000193a:	85da                	mv	a1,s6
    8000193c:	8526                	mv	a0,s1
    8000193e:	fffff097          	auipc	ra,0xfffff
    80001942:	208080e7          	jalr	520(ra) # 80000b46 <initlock>
      p->state = UNUSED;
    80001946:	0004ac23          	sw	zero,24(s1)
      p->kstack = KSTACK((int) (p - proc));
    8000194a:	415487b3          	sub	a5,s1,s5
    8000194e:	8791                	srai	a5,a5,0x4
    80001950:	000a3703          	ld	a4,0(s4)
    80001954:	02e787b3          	mul	a5,a5,a4
    80001958:	2785                	addiw	a5,a5,1
    8000195a:	00d7979b          	slliw	a5,a5,0xd
    8000195e:	40f907b3          	sub	a5,s2,a5
    80001962:	e0bc                	sd	a5,64(s1)
  for(p = proc; p < &proc[NPROC]; p++) {
    80001964:	17048493          	addi	s1,s1,368
    80001968:	fd3499e3          	bne	s1,s3,8000193a <procinit+0x6e>
  }
}
    8000196c:	70e2                	ld	ra,56(sp)
    8000196e:	7442                	ld	s0,48(sp)
    80001970:	74a2                	ld	s1,40(sp)
    80001972:	7902                	ld	s2,32(sp)
    80001974:	69e2                	ld	s3,24(sp)
    80001976:	6a42                	ld	s4,16(sp)
    80001978:	6aa2                	ld	s5,8(sp)
    8000197a:	6b02                	ld	s6,0(sp)
    8000197c:	6121                	addi	sp,sp,64
    8000197e:	8082                	ret

0000000080001980 <cpuid>:
// Must be called with interrupts disabled,
// to prevent race with process being moved
// to a different CPU.
int
cpuid()
{
    80001980:	1141                	addi	sp,sp,-16
    80001982:	e422                	sd	s0,8(sp)
    80001984:	0800                	addi	s0,sp,16
  asm volatile("mv %0, tp" : "=r" (x) );
    80001986:	8512                	mv	a0,tp
  int id = r_tp();
  return id;
}
    80001988:	2501                	sext.w	a0,a0
    8000198a:	6422                	ld	s0,8(sp)
    8000198c:	0141                	addi	sp,sp,16
    8000198e:	8082                	ret

0000000080001990 <mycpu>:

// Return this CPU's cpu struct.
// Interrupts must be disabled.
struct cpu*
mycpu(void)
{
    80001990:	1141                	addi	sp,sp,-16
    80001992:	e422                	sd	s0,8(sp)
    80001994:	0800                	addi	s0,sp,16
    80001996:	8792                	mv	a5,tp
  int id = cpuid();
  struct cpu *c = &cpus[id];
    80001998:	2781                	sext.w	a5,a5
    8000199a:	079e                	slli	a5,a5,0x7
  return c;
}
    8000199c:	0000f517          	auipc	a0,0xf
    800019a0:	1f450513          	addi	a0,a0,500 # 80010b90 <cpus>
    800019a4:	953e                	add	a0,a0,a5
    800019a6:	6422                	ld	s0,8(sp)
    800019a8:	0141                	addi	sp,sp,16
    800019aa:	8082                	ret

00000000800019ac <myproc>:

// Return the current struct proc *, or zero if none.
struct proc*
myproc(void)
{
    800019ac:	1101                	addi	sp,sp,-32
    800019ae:	ec06                	sd	ra,24(sp)
    800019b0:	e822                	sd	s0,16(sp)
    800019b2:	e426                	sd	s1,8(sp)
    800019b4:	1000                	addi	s0,sp,32
  push_off();
    800019b6:	fffff097          	auipc	ra,0xfffff
    800019ba:	1d4080e7          	jalr	468(ra) # 80000b8a <push_off>
    800019be:	8792                	mv	a5,tp
  struct cpu *c = mycpu();
  struct proc *p = c->proc;
    800019c0:	2781                	sext.w	a5,a5
    800019c2:	079e                	slli	a5,a5,0x7
    800019c4:	0000f717          	auipc	a4,0xf
    800019c8:	19c70713          	addi	a4,a4,412 # 80010b60 <pid_lock>
    800019cc:	97ba                	add	a5,a5,a4
    800019ce:	7b84                	ld	s1,48(a5)
  pop_off();
    800019d0:	fffff097          	auipc	ra,0xfffff
    800019d4:	25a080e7          	jalr	602(ra) # 80000c2a <pop_off>
  return p;
}
    800019d8:	8526                	mv	a0,s1
    800019da:	60e2                	ld	ra,24(sp)
    800019dc:	6442                	ld	s0,16(sp)
    800019de:	64a2                	ld	s1,8(sp)
    800019e0:	6105                	addi	sp,sp,32
    800019e2:	8082                	ret

00000000800019e4 <forkret>:

// A fork child's very first scheduling by scheduler()
// will swtch to forkret.
void
forkret(void)
{
    800019e4:	1141                	addi	sp,sp,-16
    800019e6:	e406                	sd	ra,8(sp)
    800019e8:	e022                	sd	s0,0(sp)
    800019ea:	0800                	addi	s0,sp,16
  static int first = 1;

  // Still holding p->lock from scheduler.
  release(&myproc()->lock);
    800019ec:	00000097          	auipc	ra,0x0
    800019f0:	fc0080e7          	jalr	-64(ra) # 800019ac <myproc>
    800019f4:	fffff097          	auipc	ra,0xfffff
    800019f8:	296080e7          	jalr	662(ra) # 80000c8a <release>

  if (first) {
    800019fc:	00007797          	auipc	a5,0x7
    80001a00:	e547a783          	lw	a5,-428(a5) # 80008850 <first.1>
    80001a04:	eb89                	bnez	a5,80001a16 <forkret+0x32>
    // be run from main().
    first = 0;
    fsinit(ROOTDEV);
  }

  usertrapret();
    80001a06:	00001097          	auipc	ra,0x1
    80001a0a:	ec6080e7          	jalr	-314(ra) # 800028cc <usertrapret>
}
    80001a0e:	60a2                	ld	ra,8(sp)
    80001a10:	6402                	ld	s0,0(sp)
    80001a12:	0141                	addi	sp,sp,16
    80001a14:	8082                	ret
    first = 0;
    80001a16:	00007797          	auipc	a5,0x7
    80001a1a:	e207ad23          	sw	zero,-454(a5) # 80008850 <first.1>
    fsinit(ROOTDEV);
    80001a1e:	4505                	li	a0,1
    80001a20:	00002097          	auipc	ra,0x2
    80001a24:	c48080e7          	jalr	-952(ra) # 80003668 <fsinit>
    80001a28:	bff9                	j	80001a06 <forkret+0x22>

0000000080001a2a <allocpid>:
{
    80001a2a:	1101                	addi	sp,sp,-32
    80001a2c:	ec06                	sd	ra,24(sp)
    80001a2e:	e822                	sd	s0,16(sp)
    80001a30:	e426                	sd	s1,8(sp)
    80001a32:	e04a                	sd	s2,0(sp)
    80001a34:	1000                	addi	s0,sp,32
  acquire(&pid_lock);
    80001a36:	0000f917          	auipc	s2,0xf
    80001a3a:	12a90913          	addi	s2,s2,298 # 80010b60 <pid_lock>
    80001a3e:	854a                	mv	a0,s2
    80001a40:	fffff097          	auipc	ra,0xfffff
    80001a44:	196080e7          	jalr	406(ra) # 80000bd6 <acquire>
  pid = nextpid;
    80001a48:	00007797          	auipc	a5,0x7
    80001a4c:	e1078793          	addi	a5,a5,-496 # 80008858 <nextpid>
    80001a50:	4384                	lw	s1,0(a5)
  nextpid = nextpid + 1;
    80001a52:	0014871b          	addiw	a4,s1,1
    80001a56:	c398                	sw	a4,0(a5)
  release(&pid_lock);
    80001a58:	854a                	mv	a0,s2
    80001a5a:	fffff097          	auipc	ra,0xfffff
    80001a5e:	230080e7          	jalr	560(ra) # 80000c8a <release>
}
    80001a62:	8526                	mv	a0,s1
    80001a64:	60e2                	ld	ra,24(sp)
    80001a66:	6442                	ld	s0,16(sp)
    80001a68:	64a2                	ld	s1,8(sp)
    80001a6a:	6902                	ld	s2,0(sp)
    80001a6c:	6105                	addi	sp,sp,32
    80001a6e:	8082                	ret

0000000080001a70 <alloctid>:
{
    80001a70:	1101                	addi	sp,sp,-32
    80001a72:	ec06                	sd	ra,24(sp)
    80001a74:	e822                	sd	s0,16(sp)
    80001a76:	e426                	sd	s1,8(sp)
    80001a78:	e04a                	sd	s2,0(sp)
    80001a7a:	1000                	addi	s0,sp,32
  acquire(&thrd_id_lk);
    80001a7c:	0000f917          	auipc	s2,0xf
    80001a80:	51490913          	addi	s2,s2,1300 # 80010f90 <thrd_id_lk>
    80001a84:	854a                	mv	a0,s2
    80001a86:	fffff097          	auipc	ra,0xfffff
    80001a8a:	150080e7          	jalr	336(ra) # 80000bd6 <acquire>
  tid= next_thrd_id;
    80001a8e:	00007797          	auipc	a5,0x7
    80001a92:	dc678793          	addi	a5,a5,-570 # 80008854 <next_thrd_id>
    80001a96:	4384                	lw	s1,0(a5)
  next_thrd_id+= 1;
    80001a98:	0014871b          	addiw	a4,s1,1
    80001a9c:	c398                	sw	a4,0(a5)
  release(&thrd_id_lk);
    80001a9e:	854a                	mv	a0,s2
    80001aa0:	fffff097          	auipc	ra,0xfffff
    80001aa4:	1ea080e7          	jalr	490(ra) # 80000c8a <release>
}
    80001aa8:	8526                	mv	a0,s1
    80001aaa:	60e2                	ld	ra,24(sp)
    80001aac:	6442                	ld	s0,16(sp)
    80001aae:	64a2                	ld	s1,8(sp)
    80001ab0:	6902                	ld	s2,0(sp)
    80001ab2:	6105                	addi	sp,sp,32
    80001ab4:	8082                	ret

0000000080001ab6 <proc_pagetable>:
{
    80001ab6:	1101                	addi	sp,sp,-32
    80001ab8:	ec06                	sd	ra,24(sp)
    80001aba:	e822                	sd	s0,16(sp)
    80001abc:	e426                	sd	s1,8(sp)
    80001abe:	e04a                	sd	s2,0(sp)
    80001ac0:	1000                	addi	s0,sp,32
    80001ac2:	892a                	mv	s2,a0
  pagetable = uvmcreate();
    80001ac4:	00000097          	auipc	ra,0x0
    80001ac8:	864080e7          	jalr	-1948(ra) # 80001328 <uvmcreate>
    80001acc:	84aa                	mv	s1,a0
  if(pagetable == 0)
    80001ace:	c121                	beqz	a0,80001b0e <proc_pagetable+0x58>
  if(mappages(pagetable, TRAMPOLINE, PGSIZE,
    80001ad0:	4729                	li	a4,10
    80001ad2:	00005697          	auipc	a3,0x5
    80001ad6:	52e68693          	addi	a3,a3,1326 # 80007000 <_trampoline>
    80001ada:	6605                	lui	a2,0x1
    80001adc:	040005b7          	lui	a1,0x4000
    80001ae0:	15fd                	addi	a1,a1,-1 # 3ffffff <_entry-0x7c000001>
    80001ae2:	05b2                	slli	a1,a1,0xc
    80001ae4:	fffff097          	auipc	ra,0xfffff
    80001ae8:	5ba080e7          	jalr	1466(ra) # 8000109e <mappages>
    80001aec:	02054863          	bltz	a0,80001b1c <proc_pagetable+0x66>
  if(mappages(pagetable, TRAPFRAME, PGSIZE,
    80001af0:	4719                	li	a4,6
    80001af2:	05893683          	ld	a3,88(s2)
    80001af6:	6605                	lui	a2,0x1
    80001af8:	020005b7          	lui	a1,0x2000
    80001afc:	15fd                	addi	a1,a1,-1 # 1ffffff <_entry-0x7e000001>
    80001afe:	05b6                	slli	a1,a1,0xd
    80001b00:	8526                	mv	a0,s1
    80001b02:	fffff097          	auipc	ra,0xfffff
    80001b06:	59c080e7          	jalr	1436(ra) # 8000109e <mappages>
    80001b0a:	02054163          	bltz	a0,80001b2c <proc_pagetable+0x76>
}
    80001b0e:	8526                	mv	a0,s1
    80001b10:	60e2                	ld	ra,24(sp)
    80001b12:	6442                	ld	s0,16(sp)
    80001b14:	64a2                	ld	s1,8(sp)
    80001b16:	6902                	ld	s2,0(sp)
    80001b18:	6105                	addi	sp,sp,32
    80001b1a:	8082                	ret
    uvmfree(pagetable, 0);
    80001b1c:	4581                	li	a1,0
    80001b1e:	8526                	mv	a0,s1
    80001b20:	00000097          	auipc	ra,0x0
    80001b24:	a0e080e7          	jalr	-1522(ra) # 8000152e <uvmfree>
    return 0;
    80001b28:	4481                	li	s1,0
    80001b2a:	b7d5                	j	80001b0e <proc_pagetable+0x58>
    uvmunmap(pagetable, TRAMPOLINE, 1, 0);
    80001b2c:	4681                	li	a3,0
    80001b2e:	4605                	li	a2,1
    80001b30:	040005b7          	lui	a1,0x4000
    80001b34:	15fd                	addi	a1,a1,-1 # 3ffffff <_entry-0x7c000001>
    80001b36:	05b2                	slli	a1,a1,0xc
    80001b38:	8526                	mv	a0,s1
    80001b3a:	fffff097          	auipc	ra,0xfffff
    80001b3e:	72a080e7          	jalr	1834(ra) # 80001264 <uvmunmap>
    uvmfree(pagetable, 0);
    80001b42:	4581                	li	a1,0
    80001b44:	8526                	mv	a0,s1
    80001b46:	00000097          	auipc	ra,0x0
    80001b4a:	9e8080e7          	jalr	-1560(ra) # 8000152e <uvmfree>
    return 0;
    80001b4e:	4481                	li	s1,0
    80001b50:	bf7d                	j	80001b0e <proc_pagetable+0x58>

0000000080001b52 <proc_freepagetable>:
{
    80001b52:	1101                	addi	sp,sp,-32
    80001b54:	ec06                	sd	ra,24(sp)
    80001b56:	e822                	sd	s0,16(sp)
    80001b58:	e426                	sd	s1,8(sp)
    80001b5a:	e04a                	sd	s2,0(sp)
    80001b5c:	1000                	addi	s0,sp,32
    80001b5e:	84aa                	mv	s1,a0
    80001b60:	892e                	mv	s2,a1
  uvmunmap(pagetable, TRAMPOLINE, 1, 0);
    80001b62:	4681                	li	a3,0
    80001b64:	4605                	li	a2,1
    80001b66:	040005b7          	lui	a1,0x4000
    80001b6a:	15fd                	addi	a1,a1,-1 # 3ffffff <_entry-0x7c000001>
    80001b6c:	05b2                	slli	a1,a1,0xc
    80001b6e:	fffff097          	auipc	ra,0xfffff
    80001b72:	6f6080e7          	jalr	1782(ra) # 80001264 <uvmunmap>
  uvmunmap(pagetable, TRAPFRAME, 1, 0);
    80001b76:	4681                	li	a3,0
    80001b78:	4605                	li	a2,1
    80001b7a:	020005b7          	lui	a1,0x2000
    80001b7e:	15fd                	addi	a1,a1,-1 # 1ffffff <_entry-0x7e000001>
    80001b80:	05b6                	slli	a1,a1,0xd
    80001b82:	8526                	mv	a0,s1
    80001b84:	fffff097          	auipc	ra,0xfffff
    80001b88:	6e0080e7          	jalr	1760(ra) # 80001264 <uvmunmap>
  uvmfree(pagetable, sz);
    80001b8c:	85ca                	mv	a1,s2
    80001b8e:	8526                	mv	a0,s1
    80001b90:	00000097          	auipc	ra,0x0
    80001b94:	99e080e7          	jalr	-1634(ra) # 8000152e <uvmfree>
}
    80001b98:	60e2                	ld	ra,24(sp)
    80001b9a:	6442                	ld	s0,16(sp)
    80001b9c:	64a2                	ld	s1,8(sp)
    80001b9e:	6902                	ld	s2,0(sp)
    80001ba0:	6105                	addi	sp,sp,32
    80001ba2:	8082                	ret

0000000080001ba4 <freeproc>:
{
    80001ba4:	1101                	addi	sp,sp,-32
    80001ba6:	ec06                	sd	ra,24(sp)
    80001ba8:	e822                	sd	s0,16(sp)
    80001baa:	e426                	sd	s1,8(sp)
    80001bac:	1000                	addi	s0,sp,32
    80001bae:	84aa                	mv	s1,a0
  if(p->trapframe)
    80001bb0:	6d28                	ld	a0,88(a0)
    80001bb2:	c509                	beqz	a0,80001bbc <freeproc+0x18>
    kfree((void*)p->trapframe);
    80001bb4:	fffff097          	auipc	ra,0xfffff
    80001bb8:	e34080e7          	jalr	-460(ra) # 800009e8 <kfree>
  p->trapframe = 0;
    80001bbc:	0404bc23          	sd	zero,88(s1)
  if(p->thread_id!= 0 && p->pagetable!= 0){
    80001bc0:	1684a583          	lw	a1,360(s1)
    80001bc4:	c195                	beqz	a1,80001be8 <freeproc+0x44>
    80001bc6:	68a8                	ld	a0,80(s1)
    80001bc8:	c51d                	beqz	a0,80001bf6 <freeproc+0x52>
    uvmunmap(p->pagetable, TRAPFRAME - PGSIZE * (p->thread_id), 1, 0);
    80001bca:	00c5959b          	slliw	a1,a1,0xc
    80001bce:	020007b7          	lui	a5,0x2000
    80001bd2:	4681                	li	a3,0
    80001bd4:	4605                	li	a2,1
    80001bd6:	17fd                	addi	a5,a5,-1 # 1ffffff <_entry-0x7e000001>
    80001bd8:	07b6                	slli	a5,a5,0xd
    80001bda:	40b785b3          	sub	a1,a5,a1
    80001bde:	fffff097          	auipc	ra,0xfffff
    80001be2:	686080e7          	jalr	1670(ra) # 80001264 <uvmunmap>
    80001be6:	a801                	j	80001bf6 <freeproc+0x52>
  else if(p->pagetable != 0){
    80001be8:	68a8                	ld	a0,80(s1)
    80001bea:	c511                	beqz	a0,80001bf6 <freeproc+0x52>
    proc_freepagetable(p->pagetable, p->sz);
    80001bec:	64ac                	ld	a1,72(s1)
    80001bee:	00000097          	auipc	ra,0x0
    80001bf2:	f64080e7          	jalr	-156(ra) # 80001b52 <proc_freepagetable>
  p->pagetable = 0;
    80001bf6:	0404b823          	sd	zero,80(s1)
  p->sz = 0;
    80001bfa:	0404b423          	sd	zero,72(s1)
  p->pid = 0;
    80001bfe:	0204a823          	sw	zero,48(s1)
  p->parent = 0;
    80001c02:	0204bc23          	sd	zero,56(s1)
  p->name[0] = 0;
    80001c06:	14048c23          	sb	zero,344(s1)
  p->chan = 0;
    80001c0a:	0204b023          	sd	zero,32(s1)
  p->killed = 0;
    80001c0e:	0204a423          	sw	zero,40(s1)
  p->xstate = 0;
    80001c12:	0204a623          	sw	zero,44(s1)
  p->state = UNUSED;
    80001c16:	0004ac23          	sw	zero,24(s1)
}
    80001c1a:	60e2                	ld	ra,24(sp)
    80001c1c:	6442                	ld	s0,16(sp)
    80001c1e:	64a2                	ld	s1,8(sp)
    80001c20:	6105                	addi	sp,sp,32
    80001c22:	8082                	ret

0000000080001c24 <allocproc>:
{
    80001c24:	1101                	addi	sp,sp,-32
    80001c26:	ec06                	sd	ra,24(sp)
    80001c28:	e822                	sd	s0,16(sp)
    80001c2a:	e426                	sd	s1,8(sp)
    80001c2c:	e04a                	sd	s2,0(sp)
    80001c2e:	1000                	addi	s0,sp,32
  for(p = proc; p < &proc[NPROC]; p++) {
    80001c30:	0000f497          	auipc	s1,0xf
    80001c34:	37848493          	addi	s1,s1,888 # 80010fa8 <proc>
    80001c38:	00015917          	auipc	s2,0x15
    80001c3c:	f7090913          	addi	s2,s2,-144 # 80016ba8 <tickslock>
    acquire(&p->lock);
    80001c40:	8526                	mv	a0,s1
    80001c42:	fffff097          	auipc	ra,0xfffff
    80001c46:	f94080e7          	jalr	-108(ra) # 80000bd6 <acquire>
    if(p->state == UNUSED) {
    80001c4a:	4c9c                	lw	a5,24(s1)
    80001c4c:	cf81                	beqz	a5,80001c64 <allocproc+0x40>
      release(&p->lock);
    80001c4e:	8526                	mv	a0,s1
    80001c50:	fffff097          	auipc	ra,0xfffff
    80001c54:	03a080e7          	jalr	58(ra) # 80000c8a <release>
  for(p = proc; p < &proc[NPROC]; p++) {
    80001c58:	17048493          	addi	s1,s1,368
    80001c5c:	ff2492e3          	bne	s1,s2,80001c40 <allocproc+0x1c>
  return 0;
    80001c60:	4481                	li	s1,0
    80001c62:	a889                	j	80001cb4 <allocproc+0x90>
  p->pid = allocpid();
    80001c64:	00000097          	auipc	ra,0x0
    80001c68:	dc6080e7          	jalr	-570(ra) # 80001a2a <allocpid>
    80001c6c:	d888                	sw	a0,48(s1)
  p->state = USED;
    80001c6e:	4785                	li	a5,1
    80001c70:	cc9c                	sw	a5,24(s1)
  if((p->trapframe = (struct trapframe *)kalloc()) == 0){
    80001c72:	fffff097          	auipc	ra,0xfffff
    80001c76:	e74080e7          	jalr	-396(ra) # 80000ae6 <kalloc>
    80001c7a:	892a                	mv	s2,a0
    80001c7c:	eca8                	sd	a0,88(s1)
    80001c7e:	c131                	beqz	a0,80001cc2 <allocproc+0x9e>
  p->pagetable = proc_pagetable(p);
    80001c80:	8526                	mv	a0,s1
    80001c82:	00000097          	auipc	ra,0x0
    80001c86:	e34080e7          	jalr	-460(ra) # 80001ab6 <proc_pagetable>
    80001c8a:	892a                	mv	s2,a0
    80001c8c:	e8a8                	sd	a0,80(s1)
  if(p->pagetable == 0){
    80001c8e:	c531                	beqz	a0,80001cda <allocproc+0xb6>
  memset(&p->context, 0, sizeof(p->context));
    80001c90:	07000613          	li	a2,112
    80001c94:	4581                	li	a1,0
    80001c96:	06048513          	addi	a0,s1,96
    80001c9a:	fffff097          	auipc	ra,0xfffff
    80001c9e:	038080e7          	jalr	56(ra) # 80000cd2 <memset>
  p->context.ra = (uint64)forkret;
    80001ca2:	00000797          	auipc	a5,0x0
    80001ca6:	d4278793          	addi	a5,a5,-702 # 800019e4 <forkret>
    80001caa:	f0bc                	sd	a5,96(s1)
  p->context.sp = p->kstack + PGSIZE;
    80001cac:	60bc                	ld	a5,64(s1)
    80001cae:	6705                	lui	a4,0x1
    80001cb0:	97ba                	add	a5,a5,a4
    80001cb2:	f4bc                	sd	a5,104(s1)
}
    80001cb4:	8526                	mv	a0,s1
    80001cb6:	60e2                	ld	ra,24(sp)
    80001cb8:	6442                	ld	s0,16(sp)
    80001cba:	64a2                	ld	s1,8(sp)
    80001cbc:	6902                	ld	s2,0(sp)
    80001cbe:	6105                	addi	sp,sp,32
    80001cc0:	8082                	ret
    freeproc(p);
    80001cc2:	8526                	mv	a0,s1
    80001cc4:	00000097          	auipc	ra,0x0
    80001cc8:	ee0080e7          	jalr	-288(ra) # 80001ba4 <freeproc>
    release(&p->lock);
    80001ccc:	8526                	mv	a0,s1
    80001cce:	fffff097          	auipc	ra,0xfffff
    80001cd2:	fbc080e7          	jalr	-68(ra) # 80000c8a <release>
    return 0;
    80001cd6:	84ca                	mv	s1,s2
    80001cd8:	bff1                	j	80001cb4 <allocproc+0x90>
    freeproc(p);
    80001cda:	8526                	mv	a0,s1
    80001cdc:	00000097          	auipc	ra,0x0
    80001ce0:	ec8080e7          	jalr	-312(ra) # 80001ba4 <freeproc>
    release(&p->lock);
    80001ce4:	8526                	mv	a0,s1
    80001ce6:	fffff097          	auipc	ra,0xfffff
    80001cea:	fa4080e7          	jalr	-92(ra) # 80000c8a <release>
    return 0;
    80001cee:	84ca                	mv	s1,s2
    80001cf0:	b7d1                	j	80001cb4 <allocproc+0x90>

0000000080001cf2 <userinit>:
{
    80001cf2:	1101                	addi	sp,sp,-32
    80001cf4:	ec06                	sd	ra,24(sp)
    80001cf6:	e822                	sd	s0,16(sp)
    80001cf8:	e426                	sd	s1,8(sp)
    80001cfa:	1000                	addi	s0,sp,32
  p = allocproc();
    80001cfc:	00000097          	auipc	ra,0x0
    80001d00:	f28080e7          	jalr	-216(ra) # 80001c24 <allocproc>
    80001d04:	84aa                	mv	s1,a0
  initproc = p;
    80001d06:	00007797          	auipc	a5,0x7
    80001d0a:	bea7b123          	sd	a0,-1054(a5) # 800088e8 <initproc>
  uvmfirst(p->pagetable, initcode, sizeof(initcode));
    80001d0e:	03400613          	li	a2,52
    80001d12:	00007597          	auipc	a1,0x7
    80001d16:	b4e58593          	addi	a1,a1,-1202 # 80008860 <initcode>
    80001d1a:	6928                	ld	a0,80(a0)
    80001d1c:	fffff097          	auipc	ra,0xfffff
    80001d20:	63a080e7          	jalr	1594(ra) # 80001356 <uvmfirst>
  p->sz = PGSIZE;
    80001d24:	6785                	lui	a5,0x1
    80001d26:	e4bc                	sd	a5,72(s1)
  p->trapframe->epc = 0;      // user program counter
    80001d28:	6cb8                	ld	a4,88(s1)
    80001d2a:	00073c23          	sd	zero,24(a4) # 1018 <_entry-0x7fffefe8>
  p->trapframe->sp = PGSIZE;  // user stack pointer
    80001d2e:	6cb8                	ld	a4,88(s1)
    80001d30:	fb1c                	sd	a5,48(a4)
  safestrcpy(p->name, "initcode", sizeof(p->name));
    80001d32:	4641                	li	a2,16
    80001d34:	00006597          	auipc	a1,0x6
    80001d38:	4cc58593          	addi	a1,a1,1228 # 80008200 <digits+0x1c0>
    80001d3c:	15848513          	addi	a0,s1,344
    80001d40:	fffff097          	auipc	ra,0xfffff
    80001d44:	0dc080e7          	jalr	220(ra) # 80000e1c <safestrcpy>
  p->cwd = namei("/");
    80001d48:	00006517          	auipc	a0,0x6
    80001d4c:	4c850513          	addi	a0,a0,1224 # 80008210 <digits+0x1d0>
    80001d50:	00002097          	auipc	ra,0x2
    80001d54:	342080e7          	jalr	834(ra) # 80004092 <namei>
    80001d58:	14a4b823          	sd	a0,336(s1)
  p->state = RUNNABLE;
    80001d5c:	478d                	li	a5,3
    80001d5e:	cc9c                	sw	a5,24(s1)
  release(&p->lock);
    80001d60:	8526                	mv	a0,s1
    80001d62:	fffff097          	auipc	ra,0xfffff
    80001d66:	f28080e7          	jalr	-216(ra) # 80000c8a <release>
}
    80001d6a:	60e2                	ld	ra,24(sp)
    80001d6c:	6442                	ld	s0,16(sp)
    80001d6e:	64a2                	ld	s1,8(sp)
    80001d70:	6105                	addi	sp,sp,32
    80001d72:	8082                	ret

0000000080001d74 <growproc>:
{
    80001d74:	1101                	addi	sp,sp,-32
    80001d76:	ec06                	sd	ra,24(sp)
    80001d78:	e822                	sd	s0,16(sp)
    80001d7a:	e426                	sd	s1,8(sp)
    80001d7c:	e04a                	sd	s2,0(sp)
    80001d7e:	1000                	addi	s0,sp,32
    80001d80:	892a                	mv	s2,a0
  struct proc *p = myproc();
    80001d82:	00000097          	auipc	ra,0x0
    80001d86:	c2a080e7          	jalr	-982(ra) # 800019ac <myproc>
    80001d8a:	84aa                	mv	s1,a0
  sz = p->sz;
    80001d8c:	652c                	ld	a1,72(a0)
  if(n > 0){
    80001d8e:	01204c63          	bgtz	s2,80001da6 <growproc+0x32>
  } else if(n < 0){
    80001d92:	02094663          	bltz	s2,80001dbe <growproc+0x4a>
  p->sz = sz;
    80001d96:	e4ac                	sd	a1,72(s1)
  return 0;
    80001d98:	4501                	li	a0,0
}
    80001d9a:	60e2                	ld	ra,24(sp)
    80001d9c:	6442                	ld	s0,16(sp)
    80001d9e:	64a2                	ld	s1,8(sp)
    80001da0:	6902                	ld	s2,0(sp)
    80001da2:	6105                	addi	sp,sp,32
    80001da4:	8082                	ret
    if((sz = uvmalloc(p->pagetable, sz, sz + n, PTE_W)) == 0) {
    80001da6:	4691                	li	a3,4
    80001da8:	00b90633          	add	a2,s2,a1
    80001dac:	6928                	ld	a0,80(a0)
    80001dae:	fffff097          	auipc	ra,0xfffff
    80001db2:	662080e7          	jalr	1634(ra) # 80001410 <uvmalloc>
    80001db6:	85aa                	mv	a1,a0
    80001db8:	fd79                	bnez	a0,80001d96 <growproc+0x22>
      return -1;
    80001dba:	557d                	li	a0,-1
    80001dbc:	bff9                	j	80001d9a <growproc+0x26>
    sz = uvmdealloc(p->pagetable, sz, sz + n);
    80001dbe:	00b90633          	add	a2,s2,a1
    80001dc2:	6928                	ld	a0,80(a0)
    80001dc4:	fffff097          	auipc	ra,0xfffff
    80001dc8:	604080e7          	jalr	1540(ra) # 800013c8 <uvmdealloc>
    80001dcc:	85aa                	mv	a1,a0
    80001dce:	b7e1                	j	80001d96 <growproc+0x22>

0000000080001dd0 <fork>:
{
    80001dd0:	7139                	addi	sp,sp,-64
    80001dd2:	fc06                	sd	ra,56(sp)
    80001dd4:	f822                	sd	s0,48(sp)
    80001dd6:	f426                	sd	s1,40(sp)
    80001dd8:	f04a                	sd	s2,32(sp)
    80001dda:	ec4e                	sd	s3,24(sp)
    80001ddc:	e852                	sd	s4,16(sp)
    80001dde:	e456                	sd	s5,8(sp)
    80001de0:	0080                	addi	s0,sp,64
  struct proc *p = myproc();
    80001de2:	00000097          	auipc	ra,0x0
    80001de6:	bca080e7          	jalr	-1078(ra) # 800019ac <myproc>
    80001dea:	8aaa                	mv	s5,a0
  if((np = allocproc()) == 0){
    80001dec:	00000097          	auipc	ra,0x0
    80001df0:	e38080e7          	jalr	-456(ra) # 80001c24 <allocproc>
    80001df4:	10050c63          	beqz	a0,80001f0c <fork+0x13c>
    80001df8:	8a2a                	mv	s4,a0
  if(uvmcopy(p->pagetable, np->pagetable, p->sz) < 0){
    80001dfa:	048ab603          	ld	a2,72(s5)
    80001dfe:	692c                	ld	a1,80(a0)
    80001e00:	050ab503          	ld	a0,80(s5)
    80001e04:	fffff097          	auipc	ra,0xfffff
    80001e08:	764080e7          	jalr	1892(ra) # 80001568 <uvmcopy>
    80001e0c:	04054863          	bltz	a0,80001e5c <fork+0x8c>
  np->sz = p->sz;
    80001e10:	048ab783          	ld	a5,72(s5)
    80001e14:	04fa3423          	sd	a5,72(s4)
  *(np->trapframe) = *(p->trapframe);
    80001e18:	058ab683          	ld	a3,88(s5)
    80001e1c:	87b6                	mv	a5,a3
    80001e1e:	058a3703          	ld	a4,88(s4)
    80001e22:	12068693          	addi	a3,a3,288
    80001e26:	0007b803          	ld	a6,0(a5) # 1000 <_entry-0x7ffff000>
    80001e2a:	6788                	ld	a0,8(a5)
    80001e2c:	6b8c                	ld	a1,16(a5)
    80001e2e:	6f90                	ld	a2,24(a5)
    80001e30:	01073023          	sd	a6,0(a4)
    80001e34:	e708                	sd	a0,8(a4)
    80001e36:	eb0c                	sd	a1,16(a4)
    80001e38:	ef10                	sd	a2,24(a4)
    80001e3a:	02078793          	addi	a5,a5,32
    80001e3e:	02070713          	addi	a4,a4,32
    80001e42:	fed792e3          	bne	a5,a3,80001e26 <fork+0x56>
  np->trapframe->a0 = 0;
    80001e46:	058a3783          	ld	a5,88(s4)
    80001e4a:	0607b823          	sd	zero,112(a5)
  for(i = 0; i < NOFILE; i++)
    80001e4e:	0d0a8493          	addi	s1,s5,208
    80001e52:	0d0a0913          	addi	s2,s4,208
    80001e56:	150a8993          	addi	s3,s5,336
    80001e5a:	a00d                	j	80001e7c <fork+0xac>
    freeproc(np);
    80001e5c:	8552                	mv	a0,s4
    80001e5e:	00000097          	auipc	ra,0x0
    80001e62:	d46080e7          	jalr	-698(ra) # 80001ba4 <freeproc>
    release(&np->lock);
    80001e66:	8552                	mv	a0,s4
    80001e68:	fffff097          	auipc	ra,0xfffff
    80001e6c:	e22080e7          	jalr	-478(ra) # 80000c8a <release>
    return -1;
    80001e70:	597d                	li	s2,-1
    80001e72:	a059                	j	80001ef8 <fork+0x128>
  for(i = 0; i < NOFILE; i++)
    80001e74:	04a1                	addi	s1,s1,8
    80001e76:	0921                	addi	s2,s2,8
    80001e78:	01348b63          	beq	s1,s3,80001e8e <fork+0xbe>
    if(p->ofile[i])
    80001e7c:	6088                	ld	a0,0(s1)
    80001e7e:	d97d                	beqz	a0,80001e74 <fork+0xa4>
      np->ofile[i] = filedup(p->ofile[i]);
    80001e80:	00003097          	auipc	ra,0x3
    80001e84:	8a8080e7          	jalr	-1880(ra) # 80004728 <filedup>
    80001e88:	00a93023          	sd	a0,0(s2)
    80001e8c:	b7e5                	j	80001e74 <fork+0xa4>
  np->cwd = idup(p->cwd);
    80001e8e:	150ab503          	ld	a0,336(s5)
    80001e92:	00002097          	auipc	ra,0x2
    80001e96:	a16080e7          	jalr	-1514(ra) # 800038a8 <idup>
    80001e9a:	14aa3823          	sd	a0,336(s4)
  safestrcpy(np->name, p->name, sizeof(p->name));
    80001e9e:	4641                	li	a2,16
    80001ea0:	158a8593          	addi	a1,s5,344
    80001ea4:	158a0513          	addi	a0,s4,344
    80001ea8:	fffff097          	auipc	ra,0xfffff
    80001eac:	f74080e7          	jalr	-140(ra) # 80000e1c <safestrcpy>
  pid = np->pid;
    80001eb0:	030a2903          	lw	s2,48(s4)
  release(&np->lock);
    80001eb4:	8552                	mv	a0,s4
    80001eb6:	fffff097          	auipc	ra,0xfffff
    80001eba:	dd4080e7          	jalr	-556(ra) # 80000c8a <release>
  acquire(&wait_lock);
    80001ebe:	0000f497          	auipc	s1,0xf
    80001ec2:	cba48493          	addi	s1,s1,-838 # 80010b78 <wait_lock>
    80001ec6:	8526                	mv	a0,s1
    80001ec8:	fffff097          	auipc	ra,0xfffff
    80001ecc:	d0e080e7          	jalr	-754(ra) # 80000bd6 <acquire>
  np->parent = p;
    80001ed0:	035a3c23          	sd	s5,56(s4)
  release(&wait_lock);
    80001ed4:	8526                	mv	a0,s1
    80001ed6:	fffff097          	auipc	ra,0xfffff
    80001eda:	db4080e7          	jalr	-588(ra) # 80000c8a <release>
  acquire(&np->lock);
    80001ede:	8552                	mv	a0,s4
    80001ee0:	fffff097          	auipc	ra,0xfffff
    80001ee4:	cf6080e7          	jalr	-778(ra) # 80000bd6 <acquire>
  np->state = RUNNABLE;
    80001ee8:	478d                	li	a5,3
    80001eea:	00fa2c23          	sw	a5,24(s4)
  release(&np->lock);
    80001eee:	8552                	mv	a0,s4
    80001ef0:	fffff097          	auipc	ra,0xfffff
    80001ef4:	d9a080e7          	jalr	-614(ra) # 80000c8a <release>
}
    80001ef8:	854a                	mv	a0,s2
    80001efa:	70e2                	ld	ra,56(sp)
    80001efc:	7442                	ld	s0,48(sp)
    80001efe:	74a2                	ld	s1,40(sp)
    80001f00:	7902                	ld	s2,32(sp)
    80001f02:	69e2                	ld	s3,24(sp)
    80001f04:	6a42                	ld	s4,16(sp)
    80001f06:	6aa2                	ld	s5,8(sp)
    80001f08:	6121                	addi	sp,sp,64
    80001f0a:	8082                	ret
    return -1;
    80001f0c:	597d                	li	s2,-1
    80001f0e:	b7ed                	j	80001ef8 <fork+0x128>

0000000080001f10 <scheduler>:
{
    80001f10:	7139                	addi	sp,sp,-64
    80001f12:	fc06                	sd	ra,56(sp)
    80001f14:	f822                	sd	s0,48(sp)
    80001f16:	f426                	sd	s1,40(sp)
    80001f18:	f04a                	sd	s2,32(sp)
    80001f1a:	ec4e                	sd	s3,24(sp)
    80001f1c:	e852                	sd	s4,16(sp)
    80001f1e:	e456                	sd	s5,8(sp)
    80001f20:	e05a                	sd	s6,0(sp)
    80001f22:	0080                	addi	s0,sp,64
    80001f24:	8792                	mv	a5,tp
  int id = r_tp();
    80001f26:	2781                	sext.w	a5,a5
  c->proc = 0;
    80001f28:	00779a93          	slli	s5,a5,0x7
    80001f2c:	0000f717          	auipc	a4,0xf
    80001f30:	c3470713          	addi	a4,a4,-972 # 80010b60 <pid_lock>
    80001f34:	9756                	add	a4,a4,s5
    80001f36:	02073823          	sd	zero,48(a4)
        swtch(&c->context, &p->context);
    80001f3a:	0000f717          	auipc	a4,0xf
    80001f3e:	c5e70713          	addi	a4,a4,-930 # 80010b98 <cpus+0x8>
    80001f42:	9aba                	add	s5,s5,a4
      if(p->state == RUNNABLE) {
    80001f44:	498d                	li	s3,3
        p->state = RUNNING;
    80001f46:	4b11                	li	s6,4
        c->proc = p;
    80001f48:	079e                	slli	a5,a5,0x7
    80001f4a:	0000fa17          	auipc	s4,0xf
    80001f4e:	c16a0a13          	addi	s4,s4,-1002 # 80010b60 <pid_lock>
    80001f52:	9a3e                	add	s4,s4,a5
    for(p = proc; p < &proc[NPROC]; p++) {
    80001f54:	00015917          	auipc	s2,0x15
    80001f58:	c5490913          	addi	s2,s2,-940 # 80016ba8 <tickslock>
  asm volatile("csrr %0, sstatus" : "=r" (x) );
    80001f5c:	100027f3          	csrr	a5,sstatus
  w_sstatus(r_sstatus() | SSTATUS_SIE);
    80001f60:	0027e793          	ori	a5,a5,2
  asm volatile("csrw sstatus, %0" : : "r" (x));
    80001f64:	10079073          	csrw	sstatus,a5
    80001f68:	0000f497          	auipc	s1,0xf
    80001f6c:	04048493          	addi	s1,s1,64 # 80010fa8 <proc>
    80001f70:	a811                	j	80001f84 <scheduler+0x74>
      release(&p->lock);
    80001f72:	8526                	mv	a0,s1
    80001f74:	fffff097          	auipc	ra,0xfffff
    80001f78:	d16080e7          	jalr	-746(ra) # 80000c8a <release>
    for(p = proc; p < &proc[NPROC]; p++) {
    80001f7c:	17048493          	addi	s1,s1,368
    80001f80:	fd248ee3          	beq	s1,s2,80001f5c <scheduler+0x4c>
      acquire(&p->lock);
    80001f84:	8526                	mv	a0,s1
    80001f86:	fffff097          	auipc	ra,0xfffff
    80001f8a:	c50080e7          	jalr	-944(ra) # 80000bd6 <acquire>
      if(p->state == RUNNABLE) {
    80001f8e:	4c9c                	lw	a5,24(s1)
    80001f90:	ff3791e3          	bne	a5,s3,80001f72 <scheduler+0x62>
        p->state = RUNNING;
    80001f94:	0164ac23          	sw	s6,24(s1)
        c->proc = p;
    80001f98:	029a3823          	sd	s1,48(s4)
        swtch(&c->context, &p->context);
    80001f9c:	06048593          	addi	a1,s1,96
    80001fa0:	8556                	mv	a0,s5
    80001fa2:	00001097          	auipc	ra,0x1
    80001fa6:	880080e7          	jalr	-1920(ra) # 80002822 <swtch>
        c->proc = 0;
    80001faa:	020a3823          	sd	zero,48(s4)
    80001fae:	b7d1                	j	80001f72 <scheduler+0x62>

0000000080001fb0 <sched>:
{
    80001fb0:	7179                	addi	sp,sp,-48
    80001fb2:	f406                	sd	ra,40(sp)
    80001fb4:	f022                	sd	s0,32(sp)
    80001fb6:	ec26                	sd	s1,24(sp)
    80001fb8:	e84a                	sd	s2,16(sp)
    80001fba:	e44e                	sd	s3,8(sp)
    80001fbc:	1800                	addi	s0,sp,48
  struct proc *p = myproc();
    80001fbe:	00000097          	auipc	ra,0x0
    80001fc2:	9ee080e7          	jalr	-1554(ra) # 800019ac <myproc>
    80001fc6:	84aa                	mv	s1,a0
  if(!holding(&p->lock))
    80001fc8:	fffff097          	auipc	ra,0xfffff
    80001fcc:	b94080e7          	jalr	-1132(ra) # 80000b5c <holding>
    80001fd0:	c93d                	beqz	a0,80002046 <sched+0x96>
  asm volatile("mv %0, tp" : "=r" (x) );
    80001fd2:	8792                	mv	a5,tp
  if(mycpu()->noff != 1)
    80001fd4:	2781                	sext.w	a5,a5
    80001fd6:	079e                	slli	a5,a5,0x7
    80001fd8:	0000f717          	auipc	a4,0xf
    80001fdc:	b8870713          	addi	a4,a4,-1144 # 80010b60 <pid_lock>
    80001fe0:	97ba                	add	a5,a5,a4
    80001fe2:	0a87a703          	lw	a4,168(a5)
    80001fe6:	4785                	li	a5,1
    80001fe8:	06f71763          	bne	a4,a5,80002056 <sched+0xa6>
  if(p->state == RUNNING)
    80001fec:	4c98                	lw	a4,24(s1)
    80001fee:	4791                	li	a5,4
    80001ff0:	06f70b63          	beq	a4,a5,80002066 <sched+0xb6>
  asm volatile("csrr %0, sstatus" : "=r" (x) );
    80001ff4:	100027f3          	csrr	a5,sstatus
  return (x & SSTATUS_SIE) != 0;
    80001ff8:	8b89                	andi	a5,a5,2
  if(intr_get())
    80001ffa:	efb5                	bnez	a5,80002076 <sched+0xc6>
  asm volatile("mv %0, tp" : "=r" (x) );
    80001ffc:	8792                	mv	a5,tp
  intena = mycpu()->intena;
    80001ffe:	0000f917          	auipc	s2,0xf
    80002002:	b6290913          	addi	s2,s2,-1182 # 80010b60 <pid_lock>
    80002006:	2781                	sext.w	a5,a5
    80002008:	079e                	slli	a5,a5,0x7
    8000200a:	97ca                	add	a5,a5,s2
    8000200c:	0ac7a983          	lw	s3,172(a5)
    80002010:	8792                	mv	a5,tp
  swtch(&p->context, &mycpu()->context);
    80002012:	2781                	sext.w	a5,a5
    80002014:	079e                	slli	a5,a5,0x7
    80002016:	0000f597          	auipc	a1,0xf
    8000201a:	b8258593          	addi	a1,a1,-1150 # 80010b98 <cpus+0x8>
    8000201e:	95be                	add	a1,a1,a5
    80002020:	06048513          	addi	a0,s1,96
    80002024:	00000097          	auipc	ra,0x0
    80002028:	7fe080e7          	jalr	2046(ra) # 80002822 <swtch>
    8000202c:	8792                	mv	a5,tp
  mycpu()->intena = intena;
    8000202e:	2781                	sext.w	a5,a5
    80002030:	079e                	slli	a5,a5,0x7
    80002032:	993e                	add	s2,s2,a5
    80002034:	0b392623          	sw	s3,172(s2)
}
    80002038:	70a2                	ld	ra,40(sp)
    8000203a:	7402                	ld	s0,32(sp)
    8000203c:	64e2                	ld	s1,24(sp)
    8000203e:	6942                	ld	s2,16(sp)
    80002040:	69a2                	ld	s3,8(sp)
    80002042:	6145                	addi	sp,sp,48
    80002044:	8082                	ret
    panic("sched p->lock");
    80002046:	00006517          	auipc	a0,0x6
    8000204a:	1d250513          	addi	a0,a0,466 # 80008218 <digits+0x1d8>
    8000204e:	ffffe097          	auipc	ra,0xffffe
    80002052:	4f2080e7          	jalr	1266(ra) # 80000540 <panic>
    panic("sched locks");
    80002056:	00006517          	auipc	a0,0x6
    8000205a:	1d250513          	addi	a0,a0,466 # 80008228 <digits+0x1e8>
    8000205e:	ffffe097          	auipc	ra,0xffffe
    80002062:	4e2080e7          	jalr	1250(ra) # 80000540 <panic>
    panic("sched running");
    80002066:	00006517          	auipc	a0,0x6
    8000206a:	1d250513          	addi	a0,a0,466 # 80008238 <digits+0x1f8>
    8000206e:	ffffe097          	auipc	ra,0xffffe
    80002072:	4d2080e7          	jalr	1234(ra) # 80000540 <panic>
    panic("sched interruptible");
    80002076:	00006517          	auipc	a0,0x6
    8000207a:	1d250513          	addi	a0,a0,466 # 80008248 <digits+0x208>
    8000207e:	ffffe097          	auipc	ra,0xffffe
    80002082:	4c2080e7          	jalr	1218(ra) # 80000540 <panic>

0000000080002086 <yield>:
{
    80002086:	1101                	addi	sp,sp,-32
    80002088:	ec06                	sd	ra,24(sp)
    8000208a:	e822                	sd	s0,16(sp)
    8000208c:	e426                	sd	s1,8(sp)
    8000208e:	1000                	addi	s0,sp,32
  struct proc *p = myproc();
    80002090:	00000097          	auipc	ra,0x0
    80002094:	91c080e7          	jalr	-1764(ra) # 800019ac <myproc>
    80002098:	84aa                	mv	s1,a0
  acquire(&p->lock);
    8000209a:	fffff097          	auipc	ra,0xfffff
    8000209e:	b3c080e7          	jalr	-1220(ra) # 80000bd6 <acquire>
  p->state = RUNNABLE;
    800020a2:	478d                	li	a5,3
    800020a4:	cc9c                	sw	a5,24(s1)
  sched();
    800020a6:	00000097          	auipc	ra,0x0
    800020aa:	f0a080e7          	jalr	-246(ra) # 80001fb0 <sched>
  release(&p->lock);
    800020ae:	8526                	mv	a0,s1
    800020b0:	fffff097          	auipc	ra,0xfffff
    800020b4:	bda080e7          	jalr	-1062(ra) # 80000c8a <release>
}
    800020b8:	60e2                	ld	ra,24(sp)
    800020ba:	6442                	ld	s0,16(sp)
    800020bc:	64a2                	ld	s1,8(sp)
    800020be:	6105                	addi	sp,sp,32
    800020c0:	8082                	ret

00000000800020c2 <sleep>:

// Atomically release lock and sleep on chan.
// Reacquires lock when awakened.
void
sleep(void *chan, struct spinlock *lk)
{
    800020c2:	7179                	addi	sp,sp,-48
    800020c4:	f406                	sd	ra,40(sp)
    800020c6:	f022                	sd	s0,32(sp)
    800020c8:	ec26                	sd	s1,24(sp)
    800020ca:	e84a                	sd	s2,16(sp)
    800020cc:	e44e                	sd	s3,8(sp)
    800020ce:	1800                	addi	s0,sp,48
    800020d0:	89aa                	mv	s3,a0
    800020d2:	892e                	mv	s2,a1
  struct proc *p = myproc();
    800020d4:	00000097          	auipc	ra,0x0
    800020d8:	8d8080e7          	jalr	-1832(ra) # 800019ac <myproc>
    800020dc:	84aa                	mv	s1,a0
  // Once we hold p->lock, we can be
  // guaranteed that we won't miss any wakeup
  // (wakeup locks p->lock),
  // so it's okay to release lk.

  acquire(&p->lock);  //DOC: sleeplock1
    800020de:	fffff097          	auipc	ra,0xfffff
    800020e2:	af8080e7          	jalr	-1288(ra) # 80000bd6 <acquire>
  release(lk);
    800020e6:	854a                	mv	a0,s2
    800020e8:	fffff097          	auipc	ra,0xfffff
    800020ec:	ba2080e7          	jalr	-1118(ra) # 80000c8a <release>

  // Go to sleep.
  p->chan = chan;
    800020f0:	0334b023          	sd	s3,32(s1)
  p->state = SLEEPING;
    800020f4:	4789                	li	a5,2
    800020f6:	cc9c                	sw	a5,24(s1)

  sched();
    800020f8:	00000097          	auipc	ra,0x0
    800020fc:	eb8080e7          	jalr	-328(ra) # 80001fb0 <sched>

  // Tidy up.
  p->chan = 0;
    80002100:	0204b023          	sd	zero,32(s1)

  // Reacquire original lock.
  release(&p->lock);
    80002104:	8526                	mv	a0,s1
    80002106:	fffff097          	auipc	ra,0xfffff
    8000210a:	b84080e7          	jalr	-1148(ra) # 80000c8a <release>
  acquire(lk);
    8000210e:	854a                	mv	a0,s2
    80002110:	fffff097          	auipc	ra,0xfffff
    80002114:	ac6080e7          	jalr	-1338(ra) # 80000bd6 <acquire>
}
    80002118:	70a2                	ld	ra,40(sp)
    8000211a:	7402                	ld	s0,32(sp)
    8000211c:	64e2                	ld	s1,24(sp)
    8000211e:	6942                	ld	s2,16(sp)
    80002120:	69a2                	ld	s3,8(sp)
    80002122:	6145                	addi	sp,sp,48
    80002124:	8082                	ret

0000000080002126 <wakeup>:

// Wake up all processes sleeping on chan.
// Must be called without any p->lock.
void
wakeup(void *chan)
{
    80002126:	7139                	addi	sp,sp,-64
    80002128:	fc06                	sd	ra,56(sp)
    8000212a:	f822                	sd	s0,48(sp)
    8000212c:	f426                	sd	s1,40(sp)
    8000212e:	f04a                	sd	s2,32(sp)
    80002130:	ec4e                	sd	s3,24(sp)
    80002132:	e852                	sd	s4,16(sp)
    80002134:	e456                	sd	s5,8(sp)
    80002136:	0080                	addi	s0,sp,64
    80002138:	8a2a                	mv	s4,a0
  struct proc *p;

  for(p = proc; p < &proc[NPROC]; p++) {
    8000213a:	0000f497          	auipc	s1,0xf
    8000213e:	e6e48493          	addi	s1,s1,-402 # 80010fa8 <proc>
    if(p != myproc()){
      acquire(&p->lock);
      if(p->state == SLEEPING && p->chan == chan) {
    80002142:	4989                	li	s3,2
        p->state = RUNNABLE;
    80002144:	4a8d                	li	s5,3
  for(p = proc; p < &proc[NPROC]; p++) {
    80002146:	00015917          	auipc	s2,0x15
    8000214a:	a6290913          	addi	s2,s2,-1438 # 80016ba8 <tickslock>
    8000214e:	a811                	j	80002162 <wakeup+0x3c>
      }
      release(&p->lock);
    80002150:	8526                	mv	a0,s1
    80002152:	fffff097          	auipc	ra,0xfffff
    80002156:	b38080e7          	jalr	-1224(ra) # 80000c8a <release>
  for(p = proc; p < &proc[NPROC]; p++) {
    8000215a:	17048493          	addi	s1,s1,368
    8000215e:	03248663          	beq	s1,s2,8000218a <wakeup+0x64>
    if(p != myproc()){
    80002162:	00000097          	auipc	ra,0x0
    80002166:	84a080e7          	jalr	-1974(ra) # 800019ac <myproc>
    8000216a:	fea488e3          	beq	s1,a0,8000215a <wakeup+0x34>
      acquire(&p->lock);
    8000216e:	8526                	mv	a0,s1
    80002170:	fffff097          	auipc	ra,0xfffff
    80002174:	a66080e7          	jalr	-1434(ra) # 80000bd6 <acquire>
      if(p->state == SLEEPING && p->chan == chan) {
    80002178:	4c9c                	lw	a5,24(s1)
    8000217a:	fd379be3          	bne	a5,s3,80002150 <wakeup+0x2a>
    8000217e:	709c                	ld	a5,32(s1)
    80002180:	fd4798e3          	bne	a5,s4,80002150 <wakeup+0x2a>
        p->state = RUNNABLE;
    80002184:	0154ac23          	sw	s5,24(s1)
    80002188:	b7e1                	j	80002150 <wakeup+0x2a>
    }
  }
}
    8000218a:	70e2                	ld	ra,56(sp)
    8000218c:	7442                	ld	s0,48(sp)
    8000218e:	74a2                	ld	s1,40(sp)
    80002190:	7902                	ld	s2,32(sp)
    80002192:	69e2                	ld	s3,24(sp)
    80002194:	6a42                	ld	s4,16(sp)
    80002196:	6aa2                	ld	s5,8(sp)
    80002198:	6121                	addi	sp,sp,64
    8000219a:	8082                	ret

000000008000219c <reparent>:
{
    8000219c:	7179                	addi	sp,sp,-48
    8000219e:	f406                	sd	ra,40(sp)
    800021a0:	f022                	sd	s0,32(sp)
    800021a2:	ec26                	sd	s1,24(sp)
    800021a4:	e84a                	sd	s2,16(sp)
    800021a6:	e44e                	sd	s3,8(sp)
    800021a8:	e052                	sd	s4,0(sp)
    800021aa:	1800                	addi	s0,sp,48
    800021ac:	892a                	mv	s2,a0
  for(pp = proc; pp < &proc[NPROC]; pp++){
    800021ae:	0000f497          	auipc	s1,0xf
    800021b2:	dfa48493          	addi	s1,s1,-518 # 80010fa8 <proc>
      pp->parent = initproc;
    800021b6:	00006a17          	auipc	s4,0x6
    800021ba:	732a0a13          	addi	s4,s4,1842 # 800088e8 <initproc>
  for(pp = proc; pp < &proc[NPROC]; pp++){
    800021be:	00015997          	auipc	s3,0x15
    800021c2:	9ea98993          	addi	s3,s3,-1558 # 80016ba8 <tickslock>
    800021c6:	a029                	j	800021d0 <reparent+0x34>
    800021c8:	17048493          	addi	s1,s1,368
    800021cc:	01348d63          	beq	s1,s3,800021e6 <reparent+0x4a>
    if(pp->parent == p){
    800021d0:	7c9c                	ld	a5,56(s1)
    800021d2:	ff279be3          	bne	a5,s2,800021c8 <reparent+0x2c>
      pp->parent = initproc;
    800021d6:	000a3503          	ld	a0,0(s4)
    800021da:	fc88                	sd	a0,56(s1)
      wakeup(initproc);
    800021dc:	00000097          	auipc	ra,0x0
    800021e0:	f4a080e7          	jalr	-182(ra) # 80002126 <wakeup>
    800021e4:	b7d5                	j	800021c8 <reparent+0x2c>
}
    800021e6:	70a2                	ld	ra,40(sp)
    800021e8:	7402                	ld	s0,32(sp)
    800021ea:	64e2                	ld	s1,24(sp)
    800021ec:	6942                	ld	s2,16(sp)
    800021ee:	69a2                	ld	s3,8(sp)
    800021f0:	6a02                	ld	s4,0(sp)
    800021f2:	6145                	addi	sp,sp,48
    800021f4:	8082                	ret

00000000800021f6 <exit>:
{
    800021f6:	7179                	addi	sp,sp,-48
    800021f8:	f406                	sd	ra,40(sp)
    800021fa:	f022                	sd	s0,32(sp)
    800021fc:	ec26                	sd	s1,24(sp)
    800021fe:	e84a                	sd	s2,16(sp)
    80002200:	e44e                	sd	s3,8(sp)
    80002202:	e052                	sd	s4,0(sp)
    80002204:	1800                	addi	s0,sp,48
    80002206:	8a2a                	mv	s4,a0
  struct proc *p = myproc();
    80002208:	fffff097          	auipc	ra,0xfffff
    8000220c:	7a4080e7          	jalr	1956(ra) # 800019ac <myproc>
  if(p == initproc)
    80002210:	00006797          	auipc	a5,0x6
    80002214:	6d87b783          	ld	a5,1752(a5) # 800088e8 <initproc>
    80002218:	00a78b63          	beq	a5,a0,8000222e <exit+0x38>
    8000221c:	892a                	mv	s2,a0
  if(p->thread_id== 0)
    8000221e:	16852783          	lw	a5,360(a0)
    80002222:	eb95                	bnez	a5,80002256 <exit+0x60>
    80002224:	0d050493          	addi	s1,a0,208
    80002228:	15050993          	addi	s3,a0,336
    8000222c:	a015                	j	80002250 <exit+0x5a>
    panic("init exiting");
    8000222e:	00006517          	auipc	a0,0x6
    80002232:	03250513          	addi	a0,a0,50 # 80008260 <digits+0x220>
    80002236:	ffffe097          	auipc	ra,0xffffe
    8000223a:	30a080e7          	jalr	778(ra) # 80000540 <panic>
        fileclose(f);
    8000223e:	00002097          	auipc	ra,0x2
    80002242:	53c080e7          	jalr	1340(ra) # 8000477a <fileclose>
        p->ofile[fd] = 0;
    80002246:	0004b023          	sd	zero,0(s1)
    for(int fd = 0; fd < NOFILE; fd++){
    8000224a:	04a1                	addi	s1,s1,8
    8000224c:	01348563          	beq	s1,s3,80002256 <exit+0x60>
      if(p->ofile[fd]){
    80002250:	6088                	ld	a0,0(s1)
    80002252:	f575                	bnez	a0,8000223e <exit+0x48>
    80002254:	bfdd                	j	8000224a <exit+0x54>
  begin_op();
    80002256:	00002097          	auipc	ra,0x2
    8000225a:	05c080e7          	jalr	92(ra) # 800042b2 <begin_op>
  iput(p->cwd);
    8000225e:	15093503          	ld	a0,336(s2)
    80002262:	00002097          	auipc	ra,0x2
    80002266:	83e080e7          	jalr	-1986(ra) # 80003aa0 <iput>
  end_op();
    8000226a:	00002097          	auipc	ra,0x2
    8000226e:	0c6080e7          	jalr	198(ra) # 80004330 <end_op>
  p->cwd = 0;
    80002272:	14093823          	sd	zero,336(s2)
  acquire(&wait_lock);
    80002276:	0000f497          	auipc	s1,0xf
    8000227a:	90248493          	addi	s1,s1,-1790 # 80010b78 <wait_lock>
    8000227e:	8526                	mv	a0,s1
    80002280:	fffff097          	auipc	ra,0xfffff
    80002284:	956080e7          	jalr	-1706(ra) # 80000bd6 <acquire>
  reparent(p);
    80002288:	854a                	mv	a0,s2
    8000228a:	00000097          	auipc	ra,0x0
    8000228e:	f12080e7          	jalr	-238(ra) # 8000219c <reparent>
  wakeup(p->parent);
    80002292:	03893503          	ld	a0,56(s2)
    80002296:	00000097          	auipc	ra,0x0
    8000229a:	e90080e7          	jalr	-368(ra) # 80002126 <wakeup>
  acquire(&p->lock);
    8000229e:	854a                	mv	a0,s2
    800022a0:	fffff097          	auipc	ra,0xfffff
    800022a4:	936080e7          	jalr	-1738(ra) # 80000bd6 <acquire>
  p->xstate = status;
    800022a8:	03492623          	sw	s4,44(s2)
  p->state = ZOMBIE;
    800022ac:	4795                	li	a5,5
    800022ae:	00f92c23          	sw	a5,24(s2)
  release(&wait_lock);
    800022b2:	8526                	mv	a0,s1
    800022b4:	fffff097          	auipc	ra,0xfffff
    800022b8:	9d6080e7          	jalr	-1578(ra) # 80000c8a <release>
  sched();
    800022bc:	00000097          	auipc	ra,0x0
    800022c0:	cf4080e7          	jalr	-780(ra) # 80001fb0 <sched>
  panic("zombie exit");
    800022c4:	00006517          	auipc	a0,0x6
    800022c8:	fac50513          	addi	a0,a0,-84 # 80008270 <digits+0x230>
    800022cc:	ffffe097          	auipc	ra,0xffffe
    800022d0:	274080e7          	jalr	628(ra) # 80000540 <panic>

00000000800022d4 <kill>:
// Kill the process with the given pid.
// The victim won't exit until it tries to return
// to user space (see usertrap() in trap.c).
int
kill(int pid)
{
    800022d4:	7179                	addi	sp,sp,-48
    800022d6:	f406                	sd	ra,40(sp)
    800022d8:	f022                	sd	s0,32(sp)
    800022da:	ec26                	sd	s1,24(sp)
    800022dc:	e84a                	sd	s2,16(sp)
    800022de:	e44e                	sd	s3,8(sp)
    800022e0:	1800                	addi	s0,sp,48
    800022e2:	892a                	mv	s2,a0
  struct proc *p;

  for(p = proc; p < &proc[NPROC]; p++){
    800022e4:	0000f497          	auipc	s1,0xf
    800022e8:	cc448493          	addi	s1,s1,-828 # 80010fa8 <proc>
    800022ec:	00015997          	auipc	s3,0x15
    800022f0:	8bc98993          	addi	s3,s3,-1860 # 80016ba8 <tickslock>
    acquire(&p->lock);
    800022f4:	8526                	mv	a0,s1
    800022f6:	fffff097          	auipc	ra,0xfffff
    800022fa:	8e0080e7          	jalr	-1824(ra) # 80000bd6 <acquire>
    if(p->pid == pid){
    800022fe:	589c                	lw	a5,48(s1)
    80002300:	01278d63          	beq	a5,s2,8000231a <kill+0x46>
        p->state = RUNNABLE;
      }
      release(&p->lock);
      return 0;
    }
    release(&p->lock);
    80002304:	8526                	mv	a0,s1
    80002306:	fffff097          	auipc	ra,0xfffff
    8000230a:	984080e7          	jalr	-1660(ra) # 80000c8a <release>
  for(p = proc; p < &proc[NPROC]; p++){
    8000230e:	17048493          	addi	s1,s1,368
    80002312:	ff3491e3          	bne	s1,s3,800022f4 <kill+0x20>
  }
  return -1;
    80002316:	557d                	li	a0,-1
    80002318:	a829                	j	80002332 <kill+0x5e>
      p->killed = 1;
    8000231a:	4785                	li	a5,1
    8000231c:	d49c                	sw	a5,40(s1)
      if(p->state == SLEEPING){
    8000231e:	4c98                	lw	a4,24(s1)
    80002320:	4789                	li	a5,2
    80002322:	00f70f63          	beq	a4,a5,80002340 <kill+0x6c>
      release(&p->lock);
    80002326:	8526                	mv	a0,s1
    80002328:	fffff097          	auipc	ra,0xfffff
    8000232c:	962080e7          	jalr	-1694(ra) # 80000c8a <release>
      return 0;
    80002330:	4501                	li	a0,0
}
    80002332:	70a2                	ld	ra,40(sp)
    80002334:	7402                	ld	s0,32(sp)
    80002336:	64e2                	ld	s1,24(sp)
    80002338:	6942                	ld	s2,16(sp)
    8000233a:	69a2                	ld	s3,8(sp)
    8000233c:	6145                	addi	sp,sp,48
    8000233e:	8082                	ret
        p->state = RUNNABLE;
    80002340:	478d                	li	a5,3
    80002342:	cc9c                	sw	a5,24(s1)
    80002344:	b7cd                	j	80002326 <kill+0x52>

0000000080002346 <setkilled>:

void
setkilled(struct proc *p)
{
    80002346:	1101                	addi	sp,sp,-32
    80002348:	ec06                	sd	ra,24(sp)
    8000234a:	e822                	sd	s0,16(sp)
    8000234c:	e426                	sd	s1,8(sp)
    8000234e:	1000                	addi	s0,sp,32
    80002350:	84aa                	mv	s1,a0
  acquire(&p->lock);
    80002352:	fffff097          	auipc	ra,0xfffff
    80002356:	884080e7          	jalr	-1916(ra) # 80000bd6 <acquire>
  p->killed = 1;
    8000235a:	4785                	li	a5,1
    8000235c:	d49c                	sw	a5,40(s1)
  release(&p->lock);
    8000235e:	8526                	mv	a0,s1
    80002360:	fffff097          	auipc	ra,0xfffff
    80002364:	92a080e7          	jalr	-1750(ra) # 80000c8a <release>
}
    80002368:	60e2                	ld	ra,24(sp)
    8000236a:	6442                	ld	s0,16(sp)
    8000236c:	64a2                	ld	s1,8(sp)
    8000236e:	6105                	addi	sp,sp,32
    80002370:	8082                	ret

0000000080002372 <killed>:

int
killed(struct proc *p)
{
    80002372:	1101                	addi	sp,sp,-32
    80002374:	ec06                	sd	ra,24(sp)
    80002376:	e822                	sd	s0,16(sp)
    80002378:	e426                	sd	s1,8(sp)
    8000237a:	e04a                	sd	s2,0(sp)
    8000237c:	1000                	addi	s0,sp,32
    8000237e:	84aa                	mv	s1,a0
  int k;
  
  acquire(&p->lock);
    80002380:	fffff097          	auipc	ra,0xfffff
    80002384:	856080e7          	jalr	-1962(ra) # 80000bd6 <acquire>
  k = p->killed;
    80002388:	0284a903          	lw	s2,40(s1)
  release(&p->lock);
    8000238c:	8526                	mv	a0,s1
    8000238e:	fffff097          	auipc	ra,0xfffff
    80002392:	8fc080e7          	jalr	-1796(ra) # 80000c8a <release>
  return k;
}
    80002396:	854a                	mv	a0,s2
    80002398:	60e2                	ld	ra,24(sp)
    8000239a:	6442                	ld	s0,16(sp)
    8000239c:	64a2                	ld	s1,8(sp)
    8000239e:	6902                	ld	s2,0(sp)
    800023a0:	6105                	addi	sp,sp,32
    800023a2:	8082                	ret

00000000800023a4 <wait>:
{
    800023a4:	715d                	addi	sp,sp,-80
    800023a6:	e486                	sd	ra,72(sp)
    800023a8:	e0a2                	sd	s0,64(sp)
    800023aa:	fc26                	sd	s1,56(sp)
    800023ac:	f84a                	sd	s2,48(sp)
    800023ae:	f44e                	sd	s3,40(sp)
    800023b0:	f052                	sd	s4,32(sp)
    800023b2:	ec56                	sd	s5,24(sp)
    800023b4:	e85a                	sd	s6,16(sp)
    800023b6:	e45e                	sd	s7,8(sp)
    800023b8:	e062                	sd	s8,0(sp)
    800023ba:	0880                	addi	s0,sp,80
    800023bc:	8b2a                	mv	s6,a0
  struct proc *p = myproc();
    800023be:	fffff097          	auipc	ra,0xfffff
    800023c2:	5ee080e7          	jalr	1518(ra) # 800019ac <myproc>
    800023c6:	892a                	mv	s2,a0
  acquire(&wait_lock);
    800023c8:	0000e517          	auipc	a0,0xe
    800023cc:	7b050513          	addi	a0,a0,1968 # 80010b78 <wait_lock>
    800023d0:	fffff097          	auipc	ra,0xfffff
    800023d4:	806080e7          	jalr	-2042(ra) # 80000bd6 <acquire>
    havekids = 0;
    800023d8:	4b81                	li	s7,0
        if(pp->state == ZOMBIE){
    800023da:	4a15                	li	s4,5
        havekids = 1;
    800023dc:	4a85                	li	s5,1
    for(pp = proc; pp < &proc[NPROC]; pp++){
    800023de:	00014997          	auipc	s3,0x14
    800023e2:	7ca98993          	addi	s3,s3,1994 # 80016ba8 <tickslock>
    sleep(p, &wait_lock);  //DOC: wait-sleep
    800023e6:	0000ec17          	auipc	s8,0xe
    800023ea:	792c0c13          	addi	s8,s8,1938 # 80010b78 <wait_lock>
    havekids = 0;
    800023ee:	875e                	mv	a4,s7
    for(pp = proc; pp < &proc[NPROC]; pp++){
    800023f0:	0000f497          	auipc	s1,0xf
    800023f4:	bb848493          	addi	s1,s1,-1096 # 80010fa8 <proc>
    800023f8:	a0bd                	j	80002466 <wait+0xc2>
          pid = pp->pid;
    800023fa:	0304a983          	lw	s3,48(s1)
          if(addr != 0 && copyout(p->pagetable, addr, (char *)&pp->xstate,
    800023fe:	000b0e63          	beqz	s6,8000241a <wait+0x76>
    80002402:	4691                	li	a3,4
    80002404:	02c48613          	addi	a2,s1,44
    80002408:	85da                	mv	a1,s6
    8000240a:	05093503          	ld	a0,80(s2)
    8000240e:	fffff097          	auipc	ra,0xfffff
    80002412:	25e080e7          	jalr	606(ra) # 8000166c <copyout>
    80002416:	02054563          	bltz	a0,80002440 <wait+0x9c>
          freeproc(pp);
    8000241a:	8526                	mv	a0,s1
    8000241c:	fffff097          	auipc	ra,0xfffff
    80002420:	788080e7          	jalr	1928(ra) # 80001ba4 <freeproc>
          release(&pp->lock);
    80002424:	8526                	mv	a0,s1
    80002426:	fffff097          	auipc	ra,0xfffff
    8000242a:	864080e7          	jalr	-1948(ra) # 80000c8a <release>
          release(&wait_lock);
    8000242e:	0000e517          	auipc	a0,0xe
    80002432:	74a50513          	addi	a0,a0,1866 # 80010b78 <wait_lock>
    80002436:	fffff097          	auipc	ra,0xfffff
    8000243a:	854080e7          	jalr	-1964(ra) # 80000c8a <release>
          return pid;
    8000243e:	a0b5                	j	800024aa <wait+0x106>
            release(&pp->lock);
    80002440:	8526                	mv	a0,s1
    80002442:	fffff097          	auipc	ra,0xfffff
    80002446:	848080e7          	jalr	-1976(ra) # 80000c8a <release>
            release(&wait_lock);
    8000244a:	0000e517          	auipc	a0,0xe
    8000244e:	72e50513          	addi	a0,a0,1838 # 80010b78 <wait_lock>
    80002452:	fffff097          	auipc	ra,0xfffff
    80002456:	838080e7          	jalr	-1992(ra) # 80000c8a <release>
            return -1;
    8000245a:	59fd                	li	s3,-1
    8000245c:	a0b9                	j	800024aa <wait+0x106>
    for(pp = proc; pp < &proc[NPROC]; pp++){
    8000245e:	17048493          	addi	s1,s1,368
    80002462:	03348463          	beq	s1,s3,8000248a <wait+0xe6>
      if(pp->parent == p){
    80002466:	7c9c                	ld	a5,56(s1)
    80002468:	ff279be3          	bne	a5,s2,8000245e <wait+0xba>
        acquire(&pp->lock);
    8000246c:	8526                	mv	a0,s1
    8000246e:	ffffe097          	auipc	ra,0xffffe
    80002472:	768080e7          	jalr	1896(ra) # 80000bd6 <acquire>
        if(pp->state == ZOMBIE){
    80002476:	4c9c                	lw	a5,24(s1)
    80002478:	f94781e3          	beq	a5,s4,800023fa <wait+0x56>
        release(&pp->lock);
    8000247c:	8526                	mv	a0,s1
    8000247e:	fffff097          	auipc	ra,0xfffff
    80002482:	80c080e7          	jalr	-2036(ra) # 80000c8a <release>
        havekids = 1;
    80002486:	8756                	mv	a4,s5
    80002488:	bfd9                	j	8000245e <wait+0xba>
    if(!havekids || killed(p)){
    8000248a:	c719                	beqz	a4,80002498 <wait+0xf4>
    8000248c:	854a                	mv	a0,s2
    8000248e:	00000097          	auipc	ra,0x0
    80002492:	ee4080e7          	jalr	-284(ra) # 80002372 <killed>
    80002496:	c51d                	beqz	a0,800024c4 <wait+0x120>
      release(&wait_lock);
    80002498:	0000e517          	auipc	a0,0xe
    8000249c:	6e050513          	addi	a0,a0,1760 # 80010b78 <wait_lock>
    800024a0:	ffffe097          	auipc	ra,0xffffe
    800024a4:	7ea080e7          	jalr	2026(ra) # 80000c8a <release>
      return -1;
    800024a8:	59fd                	li	s3,-1
}
    800024aa:	854e                	mv	a0,s3
    800024ac:	60a6                	ld	ra,72(sp)
    800024ae:	6406                	ld	s0,64(sp)
    800024b0:	74e2                	ld	s1,56(sp)
    800024b2:	7942                	ld	s2,48(sp)
    800024b4:	79a2                	ld	s3,40(sp)
    800024b6:	7a02                	ld	s4,32(sp)
    800024b8:	6ae2                	ld	s5,24(sp)
    800024ba:	6b42                	ld	s6,16(sp)
    800024bc:	6ba2                	ld	s7,8(sp)
    800024be:	6c02                	ld	s8,0(sp)
    800024c0:	6161                	addi	sp,sp,80
    800024c2:	8082                	ret
    sleep(p, &wait_lock);  //DOC: wait-sleep
    800024c4:	85e2                	mv	a1,s8
    800024c6:	854a                	mv	a0,s2
    800024c8:	00000097          	auipc	ra,0x0
    800024cc:	bfa080e7          	jalr	-1030(ra) # 800020c2 <sleep>
    havekids = 0;
    800024d0:	bf39                	j	800023ee <wait+0x4a>

00000000800024d2 <either_copyout>:
// Copy to either a user address, or kernel address,
// depending on usr_dst.
// Returns 0 on success, -1 on error.
int
either_copyout(int user_dst, uint64 dst, void *src, uint64 len)
{
    800024d2:	7179                	addi	sp,sp,-48
    800024d4:	f406                	sd	ra,40(sp)
    800024d6:	f022                	sd	s0,32(sp)
    800024d8:	ec26                	sd	s1,24(sp)
    800024da:	e84a                	sd	s2,16(sp)
    800024dc:	e44e                	sd	s3,8(sp)
    800024de:	e052                	sd	s4,0(sp)
    800024e0:	1800                	addi	s0,sp,48
    800024e2:	84aa                	mv	s1,a0
    800024e4:	892e                	mv	s2,a1
    800024e6:	89b2                	mv	s3,a2
    800024e8:	8a36                	mv	s4,a3
  struct proc *p = myproc();
    800024ea:	fffff097          	auipc	ra,0xfffff
    800024ee:	4c2080e7          	jalr	1218(ra) # 800019ac <myproc>
  if(user_dst){
    800024f2:	c08d                	beqz	s1,80002514 <either_copyout+0x42>
    return copyout(p->pagetable, dst, src, len);
    800024f4:	86d2                	mv	a3,s4
    800024f6:	864e                	mv	a2,s3
    800024f8:	85ca                	mv	a1,s2
    800024fa:	6928                	ld	a0,80(a0)
    800024fc:	fffff097          	auipc	ra,0xfffff
    80002500:	170080e7          	jalr	368(ra) # 8000166c <copyout>
  } else {
    memmove((char *)dst, src, len);
    return 0;
  }
}
    80002504:	70a2                	ld	ra,40(sp)
    80002506:	7402                	ld	s0,32(sp)
    80002508:	64e2                	ld	s1,24(sp)
    8000250a:	6942                	ld	s2,16(sp)
    8000250c:	69a2                	ld	s3,8(sp)
    8000250e:	6a02                	ld	s4,0(sp)
    80002510:	6145                	addi	sp,sp,48
    80002512:	8082                	ret
    memmove((char *)dst, src, len);
    80002514:	000a061b          	sext.w	a2,s4
    80002518:	85ce                	mv	a1,s3
    8000251a:	854a                	mv	a0,s2
    8000251c:	fffff097          	auipc	ra,0xfffff
    80002520:	812080e7          	jalr	-2030(ra) # 80000d2e <memmove>
    return 0;
    80002524:	8526                	mv	a0,s1
    80002526:	bff9                	j	80002504 <either_copyout+0x32>

0000000080002528 <either_copyin>:
// Copy from either a user address, or kernel address,
// depending on usr_src.
// Returns 0 on success, -1 on error.
int
either_copyin(void *dst, int user_src, uint64 src, uint64 len)
{
    80002528:	7179                	addi	sp,sp,-48
    8000252a:	f406                	sd	ra,40(sp)
    8000252c:	f022                	sd	s0,32(sp)
    8000252e:	ec26                	sd	s1,24(sp)
    80002530:	e84a                	sd	s2,16(sp)
    80002532:	e44e                	sd	s3,8(sp)
    80002534:	e052                	sd	s4,0(sp)
    80002536:	1800                	addi	s0,sp,48
    80002538:	892a                	mv	s2,a0
    8000253a:	84ae                	mv	s1,a1
    8000253c:	89b2                	mv	s3,a2
    8000253e:	8a36                	mv	s4,a3
  struct proc *p = myproc();
    80002540:	fffff097          	auipc	ra,0xfffff
    80002544:	46c080e7          	jalr	1132(ra) # 800019ac <myproc>
  if(user_src){
    80002548:	c08d                	beqz	s1,8000256a <either_copyin+0x42>
    return copyin(p->pagetable, dst, src, len);
    8000254a:	86d2                	mv	a3,s4
    8000254c:	864e                	mv	a2,s3
    8000254e:	85ca                	mv	a1,s2
    80002550:	6928                	ld	a0,80(a0)
    80002552:	fffff097          	auipc	ra,0xfffff
    80002556:	1a6080e7          	jalr	422(ra) # 800016f8 <copyin>
  } else {
    memmove(dst, (char*)src, len);
    return 0;
  }
}
    8000255a:	70a2                	ld	ra,40(sp)
    8000255c:	7402                	ld	s0,32(sp)
    8000255e:	64e2                	ld	s1,24(sp)
    80002560:	6942                	ld	s2,16(sp)
    80002562:	69a2                	ld	s3,8(sp)
    80002564:	6a02                	ld	s4,0(sp)
    80002566:	6145                	addi	sp,sp,48
    80002568:	8082                	ret
    memmove(dst, (char*)src, len);
    8000256a:	000a061b          	sext.w	a2,s4
    8000256e:	85ce                	mv	a1,s3
    80002570:	854a                	mv	a0,s2
    80002572:	ffffe097          	auipc	ra,0xffffe
    80002576:	7bc080e7          	jalr	1980(ra) # 80000d2e <memmove>
    return 0;
    8000257a:	8526                	mv	a0,s1
    8000257c:	bff9                	j	8000255a <either_copyin+0x32>

000000008000257e <procdump>:
// Print a process listing to console.  For debugging.
// Runs when user types ^P on console.
// No lock to avoid wedging a stuck machine further.
void
procdump(void)
{
    8000257e:	715d                	addi	sp,sp,-80
    80002580:	e486                	sd	ra,72(sp)
    80002582:	e0a2                	sd	s0,64(sp)
    80002584:	fc26                	sd	s1,56(sp)
    80002586:	f84a                	sd	s2,48(sp)
    80002588:	f44e                	sd	s3,40(sp)
    8000258a:	f052                	sd	s4,32(sp)
    8000258c:	ec56                	sd	s5,24(sp)
    8000258e:	e85a                	sd	s6,16(sp)
    80002590:	e45e                	sd	s7,8(sp)
    80002592:	0880                	addi	s0,sp,80
  [ZOMBIE]    "zombie"
  };
  struct proc *p;
  char *state;

  printf("\n");
    80002594:	00006517          	auipc	a0,0x6
    80002598:	b3450513          	addi	a0,a0,-1228 # 800080c8 <digits+0x88>
    8000259c:	ffffe097          	auipc	ra,0xffffe
    800025a0:	fee080e7          	jalr	-18(ra) # 8000058a <printf>
  for(p = proc; p < &proc[NPROC]; p++){
    800025a4:	0000f497          	auipc	s1,0xf
    800025a8:	b5c48493          	addi	s1,s1,-1188 # 80011100 <proc+0x158>
    800025ac:	00014917          	auipc	s2,0x14
    800025b0:	75490913          	addi	s2,s2,1876 # 80016d00 <bcache+0x140>
    if(p->state == UNUSED)
      continue;
    if(p->state >= 0 && p->state < NELEM(states) && states[p->state])
    800025b4:	4b15                	li	s6,5
      state = states[p->state];
    else
      state = "???";
    800025b6:	00006997          	auipc	s3,0x6
    800025ba:	cca98993          	addi	s3,s3,-822 # 80008280 <digits+0x240>
    printf("%d %s %s", p->pid, state, p->name);
    800025be:	00006a97          	auipc	s5,0x6
    800025c2:	ccaa8a93          	addi	s5,s5,-822 # 80008288 <digits+0x248>
    printf("\n");
    800025c6:	00006a17          	auipc	s4,0x6
    800025ca:	b02a0a13          	addi	s4,s4,-1278 # 800080c8 <digits+0x88>
    if(p->state >= 0 && p->state < NELEM(states) && states[p->state])
    800025ce:	00006b97          	auipc	s7,0x6
    800025d2:	cfab8b93          	addi	s7,s7,-774 # 800082c8 <states.0>
    800025d6:	a00d                	j	800025f8 <procdump+0x7a>
    printf("%d %s %s", p->pid, state, p->name);
    800025d8:	ed86a583          	lw	a1,-296(a3)
    800025dc:	8556                	mv	a0,s5
    800025de:	ffffe097          	auipc	ra,0xffffe
    800025e2:	fac080e7          	jalr	-84(ra) # 8000058a <printf>
    printf("\n");
    800025e6:	8552                	mv	a0,s4
    800025e8:	ffffe097          	auipc	ra,0xffffe
    800025ec:	fa2080e7          	jalr	-94(ra) # 8000058a <printf>
  for(p = proc; p < &proc[NPROC]; p++){
    800025f0:	17048493          	addi	s1,s1,368
    800025f4:	03248263          	beq	s1,s2,80002618 <procdump+0x9a>
    if(p->state == UNUSED)
    800025f8:	86a6                	mv	a3,s1
    800025fa:	ec04a783          	lw	a5,-320(s1)
    800025fe:	dbed                	beqz	a5,800025f0 <procdump+0x72>
      state = "???";
    80002600:	864e                	mv	a2,s3
    if(p->state >= 0 && p->state < NELEM(states) && states[p->state])
    80002602:	fcfb6be3          	bltu	s6,a5,800025d8 <procdump+0x5a>
    80002606:	02079713          	slli	a4,a5,0x20
    8000260a:	01d75793          	srli	a5,a4,0x1d
    8000260e:	97de                	add	a5,a5,s7
    80002610:	6390                	ld	a2,0(a5)
    80002612:	f279                	bnez	a2,800025d8 <procdump+0x5a>
      state = "???";
    80002614:	864e                	mv	a2,s3
    80002616:	b7c9                	j	800025d8 <procdump+0x5a>
  }
}
    80002618:	60a6                	ld	ra,72(sp)
    8000261a:	6406                	ld	s0,64(sp)
    8000261c:	74e2                	ld	s1,56(sp)
    8000261e:	7942                	ld	s2,48(sp)
    80002620:	79a2                	ld	s3,40(sp)
    80002622:	7a02                	ld	s4,32(sp)
    80002624:	6ae2                	ld	s5,24(sp)
    80002626:	6b42                	ld	s6,16(sp)
    80002628:	6ba2                	ld	s7,8(sp)
    8000262a:	6161                	addi	sp,sp,80
    8000262c:	8082                	ret

000000008000262e <clone_process>:


int clone_process(void* stack_address, int size)
{
    8000262e:	7139                	addi	sp,sp,-64
    80002630:	fc06                	sd	ra,56(sp)
    80002632:	f822                	sd	s0,48(sp)
    80002634:	f426                	sd	s1,40(sp)
    80002636:	f04a                	sd	s2,32(sp)
    80002638:	ec4e                	sd	s3,24(sp)
    8000263a:	e852                	sd	s4,16(sp)
    8000263c:	e456                	sd	s5,8(sp)
    8000263e:	0080                	addi	s0,sp,64
    80002640:	89aa                	mv	s3,a0
    80002642:	8a2e                	mv	s4,a1
  int i, tid;

  struct proc *nprocess;
  struct proc *p = myproc();
    80002644:	fffff097          	auipc	ra,0xfffff
    80002648:	368080e7          	jalr	872(ra) # 800019ac <myproc>

  if(stack_address == NULL) 
    8000264c:	1c098963          	beqz	s3,8000281e <clone_process+0x1f0>
    80002650:	8aaa                	mv	s5,a0
  for(p= proc; p< &proc[NPROC]; p++) 
    80002652:	0000f497          	auipc	s1,0xf
    80002656:	95648493          	addi	s1,s1,-1706 # 80010fa8 <proc>
    8000265a:	00014917          	auipc	s2,0x14
    8000265e:	54e90913          	addi	s2,s2,1358 # 80016ba8 <tickslock>
    acquire(&p->lock);
    80002662:	8526                	mv	a0,s1
    80002664:	ffffe097          	auipc	ra,0xffffe
    80002668:	572080e7          	jalr	1394(ra) # 80000bd6 <acquire>
    if(p->state == UNUSED) 
    8000266c:	4c9c                	lw	a5,24(s1)
    8000266e:	cf81                	beqz	a5,80002686 <clone_process+0x58>
      release(&p->lock);
    80002670:	8526                	mv	a0,s1
    80002672:	ffffe097          	auipc	ra,0xffffe
    80002676:	618080e7          	jalr	1560(ra) # 80000c8a <release>
  for(p= proc; p< &proc[NPROC]; p++) 
    8000267a:	17048493          	addi	s1,s1,368
    8000267e:	ff2492e3          	bne	s1,s2,80002662 <clone_process+0x34>
    return -1;
  
  if((nprocess = allocthread()) == 0) 
    return -1; 
    80002682:	59fd                	li	s3,-1
    80002684:	a259                	j	8000280a <clone_process+0x1dc>
  p->pid = allocpid();
    80002686:	fffff097          	auipc	ra,0xfffff
    8000268a:	3a4080e7          	jalr	932(ra) # 80001a2a <allocpid>
    8000268e:	d888                	sw	a0,48(s1)
  p->state = USED;
    80002690:	4785                	li	a5,1
    80002692:	cc9c                	sw	a5,24(s1)
  p->thread_id = alloctid();
    80002694:	fffff097          	auipc	ra,0xfffff
    80002698:	3dc080e7          	jalr	988(ra) # 80001a70 <alloctid>
    8000269c:	16a4a423          	sw	a0,360(s1)
  if((p->trapframe = (struct trapframe *) kalloc() ) == 0)
    800026a0:	ffffe097          	auipc	ra,0xffffe
    800026a4:	446080e7          	jalr	1094(ra) # 80000ae6 <kalloc>
    800026a8:	eca8                	sd	a0,88(s1)
    800026aa:	c145                	beqz	a0,8000274a <clone_process+0x11c>
  memset(&p->context, 0, sizeof(p->context));
    800026ac:	07000613          	li	a2,112
    800026b0:	4581                	li	a1,0
    800026b2:	06048513          	addi	a0,s1,96
    800026b6:	ffffe097          	auipc	ra,0xffffe
    800026ba:	61c080e7          	jalr	1564(ra) # 80000cd2 <memset>
  p->context.ra = (uint64) forkret;
    800026be:	fffff797          	auipc	a5,0xfffff
    800026c2:	32678793          	addi	a5,a5,806 # 800019e4 <forkret>
    800026c6:	f0bc                	sd	a5,96(s1)
  p->context.sp = p->kstack + PGSIZE;
    800026c8:	60bc                	ld	a5,64(s1)
    800026ca:	6705                	lui	a4,0x1
    800026cc:	97ba                	add	a5,a5,a4
    800026ce:	f4bc                	sd	a5,104(s1)

  nprocess->pagetable = p->pagetable;
    800026d0:	050ab503          	ld	a0,80(s5)
    800026d4:	e8a8                	sd	a0,80(s1)
  
  if(mappages(nprocess->pagetable, TRAPFRAME - (PGSIZE * nprocess->thread_id), PGSIZE, (uint64)(nprocess->trapframe), PTE_R | PTE_W ) < 0)
    800026d6:	1684a583          	lw	a1,360(s1)
    800026da:	00c5959b          	slliw	a1,a1,0xc
    800026de:	020007b7          	lui	a5,0x2000
    800026e2:	4719                	li	a4,6
    800026e4:	6cb4                	ld	a3,88(s1)
    800026e6:	6605                	lui	a2,0x1
    800026e8:	17fd                	addi	a5,a5,-1 # 1ffffff <_entry-0x7e000001>
    800026ea:	07b6                	slli	a5,a5,0xd
    800026ec:	40b785b3          	sub	a1,a5,a1
    800026f0:	fffff097          	auipc	ra,0xfffff
    800026f4:	9ae080e7          	jalr	-1618(ra) # 8000109e <mappages>
    800026f8:	06054463          	bltz	a0,80002760 <clone_process+0x132>
    uvmfree(nprocess->pagetable,0);
    return 0;
  }


  nprocess->sz = p->sz;
    800026fc:	048ab783          	ld	a5,72(s5)
    80002700:	e4bc                	sd	a5,72(s1)
  
  *(nprocess->trapframe) = *(p->trapframe);
    80002702:	058ab683          	ld	a3,88(s5)
    80002706:	87b6                	mv	a5,a3
    80002708:	6cb8                	ld	a4,88(s1)
    8000270a:	12068693          	addi	a3,a3,288
    8000270e:	0007b803          	ld	a6,0(a5)
    80002712:	6788                	ld	a0,8(a5)
    80002714:	6b8c                	ld	a1,16(a5)
    80002716:	6f90                	ld	a2,24(a5)
    80002718:	01073023          	sd	a6,0(a4) # 1000 <_entry-0x7ffff000>
    8000271c:	e708                	sd	a0,8(a4)
    8000271e:	eb0c                	sd	a1,16(a4)
    80002720:	ef10                	sd	a2,24(a4)
    80002722:	02078793          	addi	a5,a5,32
    80002726:	02070713          	addi	a4,a4,32
    8000272a:	fed792e3          	bne	a5,a3,8000270e <clone_process+0xe0>
  nprocess->trapframe->sp = (uint64)(stack_address+size);
    8000272e:	6cbc                	ld	a5,88(s1)
    80002730:	99d2                	add	s3,s3,s4
    80002732:	0337b823          	sd	s3,48(a5)
  nprocess->trapframe->a0 = 0;
    80002736:	6cbc                	ld	a5,88(s1)
    80002738:	0607b823          	sd	zero,112(a5)

  for(i = 0; i < NOFILE; i++)
    8000273c:	0d0a8913          	addi	s2,s5,208
    80002740:	0d048993          	addi	s3,s1,208
    80002744:	150a8a13          	addi	s4,s5,336
    80002748:	a889                	j	8000279a <clone_process+0x16c>
    freeproc(p);
    8000274a:	8526                	mv	a0,s1
    8000274c:	fffff097          	auipc	ra,0xfffff
    80002750:	458080e7          	jalr	1112(ra) # 80001ba4 <freeproc>
    release(&p->lock);
    80002754:	8526                	mv	a0,s1
    80002756:	ffffe097          	auipc	ra,0xffffe
    8000275a:	534080e7          	jalr	1332(ra) # 80000c8a <release>
    return 0;
    8000275e:	b715                	j	80002682 <clone_process+0x54>
    uvmunmap(nprocess->pagetable, TRAMPOLINE,1,0);
    80002760:	4681                	li	a3,0
    80002762:	4605                	li	a2,1
    80002764:	040005b7          	lui	a1,0x4000
    80002768:	15fd                	addi	a1,a1,-1 # 3ffffff <_entry-0x7c000001>
    8000276a:	05b2                	slli	a1,a1,0xc
    8000276c:	68a8                	ld	a0,80(s1)
    8000276e:	fffff097          	auipc	ra,0xfffff
    80002772:	af6080e7          	jalr	-1290(ra) # 80001264 <uvmunmap>
    uvmfree(nprocess->pagetable,0);
    80002776:	4581                	li	a1,0
    80002778:	68a8                	ld	a0,80(s1)
    8000277a:	fffff097          	auipc	ra,0xfffff
    8000277e:	db4080e7          	jalr	-588(ra) # 8000152e <uvmfree>
    return 0;
    80002782:	4981                	li	s3,0
    80002784:	a059                	j	8000280a <clone_process+0x1dc>
  {
    if(p->ofile[i])
      nprocess->ofile[i] = filedup(p->ofile[i]);
    80002786:	00002097          	auipc	ra,0x2
    8000278a:	fa2080e7          	jalr	-94(ra) # 80004728 <filedup>
    8000278e:	00a9b023          	sd	a0,0(s3)
  for(i = 0; i < NOFILE; i++)
    80002792:	0921                	addi	s2,s2,8
    80002794:	09a1                	addi	s3,s3,8
    80002796:	01490663          	beq	s2,s4,800027a2 <clone_process+0x174>
    if(p->ofile[i])
    8000279a:	00093503          	ld	a0,0(s2)
    8000279e:	f565                	bnez	a0,80002786 <clone_process+0x158>
    800027a0:	bfcd                	j	80002792 <clone_process+0x164>
  }
  nprocess->cwd = idup(p->cwd);
    800027a2:	150ab503          	ld	a0,336(s5)
    800027a6:	00001097          	auipc	ra,0x1
    800027aa:	102080e7          	jalr	258(ra) # 800038a8 <idup>
    800027ae:	14a4b823          	sd	a0,336(s1)
  
  safestrcpy(nprocess->name, p->name, sizeof(p->name));
    800027b2:	4641                	li	a2,16
    800027b4:	158a8593          	addi	a1,s5,344
    800027b8:	15848513          	addi	a0,s1,344
    800027bc:	ffffe097          	auipc	ra,0xffffe
    800027c0:	660080e7          	jalr	1632(ra) # 80000e1c <safestrcpy>
  tid = nprocess->thread_id;
    800027c4:	1684a983          	lw	s3,360(s1)
  release(&nprocess->lock);
    800027c8:	8526                	mv	a0,s1
    800027ca:	ffffe097          	auipc	ra,0xffffe
    800027ce:	4c0080e7          	jalr	1216(ra) # 80000c8a <release>

  
  acquire(&wait_lock);
    800027d2:	0000e917          	auipc	s2,0xe
    800027d6:	3a690913          	addi	s2,s2,934 # 80010b78 <wait_lock>
    800027da:	854a                	mv	a0,s2
    800027dc:	ffffe097          	auipc	ra,0xffffe
    800027e0:	3fa080e7          	jalr	1018(ra) # 80000bd6 <acquire>
  nprocess->parent = p;
    800027e4:	0354bc23          	sd	s5,56(s1)
  release(&wait_lock);
    800027e8:	854a                	mv	a0,s2
    800027ea:	ffffe097          	auipc	ra,0xffffe
    800027ee:	4a0080e7          	jalr	1184(ra) # 80000c8a <release>

  
  acquire(&nprocess->lock);
    800027f2:	8526                	mv	a0,s1
    800027f4:	ffffe097          	auipc	ra,0xffffe
    800027f8:	3e2080e7          	jalr	994(ra) # 80000bd6 <acquire>
  nprocess->state = RUNNABLE;
    800027fc:	478d                	li	a5,3
    800027fe:	cc9c                	sw	a5,24(s1)
  release(&nprocess->lock);
    80002800:	8526                	mv	a0,s1
    80002802:	ffffe097          	auipc	ra,0xffffe
    80002806:	488080e7          	jalr	1160(ra) # 80000c8a <release>

  
  return tid;
}
    8000280a:	854e                	mv	a0,s3
    8000280c:	70e2                	ld	ra,56(sp)
    8000280e:	7442                	ld	s0,48(sp)
    80002810:	74a2                	ld	s1,40(sp)
    80002812:	7902                	ld	s2,32(sp)
    80002814:	69e2                	ld	s3,24(sp)
    80002816:	6a42                	ld	s4,16(sp)
    80002818:	6aa2                	ld	s5,8(sp)
    8000281a:	6121                	addi	sp,sp,64
    8000281c:	8082                	ret
    return -1;
    8000281e:	59fd                	li	s3,-1
    80002820:	b7ed                	j	8000280a <clone_process+0x1dc>

0000000080002822 <swtch>:
    80002822:	00153023          	sd	ra,0(a0)
    80002826:	00253423          	sd	sp,8(a0)
    8000282a:	e900                	sd	s0,16(a0)
    8000282c:	ed04                	sd	s1,24(a0)
    8000282e:	03253023          	sd	s2,32(a0)
    80002832:	03353423          	sd	s3,40(a0)
    80002836:	03453823          	sd	s4,48(a0)
    8000283a:	03553c23          	sd	s5,56(a0)
    8000283e:	05653023          	sd	s6,64(a0)
    80002842:	05753423          	sd	s7,72(a0)
    80002846:	05853823          	sd	s8,80(a0)
    8000284a:	05953c23          	sd	s9,88(a0)
    8000284e:	07a53023          	sd	s10,96(a0)
    80002852:	07b53423          	sd	s11,104(a0)
    80002856:	0005b083          	ld	ra,0(a1)
    8000285a:	0085b103          	ld	sp,8(a1)
    8000285e:	6980                	ld	s0,16(a1)
    80002860:	6d84                	ld	s1,24(a1)
    80002862:	0205b903          	ld	s2,32(a1)
    80002866:	0285b983          	ld	s3,40(a1)
    8000286a:	0305ba03          	ld	s4,48(a1)
    8000286e:	0385ba83          	ld	s5,56(a1)
    80002872:	0405bb03          	ld	s6,64(a1)
    80002876:	0485bb83          	ld	s7,72(a1)
    8000287a:	0505bc03          	ld	s8,80(a1)
    8000287e:	0585bc83          	ld	s9,88(a1)
    80002882:	0605bd03          	ld	s10,96(a1)
    80002886:	0685bd83          	ld	s11,104(a1)
    8000288a:	8082                	ret

000000008000288c <trapinit>:

extern int devintr();

void
trapinit(void)
{
    8000288c:	1141                	addi	sp,sp,-16
    8000288e:	e406                	sd	ra,8(sp)
    80002890:	e022                	sd	s0,0(sp)
    80002892:	0800                	addi	s0,sp,16
  initlock(&tickslock, "time");
    80002894:	00006597          	auipc	a1,0x6
    80002898:	a6458593          	addi	a1,a1,-1436 # 800082f8 <states.0+0x30>
    8000289c:	00014517          	auipc	a0,0x14
    800028a0:	30c50513          	addi	a0,a0,780 # 80016ba8 <tickslock>
    800028a4:	ffffe097          	auipc	ra,0xffffe
    800028a8:	2a2080e7          	jalr	674(ra) # 80000b46 <initlock>
}
    800028ac:	60a2                	ld	ra,8(sp)
    800028ae:	6402                	ld	s0,0(sp)
    800028b0:	0141                	addi	sp,sp,16
    800028b2:	8082                	ret

00000000800028b4 <trapinithart>:

// set up to take exceptions and traps while in the kernel.
void
trapinithart(void)
{
    800028b4:	1141                	addi	sp,sp,-16
    800028b6:	e422                	sd	s0,8(sp)
    800028b8:	0800                	addi	s0,sp,16
  asm volatile("csrw stvec, %0" : : "r" (x));
    800028ba:	00003797          	auipc	a5,0x3
    800028be:	51678793          	addi	a5,a5,1302 # 80005dd0 <kernelvec>
    800028c2:	10579073          	csrw	stvec,a5
  w_stvec((uint64)kernelvec);
}
    800028c6:	6422                	ld	s0,8(sp)
    800028c8:	0141                	addi	sp,sp,16
    800028ca:	8082                	ret

00000000800028cc <usertrapret>:
//
// return to user space
//
void
usertrapret(void)
{
    800028cc:	1141                	addi	sp,sp,-16
    800028ce:	e406                	sd	ra,8(sp)
    800028d0:	e022                	sd	s0,0(sp)
    800028d2:	0800                	addi	s0,sp,16
  struct proc *p = myproc();
    800028d4:	fffff097          	auipc	ra,0xfffff
    800028d8:	0d8080e7          	jalr	216(ra) # 800019ac <myproc>
  asm volatile("csrr %0, sstatus" : "=r" (x) );
    800028dc:	100027f3          	csrr	a5,sstatus
  w_sstatus(r_sstatus() & ~SSTATUS_SIE);
    800028e0:	9bf5                	andi	a5,a5,-3
  asm volatile("csrw sstatus, %0" : : "r" (x));
    800028e2:	10079073          	csrw	sstatus,a5
  // kerneltrap() to usertrap(), so turn off interrupts until
  // we're back in user space, where usertrap() is correct.
  intr_off();

  // send syscalls, interrupts, and exceptions to uservec in trampoline.S
  uint64 trampoline_uservec = TRAMPOLINE + (uservec - trampoline);
    800028e6:	00004617          	auipc	a2,0x4
    800028ea:	71a60613          	addi	a2,a2,1818 # 80007000 <_trampoline>
    800028ee:	00004717          	auipc	a4,0x4
    800028f2:	71270713          	addi	a4,a4,1810 # 80007000 <_trampoline>
    800028f6:	8f11                	sub	a4,a4,a2
    800028f8:	040007b7          	lui	a5,0x4000
    800028fc:	17fd                	addi	a5,a5,-1 # 3ffffff <_entry-0x7c000001>
    800028fe:	07b2                	slli	a5,a5,0xc
    80002900:	973e                	add	a4,a4,a5
  asm volatile("csrw stvec, %0" : : "r" (x));
    80002902:	10571073          	csrw	stvec,a4
  w_stvec(trampoline_uservec);

  // set up trapframe values that uservec will need when
  // the process next traps into the kernel.
  p->trapframe->kernel_satp = r_satp();         // kernel page table
    80002906:	6d38                	ld	a4,88(a0)
  asm volatile("csrr %0, satp" : "=r" (x) );
    80002908:	180026f3          	csrr	a3,satp
    8000290c:	e314                	sd	a3,0(a4)
  p->trapframe->kernel_sp = p->kstack + PGSIZE; // process's kernel stack
    8000290e:	6d34                	ld	a3,88(a0)
    80002910:	6138                	ld	a4,64(a0)
    80002912:	6585                	lui	a1,0x1
    80002914:	972e                	add	a4,a4,a1
    80002916:	e698                	sd	a4,8(a3)
  p->trapframe->kernel_trap = (uint64)usertrap;
    80002918:	6d38                	ld	a4,88(a0)
    8000291a:	00000697          	auipc	a3,0x0
    8000291e:	14468693          	addi	a3,a3,324 # 80002a5e <usertrap>
    80002922:	eb14                	sd	a3,16(a4)
  p->trapframe->kernel_hartid = r_tp();         // hartid for cpuid()
    80002924:	6d38                	ld	a4,88(a0)
  asm volatile("mv %0, tp" : "=r" (x) );
    80002926:	8692                	mv	a3,tp
    80002928:	f314                	sd	a3,32(a4)
  asm volatile("csrr %0, sstatus" : "=r" (x) );
    8000292a:	10002773          	csrr	a4,sstatus
  // set up the registers that trampoline.S's sret will use
  // to get to user space.
  
  // set S Previous Privilege mode to User.
  unsigned long x = r_sstatus();
  x &= ~SSTATUS_SPP; // clear SPP to 0 for user mode
    8000292e:	eff77713          	andi	a4,a4,-257
  x |= SSTATUS_SPIE; // enable interrupts in user mode
    80002932:	02076713          	ori	a4,a4,32
  asm volatile("csrw sstatus, %0" : : "r" (x));
    80002936:	10071073          	csrw	sstatus,a4
  w_sstatus(x);

  // set S Exception Program Counter to the saved user pc.
  w_sepc(p->trapframe->epc);
    8000293a:	6d38                	ld	a4,88(a0)
  asm volatile("csrw sepc, %0" : : "r" (x));
    8000293c:	6f18                	ld	a4,24(a4)
    8000293e:	14171073          	csrw	sepc,a4

  // tell trampoline.S the user page table to switch to.
  uint64 satp = MAKE_SATP(p->pagetable);
    80002942:	692c                	ld	a1,80(a0)
    80002944:	81b1                	srli	a1,a1,0xc

  // jump to userret in trampoline.S at the top of memory, which 
  // switches to the user page table, restores user registers,
  // and switches to user mode with sret.
  uint64 trampoline_userret = TRAMPOLINE + (userret - trampoline);
  ((void (*)(uint64, uint64))trampoline_userret)(TRAPFRAME- PGSIZE* p->thread_id, satp);
    80002946:	16852503          	lw	a0,360(a0)
    8000294a:	00c5151b          	slliw	a0,a0,0xc
    8000294e:	020006b7          	lui	a3,0x2000
  uint64 trampoline_userret = TRAMPOLINE + (userret - trampoline);
    80002952:	00004717          	auipc	a4,0x4
    80002956:	73e70713          	addi	a4,a4,1854 # 80007090 <userret>
    8000295a:	8f11                	sub	a4,a4,a2
    8000295c:	97ba                	add	a5,a5,a4
  ((void (*)(uint64, uint64))trampoline_userret)(TRAPFRAME- PGSIZE* p->thread_id, satp);
    8000295e:	577d                	li	a4,-1
    80002960:	177e                	slli	a4,a4,0x3f
    80002962:	8dd9                	or	a1,a1,a4
    80002964:	16fd                	addi	a3,a3,-1 # 1ffffff <_entry-0x7e000001>
    80002966:	06b6                	slli	a3,a3,0xd
    80002968:	40a68533          	sub	a0,a3,a0
    8000296c:	9782                	jalr	a5
}
    8000296e:	60a2                	ld	ra,8(sp)
    80002970:	6402                	ld	s0,0(sp)
    80002972:	0141                	addi	sp,sp,16
    80002974:	8082                	ret

0000000080002976 <clockintr>:
  w_sstatus(sstatus);
}

void
clockintr()
{
    80002976:	1101                	addi	sp,sp,-32
    80002978:	ec06                	sd	ra,24(sp)
    8000297a:	e822                	sd	s0,16(sp)
    8000297c:	e426                	sd	s1,8(sp)
    8000297e:	1000                	addi	s0,sp,32
  acquire(&tickslock);
    80002980:	00014497          	auipc	s1,0x14
    80002984:	22848493          	addi	s1,s1,552 # 80016ba8 <tickslock>
    80002988:	8526                	mv	a0,s1
    8000298a:	ffffe097          	auipc	ra,0xffffe
    8000298e:	24c080e7          	jalr	588(ra) # 80000bd6 <acquire>
  ticks++;
    80002992:	00006517          	auipc	a0,0x6
    80002996:	f5e50513          	addi	a0,a0,-162 # 800088f0 <ticks>
    8000299a:	411c                	lw	a5,0(a0)
    8000299c:	2785                	addiw	a5,a5,1
    8000299e:	c11c                	sw	a5,0(a0)
  wakeup(&ticks);
    800029a0:	fffff097          	auipc	ra,0xfffff
    800029a4:	786080e7          	jalr	1926(ra) # 80002126 <wakeup>
  release(&tickslock);
    800029a8:	8526                	mv	a0,s1
    800029aa:	ffffe097          	auipc	ra,0xffffe
    800029ae:	2e0080e7          	jalr	736(ra) # 80000c8a <release>
}
    800029b2:	60e2                	ld	ra,24(sp)
    800029b4:	6442                	ld	s0,16(sp)
    800029b6:	64a2                	ld	s1,8(sp)
    800029b8:	6105                	addi	sp,sp,32
    800029ba:	8082                	ret

00000000800029bc <devintr>:
// returns 2 if timer interrupt,
// 1 if other device,
// 0 if not recognized.
int
devintr()
{
    800029bc:	1101                	addi	sp,sp,-32
    800029be:	ec06                	sd	ra,24(sp)
    800029c0:	e822                	sd	s0,16(sp)
    800029c2:	e426                	sd	s1,8(sp)
    800029c4:	1000                	addi	s0,sp,32
  asm volatile("csrr %0, scause" : "=r" (x) );
    800029c6:	14202773          	csrr	a4,scause
  uint64 scause = r_scause();

  if((scause & 0x8000000000000000L) &&
    800029ca:	00074d63          	bltz	a4,800029e4 <devintr+0x28>
    // now allowed to interrupt again.
    if(irq)
      plic_complete(irq);

    return 1;
  } else if(scause == 0x8000000000000001L){
    800029ce:	57fd                	li	a5,-1
    800029d0:	17fe                	slli	a5,a5,0x3f
    800029d2:	0785                	addi	a5,a5,1
    // the SSIP bit in sip.
    w_sip(r_sip() & ~2);

    return 2;
  } else {
    return 0;
    800029d4:	4501                	li	a0,0
  } else if(scause == 0x8000000000000001L){
    800029d6:	06f70363          	beq	a4,a5,80002a3c <devintr+0x80>
  }
}
    800029da:	60e2                	ld	ra,24(sp)
    800029dc:	6442                	ld	s0,16(sp)
    800029de:	64a2                	ld	s1,8(sp)
    800029e0:	6105                	addi	sp,sp,32
    800029e2:	8082                	ret
     (scause & 0xff) == 9){
    800029e4:	0ff77793          	zext.b	a5,a4
  if((scause & 0x8000000000000000L) &&
    800029e8:	46a5                	li	a3,9
    800029ea:	fed792e3          	bne	a5,a3,800029ce <devintr+0x12>
    int irq = plic_claim();
    800029ee:	00003097          	auipc	ra,0x3
    800029f2:	4ea080e7          	jalr	1258(ra) # 80005ed8 <plic_claim>
    800029f6:	84aa                	mv	s1,a0
    if(irq == UART0_IRQ){
    800029f8:	47a9                	li	a5,10
    800029fa:	02f50763          	beq	a0,a5,80002a28 <devintr+0x6c>
    } else if(irq == VIRTIO0_IRQ){
    800029fe:	4785                	li	a5,1
    80002a00:	02f50963          	beq	a0,a5,80002a32 <devintr+0x76>
    return 1;
    80002a04:	4505                	li	a0,1
    } else if(irq){
    80002a06:	d8f1                	beqz	s1,800029da <devintr+0x1e>
      printf("unexpected interrupt irq=%d\n", irq);
    80002a08:	85a6                	mv	a1,s1
    80002a0a:	00006517          	auipc	a0,0x6
    80002a0e:	8f650513          	addi	a0,a0,-1802 # 80008300 <states.0+0x38>
    80002a12:	ffffe097          	auipc	ra,0xffffe
    80002a16:	b78080e7          	jalr	-1160(ra) # 8000058a <printf>
      plic_complete(irq);
    80002a1a:	8526                	mv	a0,s1
    80002a1c:	00003097          	auipc	ra,0x3
    80002a20:	4e0080e7          	jalr	1248(ra) # 80005efc <plic_complete>
    return 1;
    80002a24:	4505                	li	a0,1
    80002a26:	bf55                	j	800029da <devintr+0x1e>
      uartintr();
    80002a28:	ffffe097          	auipc	ra,0xffffe
    80002a2c:	f70080e7          	jalr	-144(ra) # 80000998 <uartintr>
    80002a30:	b7ed                	j	80002a1a <devintr+0x5e>
      virtio_disk_intr();
    80002a32:	00004097          	auipc	ra,0x4
    80002a36:	992080e7          	jalr	-1646(ra) # 800063c4 <virtio_disk_intr>
    80002a3a:	b7c5                	j	80002a1a <devintr+0x5e>
    if(cpuid() == 0){
    80002a3c:	fffff097          	auipc	ra,0xfffff
    80002a40:	f44080e7          	jalr	-188(ra) # 80001980 <cpuid>
    80002a44:	c901                	beqz	a0,80002a54 <devintr+0x98>
  asm volatile("csrr %0, sip" : "=r" (x) );
    80002a46:	144027f3          	csrr	a5,sip
    w_sip(r_sip() & ~2);
    80002a4a:	9bf5                	andi	a5,a5,-3
  asm volatile("csrw sip, %0" : : "r" (x));
    80002a4c:	14479073          	csrw	sip,a5
    return 2;
    80002a50:	4509                	li	a0,2
    80002a52:	b761                	j	800029da <devintr+0x1e>
      clockintr();
    80002a54:	00000097          	auipc	ra,0x0
    80002a58:	f22080e7          	jalr	-222(ra) # 80002976 <clockintr>
    80002a5c:	b7ed                	j	80002a46 <devintr+0x8a>

0000000080002a5e <usertrap>:
{
    80002a5e:	1101                	addi	sp,sp,-32
    80002a60:	ec06                	sd	ra,24(sp)
    80002a62:	e822                	sd	s0,16(sp)
    80002a64:	e426                	sd	s1,8(sp)
    80002a66:	e04a                	sd	s2,0(sp)
    80002a68:	1000                	addi	s0,sp,32
  asm volatile("csrr %0, sstatus" : "=r" (x) );
    80002a6a:	100027f3          	csrr	a5,sstatus
  if((r_sstatus() & SSTATUS_SPP) != 0)
    80002a6e:	1007f793          	andi	a5,a5,256
    80002a72:	e3b1                	bnez	a5,80002ab6 <usertrap+0x58>
  asm volatile("csrw stvec, %0" : : "r" (x));
    80002a74:	00003797          	auipc	a5,0x3
    80002a78:	35c78793          	addi	a5,a5,860 # 80005dd0 <kernelvec>
    80002a7c:	10579073          	csrw	stvec,a5
  struct proc *p = myproc();
    80002a80:	fffff097          	auipc	ra,0xfffff
    80002a84:	f2c080e7          	jalr	-212(ra) # 800019ac <myproc>
    80002a88:	84aa                	mv	s1,a0
  p->trapframe->epc = r_sepc();
    80002a8a:	6d3c                	ld	a5,88(a0)
  asm volatile("csrr %0, sepc" : "=r" (x) );
    80002a8c:	14102773          	csrr	a4,sepc
    80002a90:	ef98                	sd	a4,24(a5)
  asm volatile("csrr %0, scause" : "=r" (x) );
    80002a92:	14202773          	csrr	a4,scause
  if(r_scause() == 8){
    80002a96:	47a1                	li	a5,8
    80002a98:	02f70763          	beq	a4,a5,80002ac6 <usertrap+0x68>
  } else if((which_dev = devintr()) != 0){
    80002a9c:	00000097          	auipc	ra,0x0
    80002aa0:	f20080e7          	jalr	-224(ra) # 800029bc <devintr>
    80002aa4:	892a                	mv	s2,a0
    80002aa6:	c151                	beqz	a0,80002b2a <usertrap+0xcc>
  if(killed(p))
    80002aa8:	8526                	mv	a0,s1
    80002aaa:	00000097          	auipc	ra,0x0
    80002aae:	8c8080e7          	jalr	-1848(ra) # 80002372 <killed>
    80002ab2:	c929                	beqz	a0,80002b04 <usertrap+0xa6>
    80002ab4:	a099                	j	80002afa <usertrap+0x9c>
    panic("usertrap: not from user mode");
    80002ab6:	00006517          	auipc	a0,0x6
    80002aba:	86a50513          	addi	a0,a0,-1942 # 80008320 <states.0+0x58>
    80002abe:	ffffe097          	auipc	ra,0xffffe
    80002ac2:	a82080e7          	jalr	-1406(ra) # 80000540 <panic>
    if(killed(p))
    80002ac6:	00000097          	auipc	ra,0x0
    80002aca:	8ac080e7          	jalr	-1876(ra) # 80002372 <killed>
    80002ace:	e921                	bnez	a0,80002b1e <usertrap+0xc0>
    p->trapframe->epc += 4;
    80002ad0:	6cb8                	ld	a4,88(s1)
    80002ad2:	6f1c                	ld	a5,24(a4)
    80002ad4:	0791                	addi	a5,a5,4
    80002ad6:	ef1c                	sd	a5,24(a4)
  asm volatile("csrr %0, sstatus" : "=r" (x) );
    80002ad8:	100027f3          	csrr	a5,sstatus
  w_sstatus(r_sstatus() | SSTATUS_SIE);
    80002adc:	0027e793          	ori	a5,a5,2
  asm volatile("csrw sstatus, %0" : : "r" (x));
    80002ae0:	10079073          	csrw	sstatus,a5
    syscall();
    80002ae4:	00000097          	auipc	ra,0x0
    80002ae8:	2d4080e7          	jalr	724(ra) # 80002db8 <syscall>
  if(killed(p))
    80002aec:	8526                	mv	a0,s1
    80002aee:	00000097          	auipc	ra,0x0
    80002af2:	884080e7          	jalr	-1916(ra) # 80002372 <killed>
    80002af6:	c911                	beqz	a0,80002b0a <usertrap+0xac>
    80002af8:	4901                	li	s2,0
    exit(-1);
    80002afa:	557d                	li	a0,-1
    80002afc:	fffff097          	auipc	ra,0xfffff
    80002b00:	6fa080e7          	jalr	1786(ra) # 800021f6 <exit>
  if(which_dev == 2)
    80002b04:	4789                	li	a5,2
    80002b06:	04f90f63          	beq	s2,a5,80002b64 <usertrap+0x106>
  usertrapret();
    80002b0a:	00000097          	auipc	ra,0x0
    80002b0e:	dc2080e7          	jalr	-574(ra) # 800028cc <usertrapret>
}
    80002b12:	60e2                	ld	ra,24(sp)
    80002b14:	6442                	ld	s0,16(sp)
    80002b16:	64a2                	ld	s1,8(sp)
    80002b18:	6902                	ld	s2,0(sp)
    80002b1a:	6105                	addi	sp,sp,32
    80002b1c:	8082                	ret
      exit(-1);
    80002b1e:	557d                	li	a0,-1
    80002b20:	fffff097          	auipc	ra,0xfffff
    80002b24:	6d6080e7          	jalr	1750(ra) # 800021f6 <exit>
    80002b28:	b765                	j	80002ad0 <usertrap+0x72>
  asm volatile("csrr %0, scause" : "=r" (x) );
    80002b2a:	142025f3          	csrr	a1,scause
    printf("usertrap(): unexpected scause %p pid=%d\n", r_scause(), p->pid);
    80002b2e:	5890                	lw	a2,48(s1)
    80002b30:	00006517          	auipc	a0,0x6
    80002b34:	81050513          	addi	a0,a0,-2032 # 80008340 <states.0+0x78>
    80002b38:	ffffe097          	auipc	ra,0xffffe
    80002b3c:	a52080e7          	jalr	-1454(ra) # 8000058a <printf>
  asm volatile("csrr %0, sepc" : "=r" (x) );
    80002b40:	141025f3          	csrr	a1,sepc
  asm volatile("csrr %0, stval" : "=r" (x) );
    80002b44:	14302673          	csrr	a2,stval
    printf("            sepc=%p stval=%p\n", r_sepc(), r_stval());
    80002b48:	00006517          	auipc	a0,0x6
    80002b4c:	82850513          	addi	a0,a0,-2008 # 80008370 <states.0+0xa8>
    80002b50:	ffffe097          	auipc	ra,0xffffe
    80002b54:	a3a080e7          	jalr	-1478(ra) # 8000058a <printf>
    setkilled(p);
    80002b58:	8526                	mv	a0,s1
    80002b5a:	fffff097          	auipc	ra,0xfffff
    80002b5e:	7ec080e7          	jalr	2028(ra) # 80002346 <setkilled>
    80002b62:	b769                	j	80002aec <usertrap+0x8e>
    yield();
    80002b64:	fffff097          	auipc	ra,0xfffff
    80002b68:	522080e7          	jalr	1314(ra) # 80002086 <yield>
    80002b6c:	bf79                	j	80002b0a <usertrap+0xac>

0000000080002b6e <kerneltrap>:
{
    80002b6e:	7179                	addi	sp,sp,-48
    80002b70:	f406                	sd	ra,40(sp)
    80002b72:	f022                	sd	s0,32(sp)
    80002b74:	ec26                	sd	s1,24(sp)
    80002b76:	e84a                	sd	s2,16(sp)
    80002b78:	e44e                	sd	s3,8(sp)
    80002b7a:	1800                	addi	s0,sp,48
  asm volatile("csrr %0, sepc" : "=r" (x) );
    80002b7c:	14102973          	csrr	s2,sepc
  asm volatile("csrr %0, sstatus" : "=r" (x) );
    80002b80:	100024f3          	csrr	s1,sstatus
  asm volatile("csrr %0, scause" : "=r" (x) );
    80002b84:	142029f3          	csrr	s3,scause
  if((sstatus & SSTATUS_SPP) == 0)
    80002b88:	1004f793          	andi	a5,s1,256
    80002b8c:	cb85                	beqz	a5,80002bbc <kerneltrap+0x4e>
  asm volatile("csrr %0, sstatus" : "=r" (x) );
    80002b8e:	100027f3          	csrr	a5,sstatus
  return (x & SSTATUS_SIE) != 0;
    80002b92:	8b89                	andi	a5,a5,2
  if(intr_get() != 0)
    80002b94:	ef85                	bnez	a5,80002bcc <kerneltrap+0x5e>
  if((which_dev = devintr()) == 0){
    80002b96:	00000097          	auipc	ra,0x0
    80002b9a:	e26080e7          	jalr	-474(ra) # 800029bc <devintr>
    80002b9e:	cd1d                	beqz	a0,80002bdc <kerneltrap+0x6e>
  if(which_dev == 2 && myproc() != 0 && myproc()->state == RUNNING)
    80002ba0:	4789                	li	a5,2
    80002ba2:	06f50a63          	beq	a0,a5,80002c16 <kerneltrap+0xa8>
  asm volatile("csrw sepc, %0" : : "r" (x));
    80002ba6:	14191073          	csrw	sepc,s2
  asm volatile("csrw sstatus, %0" : : "r" (x));
    80002baa:	10049073          	csrw	sstatus,s1
}
    80002bae:	70a2                	ld	ra,40(sp)
    80002bb0:	7402                	ld	s0,32(sp)
    80002bb2:	64e2                	ld	s1,24(sp)
    80002bb4:	6942                	ld	s2,16(sp)
    80002bb6:	69a2                	ld	s3,8(sp)
    80002bb8:	6145                	addi	sp,sp,48
    80002bba:	8082                	ret
    panic("kerneltrap: not from supervisor mode");
    80002bbc:	00005517          	auipc	a0,0x5
    80002bc0:	7d450513          	addi	a0,a0,2004 # 80008390 <states.0+0xc8>
    80002bc4:	ffffe097          	auipc	ra,0xffffe
    80002bc8:	97c080e7          	jalr	-1668(ra) # 80000540 <panic>
    panic("kerneltrap: interrupts enabled");
    80002bcc:	00005517          	auipc	a0,0x5
    80002bd0:	7ec50513          	addi	a0,a0,2028 # 800083b8 <states.0+0xf0>
    80002bd4:	ffffe097          	auipc	ra,0xffffe
    80002bd8:	96c080e7          	jalr	-1684(ra) # 80000540 <panic>
    printf("scause %p\n", scause);
    80002bdc:	85ce                	mv	a1,s3
    80002bde:	00005517          	auipc	a0,0x5
    80002be2:	7fa50513          	addi	a0,a0,2042 # 800083d8 <states.0+0x110>
    80002be6:	ffffe097          	auipc	ra,0xffffe
    80002bea:	9a4080e7          	jalr	-1628(ra) # 8000058a <printf>
  asm volatile("csrr %0, sepc" : "=r" (x) );
    80002bee:	141025f3          	csrr	a1,sepc
  asm volatile("csrr %0, stval" : "=r" (x) );
    80002bf2:	14302673          	csrr	a2,stval
    printf("sepc=%p stval=%p\n", r_sepc(), r_stval());
    80002bf6:	00005517          	auipc	a0,0x5
    80002bfa:	7f250513          	addi	a0,a0,2034 # 800083e8 <states.0+0x120>
    80002bfe:	ffffe097          	auipc	ra,0xffffe
    80002c02:	98c080e7          	jalr	-1652(ra) # 8000058a <printf>
    panic("kerneltrap");
    80002c06:	00005517          	auipc	a0,0x5
    80002c0a:	7fa50513          	addi	a0,a0,2042 # 80008400 <states.0+0x138>
    80002c0e:	ffffe097          	auipc	ra,0xffffe
    80002c12:	932080e7          	jalr	-1742(ra) # 80000540 <panic>
  if(which_dev == 2 && myproc() != 0 && myproc()->state == RUNNING)
    80002c16:	fffff097          	auipc	ra,0xfffff
    80002c1a:	d96080e7          	jalr	-618(ra) # 800019ac <myproc>
    80002c1e:	d541                	beqz	a0,80002ba6 <kerneltrap+0x38>
    80002c20:	fffff097          	auipc	ra,0xfffff
    80002c24:	d8c080e7          	jalr	-628(ra) # 800019ac <myproc>
    80002c28:	4d18                	lw	a4,24(a0)
    80002c2a:	4791                	li	a5,4
    80002c2c:	f6f71de3          	bne	a4,a5,80002ba6 <kerneltrap+0x38>
    yield();
    80002c30:	fffff097          	auipc	ra,0xfffff
    80002c34:	456080e7          	jalr	1110(ra) # 80002086 <yield>
    80002c38:	b7bd                	j	80002ba6 <kerneltrap+0x38>

0000000080002c3a <argraw>:
  return strlen(buf);
}

static uint64
argraw(int n)
{
    80002c3a:	1101                	addi	sp,sp,-32
    80002c3c:	ec06                	sd	ra,24(sp)
    80002c3e:	e822                	sd	s0,16(sp)
    80002c40:	e426                	sd	s1,8(sp)
    80002c42:	1000                	addi	s0,sp,32
    80002c44:	84aa                	mv	s1,a0
  struct proc *p = myproc();
    80002c46:	fffff097          	auipc	ra,0xfffff
    80002c4a:	d66080e7          	jalr	-666(ra) # 800019ac <myproc>
  switch (n) {
    80002c4e:	4795                	li	a5,5
    80002c50:	0497e163          	bltu	a5,s1,80002c92 <argraw+0x58>
    80002c54:	048a                	slli	s1,s1,0x2
    80002c56:	00005717          	auipc	a4,0x5
    80002c5a:	7e270713          	addi	a4,a4,2018 # 80008438 <states.0+0x170>
    80002c5e:	94ba                	add	s1,s1,a4
    80002c60:	409c                	lw	a5,0(s1)
    80002c62:	97ba                	add	a5,a5,a4
    80002c64:	8782                	jr	a5
  case 0:
    return p->trapframe->a0;
    80002c66:	6d3c                	ld	a5,88(a0)
    80002c68:	7ba8                	ld	a0,112(a5)
  case 5:
    return p->trapframe->a5;
  }
  panic("argraw");
  return -1;
}
    80002c6a:	60e2                	ld	ra,24(sp)
    80002c6c:	6442                	ld	s0,16(sp)
    80002c6e:	64a2                	ld	s1,8(sp)
    80002c70:	6105                	addi	sp,sp,32
    80002c72:	8082                	ret
    return p->trapframe->a1;
    80002c74:	6d3c                	ld	a5,88(a0)
    80002c76:	7fa8                	ld	a0,120(a5)
    80002c78:	bfcd                	j	80002c6a <argraw+0x30>
    return p->trapframe->a2;
    80002c7a:	6d3c                	ld	a5,88(a0)
    80002c7c:	63c8                	ld	a0,128(a5)
    80002c7e:	b7f5                	j	80002c6a <argraw+0x30>
    return p->trapframe->a3;
    80002c80:	6d3c                	ld	a5,88(a0)
    80002c82:	67c8                	ld	a0,136(a5)
    80002c84:	b7dd                	j	80002c6a <argraw+0x30>
    return p->trapframe->a4;
    80002c86:	6d3c                	ld	a5,88(a0)
    80002c88:	6bc8                	ld	a0,144(a5)
    80002c8a:	b7c5                	j	80002c6a <argraw+0x30>
    return p->trapframe->a5;
    80002c8c:	6d3c                	ld	a5,88(a0)
    80002c8e:	6fc8                	ld	a0,152(a5)
    80002c90:	bfe9                	j	80002c6a <argraw+0x30>
  panic("argraw");
    80002c92:	00005517          	auipc	a0,0x5
    80002c96:	77e50513          	addi	a0,a0,1918 # 80008410 <states.0+0x148>
    80002c9a:	ffffe097          	auipc	ra,0xffffe
    80002c9e:	8a6080e7          	jalr	-1882(ra) # 80000540 <panic>

0000000080002ca2 <fetchaddr>:
{
    80002ca2:	1101                	addi	sp,sp,-32
    80002ca4:	ec06                	sd	ra,24(sp)
    80002ca6:	e822                	sd	s0,16(sp)
    80002ca8:	e426                	sd	s1,8(sp)
    80002caa:	e04a                	sd	s2,0(sp)
    80002cac:	1000                	addi	s0,sp,32
    80002cae:	84aa                	mv	s1,a0
    80002cb0:	892e                	mv	s2,a1
  struct proc *p = myproc();
    80002cb2:	fffff097          	auipc	ra,0xfffff
    80002cb6:	cfa080e7          	jalr	-774(ra) # 800019ac <myproc>
  if(addr >= p->sz || addr+sizeof(uint64) > p->sz) // both tests needed, in case of overflow
    80002cba:	653c                	ld	a5,72(a0)
    80002cbc:	02f4f863          	bgeu	s1,a5,80002cec <fetchaddr+0x4a>
    80002cc0:	00848713          	addi	a4,s1,8
    80002cc4:	02e7e663          	bltu	a5,a4,80002cf0 <fetchaddr+0x4e>
  if(copyin(p->pagetable, (char *)ip, addr, sizeof(*ip)) != 0)
    80002cc8:	46a1                	li	a3,8
    80002cca:	8626                	mv	a2,s1
    80002ccc:	85ca                	mv	a1,s2
    80002cce:	6928                	ld	a0,80(a0)
    80002cd0:	fffff097          	auipc	ra,0xfffff
    80002cd4:	a28080e7          	jalr	-1496(ra) # 800016f8 <copyin>
    80002cd8:	00a03533          	snez	a0,a0
    80002cdc:	40a00533          	neg	a0,a0
}
    80002ce0:	60e2                	ld	ra,24(sp)
    80002ce2:	6442                	ld	s0,16(sp)
    80002ce4:	64a2                	ld	s1,8(sp)
    80002ce6:	6902                	ld	s2,0(sp)
    80002ce8:	6105                	addi	sp,sp,32
    80002cea:	8082                	ret
    return -1;
    80002cec:	557d                	li	a0,-1
    80002cee:	bfcd                	j	80002ce0 <fetchaddr+0x3e>
    80002cf0:	557d                	li	a0,-1
    80002cf2:	b7fd                	j	80002ce0 <fetchaddr+0x3e>

0000000080002cf4 <fetchstr>:
{
    80002cf4:	7179                	addi	sp,sp,-48
    80002cf6:	f406                	sd	ra,40(sp)
    80002cf8:	f022                	sd	s0,32(sp)
    80002cfa:	ec26                	sd	s1,24(sp)
    80002cfc:	e84a                	sd	s2,16(sp)
    80002cfe:	e44e                	sd	s3,8(sp)
    80002d00:	1800                	addi	s0,sp,48
    80002d02:	892a                	mv	s2,a0
    80002d04:	84ae                	mv	s1,a1
    80002d06:	89b2                	mv	s3,a2
  struct proc *p = myproc();
    80002d08:	fffff097          	auipc	ra,0xfffff
    80002d0c:	ca4080e7          	jalr	-860(ra) # 800019ac <myproc>
  if(copyinstr(p->pagetable, buf, addr, max) < 0)
    80002d10:	86ce                	mv	a3,s3
    80002d12:	864a                	mv	a2,s2
    80002d14:	85a6                	mv	a1,s1
    80002d16:	6928                	ld	a0,80(a0)
    80002d18:	fffff097          	auipc	ra,0xfffff
    80002d1c:	a6e080e7          	jalr	-1426(ra) # 80001786 <copyinstr>
    80002d20:	00054e63          	bltz	a0,80002d3c <fetchstr+0x48>
  return strlen(buf);
    80002d24:	8526                	mv	a0,s1
    80002d26:	ffffe097          	auipc	ra,0xffffe
    80002d2a:	128080e7          	jalr	296(ra) # 80000e4e <strlen>
}
    80002d2e:	70a2                	ld	ra,40(sp)
    80002d30:	7402                	ld	s0,32(sp)
    80002d32:	64e2                	ld	s1,24(sp)
    80002d34:	6942                	ld	s2,16(sp)
    80002d36:	69a2                	ld	s3,8(sp)
    80002d38:	6145                	addi	sp,sp,48
    80002d3a:	8082                	ret
    return -1;
    80002d3c:	557d                	li	a0,-1
    80002d3e:	bfc5                	j	80002d2e <fetchstr+0x3a>

0000000080002d40 <argint>:

// Fetch the nth 32-bit system call argument.
void
argint(int n, int *ip)
{
    80002d40:	1101                	addi	sp,sp,-32
    80002d42:	ec06                	sd	ra,24(sp)
    80002d44:	e822                	sd	s0,16(sp)
    80002d46:	e426                	sd	s1,8(sp)
    80002d48:	1000                	addi	s0,sp,32
    80002d4a:	84ae                	mv	s1,a1
  *ip = argraw(n);
    80002d4c:	00000097          	auipc	ra,0x0
    80002d50:	eee080e7          	jalr	-274(ra) # 80002c3a <argraw>
    80002d54:	c088                	sw	a0,0(s1)
}
    80002d56:	60e2                	ld	ra,24(sp)
    80002d58:	6442                	ld	s0,16(sp)
    80002d5a:	64a2                	ld	s1,8(sp)
    80002d5c:	6105                	addi	sp,sp,32
    80002d5e:	8082                	ret

0000000080002d60 <argaddr>:
// Retrieve an argument as a pointer.
// Doesn't check for legality, since
// copyin/copyout will do that.
void
argaddr(int n, uint64 *ip)
{
    80002d60:	1101                	addi	sp,sp,-32
    80002d62:	ec06                	sd	ra,24(sp)
    80002d64:	e822                	sd	s0,16(sp)
    80002d66:	e426                	sd	s1,8(sp)
    80002d68:	1000                	addi	s0,sp,32
    80002d6a:	84ae                	mv	s1,a1
  *ip = argraw(n);
    80002d6c:	00000097          	auipc	ra,0x0
    80002d70:	ece080e7          	jalr	-306(ra) # 80002c3a <argraw>
    80002d74:	e088                	sd	a0,0(s1)
}
    80002d76:	60e2                	ld	ra,24(sp)
    80002d78:	6442                	ld	s0,16(sp)
    80002d7a:	64a2                	ld	s1,8(sp)
    80002d7c:	6105                	addi	sp,sp,32
    80002d7e:	8082                	ret

0000000080002d80 <argstr>:
// Fetch the nth word-sized system call argument as a null-terminated string.
// Copies into buf, at most max.
// Returns string length if OK (including nul), -1 if error.
int
argstr(int n, char *buf, int max)
{
    80002d80:	7179                	addi	sp,sp,-48
    80002d82:	f406                	sd	ra,40(sp)
    80002d84:	f022                	sd	s0,32(sp)
    80002d86:	ec26                	sd	s1,24(sp)
    80002d88:	e84a                	sd	s2,16(sp)
    80002d8a:	1800                	addi	s0,sp,48
    80002d8c:	84ae                	mv	s1,a1
    80002d8e:	8932                	mv	s2,a2
  uint64 addr;
  argaddr(n, &addr);
    80002d90:	fd840593          	addi	a1,s0,-40
    80002d94:	00000097          	auipc	ra,0x0
    80002d98:	fcc080e7          	jalr	-52(ra) # 80002d60 <argaddr>
  return fetchstr(addr, buf, max);
    80002d9c:	864a                	mv	a2,s2
    80002d9e:	85a6                	mv	a1,s1
    80002da0:	fd843503          	ld	a0,-40(s0)
    80002da4:	00000097          	auipc	ra,0x0
    80002da8:	f50080e7          	jalr	-176(ra) # 80002cf4 <fetchstr>
}
    80002dac:	70a2                	ld	ra,40(sp)
    80002dae:	7402                	ld	s0,32(sp)
    80002db0:	64e2                	ld	s1,24(sp)
    80002db2:	6942                	ld	s2,16(sp)
    80002db4:	6145                	addi	sp,sp,48
    80002db6:	8082                	ret

0000000080002db8 <syscall>:
[SYS_clone]   sys_clone,
};

void
syscall(void)
{
    80002db8:	1101                	addi	sp,sp,-32
    80002dba:	ec06                	sd	ra,24(sp)
    80002dbc:	e822                	sd	s0,16(sp)
    80002dbe:	e426                	sd	s1,8(sp)
    80002dc0:	e04a                	sd	s2,0(sp)
    80002dc2:	1000                	addi	s0,sp,32
  int num;
  struct proc *p = myproc();
    80002dc4:	fffff097          	auipc	ra,0xfffff
    80002dc8:	be8080e7          	jalr	-1048(ra) # 800019ac <myproc>
    80002dcc:	84aa                	mv	s1,a0

  num = p->trapframe->a7;
    80002dce:	05853903          	ld	s2,88(a0)
    80002dd2:	0a893783          	ld	a5,168(s2)
    80002dd6:	0007869b          	sext.w	a3,a5
  if(num > 0 && num < NELEM(syscalls) && syscalls[num]) {
    80002dda:	37fd                	addiw	a5,a5,-1
    80002ddc:	4755                	li	a4,21
    80002dde:	00f76f63          	bltu	a4,a5,80002dfc <syscall+0x44>
    80002de2:	00369713          	slli	a4,a3,0x3
    80002de6:	00005797          	auipc	a5,0x5
    80002dea:	66a78793          	addi	a5,a5,1642 # 80008450 <syscalls>
    80002dee:	97ba                	add	a5,a5,a4
    80002df0:	639c                	ld	a5,0(a5)
    80002df2:	c789                	beqz	a5,80002dfc <syscall+0x44>
    // Use num to lookup the system call function for num, call it,
    // and store its return value in p->trapframe->a0
    p->trapframe->a0 = syscalls[num]();
    80002df4:	9782                	jalr	a5
    80002df6:	06a93823          	sd	a0,112(s2)
    80002dfa:	a839                	j	80002e18 <syscall+0x60>
  } else {
    printf("%d %s: unknown sys call %d\n",
    80002dfc:	15848613          	addi	a2,s1,344
    80002e00:	588c                	lw	a1,48(s1)
    80002e02:	00005517          	auipc	a0,0x5
    80002e06:	61650513          	addi	a0,a0,1558 # 80008418 <states.0+0x150>
    80002e0a:	ffffd097          	auipc	ra,0xffffd
    80002e0e:	780080e7          	jalr	1920(ra) # 8000058a <printf>
            p->pid, p->name, num);
    p->trapframe->a0 = -1;
    80002e12:	6cbc                	ld	a5,88(s1)
    80002e14:	577d                	li	a4,-1
    80002e16:	fbb8                	sd	a4,112(a5)
  }
}
    80002e18:	60e2                	ld	ra,24(sp)
    80002e1a:	6442                	ld	s0,16(sp)
    80002e1c:	64a2                	ld	s1,8(sp)
    80002e1e:	6902                	ld	s2,0(sp)
    80002e20:	6105                	addi	sp,sp,32
    80002e22:	8082                	ret

0000000080002e24 <sys_exit>:
#include "spinlock.h"
#include "proc.h"

uint64
sys_exit(void)
{
    80002e24:	1101                	addi	sp,sp,-32
    80002e26:	ec06                	sd	ra,24(sp)
    80002e28:	e822                	sd	s0,16(sp)
    80002e2a:	1000                	addi	s0,sp,32
  int n;
  argint(0, &n);
    80002e2c:	fec40593          	addi	a1,s0,-20
    80002e30:	4501                	li	a0,0
    80002e32:	00000097          	auipc	ra,0x0
    80002e36:	f0e080e7          	jalr	-242(ra) # 80002d40 <argint>
  exit(n);
    80002e3a:	fec42503          	lw	a0,-20(s0)
    80002e3e:	fffff097          	auipc	ra,0xfffff
    80002e42:	3b8080e7          	jalr	952(ra) # 800021f6 <exit>
  return 0;  // not reached
}
    80002e46:	4501                	li	a0,0
    80002e48:	60e2                	ld	ra,24(sp)
    80002e4a:	6442                	ld	s0,16(sp)
    80002e4c:	6105                	addi	sp,sp,32
    80002e4e:	8082                	ret

0000000080002e50 <sys_getpid>:

uint64
sys_getpid(void)
{
    80002e50:	1141                	addi	sp,sp,-16
    80002e52:	e406                	sd	ra,8(sp)
    80002e54:	e022                	sd	s0,0(sp)
    80002e56:	0800                	addi	s0,sp,16
  return myproc()->pid;
    80002e58:	fffff097          	auipc	ra,0xfffff
    80002e5c:	b54080e7          	jalr	-1196(ra) # 800019ac <myproc>
}
    80002e60:	5908                	lw	a0,48(a0)
    80002e62:	60a2                	ld	ra,8(sp)
    80002e64:	6402                	ld	s0,0(sp)
    80002e66:	0141                	addi	sp,sp,16
    80002e68:	8082                	ret

0000000080002e6a <sys_fork>:

uint64
sys_fork(void)
{
    80002e6a:	1141                	addi	sp,sp,-16
    80002e6c:	e406                	sd	ra,8(sp)
    80002e6e:	e022                	sd	s0,0(sp)
    80002e70:	0800                	addi	s0,sp,16
  return fork();
    80002e72:	fffff097          	auipc	ra,0xfffff
    80002e76:	f5e080e7          	jalr	-162(ra) # 80001dd0 <fork>
}
    80002e7a:	60a2                	ld	ra,8(sp)
    80002e7c:	6402                	ld	s0,0(sp)
    80002e7e:	0141                	addi	sp,sp,16
    80002e80:	8082                	ret

0000000080002e82 <sys_wait>:

uint64
sys_wait(void)
{
    80002e82:	1101                	addi	sp,sp,-32
    80002e84:	ec06                	sd	ra,24(sp)
    80002e86:	e822                	sd	s0,16(sp)
    80002e88:	1000                	addi	s0,sp,32
  uint64 p;
  argaddr(0, &p);
    80002e8a:	fe840593          	addi	a1,s0,-24
    80002e8e:	4501                	li	a0,0
    80002e90:	00000097          	auipc	ra,0x0
    80002e94:	ed0080e7          	jalr	-304(ra) # 80002d60 <argaddr>
  return wait(p);
    80002e98:	fe843503          	ld	a0,-24(s0)
    80002e9c:	fffff097          	auipc	ra,0xfffff
    80002ea0:	508080e7          	jalr	1288(ra) # 800023a4 <wait>
}
    80002ea4:	60e2                	ld	ra,24(sp)
    80002ea6:	6442                	ld	s0,16(sp)
    80002ea8:	6105                	addi	sp,sp,32
    80002eaa:	8082                	ret

0000000080002eac <sys_sbrk>:

uint64
sys_sbrk(void)
{
    80002eac:	7179                	addi	sp,sp,-48
    80002eae:	f406                	sd	ra,40(sp)
    80002eb0:	f022                	sd	s0,32(sp)
    80002eb2:	ec26                	sd	s1,24(sp)
    80002eb4:	1800                	addi	s0,sp,48
  uint64 addr;
  int n;

  argint(0, &n);
    80002eb6:	fdc40593          	addi	a1,s0,-36
    80002eba:	4501                	li	a0,0
    80002ebc:	00000097          	auipc	ra,0x0
    80002ec0:	e84080e7          	jalr	-380(ra) # 80002d40 <argint>
  addr = myproc()->sz;
    80002ec4:	fffff097          	auipc	ra,0xfffff
    80002ec8:	ae8080e7          	jalr	-1304(ra) # 800019ac <myproc>
    80002ecc:	6524                	ld	s1,72(a0)
  if(growproc(n) < 0)
    80002ece:	fdc42503          	lw	a0,-36(s0)
    80002ed2:	fffff097          	auipc	ra,0xfffff
    80002ed6:	ea2080e7          	jalr	-350(ra) # 80001d74 <growproc>
    80002eda:	00054863          	bltz	a0,80002eea <sys_sbrk+0x3e>
    return -1;
  return addr;
}
    80002ede:	8526                	mv	a0,s1
    80002ee0:	70a2                	ld	ra,40(sp)
    80002ee2:	7402                	ld	s0,32(sp)
    80002ee4:	64e2                	ld	s1,24(sp)
    80002ee6:	6145                	addi	sp,sp,48
    80002ee8:	8082                	ret
    return -1;
    80002eea:	54fd                	li	s1,-1
    80002eec:	bfcd                	j	80002ede <sys_sbrk+0x32>

0000000080002eee <sys_sleep>:

uint64
sys_sleep(void)
{
    80002eee:	7139                	addi	sp,sp,-64
    80002ef0:	fc06                	sd	ra,56(sp)
    80002ef2:	f822                	sd	s0,48(sp)
    80002ef4:	f426                	sd	s1,40(sp)
    80002ef6:	f04a                	sd	s2,32(sp)
    80002ef8:	ec4e                	sd	s3,24(sp)
    80002efa:	0080                	addi	s0,sp,64
  int n;
  uint ticks0;

  argint(0, &n);
    80002efc:	fcc40593          	addi	a1,s0,-52
    80002f00:	4501                	li	a0,0
    80002f02:	00000097          	auipc	ra,0x0
    80002f06:	e3e080e7          	jalr	-450(ra) # 80002d40 <argint>
  acquire(&tickslock);
    80002f0a:	00014517          	auipc	a0,0x14
    80002f0e:	c9e50513          	addi	a0,a0,-866 # 80016ba8 <tickslock>
    80002f12:	ffffe097          	auipc	ra,0xffffe
    80002f16:	cc4080e7          	jalr	-828(ra) # 80000bd6 <acquire>
  ticks0 = ticks;
    80002f1a:	00006917          	auipc	s2,0x6
    80002f1e:	9d692903          	lw	s2,-1578(s2) # 800088f0 <ticks>
  while(ticks - ticks0 < n){
    80002f22:	fcc42783          	lw	a5,-52(s0)
    80002f26:	cf9d                	beqz	a5,80002f64 <sys_sleep+0x76>
    if(killed(myproc())){
      release(&tickslock);
      return -1;
    }
    sleep(&ticks, &tickslock);
    80002f28:	00014997          	auipc	s3,0x14
    80002f2c:	c8098993          	addi	s3,s3,-896 # 80016ba8 <tickslock>
    80002f30:	00006497          	auipc	s1,0x6
    80002f34:	9c048493          	addi	s1,s1,-1600 # 800088f0 <ticks>
    if(killed(myproc())){
    80002f38:	fffff097          	auipc	ra,0xfffff
    80002f3c:	a74080e7          	jalr	-1420(ra) # 800019ac <myproc>
    80002f40:	fffff097          	auipc	ra,0xfffff
    80002f44:	432080e7          	jalr	1074(ra) # 80002372 <killed>
    80002f48:	ed15                	bnez	a0,80002f84 <sys_sleep+0x96>
    sleep(&ticks, &tickslock);
    80002f4a:	85ce                	mv	a1,s3
    80002f4c:	8526                	mv	a0,s1
    80002f4e:	fffff097          	auipc	ra,0xfffff
    80002f52:	174080e7          	jalr	372(ra) # 800020c2 <sleep>
  while(ticks - ticks0 < n){
    80002f56:	409c                	lw	a5,0(s1)
    80002f58:	412787bb          	subw	a5,a5,s2
    80002f5c:	fcc42703          	lw	a4,-52(s0)
    80002f60:	fce7ece3          	bltu	a5,a4,80002f38 <sys_sleep+0x4a>
  }
  release(&tickslock);
    80002f64:	00014517          	auipc	a0,0x14
    80002f68:	c4450513          	addi	a0,a0,-956 # 80016ba8 <tickslock>
    80002f6c:	ffffe097          	auipc	ra,0xffffe
    80002f70:	d1e080e7          	jalr	-738(ra) # 80000c8a <release>
  return 0;
    80002f74:	4501                	li	a0,0
}
    80002f76:	70e2                	ld	ra,56(sp)
    80002f78:	7442                	ld	s0,48(sp)
    80002f7a:	74a2                	ld	s1,40(sp)
    80002f7c:	7902                	ld	s2,32(sp)
    80002f7e:	69e2                	ld	s3,24(sp)
    80002f80:	6121                	addi	sp,sp,64
    80002f82:	8082                	ret
      release(&tickslock);
    80002f84:	00014517          	auipc	a0,0x14
    80002f88:	c2450513          	addi	a0,a0,-988 # 80016ba8 <tickslock>
    80002f8c:	ffffe097          	auipc	ra,0xffffe
    80002f90:	cfe080e7          	jalr	-770(ra) # 80000c8a <release>
      return -1;
    80002f94:	557d                	li	a0,-1
    80002f96:	b7c5                	j	80002f76 <sys_sleep+0x88>

0000000080002f98 <sys_kill>:

uint64
sys_kill(void)
{
    80002f98:	1101                	addi	sp,sp,-32
    80002f9a:	ec06                	sd	ra,24(sp)
    80002f9c:	e822                	sd	s0,16(sp)
    80002f9e:	1000                	addi	s0,sp,32
  int pid;

  argint(0, &pid);
    80002fa0:	fec40593          	addi	a1,s0,-20
    80002fa4:	4501                	li	a0,0
    80002fa6:	00000097          	auipc	ra,0x0
    80002faa:	d9a080e7          	jalr	-614(ra) # 80002d40 <argint>
  return kill(pid);
    80002fae:	fec42503          	lw	a0,-20(s0)
    80002fb2:	fffff097          	auipc	ra,0xfffff
    80002fb6:	322080e7          	jalr	802(ra) # 800022d4 <kill>
}
    80002fba:	60e2                	ld	ra,24(sp)
    80002fbc:	6442                	ld	s0,16(sp)
    80002fbe:	6105                	addi	sp,sp,32
    80002fc0:	8082                	ret

0000000080002fc2 <sys_uptime>:

// return how many clock tick interrupts have occurred
// since start.
uint64
sys_uptime(void)
{
    80002fc2:	1101                	addi	sp,sp,-32
    80002fc4:	ec06                	sd	ra,24(sp)
    80002fc6:	e822                	sd	s0,16(sp)
    80002fc8:	e426                	sd	s1,8(sp)
    80002fca:	1000                	addi	s0,sp,32
  uint xticks;

  acquire(&tickslock);
    80002fcc:	00014517          	auipc	a0,0x14
    80002fd0:	bdc50513          	addi	a0,a0,-1060 # 80016ba8 <tickslock>
    80002fd4:	ffffe097          	auipc	ra,0xffffe
    80002fd8:	c02080e7          	jalr	-1022(ra) # 80000bd6 <acquire>
  xticks = ticks;
    80002fdc:	00006497          	auipc	s1,0x6
    80002fe0:	9144a483          	lw	s1,-1772(s1) # 800088f0 <ticks>
  release(&tickslock);
    80002fe4:	00014517          	auipc	a0,0x14
    80002fe8:	bc450513          	addi	a0,a0,-1084 # 80016ba8 <tickslock>
    80002fec:	ffffe097          	auipc	ra,0xffffe
    80002ff0:	c9e080e7          	jalr	-866(ra) # 80000c8a <release>
  return xticks;
}
    80002ff4:	02049513          	slli	a0,s1,0x20
    80002ff8:	9101                	srli	a0,a0,0x20
    80002ffa:	60e2                	ld	ra,24(sp)
    80002ffc:	6442                	ld	s0,16(sp)
    80002ffe:	64a2                	ld	s1,8(sp)
    80003000:	6105                	addi	sp,sp,32
    80003002:	8082                	ret

0000000080003004 <sys_clone>:

uint64 sys_clone(void){
    80003004:	1101                	addi	sp,sp,-32
    80003006:	ec06                	sd	ra,24(sp)
    80003008:	e822                	sd	s0,16(sp)
    8000300a:	1000                	addi	s0,sp,32
  uint64 stack_address;
  int size;
  argaddr(0,&stack_address);
    8000300c:	fe840593          	addi	a1,s0,-24
    80003010:	4501                	li	a0,0
    80003012:	00000097          	auipc	ra,0x0
    80003016:	d4e080e7          	jalr	-690(ra) # 80002d60 <argaddr>
  argint(1,&size);
    8000301a:	fe440593          	addi	a1,s0,-28
    8000301e:	4505                	li	a0,1
    80003020:	00000097          	auipc	ra,0x0
    80003024:	d20080e7          	jalr	-736(ra) # 80002d40 <argint>
  return clone_process((void *)stack_address,size);
    80003028:	fe442583          	lw	a1,-28(s0)
    8000302c:	fe843503          	ld	a0,-24(s0)
    80003030:	fffff097          	auipc	ra,0xfffff
    80003034:	5fe080e7          	jalr	1534(ra) # 8000262e <clone_process>
}
    80003038:	60e2                	ld	ra,24(sp)
    8000303a:	6442                	ld	s0,16(sp)
    8000303c:	6105                	addi	sp,sp,32
    8000303e:	8082                	ret

0000000080003040 <binit>:
  struct buf head;
} bcache;

void
binit(void)
{
    80003040:	7179                	addi	sp,sp,-48
    80003042:	f406                	sd	ra,40(sp)
    80003044:	f022                	sd	s0,32(sp)
    80003046:	ec26                	sd	s1,24(sp)
    80003048:	e84a                	sd	s2,16(sp)
    8000304a:	e44e                	sd	s3,8(sp)
    8000304c:	e052                	sd	s4,0(sp)
    8000304e:	1800                	addi	s0,sp,48
  struct buf *b;

  initlock(&bcache.lock, "bcache");
    80003050:	00005597          	auipc	a1,0x5
    80003054:	4b858593          	addi	a1,a1,1208 # 80008508 <syscalls+0xb8>
    80003058:	00014517          	auipc	a0,0x14
    8000305c:	b6850513          	addi	a0,a0,-1176 # 80016bc0 <bcache>
    80003060:	ffffe097          	auipc	ra,0xffffe
    80003064:	ae6080e7          	jalr	-1306(ra) # 80000b46 <initlock>

  // Create linked list of buffers
  bcache.head.prev = &bcache.head;
    80003068:	0001c797          	auipc	a5,0x1c
    8000306c:	b5878793          	addi	a5,a5,-1192 # 8001ebc0 <bcache+0x8000>
    80003070:	0001c717          	auipc	a4,0x1c
    80003074:	db870713          	addi	a4,a4,-584 # 8001ee28 <bcache+0x8268>
    80003078:	2ae7b823          	sd	a4,688(a5)
  bcache.head.next = &bcache.head;
    8000307c:	2ae7bc23          	sd	a4,696(a5)
  for(b = bcache.buf; b < bcache.buf+NBUF; b++){
    80003080:	00014497          	auipc	s1,0x14
    80003084:	b5848493          	addi	s1,s1,-1192 # 80016bd8 <bcache+0x18>
    b->next = bcache.head.next;
    80003088:	893e                	mv	s2,a5
    b->prev = &bcache.head;
    8000308a:	89ba                	mv	s3,a4
    initsleeplock(&b->lock, "buffer");
    8000308c:	00005a17          	auipc	s4,0x5
    80003090:	484a0a13          	addi	s4,s4,1156 # 80008510 <syscalls+0xc0>
    b->next = bcache.head.next;
    80003094:	2b893783          	ld	a5,696(s2)
    80003098:	e8bc                	sd	a5,80(s1)
    b->prev = &bcache.head;
    8000309a:	0534b423          	sd	s3,72(s1)
    initsleeplock(&b->lock, "buffer");
    8000309e:	85d2                	mv	a1,s4
    800030a0:	01048513          	addi	a0,s1,16
    800030a4:	00001097          	auipc	ra,0x1
    800030a8:	4c8080e7          	jalr	1224(ra) # 8000456c <initsleeplock>
    bcache.head.next->prev = b;
    800030ac:	2b893783          	ld	a5,696(s2)
    800030b0:	e7a4                	sd	s1,72(a5)
    bcache.head.next = b;
    800030b2:	2a993c23          	sd	s1,696(s2)
  for(b = bcache.buf; b < bcache.buf+NBUF; b++){
    800030b6:	45848493          	addi	s1,s1,1112
    800030ba:	fd349de3          	bne	s1,s3,80003094 <binit+0x54>
  }
}
    800030be:	70a2                	ld	ra,40(sp)
    800030c0:	7402                	ld	s0,32(sp)
    800030c2:	64e2                	ld	s1,24(sp)
    800030c4:	6942                	ld	s2,16(sp)
    800030c6:	69a2                	ld	s3,8(sp)
    800030c8:	6a02                	ld	s4,0(sp)
    800030ca:	6145                	addi	sp,sp,48
    800030cc:	8082                	ret

00000000800030ce <bread>:
}

// Return a locked buf with the contents of the indicated block.
struct buf*
bread(uint dev, uint blockno)
{
    800030ce:	7179                	addi	sp,sp,-48
    800030d0:	f406                	sd	ra,40(sp)
    800030d2:	f022                	sd	s0,32(sp)
    800030d4:	ec26                	sd	s1,24(sp)
    800030d6:	e84a                	sd	s2,16(sp)
    800030d8:	e44e                	sd	s3,8(sp)
    800030da:	1800                	addi	s0,sp,48
    800030dc:	892a                	mv	s2,a0
    800030de:	89ae                	mv	s3,a1
  acquire(&bcache.lock);
    800030e0:	00014517          	auipc	a0,0x14
    800030e4:	ae050513          	addi	a0,a0,-1312 # 80016bc0 <bcache>
    800030e8:	ffffe097          	auipc	ra,0xffffe
    800030ec:	aee080e7          	jalr	-1298(ra) # 80000bd6 <acquire>
  for(b = bcache.head.next; b != &bcache.head; b = b->next){
    800030f0:	0001c497          	auipc	s1,0x1c
    800030f4:	d884b483          	ld	s1,-632(s1) # 8001ee78 <bcache+0x82b8>
    800030f8:	0001c797          	auipc	a5,0x1c
    800030fc:	d3078793          	addi	a5,a5,-720 # 8001ee28 <bcache+0x8268>
    80003100:	02f48f63          	beq	s1,a5,8000313e <bread+0x70>
    80003104:	873e                	mv	a4,a5
    80003106:	a021                	j	8000310e <bread+0x40>
    80003108:	68a4                	ld	s1,80(s1)
    8000310a:	02e48a63          	beq	s1,a4,8000313e <bread+0x70>
    if(b->dev == dev && b->blockno == blockno){
    8000310e:	449c                	lw	a5,8(s1)
    80003110:	ff279ce3          	bne	a5,s2,80003108 <bread+0x3a>
    80003114:	44dc                	lw	a5,12(s1)
    80003116:	ff3799e3          	bne	a5,s3,80003108 <bread+0x3a>
      b->refcnt++;
    8000311a:	40bc                	lw	a5,64(s1)
    8000311c:	2785                	addiw	a5,a5,1
    8000311e:	c0bc                	sw	a5,64(s1)
      release(&bcache.lock);
    80003120:	00014517          	auipc	a0,0x14
    80003124:	aa050513          	addi	a0,a0,-1376 # 80016bc0 <bcache>
    80003128:	ffffe097          	auipc	ra,0xffffe
    8000312c:	b62080e7          	jalr	-1182(ra) # 80000c8a <release>
      acquiresleep(&b->lock);
    80003130:	01048513          	addi	a0,s1,16
    80003134:	00001097          	auipc	ra,0x1
    80003138:	472080e7          	jalr	1138(ra) # 800045a6 <acquiresleep>
      return b;
    8000313c:	a8b9                	j	8000319a <bread+0xcc>
  for(b = bcache.head.prev; b != &bcache.head; b = b->prev){
    8000313e:	0001c497          	auipc	s1,0x1c
    80003142:	d324b483          	ld	s1,-718(s1) # 8001ee70 <bcache+0x82b0>
    80003146:	0001c797          	auipc	a5,0x1c
    8000314a:	ce278793          	addi	a5,a5,-798 # 8001ee28 <bcache+0x8268>
    8000314e:	00f48863          	beq	s1,a5,8000315e <bread+0x90>
    80003152:	873e                	mv	a4,a5
    if(b->refcnt == 0) {
    80003154:	40bc                	lw	a5,64(s1)
    80003156:	cf81                	beqz	a5,8000316e <bread+0xa0>
  for(b = bcache.head.prev; b != &bcache.head; b = b->prev){
    80003158:	64a4                	ld	s1,72(s1)
    8000315a:	fee49de3          	bne	s1,a4,80003154 <bread+0x86>
  panic("bget: no buffers");
    8000315e:	00005517          	auipc	a0,0x5
    80003162:	3ba50513          	addi	a0,a0,954 # 80008518 <syscalls+0xc8>
    80003166:	ffffd097          	auipc	ra,0xffffd
    8000316a:	3da080e7          	jalr	986(ra) # 80000540 <panic>
      b->dev = dev;
    8000316e:	0124a423          	sw	s2,8(s1)
      b->blockno = blockno;
    80003172:	0134a623          	sw	s3,12(s1)
      b->valid = 0;
    80003176:	0004a023          	sw	zero,0(s1)
      b->refcnt = 1;
    8000317a:	4785                	li	a5,1
    8000317c:	c0bc                	sw	a5,64(s1)
      release(&bcache.lock);
    8000317e:	00014517          	auipc	a0,0x14
    80003182:	a4250513          	addi	a0,a0,-1470 # 80016bc0 <bcache>
    80003186:	ffffe097          	auipc	ra,0xffffe
    8000318a:	b04080e7          	jalr	-1276(ra) # 80000c8a <release>
      acquiresleep(&b->lock);
    8000318e:	01048513          	addi	a0,s1,16
    80003192:	00001097          	auipc	ra,0x1
    80003196:	414080e7          	jalr	1044(ra) # 800045a6 <acquiresleep>
  struct buf *b;

  b = bget(dev, blockno);
  if(!b->valid) {
    8000319a:	409c                	lw	a5,0(s1)
    8000319c:	cb89                	beqz	a5,800031ae <bread+0xe0>
    virtio_disk_rw(b, 0);
    b->valid = 1;
  }
  return b;
}
    8000319e:	8526                	mv	a0,s1
    800031a0:	70a2                	ld	ra,40(sp)
    800031a2:	7402                	ld	s0,32(sp)
    800031a4:	64e2                	ld	s1,24(sp)
    800031a6:	6942                	ld	s2,16(sp)
    800031a8:	69a2                	ld	s3,8(sp)
    800031aa:	6145                	addi	sp,sp,48
    800031ac:	8082                	ret
    virtio_disk_rw(b, 0);
    800031ae:	4581                	li	a1,0
    800031b0:	8526                	mv	a0,s1
    800031b2:	00003097          	auipc	ra,0x3
    800031b6:	fe0080e7          	jalr	-32(ra) # 80006192 <virtio_disk_rw>
    b->valid = 1;
    800031ba:	4785                	li	a5,1
    800031bc:	c09c                	sw	a5,0(s1)
  return b;
    800031be:	b7c5                	j	8000319e <bread+0xd0>

00000000800031c0 <bwrite>:

// Write b's contents to disk.  Must be locked.
void
bwrite(struct buf *b)
{
    800031c0:	1101                	addi	sp,sp,-32
    800031c2:	ec06                	sd	ra,24(sp)
    800031c4:	e822                	sd	s0,16(sp)
    800031c6:	e426                	sd	s1,8(sp)
    800031c8:	1000                	addi	s0,sp,32
    800031ca:	84aa                	mv	s1,a0
  if(!holdingsleep(&b->lock))
    800031cc:	0541                	addi	a0,a0,16
    800031ce:	00001097          	auipc	ra,0x1
    800031d2:	472080e7          	jalr	1138(ra) # 80004640 <holdingsleep>
    800031d6:	cd01                	beqz	a0,800031ee <bwrite+0x2e>
    panic("bwrite");
  virtio_disk_rw(b, 1);
    800031d8:	4585                	li	a1,1
    800031da:	8526                	mv	a0,s1
    800031dc:	00003097          	auipc	ra,0x3
    800031e0:	fb6080e7          	jalr	-74(ra) # 80006192 <virtio_disk_rw>
}
    800031e4:	60e2                	ld	ra,24(sp)
    800031e6:	6442                	ld	s0,16(sp)
    800031e8:	64a2                	ld	s1,8(sp)
    800031ea:	6105                	addi	sp,sp,32
    800031ec:	8082                	ret
    panic("bwrite");
    800031ee:	00005517          	auipc	a0,0x5
    800031f2:	34250513          	addi	a0,a0,834 # 80008530 <syscalls+0xe0>
    800031f6:	ffffd097          	auipc	ra,0xffffd
    800031fa:	34a080e7          	jalr	842(ra) # 80000540 <panic>

00000000800031fe <brelse>:

// Release a locked buffer.
// Move to the head of the most-recently-used list.
void
brelse(struct buf *b)
{
    800031fe:	1101                	addi	sp,sp,-32
    80003200:	ec06                	sd	ra,24(sp)
    80003202:	e822                	sd	s0,16(sp)
    80003204:	e426                	sd	s1,8(sp)
    80003206:	e04a                	sd	s2,0(sp)
    80003208:	1000                	addi	s0,sp,32
    8000320a:	84aa                	mv	s1,a0
  if(!holdingsleep(&b->lock))
    8000320c:	01050913          	addi	s2,a0,16
    80003210:	854a                	mv	a0,s2
    80003212:	00001097          	auipc	ra,0x1
    80003216:	42e080e7          	jalr	1070(ra) # 80004640 <holdingsleep>
    8000321a:	c92d                	beqz	a0,8000328c <brelse+0x8e>
    panic("brelse");

  releasesleep(&b->lock);
    8000321c:	854a                	mv	a0,s2
    8000321e:	00001097          	auipc	ra,0x1
    80003222:	3de080e7          	jalr	990(ra) # 800045fc <releasesleep>

  acquire(&bcache.lock);
    80003226:	00014517          	auipc	a0,0x14
    8000322a:	99a50513          	addi	a0,a0,-1638 # 80016bc0 <bcache>
    8000322e:	ffffe097          	auipc	ra,0xffffe
    80003232:	9a8080e7          	jalr	-1624(ra) # 80000bd6 <acquire>
  b->refcnt--;
    80003236:	40bc                	lw	a5,64(s1)
    80003238:	37fd                	addiw	a5,a5,-1
    8000323a:	0007871b          	sext.w	a4,a5
    8000323e:	c0bc                	sw	a5,64(s1)
  if (b->refcnt == 0) {
    80003240:	eb05                	bnez	a4,80003270 <brelse+0x72>
    // no one is waiting for it.
    b->next->prev = b->prev;
    80003242:	68bc                	ld	a5,80(s1)
    80003244:	64b8                	ld	a4,72(s1)
    80003246:	e7b8                	sd	a4,72(a5)
    b->prev->next = b->next;
    80003248:	64bc                	ld	a5,72(s1)
    8000324a:	68b8                	ld	a4,80(s1)
    8000324c:	ebb8                	sd	a4,80(a5)
    b->next = bcache.head.next;
    8000324e:	0001c797          	auipc	a5,0x1c
    80003252:	97278793          	addi	a5,a5,-1678 # 8001ebc0 <bcache+0x8000>
    80003256:	2b87b703          	ld	a4,696(a5)
    8000325a:	e8b8                	sd	a4,80(s1)
    b->prev = &bcache.head;
    8000325c:	0001c717          	auipc	a4,0x1c
    80003260:	bcc70713          	addi	a4,a4,-1076 # 8001ee28 <bcache+0x8268>
    80003264:	e4b8                	sd	a4,72(s1)
    bcache.head.next->prev = b;
    80003266:	2b87b703          	ld	a4,696(a5)
    8000326a:	e724                	sd	s1,72(a4)
    bcache.head.next = b;
    8000326c:	2a97bc23          	sd	s1,696(a5)
  }
  
  release(&bcache.lock);
    80003270:	00014517          	auipc	a0,0x14
    80003274:	95050513          	addi	a0,a0,-1712 # 80016bc0 <bcache>
    80003278:	ffffe097          	auipc	ra,0xffffe
    8000327c:	a12080e7          	jalr	-1518(ra) # 80000c8a <release>
}
    80003280:	60e2                	ld	ra,24(sp)
    80003282:	6442                	ld	s0,16(sp)
    80003284:	64a2                	ld	s1,8(sp)
    80003286:	6902                	ld	s2,0(sp)
    80003288:	6105                	addi	sp,sp,32
    8000328a:	8082                	ret
    panic("brelse");
    8000328c:	00005517          	auipc	a0,0x5
    80003290:	2ac50513          	addi	a0,a0,684 # 80008538 <syscalls+0xe8>
    80003294:	ffffd097          	auipc	ra,0xffffd
    80003298:	2ac080e7          	jalr	684(ra) # 80000540 <panic>

000000008000329c <bpin>:

void
bpin(struct buf *b) {
    8000329c:	1101                	addi	sp,sp,-32
    8000329e:	ec06                	sd	ra,24(sp)
    800032a0:	e822                	sd	s0,16(sp)
    800032a2:	e426                	sd	s1,8(sp)
    800032a4:	1000                	addi	s0,sp,32
    800032a6:	84aa                	mv	s1,a0
  acquire(&bcache.lock);
    800032a8:	00014517          	auipc	a0,0x14
    800032ac:	91850513          	addi	a0,a0,-1768 # 80016bc0 <bcache>
    800032b0:	ffffe097          	auipc	ra,0xffffe
    800032b4:	926080e7          	jalr	-1754(ra) # 80000bd6 <acquire>
  b->refcnt++;
    800032b8:	40bc                	lw	a5,64(s1)
    800032ba:	2785                	addiw	a5,a5,1
    800032bc:	c0bc                	sw	a5,64(s1)
  release(&bcache.lock);
    800032be:	00014517          	auipc	a0,0x14
    800032c2:	90250513          	addi	a0,a0,-1790 # 80016bc0 <bcache>
    800032c6:	ffffe097          	auipc	ra,0xffffe
    800032ca:	9c4080e7          	jalr	-1596(ra) # 80000c8a <release>
}
    800032ce:	60e2                	ld	ra,24(sp)
    800032d0:	6442                	ld	s0,16(sp)
    800032d2:	64a2                	ld	s1,8(sp)
    800032d4:	6105                	addi	sp,sp,32
    800032d6:	8082                	ret

00000000800032d8 <bunpin>:

void
bunpin(struct buf *b) {
    800032d8:	1101                	addi	sp,sp,-32
    800032da:	ec06                	sd	ra,24(sp)
    800032dc:	e822                	sd	s0,16(sp)
    800032de:	e426                	sd	s1,8(sp)
    800032e0:	1000                	addi	s0,sp,32
    800032e2:	84aa                	mv	s1,a0
  acquire(&bcache.lock);
    800032e4:	00014517          	auipc	a0,0x14
    800032e8:	8dc50513          	addi	a0,a0,-1828 # 80016bc0 <bcache>
    800032ec:	ffffe097          	auipc	ra,0xffffe
    800032f0:	8ea080e7          	jalr	-1814(ra) # 80000bd6 <acquire>
  b->refcnt--;
    800032f4:	40bc                	lw	a5,64(s1)
    800032f6:	37fd                	addiw	a5,a5,-1
    800032f8:	c0bc                	sw	a5,64(s1)
  release(&bcache.lock);
    800032fa:	00014517          	auipc	a0,0x14
    800032fe:	8c650513          	addi	a0,a0,-1850 # 80016bc0 <bcache>
    80003302:	ffffe097          	auipc	ra,0xffffe
    80003306:	988080e7          	jalr	-1656(ra) # 80000c8a <release>
}
    8000330a:	60e2                	ld	ra,24(sp)
    8000330c:	6442                	ld	s0,16(sp)
    8000330e:	64a2                	ld	s1,8(sp)
    80003310:	6105                	addi	sp,sp,32
    80003312:	8082                	ret

0000000080003314 <bfree>:
}

// Free a disk block.
static void
bfree(int dev, uint b)
{
    80003314:	1101                	addi	sp,sp,-32
    80003316:	ec06                	sd	ra,24(sp)
    80003318:	e822                	sd	s0,16(sp)
    8000331a:	e426                	sd	s1,8(sp)
    8000331c:	e04a                	sd	s2,0(sp)
    8000331e:	1000                	addi	s0,sp,32
    80003320:	84ae                	mv	s1,a1
  struct buf *bp;
  int bi, m;

  bp = bread(dev, BBLOCK(b, sb));
    80003322:	00d5d59b          	srliw	a1,a1,0xd
    80003326:	0001c797          	auipc	a5,0x1c
    8000332a:	f767a783          	lw	a5,-138(a5) # 8001f29c <sb+0x1c>
    8000332e:	9dbd                	addw	a1,a1,a5
    80003330:	00000097          	auipc	ra,0x0
    80003334:	d9e080e7          	jalr	-610(ra) # 800030ce <bread>
  bi = b % BPB;
  m = 1 << (bi % 8);
    80003338:	0074f713          	andi	a4,s1,7
    8000333c:	4785                	li	a5,1
    8000333e:	00e797bb          	sllw	a5,a5,a4
  if((bp->data[bi/8] & m) == 0)
    80003342:	14ce                	slli	s1,s1,0x33
    80003344:	90d9                	srli	s1,s1,0x36
    80003346:	00950733          	add	a4,a0,s1
    8000334a:	05874703          	lbu	a4,88(a4)
    8000334e:	00e7f6b3          	and	a3,a5,a4
    80003352:	c69d                	beqz	a3,80003380 <bfree+0x6c>
    80003354:	892a                	mv	s2,a0
    panic("freeing free block");
  bp->data[bi/8] &= ~m;
    80003356:	94aa                	add	s1,s1,a0
    80003358:	fff7c793          	not	a5,a5
    8000335c:	8f7d                	and	a4,a4,a5
    8000335e:	04e48c23          	sb	a4,88(s1)
  log_write(bp);
    80003362:	00001097          	auipc	ra,0x1
    80003366:	126080e7          	jalr	294(ra) # 80004488 <log_write>
  brelse(bp);
    8000336a:	854a                	mv	a0,s2
    8000336c:	00000097          	auipc	ra,0x0
    80003370:	e92080e7          	jalr	-366(ra) # 800031fe <brelse>
}
    80003374:	60e2                	ld	ra,24(sp)
    80003376:	6442                	ld	s0,16(sp)
    80003378:	64a2                	ld	s1,8(sp)
    8000337a:	6902                	ld	s2,0(sp)
    8000337c:	6105                	addi	sp,sp,32
    8000337e:	8082                	ret
    panic("freeing free block");
    80003380:	00005517          	auipc	a0,0x5
    80003384:	1c050513          	addi	a0,a0,448 # 80008540 <syscalls+0xf0>
    80003388:	ffffd097          	auipc	ra,0xffffd
    8000338c:	1b8080e7          	jalr	440(ra) # 80000540 <panic>

0000000080003390 <balloc>:
{
    80003390:	711d                	addi	sp,sp,-96
    80003392:	ec86                	sd	ra,88(sp)
    80003394:	e8a2                	sd	s0,80(sp)
    80003396:	e4a6                	sd	s1,72(sp)
    80003398:	e0ca                	sd	s2,64(sp)
    8000339a:	fc4e                	sd	s3,56(sp)
    8000339c:	f852                	sd	s4,48(sp)
    8000339e:	f456                	sd	s5,40(sp)
    800033a0:	f05a                	sd	s6,32(sp)
    800033a2:	ec5e                	sd	s7,24(sp)
    800033a4:	e862                	sd	s8,16(sp)
    800033a6:	e466                	sd	s9,8(sp)
    800033a8:	1080                	addi	s0,sp,96
  for(b = 0; b < sb.size; b += BPB){
    800033aa:	0001c797          	auipc	a5,0x1c
    800033ae:	eda7a783          	lw	a5,-294(a5) # 8001f284 <sb+0x4>
    800033b2:	cff5                	beqz	a5,800034ae <balloc+0x11e>
    800033b4:	8baa                	mv	s7,a0
    800033b6:	4a81                	li	s5,0
    bp = bread(dev, BBLOCK(b, sb));
    800033b8:	0001cb17          	auipc	s6,0x1c
    800033bc:	ec8b0b13          	addi	s6,s6,-312 # 8001f280 <sb>
    for(bi = 0; bi < BPB && b + bi < sb.size; bi++){
    800033c0:	4c01                	li	s8,0
      m = 1 << (bi % 8);
    800033c2:	4985                	li	s3,1
    for(bi = 0; bi < BPB && b + bi < sb.size; bi++){
    800033c4:	6a09                	lui	s4,0x2
  for(b = 0; b < sb.size; b += BPB){
    800033c6:	6c89                	lui	s9,0x2
    800033c8:	a061                	j	80003450 <balloc+0xc0>
        bp->data[bi/8] |= m;  // Mark block in use.
    800033ca:	97ca                	add	a5,a5,s2
    800033cc:	8e55                	or	a2,a2,a3
    800033ce:	04c78c23          	sb	a2,88(a5)
        log_write(bp);
    800033d2:	854a                	mv	a0,s2
    800033d4:	00001097          	auipc	ra,0x1
    800033d8:	0b4080e7          	jalr	180(ra) # 80004488 <log_write>
        brelse(bp);
    800033dc:	854a                	mv	a0,s2
    800033de:	00000097          	auipc	ra,0x0
    800033e2:	e20080e7          	jalr	-480(ra) # 800031fe <brelse>
  bp = bread(dev, bno);
    800033e6:	85a6                	mv	a1,s1
    800033e8:	855e                	mv	a0,s7
    800033ea:	00000097          	auipc	ra,0x0
    800033ee:	ce4080e7          	jalr	-796(ra) # 800030ce <bread>
    800033f2:	892a                	mv	s2,a0
  memset(bp->data, 0, BSIZE);
    800033f4:	40000613          	li	a2,1024
    800033f8:	4581                	li	a1,0
    800033fa:	05850513          	addi	a0,a0,88
    800033fe:	ffffe097          	auipc	ra,0xffffe
    80003402:	8d4080e7          	jalr	-1836(ra) # 80000cd2 <memset>
  log_write(bp);
    80003406:	854a                	mv	a0,s2
    80003408:	00001097          	auipc	ra,0x1
    8000340c:	080080e7          	jalr	128(ra) # 80004488 <log_write>
  brelse(bp);
    80003410:	854a                	mv	a0,s2
    80003412:	00000097          	auipc	ra,0x0
    80003416:	dec080e7          	jalr	-532(ra) # 800031fe <brelse>
}
    8000341a:	8526                	mv	a0,s1
    8000341c:	60e6                	ld	ra,88(sp)
    8000341e:	6446                	ld	s0,80(sp)
    80003420:	64a6                	ld	s1,72(sp)
    80003422:	6906                	ld	s2,64(sp)
    80003424:	79e2                	ld	s3,56(sp)
    80003426:	7a42                	ld	s4,48(sp)
    80003428:	7aa2                	ld	s5,40(sp)
    8000342a:	7b02                	ld	s6,32(sp)
    8000342c:	6be2                	ld	s7,24(sp)
    8000342e:	6c42                	ld	s8,16(sp)
    80003430:	6ca2                	ld	s9,8(sp)
    80003432:	6125                	addi	sp,sp,96
    80003434:	8082                	ret
    brelse(bp);
    80003436:	854a                	mv	a0,s2
    80003438:	00000097          	auipc	ra,0x0
    8000343c:	dc6080e7          	jalr	-570(ra) # 800031fe <brelse>
  for(b = 0; b < sb.size; b += BPB){
    80003440:	015c87bb          	addw	a5,s9,s5
    80003444:	00078a9b          	sext.w	s5,a5
    80003448:	004b2703          	lw	a4,4(s6)
    8000344c:	06eaf163          	bgeu	s5,a4,800034ae <balloc+0x11e>
    bp = bread(dev, BBLOCK(b, sb));
    80003450:	41fad79b          	sraiw	a5,s5,0x1f
    80003454:	0137d79b          	srliw	a5,a5,0x13
    80003458:	015787bb          	addw	a5,a5,s5
    8000345c:	40d7d79b          	sraiw	a5,a5,0xd
    80003460:	01cb2583          	lw	a1,28(s6)
    80003464:	9dbd                	addw	a1,a1,a5
    80003466:	855e                	mv	a0,s7
    80003468:	00000097          	auipc	ra,0x0
    8000346c:	c66080e7          	jalr	-922(ra) # 800030ce <bread>
    80003470:	892a                	mv	s2,a0
    for(bi = 0; bi < BPB && b + bi < sb.size; bi++){
    80003472:	004b2503          	lw	a0,4(s6)
    80003476:	000a849b          	sext.w	s1,s5
    8000347a:	8762                	mv	a4,s8
    8000347c:	faa4fde3          	bgeu	s1,a0,80003436 <balloc+0xa6>
      m = 1 << (bi % 8);
    80003480:	00777693          	andi	a3,a4,7
    80003484:	00d996bb          	sllw	a3,s3,a3
      if((bp->data[bi/8] & m) == 0){  // Is block free?
    80003488:	41f7579b          	sraiw	a5,a4,0x1f
    8000348c:	01d7d79b          	srliw	a5,a5,0x1d
    80003490:	9fb9                	addw	a5,a5,a4
    80003492:	4037d79b          	sraiw	a5,a5,0x3
    80003496:	00f90633          	add	a2,s2,a5
    8000349a:	05864603          	lbu	a2,88(a2)
    8000349e:	00c6f5b3          	and	a1,a3,a2
    800034a2:	d585                	beqz	a1,800033ca <balloc+0x3a>
    for(bi = 0; bi < BPB && b + bi < sb.size; bi++){
    800034a4:	2705                	addiw	a4,a4,1
    800034a6:	2485                	addiw	s1,s1,1
    800034a8:	fd471ae3          	bne	a4,s4,8000347c <balloc+0xec>
    800034ac:	b769                	j	80003436 <balloc+0xa6>
  printf("balloc: out of blocks\n");
    800034ae:	00005517          	auipc	a0,0x5
    800034b2:	0aa50513          	addi	a0,a0,170 # 80008558 <syscalls+0x108>
    800034b6:	ffffd097          	auipc	ra,0xffffd
    800034ba:	0d4080e7          	jalr	212(ra) # 8000058a <printf>
  return 0;
    800034be:	4481                	li	s1,0
    800034c0:	bfa9                	j	8000341a <balloc+0x8a>

00000000800034c2 <bmap>:
// Return the disk block address of the nth block in inode ip.
// If there is no such block, bmap allocates one.
// returns 0 if out of disk space.
static uint
bmap(struct inode *ip, uint bn)
{
    800034c2:	7179                	addi	sp,sp,-48
    800034c4:	f406                	sd	ra,40(sp)
    800034c6:	f022                	sd	s0,32(sp)
    800034c8:	ec26                	sd	s1,24(sp)
    800034ca:	e84a                	sd	s2,16(sp)
    800034cc:	e44e                	sd	s3,8(sp)
    800034ce:	e052                	sd	s4,0(sp)
    800034d0:	1800                	addi	s0,sp,48
    800034d2:	89aa                	mv	s3,a0
  uint addr, *a;
  struct buf *bp;

  if(bn < NDIRECT){
    800034d4:	47ad                	li	a5,11
    800034d6:	02b7e863          	bltu	a5,a1,80003506 <bmap+0x44>
    if((addr = ip->addrs[bn]) == 0){
    800034da:	02059793          	slli	a5,a1,0x20
    800034de:	01e7d593          	srli	a1,a5,0x1e
    800034e2:	00b504b3          	add	s1,a0,a1
    800034e6:	0504a903          	lw	s2,80(s1)
    800034ea:	06091e63          	bnez	s2,80003566 <bmap+0xa4>
      addr = balloc(ip->dev);
    800034ee:	4108                	lw	a0,0(a0)
    800034f0:	00000097          	auipc	ra,0x0
    800034f4:	ea0080e7          	jalr	-352(ra) # 80003390 <balloc>
    800034f8:	0005091b          	sext.w	s2,a0
      if(addr == 0)
    800034fc:	06090563          	beqz	s2,80003566 <bmap+0xa4>
        return 0;
      ip->addrs[bn] = addr;
    80003500:	0524a823          	sw	s2,80(s1)
    80003504:	a08d                	j	80003566 <bmap+0xa4>
    }
    return addr;
  }
  bn -= NDIRECT;
    80003506:	ff45849b          	addiw	s1,a1,-12
    8000350a:	0004871b          	sext.w	a4,s1

  if(bn < NINDIRECT){
    8000350e:	0ff00793          	li	a5,255
    80003512:	08e7e563          	bltu	a5,a4,8000359c <bmap+0xda>
    // Load indirect block, allocating if necessary.
    if((addr = ip->addrs[NDIRECT]) == 0){
    80003516:	08052903          	lw	s2,128(a0)
    8000351a:	00091d63          	bnez	s2,80003534 <bmap+0x72>
      addr = balloc(ip->dev);
    8000351e:	4108                	lw	a0,0(a0)
    80003520:	00000097          	auipc	ra,0x0
    80003524:	e70080e7          	jalr	-400(ra) # 80003390 <balloc>
    80003528:	0005091b          	sext.w	s2,a0
      if(addr == 0)
    8000352c:	02090d63          	beqz	s2,80003566 <bmap+0xa4>
        return 0;
      ip->addrs[NDIRECT] = addr;
    80003530:	0929a023          	sw	s2,128(s3)
    }
    bp = bread(ip->dev, addr);
    80003534:	85ca                	mv	a1,s2
    80003536:	0009a503          	lw	a0,0(s3)
    8000353a:	00000097          	auipc	ra,0x0
    8000353e:	b94080e7          	jalr	-1132(ra) # 800030ce <bread>
    80003542:	8a2a                	mv	s4,a0
    a = (uint*)bp->data;
    80003544:	05850793          	addi	a5,a0,88
    if((addr = a[bn]) == 0){
    80003548:	02049713          	slli	a4,s1,0x20
    8000354c:	01e75593          	srli	a1,a4,0x1e
    80003550:	00b784b3          	add	s1,a5,a1
    80003554:	0004a903          	lw	s2,0(s1)
    80003558:	02090063          	beqz	s2,80003578 <bmap+0xb6>
      if(addr){
        a[bn] = addr;
        log_write(bp);
      }
    }
    brelse(bp);
    8000355c:	8552                	mv	a0,s4
    8000355e:	00000097          	auipc	ra,0x0
    80003562:	ca0080e7          	jalr	-864(ra) # 800031fe <brelse>
    return addr;
  }

  panic("bmap: out of range");
}
    80003566:	854a                	mv	a0,s2
    80003568:	70a2                	ld	ra,40(sp)
    8000356a:	7402                	ld	s0,32(sp)
    8000356c:	64e2                	ld	s1,24(sp)
    8000356e:	6942                	ld	s2,16(sp)
    80003570:	69a2                	ld	s3,8(sp)
    80003572:	6a02                	ld	s4,0(sp)
    80003574:	6145                	addi	sp,sp,48
    80003576:	8082                	ret
      addr = balloc(ip->dev);
    80003578:	0009a503          	lw	a0,0(s3)
    8000357c:	00000097          	auipc	ra,0x0
    80003580:	e14080e7          	jalr	-492(ra) # 80003390 <balloc>
    80003584:	0005091b          	sext.w	s2,a0
      if(addr){
    80003588:	fc090ae3          	beqz	s2,8000355c <bmap+0x9a>
        a[bn] = addr;
    8000358c:	0124a023          	sw	s2,0(s1)
        log_write(bp);
    80003590:	8552                	mv	a0,s4
    80003592:	00001097          	auipc	ra,0x1
    80003596:	ef6080e7          	jalr	-266(ra) # 80004488 <log_write>
    8000359a:	b7c9                	j	8000355c <bmap+0x9a>
  panic("bmap: out of range");
    8000359c:	00005517          	auipc	a0,0x5
    800035a0:	fd450513          	addi	a0,a0,-44 # 80008570 <syscalls+0x120>
    800035a4:	ffffd097          	auipc	ra,0xffffd
    800035a8:	f9c080e7          	jalr	-100(ra) # 80000540 <panic>

00000000800035ac <iget>:
{
    800035ac:	7179                	addi	sp,sp,-48
    800035ae:	f406                	sd	ra,40(sp)
    800035b0:	f022                	sd	s0,32(sp)
    800035b2:	ec26                	sd	s1,24(sp)
    800035b4:	e84a                	sd	s2,16(sp)
    800035b6:	e44e                	sd	s3,8(sp)
    800035b8:	e052                	sd	s4,0(sp)
    800035ba:	1800                	addi	s0,sp,48
    800035bc:	89aa                	mv	s3,a0
    800035be:	8a2e                	mv	s4,a1
  acquire(&itable.lock);
    800035c0:	0001c517          	auipc	a0,0x1c
    800035c4:	ce050513          	addi	a0,a0,-800 # 8001f2a0 <itable>
    800035c8:	ffffd097          	auipc	ra,0xffffd
    800035cc:	60e080e7          	jalr	1550(ra) # 80000bd6 <acquire>
  empty = 0;
    800035d0:	4901                	li	s2,0
  for(ip = &itable.inode[0]; ip < &itable.inode[NINODE]; ip++){
    800035d2:	0001c497          	auipc	s1,0x1c
    800035d6:	ce648493          	addi	s1,s1,-794 # 8001f2b8 <itable+0x18>
    800035da:	0001d697          	auipc	a3,0x1d
    800035de:	76e68693          	addi	a3,a3,1902 # 80020d48 <log>
    800035e2:	a039                	j	800035f0 <iget+0x44>
    if(empty == 0 && ip->ref == 0)    // Remember empty slot.
    800035e4:	02090b63          	beqz	s2,8000361a <iget+0x6e>
  for(ip = &itable.inode[0]; ip < &itable.inode[NINODE]; ip++){
    800035e8:	08848493          	addi	s1,s1,136
    800035ec:	02d48a63          	beq	s1,a3,80003620 <iget+0x74>
    if(ip->ref > 0 && ip->dev == dev && ip->inum == inum){
    800035f0:	449c                	lw	a5,8(s1)
    800035f2:	fef059e3          	blez	a5,800035e4 <iget+0x38>
    800035f6:	4098                	lw	a4,0(s1)
    800035f8:	ff3716e3          	bne	a4,s3,800035e4 <iget+0x38>
    800035fc:	40d8                	lw	a4,4(s1)
    800035fe:	ff4713e3          	bne	a4,s4,800035e4 <iget+0x38>
      ip->ref++;
    80003602:	2785                	addiw	a5,a5,1
    80003604:	c49c                	sw	a5,8(s1)
      release(&itable.lock);
    80003606:	0001c517          	auipc	a0,0x1c
    8000360a:	c9a50513          	addi	a0,a0,-870 # 8001f2a0 <itable>
    8000360e:	ffffd097          	auipc	ra,0xffffd
    80003612:	67c080e7          	jalr	1660(ra) # 80000c8a <release>
      return ip;
    80003616:	8926                	mv	s2,s1
    80003618:	a03d                	j	80003646 <iget+0x9a>
    if(empty == 0 && ip->ref == 0)    // Remember empty slot.
    8000361a:	f7f9                	bnez	a5,800035e8 <iget+0x3c>
    8000361c:	8926                	mv	s2,s1
    8000361e:	b7e9                	j	800035e8 <iget+0x3c>
  if(empty == 0)
    80003620:	02090c63          	beqz	s2,80003658 <iget+0xac>
  ip->dev = dev;
    80003624:	01392023          	sw	s3,0(s2)
  ip->inum = inum;
    80003628:	01492223          	sw	s4,4(s2)
  ip->ref = 1;
    8000362c:	4785                	li	a5,1
    8000362e:	00f92423          	sw	a5,8(s2)
  ip->valid = 0;
    80003632:	04092023          	sw	zero,64(s2)
  release(&itable.lock);
    80003636:	0001c517          	auipc	a0,0x1c
    8000363a:	c6a50513          	addi	a0,a0,-918 # 8001f2a0 <itable>
    8000363e:	ffffd097          	auipc	ra,0xffffd
    80003642:	64c080e7          	jalr	1612(ra) # 80000c8a <release>
}
    80003646:	854a                	mv	a0,s2
    80003648:	70a2                	ld	ra,40(sp)
    8000364a:	7402                	ld	s0,32(sp)
    8000364c:	64e2                	ld	s1,24(sp)
    8000364e:	6942                	ld	s2,16(sp)
    80003650:	69a2                	ld	s3,8(sp)
    80003652:	6a02                	ld	s4,0(sp)
    80003654:	6145                	addi	sp,sp,48
    80003656:	8082                	ret
    panic("iget: no inodes");
    80003658:	00005517          	auipc	a0,0x5
    8000365c:	f3050513          	addi	a0,a0,-208 # 80008588 <syscalls+0x138>
    80003660:	ffffd097          	auipc	ra,0xffffd
    80003664:	ee0080e7          	jalr	-288(ra) # 80000540 <panic>

0000000080003668 <fsinit>:
fsinit(int dev) {
    80003668:	7179                	addi	sp,sp,-48
    8000366a:	f406                	sd	ra,40(sp)
    8000366c:	f022                	sd	s0,32(sp)
    8000366e:	ec26                	sd	s1,24(sp)
    80003670:	e84a                	sd	s2,16(sp)
    80003672:	e44e                	sd	s3,8(sp)
    80003674:	1800                	addi	s0,sp,48
    80003676:	892a                	mv	s2,a0
  bp = bread(dev, 1);
    80003678:	4585                	li	a1,1
    8000367a:	00000097          	auipc	ra,0x0
    8000367e:	a54080e7          	jalr	-1452(ra) # 800030ce <bread>
    80003682:	84aa                	mv	s1,a0
  memmove(sb, bp->data, sizeof(*sb));
    80003684:	0001c997          	auipc	s3,0x1c
    80003688:	bfc98993          	addi	s3,s3,-1028 # 8001f280 <sb>
    8000368c:	02000613          	li	a2,32
    80003690:	05850593          	addi	a1,a0,88
    80003694:	854e                	mv	a0,s3
    80003696:	ffffd097          	auipc	ra,0xffffd
    8000369a:	698080e7          	jalr	1688(ra) # 80000d2e <memmove>
  brelse(bp);
    8000369e:	8526                	mv	a0,s1
    800036a0:	00000097          	auipc	ra,0x0
    800036a4:	b5e080e7          	jalr	-1186(ra) # 800031fe <brelse>
  if(sb.magic != FSMAGIC)
    800036a8:	0009a703          	lw	a4,0(s3)
    800036ac:	102037b7          	lui	a5,0x10203
    800036b0:	04078793          	addi	a5,a5,64 # 10203040 <_entry-0x6fdfcfc0>
    800036b4:	02f71263          	bne	a4,a5,800036d8 <fsinit+0x70>
  initlog(dev, &sb);
    800036b8:	0001c597          	auipc	a1,0x1c
    800036bc:	bc858593          	addi	a1,a1,-1080 # 8001f280 <sb>
    800036c0:	854a                	mv	a0,s2
    800036c2:	00001097          	auipc	ra,0x1
    800036c6:	b4a080e7          	jalr	-1206(ra) # 8000420c <initlog>
}
    800036ca:	70a2                	ld	ra,40(sp)
    800036cc:	7402                	ld	s0,32(sp)
    800036ce:	64e2                	ld	s1,24(sp)
    800036d0:	6942                	ld	s2,16(sp)
    800036d2:	69a2                	ld	s3,8(sp)
    800036d4:	6145                	addi	sp,sp,48
    800036d6:	8082                	ret
    panic("invalid file system");
    800036d8:	00005517          	auipc	a0,0x5
    800036dc:	ec050513          	addi	a0,a0,-320 # 80008598 <syscalls+0x148>
    800036e0:	ffffd097          	auipc	ra,0xffffd
    800036e4:	e60080e7          	jalr	-416(ra) # 80000540 <panic>

00000000800036e8 <iinit>:
{
    800036e8:	7179                	addi	sp,sp,-48
    800036ea:	f406                	sd	ra,40(sp)
    800036ec:	f022                	sd	s0,32(sp)
    800036ee:	ec26                	sd	s1,24(sp)
    800036f0:	e84a                	sd	s2,16(sp)
    800036f2:	e44e                	sd	s3,8(sp)
    800036f4:	1800                	addi	s0,sp,48
  initlock(&itable.lock, "itable");
    800036f6:	00005597          	auipc	a1,0x5
    800036fa:	eba58593          	addi	a1,a1,-326 # 800085b0 <syscalls+0x160>
    800036fe:	0001c517          	auipc	a0,0x1c
    80003702:	ba250513          	addi	a0,a0,-1118 # 8001f2a0 <itable>
    80003706:	ffffd097          	auipc	ra,0xffffd
    8000370a:	440080e7          	jalr	1088(ra) # 80000b46 <initlock>
  for(i = 0; i < NINODE; i++) {
    8000370e:	0001c497          	auipc	s1,0x1c
    80003712:	bba48493          	addi	s1,s1,-1094 # 8001f2c8 <itable+0x28>
    80003716:	0001d997          	auipc	s3,0x1d
    8000371a:	64298993          	addi	s3,s3,1602 # 80020d58 <log+0x10>
    initsleeplock(&itable.inode[i].lock, "inode");
    8000371e:	00005917          	auipc	s2,0x5
    80003722:	e9a90913          	addi	s2,s2,-358 # 800085b8 <syscalls+0x168>
    80003726:	85ca                	mv	a1,s2
    80003728:	8526                	mv	a0,s1
    8000372a:	00001097          	auipc	ra,0x1
    8000372e:	e42080e7          	jalr	-446(ra) # 8000456c <initsleeplock>
  for(i = 0; i < NINODE; i++) {
    80003732:	08848493          	addi	s1,s1,136
    80003736:	ff3498e3          	bne	s1,s3,80003726 <iinit+0x3e>
}
    8000373a:	70a2                	ld	ra,40(sp)
    8000373c:	7402                	ld	s0,32(sp)
    8000373e:	64e2                	ld	s1,24(sp)
    80003740:	6942                	ld	s2,16(sp)
    80003742:	69a2                	ld	s3,8(sp)
    80003744:	6145                	addi	sp,sp,48
    80003746:	8082                	ret

0000000080003748 <ialloc>:
{
    80003748:	715d                	addi	sp,sp,-80
    8000374a:	e486                	sd	ra,72(sp)
    8000374c:	e0a2                	sd	s0,64(sp)
    8000374e:	fc26                	sd	s1,56(sp)
    80003750:	f84a                	sd	s2,48(sp)
    80003752:	f44e                	sd	s3,40(sp)
    80003754:	f052                	sd	s4,32(sp)
    80003756:	ec56                	sd	s5,24(sp)
    80003758:	e85a                	sd	s6,16(sp)
    8000375a:	e45e                	sd	s7,8(sp)
    8000375c:	0880                	addi	s0,sp,80
  for(inum = 1; inum < sb.ninodes; inum++){
    8000375e:	0001c717          	auipc	a4,0x1c
    80003762:	b2e72703          	lw	a4,-1234(a4) # 8001f28c <sb+0xc>
    80003766:	4785                	li	a5,1
    80003768:	04e7fa63          	bgeu	a5,a4,800037bc <ialloc+0x74>
    8000376c:	8aaa                	mv	s5,a0
    8000376e:	8bae                	mv	s7,a1
    80003770:	4485                	li	s1,1
    bp = bread(dev, IBLOCK(inum, sb));
    80003772:	0001ca17          	auipc	s4,0x1c
    80003776:	b0ea0a13          	addi	s4,s4,-1266 # 8001f280 <sb>
    8000377a:	00048b1b          	sext.w	s6,s1
    8000377e:	0044d593          	srli	a1,s1,0x4
    80003782:	018a2783          	lw	a5,24(s4)
    80003786:	9dbd                	addw	a1,a1,a5
    80003788:	8556                	mv	a0,s5
    8000378a:	00000097          	auipc	ra,0x0
    8000378e:	944080e7          	jalr	-1724(ra) # 800030ce <bread>
    80003792:	892a                	mv	s2,a0
    dip = (struct dinode*)bp->data + inum%IPB;
    80003794:	05850993          	addi	s3,a0,88
    80003798:	00f4f793          	andi	a5,s1,15
    8000379c:	079a                	slli	a5,a5,0x6
    8000379e:	99be                	add	s3,s3,a5
    if(dip->type == 0){  // a free inode
    800037a0:	00099783          	lh	a5,0(s3)
    800037a4:	c3a1                	beqz	a5,800037e4 <ialloc+0x9c>
    brelse(bp);
    800037a6:	00000097          	auipc	ra,0x0
    800037aa:	a58080e7          	jalr	-1448(ra) # 800031fe <brelse>
  for(inum = 1; inum < sb.ninodes; inum++){
    800037ae:	0485                	addi	s1,s1,1
    800037b0:	00ca2703          	lw	a4,12(s4)
    800037b4:	0004879b          	sext.w	a5,s1
    800037b8:	fce7e1e3          	bltu	a5,a4,8000377a <ialloc+0x32>
  printf("ialloc: no inodes\n");
    800037bc:	00005517          	auipc	a0,0x5
    800037c0:	e0450513          	addi	a0,a0,-508 # 800085c0 <syscalls+0x170>
    800037c4:	ffffd097          	auipc	ra,0xffffd
    800037c8:	dc6080e7          	jalr	-570(ra) # 8000058a <printf>
  return 0;
    800037cc:	4501                	li	a0,0
}
    800037ce:	60a6                	ld	ra,72(sp)
    800037d0:	6406                	ld	s0,64(sp)
    800037d2:	74e2                	ld	s1,56(sp)
    800037d4:	7942                	ld	s2,48(sp)
    800037d6:	79a2                	ld	s3,40(sp)
    800037d8:	7a02                	ld	s4,32(sp)
    800037da:	6ae2                	ld	s5,24(sp)
    800037dc:	6b42                	ld	s6,16(sp)
    800037de:	6ba2                	ld	s7,8(sp)
    800037e0:	6161                	addi	sp,sp,80
    800037e2:	8082                	ret
      memset(dip, 0, sizeof(*dip));
    800037e4:	04000613          	li	a2,64
    800037e8:	4581                	li	a1,0
    800037ea:	854e                	mv	a0,s3
    800037ec:	ffffd097          	auipc	ra,0xffffd
    800037f0:	4e6080e7          	jalr	1254(ra) # 80000cd2 <memset>
      dip->type = type;
    800037f4:	01799023          	sh	s7,0(s3)
      log_write(bp);   // mark it allocated on the disk
    800037f8:	854a                	mv	a0,s2
    800037fa:	00001097          	auipc	ra,0x1
    800037fe:	c8e080e7          	jalr	-882(ra) # 80004488 <log_write>
      brelse(bp);
    80003802:	854a                	mv	a0,s2
    80003804:	00000097          	auipc	ra,0x0
    80003808:	9fa080e7          	jalr	-1542(ra) # 800031fe <brelse>
      return iget(dev, inum);
    8000380c:	85da                	mv	a1,s6
    8000380e:	8556                	mv	a0,s5
    80003810:	00000097          	auipc	ra,0x0
    80003814:	d9c080e7          	jalr	-612(ra) # 800035ac <iget>
    80003818:	bf5d                	j	800037ce <ialloc+0x86>

000000008000381a <iupdate>:
{
    8000381a:	1101                	addi	sp,sp,-32
    8000381c:	ec06                	sd	ra,24(sp)
    8000381e:	e822                	sd	s0,16(sp)
    80003820:	e426                	sd	s1,8(sp)
    80003822:	e04a                	sd	s2,0(sp)
    80003824:	1000                	addi	s0,sp,32
    80003826:	84aa                	mv	s1,a0
  bp = bread(ip->dev, IBLOCK(ip->inum, sb));
    80003828:	415c                	lw	a5,4(a0)
    8000382a:	0047d79b          	srliw	a5,a5,0x4
    8000382e:	0001c597          	auipc	a1,0x1c
    80003832:	a6a5a583          	lw	a1,-1430(a1) # 8001f298 <sb+0x18>
    80003836:	9dbd                	addw	a1,a1,a5
    80003838:	4108                	lw	a0,0(a0)
    8000383a:	00000097          	auipc	ra,0x0
    8000383e:	894080e7          	jalr	-1900(ra) # 800030ce <bread>
    80003842:	892a                	mv	s2,a0
  dip = (struct dinode*)bp->data + ip->inum%IPB;
    80003844:	05850793          	addi	a5,a0,88
    80003848:	40d8                	lw	a4,4(s1)
    8000384a:	8b3d                	andi	a4,a4,15
    8000384c:	071a                	slli	a4,a4,0x6
    8000384e:	97ba                	add	a5,a5,a4
  dip->type = ip->type;
    80003850:	04449703          	lh	a4,68(s1)
    80003854:	00e79023          	sh	a4,0(a5)
  dip->major = ip->major;
    80003858:	04649703          	lh	a4,70(s1)
    8000385c:	00e79123          	sh	a4,2(a5)
  dip->minor = ip->minor;
    80003860:	04849703          	lh	a4,72(s1)
    80003864:	00e79223          	sh	a4,4(a5)
  dip->nlink = ip->nlink;
    80003868:	04a49703          	lh	a4,74(s1)
    8000386c:	00e79323          	sh	a4,6(a5)
  dip->size = ip->size;
    80003870:	44f8                	lw	a4,76(s1)
    80003872:	c798                	sw	a4,8(a5)
  memmove(dip->addrs, ip->addrs, sizeof(ip->addrs));
    80003874:	03400613          	li	a2,52
    80003878:	05048593          	addi	a1,s1,80
    8000387c:	00c78513          	addi	a0,a5,12
    80003880:	ffffd097          	auipc	ra,0xffffd
    80003884:	4ae080e7          	jalr	1198(ra) # 80000d2e <memmove>
  log_write(bp);
    80003888:	854a                	mv	a0,s2
    8000388a:	00001097          	auipc	ra,0x1
    8000388e:	bfe080e7          	jalr	-1026(ra) # 80004488 <log_write>
  brelse(bp);
    80003892:	854a                	mv	a0,s2
    80003894:	00000097          	auipc	ra,0x0
    80003898:	96a080e7          	jalr	-1686(ra) # 800031fe <brelse>
}
    8000389c:	60e2                	ld	ra,24(sp)
    8000389e:	6442                	ld	s0,16(sp)
    800038a0:	64a2                	ld	s1,8(sp)
    800038a2:	6902                	ld	s2,0(sp)
    800038a4:	6105                	addi	sp,sp,32
    800038a6:	8082                	ret

00000000800038a8 <idup>:
{
    800038a8:	1101                	addi	sp,sp,-32
    800038aa:	ec06                	sd	ra,24(sp)
    800038ac:	e822                	sd	s0,16(sp)
    800038ae:	e426                	sd	s1,8(sp)
    800038b0:	1000                	addi	s0,sp,32
    800038b2:	84aa                	mv	s1,a0
  acquire(&itable.lock);
    800038b4:	0001c517          	auipc	a0,0x1c
    800038b8:	9ec50513          	addi	a0,a0,-1556 # 8001f2a0 <itable>
    800038bc:	ffffd097          	auipc	ra,0xffffd
    800038c0:	31a080e7          	jalr	794(ra) # 80000bd6 <acquire>
  ip->ref++;
    800038c4:	449c                	lw	a5,8(s1)
    800038c6:	2785                	addiw	a5,a5,1
    800038c8:	c49c                	sw	a5,8(s1)
  release(&itable.lock);
    800038ca:	0001c517          	auipc	a0,0x1c
    800038ce:	9d650513          	addi	a0,a0,-1578 # 8001f2a0 <itable>
    800038d2:	ffffd097          	auipc	ra,0xffffd
    800038d6:	3b8080e7          	jalr	952(ra) # 80000c8a <release>
}
    800038da:	8526                	mv	a0,s1
    800038dc:	60e2                	ld	ra,24(sp)
    800038de:	6442                	ld	s0,16(sp)
    800038e0:	64a2                	ld	s1,8(sp)
    800038e2:	6105                	addi	sp,sp,32
    800038e4:	8082                	ret

00000000800038e6 <ilock>:
{
    800038e6:	1101                	addi	sp,sp,-32
    800038e8:	ec06                	sd	ra,24(sp)
    800038ea:	e822                	sd	s0,16(sp)
    800038ec:	e426                	sd	s1,8(sp)
    800038ee:	e04a                	sd	s2,0(sp)
    800038f0:	1000                	addi	s0,sp,32
  if(ip == 0 || ip->ref < 1)
    800038f2:	c115                	beqz	a0,80003916 <ilock+0x30>
    800038f4:	84aa                	mv	s1,a0
    800038f6:	451c                	lw	a5,8(a0)
    800038f8:	00f05f63          	blez	a5,80003916 <ilock+0x30>
  acquiresleep(&ip->lock);
    800038fc:	0541                	addi	a0,a0,16
    800038fe:	00001097          	auipc	ra,0x1
    80003902:	ca8080e7          	jalr	-856(ra) # 800045a6 <acquiresleep>
  if(ip->valid == 0){
    80003906:	40bc                	lw	a5,64(s1)
    80003908:	cf99                	beqz	a5,80003926 <ilock+0x40>
}
    8000390a:	60e2                	ld	ra,24(sp)
    8000390c:	6442                	ld	s0,16(sp)
    8000390e:	64a2                	ld	s1,8(sp)
    80003910:	6902                	ld	s2,0(sp)
    80003912:	6105                	addi	sp,sp,32
    80003914:	8082                	ret
    panic("ilock");
    80003916:	00005517          	auipc	a0,0x5
    8000391a:	cc250513          	addi	a0,a0,-830 # 800085d8 <syscalls+0x188>
    8000391e:	ffffd097          	auipc	ra,0xffffd
    80003922:	c22080e7          	jalr	-990(ra) # 80000540 <panic>
    bp = bread(ip->dev, IBLOCK(ip->inum, sb));
    80003926:	40dc                	lw	a5,4(s1)
    80003928:	0047d79b          	srliw	a5,a5,0x4
    8000392c:	0001c597          	auipc	a1,0x1c
    80003930:	96c5a583          	lw	a1,-1684(a1) # 8001f298 <sb+0x18>
    80003934:	9dbd                	addw	a1,a1,a5
    80003936:	4088                	lw	a0,0(s1)
    80003938:	fffff097          	auipc	ra,0xfffff
    8000393c:	796080e7          	jalr	1942(ra) # 800030ce <bread>
    80003940:	892a                	mv	s2,a0
    dip = (struct dinode*)bp->data + ip->inum%IPB;
    80003942:	05850593          	addi	a1,a0,88
    80003946:	40dc                	lw	a5,4(s1)
    80003948:	8bbd                	andi	a5,a5,15
    8000394a:	079a                	slli	a5,a5,0x6
    8000394c:	95be                	add	a1,a1,a5
    ip->type = dip->type;
    8000394e:	00059783          	lh	a5,0(a1)
    80003952:	04f49223          	sh	a5,68(s1)
    ip->major = dip->major;
    80003956:	00259783          	lh	a5,2(a1)
    8000395a:	04f49323          	sh	a5,70(s1)
    ip->minor = dip->minor;
    8000395e:	00459783          	lh	a5,4(a1)
    80003962:	04f49423          	sh	a5,72(s1)
    ip->nlink = dip->nlink;
    80003966:	00659783          	lh	a5,6(a1)
    8000396a:	04f49523          	sh	a5,74(s1)
    ip->size = dip->size;
    8000396e:	459c                	lw	a5,8(a1)
    80003970:	c4fc                	sw	a5,76(s1)
    memmove(ip->addrs, dip->addrs, sizeof(ip->addrs));
    80003972:	03400613          	li	a2,52
    80003976:	05b1                	addi	a1,a1,12
    80003978:	05048513          	addi	a0,s1,80
    8000397c:	ffffd097          	auipc	ra,0xffffd
    80003980:	3b2080e7          	jalr	946(ra) # 80000d2e <memmove>
    brelse(bp);
    80003984:	854a                	mv	a0,s2
    80003986:	00000097          	auipc	ra,0x0
    8000398a:	878080e7          	jalr	-1928(ra) # 800031fe <brelse>
    ip->valid = 1;
    8000398e:	4785                	li	a5,1
    80003990:	c0bc                	sw	a5,64(s1)
    if(ip->type == 0)
    80003992:	04449783          	lh	a5,68(s1)
    80003996:	fbb5                	bnez	a5,8000390a <ilock+0x24>
      panic("ilock: no type");
    80003998:	00005517          	auipc	a0,0x5
    8000399c:	c4850513          	addi	a0,a0,-952 # 800085e0 <syscalls+0x190>
    800039a0:	ffffd097          	auipc	ra,0xffffd
    800039a4:	ba0080e7          	jalr	-1120(ra) # 80000540 <panic>

00000000800039a8 <iunlock>:
{
    800039a8:	1101                	addi	sp,sp,-32
    800039aa:	ec06                	sd	ra,24(sp)
    800039ac:	e822                	sd	s0,16(sp)
    800039ae:	e426                	sd	s1,8(sp)
    800039b0:	e04a                	sd	s2,0(sp)
    800039b2:	1000                	addi	s0,sp,32
  if(ip == 0 || !holdingsleep(&ip->lock) || ip->ref < 1)
    800039b4:	c905                	beqz	a0,800039e4 <iunlock+0x3c>
    800039b6:	84aa                	mv	s1,a0
    800039b8:	01050913          	addi	s2,a0,16
    800039bc:	854a                	mv	a0,s2
    800039be:	00001097          	auipc	ra,0x1
    800039c2:	c82080e7          	jalr	-894(ra) # 80004640 <holdingsleep>
    800039c6:	cd19                	beqz	a0,800039e4 <iunlock+0x3c>
    800039c8:	449c                	lw	a5,8(s1)
    800039ca:	00f05d63          	blez	a5,800039e4 <iunlock+0x3c>
  releasesleep(&ip->lock);
    800039ce:	854a                	mv	a0,s2
    800039d0:	00001097          	auipc	ra,0x1
    800039d4:	c2c080e7          	jalr	-980(ra) # 800045fc <releasesleep>
}
    800039d8:	60e2                	ld	ra,24(sp)
    800039da:	6442                	ld	s0,16(sp)
    800039dc:	64a2                	ld	s1,8(sp)
    800039de:	6902                	ld	s2,0(sp)
    800039e0:	6105                	addi	sp,sp,32
    800039e2:	8082                	ret
    panic("iunlock");
    800039e4:	00005517          	auipc	a0,0x5
    800039e8:	c0c50513          	addi	a0,a0,-1012 # 800085f0 <syscalls+0x1a0>
    800039ec:	ffffd097          	auipc	ra,0xffffd
    800039f0:	b54080e7          	jalr	-1196(ra) # 80000540 <panic>

00000000800039f4 <itrunc>:

// Truncate inode (discard contents).
// Caller must hold ip->lock.
void
itrunc(struct inode *ip)
{
    800039f4:	7179                	addi	sp,sp,-48
    800039f6:	f406                	sd	ra,40(sp)
    800039f8:	f022                	sd	s0,32(sp)
    800039fa:	ec26                	sd	s1,24(sp)
    800039fc:	e84a                	sd	s2,16(sp)
    800039fe:	e44e                	sd	s3,8(sp)
    80003a00:	e052                	sd	s4,0(sp)
    80003a02:	1800                	addi	s0,sp,48
    80003a04:	89aa                	mv	s3,a0
  int i, j;
  struct buf *bp;
  uint *a;

  for(i = 0; i < NDIRECT; i++){
    80003a06:	05050493          	addi	s1,a0,80
    80003a0a:	08050913          	addi	s2,a0,128
    80003a0e:	a021                	j	80003a16 <itrunc+0x22>
    80003a10:	0491                	addi	s1,s1,4
    80003a12:	01248d63          	beq	s1,s2,80003a2c <itrunc+0x38>
    if(ip->addrs[i]){
    80003a16:	408c                	lw	a1,0(s1)
    80003a18:	dde5                	beqz	a1,80003a10 <itrunc+0x1c>
      bfree(ip->dev, ip->addrs[i]);
    80003a1a:	0009a503          	lw	a0,0(s3)
    80003a1e:	00000097          	auipc	ra,0x0
    80003a22:	8f6080e7          	jalr	-1802(ra) # 80003314 <bfree>
      ip->addrs[i] = 0;
    80003a26:	0004a023          	sw	zero,0(s1)
    80003a2a:	b7dd                	j	80003a10 <itrunc+0x1c>
    }
  }

  if(ip->addrs[NDIRECT]){
    80003a2c:	0809a583          	lw	a1,128(s3)
    80003a30:	e185                	bnez	a1,80003a50 <itrunc+0x5c>
    brelse(bp);
    bfree(ip->dev, ip->addrs[NDIRECT]);
    ip->addrs[NDIRECT] = 0;
  }

  ip->size = 0;
    80003a32:	0409a623          	sw	zero,76(s3)
  iupdate(ip);
    80003a36:	854e                	mv	a0,s3
    80003a38:	00000097          	auipc	ra,0x0
    80003a3c:	de2080e7          	jalr	-542(ra) # 8000381a <iupdate>
}
    80003a40:	70a2                	ld	ra,40(sp)
    80003a42:	7402                	ld	s0,32(sp)
    80003a44:	64e2                	ld	s1,24(sp)
    80003a46:	6942                	ld	s2,16(sp)
    80003a48:	69a2                	ld	s3,8(sp)
    80003a4a:	6a02                	ld	s4,0(sp)
    80003a4c:	6145                	addi	sp,sp,48
    80003a4e:	8082                	ret
    bp = bread(ip->dev, ip->addrs[NDIRECT]);
    80003a50:	0009a503          	lw	a0,0(s3)
    80003a54:	fffff097          	auipc	ra,0xfffff
    80003a58:	67a080e7          	jalr	1658(ra) # 800030ce <bread>
    80003a5c:	8a2a                	mv	s4,a0
    for(j = 0; j < NINDIRECT; j++){
    80003a5e:	05850493          	addi	s1,a0,88
    80003a62:	45850913          	addi	s2,a0,1112
    80003a66:	a021                	j	80003a6e <itrunc+0x7a>
    80003a68:	0491                	addi	s1,s1,4
    80003a6a:	01248b63          	beq	s1,s2,80003a80 <itrunc+0x8c>
      if(a[j])
    80003a6e:	408c                	lw	a1,0(s1)
    80003a70:	dde5                	beqz	a1,80003a68 <itrunc+0x74>
        bfree(ip->dev, a[j]);
    80003a72:	0009a503          	lw	a0,0(s3)
    80003a76:	00000097          	auipc	ra,0x0
    80003a7a:	89e080e7          	jalr	-1890(ra) # 80003314 <bfree>
    80003a7e:	b7ed                	j	80003a68 <itrunc+0x74>
    brelse(bp);
    80003a80:	8552                	mv	a0,s4
    80003a82:	fffff097          	auipc	ra,0xfffff
    80003a86:	77c080e7          	jalr	1916(ra) # 800031fe <brelse>
    bfree(ip->dev, ip->addrs[NDIRECT]);
    80003a8a:	0809a583          	lw	a1,128(s3)
    80003a8e:	0009a503          	lw	a0,0(s3)
    80003a92:	00000097          	auipc	ra,0x0
    80003a96:	882080e7          	jalr	-1918(ra) # 80003314 <bfree>
    ip->addrs[NDIRECT] = 0;
    80003a9a:	0809a023          	sw	zero,128(s3)
    80003a9e:	bf51                	j	80003a32 <itrunc+0x3e>

0000000080003aa0 <iput>:
{
    80003aa0:	1101                	addi	sp,sp,-32
    80003aa2:	ec06                	sd	ra,24(sp)
    80003aa4:	e822                	sd	s0,16(sp)
    80003aa6:	e426                	sd	s1,8(sp)
    80003aa8:	e04a                	sd	s2,0(sp)
    80003aaa:	1000                	addi	s0,sp,32
    80003aac:	84aa                	mv	s1,a0
  acquire(&itable.lock);
    80003aae:	0001b517          	auipc	a0,0x1b
    80003ab2:	7f250513          	addi	a0,a0,2034 # 8001f2a0 <itable>
    80003ab6:	ffffd097          	auipc	ra,0xffffd
    80003aba:	120080e7          	jalr	288(ra) # 80000bd6 <acquire>
  if(ip->ref == 1 && ip->valid && ip->nlink == 0){
    80003abe:	4498                	lw	a4,8(s1)
    80003ac0:	4785                	li	a5,1
    80003ac2:	02f70363          	beq	a4,a5,80003ae8 <iput+0x48>
  ip->ref--;
    80003ac6:	449c                	lw	a5,8(s1)
    80003ac8:	37fd                	addiw	a5,a5,-1
    80003aca:	c49c                	sw	a5,8(s1)
  release(&itable.lock);
    80003acc:	0001b517          	auipc	a0,0x1b
    80003ad0:	7d450513          	addi	a0,a0,2004 # 8001f2a0 <itable>
    80003ad4:	ffffd097          	auipc	ra,0xffffd
    80003ad8:	1b6080e7          	jalr	438(ra) # 80000c8a <release>
}
    80003adc:	60e2                	ld	ra,24(sp)
    80003ade:	6442                	ld	s0,16(sp)
    80003ae0:	64a2                	ld	s1,8(sp)
    80003ae2:	6902                	ld	s2,0(sp)
    80003ae4:	6105                	addi	sp,sp,32
    80003ae6:	8082                	ret
  if(ip->ref == 1 && ip->valid && ip->nlink == 0){
    80003ae8:	40bc                	lw	a5,64(s1)
    80003aea:	dff1                	beqz	a5,80003ac6 <iput+0x26>
    80003aec:	04a49783          	lh	a5,74(s1)
    80003af0:	fbf9                	bnez	a5,80003ac6 <iput+0x26>
    acquiresleep(&ip->lock);
    80003af2:	01048913          	addi	s2,s1,16
    80003af6:	854a                	mv	a0,s2
    80003af8:	00001097          	auipc	ra,0x1
    80003afc:	aae080e7          	jalr	-1362(ra) # 800045a6 <acquiresleep>
    release(&itable.lock);
    80003b00:	0001b517          	auipc	a0,0x1b
    80003b04:	7a050513          	addi	a0,a0,1952 # 8001f2a0 <itable>
    80003b08:	ffffd097          	auipc	ra,0xffffd
    80003b0c:	182080e7          	jalr	386(ra) # 80000c8a <release>
    itrunc(ip);
    80003b10:	8526                	mv	a0,s1
    80003b12:	00000097          	auipc	ra,0x0
    80003b16:	ee2080e7          	jalr	-286(ra) # 800039f4 <itrunc>
    ip->type = 0;
    80003b1a:	04049223          	sh	zero,68(s1)
    iupdate(ip);
    80003b1e:	8526                	mv	a0,s1
    80003b20:	00000097          	auipc	ra,0x0
    80003b24:	cfa080e7          	jalr	-774(ra) # 8000381a <iupdate>
    ip->valid = 0;
    80003b28:	0404a023          	sw	zero,64(s1)
    releasesleep(&ip->lock);
    80003b2c:	854a                	mv	a0,s2
    80003b2e:	00001097          	auipc	ra,0x1
    80003b32:	ace080e7          	jalr	-1330(ra) # 800045fc <releasesleep>
    acquire(&itable.lock);
    80003b36:	0001b517          	auipc	a0,0x1b
    80003b3a:	76a50513          	addi	a0,a0,1898 # 8001f2a0 <itable>
    80003b3e:	ffffd097          	auipc	ra,0xffffd
    80003b42:	098080e7          	jalr	152(ra) # 80000bd6 <acquire>
    80003b46:	b741                	j	80003ac6 <iput+0x26>

0000000080003b48 <iunlockput>:
{
    80003b48:	1101                	addi	sp,sp,-32
    80003b4a:	ec06                	sd	ra,24(sp)
    80003b4c:	e822                	sd	s0,16(sp)
    80003b4e:	e426                	sd	s1,8(sp)
    80003b50:	1000                	addi	s0,sp,32
    80003b52:	84aa                	mv	s1,a0
  iunlock(ip);
    80003b54:	00000097          	auipc	ra,0x0
    80003b58:	e54080e7          	jalr	-428(ra) # 800039a8 <iunlock>
  iput(ip);
    80003b5c:	8526                	mv	a0,s1
    80003b5e:	00000097          	auipc	ra,0x0
    80003b62:	f42080e7          	jalr	-190(ra) # 80003aa0 <iput>
}
    80003b66:	60e2                	ld	ra,24(sp)
    80003b68:	6442                	ld	s0,16(sp)
    80003b6a:	64a2                	ld	s1,8(sp)
    80003b6c:	6105                	addi	sp,sp,32
    80003b6e:	8082                	ret

0000000080003b70 <stati>:

// Copy stat information from inode.
// Caller must hold ip->lock.
void
stati(struct inode *ip, struct stat *st)
{
    80003b70:	1141                	addi	sp,sp,-16
    80003b72:	e422                	sd	s0,8(sp)
    80003b74:	0800                	addi	s0,sp,16
  st->dev = ip->dev;
    80003b76:	411c                	lw	a5,0(a0)
    80003b78:	c19c                	sw	a5,0(a1)
  st->ino = ip->inum;
    80003b7a:	415c                	lw	a5,4(a0)
    80003b7c:	c1dc                	sw	a5,4(a1)
  st->type = ip->type;
    80003b7e:	04451783          	lh	a5,68(a0)
    80003b82:	00f59423          	sh	a5,8(a1)
  st->nlink = ip->nlink;
    80003b86:	04a51783          	lh	a5,74(a0)
    80003b8a:	00f59523          	sh	a5,10(a1)
  st->size = ip->size;
    80003b8e:	04c56783          	lwu	a5,76(a0)
    80003b92:	e99c                	sd	a5,16(a1)
}
    80003b94:	6422                	ld	s0,8(sp)
    80003b96:	0141                	addi	sp,sp,16
    80003b98:	8082                	ret

0000000080003b9a <readi>:
readi(struct inode *ip, int user_dst, uint64 dst, uint off, uint n)
{
  uint tot, m;
  struct buf *bp;

  if(off > ip->size || off + n < off)
    80003b9a:	457c                	lw	a5,76(a0)
    80003b9c:	0ed7e963          	bltu	a5,a3,80003c8e <readi+0xf4>
{
    80003ba0:	7159                	addi	sp,sp,-112
    80003ba2:	f486                	sd	ra,104(sp)
    80003ba4:	f0a2                	sd	s0,96(sp)
    80003ba6:	eca6                	sd	s1,88(sp)
    80003ba8:	e8ca                	sd	s2,80(sp)
    80003baa:	e4ce                	sd	s3,72(sp)
    80003bac:	e0d2                	sd	s4,64(sp)
    80003bae:	fc56                	sd	s5,56(sp)
    80003bb0:	f85a                	sd	s6,48(sp)
    80003bb2:	f45e                	sd	s7,40(sp)
    80003bb4:	f062                	sd	s8,32(sp)
    80003bb6:	ec66                	sd	s9,24(sp)
    80003bb8:	e86a                	sd	s10,16(sp)
    80003bba:	e46e                	sd	s11,8(sp)
    80003bbc:	1880                	addi	s0,sp,112
    80003bbe:	8b2a                	mv	s6,a0
    80003bc0:	8bae                	mv	s7,a1
    80003bc2:	8a32                	mv	s4,a2
    80003bc4:	84b6                	mv	s1,a3
    80003bc6:	8aba                	mv	s5,a4
  if(off > ip->size || off + n < off)
    80003bc8:	9f35                	addw	a4,a4,a3
    return 0;
    80003bca:	4501                	li	a0,0
  if(off > ip->size || off + n < off)
    80003bcc:	0ad76063          	bltu	a4,a3,80003c6c <readi+0xd2>
  if(off + n > ip->size)
    80003bd0:	00e7f463          	bgeu	a5,a4,80003bd8 <readi+0x3e>
    n = ip->size - off;
    80003bd4:	40d78abb          	subw	s5,a5,a3

  for(tot=0; tot<n; tot+=m, off+=m, dst+=m){
    80003bd8:	0a0a8963          	beqz	s5,80003c8a <readi+0xf0>
    80003bdc:	4981                	li	s3,0
    uint addr = bmap(ip, off/BSIZE);
    if(addr == 0)
      break;
    bp = bread(ip->dev, addr);
    m = min(n - tot, BSIZE - off%BSIZE);
    80003bde:	40000c93          	li	s9,1024
    if(either_copyout(user_dst, dst, bp->data + (off % BSIZE), m) == -1) {
    80003be2:	5c7d                	li	s8,-1
    80003be4:	a82d                	j	80003c1e <readi+0x84>
    80003be6:	020d1d93          	slli	s11,s10,0x20
    80003bea:	020ddd93          	srli	s11,s11,0x20
    80003bee:	05890613          	addi	a2,s2,88
    80003bf2:	86ee                	mv	a3,s11
    80003bf4:	963a                	add	a2,a2,a4
    80003bf6:	85d2                	mv	a1,s4
    80003bf8:	855e                	mv	a0,s7
    80003bfa:	fffff097          	auipc	ra,0xfffff
    80003bfe:	8d8080e7          	jalr	-1832(ra) # 800024d2 <either_copyout>
    80003c02:	05850d63          	beq	a0,s8,80003c5c <readi+0xc2>
      brelse(bp);
      tot = -1;
      break;
    }
    brelse(bp);
    80003c06:	854a                	mv	a0,s2
    80003c08:	fffff097          	auipc	ra,0xfffff
    80003c0c:	5f6080e7          	jalr	1526(ra) # 800031fe <brelse>
  for(tot=0; tot<n; tot+=m, off+=m, dst+=m){
    80003c10:	013d09bb          	addw	s3,s10,s3
    80003c14:	009d04bb          	addw	s1,s10,s1
    80003c18:	9a6e                	add	s4,s4,s11
    80003c1a:	0559f763          	bgeu	s3,s5,80003c68 <readi+0xce>
    uint addr = bmap(ip, off/BSIZE);
    80003c1e:	00a4d59b          	srliw	a1,s1,0xa
    80003c22:	855a                	mv	a0,s6
    80003c24:	00000097          	auipc	ra,0x0
    80003c28:	89e080e7          	jalr	-1890(ra) # 800034c2 <bmap>
    80003c2c:	0005059b          	sext.w	a1,a0
    if(addr == 0)
    80003c30:	cd85                	beqz	a1,80003c68 <readi+0xce>
    bp = bread(ip->dev, addr);
    80003c32:	000b2503          	lw	a0,0(s6)
    80003c36:	fffff097          	auipc	ra,0xfffff
    80003c3a:	498080e7          	jalr	1176(ra) # 800030ce <bread>
    80003c3e:	892a                	mv	s2,a0
    m = min(n - tot, BSIZE - off%BSIZE);
    80003c40:	3ff4f713          	andi	a4,s1,1023
    80003c44:	40ec87bb          	subw	a5,s9,a4
    80003c48:	413a86bb          	subw	a3,s5,s3
    80003c4c:	8d3e                	mv	s10,a5
    80003c4e:	2781                	sext.w	a5,a5
    80003c50:	0006861b          	sext.w	a2,a3
    80003c54:	f8f679e3          	bgeu	a2,a5,80003be6 <readi+0x4c>
    80003c58:	8d36                	mv	s10,a3
    80003c5a:	b771                	j	80003be6 <readi+0x4c>
      brelse(bp);
    80003c5c:	854a                	mv	a0,s2
    80003c5e:	fffff097          	auipc	ra,0xfffff
    80003c62:	5a0080e7          	jalr	1440(ra) # 800031fe <brelse>
      tot = -1;
    80003c66:	59fd                	li	s3,-1
  }
  return tot;
    80003c68:	0009851b          	sext.w	a0,s3
}
    80003c6c:	70a6                	ld	ra,104(sp)
    80003c6e:	7406                	ld	s0,96(sp)
    80003c70:	64e6                	ld	s1,88(sp)
    80003c72:	6946                	ld	s2,80(sp)
    80003c74:	69a6                	ld	s3,72(sp)
    80003c76:	6a06                	ld	s4,64(sp)
    80003c78:	7ae2                	ld	s5,56(sp)
    80003c7a:	7b42                	ld	s6,48(sp)
    80003c7c:	7ba2                	ld	s7,40(sp)
    80003c7e:	7c02                	ld	s8,32(sp)
    80003c80:	6ce2                	ld	s9,24(sp)
    80003c82:	6d42                	ld	s10,16(sp)
    80003c84:	6da2                	ld	s11,8(sp)
    80003c86:	6165                	addi	sp,sp,112
    80003c88:	8082                	ret
  for(tot=0; tot<n; tot+=m, off+=m, dst+=m){
    80003c8a:	89d6                	mv	s3,s5
    80003c8c:	bff1                	j	80003c68 <readi+0xce>
    return 0;
    80003c8e:	4501                	li	a0,0
}
    80003c90:	8082                	ret

0000000080003c92 <writei>:
writei(struct inode *ip, int user_src, uint64 src, uint off, uint n)
{
  uint tot, m;
  struct buf *bp;

  if(off > ip->size || off + n < off)
    80003c92:	457c                	lw	a5,76(a0)
    80003c94:	10d7e863          	bltu	a5,a3,80003da4 <writei+0x112>
{
    80003c98:	7159                	addi	sp,sp,-112
    80003c9a:	f486                	sd	ra,104(sp)
    80003c9c:	f0a2                	sd	s0,96(sp)
    80003c9e:	eca6                	sd	s1,88(sp)
    80003ca0:	e8ca                	sd	s2,80(sp)
    80003ca2:	e4ce                	sd	s3,72(sp)
    80003ca4:	e0d2                	sd	s4,64(sp)
    80003ca6:	fc56                	sd	s5,56(sp)
    80003ca8:	f85a                	sd	s6,48(sp)
    80003caa:	f45e                	sd	s7,40(sp)
    80003cac:	f062                	sd	s8,32(sp)
    80003cae:	ec66                	sd	s9,24(sp)
    80003cb0:	e86a                	sd	s10,16(sp)
    80003cb2:	e46e                	sd	s11,8(sp)
    80003cb4:	1880                	addi	s0,sp,112
    80003cb6:	8aaa                	mv	s5,a0
    80003cb8:	8bae                	mv	s7,a1
    80003cba:	8a32                	mv	s4,a2
    80003cbc:	8936                	mv	s2,a3
    80003cbe:	8b3a                	mv	s6,a4
  if(off > ip->size || off + n < off)
    80003cc0:	00e687bb          	addw	a5,a3,a4
    80003cc4:	0ed7e263          	bltu	a5,a3,80003da8 <writei+0x116>
    return -1;
  if(off + n > MAXFILE*BSIZE)
    80003cc8:	00043737          	lui	a4,0x43
    80003ccc:	0ef76063          	bltu	a4,a5,80003dac <writei+0x11a>
    return -1;

  for(tot=0; tot<n; tot+=m, off+=m, src+=m){
    80003cd0:	0c0b0863          	beqz	s6,80003da0 <writei+0x10e>
    80003cd4:	4981                	li	s3,0
    uint addr = bmap(ip, off/BSIZE);
    if(addr == 0)
      break;
    bp = bread(ip->dev, addr);
    m = min(n - tot, BSIZE - off%BSIZE);
    80003cd6:	40000c93          	li	s9,1024
    if(either_copyin(bp->data + (off % BSIZE), user_src, src, m) == -1) {
    80003cda:	5c7d                	li	s8,-1
    80003cdc:	a091                	j	80003d20 <writei+0x8e>
    80003cde:	020d1d93          	slli	s11,s10,0x20
    80003ce2:	020ddd93          	srli	s11,s11,0x20
    80003ce6:	05848513          	addi	a0,s1,88
    80003cea:	86ee                	mv	a3,s11
    80003cec:	8652                	mv	a2,s4
    80003cee:	85de                	mv	a1,s7
    80003cf0:	953a                	add	a0,a0,a4
    80003cf2:	fffff097          	auipc	ra,0xfffff
    80003cf6:	836080e7          	jalr	-1994(ra) # 80002528 <either_copyin>
    80003cfa:	07850263          	beq	a0,s8,80003d5e <writei+0xcc>
      brelse(bp);
      break;
    }
    log_write(bp);
    80003cfe:	8526                	mv	a0,s1
    80003d00:	00000097          	auipc	ra,0x0
    80003d04:	788080e7          	jalr	1928(ra) # 80004488 <log_write>
    brelse(bp);
    80003d08:	8526                	mv	a0,s1
    80003d0a:	fffff097          	auipc	ra,0xfffff
    80003d0e:	4f4080e7          	jalr	1268(ra) # 800031fe <brelse>
  for(tot=0; tot<n; tot+=m, off+=m, src+=m){
    80003d12:	013d09bb          	addw	s3,s10,s3
    80003d16:	012d093b          	addw	s2,s10,s2
    80003d1a:	9a6e                	add	s4,s4,s11
    80003d1c:	0569f663          	bgeu	s3,s6,80003d68 <writei+0xd6>
    uint addr = bmap(ip, off/BSIZE);
    80003d20:	00a9559b          	srliw	a1,s2,0xa
    80003d24:	8556                	mv	a0,s5
    80003d26:	fffff097          	auipc	ra,0xfffff
    80003d2a:	79c080e7          	jalr	1948(ra) # 800034c2 <bmap>
    80003d2e:	0005059b          	sext.w	a1,a0
    if(addr == 0)
    80003d32:	c99d                	beqz	a1,80003d68 <writei+0xd6>
    bp = bread(ip->dev, addr);
    80003d34:	000aa503          	lw	a0,0(s5)
    80003d38:	fffff097          	auipc	ra,0xfffff
    80003d3c:	396080e7          	jalr	918(ra) # 800030ce <bread>
    80003d40:	84aa                	mv	s1,a0
    m = min(n - tot, BSIZE - off%BSIZE);
    80003d42:	3ff97713          	andi	a4,s2,1023
    80003d46:	40ec87bb          	subw	a5,s9,a4
    80003d4a:	413b06bb          	subw	a3,s6,s3
    80003d4e:	8d3e                	mv	s10,a5
    80003d50:	2781                	sext.w	a5,a5
    80003d52:	0006861b          	sext.w	a2,a3
    80003d56:	f8f674e3          	bgeu	a2,a5,80003cde <writei+0x4c>
    80003d5a:	8d36                	mv	s10,a3
    80003d5c:	b749                	j	80003cde <writei+0x4c>
      brelse(bp);
    80003d5e:	8526                	mv	a0,s1
    80003d60:	fffff097          	auipc	ra,0xfffff
    80003d64:	49e080e7          	jalr	1182(ra) # 800031fe <brelse>
  }

  if(off > ip->size)
    80003d68:	04caa783          	lw	a5,76(s5)
    80003d6c:	0127f463          	bgeu	a5,s2,80003d74 <writei+0xe2>
    ip->size = off;
    80003d70:	052aa623          	sw	s2,76(s5)

  // write the i-node back to disk even if the size didn't change
  // because the loop above might have called bmap() and added a new
  // block to ip->addrs[].
  iupdate(ip);
    80003d74:	8556                	mv	a0,s5
    80003d76:	00000097          	auipc	ra,0x0
    80003d7a:	aa4080e7          	jalr	-1372(ra) # 8000381a <iupdate>

  return tot;
    80003d7e:	0009851b          	sext.w	a0,s3
}
    80003d82:	70a6                	ld	ra,104(sp)
    80003d84:	7406                	ld	s0,96(sp)
    80003d86:	64e6                	ld	s1,88(sp)
    80003d88:	6946                	ld	s2,80(sp)
    80003d8a:	69a6                	ld	s3,72(sp)
    80003d8c:	6a06                	ld	s4,64(sp)
    80003d8e:	7ae2                	ld	s5,56(sp)
    80003d90:	7b42                	ld	s6,48(sp)
    80003d92:	7ba2                	ld	s7,40(sp)
    80003d94:	7c02                	ld	s8,32(sp)
    80003d96:	6ce2                	ld	s9,24(sp)
    80003d98:	6d42                	ld	s10,16(sp)
    80003d9a:	6da2                	ld	s11,8(sp)
    80003d9c:	6165                	addi	sp,sp,112
    80003d9e:	8082                	ret
  for(tot=0; tot<n; tot+=m, off+=m, src+=m){
    80003da0:	89da                	mv	s3,s6
    80003da2:	bfc9                	j	80003d74 <writei+0xe2>
    return -1;
    80003da4:	557d                	li	a0,-1
}
    80003da6:	8082                	ret
    return -1;
    80003da8:	557d                	li	a0,-1
    80003daa:	bfe1                	j	80003d82 <writei+0xf0>
    return -1;
    80003dac:	557d                	li	a0,-1
    80003dae:	bfd1                	j	80003d82 <writei+0xf0>

0000000080003db0 <namecmp>:

// Directories

int
namecmp(const char *s, const char *t)
{
    80003db0:	1141                	addi	sp,sp,-16
    80003db2:	e406                	sd	ra,8(sp)
    80003db4:	e022                	sd	s0,0(sp)
    80003db6:	0800                	addi	s0,sp,16
  return strncmp(s, t, DIRSIZ);
    80003db8:	4639                	li	a2,14
    80003dba:	ffffd097          	auipc	ra,0xffffd
    80003dbe:	fe8080e7          	jalr	-24(ra) # 80000da2 <strncmp>
}
    80003dc2:	60a2                	ld	ra,8(sp)
    80003dc4:	6402                	ld	s0,0(sp)
    80003dc6:	0141                	addi	sp,sp,16
    80003dc8:	8082                	ret

0000000080003dca <dirlookup>:

// Look for a directory entry in a directory.
// If found, set *poff to byte offset of entry.
struct inode*
dirlookup(struct inode *dp, char *name, uint *poff)
{
    80003dca:	7139                	addi	sp,sp,-64
    80003dcc:	fc06                	sd	ra,56(sp)
    80003dce:	f822                	sd	s0,48(sp)
    80003dd0:	f426                	sd	s1,40(sp)
    80003dd2:	f04a                	sd	s2,32(sp)
    80003dd4:	ec4e                	sd	s3,24(sp)
    80003dd6:	e852                	sd	s4,16(sp)
    80003dd8:	0080                	addi	s0,sp,64
  uint off, inum;
  struct dirent de;

  if(dp->type != T_DIR)
    80003dda:	04451703          	lh	a4,68(a0)
    80003dde:	4785                	li	a5,1
    80003de0:	00f71a63          	bne	a4,a5,80003df4 <dirlookup+0x2a>
    80003de4:	892a                	mv	s2,a0
    80003de6:	89ae                	mv	s3,a1
    80003de8:	8a32                	mv	s4,a2
    panic("dirlookup not DIR");

  for(off = 0; off < dp->size; off += sizeof(de)){
    80003dea:	457c                	lw	a5,76(a0)
    80003dec:	4481                	li	s1,0
      inum = de.inum;
      return iget(dp->dev, inum);
    }
  }

  return 0;
    80003dee:	4501                	li	a0,0
  for(off = 0; off < dp->size; off += sizeof(de)){
    80003df0:	e79d                	bnez	a5,80003e1e <dirlookup+0x54>
    80003df2:	a8a5                	j	80003e6a <dirlookup+0xa0>
    panic("dirlookup not DIR");
    80003df4:	00005517          	auipc	a0,0x5
    80003df8:	80450513          	addi	a0,a0,-2044 # 800085f8 <syscalls+0x1a8>
    80003dfc:	ffffc097          	auipc	ra,0xffffc
    80003e00:	744080e7          	jalr	1860(ra) # 80000540 <panic>
      panic("dirlookup read");
    80003e04:	00005517          	auipc	a0,0x5
    80003e08:	80c50513          	addi	a0,a0,-2036 # 80008610 <syscalls+0x1c0>
    80003e0c:	ffffc097          	auipc	ra,0xffffc
    80003e10:	734080e7          	jalr	1844(ra) # 80000540 <panic>
  for(off = 0; off < dp->size; off += sizeof(de)){
    80003e14:	24c1                	addiw	s1,s1,16
    80003e16:	04c92783          	lw	a5,76(s2)
    80003e1a:	04f4f763          	bgeu	s1,a5,80003e68 <dirlookup+0x9e>
    if(readi(dp, 0, (uint64)&de, off, sizeof(de)) != sizeof(de))
    80003e1e:	4741                	li	a4,16
    80003e20:	86a6                	mv	a3,s1
    80003e22:	fc040613          	addi	a2,s0,-64
    80003e26:	4581                	li	a1,0
    80003e28:	854a                	mv	a0,s2
    80003e2a:	00000097          	auipc	ra,0x0
    80003e2e:	d70080e7          	jalr	-656(ra) # 80003b9a <readi>
    80003e32:	47c1                	li	a5,16
    80003e34:	fcf518e3          	bne	a0,a5,80003e04 <dirlookup+0x3a>
    if(de.inum == 0)
    80003e38:	fc045783          	lhu	a5,-64(s0)
    80003e3c:	dfe1                	beqz	a5,80003e14 <dirlookup+0x4a>
    if(namecmp(name, de.name) == 0){
    80003e3e:	fc240593          	addi	a1,s0,-62
    80003e42:	854e                	mv	a0,s3
    80003e44:	00000097          	auipc	ra,0x0
    80003e48:	f6c080e7          	jalr	-148(ra) # 80003db0 <namecmp>
    80003e4c:	f561                	bnez	a0,80003e14 <dirlookup+0x4a>
      if(poff)
    80003e4e:	000a0463          	beqz	s4,80003e56 <dirlookup+0x8c>
        *poff = off;
    80003e52:	009a2023          	sw	s1,0(s4)
      return iget(dp->dev, inum);
    80003e56:	fc045583          	lhu	a1,-64(s0)
    80003e5a:	00092503          	lw	a0,0(s2)
    80003e5e:	fffff097          	auipc	ra,0xfffff
    80003e62:	74e080e7          	jalr	1870(ra) # 800035ac <iget>
    80003e66:	a011                	j	80003e6a <dirlookup+0xa0>
  return 0;
    80003e68:	4501                	li	a0,0
}
    80003e6a:	70e2                	ld	ra,56(sp)
    80003e6c:	7442                	ld	s0,48(sp)
    80003e6e:	74a2                	ld	s1,40(sp)
    80003e70:	7902                	ld	s2,32(sp)
    80003e72:	69e2                	ld	s3,24(sp)
    80003e74:	6a42                	ld	s4,16(sp)
    80003e76:	6121                	addi	sp,sp,64
    80003e78:	8082                	ret

0000000080003e7a <namex>:
// If parent != 0, return the inode for the parent and copy the final
// path element into name, which must have room for DIRSIZ bytes.
// Must be called inside a transaction since it calls iput().
static struct inode*
namex(char *path, int nameiparent, char *name)
{
    80003e7a:	711d                	addi	sp,sp,-96
    80003e7c:	ec86                	sd	ra,88(sp)
    80003e7e:	e8a2                	sd	s0,80(sp)
    80003e80:	e4a6                	sd	s1,72(sp)
    80003e82:	e0ca                	sd	s2,64(sp)
    80003e84:	fc4e                	sd	s3,56(sp)
    80003e86:	f852                	sd	s4,48(sp)
    80003e88:	f456                	sd	s5,40(sp)
    80003e8a:	f05a                	sd	s6,32(sp)
    80003e8c:	ec5e                	sd	s7,24(sp)
    80003e8e:	e862                	sd	s8,16(sp)
    80003e90:	e466                	sd	s9,8(sp)
    80003e92:	e06a                	sd	s10,0(sp)
    80003e94:	1080                	addi	s0,sp,96
    80003e96:	84aa                	mv	s1,a0
    80003e98:	8b2e                	mv	s6,a1
    80003e9a:	8ab2                	mv	s5,a2
  struct inode *ip, *next;

  if(*path == '/')
    80003e9c:	00054703          	lbu	a4,0(a0)
    80003ea0:	02f00793          	li	a5,47
    80003ea4:	02f70363          	beq	a4,a5,80003eca <namex+0x50>
    ip = iget(ROOTDEV, ROOTINO);
  else
    ip = idup(myproc()->cwd);
    80003ea8:	ffffe097          	auipc	ra,0xffffe
    80003eac:	b04080e7          	jalr	-1276(ra) # 800019ac <myproc>
    80003eb0:	15053503          	ld	a0,336(a0)
    80003eb4:	00000097          	auipc	ra,0x0
    80003eb8:	9f4080e7          	jalr	-1548(ra) # 800038a8 <idup>
    80003ebc:	8a2a                	mv	s4,a0
  while(*path == '/')
    80003ebe:	02f00913          	li	s2,47
  if(len >= DIRSIZ)
    80003ec2:	4cb5                	li	s9,13
  len = path - s;
    80003ec4:	4b81                	li	s7,0

  while((path = skipelem(path, name)) != 0){
    ilock(ip);
    if(ip->type != T_DIR){
    80003ec6:	4c05                	li	s8,1
    80003ec8:	a87d                	j	80003f86 <namex+0x10c>
    ip = iget(ROOTDEV, ROOTINO);
    80003eca:	4585                	li	a1,1
    80003ecc:	4505                	li	a0,1
    80003ece:	fffff097          	auipc	ra,0xfffff
    80003ed2:	6de080e7          	jalr	1758(ra) # 800035ac <iget>
    80003ed6:	8a2a                	mv	s4,a0
    80003ed8:	b7dd                	j	80003ebe <namex+0x44>
      iunlockput(ip);
    80003eda:	8552                	mv	a0,s4
    80003edc:	00000097          	auipc	ra,0x0
    80003ee0:	c6c080e7          	jalr	-916(ra) # 80003b48 <iunlockput>
      return 0;
    80003ee4:	4a01                	li	s4,0
  if(nameiparent){
    iput(ip);
    return 0;
  }
  return ip;
}
    80003ee6:	8552                	mv	a0,s4
    80003ee8:	60e6                	ld	ra,88(sp)
    80003eea:	6446                	ld	s0,80(sp)
    80003eec:	64a6                	ld	s1,72(sp)
    80003eee:	6906                	ld	s2,64(sp)
    80003ef0:	79e2                	ld	s3,56(sp)
    80003ef2:	7a42                	ld	s4,48(sp)
    80003ef4:	7aa2                	ld	s5,40(sp)
    80003ef6:	7b02                	ld	s6,32(sp)
    80003ef8:	6be2                	ld	s7,24(sp)
    80003efa:	6c42                	ld	s8,16(sp)
    80003efc:	6ca2                	ld	s9,8(sp)
    80003efe:	6d02                	ld	s10,0(sp)
    80003f00:	6125                	addi	sp,sp,96
    80003f02:	8082                	ret
      iunlock(ip);
    80003f04:	8552                	mv	a0,s4
    80003f06:	00000097          	auipc	ra,0x0
    80003f0a:	aa2080e7          	jalr	-1374(ra) # 800039a8 <iunlock>
      return ip;
    80003f0e:	bfe1                	j	80003ee6 <namex+0x6c>
      iunlockput(ip);
    80003f10:	8552                	mv	a0,s4
    80003f12:	00000097          	auipc	ra,0x0
    80003f16:	c36080e7          	jalr	-970(ra) # 80003b48 <iunlockput>
      return 0;
    80003f1a:	8a4e                	mv	s4,s3
    80003f1c:	b7e9                	j	80003ee6 <namex+0x6c>
  len = path - s;
    80003f1e:	40998633          	sub	a2,s3,s1
    80003f22:	00060d1b          	sext.w	s10,a2
  if(len >= DIRSIZ)
    80003f26:	09acd863          	bge	s9,s10,80003fb6 <namex+0x13c>
    memmove(name, s, DIRSIZ);
    80003f2a:	4639                	li	a2,14
    80003f2c:	85a6                	mv	a1,s1
    80003f2e:	8556                	mv	a0,s5
    80003f30:	ffffd097          	auipc	ra,0xffffd
    80003f34:	dfe080e7          	jalr	-514(ra) # 80000d2e <memmove>
    80003f38:	84ce                	mv	s1,s3
  while(*path == '/')
    80003f3a:	0004c783          	lbu	a5,0(s1)
    80003f3e:	01279763          	bne	a5,s2,80003f4c <namex+0xd2>
    path++;
    80003f42:	0485                	addi	s1,s1,1
  while(*path == '/')
    80003f44:	0004c783          	lbu	a5,0(s1)
    80003f48:	ff278de3          	beq	a5,s2,80003f42 <namex+0xc8>
    ilock(ip);
    80003f4c:	8552                	mv	a0,s4
    80003f4e:	00000097          	auipc	ra,0x0
    80003f52:	998080e7          	jalr	-1640(ra) # 800038e6 <ilock>
    if(ip->type != T_DIR){
    80003f56:	044a1783          	lh	a5,68(s4)
    80003f5a:	f98790e3          	bne	a5,s8,80003eda <namex+0x60>
    if(nameiparent && *path == '\0'){
    80003f5e:	000b0563          	beqz	s6,80003f68 <namex+0xee>
    80003f62:	0004c783          	lbu	a5,0(s1)
    80003f66:	dfd9                	beqz	a5,80003f04 <namex+0x8a>
    if((next = dirlookup(ip, name, 0)) == 0){
    80003f68:	865e                	mv	a2,s7
    80003f6a:	85d6                	mv	a1,s5
    80003f6c:	8552                	mv	a0,s4
    80003f6e:	00000097          	auipc	ra,0x0
    80003f72:	e5c080e7          	jalr	-420(ra) # 80003dca <dirlookup>
    80003f76:	89aa                	mv	s3,a0
    80003f78:	dd41                	beqz	a0,80003f10 <namex+0x96>
    iunlockput(ip);
    80003f7a:	8552                	mv	a0,s4
    80003f7c:	00000097          	auipc	ra,0x0
    80003f80:	bcc080e7          	jalr	-1076(ra) # 80003b48 <iunlockput>
    ip = next;
    80003f84:	8a4e                	mv	s4,s3
  while(*path == '/')
    80003f86:	0004c783          	lbu	a5,0(s1)
    80003f8a:	01279763          	bne	a5,s2,80003f98 <namex+0x11e>
    path++;
    80003f8e:	0485                	addi	s1,s1,1
  while(*path == '/')
    80003f90:	0004c783          	lbu	a5,0(s1)
    80003f94:	ff278de3          	beq	a5,s2,80003f8e <namex+0x114>
  if(*path == 0)
    80003f98:	cb9d                	beqz	a5,80003fce <namex+0x154>
  while(*path != '/' && *path != 0)
    80003f9a:	0004c783          	lbu	a5,0(s1)
    80003f9e:	89a6                	mv	s3,s1
  len = path - s;
    80003fa0:	8d5e                	mv	s10,s7
    80003fa2:	865e                	mv	a2,s7
  while(*path != '/' && *path != 0)
    80003fa4:	01278963          	beq	a5,s2,80003fb6 <namex+0x13c>
    80003fa8:	dbbd                	beqz	a5,80003f1e <namex+0xa4>
    path++;
    80003faa:	0985                	addi	s3,s3,1
  while(*path != '/' && *path != 0)
    80003fac:	0009c783          	lbu	a5,0(s3)
    80003fb0:	ff279ce3          	bne	a5,s2,80003fa8 <namex+0x12e>
    80003fb4:	b7ad                	j	80003f1e <namex+0xa4>
    memmove(name, s, len);
    80003fb6:	2601                	sext.w	a2,a2
    80003fb8:	85a6                	mv	a1,s1
    80003fba:	8556                	mv	a0,s5
    80003fbc:	ffffd097          	auipc	ra,0xffffd
    80003fc0:	d72080e7          	jalr	-654(ra) # 80000d2e <memmove>
    name[len] = 0;
    80003fc4:	9d56                	add	s10,s10,s5
    80003fc6:	000d0023          	sb	zero,0(s10)
    80003fca:	84ce                	mv	s1,s3
    80003fcc:	b7bd                	j	80003f3a <namex+0xc0>
  if(nameiparent){
    80003fce:	f00b0ce3          	beqz	s6,80003ee6 <namex+0x6c>
    iput(ip);
    80003fd2:	8552                	mv	a0,s4
    80003fd4:	00000097          	auipc	ra,0x0
    80003fd8:	acc080e7          	jalr	-1332(ra) # 80003aa0 <iput>
    return 0;
    80003fdc:	4a01                	li	s4,0
    80003fde:	b721                	j	80003ee6 <namex+0x6c>

0000000080003fe0 <dirlink>:
{
    80003fe0:	7139                	addi	sp,sp,-64
    80003fe2:	fc06                	sd	ra,56(sp)
    80003fe4:	f822                	sd	s0,48(sp)
    80003fe6:	f426                	sd	s1,40(sp)
    80003fe8:	f04a                	sd	s2,32(sp)
    80003fea:	ec4e                	sd	s3,24(sp)
    80003fec:	e852                	sd	s4,16(sp)
    80003fee:	0080                	addi	s0,sp,64
    80003ff0:	892a                	mv	s2,a0
    80003ff2:	8a2e                	mv	s4,a1
    80003ff4:	89b2                	mv	s3,a2
  if((ip = dirlookup(dp, name, 0)) != 0){
    80003ff6:	4601                	li	a2,0
    80003ff8:	00000097          	auipc	ra,0x0
    80003ffc:	dd2080e7          	jalr	-558(ra) # 80003dca <dirlookup>
    80004000:	e93d                	bnez	a0,80004076 <dirlink+0x96>
  for(off = 0; off < dp->size; off += sizeof(de)){
    80004002:	04c92483          	lw	s1,76(s2)
    80004006:	c49d                	beqz	s1,80004034 <dirlink+0x54>
    80004008:	4481                	li	s1,0
    if(readi(dp, 0, (uint64)&de, off, sizeof(de)) != sizeof(de))
    8000400a:	4741                	li	a4,16
    8000400c:	86a6                	mv	a3,s1
    8000400e:	fc040613          	addi	a2,s0,-64
    80004012:	4581                	li	a1,0
    80004014:	854a                	mv	a0,s2
    80004016:	00000097          	auipc	ra,0x0
    8000401a:	b84080e7          	jalr	-1148(ra) # 80003b9a <readi>
    8000401e:	47c1                	li	a5,16
    80004020:	06f51163          	bne	a0,a5,80004082 <dirlink+0xa2>
    if(de.inum == 0)
    80004024:	fc045783          	lhu	a5,-64(s0)
    80004028:	c791                	beqz	a5,80004034 <dirlink+0x54>
  for(off = 0; off < dp->size; off += sizeof(de)){
    8000402a:	24c1                	addiw	s1,s1,16
    8000402c:	04c92783          	lw	a5,76(s2)
    80004030:	fcf4ede3          	bltu	s1,a5,8000400a <dirlink+0x2a>
  strncpy(de.name, name, DIRSIZ);
    80004034:	4639                	li	a2,14
    80004036:	85d2                	mv	a1,s4
    80004038:	fc240513          	addi	a0,s0,-62
    8000403c:	ffffd097          	auipc	ra,0xffffd
    80004040:	da2080e7          	jalr	-606(ra) # 80000dde <strncpy>
  de.inum = inum;
    80004044:	fd341023          	sh	s3,-64(s0)
  if(writei(dp, 0, (uint64)&de, off, sizeof(de)) != sizeof(de))
    80004048:	4741                	li	a4,16
    8000404a:	86a6                	mv	a3,s1
    8000404c:	fc040613          	addi	a2,s0,-64
    80004050:	4581                	li	a1,0
    80004052:	854a                	mv	a0,s2
    80004054:	00000097          	auipc	ra,0x0
    80004058:	c3e080e7          	jalr	-962(ra) # 80003c92 <writei>
    8000405c:	1541                	addi	a0,a0,-16
    8000405e:	00a03533          	snez	a0,a0
    80004062:	40a00533          	neg	a0,a0
}
    80004066:	70e2                	ld	ra,56(sp)
    80004068:	7442                	ld	s0,48(sp)
    8000406a:	74a2                	ld	s1,40(sp)
    8000406c:	7902                	ld	s2,32(sp)
    8000406e:	69e2                	ld	s3,24(sp)
    80004070:	6a42                	ld	s4,16(sp)
    80004072:	6121                	addi	sp,sp,64
    80004074:	8082                	ret
    iput(ip);
    80004076:	00000097          	auipc	ra,0x0
    8000407a:	a2a080e7          	jalr	-1494(ra) # 80003aa0 <iput>
    return -1;
    8000407e:	557d                	li	a0,-1
    80004080:	b7dd                	j	80004066 <dirlink+0x86>
      panic("dirlink read");
    80004082:	00004517          	auipc	a0,0x4
    80004086:	59e50513          	addi	a0,a0,1438 # 80008620 <syscalls+0x1d0>
    8000408a:	ffffc097          	auipc	ra,0xffffc
    8000408e:	4b6080e7          	jalr	1206(ra) # 80000540 <panic>

0000000080004092 <namei>:

struct inode*
namei(char *path)
{
    80004092:	1101                	addi	sp,sp,-32
    80004094:	ec06                	sd	ra,24(sp)
    80004096:	e822                	sd	s0,16(sp)
    80004098:	1000                	addi	s0,sp,32
  char name[DIRSIZ];
  return namex(path, 0, name);
    8000409a:	fe040613          	addi	a2,s0,-32
    8000409e:	4581                	li	a1,0
    800040a0:	00000097          	auipc	ra,0x0
    800040a4:	dda080e7          	jalr	-550(ra) # 80003e7a <namex>
}
    800040a8:	60e2                	ld	ra,24(sp)
    800040aa:	6442                	ld	s0,16(sp)
    800040ac:	6105                	addi	sp,sp,32
    800040ae:	8082                	ret

00000000800040b0 <nameiparent>:

struct inode*
nameiparent(char *path, char *name)
{
    800040b0:	1141                	addi	sp,sp,-16
    800040b2:	e406                	sd	ra,8(sp)
    800040b4:	e022                	sd	s0,0(sp)
    800040b6:	0800                	addi	s0,sp,16
    800040b8:	862e                	mv	a2,a1
  return namex(path, 1, name);
    800040ba:	4585                	li	a1,1
    800040bc:	00000097          	auipc	ra,0x0
    800040c0:	dbe080e7          	jalr	-578(ra) # 80003e7a <namex>
}
    800040c4:	60a2                	ld	ra,8(sp)
    800040c6:	6402                	ld	s0,0(sp)
    800040c8:	0141                	addi	sp,sp,16
    800040ca:	8082                	ret

00000000800040cc <write_head>:
// Write in-memory log header to disk.
// This is the true point at which the
// current transaction commits.
static void
write_head(void)
{
    800040cc:	1101                	addi	sp,sp,-32
    800040ce:	ec06                	sd	ra,24(sp)
    800040d0:	e822                	sd	s0,16(sp)
    800040d2:	e426                	sd	s1,8(sp)
    800040d4:	e04a                	sd	s2,0(sp)
    800040d6:	1000                	addi	s0,sp,32
  struct buf *buf = bread(log.dev, log.start);
    800040d8:	0001d917          	auipc	s2,0x1d
    800040dc:	c7090913          	addi	s2,s2,-912 # 80020d48 <log>
    800040e0:	01892583          	lw	a1,24(s2)
    800040e4:	02892503          	lw	a0,40(s2)
    800040e8:	fffff097          	auipc	ra,0xfffff
    800040ec:	fe6080e7          	jalr	-26(ra) # 800030ce <bread>
    800040f0:	84aa                	mv	s1,a0
  struct logheader *hb = (struct logheader *) (buf->data);
  int i;
  hb->n = log.lh.n;
    800040f2:	02c92683          	lw	a3,44(s2)
    800040f6:	cd34                	sw	a3,88(a0)
  for (i = 0; i < log.lh.n; i++) {
    800040f8:	02d05863          	blez	a3,80004128 <write_head+0x5c>
    800040fc:	0001d797          	auipc	a5,0x1d
    80004100:	c7c78793          	addi	a5,a5,-900 # 80020d78 <log+0x30>
    80004104:	05c50713          	addi	a4,a0,92
    80004108:	36fd                	addiw	a3,a3,-1
    8000410a:	02069613          	slli	a2,a3,0x20
    8000410e:	01e65693          	srli	a3,a2,0x1e
    80004112:	0001d617          	auipc	a2,0x1d
    80004116:	c6a60613          	addi	a2,a2,-918 # 80020d7c <log+0x34>
    8000411a:	96b2                	add	a3,a3,a2
    hb->block[i] = log.lh.block[i];
    8000411c:	4390                	lw	a2,0(a5)
    8000411e:	c310                	sw	a2,0(a4)
  for (i = 0; i < log.lh.n; i++) {
    80004120:	0791                	addi	a5,a5,4
    80004122:	0711                	addi	a4,a4,4 # 43004 <_entry-0x7ffbcffc>
    80004124:	fed79ce3          	bne	a5,a3,8000411c <write_head+0x50>
  }
  bwrite(buf);
    80004128:	8526                	mv	a0,s1
    8000412a:	fffff097          	auipc	ra,0xfffff
    8000412e:	096080e7          	jalr	150(ra) # 800031c0 <bwrite>
  brelse(buf);
    80004132:	8526                	mv	a0,s1
    80004134:	fffff097          	auipc	ra,0xfffff
    80004138:	0ca080e7          	jalr	202(ra) # 800031fe <brelse>
}
    8000413c:	60e2                	ld	ra,24(sp)
    8000413e:	6442                	ld	s0,16(sp)
    80004140:	64a2                	ld	s1,8(sp)
    80004142:	6902                	ld	s2,0(sp)
    80004144:	6105                	addi	sp,sp,32
    80004146:	8082                	ret

0000000080004148 <install_trans>:
  for (tail = 0; tail < log.lh.n; tail++) {
    80004148:	0001d797          	auipc	a5,0x1d
    8000414c:	c2c7a783          	lw	a5,-980(a5) # 80020d74 <log+0x2c>
    80004150:	0af05d63          	blez	a5,8000420a <install_trans+0xc2>
{
    80004154:	7139                	addi	sp,sp,-64
    80004156:	fc06                	sd	ra,56(sp)
    80004158:	f822                	sd	s0,48(sp)
    8000415a:	f426                	sd	s1,40(sp)
    8000415c:	f04a                	sd	s2,32(sp)
    8000415e:	ec4e                	sd	s3,24(sp)
    80004160:	e852                	sd	s4,16(sp)
    80004162:	e456                	sd	s5,8(sp)
    80004164:	e05a                	sd	s6,0(sp)
    80004166:	0080                	addi	s0,sp,64
    80004168:	8b2a                	mv	s6,a0
    8000416a:	0001da97          	auipc	s5,0x1d
    8000416e:	c0ea8a93          	addi	s5,s5,-1010 # 80020d78 <log+0x30>
  for (tail = 0; tail < log.lh.n; tail++) {
    80004172:	4a01                	li	s4,0
    struct buf *lbuf = bread(log.dev, log.start+tail+1); // read log block
    80004174:	0001d997          	auipc	s3,0x1d
    80004178:	bd498993          	addi	s3,s3,-1068 # 80020d48 <log>
    8000417c:	a00d                	j	8000419e <install_trans+0x56>
    brelse(lbuf);
    8000417e:	854a                	mv	a0,s2
    80004180:	fffff097          	auipc	ra,0xfffff
    80004184:	07e080e7          	jalr	126(ra) # 800031fe <brelse>
    brelse(dbuf);
    80004188:	8526                	mv	a0,s1
    8000418a:	fffff097          	auipc	ra,0xfffff
    8000418e:	074080e7          	jalr	116(ra) # 800031fe <brelse>
  for (tail = 0; tail < log.lh.n; tail++) {
    80004192:	2a05                	addiw	s4,s4,1
    80004194:	0a91                	addi	s5,s5,4
    80004196:	02c9a783          	lw	a5,44(s3)
    8000419a:	04fa5e63          	bge	s4,a5,800041f6 <install_trans+0xae>
    struct buf *lbuf = bread(log.dev, log.start+tail+1); // read log block
    8000419e:	0189a583          	lw	a1,24(s3)
    800041a2:	014585bb          	addw	a1,a1,s4
    800041a6:	2585                	addiw	a1,a1,1
    800041a8:	0289a503          	lw	a0,40(s3)
    800041ac:	fffff097          	auipc	ra,0xfffff
    800041b0:	f22080e7          	jalr	-222(ra) # 800030ce <bread>
    800041b4:	892a                	mv	s2,a0
    struct buf *dbuf = bread(log.dev, log.lh.block[tail]); // read dst
    800041b6:	000aa583          	lw	a1,0(s5)
    800041ba:	0289a503          	lw	a0,40(s3)
    800041be:	fffff097          	auipc	ra,0xfffff
    800041c2:	f10080e7          	jalr	-240(ra) # 800030ce <bread>
    800041c6:	84aa                	mv	s1,a0
    memmove(dbuf->data, lbuf->data, BSIZE);  // copy block to dst
    800041c8:	40000613          	li	a2,1024
    800041cc:	05890593          	addi	a1,s2,88
    800041d0:	05850513          	addi	a0,a0,88
    800041d4:	ffffd097          	auipc	ra,0xffffd
    800041d8:	b5a080e7          	jalr	-1190(ra) # 80000d2e <memmove>
    bwrite(dbuf);  // write dst to disk
    800041dc:	8526                	mv	a0,s1
    800041de:	fffff097          	auipc	ra,0xfffff
    800041e2:	fe2080e7          	jalr	-30(ra) # 800031c0 <bwrite>
    if(recovering == 0)
    800041e6:	f80b1ce3          	bnez	s6,8000417e <install_trans+0x36>
      bunpin(dbuf);
    800041ea:	8526                	mv	a0,s1
    800041ec:	fffff097          	auipc	ra,0xfffff
    800041f0:	0ec080e7          	jalr	236(ra) # 800032d8 <bunpin>
    800041f4:	b769                	j	8000417e <install_trans+0x36>
}
    800041f6:	70e2                	ld	ra,56(sp)
    800041f8:	7442                	ld	s0,48(sp)
    800041fa:	74a2                	ld	s1,40(sp)
    800041fc:	7902                	ld	s2,32(sp)
    800041fe:	69e2                	ld	s3,24(sp)
    80004200:	6a42                	ld	s4,16(sp)
    80004202:	6aa2                	ld	s5,8(sp)
    80004204:	6b02                	ld	s6,0(sp)
    80004206:	6121                	addi	sp,sp,64
    80004208:	8082                	ret
    8000420a:	8082                	ret

000000008000420c <initlog>:
{
    8000420c:	7179                	addi	sp,sp,-48
    8000420e:	f406                	sd	ra,40(sp)
    80004210:	f022                	sd	s0,32(sp)
    80004212:	ec26                	sd	s1,24(sp)
    80004214:	e84a                	sd	s2,16(sp)
    80004216:	e44e                	sd	s3,8(sp)
    80004218:	1800                	addi	s0,sp,48
    8000421a:	892a                	mv	s2,a0
    8000421c:	89ae                	mv	s3,a1
  initlock(&log.lock, "log");
    8000421e:	0001d497          	auipc	s1,0x1d
    80004222:	b2a48493          	addi	s1,s1,-1238 # 80020d48 <log>
    80004226:	00004597          	auipc	a1,0x4
    8000422a:	40a58593          	addi	a1,a1,1034 # 80008630 <syscalls+0x1e0>
    8000422e:	8526                	mv	a0,s1
    80004230:	ffffd097          	auipc	ra,0xffffd
    80004234:	916080e7          	jalr	-1770(ra) # 80000b46 <initlock>
  log.start = sb->logstart;
    80004238:	0149a583          	lw	a1,20(s3)
    8000423c:	cc8c                	sw	a1,24(s1)
  log.size = sb->nlog;
    8000423e:	0109a783          	lw	a5,16(s3)
    80004242:	ccdc                	sw	a5,28(s1)
  log.dev = dev;
    80004244:	0324a423          	sw	s2,40(s1)
  struct buf *buf = bread(log.dev, log.start);
    80004248:	854a                	mv	a0,s2
    8000424a:	fffff097          	auipc	ra,0xfffff
    8000424e:	e84080e7          	jalr	-380(ra) # 800030ce <bread>
  log.lh.n = lh->n;
    80004252:	4d34                	lw	a3,88(a0)
    80004254:	d4d4                	sw	a3,44(s1)
  for (i = 0; i < log.lh.n; i++) {
    80004256:	02d05663          	blez	a3,80004282 <initlog+0x76>
    8000425a:	05c50793          	addi	a5,a0,92
    8000425e:	0001d717          	auipc	a4,0x1d
    80004262:	b1a70713          	addi	a4,a4,-1254 # 80020d78 <log+0x30>
    80004266:	36fd                	addiw	a3,a3,-1
    80004268:	02069613          	slli	a2,a3,0x20
    8000426c:	01e65693          	srli	a3,a2,0x1e
    80004270:	06050613          	addi	a2,a0,96
    80004274:	96b2                	add	a3,a3,a2
    log.lh.block[i] = lh->block[i];
    80004276:	4390                	lw	a2,0(a5)
    80004278:	c310                	sw	a2,0(a4)
  for (i = 0; i < log.lh.n; i++) {
    8000427a:	0791                	addi	a5,a5,4
    8000427c:	0711                	addi	a4,a4,4
    8000427e:	fed79ce3          	bne	a5,a3,80004276 <initlog+0x6a>
  brelse(buf);
    80004282:	fffff097          	auipc	ra,0xfffff
    80004286:	f7c080e7          	jalr	-132(ra) # 800031fe <brelse>

static void
recover_from_log(void)
{
  read_head();
  install_trans(1); // if committed, copy from log to disk
    8000428a:	4505                	li	a0,1
    8000428c:	00000097          	auipc	ra,0x0
    80004290:	ebc080e7          	jalr	-324(ra) # 80004148 <install_trans>
  log.lh.n = 0;
    80004294:	0001d797          	auipc	a5,0x1d
    80004298:	ae07a023          	sw	zero,-1312(a5) # 80020d74 <log+0x2c>
  write_head(); // clear the log
    8000429c:	00000097          	auipc	ra,0x0
    800042a0:	e30080e7          	jalr	-464(ra) # 800040cc <write_head>
}
    800042a4:	70a2                	ld	ra,40(sp)
    800042a6:	7402                	ld	s0,32(sp)
    800042a8:	64e2                	ld	s1,24(sp)
    800042aa:	6942                	ld	s2,16(sp)
    800042ac:	69a2                	ld	s3,8(sp)
    800042ae:	6145                	addi	sp,sp,48
    800042b0:	8082                	ret

00000000800042b2 <begin_op>:
}

// called at the start of each FS system call.
void
begin_op(void)
{
    800042b2:	1101                	addi	sp,sp,-32
    800042b4:	ec06                	sd	ra,24(sp)
    800042b6:	e822                	sd	s0,16(sp)
    800042b8:	e426                	sd	s1,8(sp)
    800042ba:	e04a                	sd	s2,0(sp)
    800042bc:	1000                	addi	s0,sp,32
  acquire(&log.lock);
    800042be:	0001d517          	auipc	a0,0x1d
    800042c2:	a8a50513          	addi	a0,a0,-1398 # 80020d48 <log>
    800042c6:	ffffd097          	auipc	ra,0xffffd
    800042ca:	910080e7          	jalr	-1776(ra) # 80000bd6 <acquire>
  while(1){
    if(log.committing){
    800042ce:	0001d497          	auipc	s1,0x1d
    800042d2:	a7a48493          	addi	s1,s1,-1414 # 80020d48 <log>
      sleep(&log, &log.lock);
    } else if(log.lh.n + (log.outstanding+1)*MAXOPBLOCKS > LOGSIZE){
    800042d6:	4979                	li	s2,30
    800042d8:	a039                	j	800042e6 <begin_op+0x34>
      sleep(&log, &log.lock);
    800042da:	85a6                	mv	a1,s1
    800042dc:	8526                	mv	a0,s1
    800042de:	ffffe097          	auipc	ra,0xffffe
    800042e2:	de4080e7          	jalr	-540(ra) # 800020c2 <sleep>
    if(log.committing){
    800042e6:	50dc                	lw	a5,36(s1)
    800042e8:	fbed                	bnez	a5,800042da <begin_op+0x28>
    } else if(log.lh.n + (log.outstanding+1)*MAXOPBLOCKS > LOGSIZE){
    800042ea:	5098                	lw	a4,32(s1)
    800042ec:	2705                	addiw	a4,a4,1
    800042ee:	0007069b          	sext.w	a3,a4
    800042f2:	0027179b          	slliw	a5,a4,0x2
    800042f6:	9fb9                	addw	a5,a5,a4
    800042f8:	0017979b          	slliw	a5,a5,0x1
    800042fc:	54d8                	lw	a4,44(s1)
    800042fe:	9fb9                	addw	a5,a5,a4
    80004300:	00f95963          	bge	s2,a5,80004312 <begin_op+0x60>
      // this op might exhaust log space; wait for commit.
      sleep(&log, &log.lock);
    80004304:	85a6                	mv	a1,s1
    80004306:	8526                	mv	a0,s1
    80004308:	ffffe097          	auipc	ra,0xffffe
    8000430c:	dba080e7          	jalr	-582(ra) # 800020c2 <sleep>
    80004310:	bfd9                	j	800042e6 <begin_op+0x34>
    } else {
      log.outstanding += 1;
    80004312:	0001d517          	auipc	a0,0x1d
    80004316:	a3650513          	addi	a0,a0,-1482 # 80020d48 <log>
    8000431a:	d114                	sw	a3,32(a0)
      release(&log.lock);
    8000431c:	ffffd097          	auipc	ra,0xffffd
    80004320:	96e080e7          	jalr	-1682(ra) # 80000c8a <release>
      break;
    }
  }
}
    80004324:	60e2                	ld	ra,24(sp)
    80004326:	6442                	ld	s0,16(sp)
    80004328:	64a2                	ld	s1,8(sp)
    8000432a:	6902                	ld	s2,0(sp)
    8000432c:	6105                	addi	sp,sp,32
    8000432e:	8082                	ret

0000000080004330 <end_op>:

// called at the end of each FS system call.
// commits if this was the last outstanding operation.
void
end_op(void)
{
    80004330:	7139                	addi	sp,sp,-64
    80004332:	fc06                	sd	ra,56(sp)
    80004334:	f822                	sd	s0,48(sp)
    80004336:	f426                	sd	s1,40(sp)
    80004338:	f04a                	sd	s2,32(sp)
    8000433a:	ec4e                	sd	s3,24(sp)
    8000433c:	e852                	sd	s4,16(sp)
    8000433e:	e456                	sd	s5,8(sp)
    80004340:	0080                	addi	s0,sp,64
  int do_commit = 0;

  acquire(&log.lock);
    80004342:	0001d497          	auipc	s1,0x1d
    80004346:	a0648493          	addi	s1,s1,-1530 # 80020d48 <log>
    8000434a:	8526                	mv	a0,s1
    8000434c:	ffffd097          	auipc	ra,0xffffd
    80004350:	88a080e7          	jalr	-1910(ra) # 80000bd6 <acquire>
  log.outstanding -= 1;
    80004354:	509c                	lw	a5,32(s1)
    80004356:	37fd                	addiw	a5,a5,-1
    80004358:	0007891b          	sext.w	s2,a5
    8000435c:	d09c                	sw	a5,32(s1)
  if(log.committing)
    8000435e:	50dc                	lw	a5,36(s1)
    80004360:	e7b9                	bnez	a5,800043ae <end_op+0x7e>
    panic("log.committing");
  if(log.outstanding == 0){
    80004362:	04091e63          	bnez	s2,800043be <end_op+0x8e>
    do_commit = 1;
    log.committing = 1;
    80004366:	0001d497          	auipc	s1,0x1d
    8000436a:	9e248493          	addi	s1,s1,-1566 # 80020d48 <log>
    8000436e:	4785                	li	a5,1
    80004370:	d0dc                	sw	a5,36(s1)
    // begin_op() may be waiting for log space,
    // and decrementing log.outstanding has decreased
    // the amount of reserved space.
    wakeup(&log);
  }
  release(&log.lock);
    80004372:	8526                	mv	a0,s1
    80004374:	ffffd097          	auipc	ra,0xffffd
    80004378:	916080e7          	jalr	-1770(ra) # 80000c8a <release>
}

static void
commit()
{
  if (log.lh.n > 0) {
    8000437c:	54dc                	lw	a5,44(s1)
    8000437e:	06f04763          	bgtz	a5,800043ec <end_op+0xbc>
    acquire(&log.lock);
    80004382:	0001d497          	auipc	s1,0x1d
    80004386:	9c648493          	addi	s1,s1,-1594 # 80020d48 <log>
    8000438a:	8526                	mv	a0,s1
    8000438c:	ffffd097          	auipc	ra,0xffffd
    80004390:	84a080e7          	jalr	-1974(ra) # 80000bd6 <acquire>
    log.committing = 0;
    80004394:	0204a223          	sw	zero,36(s1)
    wakeup(&log);
    80004398:	8526                	mv	a0,s1
    8000439a:	ffffe097          	auipc	ra,0xffffe
    8000439e:	d8c080e7          	jalr	-628(ra) # 80002126 <wakeup>
    release(&log.lock);
    800043a2:	8526                	mv	a0,s1
    800043a4:	ffffd097          	auipc	ra,0xffffd
    800043a8:	8e6080e7          	jalr	-1818(ra) # 80000c8a <release>
}
    800043ac:	a03d                	j	800043da <end_op+0xaa>
    panic("log.committing");
    800043ae:	00004517          	auipc	a0,0x4
    800043b2:	28a50513          	addi	a0,a0,650 # 80008638 <syscalls+0x1e8>
    800043b6:	ffffc097          	auipc	ra,0xffffc
    800043ba:	18a080e7          	jalr	394(ra) # 80000540 <panic>
    wakeup(&log);
    800043be:	0001d497          	auipc	s1,0x1d
    800043c2:	98a48493          	addi	s1,s1,-1654 # 80020d48 <log>
    800043c6:	8526                	mv	a0,s1
    800043c8:	ffffe097          	auipc	ra,0xffffe
    800043cc:	d5e080e7          	jalr	-674(ra) # 80002126 <wakeup>
  release(&log.lock);
    800043d0:	8526                	mv	a0,s1
    800043d2:	ffffd097          	auipc	ra,0xffffd
    800043d6:	8b8080e7          	jalr	-1864(ra) # 80000c8a <release>
}
    800043da:	70e2                	ld	ra,56(sp)
    800043dc:	7442                	ld	s0,48(sp)
    800043de:	74a2                	ld	s1,40(sp)
    800043e0:	7902                	ld	s2,32(sp)
    800043e2:	69e2                	ld	s3,24(sp)
    800043e4:	6a42                	ld	s4,16(sp)
    800043e6:	6aa2                	ld	s5,8(sp)
    800043e8:	6121                	addi	sp,sp,64
    800043ea:	8082                	ret
  for (tail = 0; tail < log.lh.n; tail++) {
    800043ec:	0001da97          	auipc	s5,0x1d
    800043f0:	98ca8a93          	addi	s5,s5,-1652 # 80020d78 <log+0x30>
    struct buf *to = bread(log.dev, log.start+tail+1); // log block
    800043f4:	0001da17          	auipc	s4,0x1d
    800043f8:	954a0a13          	addi	s4,s4,-1708 # 80020d48 <log>
    800043fc:	018a2583          	lw	a1,24(s4)
    80004400:	012585bb          	addw	a1,a1,s2
    80004404:	2585                	addiw	a1,a1,1
    80004406:	028a2503          	lw	a0,40(s4)
    8000440a:	fffff097          	auipc	ra,0xfffff
    8000440e:	cc4080e7          	jalr	-828(ra) # 800030ce <bread>
    80004412:	84aa                	mv	s1,a0
    struct buf *from = bread(log.dev, log.lh.block[tail]); // cache block
    80004414:	000aa583          	lw	a1,0(s5)
    80004418:	028a2503          	lw	a0,40(s4)
    8000441c:	fffff097          	auipc	ra,0xfffff
    80004420:	cb2080e7          	jalr	-846(ra) # 800030ce <bread>
    80004424:	89aa                	mv	s3,a0
    memmove(to->data, from->data, BSIZE);
    80004426:	40000613          	li	a2,1024
    8000442a:	05850593          	addi	a1,a0,88
    8000442e:	05848513          	addi	a0,s1,88
    80004432:	ffffd097          	auipc	ra,0xffffd
    80004436:	8fc080e7          	jalr	-1796(ra) # 80000d2e <memmove>
    bwrite(to);  // write the log
    8000443a:	8526                	mv	a0,s1
    8000443c:	fffff097          	auipc	ra,0xfffff
    80004440:	d84080e7          	jalr	-636(ra) # 800031c0 <bwrite>
    brelse(from);
    80004444:	854e                	mv	a0,s3
    80004446:	fffff097          	auipc	ra,0xfffff
    8000444a:	db8080e7          	jalr	-584(ra) # 800031fe <brelse>
    brelse(to);
    8000444e:	8526                	mv	a0,s1
    80004450:	fffff097          	auipc	ra,0xfffff
    80004454:	dae080e7          	jalr	-594(ra) # 800031fe <brelse>
  for (tail = 0; tail < log.lh.n; tail++) {
    80004458:	2905                	addiw	s2,s2,1
    8000445a:	0a91                	addi	s5,s5,4
    8000445c:	02ca2783          	lw	a5,44(s4)
    80004460:	f8f94ee3          	blt	s2,a5,800043fc <end_op+0xcc>
    write_log();     // Write modified blocks from cache to log
    write_head();    // Write header to disk -- the real commit
    80004464:	00000097          	auipc	ra,0x0
    80004468:	c68080e7          	jalr	-920(ra) # 800040cc <write_head>
    install_trans(0); // Now install writes to home locations
    8000446c:	4501                	li	a0,0
    8000446e:	00000097          	auipc	ra,0x0
    80004472:	cda080e7          	jalr	-806(ra) # 80004148 <install_trans>
    log.lh.n = 0;
    80004476:	0001d797          	auipc	a5,0x1d
    8000447a:	8e07af23          	sw	zero,-1794(a5) # 80020d74 <log+0x2c>
    write_head();    // Erase the transaction from the log
    8000447e:	00000097          	auipc	ra,0x0
    80004482:	c4e080e7          	jalr	-946(ra) # 800040cc <write_head>
    80004486:	bdf5                	j	80004382 <end_op+0x52>

0000000080004488 <log_write>:
//   modify bp->data[]
//   log_write(bp)
//   brelse(bp)
void
log_write(struct buf *b)
{
    80004488:	1101                	addi	sp,sp,-32
    8000448a:	ec06                	sd	ra,24(sp)
    8000448c:	e822                	sd	s0,16(sp)
    8000448e:	e426                	sd	s1,8(sp)
    80004490:	e04a                	sd	s2,0(sp)
    80004492:	1000                	addi	s0,sp,32
    80004494:	84aa                	mv	s1,a0
  int i;

  acquire(&log.lock);
    80004496:	0001d917          	auipc	s2,0x1d
    8000449a:	8b290913          	addi	s2,s2,-1870 # 80020d48 <log>
    8000449e:	854a                	mv	a0,s2
    800044a0:	ffffc097          	auipc	ra,0xffffc
    800044a4:	736080e7          	jalr	1846(ra) # 80000bd6 <acquire>
  if (log.lh.n >= LOGSIZE || log.lh.n >= log.size - 1)
    800044a8:	02c92603          	lw	a2,44(s2)
    800044ac:	47f5                	li	a5,29
    800044ae:	06c7c563          	blt	a5,a2,80004518 <log_write+0x90>
    800044b2:	0001d797          	auipc	a5,0x1d
    800044b6:	8b27a783          	lw	a5,-1870(a5) # 80020d64 <log+0x1c>
    800044ba:	37fd                	addiw	a5,a5,-1
    800044bc:	04f65e63          	bge	a2,a5,80004518 <log_write+0x90>
    panic("too big a transaction");
  if (log.outstanding < 1)
    800044c0:	0001d797          	auipc	a5,0x1d
    800044c4:	8a87a783          	lw	a5,-1880(a5) # 80020d68 <log+0x20>
    800044c8:	06f05063          	blez	a5,80004528 <log_write+0xa0>
    panic("log_write outside of trans");

  for (i = 0; i < log.lh.n; i++) {
    800044cc:	4781                	li	a5,0
    800044ce:	06c05563          	blez	a2,80004538 <log_write+0xb0>
    if (log.lh.block[i] == b->blockno)   // log absorption
    800044d2:	44cc                	lw	a1,12(s1)
    800044d4:	0001d717          	auipc	a4,0x1d
    800044d8:	8a470713          	addi	a4,a4,-1884 # 80020d78 <log+0x30>
  for (i = 0; i < log.lh.n; i++) {
    800044dc:	4781                	li	a5,0
    if (log.lh.block[i] == b->blockno)   // log absorption
    800044de:	4314                	lw	a3,0(a4)
    800044e0:	04b68c63          	beq	a3,a1,80004538 <log_write+0xb0>
  for (i = 0; i < log.lh.n; i++) {
    800044e4:	2785                	addiw	a5,a5,1
    800044e6:	0711                	addi	a4,a4,4
    800044e8:	fef61be3          	bne	a2,a5,800044de <log_write+0x56>
      break;
  }
  log.lh.block[i] = b->blockno;
    800044ec:	0621                	addi	a2,a2,8
    800044ee:	060a                	slli	a2,a2,0x2
    800044f0:	0001d797          	auipc	a5,0x1d
    800044f4:	85878793          	addi	a5,a5,-1960 # 80020d48 <log>
    800044f8:	97b2                	add	a5,a5,a2
    800044fa:	44d8                	lw	a4,12(s1)
    800044fc:	cb98                	sw	a4,16(a5)
  if (i == log.lh.n) {  // Add new block to log?
    bpin(b);
    800044fe:	8526                	mv	a0,s1
    80004500:	fffff097          	auipc	ra,0xfffff
    80004504:	d9c080e7          	jalr	-612(ra) # 8000329c <bpin>
    log.lh.n++;
    80004508:	0001d717          	auipc	a4,0x1d
    8000450c:	84070713          	addi	a4,a4,-1984 # 80020d48 <log>
    80004510:	575c                	lw	a5,44(a4)
    80004512:	2785                	addiw	a5,a5,1
    80004514:	d75c                	sw	a5,44(a4)
    80004516:	a82d                	j	80004550 <log_write+0xc8>
    panic("too big a transaction");
    80004518:	00004517          	auipc	a0,0x4
    8000451c:	13050513          	addi	a0,a0,304 # 80008648 <syscalls+0x1f8>
    80004520:	ffffc097          	auipc	ra,0xffffc
    80004524:	020080e7          	jalr	32(ra) # 80000540 <panic>
    panic("log_write outside of trans");
    80004528:	00004517          	auipc	a0,0x4
    8000452c:	13850513          	addi	a0,a0,312 # 80008660 <syscalls+0x210>
    80004530:	ffffc097          	auipc	ra,0xffffc
    80004534:	010080e7          	jalr	16(ra) # 80000540 <panic>
  log.lh.block[i] = b->blockno;
    80004538:	00878693          	addi	a3,a5,8
    8000453c:	068a                	slli	a3,a3,0x2
    8000453e:	0001d717          	auipc	a4,0x1d
    80004542:	80a70713          	addi	a4,a4,-2038 # 80020d48 <log>
    80004546:	9736                	add	a4,a4,a3
    80004548:	44d4                	lw	a3,12(s1)
    8000454a:	cb14                	sw	a3,16(a4)
  if (i == log.lh.n) {  // Add new block to log?
    8000454c:	faf609e3          	beq	a2,a5,800044fe <log_write+0x76>
  }
  release(&log.lock);
    80004550:	0001c517          	auipc	a0,0x1c
    80004554:	7f850513          	addi	a0,a0,2040 # 80020d48 <log>
    80004558:	ffffc097          	auipc	ra,0xffffc
    8000455c:	732080e7          	jalr	1842(ra) # 80000c8a <release>
}
    80004560:	60e2                	ld	ra,24(sp)
    80004562:	6442                	ld	s0,16(sp)
    80004564:	64a2                	ld	s1,8(sp)
    80004566:	6902                	ld	s2,0(sp)
    80004568:	6105                	addi	sp,sp,32
    8000456a:	8082                	ret

000000008000456c <initsleeplock>:
#include "proc.h"
#include "sleeplock.h"

void
initsleeplock(struct sleeplock *lk, char *name)
{
    8000456c:	1101                	addi	sp,sp,-32
    8000456e:	ec06                	sd	ra,24(sp)
    80004570:	e822                	sd	s0,16(sp)
    80004572:	e426                	sd	s1,8(sp)
    80004574:	e04a                	sd	s2,0(sp)
    80004576:	1000                	addi	s0,sp,32
    80004578:	84aa                	mv	s1,a0
    8000457a:	892e                	mv	s2,a1
  initlock(&lk->lk, "sleep lock");
    8000457c:	00004597          	auipc	a1,0x4
    80004580:	10458593          	addi	a1,a1,260 # 80008680 <syscalls+0x230>
    80004584:	0521                	addi	a0,a0,8
    80004586:	ffffc097          	auipc	ra,0xffffc
    8000458a:	5c0080e7          	jalr	1472(ra) # 80000b46 <initlock>
  lk->name = name;
    8000458e:	0324b023          	sd	s2,32(s1)
  lk->locked = 0;
    80004592:	0004a023          	sw	zero,0(s1)
  lk->pid = 0;
    80004596:	0204a423          	sw	zero,40(s1)
}
    8000459a:	60e2                	ld	ra,24(sp)
    8000459c:	6442                	ld	s0,16(sp)
    8000459e:	64a2                	ld	s1,8(sp)
    800045a0:	6902                	ld	s2,0(sp)
    800045a2:	6105                	addi	sp,sp,32
    800045a4:	8082                	ret

00000000800045a6 <acquiresleep>:

void
acquiresleep(struct sleeplock *lk)
{
    800045a6:	1101                	addi	sp,sp,-32
    800045a8:	ec06                	sd	ra,24(sp)
    800045aa:	e822                	sd	s0,16(sp)
    800045ac:	e426                	sd	s1,8(sp)
    800045ae:	e04a                	sd	s2,0(sp)
    800045b0:	1000                	addi	s0,sp,32
    800045b2:	84aa                	mv	s1,a0
  acquire(&lk->lk);
    800045b4:	00850913          	addi	s2,a0,8
    800045b8:	854a                	mv	a0,s2
    800045ba:	ffffc097          	auipc	ra,0xffffc
    800045be:	61c080e7          	jalr	1564(ra) # 80000bd6 <acquire>
  while (lk->locked) {
    800045c2:	409c                	lw	a5,0(s1)
    800045c4:	cb89                	beqz	a5,800045d6 <acquiresleep+0x30>
    sleep(lk, &lk->lk);
    800045c6:	85ca                	mv	a1,s2
    800045c8:	8526                	mv	a0,s1
    800045ca:	ffffe097          	auipc	ra,0xffffe
    800045ce:	af8080e7          	jalr	-1288(ra) # 800020c2 <sleep>
  while (lk->locked) {
    800045d2:	409c                	lw	a5,0(s1)
    800045d4:	fbed                	bnez	a5,800045c6 <acquiresleep+0x20>
  }
  lk->locked = 1;
    800045d6:	4785                	li	a5,1
    800045d8:	c09c                	sw	a5,0(s1)
  lk->pid = myproc()->pid;
    800045da:	ffffd097          	auipc	ra,0xffffd
    800045de:	3d2080e7          	jalr	978(ra) # 800019ac <myproc>
    800045e2:	591c                	lw	a5,48(a0)
    800045e4:	d49c                	sw	a5,40(s1)
  release(&lk->lk);
    800045e6:	854a                	mv	a0,s2
    800045e8:	ffffc097          	auipc	ra,0xffffc
    800045ec:	6a2080e7          	jalr	1698(ra) # 80000c8a <release>
}
    800045f0:	60e2                	ld	ra,24(sp)
    800045f2:	6442                	ld	s0,16(sp)
    800045f4:	64a2                	ld	s1,8(sp)
    800045f6:	6902                	ld	s2,0(sp)
    800045f8:	6105                	addi	sp,sp,32
    800045fa:	8082                	ret

00000000800045fc <releasesleep>:

void
releasesleep(struct sleeplock *lk)
{
    800045fc:	1101                	addi	sp,sp,-32
    800045fe:	ec06                	sd	ra,24(sp)
    80004600:	e822                	sd	s0,16(sp)
    80004602:	e426                	sd	s1,8(sp)
    80004604:	e04a                	sd	s2,0(sp)
    80004606:	1000                	addi	s0,sp,32
    80004608:	84aa                	mv	s1,a0
  acquire(&lk->lk);
    8000460a:	00850913          	addi	s2,a0,8
    8000460e:	854a                	mv	a0,s2
    80004610:	ffffc097          	auipc	ra,0xffffc
    80004614:	5c6080e7          	jalr	1478(ra) # 80000bd6 <acquire>
  lk->locked = 0;
    80004618:	0004a023          	sw	zero,0(s1)
  lk->pid = 0;
    8000461c:	0204a423          	sw	zero,40(s1)
  wakeup(lk);
    80004620:	8526                	mv	a0,s1
    80004622:	ffffe097          	auipc	ra,0xffffe
    80004626:	b04080e7          	jalr	-1276(ra) # 80002126 <wakeup>
  release(&lk->lk);
    8000462a:	854a                	mv	a0,s2
    8000462c:	ffffc097          	auipc	ra,0xffffc
    80004630:	65e080e7          	jalr	1630(ra) # 80000c8a <release>
}
    80004634:	60e2                	ld	ra,24(sp)
    80004636:	6442                	ld	s0,16(sp)
    80004638:	64a2                	ld	s1,8(sp)
    8000463a:	6902                	ld	s2,0(sp)
    8000463c:	6105                	addi	sp,sp,32
    8000463e:	8082                	ret

0000000080004640 <holdingsleep>:

int
holdingsleep(struct sleeplock *lk)
{
    80004640:	7179                	addi	sp,sp,-48
    80004642:	f406                	sd	ra,40(sp)
    80004644:	f022                	sd	s0,32(sp)
    80004646:	ec26                	sd	s1,24(sp)
    80004648:	e84a                	sd	s2,16(sp)
    8000464a:	e44e                	sd	s3,8(sp)
    8000464c:	1800                	addi	s0,sp,48
    8000464e:	84aa                	mv	s1,a0
  int r;
  
  acquire(&lk->lk);
    80004650:	00850913          	addi	s2,a0,8
    80004654:	854a                	mv	a0,s2
    80004656:	ffffc097          	auipc	ra,0xffffc
    8000465a:	580080e7          	jalr	1408(ra) # 80000bd6 <acquire>
  r = lk->locked && (lk->pid == myproc()->pid);
    8000465e:	409c                	lw	a5,0(s1)
    80004660:	ef99                	bnez	a5,8000467e <holdingsleep+0x3e>
    80004662:	4481                	li	s1,0
  release(&lk->lk);
    80004664:	854a                	mv	a0,s2
    80004666:	ffffc097          	auipc	ra,0xffffc
    8000466a:	624080e7          	jalr	1572(ra) # 80000c8a <release>
  return r;
}
    8000466e:	8526                	mv	a0,s1
    80004670:	70a2                	ld	ra,40(sp)
    80004672:	7402                	ld	s0,32(sp)
    80004674:	64e2                	ld	s1,24(sp)
    80004676:	6942                	ld	s2,16(sp)
    80004678:	69a2                	ld	s3,8(sp)
    8000467a:	6145                	addi	sp,sp,48
    8000467c:	8082                	ret
  r = lk->locked && (lk->pid == myproc()->pid);
    8000467e:	0284a983          	lw	s3,40(s1)
    80004682:	ffffd097          	auipc	ra,0xffffd
    80004686:	32a080e7          	jalr	810(ra) # 800019ac <myproc>
    8000468a:	5904                	lw	s1,48(a0)
    8000468c:	413484b3          	sub	s1,s1,s3
    80004690:	0014b493          	seqz	s1,s1
    80004694:	bfc1                	j	80004664 <holdingsleep+0x24>

0000000080004696 <fileinit>:
  struct file file[NFILE];
} ftable;

void
fileinit(void)
{
    80004696:	1141                	addi	sp,sp,-16
    80004698:	e406                	sd	ra,8(sp)
    8000469a:	e022                	sd	s0,0(sp)
    8000469c:	0800                	addi	s0,sp,16
  initlock(&ftable.lock, "ftable");
    8000469e:	00004597          	auipc	a1,0x4
    800046a2:	ff258593          	addi	a1,a1,-14 # 80008690 <syscalls+0x240>
    800046a6:	0001c517          	auipc	a0,0x1c
    800046aa:	7ea50513          	addi	a0,a0,2026 # 80020e90 <ftable>
    800046ae:	ffffc097          	auipc	ra,0xffffc
    800046b2:	498080e7          	jalr	1176(ra) # 80000b46 <initlock>
}
    800046b6:	60a2                	ld	ra,8(sp)
    800046b8:	6402                	ld	s0,0(sp)
    800046ba:	0141                	addi	sp,sp,16
    800046bc:	8082                	ret

00000000800046be <filealloc>:

// Allocate a file structure.
struct file*
filealloc(void)
{
    800046be:	1101                	addi	sp,sp,-32
    800046c0:	ec06                	sd	ra,24(sp)
    800046c2:	e822                	sd	s0,16(sp)
    800046c4:	e426                	sd	s1,8(sp)
    800046c6:	1000                	addi	s0,sp,32
  struct file *f;

  acquire(&ftable.lock);
    800046c8:	0001c517          	auipc	a0,0x1c
    800046cc:	7c850513          	addi	a0,a0,1992 # 80020e90 <ftable>
    800046d0:	ffffc097          	auipc	ra,0xffffc
    800046d4:	506080e7          	jalr	1286(ra) # 80000bd6 <acquire>
  for(f = ftable.file; f < ftable.file + NFILE; f++){
    800046d8:	0001c497          	auipc	s1,0x1c
    800046dc:	7d048493          	addi	s1,s1,2000 # 80020ea8 <ftable+0x18>
    800046e0:	0001d717          	auipc	a4,0x1d
    800046e4:	76870713          	addi	a4,a4,1896 # 80021e48 <disk>
    if(f->ref == 0){
    800046e8:	40dc                	lw	a5,4(s1)
    800046ea:	cf99                	beqz	a5,80004708 <filealloc+0x4a>
  for(f = ftable.file; f < ftable.file + NFILE; f++){
    800046ec:	02848493          	addi	s1,s1,40
    800046f0:	fee49ce3          	bne	s1,a4,800046e8 <filealloc+0x2a>
      f->ref = 1;
      release(&ftable.lock);
      return f;
    }
  }
  release(&ftable.lock);
    800046f4:	0001c517          	auipc	a0,0x1c
    800046f8:	79c50513          	addi	a0,a0,1948 # 80020e90 <ftable>
    800046fc:	ffffc097          	auipc	ra,0xffffc
    80004700:	58e080e7          	jalr	1422(ra) # 80000c8a <release>
  return 0;
    80004704:	4481                	li	s1,0
    80004706:	a819                	j	8000471c <filealloc+0x5e>
      f->ref = 1;
    80004708:	4785                	li	a5,1
    8000470a:	c0dc                	sw	a5,4(s1)
      release(&ftable.lock);
    8000470c:	0001c517          	auipc	a0,0x1c
    80004710:	78450513          	addi	a0,a0,1924 # 80020e90 <ftable>
    80004714:	ffffc097          	auipc	ra,0xffffc
    80004718:	576080e7          	jalr	1398(ra) # 80000c8a <release>
}
    8000471c:	8526                	mv	a0,s1
    8000471e:	60e2                	ld	ra,24(sp)
    80004720:	6442                	ld	s0,16(sp)
    80004722:	64a2                	ld	s1,8(sp)
    80004724:	6105                	addi	sp,sp,32
    80004726:	8082                	ret

0000000080004728 <filedup>:

// Increment ref count for file f.
struct file*
filedup(struct file *f)
{
    80004728:	1101                	addi	sp,sp,-32
    8000472a:	ec06                	sd	ra,24(sp)
    8000472c:	e822                	sd	s0,16(sp)
    8000472e:	e426                	sd	s1,8(sp)
    80004730:	1000                	addi	s0,sp,32
    80004732:	84aa                	mv	s1,a0
  acquire(&ftable.lock);
    80004734:	0001c517          	auipc	a0,0x1c
    80004738:	75c50513          	addi	a0,a0,1884 # 80020e90 <ftable>
    8000473c:	ffffc097          	auipc	ra,0xffffc
    80004740:	49a080e7          	jalr	1178(ra) # 80000bd6 <acquire>
  if(f->ref < 1)
    80004744:	40dc                	lw	a5,4(s1)
    80004746:	02f05263          	blez	a5,8000476a <filedup+0x42>
    panic("filedup");
  f->ref++;
    8000474a:	2785                	addiw	a5,a5,1
    8000474c:	c0dc                	sw	a5,4(s1)
  release(&ftable.lock);
    8000474e:	0001c517          	auipc	a0,0x1c
    80004752:	74250513          	addi	a0,a0,1858 # 80020e90 <ftable>
    80004756:	ffffc097          	auipc	ra,0xffffc
    8000475a:	534080e7          	jalr	1332(ra) # 80000c8a <release>
  return f;
}
    8000475e:	8526                	mv	a0,s1
    80004760:	60e2                	ld	ra,24(sp)
    80004762:	6442                	ld	s0,16(sp)
    80004764:	64a2                	ld	s1,8(sp)
    80004766:	6105                	addi	sp,sp,32
    80004768:	8082                	ret
    panic("filedup");
    8000476a:	00004517          	auipc	a0,0x4
    8000476e:	f2e50513          	addi	a0,a0,-210 # 80008698 <syscalls+0x248>
    80004772:	ffffc097          	auipc	ra,0xffffc
    80004776:	dce080e7          	jalr	-562(ra) # 80000540 <panic>

000000008000477a <fileclose>:

// Close file f.  (Decrement ref count, close when reaches 0.)
void
fileclose(struct file *f)
{
    8000477a:	7139                	addi	sp,sp,-64
    8000477c:	fc06                	sd	ra,56(sp)
    8000477e:	f822                	sd	s0,48(sp)
    80004780:	f426                	sd	s1,40(sp)
    80004782:	f04a                	sd	s2,32(sp)
    80004784:	ec4e                	sd	s3,24(sp)
    80004786:	e852                	sd	s4,16(sp)
    80004788:	e456                	sd	s5,8(sp)
    8000478a:	0080                	addi	s0,sp,64
    8000478c:	84aa                	mv	s1,a0
  struct file ff;

  acquire(&ftable.lock);
    8000478e:	0001c517          	auipc	a0,0x1c
    80004792:	70250513          	addi	a0,a0,1794 # 80020e90 <ftable>
    80004796:	ffffc097          	auipc	ra,0xffffc
    8000479a:	440080e7          	jalr	1088(ra) # 80000bd6 <acquire>
  if(f->ref < 1)
    8000479e:	40dc                	lw	a5,4(s1)
    800047a0:	06f05163          	blez	a5,80004802 <fileclose+0x88>
    panic("fileclose");
  if(--f->ref > 0){
    800047a4:	37fd                	addiw	a5,a5,-1
    800047a6:	0007871b          	sext.w	a4,a5
    800047aa:	c0dc                	sw	a5,4(s1)
    800047ac:	06e04363          	bgtz	a4,80004812 <fileclose+0x98>
    release(&ftable.lock);
    return;
  }
  ff = *f;
    800047b0:	0004a903          	lw	s2,0(s1)
    800047b4:	0094ca83          	lbu	s5,9(s1)
    800047b8:	0104ba03          	ld	s4,16(s1)
    800047bc:	0184b983          	ld	s3,24(s1)
  f->ref = 0;
    800047c0:	0004a223          	sw	zero,4(s1)
  f->type = FD_NONE;
    800047c4:	0004a023          	sw	zero,0(s1)
  release(&ftable.lock);
    800047c8:	0001c517          	auipc	a0,0x1c
    800047cc:	6c850513          	addi	a0,a0,1736 # 80020e90 <ftable>
    800047d0:	ffffc097          	auipc	ra,0xffffc
    800047d4:	4ba080e7          	jalr	1210(ra) # 80000c8a <release>

  if(ff.type == FD_PIPE){
    800047d8:	4785                	li	a5,1
    800047da:	04f90d63          	beq	s2,a5,80004834 <fileclose+0xba>
    pipeclose(ff.pipe, ff.writable);
  } else if(ff.type == FD_INODE || ff.type == FD_DEVICE){
    800047de:	3979                	addiw	s2,s2,-2
    800047e0:	4785                	li	a5,1
    800047e2:	0527e063          	bltu	a5,s2,80004822 <fileclose+0xa8>
    begin_op();
    800047e6:	00000097          	auipc	ra,0x0
    800047ea:	acc080e7          	jalr	-1332(ra) # 800042b2 <begin_op>
    iput(ff.ip);
    800047ee:	854e                	mv	a0,s3
    800047f0:	fffff097          	auipc	ra,0xfffff
    800047f4:	2b0080e7          	jalr	688(ra) # 80003aa0 <iput>
    end_op();
    800047f8:	00000097          	auipc	ra,0x0
    800047fc:	b38080e7          	jalr	-1224(ra) # 80004330 <end_op>
    80004800:	a00d                	j	80004822 <fileclose+0xa8>
    panic("fileclose");
    80004802:	00004517          	auipc	a0,0x4
    80004806:	e9e50513          	addi	a0,a0,-354 # 800086a0 <syscalls+0x250>
    8000480a:	ffffc097          	auipc	ra,0xffffc
    8000480e:	d36080e7          	jalr	-714(ra) # 80000540 <panic>
    release(&ftable.lock);
    80004812:	0001c517          	auipc	a0,0x1c
    80004816:	67e50513          	addi	a0,a0,1662 # 80020e90 <ftable>
    8000481a:	ffffc097          	auipc	ra,0xffffc
    8000481e:	470080e7          	jalr	1136(ra) # 80000c8a <release>
  }
}
    80004822:	70e2                	ld	ra,56(sp)
    80004824:	7442                	ld	s0,48(sp)
    80004826:	74a2                	ld	s1,40(sp)
    80004828:	7902                	ld	s2,32(sp)
    8000482a:	69e2                	ld	s3,24(sp)
    8000482c:	6a42                	ld	s4,16(sp)
    8000482e:	6aa2                	ld	s5,8(sp)
    80004830:	6121                	addi	sp,sp,64
    80004832:	8082                	ret
    pipeclose(ff.pipe, ff.writable);
    80004834:	85d6                	mv	a1,s5
    80004836:	8552                	mv	a0,s4
    80004838:	00000097          	auipc	ra,0x0
    8000483c:	34c080e7          	jalr	844(ra) # 80004b84 <pipeclose>
    80004840:	b7cd                	j	80004822 <fileclose+0xa8>

0000000080004842 <filestat>:

// Get metadata about file f.
// addr is a user virtual address, pointing to a struct stat.
int
filestat(struct file *f, uint64 addr)
{
    80004842:	715d                	addi	sp,sp,-80
    80004844:	e486                	sd	ra,72(sp)
    80004846:	e0a2                	sd	s0,64(sp)
    80004848:	fc26                	sd	s1,56(sp)
    8000484a:	f84a                	sd	s2,48(sp)
    8000484c:	f44e                	sd	s3,40(sp)
    8000484e:	0880                	addi	s0,sp,80
    80004850:	84aa                	mv	s1,a0
    80004852:	89ae                	mv	s3,a1
  struct proc *p = myproc();
    80004854:	ffffd097          	auipc	ra,0xffffd
    80004858:	158080e7          	jalr	344(ra) # 800019ac <myproc>
  struct stat st;
  
  if(f->type == FD_INODE || f->type == FD_DEVICE){
    8000485c:	409c                	lw	a5,0(s1)
    8000485e:	37f9                	addiw	a5,a5,-2
    80004860:	4705                	li	a4,1
    80004862:	04f76763          	bltu	a4,a5,800048b0 <filestat+0x6e>
    80004866:	892a                	mv	s2,a0
    ilock(f->ip);
    80004868:	6c88                	ld	a0,24(s1)
    8000486a:	fffff097          	auipc	ra,0xfffff
    8000486e:	07c080e7          	jalr	124(ra) # 800038e6 <ilock>
    stati(f->ip, &st);
    80004872:	fb840593          	addi	a1,s0,-72
    80004876:	6c88                	ld	a0,24(s1)
    80004878:	fffff097          	auipc	ra,0xfffff
    8000487c:	2f8080e7          	jalr	760(ra) # 80003b70 <stati>
    iunlock(f->ip);
    80004880:	6c88                	ld	a0,24(s1)
    80004882:	fffff097          	auipc	ra,0xfffff
    80004886:	126080e7          	jalr	294(ra) # 800039a8 <iunlock>
    if(copyout(p->pagetable, addr, (char *)&st, sizeof(st)) < 0)
    8000488a:	46e1                	li	a3,24
    8000488c:	fb840613          	addi	a2,s0,-72
    80004890:	85ce                	mv	a1,s3
    80004892:	05093503          	ld	a0,80(s2)
    80004896:	ffffd097          	auipc	ra,0xffffd
    8000489a:	dd6080e7          	jalr	-554(ra) # 8000166c <copyout>
    8000489e:	41f5551b          	sraiw	a0,a0,0x1f
      return -1;
    return 0;
  }
  return -1;
}
    800048a2:	60a6                	ld	ra,72(sp)
    800048a4:	6406                	ld	s0,64(sp)
    800048a6:	74e2                	ld	s1,56(sp)
    800048a8:	7942                	ld	s2,48(sp)
    800048aa:	79a2                	ld	s3,40(sp)
    800048ac:	6161                	addi	sp,sp,80
    800048ae:	8082                	ret
  return -1;
    800048b0:	557d                	li	a0,-1
    800048b2:	bfc5                	j	800048a2 <filestat+0x60>

00000000800048b4 <fileread>:

// Read from file f.
// addr is a user virtual address.
int
fileread(struct file *f, uint64 addr, int n)
{
    800048b4:	7179                	addi	sp,sp,-48
    800048b6:	f406                	sd	ra,40(sp)
    800048b8:	f022                	sd	s0,32(sp)
    800048ba:	ec26                	sd	s1,24(sp)
    800048bc:	e84a                	sd	s2,16(sp)
    800048be:	e44e                	sd	s3,8(sp)
    800048c0:	1800                	addi	s0,sp,48
  int r = 0;

  if(f->readable == 0)
    800048c2:	00854783          	lbu	a5,8(a0)
    800048c6:	c3d5                	beqz	a5,8000496a <fileread+0xb6>
    800048c8:	84aa                	mv	s1,a0
    800048ca:	89ae                	mv	s3,a1
    800048cc:	8932                	mv	s2,a2
    return -1;

  if(f->type == FD_PIPE){
    800048ce:	411c                	lw	a5,0(a0)
    800048d0:	4705                	li	a4,1
    800048d2:	04e78963          	beq	a5,a4,80004924 <fileread+0x70>
    r = piperead(f->pipe, addr, n);
  } else if(f->type == FD_DEVICE){
    800048d6:	470d                	li	a4,3
    800048d8:	04e78d63          	beq	a5,a4,80004932 <fileread+0x7e>
    if(f->major < 0 || f->major >= NDEV || !devsw[f->major].read)
      return -1;
    r = devsw[f->major].read(1, addr, n);
  } else if(f->type == FD_INODE){
    800048dc:	4709                	li	a4,2
    800048de:	06e79e63          	bne	a5,a4,8000495a <fileread+0xa6>
    ilock(f->ip);
    800048e2:	6d08                	ld	a0,24(a0)
    800048e4:	fffff097          	auipc	ra,0xfffff
    800048e8:	002080e7          	jalr	2(ra) # 800038e6 <ilock>
    if((r = readi(f->ip, 1, addr, f->off, n)) > 0)
    800048ec:	874a                	mv	a4,s2
    800048ee:	5094                	lw	a3,32(s1)
    800048f0:	864e                	mv	a2,s3
    800048f2:	4585                	li	a1,1
    800048f4:	6c88                	ld	a0,24(s1)
    800048f6:	fffff097          	auipc	ra,0xfffff
    800048fa:	2a4080e7          	jalr	676(ra) # 80003b9a <readi>
    800048fe:	892a                	mv	s2,a0
    80004900:	00a05563          	blez	a0,8000490a <fileread+0x56>
      f->off += r;
    80004904:	509c                	lw	a5,32(s1)
    80004906:	9fa9                	addw	a5,a5,a0
    80004908:	d09c                	sw	a5,32(s1)
    iunlock(f->ip);
    8000490a:	6c88                	ld	a0,24(s1)
    8000490c:	fffff097          	auipc	ra,0xfffff
    80004910:	09c080e7          	jalr	156(ra) # 800039a8 <iunlock>
  } else {
    panic("fileread");
  }

  return r;
}
    80004914:	854a                	mv	a0,s2
    80004916:	70a2                	ld	ra,40(sp)
    80004918:	7402                	ld	s0,32(sp)
    8000491a:	64e2                	ld	s1,24(sp)
    8000491c:	6942                	ld	s2,16(sp)
    8000491e:	69a2                	ld	s3,8(sp)
    80004920:	6145                	addi	sp,sp,48
    80004922:	8082                	ret
    r = piperead(f->pipe, addr, n);
    80004924:	6908                	ld	a0,16(a0)
    80004926:	00000097          	auipc	ra,0x0
    8000492a:	3c6080e7          	jalr	966(ra) # 80004cec <piperead>
    8000492e:	892a                	mv	s2,a0
    80004930:	b7d5                	j	80004914 <fileread+0x60>
    if(f->major < 0 || f->major >= NDEV || !devsw[f->major].read)
    80004932:	02451783          	lh	a5,36(a0)
    80004936:	03079693          	slli	a3,a5,0x30
    8000493a:	92c1                	srli	a3,a3,0x30
    8000493c:	4725                	li	a4,9
    8000493e:	02d76863          	bltu	a4,a3,8000496e <fileread+0xba>
    80004942:	0792                	slli	a5,a5,0x4
    80004944:	0001c717          	auipc	a4,0x1c
    80004948:	4ac70713          	addi	a4,a4,1196 # 80020df0 <devsw>
    8000494c:	97ba                	add	a5,a5,a4
    8000494e:	639c                	ld	a5,0(a5)
    80004950:	c38d                	beqz	a5,80004972 <fileread+0xbe>
    r = devsw[f->major].read(1, addr, n);
    80004952:	4505                	li	a0,1
    80004954:	9782                	jalr	a5
    80004956:	892a                	mv	s2,a0
    80004958:	bf75                	j	80004914 <fileread+0x60>
    panic("fileread");
    8000495a:	00004517          	auipc	a0,0x4
    8000495e:	d5650513          	addi	a0,a0,-682 # 800086b0 <syscalls+0x260>
    80004962:	ffffc097          	auipc	ra,0xffffc
    80004966:	bde080e7          	jalr	-1058(ra) # 80000540 <panic>
    return -1;
    8000496a:	597d                	li	s2,-1
    8000496c:	b765                	j	80004914 <fileread+0x60>
      return -1;
    8000496e:	597d                	li	s2,-1
    80004970:	b755                	j	80004914 <fileread+0x60>
    80004972:	597d                	li	s2,-1
    80004974:	b745                	j	80004914 <fileread+0x60>

0000000080004976 <filewrite>:

// Write to file f.
// addr is a user virtual address.
int
filewrite(struct file *f, uint64 addr, int n)
{
    80004976:	715d                	addi	sp,sp,-80
    80004978:	e486                	sd	ra,72(sp)
    8000497a:	e0a2                	sd	s0,64(sp)
    8000497c:	fc26                	sd	s1,56(sp)
    8000497e:	f84a                	sd	s2,48(sp)
    80004980:	f44e                	sd	s3,40(sp)
    80004982:	f052                	sd	s4,32(sp)
    80004984:	ec56                	sd	s5,24(sp)
    80004986:	e85a                	sd	s6,16(sp)
    80004988:	e45e                	sd	s7,8(sp)
    8000498a:	e062                	sd	s8,0(sp)
    8000498c:	0880                	addi	s0,sp,80
  int r, ret = 0;

  if(f->writable == 0)
    8000498e:	00954783          	lbu	a5,9(a0)
    80004992:	10078663          	beqz	a5,80004a9e <filewrite+0x128>
    80004996:	892a                	mv	s2,a0
    80004998:	8b2e                	mv	s6,a1
    8000499a:	8a32                	mv	s4,a2
    return -1;

  if(f->type == FD_PIPE){
    8000499c:	411c                	lw	a5,0(a0)
    8000499e:	4705                	li	a4,1
    800049a0:	02e78263          	beq	a5,a4,800049c4 <filewrite+0x4e>
    ret = pipewrite(f->pipe, addr, n);
  } else if(f->type == FD_DEVICE){
    800049a4:	470d                	li	a4,3
    800049a6:	02e78663          	beq	a5,a4,800049d2 <filewrite+0x5c>
    if(f->major < 0 || f->major >= NDEV || !devsw[f->major].write)
      return -1;
    ret = devsw[f->major].write(1, addr, n);
  } else if(f->type == FD_INODE){
    800049aa:	4709                	li	a4,2
    800049ac:	0ee79163          	bne	a5,a4,80004a8e <filewrite+0x118>
    // and 2 blocks of slop for non-aligned writes.
    // this really belongs lower down, since writei()
    // might be writing a device like the console.
    int max = ((MAXOPBLOCKS-1-1-2) / 2) * BSIZE;
    int i = 0;
    while(i < n){
    800049b0:	0ac05d63          	blez	a2,80004a6a <filewrite+0xf4>
    int i = 0;
    800049b4:	4981                	li	s3,0
    800049b6:	6b85                	lui	s7,0x1
    800049b8:	c00b8b93          	addi	s7,s7,-1024 # c00 <_entry-0x7ffff400>
    800049bc:	6c05                	lui	s8,0x1
    800049be:	c00c0c1b          	addiw	s8,s8,-1024 # c00 <_entry-0x7ffff400>
    800049c2:	a861                	j	80004a5a <filewrite+0xe4>
    ret = pipewrite(f->pipe, addr, n);
    800049c4:	6908                	ld	a0,16(a0)
    800049c6:	00000097          	auipc	ra,0x0
    800049ca:	22e080e7          	jalr	558(ra) # 80004bf4 <pipewrite>
    800049ce:	8a2a                	mv	s4,a0
    800049d0:	a045                	j	80004a70 <filewrite+0xfa>
    if(f->major < 0 || f->major >= NDEV || !devsw[f->major].write)
    800049d2:	02451783          	lh	a5,36(a0)
    800049d6:	03079693          	slli	a3,a5,0x30
    800049da:	92c1                	srli	a3,a3,0x30
    800049dc:	4725                	li	a4,9
    800049de:	0cd76263          	bltu	a4,a3,80004aa2 <filewrite+0x12c>
    800049e2:	0792                	slli	a5,a5,0x4
    800049e4:	0001c717          	auipc	a4,0x1c
    800049e8:	40c70713          	addi	a4,a4,1036 # 80020df0 <devsw>
    800049ec:	97ba                	add	a5,a5,a4
    800049ee:	679c                	ld	a5,8(a5)
    800049f0:	cbdd                	beqz	a5,80004aa6 <filewrite+0x130>
    ret = devsw[f->major].write(1, addr, n);
    800049f2:	4505                	li	a0,1
    800049f4:	9782                	jalr	a5
    800049f6:	8a2a                	mv	s4,a0
    800049f8:	a8a5                	j	80004a70 <filewrite+0xfa>
    800049fa:	00048a9b          	sext.w	s5,s1
      int n1 = n - i;
      if(n1 > max)
        n1 = max;

      begin_op();
    800049fe:	00000097          	auipc	ra,0x0
    80004a02:	8b4080e7          	jalr	-1868(ra) # 800042b2 <begin_op>
      ilock(f->ip);
    80004a06:	01893503          	ld	a0,24(s2)
    80004a0a:	fffff097          	auipc	ra,0xfffff
    80004a0e:	edc080e7          	jalr	-292(ra) # 800038e6 <ilock>
      if ((r = writei(f->ip, 1, addr + i, f->off, n1)) > 0)
    80004a12:	8756                	mv	a4,s5
    80004a14:	02092683          	lw	a3,32(s2)
    80004a18:	01698633          	add	a2,s3,s6
    80004a1c:	4585                	li	a1,1
    80004a1e:	01893503          	ld	a0,24(s2)
    80004a22:	fffff097          	auipc	ra,0xfffff
    80004a26:	270080e7          	jalr	624(ra) # 80003c92 <writei>
    80004a2a:	84aa                	mv	s1,a0
    80004a2c:	00a05763          	blez	a0,80004a3a <filewrite+0xc4>
        f->off += r;
    80004a30:	02092783          	lw	a5,32(s2)
    80004a34:	9fa9                	addw	a5,a5,a0
    80004a36:	02f92023          	sw	a5,32(s2)
      iunlock(f->ip);
    80004a3a:	01893503          	ld	a0,24(s2)
    80004a3e:	fffff097          	auipc	ra,0xfffff
    80004a42:	f6a080e7          	jalr	-150(ra) # 800039a8 <iunlock>
      end_op();
    80004a46:	00000097          	auipc	ra,0x0
    80004a4a:	8ea080e7          	jalr	-1814(ra) # 80004330 <end_op>

      if(r != n1){
    80004a4e:	009a9f63          	bne	s5,s1,80004a6c <filewrite+0xf6>
        // error from writei
        break;
      }
      i += r;
    80004a52:	013489bb          	addw	s3,s1,s3
    while(i < n){
    80004a56:	0149db63          	bge	s3,s4,80004a6c <filewrite+0xf6>
      int n1 = n - i;
    80004a5a:	413a04bb          	subw	s1,s4,s3
    80004a5e:	0004879b          	sext.w	a5,s1
    80004a62:	f8fbdce3          	bge	s7,a5,800049fa <filewrite+0x84>
    80004a66:	84e2                	mv	s1,s8
    80004a68:	bf49                	j	800049fa <filewrite+0x84>
    int i = 0;
    80004a6a:	4981                	li	s3,0
    }
    ret = (i == n ? n : -1);
    80004a6c:	013a1f63          	bne	s4,s3,80004a8a <filewrite+0x114>
  } else {
    panic("filewrite");
  }

  return ret;
}
    80004a70:	8552                	mv	a0,s4
    80004a72:	60a6                	ld	ra,72(sp)
    80004a74:	6406                	ld	s0,64(sp)
    80004a76:	74e2                	ld	s1,56(sp)
    80004a78:	7942                	ld	s2,48(sp)
    80004a7a:	79a2                	ld	s3,40(sp)
    80004a7c:	7a02                	ld	s4,32(sp)
    80004a7e:	6ae2                	ld	s5,24(sp)
    80004a80:	6b42                	ld	s6,16(sp)
    80004a82:	6ba2                	ld	s7,8(sp)
    80004a84:	6c02                	ld	s8,0(sp)
    80004a86:	6161                	addi	sp,sp,80
    80004a88:	8082                	ret
    ret = (i == n ? n : -1);
    80004a8a:	5a7d                	li	s4,-1
    80004a8c:	b7d5                	j	80004a70 <filewrite+0xfa>
    panic("filewrite");
    80004a8e:	00004517          	auipc	a0,0x4
    80004a92:	c3250513          	addi	a0,a0,-974 # 800086c0 <syscalls+0x270>
    80004a96:	ffffc097          	auipc	ra,0xffffc
    80004a9a:	aaa080e7          	jalr	-1366(ra) # 80000540 <panic>
    return -1;
    80004a9e:	5a7d                	li	s4,-1
    80004aa0:	bfc1                	j	80004a70 <filewrite+0xfa>
      return -1;
    80004aa2:	5a7d                	li	s4,-1
    80004aa4:	b7f1                	j	80004a70 <filewrite+0xfa>
    80004aa6:	5a7d                	li	s4,-1
    80004aa8:	b7e1                	j	80004a70 <filewrite+0xfa>

0000000080004aaa <pipealloc>:
  int writeopen;  // write fd is still open
};

int
pipealloc(struct file **f0, struct file **f1)
{
    80004aaa:	7179                	addi	sp,sp,-48
    80004aac:	f406                	sd	ra,40(sp)
    80004aae:	f022                	sd	s0,32(sp)
    80004ab0:	ec26                	sd	s1,24(sp)
    80004ab2:	e84a                	sd	s2,16(sp)
    80004ab4:	e44e                	sd	s3,8(sp)
    80004ab6:	e052                	sd	s4,0(sp)
    80004ab8:	1800                	addi	s0,sp,48
    80004aba:	84aa                	mv	s1,a0
    80004abc:	8a2e                	mv	s4,a1
  struct pipe *pi;

  pi = 0;
  *f0 = *f1 = 0;
    80004abe:	0005b023          	sd	zero,0(a1)
    80004ac2:	00053023          	sd	zero,0(a0)
  if((*f0 = filealloc()) == 0 || (*f1 = filealloc()) == 0)
    80004ac6:	00000097          	auipc	ra,0x0
    80004aca:	bf8080e7          	jalr	-1032(ra) # 800046be <filealloc>
    80004ace:	e088                	sd	a0,0(s1)
    80004ad0:	c551                	beqz	a0,80004b5c <pipealloc+0xb2>
    80004ad2:	00000097          	auipc	ra,0x0
    80004ad6:	bec080e7          	jalr	-1044(ra) # 800046be <filealloc>
    80004ada:	00aa3023          	sd	a0,0(s4)
    80004ade:	c92d                	beqz	a0,80004b50 <pipealloc+0xa6>
    goto bad;
  if((pi = (struct pipe*)kalloc()) == 0)
    80004ae0:	ffffc097          	auipc	ra,0xffffc
    80004ae4:	006080e7          	jalr	6(ra) # 80000ae6 <kalloc>
    80004ae8:	892a                	mv	s2,a0
    80004aea:	c125                	beqz	a0,80004b4a <pipealloc+0xa0>
    goto bad;
  pi->readopen = 1;
    80004aec:	4985                	li	s3,1
    80004aee:	23352023          	sw	s3,544(a0)
  pi->writeopen = 1;
    80004af2:	23352223          	sw	s3,548(a0)
  pi->nwrite = 0;
    80004af6:	20052e23          	sw	zero,540(a0)
  pi->nread = 0;
    80004afa:	20052c23          	sw	zero,536(a0)
  initlock(&pi->lock, "pipe");
    80004afe:	00004597          	auipc	a1,0x4
    80004b02:	bd258593          	addi	a1,a1,-1070 # 800086d0 <syscalls+0x280>
    80004b06:	ffffc097          	auipc	ra,0xffffc
    80004b0a:	040080e7          	jalr	64(ra) # 80000b46 <initlock>
  (*f0)->type = FD_PIPE;
    80004b0e:	609c                	ld	a5,0(s1)
    80004b10:	0137a023          	sw	s3,0(a5)
  (*f0)->readable = 1;
    80004b14:	609c                	ld	a5,0(s1)
    80004b16:	01378423          	sb	s3,8(a5)
  (*f0)->writable = 0;
    80004b1a:	609c                	ld	a5,0(s1)
    80004b1c:	000784a3          	sb	zero,9(a5)
  (*f0)->pipe = pi;
    80004b20:	609c                	ld	a5,0(s1)
    80004b22:	0127b823          	sd	s2,16(a5)
  (*f1)->type = FD_PIPE;
    80004b26:	000a3783          	ld	a5,0(s4)
    80004b2a:	0137a023          	sw	s3,0(a5)
  (*f1)->readable = 0;
    80004b2e:	000a3783          	ld	a5,0(s4)
    80004b32:	00078423          	sb	zero,8(a5)
  (*f1)->writable = 1;
    80004b36:	000a3783          	ld	a5,0(s4)
    80004b3a:	013784a3          	sb	s3,9(a5)
  (*f1)->pipe = pi;
    80004b3e:	000a3783          	ld	a5,0(s4)
    80004b42:	0127b823          	sd	s2,16(a5)
  return 0;
    80004b46:	4501                	li	a0,0
    80004b48:	a025                	j	80004b70 <pipealloc+0xc6>

 bad:
  if(pi)
    kfree((char*)pi);
  if(*f0)
    80004b4a:	6088                	ld	a0,0(s1)
    80004b4c:	e501                	bnez	a0,80004b54 <pipealloc+0xaa>
    80004b4e:	a039                	j	80004b5c <pipealloc+0xb2>
    80004b50:	6088                	ld	a0,0(s1)
    80004b52:	c51d                	beqz	a0,80004b80 <pipealloc+0xd6>
    fileclose(*f0);
    80004b54:	00000097          	auipc	ra,0x0
    80004b58:	c26080e7          	jalr	-986(ra) # 8000477a <fileclose>
  if(*f1)
    80004b5c:	000a3783          	ld	a5,0(s4)
    fileclose(*f1);
  return -1;
    80004b60:	557d                	li	a0,-1
  if(*f1)
    80004b62:	c799                	beqz	a5,80004b70 <pipealloc+0xc6>
    fileclose(*f1);
    80004b64:	853e                	mv	a0,a5
    80004b66:	00000097          	auipc	ra,0x0
    80004b6a:	c14080e7          	jalr	-1004(ra) # 8000477a <fileclose>
  return -1;
    80004b6e:	557d                	li	a0,-1
}
    80004b70:	70a2                	ld	ra,40(sp)
    80004b72:	7402                	ld	s0,32(sp)
    80004b74:	64e2                	ld	s1,24(sp)
    80004b76:	6942                	ld	s2,16(sp)
    80004b78:	69a2                	ld	s3,8(sp)
    80004b7a:	6a02                	ld	s4,0(sp)
    80004b7c:	6145                	addi	sp,sp,48
    80004b7e:	8082                	ret
  return -1;
    80004b80:	557d                	li	a0,-1
    80004b82:	b7fd                	j	80004b70 <pipealloc+0xc6>

0000000080004b84 <pipeclose>:

void
pipeclose(struct pipe *pi, int writable)
{
    80004b84:	1101                	addi	sp,sp,-32
    80004b86:	ec06                	sd	ra,24(sp)
    80004b88:	e822                	sd	s0,16(sp)
    80004b8a:	e426                	sd	s1,8(sp)
    80004b8c:	e04a                	sd	s2,0(sp)
    80004b8e:	1000                	addi	s0,sp,32
    80004b90:	84aa                	mv	s1,a0
    80004b92:	892e                	mv	s2,a1
  acquire(&pi->lock);
    80004b94:	ffffc097          	auipc	ra,0xffffc
    80004b98:	042080e7          	jalr	66(ra) # 80000bd6 <acquire>
  if(writable){
    80004b9c:	02090d63          	beqz	s2,80004bd6 <pipeclose+0x52>
    pi->writeopen = 0;
    80004ba0:	2204a223          	sw	zero,548(s1)
    wakeup(&pi->nread);
    80004ba4:	21848513          	addi	a0,s1,536
    80004ba8:	ffffd097          	auipc	ra,0xffffd
    80004bac:	57e080e7          	jalr	1406(ra) # 80002126 <wakeup>
  } else {
    pi->readopen = 0;
    wakeup(&pi->nwrite);
  }
  if(pi->readopen == 0 && pi->writeopen == 0){
    80004bb0:	2204b783          	ld	a5,544(s1)
    80004bb4:	eb95                	bnez	a5,80004be8 <pipeclose+0x64>
    release(&pi->lock);
    80004bb6:	8526                	mv	a0,s1
    80004bb8:	ffffc097          	auipc	ra,0xffffc
    80004bbc:	0d2080e7          	jalr	210(ra) # 80000c8a <release>
    kfree((char*)pi);
    80004bc0:	8526                	mv	a0,s1
    80004bc2:	ffffc097          	auipc	ra,0xffffc
    80004bc6:	e26080e7          	jalr	-474(ra) # 800009e8 <kfree>
  } else
    release(&pi->lock);
}
    80004bca:	60e2                	ld	ra,24(sp)
    80004bcc:	6442                	ld	s0,16(sp)
    80004bce:	64a2                	ld	s1,8(sp)
    80004bd0:	6902                	ld	s2,0(sp)
    80004bd2:	6105                	addi	sp,sp,32
    80004bd4:	8082                	ret
    pi->readopen = 0;
    80004bd6:	2204a023          	sw	zero,544(s1)
    wakeup(&pi->nwrite);
    80004bda:	21c48513          	addi	a0,s1,540
    80004bde:	ffffd097          	auipc	ra,0xffffd
    80004be2:	548080e7          	jalr	1352(ra) # 80002126 <wakeup>
    80004be6:	b7e9                	j	80004bb0 <pipeclose+0x2c>
    release(&pi->lock);
    80004be8:	8526                	mv	a0,s1
    80004bea:	ffffc097          	auipc	ra,0xffffc
    80004bee:	0a0080e7          	jalr	160(ra) # 80000c8a <release>
}
    80004bf2:	bfe1                	j	80004bca <pipeclose+0x46>

0000000080004bf4 <pipewrite>:

int
pipewrite(struct pipe *pi, uint64 addr, int n)
{
    80004bf4:	711d                	addi	sp,sp,-96
    80004bf6:	ec86                	sd	ra,88(sp)
    80004bf8:	e8a2                	sd	s0,80(sp)
    80004bfa:	e4a6                	sd	s1,72(sp)
    80004bfc:	e0ca                	sd	s2,64(sp)
    80004bfe:	fc4e                	sd	s3,56(sp)
    80004c00:	f852                	sd	s4,48(sp)
    80004c02:	f456                	sd	s5,40(sp)
    80004c04:	f05a                	sd	s6,32(sp)
    80004c06:	ec5e                	sd	s7,24(sp)
    80004c08:	e862                	sd	s8,16(sp)
    80004c0a:	1080                	addi	s0,sp,96
    80004c0c:	84aa                	mv	s1,a0
    80004c0e:	8aae                	mv	s5,a1
    80004c10:	8a32                	mv	s4,a2
  int i = 0;
  struct proc *pr = myproc();
    80004c12:	ffffd097          	auipc	ra,0xffffd
    80004c16:	d9a080e7          	jalr	-614(ra) # 800019ac <myproc>
    80004c1a:	89aa                	mv	s3,a0

  acquire(&pi->lock);
    80004c1c:	8526                	mv	a0,s1
    80004c1e:	ffffc097          	auipc	ra,0xffffc
    80004c22:	fb8080e7          	jalr	-72(ra) # 80000bd6 <acquire>
  while(i < n){
    80004c26:	0b405663          	blez	s4,80004cd2 <pipewrite+0xde>
  int i = 0;
    80004c2a:	4901                	li	s2,0
    if(pi->nwrite == pi->nread + PIPESIZE){ //DOC: pipewrite-full
      wakeup(&pi->nread);
      sleep(&pi->nwrite, &pi->lock);
    } else {
      char ch;
      if(copyin(pr->pagetable, &ch, addr + i, 1) == -1)
    80004c2c:	5b7d                	li	s6,-1
      wakeup(&pi->nread);
    80004c2e:	21848c13          	addi	s8,s1,536
      sleep(&pi->nwrite, &pi->lock);
    80004c32:	21c48b93          	addi	s7,s1,540
    80004c36:	a089                	j	80004c78 <pipewrite+0x84>
      release(&pi->lock);
    80004c38:	8526                	mv	a0,s1
    80004c3a:	ffffc097          	auipc	ra,0xffffc
    80004c3e:	050080e7          	jalr	80(ra) # 80000c8a <release>
      return -1;
    80004c42:	597d                	li	s2,-1
  }
  wakeup(&pi->nread);
  release(&pi->lock);

  return i;
}
    80004c44:	854a                	mv	a0,s2
    80004c46:	60e6                	ld	ra,88(sp)
    80004c48:	6446                	ld	s0,80(sp)
    80004c4a:	64a6                	ld	s1,72(sp)
    80004c4c:	6906                	ld	s2,64(sp)
    80004c4e:	79e2                	ld	s3,56(sp)
    80004c50:	7a42                	ld	s4,48(sp)
    80004c52:	7aa2                	ld	s5,40(sp)
    80004c54:	7b02                	ld	s6,32(sp)
    80004c56:	6be2                	ld	s7,24(sp)
    80004c58:	6c42                	ld	s8,16(sp)
    80004c5a:	6125                	addi	sp,sp,96
    80004c5c:	8082                	ret
      wakeup(&pi->nread);
    80004c5e:	8562                	mv	a0,s8
    80004c60:	ffffd097          	auipc	ra,0xffffd
    80004c64:	4c6080e7          	jalr	1222(ra) # 80002126 <wakeup>
      sleep(&pi->nwrite, &pi->lock);
    80004c68:	85a6                	mv	a1,s1
    80004c6a:	855e                	mv	a0,s7
    80004c6c:	ffffd097          	auipc	ra,0xffffd
    80004c70:	456080e7          	jalr	1110(ra) # 800020c2 <sleep>
  while(i < n){
    80004c74:	07495063          	bge	s2,s4,80004cd4 <pipewrite+0xe0>
    if(pi->readopen == 0 || killed(pr)){
    80004c78:	2204a783          	lw	a5,544(s1)
    80004c7c:	dfd5                	beqz	a5,80004c38 <pipewrite+0x44>
    80004c7e:	854e                	mv	a0,s3
    80004c80:	ffffd097          	auipc	ra,0xffffd
    80004c84:	6f2080e7          	jalr	1778(ra) # 80002372 <killed>
    80004c88:	f945                	bnez	a0,80004c38 <pipewrite+0x44>
    if(pi->nwrite == pi->nread + PIPESIZE){ //DOC: pipewrite-full
    80004c8a:	2184a783          	lw	a5,536(s1)
    80004c8e:	21c4a703          	lw	a4,540(s1)
    80004c92:	2007879b          	addiw	a5,a5,512
    80004c96:	fcf704e3          	beq	a4,a5,80004c5e <pipewrite+0x6a>
      if(copyin(pr->pagetable, &ch, addr + i, 1) == -1)
    80004c9a:	4685                	li	a3,1
    80004c9c:	01590633          	add	a2,s2,s5
    80004ca0:	faf40593          	addi	a1,s0,-81
    80004ca4:	0509b503          	ld	a0,80(s3)
    80004ca8:	ffffd097          	auipc	ra,0xffffd
    80004cac:	a50080e7          	jalr	-1456(ra) # 800016f8 <copyin>
    80004cb0:	03650263          	beq	a0,s6,80004cd4 <pipewrite+0xe0>
      pi->data[pi->nwrite++ % PIPESIZE] = ch;
    80004cb4:	21c4a783          	lw	a5,540(s1)
    80004cb8:	0017871b          	addiw	a4,a5,1
    80004cbc:	20e4ae23          	sw	a4,540(s1)
    80004cc0:	1ff7f793          	andi	a5,a5,511
    80004cc4:	97a6                	add	a5,a5,s1
    80004cc6:	faf44703          	lbu	a4,-81(s0)
    80004cca:	00e78c23          	sb	a4,24(a5)
      i++;
    80004cce:	2905                	addiw	s2,s2,1
    80004cd0:	b755                	j	80004c74 <pipewrite+0x80>
  int i = 0;
    80004cd2:	4901                	li	s2,0
  wakeup(&pi->nread);
    80004cd4:	21848513          	addi	a0,s1,536
    80004cd8:	ffffd097          	auipc	ra,0xffffd
    80004cdc:	44e080e7          	jalr	1102(ra) # 80002126 <wakeup>
  release(&pi->lock);
    80004ce0:	8526                	mv	a0,s1
    80004ce2:	ffffc097          	auipc	ra,0xffffc
    80004ce6:	fa8080e7          	jalr	-88(ra) # 80000c8a <release>
  return i;
    80004cea:	bfa9                	j	80004c44 <pipewrite+0x50>

0000000080004cec <piperead>:

int
piperead(struct pipe *pi, uint64 addr, int n)
{
    80004cec:	715d                	addi	sp,sp,-80
    80004cee:	e486                	sd	ra,72(sp)
    80004cf0:	e0a2                	sd	s0,64(sp)
    80004cf2:	fc26                	sd	s1,56(sp)
    80004cf4:	f84a                	sd	s2,48(sp)
    80004cf6:	f44e                	sd	s3,40(sp)
    80004cf8:	f052                	sd	s4,32(sp)
    80004cfa:	ec56                	sd	s5,24(sp)
    80004cfc:	e85a                	sd	s6,16(sp)
    80004cfe:	0880                	addi	s0,sp,80
    80004d00:	84aa                	mv	s1,a0
    80004d02:	892e                	mv	s2,a1
    80004d04:	8ab2                	mv	s5,a2
  int i;
  struct proc *pr = myproc();
    80004d06:	ffffd097          	auipc	ra,0xffffd
    80004d0a:	ca6080e7          	jalr	-858(ra) # 800019ac <myproc>
    80004d0e:	8a2a                	mv	s4,a0
  char ch;

  acquire(&pi->lock);
    80004d10:	8526                	mv	a0,s1
    80004d12:	ffffc097          	auipc	ra,0xffffc
    80004d16:	ec4080e7          	jalr	-316(ra) # 80000bd6 <acquire>
  while(pi->nread == pi->nwrite && pi->writeopen){  //DOC: pipe-empty
    80004d1a:	2184a703          	lw	a4,536(s1)
    80004d1e:	21c4a783          	lw	a5,540(s1)
    if(killed(pr)){
      release(&pi->lock);
      return -1;
    }
    sleep(&pi->nread, &pi->lock); //DOC: piperead-sleep
    80004d22:	21848993          	addi	s3,s1,536
  while(pi->nread == pi->nwrite && pi->writeopen){  //DOC: pipe-empty
    80004d26:	02f71763          	bne	a4,a5,80004d54 <piperead+0x68>
    80004d2a:	2244a783          	lw	a5,548(s1)
    80004d2e:	c39d                	beqz	a5,80004d54 <piperead+0x68>
    if(killed(pr)){
    80004d30:	8552                	mv	a0,s4
    80004d32:	ffffd097          	auipc	ra,0xffffd
    80004d36:	640080e7          	jalr	1600(ra) # 80002372 <killed>
    80004d3a:	e949                	bnez	a0,80004dcc <piperead+0xe0>
    sleep(&pi->nread, &pi->lock); //DOC: piperead-sleep
    80004d3c:	85a6                	mv	a1,s1
    80004d3e:	854e                	mv	a0,s3
    80004d40:	ffffd097          	auipc	ra,0xffffd
    80004d44:	382080e7          	jalr	898(ra) # 800020c2 <sleep>
  while(pi->nread == pi->nwrite && pi->writeopen){  //DOC: pipe-empty
    80004d48:	2184a703          	lw	a4,536(s1)
    80004d4c:	21c4a783          	lw	a5,540(s1)
    80004d50:	fcf70de3          	beq	a4,a5,80004d2a <piperead+0x3e>
  }
  for(i = 0; i < n; i++){  //DOC: piperead-copy
    80004d54:	4981                	li	s3,0
    if(pi->nread == pi->nwrite)
      break;
    ch = pi->data[pi->nread++ % PIPESIZE];
    if(copyout(pr->pagetable, addr + i, &ch, 1) == -1)
    80004d56:	5b7d                	li	s6,-1
  for(i = 0; i < n; i++){  //DOC: piperead-copy
    80004d58:	05505463          	blez	s5,80004da0 <piperead+0xb4>
    if(pi->nread == pi->nwrite)
    80004d5c:	2184a783          	lw	a5,536(s1)
    80004d60:	21c4a703          	lw	a4,540(s1)
    80004d64:	02f70e63          	beq	a4,a5,80004da0 <piperead+0xb4>
    ch = pi->data[pi->nread++ % PIPESIZE];
    80004d68:	0017871b          	addiw	a4,a5,1
    80004d6c:	20e4ac23          	sw	a4,536(s1)
    80004d70:	1ff7f793          	andi	a5,a5,511
    80004d74:	97a6                	add	a5,a5,s1
    80004d76:	0187c783          	lbu	a5,24(a5)
    80004d7a:	faf40fa3          	sb	a5,-65(s0)
    if(copyout(pr->pagetable, addr + i, &ch, 1) == -1)
    80004d7e:	4685                	li	a3,1
    80004d80:	fbf40613          	addi	a2,s0,-65
    80004d84:	85ca                	mv	a1,s2
    80004d86:	050a3503          	ld	a0,80(s4)
    80004d8a:	ffffd097          	auipc	ra,0xffffd
    80004d8e:	8e2080e7          	jalr	-1822(ra) # 8000166c <copyout>
    80004d92:	01650763          	beq	a0,s6,80004da0 <piperead+0xb4>
  for(i = 0; i < n; i++){  //DOC: piperead-copy
    80004d96:	2985                	addiw	s3,s3,1
    80004d98:	0905                	addi	s2,s2,1
    80004d9a:	fd3a91e3          	bne	s5,s3,80004d5c <piperead+0x70>
    80004d9e:	89d6                	mv	s3,s5
      break;
  }
  wakeup(&pi->nwrite);  //DOC: piperead-wakeup
    80004da0:	21c48513          	addi	a0,s1,540
    80004da4:	ffffd097          	auipc	ra,0xffffd
    80004da8:	382080e7          	jalr	898(ra) # 80002126 <wakeup>
  release(&pi->lock);
    80004dac:	8526                	mv	a0,s1
    80004dae:	ffffc097          	auipc	ra,0xffffc
    80004db2:	edc080e7          	jalr	-292(ra) # 80000c8a <release>
  return i;
}
    80004db6:	854e                	mv	a0,s3
    80004db8:	60a6                	ld	ra,72(sp)
    80004dba:	6406                	ld	s0,64(sp)
    80004dbc:	74e2                	ld	s1,56(sp)
    80004dbe:	7942                	ld	s2,48(sp)
    80004dc0:	79a2                	ld	s3,40(sp)
    80004dc2:	7a02                	ld	s4,32(sp)
    80004dc4:	6ae2                	ld	s5,24(sp)
    80004dc6:	6b42                	ld	s6,16(sp)
    80004dc8:	6161                	addi	sp,sp,80
    80004dca:	8082                	ret
      release(&pi->lock);
    80004dcc:	8526                	mv	a0,s1
    80004dce:	ffffc097          	auipc	ra,0xffffc
    80004dd2:	ebc080e7          	jalr	-324(ra) # 80000c8a <release>
      return -1;
    80004dd6:	59fd                	li	s3,-1
    80004dd8:	bff9                	j	80004db6 <piperead+0xca>

0000000080004dda <flags2perm>:
#include "elf.h"

static int loadseg(pde_t *, uint64, struct inode *, uint, uint);

int flags2perm(int flags)
{
    80004dda:	1141                	addi	sp,sp,-16
    80004ddc:	e422                	sd	s0,8(sp)
    80004dde:	0800                	addi	s0,sp,16
    80004de0:	87aa                	mv	a5,a0
    int perm = 0;
    if(flags & 0x1)
    80004de2:	8905                	andi	a0,a0,1
    80004de4:	050e                	slli	a0,a0,0x3
      perm = PTE_X;
    if(flags & 0x2)
    80004de6:	8b89                	andi	a5,a5,2
    80004de8:	c399                	beqz	a5,80004dee <flags2perm+0x14>
      perm |= PTE_W;
    80004dea:	00456513          	ori	a0,a0,4
    return perm;
}
    80004dee:	6422                	ld	s0,8(sp)
    80004df0:	0141                	addi	sp,sp,16
    80004df2:	8082                	ret

0000000080004df4 <exec>:

int
exec(char *path, char **argv)
{
    80004df4:	de010113          	addi	sp,sp,-544
    80004df8:	20113c23          	sd	ra,536(sp)
    80004dfc:	20813823          	sd	s0,528(sp)
    80004e00:	20913423          	sd	s1,520(sp)
    80004e04:	21213023          	sd	s2,512(sp)
    80004e08:	ffce                	sd	s3,504(sp)
    80004e0a:	fbd2                	sd	s4,496(sp)
    80004e0c:	f7d6                	sd	s5,488(sp)
    80004e0e:	f3da                	sd	s6,480(sp)
    80004e10:	efde                	sd	s7,472(sp)
    80004e12:	ebe2                	sd	s8,464(sp)
    80004e14:	e7e6                	sd	s9,456(sp)
    80004e16:	e3ea                	sd	s10,448(sp)
    80004e18:	ff6e                	sd	s11,440(sp)
    80004e1a:	1400                	addi	s0,sp,544
    80004e1c:	892a                	mv	s2,a0
    80004e1e:	dea43423          	sd	a0,-536(s0)
    80004e22:	deb43823          	sd	a1,-528(s0)
  uint64 argc, sz = 0, sp, ustack[MAXARG], stackbase;
  struct elfhdr elf;
  struct inode *ip;
  struct proghdr ph;
  pagetable_t pagetable = 0, oldpagetable;
  struct proc *p = myproc();
    80004e26:	ffffd097          	auipc	ra,0xffffd
    80004e2a:	b86080e7          	jalr	-1146(ra) # 800019ac <myproc>
    80004e2e:	84aa                	mv	s1,a0

  begin_op();
    80004e30:	fffff097          	auipc	ra,0xfffff
    80004e34:	482080e7          	jalr	1154(ra) # 800042b2 <begin_op>

  if((ip = namei(path)) == 0){
    80004e38:	854a                	mv	a0,s2
    80004e3a:	fffff097          	auipc	ra,0xfffff
    80004e3e:	258080e7          	jalr	600(ra) # 80004092 <namei>
    80004e42:	c93d                	beqz	a0,80004eb8 <exec+0xc4>
    80004e44:	8aaa                	mv	s5,a0
    end_op();
    return -1;
  }
  ilock(ip);
    80004e46:	fffff097          	auipc	ra,0xfffff
    80004e4a:	aa0080e7          	jalr	-1376(ra) # 800038e6 <ilock>

  // Check ELF header
  if(readi(ip, 0, (uint64)&elf, 0, sizeof(elf)) != sizeof(elf))
    80004e4e:	04000713          	li	a4,64
    80004e52:	4681                	li	a3,0
    80004e54:	e5040613          	addi	a2,s0,-432
    80004e58:	4581                	li	a1,0
    80004e5a:	8556                	mv	a0,s5
    80004e5c:	fffff097          	auipc	ra,0xfffff
    80004e60:	d3e080e7          	jalr	-706(ra) # 80003b9a <readi>
    80004e64:	04000793          	li	a5,64
    80004e68:	00f51a63          	bne	a0,a5,80004e7c <exec+0x88>
    goto bad;

  if(elf.magic != ELF_MAGIC)
    80004e6c:	e5042703          	lw	a4,-432(s0)
    80004e70:	464c47b7          	lui	a5,0x464c4
    80004e74:	57f78793          	addi	a5,a5,1407 # 464c457f <_entry-0x39b3ba81>
    80004e78:	04f70663          	beq	a4,a5,80004ec4 <exec+0xd0>

 bad:
  if(pagetable)
    proc_freepagetable(pagetable, sz);
  if(ip){
    iunlockput(ip);
    80004e7c:	8556                	mv	a0,s5
    80004e7e:	fffff097          	auipc	ra,0xfffff
    80004e82:	cca080e7          	jalr	-822(ra) # 80003b48 <iunlockput>
    end_op();
    80004e86:	fffff097          	auipc	ra,0xfffff
    80004e8a:	4aa080e7          	jalr	1194(ra) # 80004330 <end_op>
  }
  return -1;
    80004e8e:	557d                	li	a0,-1
}
    80004e90:	21813083          	ld	ra,536(sp)
    80004e94:	21013403          	ld	s0,528(sp)
    80004e98:	20813483          	ld	s1,520(sp)
    80004e9c:	20013903          	ld	s2,512(sp)
    80004ea0:	79fe                	ld	s3,504(sp)
    80004ea2:	7a5e                	ld	s4,496(sp)
    80004ea4:	7abe                	ld	s5,488(sp)
    80004ea6:	7b1e                	ld	s6,480(sp)
    80004ea8:	6bfe                	ld	s7,472(sp)
    80004eaa:	6c5e                	ld	s8,464(sp)
    80004eac:	6cbe                	ld	s9,456(sp)
    80004eae:	6d1e                	ld	s10,448(sp)
    80004eb0:	7dfa                	ld	s11,440(sp)
    80004eb2:	22010113          	addi	sp,sp,544
    80004eb6:	8082                	ret
    end_op();
    80004eb8:	fffff097          	auipc	ra,0xfffff
    80004ebc:	478080e7          	jalr	1144(ra) # 80004330 <end_op>
    return -1;
    80004ec0:	557d                	li	a0,-1
    80004ec2:	b7f9                	j	80004e90 <exec+0x9c>
  if((pagetable = proc_pagetable(p)) == 0)
    80004ec4:	8526                	mv	a0,s1
    80004ec6:	ffffd097          	auipc	ra,0xffffd
    80004eca:	bf0080e7          	jalr	-1040(ra) # 80001ab6 <proc_pagetable>
    80004ece:	8b2a                	mv	s6,a0
    80004ed0:	d555                	beqz	a0,80004e7c <exec+0x88>
  for(i=0, off=elf.phoff; i<elf.phnum; i++, off+=sizeof(ph)){
    80004ed2:	e7042783          	lw	a5,-400(s0)
    80004ed6:	e8845703          	lhu	a4,-376(s0)
    80004eda:	c735                	beqz	a4,80004f46 <exec+0x152>
  uint64 argc, sz = 0, sp, ustack[MAXARG], stackbase;
    80004edc:	4901                	li	s2,0
  for(i=0, off=elf.phoff; i<elf.phnum; i++, off+=sizeof(ph)){
    80004ede:	e0043423          	sd	zero,-504(s0)
    if(ph.vaddr % PGSIZE != 0)
    80004ee2:	6a05                	lui	s4,0x1
    80004ee4:	fffa0713          	addi	a4,s4,-1 # fff <_entry-0x7ffff001>
    80004ee8:	dee43023          	sd	a4,-544(s0)
loadseg(pagetable_t pagetable, uint64 va, struct inode *ip, uint offset, uint sz)
{
  uint i, n;
  uint64 pa;

  for(i = 0; i < sz; i += PGSIZE){
    80004eec:	6d85                	lui	s11,0x1
    80004eee:	7d7d                	lui	s10,0xfffff
    80004ef0:	ac3d                	j	8000512e <exec+0x33a>
    pa = walkaddr(pagetable, va + i);
    if(pa == 0)
      panic("loadseg: address should exist");
    80004ef2:	00003517          	auipc	a0,0x3
    80004ef6:	7e650513          	addi	a0,a0,2022 # 800086d8 <syscalls+0x288>
    80004efa:	ffffb097          	auipc	ra,0xffffb
    80004efe:	646080e7          	jalr	1606(ra) # 80000540 <panic>
    if(sz - i < PGSIZE)
      n = sz - i;
    else
      n = PGSIZE;
    if(readi(ip, 0, (uint64)pa, offset+i, n) != n)
    80004f02:	874a                	mv	a4,s2
    80004f04:	009c86bb          	addw	a3,s9,s1
    80004f08:	4581                	li	a1,0
    80004f0a:	8556                	mv	a0,s5
    80004f0c:	fffff097          	auipc	ra,0xfffff
    80004f10:	c8e080e7          	jalr	-882(ra) # 80003b9a <readi>
    80004f14:	2501                	sext.w	a0,a0
    80004f16:	1aa91963          	bne	s2,a0,800050c8 <exec+0x2d4>
  for(i = 0; i < sz; i += PGSIZE){
    80004f1a:	009d84bb          	addw	s1,s11,s1
    80004f1e:	013d09bb          	addw	s3,s10,s3
    80004f22:	1f74f663          	bgeu	s1,s7,8000510e <exec+0x31a>
    pa = walkaddr(pagetable, va + i);
    80004f26:	02049593          	slli	a1,s1,0x20
    80004f2a:	9181                	srli	a1,a1,0x20
    80004f2c:	95e2                	add	a1,a1,s8
    80004f2e:	855a                	mv	a0,s6
    80004f30:	ffffc097          	auipc	ra,0xffffc
    80004f34:	12c080e7          	jalr	300(ra) # 8000105c <walkaddr>
    80004f38:	862a                	mv	a2,a0
    if(pa == 0)
    80004f3a:	dd45                	beqz	a0,80004ef2 <exec+0xfe>
      n = PGSIZE;
    80004f3c:	8952                	mv	s2,s4
    if(sz - i < PGSIZE)
    80004f3e:	fd49f2e3          	bgeu	s3,s4,80004f02 <exec+0x10e>
      n = sz - i;
    80004f42:	894e                	mv	s2,s3
    80004f44:	bf7d                	j	80004f02 <exec+0x10e>
  uint64 argc, sz = 0, sp, ustack[MAXARG], stackbase;
    80004f46:	4901                	li	s2,0
  iunlockput(ip);
    80004f48:	8556                	mv	a0,s5
    80004f4a:	fffff097          	auipc	ra,0xfffff
    80004f4e:	bfe080e7          	jalr	-1026(ra) # 80003b48 <iunlockput>
  end_op();
    80004f52:	fffff097          	auipc	ra,0xfffff
    80004f56:	3de080e7          	jalr	990(ra) # 80004330 <end_op>
  p = myproc();
    80004f5a:	ffffd097          	auipc	ra,0xffffd
    80004f5e:	a52080e7          	jalr	-1454(ra) # 800019ac <myproc>
    80004f62:	8baa                	mv	s7,a0
  uint64 oldsz = p->sz;
    80004f64:	04853d03          	ld	s10,72(a0)
  sz = PGROUNDUP(sz);
    80004f68:	6785                	lui	a5,0x1
    80004f6a:	17fd                	addi	a5,a5,-1 # fff <_entry-0x7ffff001>
    80004f6c:	97ca                	add	a5,a5,s2
    80004f6e:	777d                	lui	a4,0xfffff
    80004f70:	8ff9                	and	a5,a5,a4
    80004f72:	def43c23          	sd	a5,-520(s0)
  if((sz1 = uvmalloc(pagetable, sz, sz + 2*PGSIZE, PTE_W)) == 0)
    80004f76:	4691                	li	a3,4
    80004f78:	6609                	lui	a2,0x2
    80004f7a:	963e                	add	a2,a2,a5
    80004f7c:	85be                	mv	a1,a5
    80004f7e:	855a                	mv	a0,s6
    80004f80:	ffffc097          	auipc	ra,0xffffc
    80004f84:	490080e7          	jalr	1168(ra) # 80001410 <uvmalloc>
    80004f88:	8c2a                	mv	s8,a0
  ip = 0;
    80004f8a:	4a81                	li	s5,0
  if((sz1 = uvmalloc(pagetable, sz, sz + 2*PGSIZE, PTE_W)) == 0)
    80004f8c:	12050e63          	beqz	a0,800050c8 <exec+0x2d4>
  uvmclear(pagetable, sz-2*PGSIZE);
    80004f90:	75f9                	lui	a1,0xffffe
    80004f92:	95aa                	add	a1,a1,a0
    80004f94:	855a                	mv	a0,s6
    80004f96:	ffffc097          	auipc	ra,0xffffc
    80004f9a:	6a4080e7          	jalr	1700(ra) # 8000163a <uvmclear>
  stackbase = sp - PGSIZE;
    80004f9e:	7afd                	lui	s5,0xfffff
    80004fa0:	9ae2                	add	s5,s5,s8
  for(argc = 0; argv[argc]; argc++) {
    80004fa2:	df043783          	ld	a5,-528(s0)
    80004fa6:	6388                	ld	a0,0(a5)
    80004fa8:	c925                	beqz	a0,80005018 <exec+0x224>
    80004faa:	e9040993          	addi	s3,s0,-368
    80004fae:	f9040c93          	addi	s9,s0,-112
  sp = sz;
    80004fb2:	8962                	mv	s2,s8
  for(argc = 0; argv[argc]; argc++) {
    80004fb4:	4481                	li	s1,0
    sp -= strlen(argv[argc]) + 1;
    80004fb6:	ffffc097          	auipc	ra,0xffffc
    80004fba:	e98080e7          	jalr	-360(ra) # 80000e4e <strlen>
    80004fbe:	0015079b          	addiw	a5,a0,1
    80004fc2:	40f907b3          	sub	a5,s2,a5
    sp -= sp % 16; // riscv sp must be 16-byte aligned
    80004fc6:	ff07f913          	andi	s2,a5,-16
    if(sp < stackbase)
    80004fca:	13596663          	bltu	s2,s5,800050f6 <exec+0x302>
    if(copyout(pagetable, sp, argv[argc], strlen(argv[argc]) + 1) < 0)
    80004fce:	df043d83          	ld	s11,-528(s0)
    80004fd2:	000dba03          	ld	s4,0(s11) # 1000 <_entry-0x7ffff000>
    80004fd6:	8552                	mv	a0,s4
    80004fd8:	ffffc097          	auipc	ra,0xffffc
    80004fdc:	e76080e7          	jalr	-394(ra) # 80000e4e <strlen>
    80004fe0:	0015069b          	addiw	a3,a0,1
    80004fe4:	8652                	mv	a2,s4
    80004fe6:	85ca                	mv	a1,s2
    80004fe8:	855a                	mv	a0,s6
    80004fea:	ffffc097          	auipc	ra,0xffffc
    80004fee:	682080e7          	jalr	1666(ra) # 8000166c <copyout>
    80004ff2:	10054663          	bltz	a0,800050fe <exec+0x30a>
    ustack[argc] = sp;
    80004ff6:	0129b023          	sd	s2,0(s3)
  for(argc = 0; argv[argc]; argc++) {
    80004ffa:	0485                	addi	s1,s1,1
    80004ffc:	008d8793          	addi	a5,s11,8
    80005000:	def43823          	sd	a5,-528(s0)
    80005004:	008db503          	ld	a0,8(s11)
    80005008:	c911                	beqz	a0,8000501c <exec+0x228>
    if(argc >= MAXARG)
    8000500a:	09a1                	addi	s3,s3,8
    8000500c:	fb3c95e3          	bne	s9,s3,80004fb6 <exec+0x1c2>
  sz = sz1;
    80005010:	df843c23          	sd	s8,-520(s0)
  ip = 0;
    80005014:	4a81                	li	s5,0
    80005016:	a84d                	j	800050c8 <exec+0x2d4>
  sp = sz;
    80005018:	8962                	mv	s2,s8
  for(argc = 0; argv[argc]; argc++) {
    8000501a:	4481                	li	s1,0
  ustack[argc] = 0;
    8000501c:	00349793          	slli	a5,s1,0x3
    80005020:	f9078793          	addi	a5,a5,-112
    80005024:	97a2                	add	a5,a5,s0
    80005026:	f007b023          	sd	zero,-256(a5)
  sp -= (argc+1) * sizeof(uint64);
    8000502a:	00148693          	addi	a3,s1,1
    8000502e:	068e                	slli	a3,a3,0x3
    80005030:	40d90933          	sub	s2,s2,a3
  sp -= sp % 16;
    80005034:	ff097913          	andi	s2,s2,-16
  if(sp < stackbase)
    80005038:	01597663          	bgeu	s2,s5,80005044 <exec+0x250>
  sz = sz1;
    8000503c:	df843c23          	sd	s8,-520(s0)
  ip = 0;
    80005040:	4a81                	li	s5,0
    80005042:	a059                	j	800050c8 <exec+0x2d4>
  if(copyout(pagetable, sp, (char *)ustack, (argc+1)*sizeof(uint64)) < 0)
    80005044:	e9040613          	addi	a2,s0,-368
    80005048:	85ca                	mv	a1,s2
    8000504a:	855a                	mv	a0,s6
    8000504c:	ffffc097          	auipc	ra,0xffffc
    80005050:	620080e7          	jalr	1568(ra) # 8000166c <copyout>
    80005054:	0a054963          	bltz	a0,80005106 <exec+0x312>
  p->trapframe->a1 = sp;
    80005058:	058bb783          	ld	a5,88(s7)
    8000505c:	0727bc23          	sd	s2,120(a5)
  for(last=s=path; *s; s++)
    80005060:	de843783          	ld	a5,-536(s0)
    80005064:	0007c703          	lbu	a4,0(a5)
    80005068:	cf11                	beqz	a4,80005084 <exec+0x290>
    8000506a:	0785                	addi	a5,a5,1
    if(*s == '/')
    8000506c:	02f00693          	li	a3,47
    80005070:	a039                	j	8000507e <exec+0x28a>
      last = s+1;
    80005072:	def43423          	sd	a5,-536(s0)
  for(last=s=path; *s; s++)
    80005076:	0785                	addi	a5,a5,1
    80005078:	fff7c703          	lbu	a4,-1(a5)
    8000507c:	c701                	beqz	a4,80005084 <exec+0x290>
    if(*s == '/')
    8000507e:	fed71ce3          	bne	a4,a3,80005076 <exec+0x282>
    80005082:	bfc5                	j	80005072 <exec+0x27e>
  safestrcpy(p->name, last, sizeof(p->name));
    80005084:	4641                	li	a2,16
    80005086:	de843583          	ld	a1,-536(s0)
    8000508a:	158b8513          	addi	a0,s7,344
    8000508e:	ffffc097          	auipc	ra,0xffffc
    80005092:	d8e080e7          	jalr	-626(ra) # 80000e1c <safestrcpy>
  oldpagetable = p->pagetable;
    80005096:	050bb503          	ld	a0,80(s7)
  p->pagetable = pagetable;
    8000509a:	056bb823          	sd	s6,80(s7)
  p->sz = sz;
    8000509e:	058bb423          	sd	s8,72(s7)
  p->trapframe->epc = elf.entry;  // initial program counter = main
    800050a2:	058bb783          	ld	a5,88(s7)
    800050a6:	e6843703          	ld	a4,-408(s0)
    800050aa:	ef98                	sd	a4,24(a5)
  p->trapframe->sp = sp; // initial stack pointer
    800050ac:	058bb783          	ld	a5,88(s7)
    800050b0:	0327b823          	sd	s2,48(a5)
  proc_freepagetable(oldpagetable, oldsz);
    800050b4:	85ea                	mv	a1,s10
    800050b6:	ffffd097          	auipc	ra,0xffffd
    800050ba:	a9c080e7          	jalr	-1380(ra) # 80001b52 <proc_freepagetable>
  return argc; // this ends up in a0, the first argument to main(argc, argv)
    800050be:	0004851b          	sext.w	a0,s1
    800050c2:	b3f9                	j	80004e90 <exec+0x9c>
    800050c4:	df243c23          	sd	s2,-520(s0)
    proc_freepagetable(pagetable, sz);
    800050c8:	df843583          	ld	a1,-520(s0)
    800050cc:	855a                	mv	a0,s6
    800050ce:	ffffd097          	auipc	ra,0xffffd
    800050d2:	a84080e7          	jalr	-1404(ra) # 80001b52 <proc_freepagetable>
  if(ip){
    800050d6:	da0a93e3          	bnez	s5,80004e7c <exec+0x88>
  return -1;
    800050da:	557d                	li	a0,-1
    800050dc:	bb55                	j	80004e90 <exec+0x9c>
    800050de:	df243c23          	sd	s2,-520(s0)
    800050e2:	b7dd                	j	800050c8 <exec+0x2d4>
    800050e4:	df243c23          	sd	s2,-520(s0)
    800050e8:	b7c5                	j	800050c8 <exec+0x2d4>
    800050ea:	df243c23          	sd	s2,-520(s0)
    800050ee:	bfe9                	j	800050c8 <exec+0x2d4>
    800050f0:	df243c23          	sd	s2,-520(s0)
    800050f4:	bfd1                	j	800050c8 <exec+0x2d4>
  sz = sz1;
    800050f6:	df843c23          	sd	s8,-520(s0)
  ip = 0;
    800050fa:	4a81                	li	s5,0
    800050fc:	b7f1                	j	800050c8 <exec+0x2d4>
  sz = sz1;
    800050fe:	df843c23          	sd	s8,-520(s0)
  ip = 0;
    80005102:	4a81                	li	s5,0
    80005104:	b7d1                	j	800050c8 <exec+0x2d4>
  sz = sz1;
    80005106:	df843c23          	sd	s8,-520(s0)
  ip = 0;
    8000510a:	4a81                	li	s5,0
    8000510c:	bf75                	j	800050c8 <exec+0x2d4>
    if((sz1 = uvmalloc(pagetable, sz, ph.vaddr + ph.memsz, flags2perm(ph.flags))) == 0)
    8000510e:	df843903          	ld	s2,-520(s0)
  for(i=0, off=elf.phoff; i<elf.phnum; i++, off+=sizeof(ph)){
    80005112:	e0843783          	ld	a5,-504(s0)
    80005116:	0017869b          	addiw	a3,a5,1
    8000511a:	e0d43423          	sd	a3,-504(s0)
    8000511e:	e0043783          	ld	a5,-512(s0)
    80005122:	0387879b          	addiw	a5,a5,56
    80005126:	e8845703          	lhu	a4,-376(s0)
    8000512a:	e0e6dfe3          	bge	a3,a4,80004f48 <exec+0x154>
    if(readi(ip, 0, (uint64)&ph, off, sizeof(ph)) != sizeof(ph))
    8000512e:	2781                	sext.w	a5,a5
    80005130:	e0f43023          	sd	a5,-512(s0)
    80005134:	03800713          	li	a4,56
    80005138:	86be                	mv	a3,a5
    8000513a:	e1840613          	addi	a2,s0,-488
    8000513e:	4581                	li	a1,0
    80005140:	8556                	mv	a0,s5
    80005142:	fffff097          	auipc	ra,0xfffff
    80005146:	a58080e7          	jalr	-1448(ra) # 80003b9a <readi>
    8000514a:	03800793          	li	a5,56
    8000514e:	f6f51be3          	bne	a0,a5,800050c4 <exec+0x2d0>
    if(ph.type != ELF_PROG_LOAD)
    80005152:	e1842783          	lw	a5,-488(s0)
    80005156:	4705                	li	a4,1
    80005158:	fae79de3          	bne	a5,a4,80005112 <exec+0x31e>
    if(ph.memsz < ph.filesz)
    8000515c:	e4043483          	ld	s1,-448(s0)
    80005160:	e3843783          	ld	a5,-456(s0)
    80005164:	f6f4ede3          	bltu	s1,a5,800050de <exec+0x2ea>
    if(ph.vaddr + ph.memsz < ph.vaddr)
    80005168:	e2843783          	ld	a5,-472(s0)
    8000516c:	94be                	add	s1,s1,a5
    8000516e:	f6f4ebe3          	bltu	s1,a5,800050e4 <exec+0x2f0>
    if(ph.vaddr % PGSIZE != 0)
    80005172:	de043703          	ld	a4,-544(s0)
    80005176:	8ff9                	and	a5,a5,a4
    80005178:	fbad                	bnez	a5,800050ea <exec+0x2f6>
    if((sz1 = uvmalloc(pagetable, sz, ph.vaddr + ph.memsz, flags2perm(ph.flags))) == 0)
    8000517a:	e1c42503          	lw	a0,-484(s0)
    8000517e:	00000097          	auipc	ra,0x0
    80005182:	c5c080e7          	jalr	-932(ra) # 80004dda <flags2perm>
    80005186:	86aa                	mv	a3,a0
    80005188:	8626                	mv	a2,s1
    8000518a:	85ca                	mv	a1,s2
    8000518c:	855a                	mv	a0,s6
    8000518e:	ffffc097          	auipc	ra,0xffffc
    80005192:	282080e7          	jalr	642(ra) # 80001410 <uvmalloc>
    80005196:	dea43c23          	sd	a0,-520(s0)
    8000519a:	d939                	beqz	a0,800050f0 <exec+0x2fc>
    if(loadseg(pagetable, ph.vaddr, ip, ph.off, ph.filesz) < 0)
    8000519c:	e2843c03          	ld	s8,-472(s0)
    800051a0:	e2042c83          	lw	s9,-480(s0)
    800051a4:	e3842b83          	lw	s7,-456(s0)
  for(i = 0; i < sz; i += PGSIZE){
    800051a8:	f60b83e3          	beqz	s7,8000510e <exec+0x31a>
    800051ac:	89de                	mv	s3,s7
    800051ae:	4481                	li	s1,0
    800051b0:	bb9d                	j	80004f26 <exec+0x132>

00000000800051b2 <argfd>:

// Fetch the nth word-sized system call argument as a file descriptor
// and return both the descriptor and the corresponding struct file.
static int
argfd(int n, int *pfd, struct file **pf)
{
    800051b2:	7179                	addi	sp,sp,-48
    800051b4:	f406                	sd	ra,40(sp)
    800051b6:	f022                	sd	s0,32(sp)
    800051b8:	ec26                	sd	s1,24(sp)
    800051ba:	e84a                	sd	s2,16(sp)
    800051bc:	1800                	addi	s0,sp,48
    800051be:	892e                	mv	s2,a1
    800051c0:	84b2                	mv	s1,a2
  int fd;
  struct file *f;

  argint(n, &fd);
    800051c2:	fdc40593          	addi	a1,s0,-36
    800051c6:	ffffe097          	auipc	ra,0xffffe
    800051ca:	b7a080e7          	jalr	-1158(ra) # 80002d40 <argint>
  if(fd < 0 || fd >= NOFILE || (f=myproc()->ofile[fd]) == 0)
    800051ce:	fdc42703          	lw	a4,-36(s0)
    800051d2:	47bd                	li	a5,15
    800051d4:	02e7eb63          	bltu	a5,a4,8000520a <argfd+0x58>
    800051d8:	ffffc097          	auipc	ra,0xffffc
    800051dc:	7d4080e7          	jalr	2004(ra) # 800019ac <myproc>
    800051e0:	fdc42703          	lw	a4,-36(s0)
    800051e4:	01a70793          	addi	a5,a4,26 # fffffffffffff01a <end+0xffffffff7ffdd092>
    800051e8:	078e                	slli	a5,a5,0x3
    800051ea:	953e                	add	a0,a0,a5
    800051ec:	611c                	ld	a5,0(a0)
    800051ee:	c385                	beqz	a5,8000520e <argfd+0x5c>
    return -1;
  if(pfd)
    800051f0:	00090463          	beqz	s2,800051f8 <argfd+0x46>
    *pfd = fd;
    800051f4:	00e92023          	sw	a4,0(s2)
  if(pf)
    *pf = f;
  return 0;
    800051f8:	4501                	li	a0,0
  if(pf)
    800051fa:	c091                	beqz	s1,800051fe <argfd+0x4c>
    *pf = f;
    800051fc:	e09c                	sd	a5,0(s1)
}
    800051fe:	70a2                	ld	ra,40(sp)
    80005200:	7402                	ld	s0,32(sp)
    80005202:	64e2                	ld	s1,24(sp)
    80005204:	6942                	ld	s2,16(sp)
    80005206:	6145                	addi	sp,sp,48
    80005208:	8082                	ret
    return -1;
    8000520a:	557d                	li	a0,-1
    8000520c:	bfcd                	j	800051fe <argfd+0x4c>
    8000520e:	557d                	li	a0,-1
    80005210:	b7fd                	j	800051fe <argfd+0x4c>

0000000080005212 <fdalloc>:

// Allocate a file descriptor for the given file.
// Takes over file reference from caller on success.
static int
fdalloc(struct file *f)
{
    80005212:	1101                	addi	sp,sp,-32
    80005214:	ec06                	sd	ra,24(sp)
    80005216:	e822                	sd	s0,16(sp)
    80005218:	e426                	sd	s1,8(sp)
    8000521a:	1000                	addi	s0,sp,32
    8000521c:	84aa                	mv	s1,a0
  int fd;
  struct proc *p = myproc();
    8000521e:	ffffc097          	auipc	ra,0xffffc
    80005222:	78e080e7          	jalr	1934(ra) # 800019ac <myproc>
    80005226:	862a                	mv	a2,a0

  for(fd = 0; fd < NOFILE; fd++){
    80005228:	0d050793          	addi	a5,a0,208
    8000522c:	4501                	li	a0,0
    8000522e:	46c1                	li	a3,16
    if(p->ofile[fd] == 0){
    80005230:	6398                	ld	a4,0(a5)
    80005232:	cb19                	beqz	a4,80005248 <fdalloc+0x36>
  for(fd = 0; fd < NOFILE; fd++){
    80005234:	2505                	addiw	a0,a0,1
    80005236:	07a1                	addi	a5,a5,8
    80005238:	fed51ce3          	bne	a0,a3,80005230 <fdalloc+0x1e>
      p->ofile[fd] = f;
      return fd;
    }
  }
  return -1;
    8000523c:	557d                	li	a0,-1
}
    8000523e:	60e2                	ld	ra,24(sp)
    80005240:	6442                	ld	s0,16(sp)
    80005242:	64a2                	ld	s1,8(sp)
    80005244:	6105                	addi	sp,sp,32
    80005246:	8082                	ret
      p->ofile[fd] = f;
    80005248:	01a50793          	addi	a5,a0,26
    8000524c:	078e                	slli	a5,a5,0x3
    8000524e:	963e                	add	a2,a2,a5
    80005250:	e204                	sd	s1,0(a2)
      return fd;
    80005252:	b7f5                	j	8000523e <fdalloc+0x2c>

0000000080005254 <create>:
  return -1;
}

static struct inode*
create(char *path, short type, short major, short minor)
{
    80005254:	715d                	addi	sp,sp,-80
    80005256:	e486                	sd	ra,72(sp)
    80005258:	e0a2                	sd	s0,64(sp)
    8000525a:	fc26                	sd	s1,56(sp)
    8000525c:	f84a                	sd	s2,48(sp)
    8000525e:	f44e                	sd	s3,40(sp)
    80005260:	f052                	sd	s4,32(sp)
    80005262:	ec56                	sd	s5,24(sp)
    80005264:	e85a                	sd	s6,16(sp)
    80005266:	0880                	addi	s0,sp,80
    80005268:	8b2e                	mv	s6,a1
    8000526a:	89b2                	mv	s3,a2
    8000526c:	8936                	mv	s2,a3
  struct inode *ip, *dp;
  char name[DIRSIZ];

  if((dp = nameiparent(path, name)) == 0)
    8000526e:	fb040593          	addi	a1,s0,-80
    80005272:	fffff097          	auipc	ra,0xfffff
    80005276:	e3e080e7          	jalr	-450(ra) # 800040b0 <nameiparent>
    8000527a:	84aa                	mv	s1,a0
    8000527c:	14050f63          	beqz	a0,800053da <create+0x186>
    return 0;

  ilock(dp);
    80005280:	ffffe097          	auipc	ra,0xffffe
    80005284:	666080e7          	jalr	1638(ra) # 800038e6 <ilock>

  if((ip = dirlookup(dp, name, 0)) != 0){
    80005288:	4601                	li	a2,0
    8000528a:	fb040593          	addi	a1,s0,-80
    8000528e:	8526                	mv	a0,s1
    80005290:	fffff097          	auipc	ra,0xfffff
    80005294:	b3a080e7          	jalr	-1222(ra) # 80003dca <dirlookup>
    80005298:	8aaa                	mv	s5,a0
    8000529a:	c931                	beqz	a0,800052ee <create+0x9a>
    iunlockput(dp);
    8000529c:	8526                	mv	a0,s1
    8000529e:	fffff097          	auipc	ra,0xfffff
    800052a2:	8aa080e7          	jalr	-1878(ra) # 80003b48 <iunlockput>
    ilock(ip);
    800052a6:	8556                	mv	a0,s5
    800052a8:	ffffe097          	auipc	ra,0xffffe
    800052ac:	63e080e7          	jalr	1598(ra) # 800038e6 <ilock>
    if(type == T_FILE && (ip->type == T_FILE || ip->type == T_DEVICE))
    800052b0:	000b059b          	sext.w	a1,s6
    800052b4:	4789                	li	a5,2
    800052b6:	02f59563          	bne	a1,a5,800052e0 <create+0x8c>
    800052ba:	044ad783          	lhu	a5,68(s5) # fffffffffffff044 <end+0xffffffff7ffdd0bc>
    800052be:	37f9                	addiw	a5,a5,-2
    800052c0:	17c2                	slli	a5,a5,0x30
    800052c2:	93c1                	srli	a5,a5,0x30
    800052c4:	4705                	li	a4,1
    800052c6:	00f76d63          	bltu	a4,a5,800052e0 <create+0x8c>
  ip->nlink = 0;
  iupdate(ip);
  iunlockput(ip);
  iunlockput(dp);
  return 0;
}
    800052ca:	8556                	mv	a0,s5
    800052cc:	60a6                	ld	ra,72(sp)
    800052ce:	6406                	ld	s0,64(sp)
    800052d0:	74e2                	ld	s1,56(sp)
    800052d2:	7942                	ld	s2,48(sp)
    800052d4:	79a2                	ld	s3,40(sp)
    800052d6:	7a02                	ld	s4,32(sp)
    800052d8:	6ae2                	ld	s5,24(sp)
    800052da:	6b42                	ld	s6,16(sp)
    800052dc:	6161                	addi	sp,sp,80
    800052de:	8082                	ret
    iunlockput(ip);
    800052e0:	8556                	mv	a0,s5
    800052e2:	fffff097          	auipc	ra,0xfffff
    800052e6:	866080e7          	jalr	-1946(ra) # 80003b48 <iunlockput>
    return 0;
    800052ea:	4a81                	li	s5,0
    800052ec:	bff9                	j	800052ca <create+0x76>
  if((ip = ialloc(dp->dev, type)) == 0){
    800052ee:	85da                	mv	a1,s6
    800052f0:	4088                	lw	a0,0(s1)
    800052f2:	ffffe097          	auipc	ra,0xffffe
    800052f6:	456080e7          	jalr	1110(ra) # 80003748 <ialloc>
    800052fa:	8a2a                	mv	s4,a0
    800052fc:	c539                	beqz	a0,8000534a <create+0xf6>
  ilock(ip);
    800052fe:	ffffe097          	auipc	ra,0xffffe
    80005302:	5e8080e7          	jalr	1512(ra) # 800038e6 <ilock>
  ip->major = major;
    80005306:	053a1323          	sh	s3,70(s4)
  ip->minor = minor;
    8000530a:	052a1423          	sh	s2,72(s4)
  ip->nlink = 1;
    8000530e:	4905                	li	s2,1
    80005310:	052a1523          	sh	s2,74(s4)
  iupdate(ip);
    80005314:	8552                	mv	a0,s4
    80005316:	ffffe097          	auipc	ra,0xffffe
    8000531a:	504080e7          	jalr	1284(ra) # 8000381a <iupdate>
  if(type == T_DIR){  // Create . and .. entries.
    8000531e:	000b059b          	sext.w	a1,s6
    80005322:	03258b63          	beq	a1,s2,80005358 <create+0x104>
  if(dirlink(dp, name, ip->inum) < 0)
    80005326:	004a2603          	lw	a2,4(s4)
    8000532a:	fb040593          	addi	a1,s0,-80
    8000532e:	8526                	mv	a0,s1
    80005330:	fffff097          	auipc	ra,0xfffff
    80005334:	cb0080e7          	jalr	-848(ra) # 80003fe0 <dirlink>
    80005338:	06054f63          	bltz	a0,800053b6 <create+0x162>
  iunlockput(dp);
    8000533c:	8526                	mv	a0,s1
    8000533e:	fffff097          	auipc	ra,0xfffff
    80005342:	80a080e7          	jalr	-2038(ra) # 80003b48 <iunlockput>
  return ip;
    80005346:	8ad2                	mv	s5,s4
    80005348:	b749                	j	800052ca <create+0x76>
    iunlockput(dp);
    8000534a:	8526                	mv	a0,s1
    8000534c:	ffffe097          	auipc	ra,0xffffe
    80005350:	7fc080e7          	jalr	2044(ra) # 80003b48 <iunlockput>
    return 0;
    80005354:	8ad2                	mv	s5,s4
    80005356:	bf95                	j	800052ca <create+0x76>
    if(dirlink(ip, ".", ip->inum) < 0 || dirlink(ip, "..", dp->inum) < 0)
    80005358:	004a2603          	lw	a2,4(s4)
    8000535c:	00003597          	auipc	a1,0x3
    80005360:	39c58593          	addi	a1,a1,924 # 800086f8 <syscalls+0x2a8>
    80005364:	8552                	mv	a0,s4
    80005366:	fffff097          	auipc	ra,0xfffff
    8000536a:	c7a080e7          	jalr	-902(ra) # 80003fe0 <dirlink>
    8000536e:	04054463          	bltz	a0,800053b6 <create+0x162>
    80005372:	40d0                	lw	a2,4(s1)
    80005374:	00003597          	auipc	a1,0x3
    80005378:	38c58593          	addi	a1,a1,908 # 80008700 <syscalls+0x2b0>
    8000537c:	8552                	mv	a0,s4
    8000537e:	fffff097          	auipc	ra,0xfffff
    80005382:	c62080e7          	jalr	-926(ra) # 80003fe0 <dirlink>
    80005386:	02054863          	bltz	a0,800053b6 <create+0x162>
  if(dirlink(dp, name, ip->inum) < 0)
    8000538a:	004a2603          	lw	a2,4(s4)
    8000538e:	fb040593          	addi	a1,s0,-80
    80005392:	8526                	mv	a0,s1
    80005394:	fffff097          	auipc	ra,0xfffff
    80005398:	c4c080e7          	jalr	-948(ra) # 80003fe0 <dirlink>
    8000539c:	00054d63          	bltz	a0,800053b6 <create+0x162>
    dp->nlink++;  // for ".."
    800053a0:	04a4d783          	lhu	a5,74(s1)
    800053a4:	2785                	addiw	a5,a5,1
    800053a6:	04f49523          	sh	a5,74(s1)
    iupdate(dp);
    800053aa:	8526                	mv	a0,s1
    800053ac:	ffffe097          	auipc	ra,0xffffe
    800053b0:	46e080e7          	jalr	1134(ra) # 8000381a <iupdate>
    800053b4:	b761                	j	8000533c <create+0xe8>
  ip->nlink = 0;
    800053b6:	040a1523          	sh	zero,74(s4)
  iupdate(ip);
    800053ba:	8552                	mv	a0,s4
    800053bc:	ffffe097          	auipc	ra,0xffffe
    800053c0:	45e080e7          	jalr	1118(ra) # 8000381a <iupdate>
  iunlockput(ip);
    800053c4:	8552                	mv	a0,s4
    800053c6:	ffffe097          	auipc	ra,0xffffe
    800053ca:	782080e7          	jalr	1922(ra) # 80003b48 <iunlockput>
  iunlockput(dp);
    800053ce:	8526                	mv	a0,s1
    800053d0:	ffffe097          	auipc	ra,0xffffe
    800053d4:	778080e7          	jalr	1912(ra) # 80003b48 <iunlockput>
  return 0;
    800053d8:	bdcd                	j	800052ca <create+0x76>
    return 0;
    800053da:	8aaa                	mv	s5,a0
    800053dc:	b5fd                	j	800052ca <create+0x76>

00000000800053de <sys_dup>:
{
    800053de:	7179                	addi	sp,sp,-48
    800053e0:	f406                	sd	ra,40(sp)
    800053e2:	f022                	sd	s0,32(sp)
    800053e4:	ec26                	sd	s1,24(sp)
    800053e6:	e84a                	sd	s2,16(sp)
    800053e8:	1800                	addi	s0,sp,48
  if(argfd(0, 0, &f) < 0)
    800053ea:	fd840613          	addi	a2,s0,-40
    800053ee:	4581                	li	a1,0
    800053f0:	4501                	li	a0,0
    800053f2:	00000097          	auipc	ra,0x0
    800053f6:	dc0080e7          	jalr	-576(ra) # 800051b2 <argfd>
    return -1;
    800053fa:	57fd                	li	a5,-1
  if(argfd(0, 0, &f) < 0)
    800053fc:	02054363          	bltz	a0,80005422 <sys_dup+0x44>
  if((fd=fdalloc(f)) < 0)
    80005400:	fd843903          	ld	s2,-40(s0)
    80005404:	854a                	mv	a0,s2
    80005406:	00000097          	auipc	ra,0x0
    8000540a:	e0c080e7          	jalr	-500(ra) # 80005212 <fdalloc>
    8000540e:	84aa                	mv	s1,a0
    return -1;
    80005410:	57fd                	li	a5,-1
  if((fd=fdalloc(f)) < 0)
    80005412:	00054863          	bltz	a0,80005422 <sys_dup+0x44>
  filedup(f);
    80005416:	854a                	mv	a0,s2
    80005418:	fffff097          	auipc	ra,0xfffff
    8000541c:	310080e7          	jalr	784(ra) # 80004728 <filedup>
  return fd;
    80005420:	87a6                	mv	a5,s1
}
    80005422:	853e                	mv	a0,a5
    80005424:	70a2                	ld	ra,40(sp)
    80005426:	7402                	ld	s0,32(sp)
    80005428:	64e2                	ld	s1,24(sp)
    8000542a:	6942                	ld	s2,16(sp)
    8000542c:	6145                	addi	sp,sp,48
    8000542e:	8082                	ret

0000000080005430 <sys_read>:
{
    80005430:	7179                	addi	sp,sp,-48
    80005432:	f406                	sd	ra,40(sp)
    80005434:	f022                	sd	s0,32(sp)
    80005436:	1800                	addi	s0,sp,48
  argaddr(1, &p);
    80005438:	fd840593          	addi	a1,s0,-40
    8000543c:	4505                	li	a0,1
    8000543e:	ffffe097          	auipc	ra,0xffffe
    80005442:	922080e7          	jalr	-1758(ra) # 80002d60 <argaddr>
  argint(2, &n);
    80005446:	fe440593          	addi	a1,s0,-28
    8000544a:	4509                	li	a0,2
    8000544c:	ffffe097          	auipc	ra,0xffffe
    80005450:	8f4080e7          	jalr	-1804(ra) # 80002d40 <argint>
  if(argfd(0, 0, &f) < 0)
    80005454:	fe840613          	addi	a2,s0,-24
    80005458:	4581                	li	a1,0
    8000545a:	4501                	li	a0,0
    8000545c:	00000097          	auipc	ra,0x0
    80005460:	d56080e7          	jalr	-682(ra) # 800051b2 <argfd>
    80005464:	87aa                	mv	a5,a0
    return -1;
    80005466:	557d                	li	a0,-1
  if(argfd(0, 0, &f) < 0)
    80005468:	0007cc63          	bltz	a5,80005480 <sys_read+0x50>
  return fileread(f, p, n);
    8000546c:	fe442603          	lw	a2,-28(s0)
    80005470:	fd843583          	ld	a1,-40(s0)
    80005474:	fe843503          	ld	a0,-24(s0)
    80005478:	fffff097          	auipc	ra,0xfffff
    8000547c:	43c080e7          	jalr	1084(ra) # 800048b4 <fileread>
}
    80005480:	70a2                	ld	ra,40(sp)
    80005482:	7402                	ld	s0,32(sp)
    80005484:	6145                	addi	sp,sp,48
    80005486:	8082                	ret

0000000080005488 <sys_write>:
{
    80005488:	7179                	addi	sp,sp,-48
    8000548a:	f406                	sd	ra,40(sp)
    8000548c:	f022                	sd	s0,32(sp)
    8000548e:	1800                	addi	s0,sp,48
  argaddr(1, &p);
    80005490:	fd840593          	addi	a1,s0,-40
    80005494:	4505                	li	a0,1
    80005496:	ffffe097          	auipc	ra,0xffffe
    8000549a:	8ca080e7          	jalr	-1846(ra) # 80002d60 <argaddr>
  argint(2, &n);
    8000549e:	fe440593          	addi	a1,s0,-28
    800054a2:	4509                	li	a0,2
    800054a4:	ffffe097          	auipc	ra,0xffffe
    800054a8:	89c080e7          	jalr	-1892(ra) # 80002d40 <argint>
  if(argfd(0, 0, &f) < 0)
    800054ac:	fe840613          	addi	a2,s0,-24
    800054b0:	4581                	li	a1,0
    800054b2:	4501                	li	a0,0
    800054b4:	00000097          	auipc	ra,0x0
    800054b8:	cfe080e7          	jalr	-770(ra) # 800051b2 <argfd>
    800054bc:	87aa                	mv	a5,a0
    return -1;
    800054be:	557d                	li	a0,-1
  if(argfd(0, 0, &f) < 0)
    800054c0:	0007cc63          	bltz	a5,800054d8 <sys_write+0x50>
  return filewrite(f, p, n);
    800054c4:	fe442603          	lw	a2,-28(s0)
    800054c8:	fd843583          	ld	a1,-40(s0)
    800054cc:	fe843503          	ld	a0,-24(s0)
    800054d0:	fffff097          	auipc	ra,0xfffff
    800054d4:	4a6080e7          	jalr	1190(ra) # 80004976 <filewrite>
}
    800054d8:	70a2                	ld	ra,40(sp)
    800054da:	7402                	ld	s0,32(sp)
    800054dc:	6145                	addi	sp,sp,48
    800054de:	8082                	ret

00000000800054e0 <sys_close>:
{
    800054e0:	1101                	addi	sp,sp,-32
    800054e2:	ec06                	sd	ra,24(sp)
    800054e4:	e822                	sd	s0,16(sp)
    800054e6:	1000                	addi	s0,sp,32
  if(argfd(0, &fd, &f) < 0)
    800054e8:	fe040613          	addi	a2,s0,-32
    800054ec:	fec40593          	addi	a1,s0,-20
    800054f0:	4501                	li	a0,0
    800054f2:	00000097          	auipc	ra,0x0
    800054f6:	cc0080e7          	jalr	-832(ra) # 800051b2 <argfd>
    return -1;
    800054fa:	57fd                	li	a5,-1
  if(argfd(0, &fd, &f) < 0)
    800054fc:	02054463          	bltz	a0,80005524 <sys_close+0x44>
  myproc()->ofile[fd] = 0;
    80005500:	ffffc097          	auipc	ra,0xffffc
    80005504:	4ac080e7          	jalr	1196(ra) # 800019ac <myproc>
    80005508:	fec42783          	lw	a5,-20(s0)
    8000550c:	07e9                	addi	a5,a5,26
    8000550e:	078e                	slli	a5,a5,0x3
    80005510:	953e                	add	a0,a0,a5
    80005512:	00053023          	sd	zero,0(a0)
  fileclose(f);
    80005516:	fe043503          	ld	a0,-32(s0)
    8000551a:	fffff097          	auipc	ra,0xfffff
    8000551e:	260080e7          	jalr	608(ra) # 8000477a <fileclose>
  return 0;
    80005522:	4781                	li	a5,0
}
    80005524:	853e                	mv	a0,a5
    80005526:	60e2                	ld	ra,24(sp)
    80005528:	6442                	ld	s0,16(sp)
    8000552a:	6105                	addi	sp,sp,32
    8000552c:	8082                	ret

000000008000552e <sys_fstat>:
{
    8000552e:	1101                	addi	sp,sp,-32
    80005530:	ec06                	sd	ra,24(sp)
    80005532:	e822                	sd	s0,16(sp)
    80005534:	1000                	addi	s0,sp,32
  argaddr(1, &st);
    80005536:	fe040593          	addi	a1,s0,-32
    8000553a:	4505                	li	a0,1
    8000553c:	ffffe097          	auipc	ra,0xffffe
    80005540:	824080e7          	jalr	-2012(ra) # 80002d60 <argaddr>
  if(argfd(0, 0, &f) < 0)
    80005544:	fe840613          	addi	a2,s0,-24
    80005548:	4581                	li	a1,0
    8000554a:	4501                	li	a0,0
    8000554c:	00000097          	auipc	ra,0x0
    80005550:	c66080e7          	jalr	-922(ra) # 800051b2 <argfd>
    80005554:	87aa                	mv	a5,a0
    return -1;
    80005556:	557d                	li	a0,-1
  if(argfd(0, 0, &f) < 0)
    80005558:	0007ca63          	bltz	a5,8000556c <sys_fstat+0x3e>
  return filestat(f, st);
    8000555c:	fe043583          	ld	a1,-32(s0)
    80005560:	fe843503          	ld	a0,-24(s0)
    80005564:	fffff097          	auipc	ra,0xfffff
    80005568:	2de080e7          	jalr	734(ra) # 80004842 <filestat>
}
    8000556c:	60e2                	ld	ra,24(sp)
    8000556e:	6442                	ld	s0,16(sp)
    80005570:	6105                	addi	sp,sp,32
    80005572:	8082                	ret

0000000080005574 <sys_link>:
{
    80005574:	7169                	addi	sp,sp,-304
    80005576:	f606                	sd	ra,296(sp)
    80005578:	f222                	sd	s0,288(sp)
    8000557a:	ee26                	sd	s1,280(sp)
    8000557c:	ea4a                	sd	s2,272(sp)
    8000557e:	1a00                	addi	s0,sp,304
  if(argstr(0, old, MAXPATH) < 0 || argstr(1, new, MAXPATH) < 0)
    80005580:	08000613          	li	a2,128
    80005584:	ed040593          	addi	a1,s0,-304
    80005588:	4501                	li	a0,0
    8000558a:	ffffd097          	auipc	ra,0xffffd
    8000558e:	7f6080e7          	jalr	2038(ra) # 80002d80 <argstr>
    return -1;
    80005592:	57fd                	li	a5,-1
  if(argstr(0, old, MAXPATH) < 0 || argstr(1, new, MAXPATH) < 0)
    80005594:	10054e63          	bltz	a0,800056b0 <sys_link+0x13c>
    80005598:	08000613          	li	a2,128
    8000559c:	f5040593          	addi	a1,s0,-176
    800055a0:	4505                	li	a0,1
    800055a2:	ffffd097          	auipc	ra,0xffffd
    800055a6:	7de080e7          	jalr	2014(ra) # 80002d80 <argstr>
    return -1;
    800055aa:	57fd                	li	a5,-1
  if(argstr(0, old, MAXPATH) < 0 || argstr(1, new, MAXPATH) < 0)
    800055ac:	10054263          	bltz	a0,800056b0 <sys_link+0x13c>
  begin_op();
    800055b0:	fffff097          	auipc	ra,0xfffff
    800055b4:	d02080e7          	jalr	-766(ra) # 800042b2 <begin_op>
  if((ip = namei(old)) == 0){
    800055b8:	ed040513          	addi	a0,s0,-304
    800055bc:	fffff097          	auipc	ra,0xfffff
    800055c0:	ad6080e7          	jalr	-1322(ra) # 80004092 <namei>
    800055c4:	84aa                	mv	s1,a0
    800055c6:	c551                	beqz	a0,80005652 <sys_link+0xde>
  ilock(ip);
    800055c8:	ffffe097          	auipc	ra,0xffffe
    800055cc:	31e080e7          	jalr	798(ra) # 800038e6 <ilock>
  if(ip->type == T_DIR){
    800055d0:	04449703          	lh	a4,68(s1)
    800055d4:	4785                	li	a5,1
    800055d6:	08f70463          	beq	a4,a5,8000565e <sys_link+0xea>
  ip->nlink++;
    800055da:	04a4d783          	lhu	a5,74(s1)
    800055de:	2785                	addiw	a5,a5,1
    800055e0:	04f49523          	sh	a5,74(s1)
  iupdate(ip);
    800055e4:	8526                	mv	a0,s1
    800055e6:	ffffe097          	auipc	ra,0xffffe
    800055ea:	234080e7          	jalr	564(ra) # 8000381a <iupdate>
  iunlock(ip);
    800055ee:	8526                	mv	a0,s1
    800055f0:	ffffe097          	auipc	ra,0xffffe
    800055f4:	3b8080e7          	jalr	952(ra) # 800039a8 <iunlock>
  if((dp = nameiparent(new, name)) == 0)
    800055f8:	fd040593          	addi	a1,s0,-48
    800055fc:	f5040513          	addi	a0,s0,-176
    80005600:	fffff097          	auipc	ra,0xfffff
    80005604:	ab0080e7          	jalr	-1360(ra) # 800040b0 <nameiparent>
    80005608:	892a                	mv	s2,a0
    8000560a:	c935                	beqz	a0,8000567e <sys_link+0x10a>
  ilock(dp);
    8000560c:	ffffe097          	auipc	ra,0xffffe
    80005610:	2da080e7          	jalr	730(ra) # 800038e6 <ilock>
  if(dp->dev != ip->dev || dirlink(dp, name, ip->inum) < 0){
    80005614:	00092703          	lw	a4,0(s2)
    80005618:	409c                	lw	a5,0(s1)
    8000561a:	04f71d63          	bne	a4,a5,80005674 <sys_link+0x100>
    8000561e:	40d0                	lw	a2,4(s1)
    80005620:	fd040593          	addi	a1,s0,-48
    80005624:	854a                	mv	a0,s2
    80005626:	fffff097          	auipc	ra,0xfffff
    8000562a:	9ba080e7          	jalr	-1606(ra) # 80003fe0 <dirlink>
    8000562e:	04054363          	bltz	a0,80005674 <sys_link+0x100>
  iunlockput(dp);
    80005632:	854a                	mv	a0,s2
    80005634:	ffffe097          	auipc	ra,0xffffe
    80005638:	514080e7          	jalr	1300(ra) # 80003b48 <iunlockput>
  iput(ip);
    8000563c:	8526                	mv	a0,s1
    8000563e:	ffffe097          	auipc	ra,0xffffe
    80005642:	462080e7          	jalr	1122(ra) # 80003aa0 <iput>
  end_op();
    80005646:	fffff097          	auipc	ra,0xfffff
    8000564a:	cea080e7          	jalr	-790(ra) # 80004330 <end_op>
  return 0;
    8000564e:	4781                	li	a5,0
    80005650:	a085                	j	800056b0 <sys_link+0x13c>
    end_op();
    80005652:	fffff097          	auipc	ra,0xfffff
    80005656:	cde080e7          	jalr	-802(ra) # 80004330 <end_op>
    return -1;
    8000565a:	57fd                	li	a5,-1
    8000565c:	a891                	j	800056b0 <sys_link+0x13c>
    iunlockput(ip);
    8000565e:	8526                	mv	a0,s1
    80005660:	ffffe097          	auipc	ra,0xffffe
    80005664:	4e8080e7          	jalr	1256(ra) # 80003b48 <iunlockput>
    end_op();
    80005668:	fffff097          	auipc	ra,0xfffff
    8000566c:	cc8080e7          	jalr	-824(ra) # 80004330 <end_op>
    return -1;
    80005670:	57fd                	li	a5,-1
    80005672:	a83d                	j	800056b0 <sys_link+0x13c>
    iunlockput(dp);
    80005674:	854a                	mv	a0,s2
    80005676:	ffffe097          	auipc	ra,0xffffe
    8000567a:	4d2080e7          	jalr	1234(ra) # 80003b48 <iunlockput>
  ilock(ip);
    8000567e:	8526                	mv	a0,s1
    80005680:	ffffe097          	auipc	ra,0xffffe
    80005684:	266080e7          	jalr	614(ra) # 800038e6 <ilock>
  ip->nlink--;
    80005688:	04a4d783          	lhu	a5,74(s1)
    8000568c:	37fd                	addiw	a5,a5,-1
    8000568e:	04f49523          	sh	a5,74(s1)
  iupdate(ip);
    80005692:	8526                	mv	a0,s1
    80005694:	ffffe097          	auipc	ra,0xffffe
    80005698:	186080e7          	jalr	390(ra) # 8000381a <iupdate>
  iunlockput(ip);
    8000569c:	8526                	mv	a0,s1
    8000569e:	ffffe097          	auipc	ra,0xffffe
    800056a2:	4aa080e7          	jalr	1194(ra) # 80003b48 <iunlockput>
  end_op();
    800056a6:	fffff097          	auipc	ra,0xfffff
    800056aa:	c8a080e7          	jalr	-886(ra) # 80004330 <end_op>
  return -1;
    800056ae:	57fd                	li	a5,-1
}
    800056b0:	853e                	mv	a0,a5
    800056b2:	70b2                	ld	ra,296(sp)
    800056b4:	7412                	ld	s0,288(sp)
    800056b6:	64f2                	ld	s1,280(sp)
    800056b8:	6952                	ld	s2,272(sp)
    800056ba:	6155                	addi	sp,sp,304
    800056bc:	8082                	ret

00000000800056be <sys_unlink>:
{
    800056be:	7151                	addi	sp,sp,-240
    800056c0:	f586                	sd	ra,232(sp)
    800056c2:	f1a2                	sd	s0,224(sp)
    800056c4:	eda6                	sd	s1,216(sp)
    800056c6:	e9ca                	sd	s2,208(sp)
    800056c8:	e5ce                	sd	s3,200(sp)
    800056ca:	1980                	addi	s0,sp,240
  if(argstr(0, path, MAXPATH) < 0)
    800056cc:	08000613          	li	a2,128
    800056d0:	f3040593          	addi	a1,s0,-208
    800056d4:	4501                	li	a0,0
    800056d6:	ffffd097          	auipc	ra,0xffffd
    800056da:	6aa080e7          	jalr	1706(ra) # 80002d80 <argstr>
    800056de:	18054163          	bltz	a0,80005860 <sys_unlink+0x1a2>
  begin_op();
    800056e2:	fffff097          	auipc	ra,0xfffff
    800056e6:	bd0080e7          	jalr	-1072(ra) # 800042b2 <begin_op>
  if((dp = nameiparent(path, name)) == 0){
    800056ea:	fb040593          	addi	a1,s0,-80
    800056ee:	f3040513          	addi	a0,s0,-208
    800056f2:	fffff097          	auipc	ra,0xfffff
    800056f6:	9be080e7          	jalr	-1602(ra) # 800040b0 <nameiparent>
    800056fa:	84aa                	mv	s1,a0
    800056fc:	c979                	beqz	a0,800057d2 <sys_unlink+0x114>
  ilock(dp);
    800056fe:	ffffe097          	auipc	ra,0xffffe
    80005702:	1e8080e7          	jalr	488(ra) # 800038e6 <ilock>
  if(namecmp(name, ".") == 0 || namecmp(name, "..") == 0)
    80005706:	00003597          	auipc	a1,0x3
    8000570a:	ff258593          	addi	a1,a1,-14 # 800086f8 <syscalls+0x2a8>
    8000570e:	fb040513          	addi	a0,s0,-80
    80005712:	ffffe097          	auipc	ra,0xffffe
    80005716:	69e080e7          	jalr	1694(ra) # 80003db0 <namecmp>
    8000571a:	14050a63          	beqz	a0,8000586e <sys_unlink+0x1b0>
    8000571e:	00003597          	auipc	a1,0x3
    80005722:	fe258593          	addi	a1,a1,-30 # 80008700 <syscalls+0x2b0>
    80005726:	fb040513          	addi	a0,s0,-80
    8000572a:	ffffe097          	auipc	ra,0xffffe
    8000572e:	686080e7          	jalr	1670(ra) # 80003db0 <namecmp>
    80005732:	12050e63          	beqz	a0,8000586e <sys_unlink+0x1b0>
  if((ip = dirlookup(dp, name, &off)) == 0)
    80005736:	f2c40613          	addi	a2,s0,-212
    8000573a:	fb040593          	addi	a1,s0,-80
    8000573e:	8526                	mv	a0,s1
    80005740:	ffffe097          	auipc	ra,0xffffe
    80005744:	68a080e7          	jalr	1674(ra) # 80003dca <dirlookup>
    80005748:	892a                	mv	s2,a0
    8000574a:	12050263          	beqz	a0,8000586e <sys_unlink+0x1b0>
  ilock(ip);
    8000574e:	ffffe097          	auipc	ra,0xffffe
    80005752:	198080e7          	jalr	408(ra) # 800038e6 <ilock>
  if(ip->nlink < 1)
    80005756:	04a91783          	lh	a5,74(s2)
    8000575a:	08f05263          	blez	a5,800057de <sys_unlink+0x120>
  if(ip->type == T_DIR && !isdirempty(ip)){
    8000575e:	04491703          	lh	a4,68(s2)
    80005762:	4785                	li	a5,1
    80005764:	08f70563          	beq	a4,a5,800057ee <sys_unlink+0x130>
  memset(&de, 0, sizeof(de));
    80005768:	4641                	li	a2,16
    8000576a:	4581                	li	a1,0
    8000576c:	fc040513          	addi	a0,s0,-64
    80005770:	ffffb097          	auipc	ra,0xffffb
    80005774:	562080e7          	jalr	1378(ra) # 80000cd2 <memset>
  if(writei(dp, 0, (uint64)&de, off, sizeof(de)) != sizeof(de))
    80005778:	4741                	li	a4,16
    8000577a:	f2c42683          	lw	a3,-212(s0)
    8000577e:	fc040613          	addi	a2,s0,-64
    80005782:	4581                	li	a1,0
    80005784:	8526                	mv	a0,s1
    80005786:	ffffe097          	auipc	ra,0xffffe
    8000578a:	50c080e7          	jalr	1292(ra) # 80003c92 <writei>
    8000578e:	47c1                	li	a5,16
    80005790:	0af51563          	bne	a0,a5,8000583a <sys_unlink+0x17c>
  if(ip->type == T_DIR){
    80005794:	04491703          	lh	a4,68(s2)
    80005798:	4785                	li	a5,1
    8000579a:	0af70863          	beq	a4,a5,8000584a <sys_unlink+0x18c>
  iunlockput(dp);
    8000579e:	8526                	mv	a0,s1
    800057a0:	ffffe097          	auipc	ra,0xffffe
    800057a4:	3a8080e7          	jalr	936(ra) # 80003b48 <iunlockput>
  ip->nlink--;
    800057a8:	04a95783          	lhu	a5,74(s2)
    800057ac:	37fd                	addiw	a5,a5,-1
    800057ae:	04f91523          	sh	a5,74(s2)
  iupdate(ip);
    800057b2:	854a                	mv	a0,s2
    800057b4:	ffffe097          	auipc	ra,0xffffe
    800057b8:	066080e7          	jalr	102(ra) # 8000381a <iupdate>
  iunlockput(ip);
    800057bc:	854a                	mv	a0,s2
    800057be:	ffffe097          	auipc	ra,0xffffe
    800057c2:	38a080e7          	jalr	906(ra) # 80003b48 <iunlockput>
  end_op();
    800057c6:	fffff097          	auipc	ra,0xfffff
    800057ca:	b6a080e7          	jalr	-1174(ra) # 80004330 <end_op>
  return 0;
    800057ce:	4501                	li	a0,0
    800057d0:	a84d                	j	80005882 <sys_unlink+0x1c4>
    end_op();
    800057d2:	fffff097          	auipc	ra,0xfffff
    800057d6:	b5e080e7          	jalr	-1186(ra) # 80004330 <end_op>
    return -1;
    800057da:	557d                	li	a0,-1
    800057dc:	a05d                	j	80005882 <sys_unlink+0x1c4>
    panic("unlink: nlink < 1");
    800057de:	00003517          	auipc	a0,0x3
    800057e2:	f2a50513          	addi	a0,a0,-214 # 80008708 <syscalls+0x2b8>
    800057e6:	ffffb097          	auipc	ra,0xffffb
    800057ea:	d5a080e7          	jalr	-678(ra) # 80000540 <panic>
  for(off=2*sizeof(de); off<dp->size; off+=sizeof(de)){
    800057ee:	04c92703          	lw	a4,76(s2)
    800057f2:	02000793          	li	a5,32
    800057f6:	f6e7f9e3          	bgeu	a5,a4,80005768 <sys_unlink+0xaa>
    800057fa:	02000993          	li	s3,32
    if(readi(dp, 0, (uint64)&de, off, sizeof(de)) != sizeof(de))
    800057fe:	4741                	li	a4,16
    80005800:	86ce                	mv	a3,s3
    80005802:	f1840613          	addi	a2,s0,-232
    80005806:	4581                	li	a1,0
    80005808:	854a                	mv	a0,s2
    8000580a:	ffffe097          	auipc	ra,0xffffe
    8000580e:	390080e7          	jalr	912(ra) # 80003b9a <readi>
    80005812:	47c1                	li	a5,16
    80005814:	00f51b63          	bne	a0,a5,8000582a <sys_unlink+0x16c>
    if(de.inum != 0)
    80005818:	f1845783          	lhu	a5,-232(s0)
    8000581c:	e7a1                	bnez	a5,80005864 <sys_unlink+0x1a6>
  for(off=2*sizeof(de); off<dp->size; off+=sizeof(de)){
    8000581e:	29c1                	addiw	s3,s3,16
    80005820:	04c92783          	lw	a5,76(s2)
    80005824:	fcf9ede3          	bltu	s3,a5,800057fe <sys_unlink+0x140>
    80005828:	b781                	j	80005768 <sys_unlink+0xaa>
      panic("isdirempty: readi");
    8000582a:	00003517          	auipc	a0,0x3
    8000582e:	ef650513          	addi	a0,a0,-266 # 80008720 <syscalls+0x2d0>
    80005832:	ffffb097          	auipc	ra,0xffffb
    80005836:	d0e080e7          	jalr	-754(ra) # 80000540 <panic>
    panic("unlink: writei");
    8000583a:	00003517          	auipc	a0,0x3
    8000583e:	efe50513          	addi	a0,a0,-258 # 80008738 <syscalls+0x2e8>
    80005842:	ffffb097          	auipc	ra,0xffffb
    80005846:	cfe080e7          	jalr	-770(ra) # 80000540 <panic>
    dp->nlink--;
    8000584a:	04a4d783          	lhu	a5,74(s1)
    8000584e:	37fd                	addiw	a5,a5,-1
    80005850:	04f49523          	sh	a5,74(s1)
    iupdate(dp);
    80005854:	8526                	mv	a0,s1
    80005856:	ffffe097          	auipc	ra,0xffffe
    8000585a:	fc4080e7          	jalr	-60(ra) # 8000381a <iupdate>
    8000585e:	b781                	j	8000579e <sys_unlink+0xe0>
    return -1;
    80005860:	557d                	li	a0,-1
    80005862:	a005                	j	80005882 <sys_unlink+0x1c4>
    iunlockput(ip);
    80005864:	854a                	mv	a0,s2
    80005866:	ffffe097          	auipc	ra,0xffffe
    8000586a:	2e2080e7          	jalr	738(ra) # 80003b48 <iunlockput>
  iunlockput(dp);
    8000586e:	8526                	mv	a0,s1
    80005870:	ffffe097          	auipc	ra,0xffffe
    80005874:	2d8080e7          	jalr	728(ra) # 80003b48 <iunlockput>
  end_op();
    80005878:	fffff097          	auipc	ra,0xfffff
    8000587c:	ab8080e7          	jalr	-1352(ra) # 80004330 <end_op>
  return -1;
    80005880:	557d                	li	a0,-1
}
    80005882:	70ae                	ld	ra,232(sp)
    80005884:	740e                	ld	s0,224(sp)
    80005886:	64ee                	ld	s1,216(sp)
    80005888:	694e                	ld	s2,208(sp)
    8000588a:	69ae                	ld	s3,200(sp)
    8000588c:	616d                	addi	sp,sp,240
    8000588e:	8082                	ret

0000000080005890 <sys_open>:

uint64
sys_open(void)
{
    80005890:	7131                	addi	sp,sp,-192
    80005892:	fd06                	sd	ra,184(sp)
    80005894:	f922                	sd	s0,176(sp)
    80005896:	f526                	sd	s1,168(sp)
    80005898:	f14a                	sd	s2,160(sp)
    8000589a:	ed4e                	sd	s3,152(sp)
    8000589c:	0180                	addi	s0,sp,192
  int fd, omode;
  struct file *f;
  struct inode *ip;
  int n;

  argint(1, &omode);
    8000589e:	f4c40593          	addi	a1,s0,-180
    800058a2:	4505                	li	a0,1
    800058a4:	ffffd097          	auipc	ra,0xffffd
    800058a8:	49c080e7          	jalr	1180(ra) # 80002d40 <argint>
  if((n = argstr(0, path, MAXPATH)) < 0)
    800058ac:	08000613          	li	a2,128
    800058b0:	f5040593          	addi	a1,s0,-176
    800058b4:	4501                	li	a0,0
    800058b6:	ffffd097          	auipc	ra,0xffffd
    800058ba:	4ca080e7          	jalr	1226(ra) # 80002d80 <argstr>
    800058be:	87aa                	mv	a5,a0
    return -1;
    800058c0:	557d                	li	a0,-1
  if((n = argstr(0, path, MAXPATH)) < 0)
    800058c2:	0a07c963          	bltz	a5,80005974 <sys_open+0xe4>

  begin_op();
    800058c6:	fffff097          	auipc	ra,0xfffff
    800058ca:	9ec080e7          	jalr	-1556(ra) # 800042b2 <begin_op>

  if(omode & O_CREATE){
    800058ce:	f4c42783          	lw	a5,-180(s0)
    800058d2:	2007f793          	andi	a5,a5,512
    800058d6:	cfc5                	beqz	a5,8000598e <sys_open+0xfe>
    ip = create(path, T_FILE, 0, 0);
    800058d8:	4681                	li	a3,0
    800058da:	4601                	li	a2,0
    800058dc:	4589                	li	a1,2
    800058de:	f5040513          	addi	a0,s0,-176
    800058e2:	00000097          	auipc	ra,0x0
    800058e6:	972080e7          	jalr	-1678(ra) # 80005254 <create>
    800058ea:	84aa                	mv	s1,a0
    if(ip == 0){
    800058ec:	c959                	beqz	a0,80005982 <sys_open+0xf2>
      end_op();
      return -1;
    }
  }

  if(ip->type == T_DEVICE && (ip->major < 0 || ip->major >= NDEV)){
    800058ee:	04449703          	lh	a4,68(s1)
    800058f2:	478d                	li	a5,3
    800058f4:	00f71763          	bne	a4,a5,80005902 <sys_open+0x72>
    800058f8:	0464d703          	lhu	a4,70(s1)
    800058fc:	47a5                	li	a5,9
    800058fe:	0ce7ed63          	bltu	a5,a4,800059d8 <sys_open+0x148>
    iunlockput(ip);
    end_op();
    return -1;
  }

  if((f = filealloc()) == 0 || (fd = fdalloc(f)) < 0){
    80005902:	fffff097          	auipc	ra,0xfffff
    80005906:	dbc080e7          	jalr	-580(ra) # 800046be <filealloc>
    8000590a:	89aa                	mv	s3,a0
    8000590c:	10050363          	beqz	a0,80005a12 <sys_open+0x182>
    80005910:	00000097          	auipc	ra,0x0
    80005914:	902080e7          	jalr	-1790(ra) # 80005212 <fdalloc>
    80005918:	892a                	mv	s2,a0
    8000591a:	0e054763          	bltz	a0,80005a08 <sys_open+0x178>
    iunlockput(ip);
    end_op();
    return -1;
  }

  if(ip->type == T_DEVICE){
    8000591e:	04449703          	lh	a4,68(s1)
    80005922:	478d                	li	a5,3
    80005924:	0cf70563          	beq	a4,a5,800059ee <sys_open+0x15e>
    f->type = FD_DEVICE;
    f->major = ip->major;
  } else {
    f->type = FD_INODE;
    80005928:	4789                	li	a5,2
    8000592a:	00f9a023          	sw	a5,0(s3)
    f->off = 0;
    8000592e:	0209a023          	sw	zero,32(s3)
  }
  f->ip = ip;
    80005932:	0099bc23          	sd	s1,24(s3)
  f->readable = !(omode & O_WRONLY);
    80005936:	f4c42783          	lw	a5,-180(s0)
    8000593a:	0017c713          	xori	a4,a5,1
    8000593e:	8b05                	andi	a4,a4,1
    80005940:	00e98423          	sb	a4,8(s3)
  f->writable = (omode & O_WRONLY) || (omode & O_RDWR);
    80005944:	0037f713          	andi	a4,a5,3
    80005948:	00e03733          	snez	a4,a4
    8000594c:	00e984a3          	sb	a4,9(s3)

  if((omode & O_TRUNC) && ip->type == T_FILE){
    80005950:	4007f793          	andi	a5,a5,1024
    80005954:	c791                	beqz	a5,80005960 <sys_open+0xd0>
    80005956:	04449703          	lh	a4,68(s1)
    8000595a:	4789                	li	a5,2
    8000595c:	0af70063          	beq	a4,a5,800059fc <sys_open+0x16c>
    itrunc(ip);
  }

  iunlock(ip);
    80005960:	8526                	mv	a0,s1
    80005962:	ffffe097          	auipc	ra,0xffffe
    80005966:	046080e7          	jalr	70(ra) # 800039a8 <iunlock>
  end_op();
    8000596a:	fffff097          	auipc	ra,0xfffff
    8000596e:	9c6080e7          	jalr	-1594(ra) # 80004330 <end_op>

  return fd;
    80005972:	854a                	mv	a0,s2
}
    80005974:	70ea                	ld	ra,184(sp)
    80005976:	744a                	ld	s0,176(sp)
    80005978:	74aa                	ld	s1,168(sp)
    8000597a:	790a                	ld	s2,160(sp)
    8000597c:	69ea                	ld	s3,152(sp)
    8000597e:	6129                	addi	sp,sp,192
    80005980:	8082                	ret
      end_op();
    80005982:	fffff097          	auipc	ra,0xfffff
    80005986:	9ae080e7          	jalr	-1618(ra) # 80004330 <end_op>
      return -1;
    8000598a:	557d                	li	a0,-1
    8000598c:	b7e5                	j	80005974 <sys_open+0xe4>
    if((ip = namei(path)) == 0){
    8000598e:	f5040513          	addi	a0,s0,-176
    80005992:	ffffe097          	auipc	ra,0xffffe
    80005996:	700080e7          	jalr	1792(ra) # 80004092 <namei>
    8000599a:	84aa                	mv	s1,a0
    8000599c:	c905                	beqz	a0,800059cc <sys_open+0x13c>
    ilock(ip);
    8000599e:	ffffe097          	auipc	ra,0xffffe
    800059a2:	f48080e7          	jalr	-184(ra) # 800038e6 <ilock>
    if(ip->type == T_DIR && omode != O_RDONLY){
    800059a6:	04449703          	lh	a4,68(s1)
    800059aa:	4785                	li	a5,1
    800059ac:	f4f711e3          	bne	a4,a5,800058ee <sys_open+0x5e>
    800059b0:	f4c42783          	lw	a5,-180(s0)
    800059b4:	d7b9                	beqz	a5,80005902 <sys_open+0x72>
      iunlockput(ip);
    800059b6:	8526                	mv	a0,s1
    800059b8:	ffffe097          	auipc	ra,0xffffe
    800059bc:	190080e7          	jalr	400(ra) # 80003b48 <iunlockput>
      end_op();
    800059c0:	fffff097          	auipc	ra,0xfffff
    800059c4:	970080e7          	jalr	-1680(ra) # 80004330 <end_op>
      return -1;
    800059c8:	557d                	li	a0,-1
    800059ca:	b76d                	j	80005974 <sys_open+0xe4>
      end_op();
    800059cc:	fffff097          	auipc	ra,0xfffff
    800059d0:	964080e7          	jalr	-1692(ra) # 80004330 <end_op>
      return -1;
    800059d4:	557d                	li	a0,-1
    800059d6:	bf79                	j	80005974 <sys_open+0xe4>
    iunlockput(ip);
    800059d8:	8526                	mv	a0,s1
    800059da:	ffffe097          	auipc	ra,0xffffe
    800059de:	16e080e7          	jalr	366(ra) # 80003b48 <iunlockput>
    end_op();
    800059e2:	fffff097          	auipc	ra,0xfffff
    800059e6:	94e080e7          	jalr	-1714(ra) # 80004330 <end_op>
    return -1;
    800059ea:	557d                	li	a0,-1
    800059ec:	b761                	j	80005974 <sys_open+0xe4>
    f->type = FD_DEVICE;
    800059ee:	00f9a023          	sw	a5,0(s3)
    f->major = ip->major;
    800059f2:	04649783          	lh	a5,70(s1)
    800059f6:	02f99223          	sh	a5,36(s3)
    800059fa:	bf25                	j	80005932 <sys_open+0xa2>
    itrunc(ip);
    800059fc:	8526                	mv	a0,s1
    800059fe:	ffffe097          	auipc	ra,0xffffe
    80005a02:	ff6080e7          	jalr	-10(ra) # 800039f4 <itrunc>
    80005a06:	bfa9                	j	80005960 <sys_open+0xd0>
      fileclose(f);
    80005a08:	854e                	mv	a0,s3
    80005a0a:	fffff097          	auipc	ra,0xfffff
    80005a0e:	d70080e7          	jalr	-656(ra) # 8000477a <fileclose>
    iunlockput(ip);
    80005a12:	8526                	mv	a0,s1
    80005a14:	ffffe097          	auipc	ra,0xffffe
    80005a18:	134080e7          	jalr	308(ra) # 80003b48 <iunlockput>
    end_op();
    80005a1c:	fffff097          	auipc	ra,0xfffff
    80005a20:	914080e7          	jalr	-1772(ra) # 80004330 <end_op>
    return -1;
    80005a24:	557d                	li	a0,-1
    80005a26:	b7b9                	j	80005974 <sys_open+0xe4>

0000000080005a28 <sys_mkdir>:

uint64
sys_mkdir(void)
{
    80005a28:	7175                	addi	sp,sp,-144
    80005a2a:	e506                	sd	ra,136(sp)
    80005a2c:	e122                	sd	s0,128(sp)
    80005a2e:	0900                	addi	s0,sp,144
  char path[MAXPATH];
  struct inode *ip;

  begin_op();
    80005a30:	fffff097          	auipc	ra,0xfffff
    80005a34:	882080e7          	jalr	-1918(ra) # 800042b2 <begin_op>
  if(argstr(0, path, MAXPATH) < 0 || (ip = create(path, T_DIR, 0, 0)) == 0){
    80005a38:	08000613          	li	a2,128
    80005a3c:	f7040593          	addi	a1,s0,-144
    80005a40:	4501                	li	a0,0
    80005a42:	ffffd097          	auipc	ra,0xffffd
    80005a46:	33e080e7          	jalr	830(ra) # 80002d80 <argstr>
    80005a4a:	02054963          	bltz	a0,80005a7c <sys_mkdir+0x54>
    80005a4e:	4681                	li	a3,0
    80005a50:	4601                	li	a2,0
    80005a52:	4585                	li	a1,1
    80005a54:	f7040513          	addi	a0,s0,-144
    80005a58:	fffff097          	auipc	ra,0xfffff
    80005a5c:	7fc080e7          	jalr	2044(ra) # 80005254 <create>
    80005a60:	cd11                	beqz	a0,80005a7c <sys_mkdir+0x54>
    end_op();
    return -1;
  }
  iunlockput(ip);
    80005a62:	ffffe097          	auipc	ra,0xffffe
    80005a66:	0e6080e7          	jalr	230(ra) # 80003b48 <iunlockput>
  end_op();
    80005a6a:	fffff097          	auipc	ra,0xfffff
    80005a6e:	8c6080e7          	jalr	-1850(ra) # 80004330 <end_op>
  return 0;
    80005a72:	4501                	li	a0,0
}
    80005a74:	60aa                	ld	ra,136(sp)
    80005a76:	640a                	ld	s0,128(sp)
    80005a78:	6149                	addi	sp,sp,144
    80005a7a:	8082                	ret
    end_op();
    80005a7c:	fffff097          	auipc	ra,0xfffff
    80005a80:	8b4080e7          	jalr	-1868(ra) # 80004330 <end_op>
    return -1;
    80005a84:	557d                	li	a0,-1
    80005a86:	b7fd                	j	80005a74 <sys_mkdir+0x4c>

0000000080005a88 <sys_mknod>:

uint64
sys_mknod(void)
{
    80005a88:	7135                	addi	sp,sp,-160
    80005a8a:	ed06                	sd	ra,152(sp)
    80005a8c:	e922                	sd	s0,144(sp)
    80005a8e:	1100                	addi	s0,sp,160
  struct inode *ip;
  char path[MAXPATH];
  int major, minor;

  begin_op();
    80005a90:	fffff097          	auipc	ra,0xfffff
    80005a94:	822080e7          	jalr	-2014(ra) # 800042b2 <begin_op>
  argint(1, &major);
    80005a98:	f6c40593          	addi	a1,s0,-148
    80005a9c:	4505                	li	a0,1
    80005a9e:	ffffd097          	auipc	ra,0xffffd
    80005aa2:	2a2080e7          	jalr	674(ra) # 80002d40 <argint>
  argint(2, &minor);
    80005aa6:	f6840593          	addi	a1,s0,-152
    80005aaa:	4509                	li	a0,2
    80005aac:	ffffd097          	auipc	ra,0xffffd
    80005ab0:	294080e7          	jalr	660(ra) # 80002d40 <argint>
  if((argstr(0, path, MAXPATH)) < 0 ||
    80005ab4:	08000613          	li	a2,128
    80005ab8:	f7040593          	addi	a1,s0,-144
    80005abc:	4501                	li	a0,0
    80005abe:	ffffd097          	auipc	ra,0xffffd
    80005ac2:	2c2080e7          	jalr	706(ra) # 80002d80 <argstr>
    80005ac6:	02054b63          	bltz	a0,80005afc <sys_mknod+0x74>
     (ip = create(path, T_DEVICE, major, minor)) == 0){
    80005aca:	f6841683          	lh	a3,-152(s0)
    80005ace:	f6c41603          	lh	a2,-148(s0)
    80005ad2:	458d                	li	a1,3
    80005ad4:	f7040513          	addi	a0,s0,-144
    80005ad8:	fffff097          	auipc	ra,0xfffff
    80005adc:	77c080e7          	jalr	1916(ra) # 80005254 <create>
  if((argstr(0, path, MAXPATH)) < 0 ||
    80005ae0:	cd11                	beqz	a0,80005afc <sys_mknod+0x74>
    end_op();
    return -1;
  }
  iunlockput(ip);
    80005ae2:	ffffe097          	auipc	ra,0xffffe
    80005ae6:	066080e7          	jalr	102(ra) # 80003b48 <iunlockput>
  end_op();
    80005aea:	fffff097          	auipc	ra,0xfffff
    80005aee:	846080e7          	jalr	-1978(ra) # 80004330 <end_op>
  return 0;
    80005af2:	4501                	li	a0,0
}
    80005af4:	60ea                	ld	ra,152(sp)
    80005af6:	644a                	ld	s0,144(sp)
    80005af8:	610d                	addi	sp,sp,160
    80005afa:	8082                	ret
    end_op();
    80005afc:	fffff097          	auipc	ra,0xfffff
    80005b00:	834080e7          	jalr	-1996(ra) # 80004330 <end_op>
    return -1;
    80005b04:	557d                	li	a0,-1
    80005b06:	b7fd                	j	80005af4 <sys_mknod+0x6c>

0000000080005b08 <sys_chdir>:

uint64
sys_chdir(void)
{
    80005b08:	7135                	addi	sp,sp,-160
    80005b0a:	ed06                	sd	ra,152(sp)
    80005b0c:	e922                	sd	s0,144(sp)
    80005b0e:	e526                	sd	s1,136(sp)
    80005b10:	e14a                	sd	s2,128(sp)
    80005b12:	1100                	addi	s0,sp,160
  char path[MAXPATH];
  struct inode *ip;
  struct proc *p = myproc();
    80005b14:	ffffc097          	auipc	ra,0xffffc
    80005b18:	e98080e7          	jalr	-360(ra) # 800019ac <myproc>
    80005b1c:	892a                	mv	s2,a0
  
  begin_op();
    80005b1e:	ffffe097          	auipc	ra,0xffffe
    80005b22:	794080e7          	jalr	1940(ra) # 800042b2 <begin_op>
  if(argstr(0, path, MAXPATH) < 0 || (ip = namei(path)) == 0){
    80005b26:	08000613          	li	a2,128
    80005b2a:	f6040593          	addi	a1,s0,-160
    80005b2e:	4501                	li	a0,0
    80005b30:	ffffd097          	auipc	ra,0xffffd
    80005b34:	250080e7          	jalr	592(ra) # 80002d80 <argstr>
    80005b38:	04054b63          	bltz	a0,80005b8e <sys_chdir+0x86>
    80005b3c:	f6040513          	addi	a0,s0,-160
    80005b40:	ffffe097          	auipc	ra,0xffffe
    80005b44:	552080e7          	jalr	1362(ra) # 80004092 <namei>
    80005b48:	84aa                	mv	s1,a0
    80005b4a:	c131                	beqz	a0,80005b8e <sys_chdir+0x86>
    end_op();
    return -1;
  }
  ilock(ip);
    80005b4c:	ffffe097          	auipc	ra,0xffffe
    80005b50:	d9a080e7          	jalr	-614(ra) # 800038e6 <ilock>
  if(ip->type != T_DIR){
    80005b54:	04449703          	lh	a4,68(s1)
    80005b58:	4785                	li	a5,1
    80005b5a:	04f71063          	bne	a4,a5,80005b9a <sys_chdir+0x92>
    iunlockput(ip);
    end_op();
    return -1;
  }
  iunlock(ip);
    80005b5e:	8526                	mv	a0,s1
    80005b60:	ffffe097          	auipc	ra,0xffffe
    80005b64:	e48080e7          	jalr	-440(ra) # 800039a8 <iunlock>
  iput(p->cwd);
    80005b68:	15093503          	ld	a0,336(s2)
    80005b6c:	ffffe097          	auipc	ra,0xffffe
    80005b70:	f34080e7          	jalr	-204(ra) # 80003aa0 <iput>
  end_op();
    80005b74:	ffffe097          	auipc	ra,0xffffe
    80005b78:	7bc080e7          	jalr	1980(ra) # 80004330 <end_op>
  p->cwd = ip;
    80005b7c:	14993823          	sd	s1,336(s2)
  return 0;
    80005b80:	4501                	li	a0,0
}
    80005b82:	60ea                	ld	ra,152(sp)
    80005b84:	644a                	ld	s0,144(sp)
    80005b86:	64aa                	ld	s1,136(sp)
    80005b88:	690a                	ld	s2,128(sp)
    80005b8a:	610d                	addi	sp,sp,160
    80005b8c:	8082                	ret
    end_op();
    80005b8e:	ffffe097          	auipc	ra,0xffffe
    80005b92:	7a2080e7          	jalr	1954(ra) # 80004330 <end_op>
    return -1;
    80005b96:	557d                	li	a0,-1
    80005b98:	b7ed                	j	80005b82 <sys_chdir+0x7a>
    iunlockput(ip);
    80005b9a:	8526                	mv	a0,s1
    80005b9c:	ffffe097          	auipc	ra,0xffffe
    80005ba0:	fac080e7          	jalr	-84(ra) # 80003b48 <iunlockput>
    end_op();
    80005ba4:	ffffe097          	auipc	ra,0xffffe
    80005ba8:	78c080e7          	jalr	1932(ra) # 80004330 <end_op>
    return -1;
    80005bac:	557d                	li	a0,-1
    80005bae:	bfd1                	j	80005b82 <sys_chdir+0x7a>

0000000080005bb0 <sys_exec>:

uint64
sys_exec(void)
{
    80005bb0:	7145                	addi	sp,sp,-464
    80005bb2:	e786                	sd	ra,456(sp)
    80005bb4:	e3a2                	sd	s0,448(sp)
    80005bb6:	ff26                	sd	s1,440(sp)
    80005bb8:	fb4a                	sd	s2,432(sp)
    80005bba:	f74e                	sd	s3,424(sp)
    80005bbc:	f352                	sd	s4,416(sp)
    80005bbe:	ef56                	sd	s5,408(sp)
    80005bc0:	0b80                	addi	s0,sp,464
  char path[MAXPATH], *argv[MAXARG];
  int i;
  uint64 uargv, uarg;

  argaddr(1, &uargv);
    80005bc2:	e3840593          	addi	a1,s0,-456
    80005bc6:	4505                	li	a0,1
    80005bc8:	ffffd097          	auipc	ra,0xffffd
    80005bcc:	198080e7          	jalr	408(ra) # 80002d60 <argaddr>
  if(argstr(0, path, MAXPATH) < 0) {
    80005bd0:	08000613          	li	a2,128
    80005bd4:	f4040593          	addi	a1,s0,-192
    80005bd8:	4501                	li	a0,0
    80005bda:	ffffd097          	auipc	ra,0xffffd
    80005bde:	1a6080e7          	jalr	422(ra) # 80002d80 <argstr>
    80005be2:	87aa                	mv	a5,a0
    return -1;
    80005be4:	557d                	li	a0,-1
  if(argstr(0, path, MAXPATH) < 0) {
    80005be6:	0c07c363          	bltz	a5,80005cac <sys_exec+0xfc>
  }
  memset(argv, 0, sizeof(argv));
    80005bea:	10000613          	li	a2,256
    80005bee:	4581                	li	a1,0
    80005bf0:	e4040513          	addi	a0,s0,-448
    80005bf4:	ffffb097          	auipc	ra,0xffffb
    80005bf8:	0de080e7          	jalr	222(ra) # 80000cd2 <memset>
  for(i=0;; i++){
    if(i >= NELEM(argv)){
    80005bfc:	e4040493          	addi	s1,s0,-448
  memset(argv, 0, sizeof(argv));
    80005c00:	89a6                	mv	s3,s1
    80005c02:	4901                	li	s2,0
    if(i >= NELEM(argv)){
    80005c04:	02000a13          	li	s4,32
    80005c08:	00090a9b          	sext.w	s5,s2
      goto bad;
    }
    if(fetchaddr(uargv+sizeof(uint64)*i, (uint64*)&uarg) < 0){
    80005c0c:	00391513          	slli	a0,s2,0x3
    80005c10:	e3040593          	addi	a1,s0,-464
    80005c14:	e3843783          	ld	a5,-456(s0)
    80005c18:	953e                	add	a0,a0,a5
    80005c1a:	ffffd097          	auipc	ra,0xffffd
    80005c1e:	088080e7          	jalr	136(ra) # 80002ca2 <fetchaddr>
    80005c22:	02054a63          	bltz	a0,80005c56 <sys_exec+0xa6>
      goto bad;
    }
    if(uarg == 0){
    80005c26:	e3043783          	ld	a5,-464(s0)
    80005c2a:	c3b9                	beqz	a5,80005c70 <sys_exec+0xc0>
      argv[i] = 0;
      break;
    }
    argv[i] = kalloc();
    80005c2c:	ffffb097          	auipc	ra,0xffffb
    80005c30:	eba080e7          	jalr	-326(ra) # 80000ae6 <kalloc>
    80005c34:	85aa                	mv	a1,a0
    80005c36:	00a9b023          	sd	a0,0(s3)
    if(argv[i] == 0)
    80005c3a:	cd11                	beqz	a0,80005c56 <sys_exec+0xa6>
      goto bad;
    if(fetchstr(uarg, argv[i], PGSIZE) < 0)
    80005c3c:	6605                	lui	a2,0x1
    80005c3e:	e3043503          	ld	a0,-464(s0)
    80005c42:	ffffd097          	auipc	ra,0xffffd
    80005c46:	0b2080e7          	jalr	178(ra) # 80002cf4 <fetchstr>
    80005c4a:	00054663          	bltz	a0,80005c56 <sys_exec+0xa6>
    if(i >= NELEM(argv)){
    80005c4e:	0905                	addi	s2,s2,1
    80005c50:	09a1                	addi	s3,s3,8
    80005c52:	fb491be3          	bne	s2,s4,80005c08 <sys_exec+0x58>
    kfree(argv[i]);

  return ret;

 bad:
  for(i = 0; i < NELEM(argv) && argv[i] != 0; i++)
    80005c56:	f4040913          	addi	s2,s0,-192
    80005c5a:	6088                	ld	a0,0(s1)
    80005c5c:	c539                	beqz	a0,80005caa <sys_exec+0xfa>
    kfree(argv[i]);
    80005c5e:	ffffb097          	auipc	ra,0xffffb
    80005c62:	d8a080e7          	jalr	-630(ra) # 800009e8 <kfree>
  for(i = 0; i < NELEM(argv) && argv[i] != 0; i++)
    80005c66:	04a1                	addi	s1,s1,8
    80005c68:	ff2499e3          	bne	s1,s2,80005c5a <sys_exec+0xaa>
  return -1;
    80005c6c:	557d                	li	a0,-1
    80005c6e:	a83d                	j	80005cac <sys_exec+0xfc>
      argv[i] = 0;
    80005c70:	0a8e                	slli	s5,s5,0x3
    80005c72:	fc0a8793          	addi	a5,s5,-64
    80005c76:	00878ab3          	add	s5,a5,s0
    80005c7a:	e80ab023          	sd	zero,-384(s5)
  int ret = exec(path, argv);
    80005c7e:	e4040593          	addi	a1,s0,-448
    80005c82:	f4040513          	addi	a0,s0,-192
    80005c86:	fffff097          	auipc	ra,0xfffff
    80005c8a:	16e080e7          	jalr	366(ra) # 80004df4 <exec>
    80005c8e:	892a                	mv	s2,a0
  for(i = 0; i < NELEM(argv) && argv[i] != 0; i++)
    80005c90:	f4040993          	addi	s3,s0,-192
    80005c94:	6088                	ld	a0,0(s1)
    80005c96:	c901                	beqz	a0,80005ca6 <sys_exec+0xf6>
    kfree(argv[i]);
    80005c98:	ffffb097          	auipc	ra,0xffffb
    80005c9c:	d50080e7          	jalr	-688(ra) # 800009e8 <kfree>
  for(i = 0; i < NELEM(argv) && argv[i] != 0; i++)
    80005ca0:	04a1                	addi	s1,s1,8
    80005ca2:	ff3499e3          	bne	s1,s3,80005c94 <sys_exec+0xe4>
  return ret;
    80005ca6:	854a                	mv	a0,s2
    80005ca8:	a011                	j	80005cac <sys_exec+0xfc>
  return -1;
    80005caa:	557d                	li	a0,-1
}
    80005cac:	60be                	ld	ra,456(sp)
    80005cae:	641e                	ld	s0,448(sp)
    80005cb0:	74fa                	ld	s1,440(sp)
    80005cb2:	795a                	ld	s2,432(sp)
    80005cb4:	79ba                	ld	s3,424(sp)
    80005cb6:	7a1a                	ld	s4,416(sp)
    80005cb8:	6afa                	ld	s5,408(sp)
    80005cba:	6179                	addi	sp,sp,464
    80005cbc:	8082                	ret

0000000080005cbe <sys_pipe>:

uint64
sys_pipe(void)
{
    80005cbe:	7139                	addi	sp,sp,-64
    80005cc0:	fc06                	sd	ra,56(sp)
    80005cc2:	f822                	sd	s0,48(sp)
    80005cc4:	f426                	sd	s1,40(sp)
    80005cc6:	0080                	addi	s0,sp,64
  uint64 fdarray; // user pointer to array of two integers
  struct file *rf, *wf;
  int fd0, fd1;
  struct proc *p = myproc();
    80005cc8:	ffffc097          	auipc	ra,0xffffc
    80005ccc:	ce4080e7          	jalr	-796(ra) # 800019ac <myproc>
    80005cd0:	84aa                	mv	s1,a0

  argaddr(0, &fdarray);
    80005cd2:	fd840593          	addi	a1,s0,-40
    80005cd6:	4501                	li	a0,0
    80005cd8:	ffffd097          	auipc	ra,0xffffd
    80005cdc:	088080e7          	jalr	136(ra) # 80002d60 <argaddr>
  if(pipealloc(&rf, &wf) < 0)
    80005ce0:	fc840593          	addi	a1,s0,-56
    80005ce4:	fd040513          	addi	a0,s0,-48
    80005ce8:	fffff097          	auipc	ra,0xfffff
    80005cec:	dc2080e7          	jalr	-574(ra) # 80004aaa <pipealloc>
    return -1;
    80005cf0:	57fd                	li	a5,-1
  if(pipealloc(&rf, &wf) < 0)
    80005cf2:	0c054463          	bltz	a0,80005dba <sys_pipe+0xfc>
  fd0 = -1;
    80005cf6:	fcf42223          	sw	a5,-60(s0)
  if((fd0 = fdalloc(rf)) < 0 || (fd1 = fdalloc(wf)) < 0){
    80005cfa:	fd043503          	ld	a0,-48(s0)
    80005cfe:	fffff097          	auipc	ra,0xfffff
    80005d02:	514080e7          	jalr	1300(ra) # 80005212 <fdalloc>
    80005d06:	fca42223          	sw	a0,-60(s0)
    80005d0a:	08054b63          	bltz	a0,80005da0 <sys_pipe+0xe2>
    80005d0e:	fc843503          	ld	a0,-56(s0)
    80005d12:	fffff097          	auipc	ra,0xfffff
    80005d16:	500080e7          	jalr	1280(ra) # 80005212 <fdalloc>
    80005d1a:	fca42023          	sw	a0,-64(s0)
    80005d1e:	06054863          	bltz	a0,80005d8e <sys_pipe+0xd0>
      p->ofile[fd0] = 0;
    fileclose(rf);
    fileclose(wf);
    return -1;
  }
  if(copyout(p->pagetable, fdarray, (char*)&fd0, sizeof(fd0)) < 0 ||
    80005d22:	4691                	li	a3,4
    80005d24:	fc440613          	addi	a2,s0,-60
    80005d28:	fd843583          	ld	a1,-40(s0)
    80005d2c:	68a8                	ld	a0,80(s1)
    80005d2e:	ffffc097          	auipc	ra,0xffffc
    80005d32:	93e080e7          	jalr	-1730(ra) # 8000166c <copyout>
    80005d36:	02054063          	bltz	a0,80005d56 <sys_pipe+0x98>
     copyout(p->pagetable, fdarray+sizeof(fd0), (char *)&fd1, sizeof(fd1)) < 0){
    80005d3a:	4691                	li	a3,4
    80005d3c:	fc040613          	addi	a2,s0,-64
    80005d40:	fd843583          	ld	a1,-40(s0)
    80005d44:	0591                	addi	a1,a1,4
    80005d46:	68a8                	ld	a0,80(s1)
    80005d48:	ffffc097          	auipc	ra,0xffffc
    80005d4c:	924080e7          	jalr	-1756(ra) # 8000166c <copyout>
    p->ofile[fd1] = 0;
    fileclose(rf);
    fileclose(wf);
    return -1;
  }
  return 0;
    80005d50:	4781                	li	a5,0
  if(copyout(p->pagetable, fdarray, (char*)&fd0, sizeof(fd0)) < 0 ||
    80005d52:	06055463          	bgez	a0,80005dba <sys_pipe+0xfc>
    p->ofile[fd0] = 0;
    80005d56:	fc442783          	lw	a5,-60(s0)
    80005d5a:	07e9                	addi	a5,a5,26
    80005d5c:	078e                	slli	a5,a5,0x3
    80005d5e:	97a6                	add	a5,a5,s1
    80005d60:	0007b023          	sd	zero,0(a5)
    p->ofile[fd1] = 0;
    80005d64:	fc042783          	lw	a5,-64(s0)
    80005d68:	07e9                	addi	a5,a5,26
    80005d6a:	078e                	slli	a5,a5,0x3
    80005d6c:	94be                	add	s1,s1,a5
    80005d6e:	0004b023          	sd	zero,0(s1)
    fileclose(rf);
    80005d72:	fd043503          	ld	a0,-48(s0)
    80005d76:	fffff097          	auipc	ra,0xfffff
    80005d7a:	a04080e7          	jalr	-1532(ra) # 8000477a <fileclose>
    fileclose(wf);
    80005d7e:	fc843503          	ld	a0,-56(s0)
    80005d82:	fffff097          	auipc	ra,0xfffff
    80005d86:	9f8080e7          	jalr	-1544(ra) # 8000477a <fileclose>
    return -1;
    80005d8a:	57fd                	li	a5,-1
    80005d8c:	a03d                	j	80005dba <sys_pipe+0xfc>
    if(fd0 >= 0)
    80005d8e:	fc442783          	lw	a5,-60(s0)
    80005d92:	0007c763          	bltz	a5,80005da0 <sys_pipe+0xe2>
      p->ofile[fd0] = 0;
    80005d96:	07e9                	addi	a5,a5,26
    80005d98:	078e                	slli	a5,a5,0x3
    80005d9a:	97a6                	add	a5,a5,s1
    80005d9c:	0007b023          	sd	zero,0(a5)
    fileclose(rf);
    80005da0:	fd043503          	ld	a0,-48(s0)
    80005da4:	fffff097          	auipc	ra,0xfffff
    80005da8:	9d6080e7          	jalr	-1578(ra) # 8000477a <fileclose>
    fileclose(wf);
    80005dac:	fc843503          	ld	a0,-56(s0)
    80005db0:	fffff097          	auipc	ra,0xfffff
    80005db4:	9ca080e7          	jalr	-1590(ra) # 8000477a <fileclose>
    return -1;
    80005db8:	57fd                	li	a5,-1
}
    80005dba:	853e                	mv	a0,a5
    80005dbc:	70e2                	ld	ra,56(sp)
    80005dbe:	7442                	ld	s0,48(sp)
    80005dc0:	74a2                	ld	s1,40(sp)
    80005dc2:	6121                	addi	sp,sp,64
    80005dc4:	8082                	ret
	...

0000000080005dd0 <kernelvec>:
    80005dd0:	7111                	addi	sp,sp,-256
    80005dd2:	e006                	sd	ra,0(sp)
    80005dd4:	e40a                	sd	sp,8(sp)
    80005dd6:	e80e                	sd	gp,16(sp)
    80005dd8:	ec12                	sd	tp,24(sp)
    80005dda:	f016                	sd	t0,32(sp)
    80005ddc:	f41a                	sd	t1,40(sp)
    80005dde:	f81e                	sd	t2,48(sp)
    80005de0:	fc22                	sd	s0,56(sp)
    80005de2:	e0a6                	sd	s1,64(sp)
    80005de4:	e4aa                	sd	a0,72(sp)
    80005de6:	e8ae                	sd	a1,80(sp)
    80005de8:	ecb2                	sd	a2,88(sp)
    80005dea:	f0b6                	sd	a3,96(sp)
    80005dec:	f4ba                	sd	a4,104(sp)
    80005dee:	f8be                	sd	a5,112(sp)
    80005df0:	fcc2                	sd	a6,120(sp)
    80005df2:	e146                	sd	a7,128(sp)
    80005df4:	e54a                	sd	s2,136(sp)
    80005df6:	e94e                	sd	s3,144(sp)
    80005df8:	ed52                	sd	s4,152(sp)
    80005dfa:	f156                	sd	s5,160(sp)
    80005dfc:	f55a                	sd	s6,168(sp)
    80005dfe:	f95e                	sd	s7,176(sp)
    80005e00:	fd62                	sd	s8,184(sp)
    80005e02:	e1e6                	sd	s9,192(sp)
    80005e04:	e5ea                	sd	s10,200(sp)
    80005e06:	e9ee                	sd	s11,208(sp)
    80005e08:	edf2                	sd	t3,216(sp)
    80005e0a:	f1f6                	sd	t4,224(sp)
    80005e0c:	f5fa                	sd	t5,232(sp)
    80005e0e:	f9fe                	sd	t6,240(sp)
    80005e10:	d5ffc0ef          	jal	ra,80002b6e <kerneltrap>
    80005e14:	6082                	ld	ra,0(sp)
    80005e16:	6122                	ld	sp,8(sp)
    80005e18:	61c2                	ld	gp,16(sp)
    80005e1a:	7282                	ld	t0,32(sp)
    80005e1c:	7322                	ld	t1,40(sp)
    80005e1e:	73c2                	ld	t2,48(sp)
    80005e20:	7462                	ld	s0,56(sp)
    80005e22:	6486                	ld	s1,64(sp)
    80005e24:	6526                	ld	a0,72(sp)
    80005e26:	65c6                	ld	a1,80(sp)
    80005e28:	6666                	ld	a2,88(sp)
    80005e2a:	7686                	ld	a3,96(sp)
    80005e2c:	7726                	ld	a4,104(sp)
    80005e2e:	77c6                	ld	a5,112(sp)
    80005e30:	7866                	ld	a6,120(sp)
    80005e32:	688a                	ld	a7,128(sp)
    80005e34:	692a                	ld	s2,136(sp)
    80005e36:	69ca                	ld	s3,144(sp)
    80005e38:	6a6a                	ld	s4,152(sp)
    80005e3a:	7a8a                	ld	s5,160(sp)
    80005e3c:	7b2a                	ld	s6,168(sp)
    80005e3e:	7bca                	ld	s7,176(sp)
    80005e40:	7c6a                	ld	s8,184(sp)
    80005e42:	6c8e                	ld	s9,192(sp)
    80005e44:	6d2e                	ld	s10,200(sp)
    80005e46:	6dce                	ld	s11,208(sp)
    80005e48:	6e6e                	ld	t3,216(sp)
    80005e4a:	7e8e                	ld	t4,224(sp)
    80005e4c:	7f2e                	ld	t5,232(sp)
    80005e4e:	7fce                	ld	t6,240(sp)
    80005e50:	6111                	addi	sp,sp,256
    80005e52:	10200073          	sret
    80005e56:	00000013          	nop
    80005e5a:	00000013          	nop
    80005e5e:	0001                	nop

0000000080005e60 <timervec>:
    80005e60:	34051573          	csrrw	a0,mscratch,a0
    80005e64:	e10c                	sd	a1,0(a0)
    80005e66:	e510                	sd	a2,8(a0)
    80005e68:	e914                	sd	a3,16(a0)
    80005e6a:	6d0c                	ld	a1,24(a0)
    80005e6c:	7110                	ld	a2,32(a0)
    80005e6e:	6194                	ld	a3,0(a1)
    80005e70:	96b2                	add	a3,a3,a2
    80005e72:	e194                	sd	a3,0(a1)
    80005e74:	4589                	li	a1,2
    80005e76:	14459073          	csrw	sip,a1
    80005e7a:	6914                	ld	a3,16(a0)
    80005e7c:	6510                	ld	a2,8(a0)
    80005e7e:	610c                	ld	a1,0(a0)
    80005e80:	34051573          	csrrw	a0,mscratch,a0
    80005e84:	30200073          	mret
	...

0000000080005e8a <plicinit>:
// the riscv Platform Level Interrupt Controller (PLIC).
//

void
plicinit(void)
{
    80005e8a:	1141                	addi	sp,sp,-16
    80005e8c:	e422                	sd	s0,8(sp)
    80005e8e:	0800                	addi	s0,sp,16
  // set desired IRQ priorities non-zero (otherwise disabled).
  *(uint32*)(PLIC + UART0_IRQ*4) = 1;
    80005e90:	0c0007b7          	lui	a5,0xc000
    80005e94:	4705                	li	a4,1
    80005e96:	d798                	sw	a4,40(a5)
  *(uint32*)(PLIC + VIRTIO0_IRQ*4) = 1;
    80005e98:	c3d8                	sw	a4,4(a5)
}
    80005e9a:	6422                	ld	s0,8(sp)
    80005e9c:	0141                	addi	sp,sp,16
    80005e9e:	8082                	ret

0000000080005ea0 <plicinithart>:

void
plicinithart(void)
{
    80005ea0:	1141                	addi	sp,sp,-16
    80005ea2:	e406                	sd	ra,8(sp)
    80005ea4:	e022                	sd	s0,0(sp)
    80005ea6:	0800                	addi	s0,sp,16
  int hart = cpuid();
    80005ea8:	ffffc097          	auipc	ra,0xffffc
    80005eac:	ad8080e7          	jalr	-1320(ra) # 80001980 <cpuid>
  
  // set enable bits for this hart's S-mode
  // for the uart and virtio disk.
  *(uint32*)PLIC_SENABLE(hart) = (1 << UART0_IRQ) | (1 << VIRTIO0_IRQ);
    80005eb0:	0085171b          	slliw	a4,a0,0x8
    80005eb4:	0c0027b7          	lui	a5,0xc002
    80005eb8:	97ba                	add	a5,a5,a4
    80005eba:	40200713          	li	a4,1026
    80005ebe:	08e7a023          	sw	a4,128(a5) # c002080 <_entry-0x73ffdf80>

  // set this hart's S-mode priority threshold to 0.
  *(uint32*)PLIC_SPRIORITY(hart) = 0;
    80005ec2:	00d5151b          	slliw	a0,a0,0xd
    80005ec6:	0c2017b7          	lui	a5,0xc201
    80005eca:	97aa                	add	a5,a5,a0
    80005ecc:	0007a023          	sw	zero,0(a5) # c201000 <_entry-0x73dff000>
}
    80005ed0:	60a2                	ld	ra,8(sp)
    80005ed2:	6402                	ld	s0,0(sp)
    80005ed4:	0141                	addi	sp,sp,16
    80005ed6:	8082                	ret

0000000080005ed8 <plic_claim>:

// ask the PLIC what interrupt we should serve.
int
plic_claim(void)
{
    80005ed8:	1141                	addi	sp,sp,-16
    80005eda:	e406                	sd	ra,8(sp)
    80005edc:	e022                	sd	s0,0(sp)
    80005ede:	0800                	addi	s0,sp,16
  int hart = cpuid();
    80005ee0:	ffffc097          	auipc	ra,0xffffc
    80005ee4:	aa0080e7          	jalr	-1376(ra) # 80001980 <cpuid>
  int irq = *(uint32*)PLIC_SCLAIM(hart);
    80005ee8:	00d5151b          	slliw	a0,a0,0xd
    80005eec:	0c2017b7          	lui	a5,0xc201
    80005ef0:	97aa                	add	a5,a5,a0
  return irq;
}
    80005ef2:	43c8                	lw	a0,4(a5)
    80005ef4:	60a2                	ld	ra,8(sp)
    80005ef6:	6402                	ld	s0,0(sp)
    80005ef8:	0141                	addi	sp,sp,16
    80005efa:	8082                	ret

0000000080005efc <plic_complete>:

// tell the PLIC we've served this IRQ.
void
plic_complete(int irq)
{
    80005efc:	1101                	addi	sp,sp,-32
    80005efe:	ec06                	sd	ra,24(sp)
    80005f00:	e822                	sd	s0,16(sp)
    80005f02:	e426                	sd	s1,8(sp)
    80005f04:	1000                	addi	s0,sp,32
    80005f06:	84aa                	mv	s1,a0
  int hart = cpuid();
    80005f08:	ffffc097          	auipc	ra,0xffffc
    80005f0c:	a78080e7          	jalr	-1416(ra) # 80001980 <cpuid>
  *(uint32*)PLIC_SCLAIM(hart) = irq;
    80005f10:	00d5151b          	slliw	a0,a0,0xd
    80005f14:	0c2017b7          	lui	a5,0xc201
    80005f18:	97aa                	add	a5,a5,a0
    80005f1a:	c3c4                	sw	s1,4(a5)
}
    80005f1c:	60e2                	ld	ra,24(sp)
    80005f1e:	6442                	ld	s0,16(sp)
    80005f20:	64a2                	ld	s1,8(sp)
    80005f22:	6105                	addi	sp,sp,32
    80005f24:	8082                	ret

0000000080005f26 <free_desc>:
}

// mark a descriptor as free.
static void
free_desc(int i)
{
    80005f26:	1141                	addi	sp,sp,-16
    80005f28:	e406                	sd	ra,8(sp)
    80005f2a:	e022                	sd	s0,0(sp)
    80005f2c:	0800                	addi	s0,sp,16
  if(i >= NUM)
    80005f2e:	479d                	li	a5,7
    80005f30:	04a7cc63          	blt	a5,a0,80005f88 <free_desc+0x62>
    panic("free_desc 1");
  if(disk.free[i])
    80005f34:	0001c797          	auipc	a5,0x1c
    80005f38:	f1478793          	addi	a5,a5,-236 # 80021e48 <disk>
    80005f3c:	97aa                	add	a5,a5,a0
    80005f3e:	0187c783          	lbu	a5,24(a5)
    80005f42:	ebb9                	bnez	a5,80005f98 <free_desc+0x72>
    panic("free_desc 2");
  disk.desc[i].addr = 0;
    80005f44:	00451693          	slli	a3,a0,0x4
    80005f48:	0001c797          	auipc	a5,0x1c
    80005f4c:	f0078793          	addi	a5,a5,-256 # 80021e48 <disk>
    80005f50:	6398                	ld	a4,0(a5)
    80005f52:	9736                	add	a4,a4,a3
    80005f54:	00073023          	sd	zero,0(a4)
  disk.desc[i].len = 0;
    80005f58:	6398                	ld	a4,0(a5)
    80005f5a:	9736                	add	a4,a4,a3
    80005f5c:	00072423          	sw	zero,8(a4)
  disk.desc[i].flags = 0;
    80005f60:	00071623          	sh	zero,12(a4)
  disk.desc[i].next = 0;
    80005f64:	00071723          	sh	zero,14(a4)
  disk.free[i] = 1;
    80005f68:	97aa                	add	a5,a5,a0
    80005f6a:	4705                	li	a4,1
    80005f6c:	00e78c23          	sb	a4,24(a5)
  wakeup(&disk.free[0]);
    80005f70:	0001c517          	auipc	a0,0x1c
    80005f74:	ef050513          	addi	a0,a0,-272 # 80021e60 <disk+0x18>
    80005f78:	ffffc097          	auipc	ra,0xffffc
    80005f7c:	1ae080e7          	jalr	430(ra) # 80002126 <wakeup>
}
    80005f80:	60a2                	ld	ra,8(sp)
    80005f82:	6402                	ld	s0,0(sp)
    80005f84:	0141                	addi	sp,sp,16
    80005f86:	8082                	ret
    panic("free_desc 1");
    80005f88:	00002517          	auipc	a0,0x2
    80005f8c:	7c050513          	addi	a0,a0,1984 # 80008748 <syscalls+0x2f8>
    80005f90:	ffffa097          	auipc	ra,0xffffa
    80005f94:	5b0080e7          	jalr	1456(ra) # 80000540 <panic>
    panic("free_desc 2");
    80005f98:	00002517          	auipc	a0,0x2
    80005f9c:	7c050513          	addi	a0,a0,1984 # 80008758 <syscalls+0x308>
    80005fa0:	ffffa097          	auipc	ra,0xffffa
    80005fa4:	5a0080e7          	jalr	1440(ra) # 80000540 <panic>

0000000080005fa8 <virtio_disk_init>:
{
    80005fa8:	1101                	addi	sp,sp,-32
    80005faa:	ec06                	sd	ra,24(sp)
    80005fac:	e822                	sd	s0,16(sp)
    80005fae:	e426                	sd	s1,8(sp)
    80005fb0:	e04a                	sd	s2,0(sp)
    80005fb2:	1000                	addi	s0,sp,32
  initlock(&disk.vdisk_lock, "virtio_disk");
    80005fb4:	00002597          	auipc	a1,0x2
    80005fb8:	7b458593          	addi	a1,a1,1972 # 80008768 <syscalls+0x318>
    80005fbc:	0001c517          	auipc	a0,0x1c
    80005fc0:	fb450513          	addi	a0,a0,-76 # 80021f70 <disk+0x128>
    80005fc4:	ffffb097          	auipc	ra,0xffffb
    80005fc8:	b82080e7          	jalr	-1150(ra) # 80000b46 <initlock>
  if(*R(VIRTIO_MMIO_MAGIC_VALUE) != 0x74726976 ||
    80005fcc:	100017b7          	lui	a5,0x10001
    80005fd0:	4398                	lw	a4,0(a5)
    80005fd2:	2701                	sext.w	a4,a4
    80005fd4:	747277b7          	lui	a5,0x74727
    80005fd8:	97678793          	addi	a5,a5,-1674 # 74726976 <_entry-0xb8d968a>
    80005fdc:	14f71b63          	bne	a4,a5,80006132 <virtio_disk_init+0x18a>
     *R(VIRTIO_MMIO_VERSION) != 2 ||
    80005fe0:	100017b7          	lui	a5,0x10001
    80005fe4:	43dc                	lw	a5,4(a5)
    80005fe6:	2781                	sext.w	a5,a5
  if(*R(VIRTIO_MMIO_MAGIC_VALUE) != 0x74726976 ||
    80005fe8:	4709                	li	a4,2
    80005fea:	14e79463          	bne	a5,a4,80006132 <virtio_disk_init+0x18a>
     *R(VIRTIO_MMIO_DEVICE_ID) != 2 ||
    80005fee:	100017b7          	lui	a5,0x10001
    80005ff2:	479c                	lw	a5,8(a5)
    80005ff4:	2781                	sext.w	a5,a5
     *R(VIRTIO_MMIO_VERSION) != 2 ||
    80005ff6:	12e79e63          	bne	a5,a4,80006132 <virtio_disk_init+0x18a>
     *R(VIRTIO_MMIO_VENDOR_ID) != 0x554d4551){
    80005ffa:	100017b7          	lui	a5,0x10001
    80005ffe:	47d8                	lw	a4,12(a5)
    80006000:	2701                	sext.w	a4,a4
     *R(VIRTIO_MMIO_DEVICE_ID) != 2 ||
    80006002:	554d47b7          	lui	a5,0x554d4
    80006006:	55178793          	addi	a5,a5,1361 # 554d4551 <_entry-0x2ab2baaf>
    8000600a:	12f71463          	bne	a4,a5,80006132 <virtio_disk_init+0x18a>
  *R(VIRTIO_MMIO_STATUS) = status;
    8000600e:	100017b7          	lui	a5,0x10001
    80006012:	0607a823          	sw	zero,112(a5) # 10001070 <_entry-0x6fffef90>
  *R(VIRTIO_MMIO_STATUS) = status;
    80006016:	4705                	li	a4,1
    80006018:	dbb8                	sw	a4,112(a5)
  *R(VIRTIO_MMIO_STATUS) = status;
    8000601a:	470d                	li	a4,3
    8000601c:	dbb8                	sw	a4,112(a5)
  uint64 features = *R(VIRTIO_MMIO_DEVICE_FEATURES);
    8000601e:	4b98                	lw	a4,16(a5)
  *R(VIRTIO_MMIO_DRIVER_FEATURES) = features;
    80006020:	c7ffe6b7          	lui	a3,0xc7ffe
    80006024:	75f68693          	addi	a3,a3,1887 # ffffffffc7ffe75f <end+0xffffffff47fdc7d7>
    80006028:	8f75                	and	a4,a4,a3
    8000602a:	d398                	sw	a4,32(a5)
  *R(VIRTIO_MMIO_STATUS) = status;
    8000602c:	472d                	li	a4,11
    8000602e:	dbb8                	sw	a4,112(a5)
  status = *R(VIRTIO_MMIO_STATUS);
    80006030:	5bbc                	lw	a5,112(a5)
    80006032:	0007891b          	sext.w	s2,a5
  if(!(status & VIRTIO_CONFIG_S_FEATURES_OK))
    80006036:	8ba1                	andi	a5,a5,8
    80006038:	10078563          	beqz	a5,80006142 <virtio_disk_init+0x19a>
  *R(VIRTIO_MMIO_QUEUE_SEL) = 0;
    8000603c:	100017b7          	lui	a5,0x10001
    80006040:	0207a823          	sw	zero,48(a5) # 10001030 <_entry-0x6fffefd0>
  if(*R(VIRTIO_MMIO_QUEUE_READY))
    80006044:	43fc                	lw	a5,68(a5)
    80006046:	2781                	sext.w	a5,a5
    80006048:	10079563          	bnez	a5,80006152 <virtio_disk_init+0x1aa>
  uint32 max = *R(VIRTIO_MMIO_QUEUE_NUM_MAX);
    8000604c:	100017b7          	lui	a5,0x10001
    80006050:	5bdc                	lw	a5,52(a5)
    80006052:	2781                	sext.w	a5,a5
  if(max == 0)
    80006054:	10078763          	beqz	a5,80006162 <virtio_disk_init+0x1ba>
  if(max < NUM)
    80006058:	471d                	li	a4,7
    8000605a:	10f77c63          	bgeu	a4,a5,80006172 <virtio_disk_init+0x1ca>
  disk.desc = kalloc();
    8000605e:	ffffb097          	auipc	ra,0xffffb
    80006062:	a88080e7          	jalr	-1400(ra) # 80000ae6 <kalloc>
    80006066:	0001c497          	auipc	s1,0x1c
    8000606a:	de248493          	addi	s1,s1,-542 # 80021e48 <disk>
    8000606e:	e088                	sd	a0,0(s1)
  disk.avail = kalloc();
    80006070:	ffffb097          	auipc	ra,0xffffb
    80006074:	a76080e7          	jalr	-1418(ra) # 80000ae6 <kalloc>
    80006078:	e488                	sd	a0,8(s1)
  disk.used = kalloc();
    8000607a:	ffffb097          	auipc	ra,0xffffb
    8000607e:	a6c080e7          	jalr	-1428(ra) # 80000ae6 <kalloc>
    80006082:	87aa                	mv	a5,a0
    80006084:	e888                	sd	a0,16(s1)
  if(!disk.desc || !disk.avail || !disk.used)
    80006086:	6088                	ld	a0,0(s1)
    80006088:	cd6d                	beqz	a0,80006182 <virtio_disk_init+0x1da>
    8000608a:	0001c717          	auipc	a4,0x1c
    8000608e:	dc673703          	ld	a4,-570(a4) # 80021e50 <disk+0x8>
    80006092:	cb65                	beqz	a4,80006182 <virtio_disk_init+0x1da>
    80006094:	c7fd                	beqz	a5,80006182 <virtio_disk_init+0x1da>
  memset(disk.desc, 0, PGSIZE);
    80006096:	6605                	lui	a2,0x1
    80006098:	4581                	li	a1,0
    8000609a:	ffffb097          	auipc	ra,0xffffb
    8000609e:	c38080e7          	jalr	-968(ra) # 80000cd2 <memset>
  memset(disk.avail, 0, PGSIZE);
    800060a2:	0001c497          	auipc	s1,0x1c
    800060a6:	da648493          	addi	s1,s1,-602 # 80021e48 <disk>
    800060aa:	6605                	lui	a2,0x1
    800060ac:	4581                	li	a1,0
    800060ae:	6488                	ld	a0,8(s1)
    800060b0:	ffffb097          	auipc	ra,0xffffb
    800060b4:	c22080e7          	jalr	-990(ra) # 80000cd2 <memset>
  memset(disk.used, 0, PGSIZE);
    800060b8:	6605                	lui	a2,0x1
    800060ba:	4581                	li	a1,0
    800060bc:	6888                	ld	a0,16(s1)
    800060be:	ffffb097          	auipc	ra,0xffffb
    800060c2:	c14080e7          	jalr	-1004(ra) # 80000cd2 <memset>
  *R(VIRTIO_MMIO_QUEUE_NUM) = NUM;
    800060c6:	100017b7          	lui	a5,0x10001
    800060ca:	4721                	li	a4,8
    800060cc:	df98                	sw	a4,56(a5)
  *R(VIRTIO_MMIO_QUEUE_DESC_LOW) = (uint64)disk.desc;
    800060ce:	4098                	lw	a4,0(s1)
    800060d0:	08e7a023          	sw	a4,128(a5) # 10001080 <_entry-0x6fffef80>
  *R(VIRTIO_MMIO_QUEUE_DESC_HIGH) = (uint64)disk.desc >> 32;
    800060d4:	40d8                	lw	a4,4(s1)
    800060d6:	08e7a223          	sw	a4,132(a5)
  *R(VIRTIO_MMIO_DRIVER_DESC_LOW) = (uint64)disk.avail;
    800060da:	6498                	ld	a4,8(s1)
    800060dc:	0007069b          	sext.w	a3,a4
    800060e0:	08d7a823          	sw	a3,144(a5)
  *R(VIRTIO_MMIO_DRIVER_DESC_HIGH) = (uint64)disk.avail >> 32;
    800060e4:	9701                	srai	a4,a4,0x20
    800060e6:	08e7aa23          	sw	a4,148(a5)
  *R(VIRTIO_MMIO_DEVICE_DESC_LOW) = (uint64)disk.used;
    800060ea:	6898                	ld	a4,16(s1)
    800060ec:	0007069b          	sext.w	a3,a4
    800060f0:	0ad7a023          	sw	a3,160(a5)
  *R(VIRTIO_MMIO_DEVICE_DESC_HIGH) = (uint64)disk.used >> 32;
    800060f4:	9701                	srai	a4,a4,0x20
    800060f6:	0ae7a223          	sw	a4,164(a5)
  *R(VIRTIO_MMIO_QUEUE_READY) = 0x1;
    800060fa:	4705                	li	a4,1
    800060fc:	c3f8                	sw	a4,68(a5)
    disk.free[i] = 1;
    800060fe:	00e48c23          	sb	a4,24(s1)
    80006102:	00e48ca3          	sb	a4,25(s1)
    80006106:	00e48d23          	sb	a4,26(s1)
    8000610a:	00e48da3          	sb	a4,27(s1)
    8000610e:	00e48e23          	sb	a4,28(s1)
    80006112:	00e48ea3          	sb	a4,29(s1)
    80006116:	00e48f23          	sb	a4,30(s1)
    8000611a:	00e48fa3          	sb	a4,31(s1)
  status |= VIRTIO_CONFIG_S_DRIVER_OK;
    8000611e:	00496913          	ori	s2,s2,4
  *R(VIRTIO_MMIO_STATUS) = status;
    80006122:	0727a823          	sw	s2,112(a5)
}
    80006126:	60e2                	ld	ra,24(sp)
    80006128:	6442                	ld	s0,16(sp)
    8000612a:	64a2                	ld	s1,8(sp)
    8000612c:	6902                	ld	s2,0(sp)
    8000612e:	6105                	addi	sp,sp,32
    80006130:	8082                	ret
    panic("could not find virtio disk");
    80006132:	00002517          	auipc	a0,0x2
    80006136:	64650513          	addi	a0,a0,1606 # 80008778 <syscalls+0x328>
    8000613a:	ffffa097          	auipc	ra,0xffffa
    8000613e:	406080e7          	jalr	1030(ra) # 80000540 <panic>
    panic("virtio disk FEATURES_OK unset");
    80006142:	00002517          	auipc	a0,0x2
    80006146:	65650513          	addi	a0,a0,1622 # 80008798 <syscalls+0x348>
    8000614a:	ffffa097          	auipc	ra,0xffffa
    8000614e:	3f6080e7          	jalr	1014(ra) # 80000540 <panic>
    panic("virtio disk should not be ready");
    80006152:	00002517          	auipc	a0,0x2
    80006156:	66650513          	addi	a0,a0,1638 # 800087b8 <syscalls+0x368>
    8000615a:	ffffa097          	auipc	ra,0xffffa
    8000615e:	3e6080e7          	jalr	998(ra) # 80000540 <panic>
    panic("virtio disk has no queue 0");
    80006162:	00002517          	auipc	a0,0x2
    80006166:	67650513          	addi	a0,a0,1654 # 800087d8 <syscalls+0x388>
    8000616a:	ffffa097          	auipc	ra,0xffffa
    8000616e:	3d6080e7          	jalr	982(ra) # 80000540 <panic>
    panic("virtio disk max queue too short");
    80006172:	00002517          	auipc	a0,0x2
    80006176:	68650513          	addi	a0,a0,1670 # 800087f8 <syscalls+0x3a8>
    8000617a:	ffffa097          	auipc	ra,0xffffa
    8000617e:	3c6080e7          	jalr	966(ra) # 80000540 <panic>
    panic("virtio disk kalloc");
    80006182:	00002517          	auipc	a0,0x2
    80006186:	69650513          	addi	a0,a0,1686 # 80008818 <syscalls+0x3c8>
    8000618a:	ffffa097          	auipc	ra,0xffffa
    8000618e:	3b6080e7          	jalr	950(ra) # 80000540 <panic>

0000000080006192 <virtio_disk_rw>:
  return 0;
}

void
virtio_disk_rw(struct buf *b, int write)
{
    80006192:	7119                	addi	sp,sp,-128
    80006194:	fc86                	sd	ra,120(sp)
    80006196:	f8a2                	sd	s0,112(sp)
    80006198:	f4a6                	sd	s1,104(sp)
    8000619a:	f0ca                	sd	s2,96(sp)
    8000619c:	ecce                	sd	s3,88(sp)
    8000619e:	e8d2                	sd	s4,80(sp)
    800061a0:	e4d6                	sd	s5,72(sp)
    800061a2:	e0da                	sd	s6,64(sp)
    800061a4:	fc5e                	sd	s7,56(sp)
    800061a6:	f862                	sd	s8,48(sp)
    800061a8:	f466                	sd	s9,40(sp)
    800061aa:	f06a                	sd	s10,32(sp)
    800061ac:	ec6e                	sd	s11,24(sp)
    800061ae:	0100                	addi	s0,sp,128
    800061b0:	8aaa                	mv	s5,a0
    800061b2:	8c2e                	mv	s8,a1
  uint64 sector = b->blockno * (BSIZE / 512);
    800061b4:	00c52d03          	lw	s10,12(a0)
    800061b8:	001d1d1b          	slliw	s10,s10,0x1
    800061bc:	1d02                	slli	s10,s10,0x20
    800061be:	020d5d13          	srli	s10,s10,0x20

  acquire(&disk.vdisk_lock);
    800061c2:	0001c517          	auipc	a0,0x1c
    800061c6:	dae50513          	addi	a0,a0,-594 # 80021f70 <disk+0x128>
    800061ca:	ffffb097          	auipc	ra,0xffffb
    800061ce:	a0c080e7          	jalr	-1524(ra) # 80000bd6 <acquire>
  for(int i = 0; i < 3; i++){
    800061d2:	4981                	li	s3,0
  for(int i = 0; i < NUM; i++){
    800061d4:	44a1                	li	s1,8
      disk.free[i] = 0;
    800061d6:	0001cb97          	auipc	s7,0x1c
    800061da:	c72b8b93          	addi	s7,s7,-910 # 80021e48 <disk>
  for(int i = 0; i < 3; i++){
    800061de:	4b0d                	li	s6,3
  int idx[3];
  while(1){
    if(alloc3_desc(idx) == 0) {
      break;
    }
    sleep(&disk.free[0], &disk.vdisk_lock);
    800061e0:	0001cc97          	auipc	s9,0x1c
    800061e4:	d90c8c93          	addi	s9,s9,-624 # 80021f70 <disk+0x128>
    800061e8:	a08d                	j	8000624a <virtio_disk_rw+0xb8>
      disk.free[i] = 0;
    800061ea:	00fb8733          	add	a4,s7,a5
    800061ee:	00070c23          	sb	zero,24(a4)
    idx[i] = alloc_desc();
    800061f2:	c19c                	sw	a5,0(a1)
    if(idx[i] < 0){
    800061f4:	0207c563          	bltz	a5,8000621e <virtio_disk_rw+0x8c>
  for(int i = 0; i < 3; i++){
    800061f8:	2905                	addiw	s2,s2,1
    800061fa:	0611                	addi	a2,a2,4 # 1004 <_entry-0x7fffeffc>
    800061fc:	05690c63          	beq	s2,s6,80006254 <virtio_disk_rw+0xc2>
    idx[i] = alloc_desc();
    80006200:	85b2                	mv	a1,a2
  for(int i = 0; i < NUM; i++){
    80006202:	0001c717          	auipc	a4,0x1c
    80006206:	c4670713          	addi	a4,a4,-954 # 80021e48 <disk>
    8000620a:	87ce                	mv	a5,s3
    if(disk.free[i]){
    8000620c:	01874683          	lbu	a3,24(a4)
    80006210:	fee9                	bnez	a3,800061ea <virtio_disk_rw+0x58>
  for(int i = 0; i < NUM; i++){
    80006212:	2785                	addiw	a5,a5,1
    80006214:	0705                	addi	a4,a4,1
    80006216:	fe979be3          	bne	a5,s1,8000620c <virtio_disk_rw+0x7a>
    idx[i] = alloc_desc();
    8000621a:	57fd                	li	a5,-1
    8000621c:	c19c                	sw	a5,0(a1)
      for(int j = 0; j < i; j++)
    8000621e:	01205d63          	blez	s2,80006238 <virtio_disk_rw+0xa6>
    80006222:	8dce                	mv	s11,s3
        free_desc(idx[j]);
    80006224:	000a2503          	lw	a0,0(s4)
    80006228:	00000097          	auipc	ra,0x0
    8000622c:	cfe080e7          	jalr	-770(ra) # 80005f26 <free_desc>
      for(int j = 0; j < i; j++)
    80006230:	2d85                	addiw	s11,s11,1
    80006232:	0a11                	addi	s4,s4,4
    80006234:	ff2d98e3          	bne	s11,s2,80006224 <virtio_disk_rw+0x92>
    sleep(&disk.free[0], &disk.vdisk_lock);
    80006238:	85e6                	mv	a1,s9
    8000623a:	0001c517          	auipc	a0,0x1c
    8000623e:	c2650513          	addi	a0,a0,-986 # 80021e60 <disk+0x18>
    80006242:	ffffc097          	auipc	ra,0xffffc
    80006246:	e80080e7          	jalr	-384(ra) # 800020c2 <sleep>
  for(int i = 0; i < 3; i++){
    8000624a:	f8040a13          	addi	s4,s0,-128
{
    8000624e:	8652                	mv	a2,s4
  for(int i = 0; i < 3; i++){
    80006250:	894e                	mv	s2,s3
    80006252:	b77d                	j	80006200 <virtio_disk_rw+0x6e>
  }

  // format the three descriptors.
  // qemu's virtio-blk.c reads them.

  struct virtio_blk_req *buf0 = &disk.ops[idx[0]];
    80006254:	f8042503          	lw	a0,-128(s0)
    80006258:	00a50713          	addi	a4,a0,10
    8000625c:	0712                	slli	a4,a4,0x4

  if(write)
    8000625e:	0001c797          	auipc	a5,0x1c
    80006262:	bea78793          	addi	a5,a5,-1046 # 80021e48 <disk>
    80006266:	00e786b3          	add	a3,a5,a4
    8000626a:	01803633          	snez	a2,s8
    8000626e:	c690                	sw	a2,8(a3)
    buf0->type = VIRTIO_BLK_T_OUT; // write the disk
  else
    buf0->type = VIRTIO_BLK_T_IN; // read the disk
  buf0->reserved = 0;
    80006270:	0006a623          	sw	zero,12(a3)
  buf0->sector = sector;
    80006274:	01a6b823          	sd	s10,16(a3)

  disk.desc[idx[0]].addr = (uint64) buf0;
    80006278:	f6070613          	addi	a2,a4,-160
    8000627c:	6394                	ld	a3,0(a5)
    8000627e:	96b2                	add	a3,a3,a2
  struct virtio_blk_req *buf0 = &disk.ops[idx[0]];
    80006280:	00870593          	addi	a1,a4,8
    80006284:	95be                	add	a1,a1,a5
  disk.desc[idx[0]].addr = (uint64) buf0;
    80006286:	e28c                	sd	a1,0(a3)
  disk.desc[idx[0]].len = sizeof(struct virtio_blk_req);
    80006288:	0007b803          	ld	a6,0(a5)
    8000628c:	9642                	add	a2,a2,a6
    8000628e:	46c1                	li	a3,16
    80006290:	c614                	sw	a3,8(a2)
  disk.desc[idx[0]].flags = VRING_DESC_F_NEXT;
    80006292:	4585                	li	a1,1
    80006294:	00b61623          	sh	a1,12(a2)
  disk.desc[idx[0]].next = idx[1];
    80006298:	f8442683          	lw	a3,-124(s0)
    8000629c:	00d61723          	sh	a3,14(a2)

  disk.desc[idx[1]].addr = (uint64) b->data;
    800062a0:	0692                	slli	a3,a3,0x4
    800062a2:	9836                	add	a6,a6,a3
    800062a4:	058a8613          	addi	a2,s5,88
    800062a8:	00c83023          	sd	a2,0(a6)
  disk.desc[idx[1]].len = BSIZE;
    800062ac:	0007b803          	ld	a6,0(a5)
    800062b0:	96c2                	add	a3,a3,a6
    800062b2:	40000613          	li	a2,1024
    800062b6:	c690                	sw	a2,8(a3)
  if(write)
    800062b8:	001c3613          	seqz	a2,s8
    800062bc:	0016161b          	slliw	a2,a2,0x1
    disk.desc[idx[1]].flags = 0; // device reads b->data
  else
    disk.desc[idx[1]].flags = VRING_DESC_F_WRITE; // device writes b->data
  disk.desc[idx[1]].flags |= VRING_DESC_F_NEXT;
    800062c0:	00166613          	ori	a2,a2,1
    800062c4:	00c69623          	sh	a2,12(a3)
  disk.desc[idx[1]].next = idx[2];
    800062c8:	f8842603          	lw	a2,-120(s0)
    800062cc:	00c69723          	sh	a2,14(a3)

  disk.info[idx[0]].status = 0xff; // device writes 0 on success
    800062d0:	00250693          	addi	a3,a0,2
    800062d4:	0692                	slli	a3,a3,0x4
    800062d6:	96be                	add	a3,a3,a5
    800062d8:	58fd                	li	a7,-1
    800062da:	01168823          	sb	a7,16(a3)
  disk.desc[idx[2]].addr = (uint64) &disk.info[idx[0]].status;
    800062de:	0612                	slli	a2,a2,0x4
    800062e0:	9832                	add	a6,a6,a2
    800062e2:	f9070713          	addi	a4,a4,-112
    800062e6:	973e                	add	a4,a4,a5
    800062e8:	00e83023          	sd	a4,0(a6)
  disk.desc[idx[2]].len = 1;
    800062ec:	6398                	ld	a4,0(a5)
    800062ee:	9732                	add	a4,a4,a2
    800062f0:	c70c                	sw	a1,8(a4)
  disk.desc[idx[2]].flags = VRING_DESC_F_WRITE; // device writes the status
    800062f2:	4609                	li	a2,2
    800062f4:	00c71623          	sh	a2,12(a4)
  disk.desc[idx[2]].next = 0;
    800062f8:	00071723          	sh	zero,14(a4)

  // record struct buf for virtio_disk_intr().
  b->disk = 1;
    800062fc:	00baa223          	sw	a1,4(s5)
  disk.info[idx[0]].b = b;
    80006300:	0156b423          	sd	s5,8(a3)

  // tell the device the first index in our chain of descriptors.
  disk.avail->ring[disk.avail->idx % NUM] = idx[0];
    80006304:	6794                	ld	a3,8(a5)
    80006306:	0026d703          	lhu	a4,2(a3)
    8000630a:	8b1d                	andi	a4,a4,7
    8000630c:	0706                	slli	a4,a4,0x1
    8000630e:	96ba                	add	a3,a3,a4
    80006310:	00a69223          	sh	a0,4(a3)

  __sync_synchronize();
    80006314:	0ff0000f          	fence

  // tell the device another avail ring entry is available.
  disk.avail->idx += 1; // not % NUM ...
    80006318:	6798                	ld	a4,8(a5)
    8000631a:	00275783          	lhu	a5,2(a4)
    8000631e:	2785                	addiw	a5,a5,1
    80006320:	00f71123          	sh	a5,2(a4)

  __sync_synchronize();
    80006324:	0ff0000f          	fence

  *R(VIRTIO_MMIO_QUEUE_NOTIFY) = 0; // value is queue number
    80006328:	100017b7          	lui	a5,0x10001
    8000632c:	0407a823          	sw	zero,80(a5) # 10001050 <_entry-0x6fffefb0>

  // Wait for virtio_disk_intr() to say request has finished.
  while(b->disk == 1) {
    80006330:	004aa783          	lw	a5,4(s5)
    sleep(b, &disk.vdisk_lock);
    80006334:	0001c917          	auipc	s2,0x1c
    80006338:	c3c90913          	addi	s2,s2,-964 # 80021f70 <disk+0x128>
  while(b->disk == 1) {
    8000633c:	4485                	li	s1,1
    8000633e:	00b79c63          	bne	a5,a1,80006356 <virtio_disk_rw+0x1c4>
    sleep(b, &disk.vdisk_lock);
    80006342:	85ca                	mv	a1,s2
    80006344:	8556                	mv	a0,s5
    80006346:	ffffc097          	auipc	ra,0xffffc
    8000634a:	d7c080e7          	jalr	-644(ra) # 800020c2 <sleep>
  while(b->disk == 1) {
    8000634e:	004aa783          	lw	a5,4(s5)
    80006352:	fe9788e3          	beq	a5,s1,80006342 <virtio_disk_rw+0x1b0>
  }

  disk.info[idx[0]].b = 0;
    80006356:	f8042903          	lw	s2,-128(s0)
    8000635a:	00290713          	addi	a4,s2,2
    8000635e:	0712                	slli	a4,a4,0x4
    80006360:	0001c797          	auipc	a5,0x1c
    80006364:	ae878793          	addi	a5,a5,-1304 # 80021e48 <disk>
    80006368:	97ba                	add	a5,a5,a4
    8000636a:	0007b423          	sd	zero,8(a5)
    int flag = disk.desc[i].flags;
    8000636e:	0001c997          	auipc	s3,0x1c
    80006372:	ada98993          	addi	s3,s3,-1318 # 80021e48 <disk>
    80006376:	00491713          	slli	a4,s2,0x4
    8000637a:	0009b783          	ld	a5,0(s3)
    8000637e:	97ba                	add	a5,a5,a4
    80006380:	00c7d483          	lhu	s1,12(a5)
    int nxt = disk.desc[i].next;
    80006384:	854a                	mv	a0,s2
    80006386:	00e7d903          	lhu	s2,14(a5)
    free_desc(i);
    8000638a:	00000097          	auipc	ra,0x0
    8000638e:	b9c080e7          	jalr	-1124(ra) # 80005f26 <free_desc>
    if(flag & VRING_DESC_F_NEXT)
    80006392:	8885                	andi	s1,s1,1
    80006394:	f0ed                	bnez	s1,80006376 <virtio_disk_rw+0x1e4>
  free_chain(idx[0]);

  release(&disk.vdisk_lock);
    80006396:	0001c517          	auipc	a0,0x1c
    8000639a:	bda50513          	addi	a0,a0,-1062 # 80021f70 <disk+0x128>
    8000639e:	ffffb097          	auipc	ra,0xffffb
    800063a2:	8ec080e7          	jalr	-1812(ra) # 80000c8a <release>
}
    800063a6:	70e6                	ld	ra,120(sp)
    800063a8:	7446                	ld	s0,112(sp)
    800063aa:	74a6                	ld	s1,104(sp)
    800063ac:	7906                	ld	s2,96(sp)
    800063ae:	69e6                	ld	s3,88(sp)
    800063b0:	6a46                	ld	s4,80(sp)
    800063b2:	6aa6                	ld	s5,72(sp)
    800063b4:	6b06                	ld	s6,64(sp)
    800063b6:	7be2                	ld	s7,56(sp)
    800063b8:	7c42                	ld	s8,48(sp)
    800063ba:	7ca2                	ld	s9,40(sp)
    800063bc:	7d02                	ld	s10,32(sp)
    800063be:	6de2                	ld	s11,24(sp)
    800063c0:	6109                	addi	sp,sp,128
    800063c2:	8082                	ret

00000000800063c4 <virtio_disk_intr>:

void
virtio_disk_intr()
{
    800063c4:	1101                	addi	sp,sp,-32
    800063c6:	ec06                	sd	ra,24(sp)
    800063c8:	e822                	sd	s0,16(sp)
    800063ca:	e426                	sd	s1,8(sp)
    800063cc:	1000                	addi	s0,sp,32
  acquire(&disk.vdisk_lock);
    800063ce:	0001c497          	auipc	s1,0x1c
    800063d2:	a7a48493          	addi	s1,s1,-1414 # 80021e48 <disk>
    800063d6:	0001c517          	auipc	a0,0x1c
    800063da:	b9a50513          	addi	a0,a0,-1126 # 80021f70 <disk+0x128>
    800063de:	ffffa097          	auipc	ra,0xffffa
    800063e2:	7f8080e7          	jalr	2040(ra) # 80000bd6 <acquire>
  // we've seen this interrupt, which the following line does.
  // this may race with the device writing new entries to
  // the "used" ring, in which case we may process the new
  // completion entries in this interrupt, and have nothing to do
  // in the next interrupt, which is harmless.
  *R(VIRTIO_MMIO_INTERRUPT_ACK) = *R(VIRTIO_MMIO_INTERRUPT_STATUS) & 0x3;
    800063e6:	10001737          	lui	a4,0x10001
    800063ea:	533c                	lw	a5,96(a4)
    800063ec:	8b8d                	andi	a5,a5,3
    800063ee:	d37c                	sw	a5,100(a4)

  __sync_synchronize();
    800063f0:	0ff0000f          	fence

  // the device increments disk.used->idx when it
  // adds an entry to the used ring.

  while(disk.used_idx != disk.used->idx){
    800063f4:	689c                	ld	a5,16(s1)
    800063f6:	0204d703          	lhu	a4,32(s1)
    800063fa:	0027d783          	lhu	a5,2(a5)
    800063fe:	04f70863          	beq	a4,a5,8000644e <virtio_disk_intr+0x8a>
    __sync_synchronize();
    80006402:	0ff0000f          	fence
    int id = disk.used->ring[disk.used_idx % NUM].id;
    80006406:	6898                	ld	a4,16(s1)
    80006408:	0204d783          	lhu	a5,32(s1)
    8000640c:	8b9d                	andi	a5,a5,7
    8000640e:	078e                	slli	a5,a5,0x3
    80006410:	97ba                	add	a5,a5,a4
    80006412:	43dc                	lw	a5,4(a5)

    if(disk.info[id].status != 0)
    80006414:	00278713          	addi	a4,a5,2
    80006418:	0712                	slli	a4,a4,0x4
    8000641a:	9726                	add	a4,a4,s1
    8000641c:	01074703          	lbu	a4,16(a4) # 10001010 <_entry-0x6fffeff0>
    80006420:	e721                	bnez	a4,80006468 <virtio_disk_intr+0xa4>
      panic("virtio_disk_intr status");

    struct buf *b = disk.info[id].b;
    80006422:	0789                	addi	a5,a5,2
    80006424:	0792                	slli	a5,a5,0x4
    80006426:	97a6                	add	a5,a5,s1
    80006428:	6788                	ld	a0,8(a5)
    b->disk = 0;   // disk is done with buf
    8000642a:	00052223          	sw	zero,4(a0)
    wakeup(b);
    8000642e:	ffffc097          	auipc	ra,0xffffc
    80006432:	cf8080e7          	jalr	-776(ra) # 80002126 <wakeup>

    disk.used_idx += 1;
    80006436:	0204d783          	lhu	a5,32(s1)
    8000643a:	2785                	addiw	a5,a5,1
    8000643c:	17c2                	slli	a5,a5,0x30
    8000643e:	93c1                	srli	a5,a5,0x30
    80006440:	02f49023          	sh	a5,32(s1)
  while(disk.used_idx != disk.used->idx){
    80006444:	6898                	ld	a4,16(s1)
    80006446:	00275703          	lhu	a4,2(a4)
    8000644a:	faf71ce3          	bne	a4,a5,80006402 <virtio_disk_intr+0x3e>
  }

  release(&disk.vdisk_lock);
    8000644e:	0001c517          	auipc	a0,0x1c
    80006452:	b2250513          	addi	a0,a0,-1246 # 80021f70 <disk+0x128>
    80006456:	ffffb097          	auipc	ra,0xffffb
    8000645a:	834080e7          	jalr	-1996(ra) # 80000c8a <release>
}
    8000645e:	60e2                	ld	ra,24(sp)
    80006460:	6442                	ld	s0,16(sp)
    80006462:	64a2                	ld	s1,8(sp)
    80006464:	6105                	addi	sp,sp,32
    80006466:	8082                	ret
      panic("virtio_disk_intr status");
    80006468:	00002517          	auipc	a0,0x2
    8000646c:	3c850513          	addi	a0,a0,968 # 80008830 <syscalls+0x3e0>
    80006470:	ffffa097          	auipc	ra,0xffffa
    80006474:	0d0080e7          	jalr	208(ra) # 80000540 <panic>
	...

0000000080007000 <_trampoline>:
    80007000:	14051573          	csrrw	a0,sscratch,a0
    80007004:	02153423          	sd	ra,40(a0)
    80007008:	02253823          	sd	sp,48(a0)
    8000700c:	02353c23          	sd	gp,56(a0)
    80007010:	04453023          	sd	tp,64(a0)
    80007014:	04553423          	sd	t0,72(a0)
    80007018:	04653823          	sd	t1,80(a0)
    8000701c:	04753c23          	sd	t2,88(a0)
    80007020:	f120                	sd	s0,96(a0)
    80007022:	f524                	sd	s1,104(a0)
    80007024:	fd2c                	sd	a1,120(a0)
    80007026:	e150                	sd	a2,128(a0)
    80007028:	e554                	sd	a3,136(a0)
    8000702a:	e958                	sd	a4,144(a0)
    8000702c:	ed5c                	sd	a5,152(a0)
    8000702e:	0b053023          	sd	a6,160(a0)
    80007032:	0b153423          	sd	a7,168(a0)
    80007036:	0b253823          	sd	s2,176(a0)
    8000703a:	0b353c23          	sd	s3,184(a0)
    8000703e:	0d453023          	sd	s4,192(a0)
    80007042:	0d553423          	sd	s5,200(a0)
    80007046:	0d653823          	sd	s6,208(a0)
    8000704a:	0d753c23          	sd	s7,216(a0)
    8000704e:	0f853023          	sd	s8,224(a0)
    80007052:	0f953423          	sd	s9,232(a0)
    80007056:	0fa53823          	sd	s10,240(a0)
    8000705a:	0fb53c23          	sd	s11,248(a0)
    8000705e:	11c53023          	sd	t3,256(a0)
    80007062:	11d53423          	sd	t4,264(a0)
    80007066:	11e53823          	sd	t5,272(a0)
    8000706a:	11f53c23          	sd	t6,280(a0)
    8000706e:	140022f3          	csrr	t0,sscratch
    80007072:	06553823          	sd	t0,112(a0)
    80007076:	00853103          	ld	sp,8(a0)
    8000707a:	02053203          	ld	tp,32(a0)
    8000707e:	01053283          	ld	t0,16(a0)
    80007082:	00053303          	ld	t1,0(a0)
    80007086:	18031073          	csrw	satp,t1
    8000708a:	12000073          	sfence.vma
    8000708e:	8282                	jr	t0

0000000080007090 <userret>:
    80007090:	18059073          	csrw	satp,a1
    80007094:	12000073          	sfence.vma
    80007098:	07053283          	ld	t0,112(a0)
    8000709c:	14029073          	csrw	sscratch,t0
    800070a0:	02853083          	ld	ra,40(a0)
    800070a4:	03053103          	ld	sp,48(a0)
    800070a8:	03853183          	ld	gp,56(a0)
    800070ac:	04053203          	ld	tp,64(a0)
    800070b0:	04853283          	ld	t0,72(a0)
    800070b4:	05053303          	ld	t1,80(a0)
    800070b8:	05853383          	ld	t2,88(a0)
    800070bc:	7120                	ld	s0,96(a0)
    800070be:	7524                	ld	s1,104(a0)
    800070c0:	7d2c                	ld	a1,120(a0)
    800070c2:	6150                	ld	a2,128(a0)
    800070c4:	6554                	ld	a3,136(a0)
    800070c6:	6958                	ld	a4,144(a0)
    800070c8:	6d5c                	ld	a5,152(a0)
    800070ca:	0a053803          	ld	a6,160(a0)
    800070ce:	0a853883          	ld	a7,168(a0)
    800070d2:	0b053903          	ld	s2,176(a0)
    800070d6:	0b853983          	ld	s3,184(a0)
    800070da:	0c053a03          	ld	s4,192(a0)
    800070de:	0c853a83          	ld	s5,200(a0)
    800070e2:	0d053b03          	ld	s6,208(a0)
    800070e6:	0d853b83          	ld	s7,216(a0)
    800070ea:	0e053c03          	ld	s8,224(a0)
    800070ee:	0e853c83          	ld	s9,232(a0)
    800070f2:	0f053d03          	ld	s10,240(a0)
    800070f6:	0f853d83          	ld	s11,248(a0)
    800070fa:	10053e03          	ld	t3,256(a0)
    800070fe:	10853e83          	ld	t4,264(a0)
    80007102:	11053f03          	ld	t5,272(a0)
    80007106:	11853f83          	ld	t6,280(a0)
    8000710a:	14051573          	csrrw	a0,sscratch,a0
    8000710e:	10200073          	sret
	...
