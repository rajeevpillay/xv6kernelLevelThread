
user/_rm:     file format elf64-littleriscv


Disassembly of section .text:

0000000000000000 <main>:
#include "kernel/stat.h"
#include "user/user.h"

int
main(int argc, char *argv[])
{
   0:	7179                	addi	sp,sp,-48
   2:	f406                	sd	ra,40(sp)
   4:	f022                	sd	s0,32(sp)
   6:	ec26                	sd	s1,24(sp)
   8:	e84a                	sd	s2,16(sp)
   a:	e44e                	sd	s3,8(sp)
   c:	1800                	addi	s0,sp,48
  int i;

  if(argc < 2){
   e:	4785                	li	a5,1
  10:	02a7d763          	bge	a5,a0,3e <main+0x3e>
  14:	00858493          	addi	s1,a1,8
  18:	ffe5091b          	addiw	s2,a0,-2
  1c:	02091793          	slli	a5,s2,0x20
  20:	01d7d913          	srli	s2,a5,0x1d
  24:	05c1                	addi	a1,a1,16
  26:	992e                	add	s2,s2,a1
    fprintf(2, "Usage: rm files...\n");
    exit(1);
  }

  for(i = 1; i < argc; i++){
    if(unlink(argv[i]) < 0){
  28:	6088                	ld	a0,0(s1)
  2a:	00000097          	auipc	ra,0x0
  2e:	324080e7          	jalr	804(ra) # 34e <unlink>
  32:	02054463          	bltz	a0,5a <main+0x5a>
  for(i = 1; i < argc; i++){
  36:	04a1                	addi	s1,s1,8
  38:	ff2498e3          	bne	s1,s2,28 <main+0x28>
  3c:	a80d                	j	6e <main+0x6e>
    fprintf(2, "Usage: rm files...\n");
  3e:	00001597          	auipc	a1,0x1
  42:	87258593          	addi	a1,a1,-1934 # 8b0 <lock_release+0x24>
  46:	4509                	li	a0,2
  48:	00000097          	auipc	ra,0x0
  4c:	60a080e7          	jalr	1546(ra) # 652 <fprintf>
    exit(1);
  50:	4505                	li	a0,1
  52:	00000097          	auipc	ra,0x0
  56:	2ac080e7          	jalr	684(ra) # 2fe <exit>
      fprintf(2, "rm: %s failed to delete\n", argv[i]);
  5a:	6090                	ld	a2,0(s1)
  5c:	00001597          	auipc	a1,0x1
  60:	86c58593          	addi	a1,a1,-1940 # 8c8 <lock_release+0x3c>
  64:	4509                	li	a0,2
  66:	00000097          	auipc	ra,0x0
  6a:	5ec080e7          	jalr	1516(ra) # 652 <fprintf>
      break;
    }
  }

  exit(0);
  6e:	4501                	li	a0,0
  70:	00000097          	auipc	ra,0x0
  74:	28e080e7          	jalr	654(ra) # 2fe <exit>

0000000000000078 <_main>:
//
// wrapper so that it's OK if main() does not call exit().
//
void
_main()
{
  78:	1141                	addi	sp,sp,-16
  7a:	e406                	sd	ra,8(sp)
  7c:	e022                	sd	s0,0(sp)
  7e:	0800                	addi	s0,sp,16
  extern int main();
  main();
  80:	00000097          	auipc	ra,0x0
  84:	f80080e7          	jalr	-128(ra) # 0 <main>
  exit(0);
  88:	4501                	li	a0,0
  8a:	00000097          	auipc	ra,0x0
  8e:	274080e7          	jalr	628(ra) # 2fe <exit>

0000000000000092 <strcpy>:
}

char*
strcpy(char *s, const char *t)
{
  92:	1141                	addi	sp,sp,-16
  94:	e422                	sd	s0,8(sp)
  96:	0800                	addi	s0,sp,16
  char *os;

  os = s;
  while((*s++ = *t++) != 0)
  98:	87aa                	mv	a5,a0
  9a:	0585                	addi	a1,a1,1
  9c:	0785                	addi	a5,a5,1
  9e:	fff5c703          	lbu	a4,-1(a1)
  a2:	fee78fa3          	sb	a4,-1(a5)
  a6:	fb75                	bnez	a4,9a <strcpy+0x8>
    ;
  return os;
}
  a8:	6422                	ld	s0,8(sp)
  aa:	0141                	addi	sp,sp,16
  ac:	8082                	ret

00000000000000ae <strcmp>:

int
strcmp(const char *p, const char *q)
{
  ae:	1141                	addi	sp,sp,-16
  b0:	e422                	sd	s0,8(sp)
  b2:	0800                	addi	s0,sp,16
  while(*p && *p == *q)
  b4:	00054783          	lbu	a5,0(a0)
  b8:	cb91                	beqz	a5,cc <strcmp+0x1e>
  ba:	0005c703          	lbu	a4,0(a1)
  be:	00f71763          	bne	a4,a5,cc <strcmp+0x1e>
    p++, q++;
  c2:	0505                	addi	a0,a0,1
  c4:	0585                	addi	a1,a1,1
  while(*p && *p == *q)
  c6:	00054783          	lbu	a5,0(a0)
  ca:	fbe5                	bnez	a5,ba <strcmp+0xc>
  return (uchar)*p - (uchar)*q;
  cc:	0005c503          	lbu	a0,0(a1)
}
  d0:	40a7853b          	subw	a0,a5,a0
  d4:	6422                	ld	s0,8(sp)
  d6:	0141                	addi	sp,sp,16
  d8:	8082                	ret

00000000000000da <strlen>:

uint
strlen(const char *s)
{
  da:	1141                	addi	sp,sp,-16
  dc:	e422                	sd	s0,8(sp)
  de:	0800                	addi	s0,sp,16
  int n;

  for(n = 0; s[n]; n++)
  e0:	00054783          	lbu	a5,0(a0)
  e4:	cf91                	beqz	a5,100 <strlen+0x26>
  e6:	0505                	addi	a0,a0,1
  e8:	87aa                	mv	a5,a0
  ea:	4685                	li	a3,1
  ec:	9e89                	subw	a3,a3,a0
  ee:	00f6853b          	addw	a0,a3,a5
  f2:	0785                	addi	a5,a5,1
  f4:	fff7c703          	lbu	a4,-1(a5)
  f8:	fb7d                	bnez	a4,ee <strlen+0x14>
    ;
  return n;
}
  fa:	6422                	ld	s0,8(sp)
  fc:	0141                	addi	sp,sp,16
  fe:	8082                	ret
  for(n = 0; s[n]; n++)
 100:	4501                	li	a0,0
 102:	bfe5                	j	fa <strlen+0x20>

0000000000000104 <memset>:

void*
memset(void *dst, int c, uint n)
{
 104:	1141                	addi	sp,sp,-16
 106:	e422                	sd	s0,8(sp)
 108:	0800                	addi	s0,sp,16
  char *cdst = (char *) dst;
  int i;
  for(i = 0; i < n; i++){
 10a:	ca19                	beqz	a2,120 <memset+0x1c>
 10c:	87aa                	mv	a5,a0
 10e:	1602                	slli	a2,a2,0x20
 110:	9201                	srli	a2,a2,0x20
 112:	00a60733          	add	a4,a2,a0
    cdst[i] = c;
 116:	00b78023          	sb	a1,0(a5)
  for(i = 0; i < n; i++){
 11a:	0785                	addi	a5,a5,1
 11c:	fee79de3          	bne	a5,a4,116 <memset+0x12>
  }
  return dst;
}
 120:	6422                	ld	s0,8(sp)
 122:	0141                	addi	sp,sp,16
 124:	8082                	ret

0000000000000126 <strchr>:

char*
strchr(const char *s, char c)
{
 126:	1141                	addi	sp,sp,-16
 128:	e422                	sd	s0,8(sp)
 12a:	0800                	addi	s0,sp,16
  for(; *s; s++)
 12c:	00054783          	lbu	a5,0(a0)
 130:	cb99                	beqz	a5,146 <strchr+0x20>
    if(*s == c)
 132:	00f58763          	beq	a1,a5,140 <strchr+0x1a>
  for(; *s; s++)
 136:	0505                	addi	a0,a0,1
 138:	00054783          	lbu	a5,0(a0)
 13c:	fbfd                	bnez	a5,132 <strchr+0xc>
      return (char*)s;
  return 0;
 13e:	4501                	li	a0,0
}
 140:	6422                	ld	s0,8(sp)
 142:	0141                	addi	sp,sp,16
 144:	8082                	ret
  return 0;
 146:	4501                	li	a0,0
 148:	bfe5                	j	140 <strchr+0x1a>

000000000000014a <gets>:

char*
gets(char *buf, int max)
{
 14a:	711d                	addi	sp,sp,-96
 14c:	ec86                	sd	ra,88(sp)
 14e:	e8a2                	sd	s0,80(sp)
 150:	e4a6                	sd	s1,72(sp)
 152:	e0ca                	sd	s2,64(sp)
 154:	fc4e                	sd	s3,56(sp)
 156:	f852                	sd	s4,48(sp)
 158:	f456                	sd	s5,40(sp)
 15a:	f05a                	sd	s6,32(sp)
 15c:	ec5e                	sd	s7,24(sp)
 15e:	1080                	addi	s0,sp,96
 160:	8baa                	mv	s7,a0
 162:	8a2e                	mv	s4,a1
  int i, cc;
  char c;

  for(i=0; i+1 < max; ){
 164:	892a                	mv	s2,a0
 166:	4481                	li	s1,0
    cc = read(0, &c, 1);
    if(cc < 1)
      break;
    buf[i++] = c;
    if(c == '\n' || c == '\r')
 168:	4aa9                	li	s5,10
 16a:	4b35                	li	s6,13
  for(i=0; i+1 < max; ){
 16c:	89a6                	mv	s3,s1
 16e:	2485                	addiw	s1,s1,1
 170:	0344d863          	bge	s1,s4,1a0 <gets+0x56>
    cc = read(0, &c, 1);
 174:	4605                	li	a2,1
 176:	faf40593          	addi	a1,s0,-81
 17a:	4501                	li	a0,0
 17c:	00000097          	auipc	ra,0x0
 180:	19a080e7          	jalr	410(ra) # 316 <read>
    if(cc < 1)
 184:	00a05e63          	blez	a0,1a0 <gets+0x56>
    buf[i++] = c;
 188:	faf44783          	lbu	a5,-81(s0)
 18c:	00f90023          	sb	a5,0(s2)
    if(c == '\n' || c == '\r')
 190:	01578763          	beq	a5,s5,19e <gets+0x54>
 194:	0905                	addi	s2,s2,1
 196:	fd679be3          	bne	a5,s6,16c <gets+0x22>
  for(i=0; i+1 < max; ){
 19a:	89a6                	mv	s3,s1
 19c:	a011                	j	1a0 <gets+0x56>
 19e:	89a6                	mv	s3,s1
      break;
  }
  buf[i] = '\0';
 1a0:	99de                	add	s3,s3,s7
 1a2:	00098023          	sb	zero,0(s3)
  return buf;
}
 1a6:	855e                	mv	a0,s7
 1a8:	60e6                	ld	ra,88(sp)
 1aa:	6446                	ld	s0,80(sp)
 1ac:	64a6                	ld	s1,72(sp)
 1ae:	6906                	ld	s2,64(sp)
 1b0:	79e2                	ld	s3,56(sp)
 1b2:	7a42                	ld	s4,48(sp)
 1b4:	7aa2                	ld	s5,40(sp)
 1b6:	7b02                	ld	s6,32(sp)
 1b8:	6be2                	ld	s7,24(sp)
 1ba:	6125                	addi	sp,sp,96
 1bc:	8082                	ret

00000000000001be <stat>:

int
stat(const char *n, struct stat *st)
{
 1be:	1101                	addi	sp,sp,-32
 1c0:	ec06                	sd	ra,24(sp)
 1c2:	e822                	sd	s0,16(sp)
 1c4:	e426                	sd	s1,8(sp)
 1c6:	e04a                	sd	s2,0(sp)
 1c8:	1000                	addi	s0,sp,32
 1ca:	892e                	mv	s2,a1
  int fd;
  int r;

  fd = open(n, O_RDONLY);
 1cc:	4581                	li	a1,0
 1ce:	00000097          	auipc	ra,0x0
 1d2:	170080e7          	jalr	368(ra) # 33e <open>
  if(fd < 0)
 1d6:	02054563          	bltz	a0,200 <stat+0x42>
 1da:	84aa                	mv	s1,a0
    return -1;
  r = fstat(fd, st);
 1dc:	85ca                	mv	a1,s2
 1de:	00000097          	auipc	ra,0x0
 1e2:	178080e7          	jalr	376(ra) # 356 <fstat>
 1e6:	892a                	mv	s2,a0
  close(fd);
 1e8:	8526                	mv	a0,s1
 1ea:	00000097          	auipc	ra,0x0
 1ee:	13c080e7          	jalr	316(ra) # 326 <close>
  return r;
}
 1f2:	854a                	mv	a0,s2
 1f4:	60e2                	ld	ra,24(sp)
 1f6:	6442                	ld	s0,16(sp)
 1f8:	64a2                	ld	s1,8(sp)
 1fa:	6902                	ld	s2,0(sp)
 1fc:	6105                	addi	sp,sp,32
 1fe:	8082                	ret
    return -1;
 200:	597d                	li	s2,-1
 202:	bfc5                	j	1f2 <stat+0x34>

0000000000000204 <atoi>:

int
atoi(const char *s)
{
 204:	1141                	addi	sp,sp,-16
 206:	e422                	sd	s0,8(sp)
 208:	0800                	addi	s0,sp,16
  int n;

  n = 0;
  while('0' <= *s && *s <= '9')
 20a:	00054683          	lbu	a3,0(a0)
 20e:	fd06879b          	addiw	a5,a3,-48
 212:	0ff7f793          	zext.b	a5,a5
 216:	4625                	li	a2,9
 218:	02f66863          	bltu	a2,a5,248 <atoi+0x44>
 21c:	872a                	mv	a4,a0
  n = 0;
 21e:	4501                	li	a0,0
    n = n*10 + *s++ - '0';
 220:	0705                	addi	a4,a4,1
 222:	0025179b          	slliw	a5,a0,0x2
 226:	9fa9                	addw	a5,a5,a0
 228:	0017979b          	slliw	a5,a5,0x1
 22c:	9fb5                	addw	a5,a5,a3
 22e:	fd07851b          	addiw	a0,a5,-48
  while('0' <= *s && *s <= '9')
 232:	00074683          	lbu	a3,0(a4)
 236:	fd06879b          	addiw	a5,a3,-48
 23a:	0ff7f793          	zext.b	a5,a5
 23e:	fef671e3          	bgeu	a2,a5,220 <atoi+0x1c>
  return n;
}
 242:	6422                	ld	s0,8(sp)
 244:	0141                	addi	sp,sp,16
 246:	8082                	ret
  n = 0;
 248:	4501                	li	a0,0
 24a:	bfe5                	j	242 <atoi+0x3e>

000000000000024c <memmove>:

void*
memmove(void *vdst, const void *vsrc, int n)
{
 24c:	1141                	addi	sp,sp,-16
 24e:	e422                	sd	s0,8(sp)
 250:	0800                	addi	s0,sp,16
  char *dst;
  const char *src;

  dst = vdst;
  src = vsrc;
  if (src > dst) {
 252:	02b57463          	bgeu	a0,a1,27a <memmove+0x2e>
    while(n-- > 0)
 256:	00c05f63          	blez	a2,274 <memmove+0x28>
 25a:	1602                	slli	a2,a2,0x20
 25c:	9201                	srli	a2,a2,0x20
 25e:	00c507b3          	add	a5,a0,a2
  dst = vdst;
 262:	872a                	mv	a4,a0
      *dst++ = *src++;
 264:	0585                	addi	a1,a1,1
 266:	0705                	addi	a4,a4,1
 268:	fff5c683          	lbu	a3,-1(a1)
 26c:	fed70fa3          	sb	a3,-1(a4)
    while(n-- > 0)
 270:	fee79ae3          	bne	a5,a4,264 <memmove+0x18>
    src += n;
    while(n-- > 0)
      *--dst = *--src;
  }
  return vdst;
}
 274:	6422                	ld	s0,8(sp)
 276:	0141                	addi	sp,sp,16
 278:	8082                	ret
    dst += n;
 27a:	00c50733          	add	a4,a0,a2
    src += n;
 27e:	95b2                	add	a1,a1,a2
    while(n-- > 0)
 280:	fec05ae3          	blez	a2,274 <memmove+0x28>
 284:	fff6079b          	addiw	a5,a2,-1
 288:	1782                	slli	a5,a5,0x20
 28a:	9381                	srli	a5,a5,0x20
 28c:	fff7c793          	not	a5,a5
 290:	97ba                	add	a5,a5,a4
      *--dst = *--src;
 292:	15fd                	addi	a1,a1,-1
 294:	177d                	addi	a4,a4,-1
 296:	0005c683          	lbu	a3,0(a1)
 29a:	00d70023          	sb	a3,0(a4)
    while(n-- > 0)
 29e:	fee79ae3          	bne	a5,a4,292 <memmove+0x46>
 2a2:	bfc9                	j	274 <memmove+0x28>

00000000000002a4 <memcmp>:

int
memcmp(const void *s1, const void *s2, uint n)
{
 2a4:	1141                	addi	sp,sp,-16
 2a6:	e422                	sd	s0,8(sp)
 2a8:	0800                	addi	s0,sp,16
  const char *p1 = s1, *p2 = s2;
  while (n-- > 0) {
 2aa:	ca05                	beqz	a2,2da <memcmp+0x36>
 2ac:	fff6069b          	addiw	a3,a2,-1
 2b0:	1682                	slli	a3,a3,0x20
 2b2:	9281                	srli	a3,a3,0x20
 2b4:	0685                	addi	a3,a3,1
 2b6:	96aa                	add	a3,a3,a0
    if (*p1 != *p2) {
 2b8:	00054783          	lbu	a5,0(a0)
 2bc:	0005c703          	lbu	a4,0(a1)
 2c0:	00e79863          	bne	a5,a4,2d0 <memcmp+0x2c>
      return *p1 - *p2;
    }
    p1++;
 2c4:	0505                	addi	a0,a0,1
    p2++;
 2c6:	0585                	addi	a1,a1,1
  while (n-- > 0) {
 2c8:	fed518e3          	bne	a0,a3,2b8 <memcmp+0x14>
  }
  return 0;
 2cc:	4501                	li	a0,0
 2ce:	a019                	j	2d4 <memcmp+0x30>
      return *p1 - *p2;
 2d0:	40e7853b          	subw	a0,a5,a4
}
 2d4:	6422                	ld	s0,8(sp)
 2d6:	0141                	addi	sp,sp,16
 2d8:	8082                	ret
  return 0;
 2da:	4501                	li	a0,0
 2dc:	bfe5                	j	2d4 <memcmp+0x30>

00000000000002de <memcpy>:

void *
memcpy(void *dst, const void *src, uint n)
{
 2de:	1141                	addi	sp,sp,-16
 2e0:	e406                	sd	ra,8(sp)
 2e2:	e022                	sd	s0,0(sp)
 2e4:	0800                	addi	s0,sp,16
  return memmove(dst, src, n);
 2e6:	00000097          	auipc	ra,0x0
 2ea:	f66080e7          	jalr	-154(ra) # 24c <memmove>
}
 2ee:	60a2                	ld	ra,8(sp)
 2f0:	6402                	ld	s0,0(sp)
 2f2:	0141                	addi	sp,sp,16
 2f4:	8082                	ret

00000000000002f6 <fork>:
# generated by usys.pl - do not edit
#include "kernel/syscall.h"
.global fork
fork:
 li a7, SYS_fork
 2f6:	4885                	li	a7,1
 ecall
 2f8:	00000073          	ecall
 ret
 2fc:	8082                	ret

00000000000002fe <exit>:
.global exit
exit:
 li a7, SYS_exit
 2fe:	4889                	li	a7,2
 ecall
 300:	00000073          	ecall
 ret
 304:	8082                	ret

0000000000000306 <wait>:
.global wait
wait:
 li a7, SYS_wait
 306:	488d                	li	a7,3
 ecall
 308:	00000073          	ecall
 ret
 30c:	8082                	ret

000000000000030e <pipe>:
.global pipe
pipe:
 li a7, SYS_pipe
 30e:	4891                	li	a7,4
 ecall
 310:	00000073          	ecall
 ret
 314:	8082                	ret

0000000000000316 <read>:
.global read
read:
 li a7, SYS_read
 316:	4895                	li	a7,5
 ecall
 318:	00000073          	ecall
 ret
 31c:	8082                	ret

000000000000031e <write>:
.global write
write:
 li a7, SYS_write
 31e:	48c1                	li	a7,16
 ecall
 320:	00000073          	ecall
 ret
 324:	8082                	ret

0000000000000326 <close>:
.global close
close:
 li a7, SYS_close
 326:	48d5                	li	a7,21
 ecall
 328:	00000073          	ecall
 ret
 32c:	8082                	ret

000000000000032e <kill>:
.global kill
kill:
 li a7, SYS_kill
 32e:	4899                	li	a7,6
 ecall
 330:	00000073          	ecall
 ret
 334:	8082                	ret

0000000000000336 <exec>:
.global exec
exec:
 li a7, SYS_exec
 336:	489d                	li	a7,7
 ecall
 338:	00000073          	ecall
 ret
 33c:	8082                	ret

000000000000033e <open>:
.global open
open:
 li a7, SYS_open
 33e:	48bd                	li	a7,15
 ecall
 340:	00000073          	ecall
 ret
 344:	8082                	ret

0000000000000346 <mknod>:
.global mknod
mknod:
 li a7, SYS_mknod
 346:	48c5                	li	a7,17
 ecall
 348:	00000073          	ecall
 ret
 34c:	8082                	ret

000000000000034e <unlink>:
.global unlink
unlink:
 li a7, SYS_unlink
 34e:	48c9                	li	a7,18
 ecall
 350:	00000073          	ecall
 ret
 354:	8082                	ret

0000000000000356 <fstat>:
.global fstat
fstat:
 li a7, SYS_fstat
 356:	48a1                	li	a7,8
 ecall
 358:	00000073          	ecall
 ret
 35c:	8082                	ret

000000000000035e <link>:
.global link
link:
 li a7, SYS_link
 35e:	48cd                	li	a7,19
 ecall
 360:	00000073          	ecall
 ret
 364:	8082                	ret

0000000000000366 <mkdir>:
.global mkdir
mkdir:
 li a7, SYS_mkdir
 366:	48d1                	li	a7,20
 ecall
 368:	00000073          	ecall
 ret
 36c:	8082                	ret

000000000000036e <chdir>:
.global chdir
chdir:
 li a7, SYS_chdir
 36e:	48a5                	li	a7,9
 ecall
 370:	00000073          	ecall
 ret
 374:	8082                	ret

0000000000000376 <dup>:
.global dup
dup:
 li a7, SYS_dup
 376:	48a9                	li	a7,10
 ecall
 378:	00000073          	ecall
 ret
 37c:	8082                	ret

000000000000037e <getpid>:
.global getpid
getpid:
 li a7, SYS_getpid
 37e:	48ad                	li	a7,11
 ecall
 380:	00000073          	ecall
 ret
 384:	8082                	ret

0000000000000386 <sbrk>:
.global sbrk
sbrk:
 li a7, SYS_sbrk
 386:	48b1                	li	a7,12
 ecall
 388:	00000073          	ecall
 ret
 38c:	8082                	ret

000000000000038e <sleep>:
.global sleep
sleep:
 li a7, SYS_sleep
 38e:	48b5                	li	a7,13
 ecall
 390:	00000073          	ecall
 ret
 394:	8082                	ret

0000000000000396 <uptime>:
.global uptime
uptime:
 li a7, SYS_uptime
 396:	48b9                	li	a7,14
 ecall
 398:	00000073          	ecall
 ret
 39c:	8082                	ret

000000000000039e <clone>:
.global clone
clone:
 li a7, SYS_clone
 39e:	48d9                	li	a7,22
 ecall
 3a0:	00000073          	ecall
 ret
 3a4:	8082                	ret

00000000000003a6 <putc>:

static char digits[] = "0123456789ABCDEF";

static void
putc(int fd, char c)
{
 3a6:	1101                	addi	sp,sp,-32
 3a8:	ec06                	sd	ra,24(sp)
 3aa:	e822                	sd	s0,16(sp)
 3ac:	1000                	addi	s0,sp,32
 3ae:	feb407a3          	sb	a1,-17(s0)
  write(fd, &c, 1);
 3b2:	4605                	li	a2,1
 3b4:	fef40593          	addi	a1,s0,-17
 3b8:	00000097          	auipc	ra,0x0
 3bc:	f66080e7          	jalr	-154(ra) # 31e <write>
}
 3c0:	60e2                	ld	ra,24(sp)
 3c2:	6442                	ld	s0,16(sp)
 3c4:	6105                	addi	sp,sp,32
 3c6:	8082                	ret

00000000000003c8 <printint>:

static void
printint(int fd, int xx, int base, int sgn)
{
 3c8:	7139                	addi	sp,sp,-64
 3ca:	fc06                	sd	ra,56(sp)
 3cc:	f822                	sd	s0,48(sp)
 3ce:	f426                	sd	s1,40(sp)
 3d0:	f04a                	sd	s2,32(sp)
 3d2:	ec4e                	sd	s3,24(sp)
 3d4:	0080                	addi	s0,sp,64
 3d6:	84aa                	mv	s1,a0
  char buf[16];
  int i, neg;
  uint x;

  neg = 0;
  if(sgn && xx < 0){
 3d8:	c299                	beqz	a3,3de <printint+0x16>
 3da:	0805c963          	bltz	a1,46c <printint+0xa4>
    neg = 1;
    x = -xx;
  } else {
    x = xx;
 3de:	2581                	sext.w	a1,a1
  neg = 0;
 3e0:	4881                	li	a7,0
 3e2:	fc040693          	addi	a3,s0,-64
  }

  i = 0;
 3e6:	4701                	li	a4,0
  do{
    buf[i++] = digits[x % base];
 3e8:	2601                	sext.w	a2,a2
 3ea:	00000517          	auipc	a0,0x0
 3ee:	55e50513          	addi	a0,a0,1374 # 948 <digits>
 3f2:	883a                	mv	a6,a4
 3f4:	2705                	addiw	a4,a4,1
 3f6:	02c5f7bb          	remuw	a5,a1,a2
 3fa:	1782                	slli	a5,a5,0x20
 3fc:	9381                	srli	a5,a5,0x20
 3fe:	97aa                	add	a5,a5,a0
 400:	0007c783          	lbu	a5,0(a5)
 404:	00f68023          	sb	a5,0(a3)
  }while((x /= base) != 0);
 408:	0005879b          	sext.w	a5,a1
 40c:	02c5d5bb          	divuw	a1,a1,a2
 410:	0685                	addi	a3,a3,1
 412:	fec7f0e3          	bgeu	a5,a2,3f2 <printint+0x2a>
  if(neg)
 416:	00088c63          	beqz	a7,42e <printint+0x66>
    buf[i++] = '-';
 41a:	fd070793          	addi	a5,a4,-48
 41e:	00878733          	add	a4,a5,s0
 422:	02d00793          	li	a5,45
 426:	fef70823          	sb	a5,-16(a4)
 42a:	0028071b          	addiw	a4,a6,2

  while(--i >= 0)
 42e:	02e05863          	blez	a4,45e <printint+0x96>
 432:	fc040793          	addi	a5,s0,-64
 436:	00e78933          	add	s2,a5,a4
 43a:	fff78993          	addi	s3,a5,-1
 43e:	99ba                	add	s3,s3,a4
 440:	377d                	addiw	a4,a4,-1
 442:	1702                	slli	a4,a4,0x20
 444:	9301                	srli	a4,a4,0x20
 446:	40e989b3          	sub	s3,s3,a4
    putc(fd, buf[i]);
 44a:	fff94583          	lbu	a1,-1(s2)
 44e:	8526                	mv	a0,s1
 450:	00000097          	auipc	ra,0x0
 454:	f56080e7          	jalr	-170(ra) # 3a6 <putc>
  while(--i >= 0)
 458:	197d                	addi	s2,s2,-1
 45a:	ff3918e3          	bne	s2,s3,44a <printint+0x82>
}
 45e:	70e2                	ld	ra,56(sp)
 460:	7442                	ld	s0,48(sp)
 462:	74a2                	ld	s1,40(sp)
 464:	7902                	ld	s2,32(sp)
 466:	69e2                	ld	s3,24(sp)
 468:	6121                	addi	sp,sp,64
 46a:	8082                	ret
    x = -xx;
 46c:	40b005bb          	negw	a1,a1
    neg = 1;
 470:	4885                	li	a7,1
    x = -xx;
 472:	bf85                	j	3e2 <printint+0x1a>

0000000000000474 <vprintf>:
}

// Print to the given fd. Only understands %d, %x, %p, %s.
void
vprintf(int fd, const char *fmt, va_list ap)
{
 474:	7119                	addi	sp,sp,-128
 476:	fc86                	sd	ra,120(sp)
 478:	f8a2                	sd	s0,112(sp)
 47a:	f4a6                	sd	s1,104(sp)
 47c:	f0ca                	sd	s2,96(sp)
 47e:	ecce                	sd	s3,88(sp)
 480:	e8d2                	sd	s4,80(sp)
 482:	e4d6                	sd	s5,72(sp)
 484:	e0da                	sd	s6,64(sp)
 486:	fc5e                	sd	s7,56(sp)
 488:	f862                	sd	s8,48(sp)
 48a:	f466                	sd	s9,40(sp)
 48c:	f06a                	sd	s10,32(sp)
 48e:	ec6e                	sd	s11,24(sp)
 490:	0100                	addi	s0,sp,128
  char *s;
  int c, i, state;

  state = 0;
  for(i = 0; fmt[i]; i++){
 492:	0005c903          	lbu	s2,0(a1)
 496:	18090f63          	beqz	s2,634 <vprintf+0x1c0>
 49a:	8aaa                	mv	s5,a0
 49c:	8b32                	mv	s6,a2
 49e:	00158493          	addi	s1,a1,1
  state = 0;
 4a2:	4981                	li	s3,0
      if(c == '%'){
        state = '%';
      } else {
        putc(fd, c);
      }
    } else if(state == '%'){
 4a4:	02500a13          	li	s4,37
 4a8:	4c55                	li	s8,21
 4aa:	00000c97          	auipc	s9,0x0
 4ae:	446c8c93          	addi	s9,s9,1094 # 8f0 <lock_release+0x64>
        printptr(fd, va_arg(ap, uint64));
      } else if(c == 's'){
        s = va_arg(ap, char*);
        if(s == 0)
          s = "(null)";
        while(*s != 0){
 4b2:	02800d93          	li	s11,40
  putc(fd, 'x');
 4b6:	4d41                	li	s10,16
    putc(fd, digits[x >> (sizeof(uint64) * 8 - 4)]);
 4b8:	00000b97          	auipc	s7,0x0
 4bc:	490b8b93          	addi	s7,s7,1168 # 948 <digits>
 4c0:	a839                	j	4de <vprintf+0x6a>
        putc(fd, c);
 4c2:	85ca                	mv	a1,s2
 4c4:	8556                	mv	a0,s5
 4c6:	00000097          	auipc	ra,0x0
 4ca:	ee0080e7          	jalr	-288(ra) # 3a6 <putc>
 4ce:	a019                	j	4d4 <vprintf+0x60>
    } else if(state == '%'){
 4d0:	01498d63          	beq	s3,s4,4ea <vprintf+0x76>
  for(i = 0; fmt[i]; i++){
 4d4:	0485                	addi	s1,s1,1
 4d6:	fff4c903          	lbu	s2,-1(s1)
 4da:	14090d63          	beqz	s2,634 <vprintf+0x1c0>
    if(state == 0){
 4de:	fe0999e3          	bnez	s3,4d0 <vprintf+0x5c>
      if(c == '%'){
 4e2:	ff4910e3          	bne	s2,s4,4c2 <vprintf+0x4e>
        state = '%';
 4e6:	89d2                	mv	s3,s4
 4e8:	b7f5                	j	4d4 <vprintf+0x60>
      if(c == 'd'){
 4ea:	11490c63          	beq	s2,s4,602 <vprintf+0x18e>
 4ee:	f9d9079b          	addiw	a5,s2,-99
 4f2:	0ff7f793          	zext.b	a5,a5
 4f6:	10fc6e63          	bltu	s8,a5,612 <vprintf+0x19e>
 4fa:	f9d9079b          	addiw	a5,s2,-99
 4fe:	0ff7f713          	zext.b	a4,a5
 502:	10ec6863          	bltu	s8,a4,612 <vprintf+0x19e>
 506:	00271793          	slli	a5,a4,0x2
 50a:	97e6                	add	a5,a5,s9
 50c:	439c                	lw	a5,0(a5)
 50e:	97e6                	add	a5,a5,s9
 510:	8782                	jr	a5
        printint(fd, va_arg(ap, int), 10, 1);
 512:	008b0913          	addi	s2,s6,8
 516:	4685                	li	a3,1
 518:	4629                	li	a2,10
 51a:	000b2583          	lw	a1,0(s6)
 51e:	8556                	mv	a0,s5
 520:	00000097          	auipc	ra,0x0
 524:	ea8080e7          	jalr	-344(ra) # 3c8 <printint>
 528:	8b4a                	mv	s6,s2
      } else {
        // Unknown % sequence.  Print it to draw attention.
        putc(fd, '%');
        putc(fd, c);
      }
      state = 0;
 52a:	4981                	li	s3,0
 52c:	b765                	j	4d4 <vprintf+0x60>
        printint(fd, va_arg(ap, uint64), 10, 0);
 52e:	008b0913          	addi	s2,s6,8
 532:	4681                	li	a3,0
 534:	4629                	li	a2,10
 536:	000b2583          	lw	a1,0(s6)
 53a:	8556                	mv	a0,s5
 53c:	00000097          	auipc	ra,0x0
 540:	e8c080e7          	jalr	-372(ra) # 3c8 <printint>
 544:	8b4a                	mv	s6,s2
      state = 0;
 546:	4981                	li	s3,0
 548:	b771                	j	4d4 <vprintf+0x60>
        printint(fd, va_arg(ap, int), 16, 0);
 54a:	008b0913          	addi	s2,s6,8
 54e:	4681                	li	a3,0
 550:	866a                	mv	a2,s10
 552:	000b2583          	lw	a1,0(s6)
 556:	8556                	mv	a0,s5
 558:	00000097          	auipc	ra,0x0
 55c:	e70080e7          	jalr	-400(ra) # 3c8 <printint>
 560:	8b4a                	mv	s6,s2
      state = 0;
 562:	4981                	li	s3,0
 564:	bf85                	j	4d4 <vprintf+0x60>
        printptr(fd, va_arg(ap, uint64));
 566:	008b0793          	addi	a5,s6,8
 56a:	f8f43423          	sd	a5,-120(s0)
 56e:	000b3983          	ld	s3,0(s6)
  putc(fd, '0');
 572:	03000593          	li	a1,48
 576:	8556                	mv	a0,s5
 578:	00000097          	auipc	ra,0x0
 57c:	e2e080e7          	jalr	-466(ra) # 3a6 <putc>
  putc(fd, 'x');
 580:	07800593          	li	a1,120
 584:	8556                	mv	a0,s5
 586:	00000097          	auipc	ra,0x0
 58a:	e20080e7          	jalr	-480(ra) # 3a6 <putc>
 58e:	896a                	mv	s2,s10
    putc(fd, digits[x >> (sizeof(uint64) * 8 - 4)]);
 590:	03c9d793          	srli	a5,s3,0x3c
 594:	97de                	add	a5,a5,s7
 596:	0007c583          	lbu	a1,0(a5)
 59a:	8556                	mv	a0,s5
 59c:	00000097          	auipc	ra,0x0
 5a0:	e0a080e7          	jalr	-502(ra) # 3a6 <putc>
  for (i = 0; i < (sizeof(uint64) * 2); i++, x <<= 4)
 5a4:	0992                	slli	s3,s3,0x4
 5a6:	397d                	addiw	s2,s2,-1
 5a8:	fe0914e3          	bnez	s2,590 <vprintf+0x11c>
        printptr(fd, va_arg(ap, uint64));
 5ac:	f8843b03          	ld	s6,-120(s0)
      state = 0;
 5b0:	4981                	li	s3,0
 5b2:	b70d                	j	4d4 <vprintf+0x60>
        s = va_arg(ap, char*);
 5b4:	008b0913          	addi	s2,s6,8
 5b8:	000b3983          	ld	s3,0(s6)
        if(s == 0)
 5bc:	02098163          	beqz	s3,5de <vprintf+0x16a>
        while(*s != 0){
 5c0:	0009c583          	lbu	a1,0(s3)
 5c4:	c5ad                	beqz	a1,62e <vprintf+0x1ba>
          putc(fd, *s);
 5c6:	8556                	mv	a0,s5
 5c8:	00000097          	auipc	ra,0x0
 5cc:	dde080e7          	jalr	-546(ra) # 3a6 <putc>
          s++;
 5d0:	0985                	addi	s3,s3,1
        while(*s != 0){
 5d2:	0009c583          	lbu	a1,0(s3)
 5d6:	f9e5                	bnez	a1,5c6 <vprintf+0x152>
        s = va_arg(ap, char*);
 5d8:	8b4a                	mv	s6,s2
      state = 0;
 5da:	4981                	li	s3,0
 5dc:	bde5                	j	4d4 <vprintf+0x60>
          s = "(null)";
 5de:	00000997          	auipc	s3,0x0
 5e2:	30a98993          	addi	s3,s3,778 # 8e8 <lock_release+0x5c>
        while(*s != 0){
 5e6:	85ee                	mv	a1,s11
 5e8:	bff9                	j	5c6 <vprintf+0x152>
        putc(fd, va_arg(ap, uint));
 5ea:	008b0913          	addi	s2,s6,8
 5ee:	000b4583          	lbu	a1,0(s6)
 5f2:	8556                	mv	a0,s5
 5f4:	00000097          	auipc	ra,0x0
 5f8:	db2080e7          	jalr	-590(ra) # 3a6 <putc>
 5fc:	8b4a                	mv	s6,s2
      state = 0;
 5fe:	4981                	li	s3,0
 600:	bdd1                	j	4d4 <vprintf+0x60>
        putc(fd, c);
 602:	85d2                	mv	a1,s4
 604:	8556                	mv	a0,s5
 606:	00000097          	auipc	ra,0x0
 60a:	da0080e7          	jalr	-608(ra) # 3a6 <putc>
      state = 0;
 60e:	4981                	li	s3,0
 610:	b5d1                	j	4d4 <vprintf+0x60>
        putc(fd, '%');
 612:	85d2                	mv	a1,s4
 614:	8556                	mv	a0,s5
 616:	00000097          	auipc	ra,0x0
 61a:	d90080e7          	jalr	-624(ra) # 3a6 <putc>
        putc(fd, c);
 61e:	85ca                	mv	a1,s2
 620:	8556                	mv	a0,s5
 622:	00000097          	auipc	ra,0x0
 626:	d84080e7          	jalr	-636(ra) # 3a6 <putc>
      state = 0;
 62a:	4981                	li	s3,0
 62c:	b565                	j	4d4 <vprintf+0x60>
        s = va_arg(ap, char*);
 62e:	8b4a                	mv	s6,s2
      state = 0;
 630:	4981                	li	s3,0
 632:	b54d                	j	4d4 <vprintf+0x60>
    }
  }
}
 634:	70e6                	ld	ra,120(sp)
 636:	7446                	ld	s0,112(sp)
 638:	74a6                	ld	s1,104(sp)
 63a:	7906                	ld	s2,96(sp)
 63c:	69e6                	ld	s3,88(sp)
 63e:	6a46                	ld	s4,80(sp)
 640:	6aa6                	ld	s5,72(sp)
 642:	6b06                	ld	s6,64(sp)
 644:	7be2                	ld	s7,56(sp)
 646:	7c42                	ld	s8,48(sp)
 648:	7ca2                	ld	s9,40(sp)
 64a:	7d02                	ld	s10,32(sp)
 64c:	6de2                	ld	s11,24(sp)
 64e:	6109                	addi	sp,sp,128
 650:	8082                	ret

0000000000000652 <fprintf>:

void
fprintf(int fd, const char *fmt, ...)
{
 652:	715d                	addi	sp,sp,-80
 654:	ec06                	sd	ra,24(sp)
 656:	e822                	sd	s0,16(sp)
 658:	1000                	addi	s0,sp,32
 65a:	e010                	sd	a2,0(s0)
 65c:	e414                	sd	a3,8(s0)
 65e:	e818                	sd	a4,16(s0)
 660:	ec1c                	sd	a5,24(s0)
 662:	03043023          	sd	a6,32(s0)
 666:	03143423          	sd	a7,40(s0)
  va_list ap;

  va_start(ap, fmt);
 66a:	fe843423          	sd	s0,-24(s0)
  vprintf(fd, fmt, ap);
 66e:	8622                	mv	a2,s0
 670:	00000097          	auipc	ra,0x0
 674:	e04080e7          	jalr	-508(ra) # 474 <vprintf>
}
 678:	60e2                	ld	ra,24(sp)
 67a:	6442                	ld	s0,16(sp)
 67c:	6161                	addi	sp,sp,80
 67e:	8082                	ret

0000000000000680 <printf>:

void
printf(const char *fmt, ...)
{
 680:	711d                	addi	sp,sp,-96
 682:	ec06                	sd	ra,24(sp)
 684:	e822                	sd	s0,16(sp)
 686:	1000                	addi	s0,sp,32
 688:	e40c                	sd	a1,8(s0)
 68a:	e810                	sd	a2,16(s0)
 68c:	ec14                	sd	a3,24(s0)
 68e:	f018                	sd	a4,32(s0)
 690:	f41c                	sd	a5,40(s0)
 692:	03043823          	sd	a6,48(s0)
 696:	03143c23          	sd	a7,56(s0)
  va_list ap;

  va_start(ap, fmt);
 69a:	00840613          	addi	a2,s0,8
 69e:	fec43423          	sd	a2,-24(s0)
  vprintf(1, fmt, ap);
 6a2:	85aa                	mv	a1,a0
 6a4:	4505                	li	a0,1
 6a6:	00000097          	auipc	ra,0x0
 6aa:	dce080e7          	jalr	-562(ra) # 474 <vprintf>
}
 6ae:	60e2                	ld	ra,24(sp)
 6b0:	6442                	ld	s0,16(sp)
 6b2:	6125                	addi	sp,sp,96
 6b4:	8082                	ret

00000000000006b6 <free>:
static Header base;
static Header *freep;

void
free(void *ap)
{
 6b6:	1141                	addi	sp,sp,-16
 6b8:	e422                	sd	s0,8(sp)
 6ba:	0800                	addi	s0,sp,16
  Header *bp, *p;

  bp = (Header*)ap - 1;
 6bc:	ff050693          	addi	a3,a0,-16
  for(p = freep; !(bp > p && bp < p->s.ptr); p = p->s.ptr)
 6c0:	00001797          	auipc	a5,0x1
 6c4:	9407b783          	ld	a5,-1728(a5) # 1000 <freep>
 6c8:	a02d                	j	6f2 <free+0x3c>
    if(p >= p->s.ptr && (bp > p || bp < p->s.ptr))
      break;
  if(bp + bp->s.size == p->s.ptr){
    bp->s.size += p->s.ptr->s.size;
 6ca:	4618                	lw	a4,8(a2)
 6cc:	9f2d                	addw	a4,a4,a1
 6ce:	fee52c23          	sw	a4,-8(a0)
    bp->s.ptr = p->s.ptr->s.ptr;
 6d2:	6398                	ld	a4,0(a5)
 6d4:	6310                	ld	a2,0(a4)
 6d6:	a83d                	j	714 <free+0x5e>
  } else
    bp->s.ptr = p->s.ptr;
  if(p + p->s.size == bp){
    p->s.size += bp->s.size;
 6d8:	ff852703          	lw	a4,-8(a0)
 6dc:	9f31                	addw	a4,a4,a2
 6de:	c798                	sw	a4,8(a5)
    p->s.ptr = bp->s.ptr;
 6e0:	ff053683          	ld	a3,-16(a0)
 6e4:	a091                	j	728 <free+0x72>
    if(p >= p->s.ptr && (bp > p || bp < p->s.ptr))
 6e6:	6398                	ld	a4,0(a5)
 6e8:	00e7e463          	bltu	a5,a4,6f0 <free+0x3a>
 6ec:	00e6ea63          	bltu	a3,a4,700 <free+0x4a>
{
 6f0:	87ba                	mv	a5,a4
  for(p = freep; !(bp > p && bp < p->s.ptr); p = p->s.ptr)
 6f2:	fed7fae3          	bgeu	a5,a3,6e6 <free+0x30>
 6f6:	6398                	ld	a4,0(a5)
 6f8:	00e6e463          	bltu	a3,a4,700 <free+0x4a>
    if(p >= p->s.ptr && (bp > p || bp < p->s.ptr))
 6fc:	fee7eae3          	bltu	a5,a4,6f0 <free+0x3a>
  if(bp + bp->s.size == p->s.ptr){
 700:	ff852583          	lw	a1,-8(a0)
 704:	6390                	ld	a2,0(a5)
 706:	02059813          	slli	a6,a1,0x20
 70a:	01c85713          	srli	a4,a6,0x1c
 70e:	9736                	add	a4,a4,a3
 710:	fae60de3          	beq	a2,a4,6ca <free+0x14>
    bp->s.ptr = p->s.ptr->s.ptr;
 714:	fec53823          	sd	a2,-16(a0)
  if(p + p->s.size == bp){
 718:	4790                	lw	a2,8(a5)
 71a:	02061593          	slli	a1,a2,0x20
 71e:	01c5d713          	srli	a4,a1,0x1c
 722:	973e                	add	a4,a4,a5
 724:	fae68ae3          	beq	a3,a4,6d8 <free+0x22>
    p->s.ptr = bp->s.ptr;
 728:	e394                	sd	a3,0(a5)
  } else
    p->s.ptr = bp;
  freep = p;
 72a:	00001717          	auipc	a4,0x1
 72e:	8cf73b23          	sd	a5,-1834(a4) # 1000 <freep>
}
 732:	6422                	ld	s0,8(sp)
 734:	0141                	addi	sp,sp,16
 736:	8082                	ret

0000000000000738 <malloc>:
  return freep;
}

void*
malloc(uint nbytes)
{
 738:	7139                	addi	sp,sp,-64
 73a:	fc06                	sd	ra,56(sp)
 73c:	f822                	sd	s0,48(sp)
 73e:	f426                	sd	s1,40(sp)
 740:	f04a                	sd	s2,32(sp)
 742:	ec4e                	sd	s3,24(sp)
 744:	e852                	sd	s4,16(sp)
 746:	e456                	sd	s5,8(sp)
 748:	e05a                	sd	s6,0(sp)
 74a:	0080                	addi	s0,sp,64
  Header *p, *prevp;
  uint nunits;

  nunits = (nbytes + sizeof(Header) - 1)/sizeof(Header) + 1;
 74c:	02051493          	slli	s1,a0,0x20
 750:	9081                	srli	s1,s1,0x20
 752:	04bd                	addi	s1,s1,15
 754:	8091                	srli	s1,s1,0x4
 756:	0014899b          	addiw	s3,s1,1
 75a:	0485                	addi	s1,s1,1
  if((prevp = freep) == 0){
 75c:	00001517          	auipc	a0,0x1
 760:	8a453503          	ld	a0,-1884(a0) # 1000 <freep>
 764:	c515                	beqz	a0,790 <malloc+0x58>
    base.s.ptr = freep = prevp = &base;
    base.s.size = 0;
  }
  for(p = prevp->s.ptr; ; prevp = p, p = p->s.ptr){
 766:	611c                	ld	a5,0(a0)
    if(p->s.size >= nunits){
 768:	4798                	lw	a4,8(a5)
 76a:	02977f63          	bgeu	a4,s1,7a8 <malloc+0x70>
 76e:	8a4e                	mv	s4,s3
 770:	0009871b          	sext.w	a4,s3
 774:	6685                	lui	a3,0x1
 776:	00d77363          	bgeu	a4,a3,77c <malloc+0x44>
 77a:	6a05                	lui	s4,0x1
 77c:	000a0b1b          	sext.w	s6,s4
  p = sbrk(nu * sizeof(Header));
 780:	004a1a1b          	slliw	s4,s4,0x4
        p->s.size = nunits;
      }
      freep = prevp;
      return (void*)(p + 1);
    }
    if(p == freep)
 784:	00001917          	auipc	s2,0x1
 788:	87c90913          	addi	s2,s2,-1924 # 1000 <freep>
  if(p == (char*)-1)
 78c:	5afd                	li	s5,-1
 78e:	a895                	j	802 <malloc+0xca>
    base.s.ptr = freep = prevp = &base;
 790:	00001797          	auipc	a5,0x1
 794:	88078793          	addi	a5,a5,-1920 # 1010 <base>
 798:	00001717          	auipc	a4,0x1
 79c:	86f73423          	sd	a5,-1944(a4) # 1000 <freep>
 7a0:	e39c                	sd	a5,0(a5)
    base.s.size = 0;
 7a2:	0007a423          	sw	zero,8(a5)
    if(p->s.size >= nunits){
 7a6:	b7e1                	j	76e <malloc+0x36>
      if(p->s.size == nunits)
 7a8:	02e48c63          	beq	s1,a4,7e0 <malloc+0xa8>
        p->s.size -= nunits;
 7ac:	4137073b          	subw	a4,a4,s3
 7b0:	c798                	sw	a4,8(a5)
        p += p->s.size;
 7b2:	02071693          	slli	a3,a4,0x20
 7b6:	01c6d713          	srli	a4,a3,0x1c
 7ba:	97ba                	add	a5,a5,a4
        p->s.size = nunits;
 7bc:	0137a423          	sw	s3,8(a5)
      freep = prevp;
 7c0:	00001717          	auipc	a4,0x1
 7c4:	84a73023          	sd	a0,-1984(a4) # 1000 <freep>
      return (void*)(p + 1);
 7c8:	01078513          	addi	a0,a5,16
      if((p = morecore(nunits)) == 0)
        return 0;
  }
}
 7cc:	70e2                	ld	ra,56(sp)
 7ce:	7442                	ld	s0,48(sp)
 7d0:	74a2                	ld	s1,40(sp)
 7d2:	7902                	ld	s2,32(sp)
 7d4:	69e2                	ld	s3,24(sp)
 7d6:	6a42                	ld	s4,16(sp)
 7d8:	6aa2                	ld	s5,8(sp)
 7da:	6b02                	ld	s6,0(sp)
 7dc:	6121                	addi	sp,sp,64
 7de:	8082                	ret
        prevp->s.ptr = p->s.ptr;
 7e0:	6398                	ld	a4,0(a5)
 7e2:	e118                	sd	a4,0(a0)
 7e4:	bff1                	j	7c0 <malloc+0x88>
  hp->s.size = nu;
 7e6:	01652423          	sw	s6,8(a0)
  free((void*)(hp + 1));
 7ea:	0541                	addi	a0,a0,16
 7ec:	00000097          	auipc	ra,0x0
 7f0:	eca080e7          	jalr	-310(ra) # 6b6 <free>
  return freep;
 7f4:	00093503          	ld	a0,0(s2)
      if((p = morecore(nunits)) == 0)
 7f8:	d971                	beqz	a0,7cc <malloc+0x94>
  for(p = prevp->s.ptr; ; prevp = p, p = p->s.ptr){
 7fa:	611c                	ld	a5,0(a0)
    if(p->s.size >= nunits){
 7fc:	4798                	lw	a4,8(a5)
 7fe:	fa9775e3          	bgeu	a4,s1,7a8 <malloc+0x70>
    if(p == freep)
 802:	00093703          	ld	a4,0(s2)
 806:	853e                	mv	a0,a5
 808:	fef719e3          	bne	a4,a5,7fa <malloc+0xc2>
  p = sbrk(nu * sizeof(Header));
 80c:	8552                	mv	a0,s4
 80e:	00000097          	auipc	ra,0x0
 812:	b78080e7          	jalr	-1160(ra) # 386 <sbrk>
  if(p == (char*)-1)
 816:	fd5518e3          	bne	a0,s5,7e6 <malloc+0xae>
        return 0;
 81a:	4501                	li	a0,0
 81c:	bf45                	j	7cc <malloc+0x94>

000000000000081e <thread_create>:
#include "user/user.h"
#include "user/thread.h"


int thread_create(void *(*start_routine)(void*), void *arg) 
{
 81e:	1101                	addi	sp,sp,-32
 820:	ec06                	sd	ra,24(sp)
 822:	e822                	sd	s0,16(sp)
 824:	e426                	sd	s1,8(sp)
 826:	e04a                	sd	s2,0(sp)
 828:	1000                	addi	s0,sp,32
 82a:	84aa                	mv	s1,a0
 82c:	892e                	mv	s2,a1
	int stksz = 4096 * sizeof(void);
	void* stk_addr = (void*) malloc(stksz);
 82e:	6505                	lui	a0,0x1
 830:	00000097          	auipc	ra,0x0
 834:	f08080e7          	jalr	-248(ra) # 738 <malloc>
	
	int tid  = clone(stk_addr,stksz);
 838:	6585                	lui	a1,0x1
 83a:	00000097          	auipc	ra,0x0
 83e:	b64080e7          	jalr	-1180(ra) # 39e <clone>
	
	if(tid == 0) {
 842:	c901                	beqz	a0,852 <thread_create+0x34>
		(*start_routine) (arg);
		exit(0);
	}
	return 0;
}
 844:	4501                	li	a0,0
 846:	60e2                	ld	ra,24(sp)
 848:	6442                	ld	s0,16(sp)
 84a:	64a2                	ld	s1,8(sp)
 84c:	6902                	ld	s2,0(sp)
 84e:	6105                	addi	sp,sp,32
 850:	8082                	ret
		(*start_routine) (arg);
 852:	854a                	mv	a0,s2
 854:	9482                	jalr	s1
		exit(0);
 856:	4501                	li	a0,0
 858:	00000097          	auipc	ra,0x0
 85c:	aa6080e7          	jalr	-1370(ra) # 2fe <exit>

0000000000000860 <lock_init>:

void lock_init(lock_t *lock)
{
 860:	1141                	addi	sp,sp,-16
 862:	e422                	sd	s0,8(sp)
 864:	0800                	addi	s0,sp,16
	*lock = 0;
 866:	00052023          	sw	zero,0(a0) # 1000 <freep>
}
 86a:	6422                	ld	s0,8(sp)
 86c:	0141                	addi	sp,sp,16
 86e:	8082                	ret

0000000000000870 <lock_acquire>:
void lock_acquire(lock_t *lock)
{
 870:	1141                	addi	sp,sp,-16
 872:	e422                	sd	s0,8(sp)
 874:	0800                	addi	s0,sp,16
	while(__sync_lock_test_and_set(lock, 1) != 0);
 876:	4705                	li	a4,1
 878:	87ba                	mv	a5,a4
 87a:	0cf527af          	amoswap.w.aq	a5,a5,(a0)
 87e:	2781                	sext.w	a5,a5
 880:	ffe5                	bnez	a5,878 <lock_acquire+0x8>
	__sync_synchronize();
 882:	0ff0000f          	fence
}
 886:	6422                	ld	s0,8(sp)
 888:	0141                	addi	sp,sp,16
 88a:	8082                	ret

000000000000088c <lock_release>:
void lock_release(lock_t *lock)
{
 88c:	1141                	addi	sp,sp,-16
 88e:	e422                	sd	s0,8(sp)
 890:	0800                	addi	s0,sp,16
	__sync_synchronize();
 892:	0ff0000f          	fence
	__sync_lock_release(lock,0);
 896:	0f50000f          	fence	iorw,ow
 89a:	0805202f          	amoswap.w	zero,zero,(a0)
}
 89e:	6422                	ld	s0,8(sp)
 8a0:	0141                	addi	sp,sp,16
 8a2:	8082                	ret
