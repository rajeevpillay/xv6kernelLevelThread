
user/_sh:     file format elf64-littleriscv


Disassembly of section .text:

0000000000000000 <getcmd>:
  exit(0);
}

int
getcmd(char *buf, int nbuf)
{
       0:	1101                	addi	sp,sp,-32
       2:	ec06                	sd	ra,24(sp)
       4:	e822                	sd	s0,16(sp)
       6:	e426                	sd	s1,8(sp)
       8:	e04a                	sd	s2,0(sp)
       a:	1000                	addi	s0,sp,32
       c:	84aa                	mv	s1,a0
       e:	892e                	mv	s2,a1
  write(2, "$ ", 2);
      10:	4609                	li	a2,2
      12:	00001597          	auipc	a1,0x1
      16:	37e58593          	addi	a1,a1,894 # 1390 <lock_release+0x1e>
      1a:	4509                	li	a0,2
      1c:	00001097          	auipc	ra,0x1
      20:	de8080e7          	jalr	-536(ra) # e04 <write>
  memset(buf, 0, nbuf);
      24:	864a                	mv	a2,s2
      26:	4581                	li	a1,0
      28:	8526                	mv	a0,s1
      2a:	00001097          	auipc	ra,0x1
      2e:	bc0080e7          	jalr	-1088(ra) # bea <memset>
  gets(buf, nbuf);
      32:	85ca                	mv	a1,s2
      34:	8526                	mv	a0,s1
      36:	00001097          	auipc	ra,0x1
      3a:	bfa080e7          	jalr	-1030(ra) # c30 <gets>
  if(buf[0] == 0) // EOF
      3e:	0004c503          	lbu	a0,0(s1)
      42:	00153513          	seqz	a0,a0
    return -1;
  return 0;
}
      46:	40a00533          	neg	a0,a0
      4a:	60e2                	ld	ra,24(sp)
      4c:	6442                	ld	s0,16(sp)
      4e:	64a2                	ld	s1,8(sp)
      50:	6902                	ld	s2,0(sp)
      52:	6105                	addi	sp,sp,32
      54:	8082                	ret

0000000000000056 <panic>:
  exit(0);
}

void
panic(char *s)
{
      56:	1141                	addi	sp,sp,-16
      58:	e406                	sd	ra,8(sp)
      5a:	e022                	sd	s0,0(sp)
      5c:	0800                	addi	s0,sp,16
      5e:	862a                	mv	a2,a0
  fprintf(2, "%s\n", s);
      60:	00001597          	auipc	a1,0x1
      64:	33858593          	addi	a1,a1,824 # 1398 <lock_release+0x26>
      68:	4509                	li	a0,2
      6a:	00001097          	auipc	ra,0x1
      6e:	0ce080e7          	jalr	206(ra) # 1138 <fprintf>
  exit(1);
      72:	4505                	li	a0,1
      74:	00001097          	auipc	ra,0x1
      78:	d70080e7          	jalr	-656(ra) # de4 <exit>

000000000000007c <fork1>:
}

int
fork1(void)
{
      7c:	1141                	addi	sp,sp,-16
      7e:	e406                	sd	ra,8(sp)
      80:	e022                	sd	s0,0(sp)
      82:	0800                	addi	s0,sp,16
  int pid;

  pid = fork();
      84:	00001097          	auipc	ra,0x1
      88:	d58080e7          	jalr	-680(ra) # ddc <fork>
  if(pid == -1)
      8c:	57fd                	li	a5,-1
      8e:	00f50663          	beq	a0,a5,9a <fork1+0x1e>
    panic("fork");
  return pid;
}
      92:	60a2                	ld	ra,8(sp)
      94:	6402                	ld	s0,0(sp)
      96:	0141                	addi	sp,sp,16
      98:	8082                	ret
    panic("fork");
      9a:	00001517          	auipc	a0,0x1
      9e:	30650513          	addi	a0,a0,774 # 13a0 <lock_release+0x2e>
      a2:	00000097          	auipc	ra,0x0
      a6:	fb4080e7          	jalr	-76(ra) # 56 <panic>

00000000000000aa <runcmd>:
{
      aa:	7179                	addi	sp,sp,-48
      ac:	f406                	sd	ra,40(sp)
      ae:	f022                	sd	s0,32(sp)
      b0:	ec26                	sd	s1,24(sp)
      b2:	1800                	addi	s0,sp,48
  if(cmd == 0)
      b4:	c10d                	beqz	a0,d6 <runcmd+0x2c>
      b6:	84aa                	mv	s1,a0
  switch(cmd->type){
      b8:	4118                	lw	a4,0(a0)
      ba:	4795                	li	a5,5
      bc:	02e7e263          	bltu	a5,a4,e0 <runcmd+0x36>
      c0:	00056783          	lwu	a5,0(a0)
      c4:	078a                	slli	a5,a5,0x2
      c6:	00001717          	auipc	a4,0x1
      ca:	3da70713          	addi	a4,a4,986 # 14a0 <lock_release+0x12e>
      ce:	97ba                	add	a5,a5,a4
      d0:	439c                	lw	a5,0(a5)
      d2:	97ba                	add	a5,a5,a4
      d4:	8782                	jr	a5
    exit(1);
      d6:	4505                	li	a0,1
      d8:	00001097          	auipc	ra,0x1
      dc:	d0c080e7          	jalr	-756(ra) # de4 <exit>
    panic("runcmd");
      e0:	00001517          	auipc	a0,0x1
      e4:	2c850513          	addi	a0,a0,712 # 13a8 <lock_release+0x36>
      e8:	00000097          	auipc	ra,0x0
      ec:	f6e080e7          	jalr	-146(ra) # 56 <panic>
    if(ecmd->argv[0] == 0)
      f0:	6508                	ld	a0,8(a0)
      f2:	c515                	beqz	a0,11e <runcmd+0x74>
    exec(ecmd->argv[0], ecmd->argv);
      f4:	00848593          	addi	a1,s1,8
      f8:	00001097          	auipc	ra,0x1
      fc:	d24080e7          	jalr	-732(ra) # e1c <exec>
    fprintf(2, "exec %s failed\n", ecmd->argv[0]);
     100:	6490                	ld	a2,8(s1)
     102:	00001597          	auipc	a1,0x1
     106:	2ae58593          	addi	a1,a1,686 # 13b0 <lock_release+0x3e>
     10a:	4509                	li	a0,2
     10c:	00001097          	auipc	ra,0x1
     110:	02c080e7          	jalr	44(ra) # 1138 <fprintf>
  exit(0);
     114:	4501                	li	a0,0
     116:	00001097          	auipc	ra,0x1
     11a:	cce080e7          	jalr	-818(ra) # de4 <exit>
      exit(1);
     11e:	4505                	li	a0,1
     120:	00001097          	auipc	ra,0x1
     124:	cc4080e7          	jalr	-828(ra) # de4 <exit>
    close(rcmd->fd);
     128:	5148                	lw	a0,36(a0)
     12a:	00001097          	auipc	ra,0x1
     12e:	ce2080e7          	jalr	-798(ra) # e0c <close>
    if(open(rcmd->file, rcmd->mode) < 0){
     132:	508c                	lw	a1,32(s1)
     134:	6888                	ld	a0,16(s1)
     136:	00001097          	auipc	ra,0x1
     13a:	cee080e7          	jalr	-786(ra) # e24 <open>
     13e:	00054763          	bltz	a0,14c <runcmd+0xa2>
    runcmd(rcmd->cmd);
     142:	6488                	ld	a0,8(s1)
     144:	00000097          	auipc	ra,0x0
     148:	f66080e7          	jalr	-154(ra) # aa <runcmd>
      fprintf(2, "open %s failed\n", rcmd->file);
     14c:	6890                	ld	a2,16(s1)
     14e:	00001597          	auipc	a1,0x1
     152:	27258593          	addi	a1,a1,626 # 13c0 <lock_release+0x4e>
     156:	4509                	li	a0,2
     158:	00001097          	auipc	ra,0x1
     15c:	fe0080e7          	jalr	-32(ra) # 1138 <fprintf>
      exit(1);
     160:	4505                	li	a0,1
     162:	00001097          	auipc	ra,0x1
     166:	c82080e7          	jalr	-894(ra) # de4 <exit>
    if(fork1() == 0)
     16a:	00000097          	auipc	ra,0x0
     16e:	f12080e7          	jalr	-238(ra) # 7c <fork1>
     172:	e511                	bnez	a0,17e <runcmd+0xd4>
      runcmd(lcmd->left);
     174:	6488                	ld	a0,8(s1)
     176:	00000097          	auipc	ra,0x0
     17a:	f34080e7          	jalr	-204(ra) # aa <runcmd>
    wait(0);
     17e:	4501                	li	a0,0
     180:	00001097          	auipc	ra,0x1
     184:	c6c080e7          	jalr	-916(ra) # dec <wait>
    runcmd(lcmd->right);
     188:	6888                	ld	a0,16(s1)
     18a:	00000097          	auipc	ra,0x0
     18e:	f20080e7          	jalr	-224(ra) # aa <runcmd>
    if(pipe(p) < 0)
     192:	fd840513          	addi	a0,s0,-40
     196:	00001097          	auipc	ra,0x1
     19a:	c5e080e7          	jalr	-930(ra) # df4 <pipe>
     19e:	04054363          	bltz	a0,1e4 <runcmd+0x13a>
    if(fork1() == 0){
     1a2:	00000097          	auipc	ra,0x0
     1a6:	eda080e7          	jalr	-294(ra) # 7c <fork1>
     1aa:	e529                	bnez	a0,1f4 <runcmd+0x14a>
      close(1);
     1ac:	4505                	li	a0,1
     1ae:	00001097          	auipc	ra,0x1
     1b2:	c5e080e7          	jalr	-930(ra) # e0c <close>
      dup(p[1]);
     1b6:	fdc42503          	lw	a0,-36(s0)
     1ba:	00001097          	auipc	ra,0x1
     1be:	ca2080e7          	jalr	-862(ra) # e5c <dup>
      close(p[0]);
     1c2:	fd842503          	lw	a0,-40(s0)
     1c6:	00001097          	auipc	ra,0x1
     1ca:	c46080e7          	jalr	-954(ra) # e0c <close>
      close(p[1]);
     1ce:	fdc42503          	lw	a0,-36(s0)
     1d2:	00001097          	auipc	ra,0x1
     1d6:	c3a080e7          	jalr	-966(ra) # e0c <close>
      runcmd(pcmd->left);
     1da:	6488                	ld	a0,8(s1)
     1dc:	00000097          	auipc	ra,0x0
     1e0:	ece080e7          	jalr	-306(ra) # aa <runcmd>
      panic("pipe");
     1e4:	00001517          	auipc	a0,0x1
     1e8:	1ec50513          	addi	a0,a0,492 # 13d0 <lock_release+0x5e>
     1ec:	00000097          	auipc	ra,0x0
     1f0:	e6a080e7          	jalr	-406(ra) # 56 <panic>
    if(fork1() == 0){
     1f4:	00000097          	auipc	ra,0x0
     1f8:	e88080e7          	jalr	-376(ra) # 7c <fork1>
     1fc:	ed05                	bnez	a0,234 <runcmd+0x18a>
      close(0);
     1fe:	00001097          	auipc	ra,0x1
     202:	c0e080e7          	jalr	-1010(ra) # e0c <close>
      dup(p[0]);
     206:	fd842503          	lw	a0,-40(s0)
     20a:	00001097          	auipc	ra,0x1
     20e:	c52080e7          	jalr	-942(ra) # e5c <dup>
      close(p[0]);
     212:	fd842503          	lw	a0,-40(s0)
     216:	00001097          	auipc	ra,0x1
     21a:	bf6080e7          	jalr	-1034(ra) # e0c <close>
      close(p[1]);
     21e:	fdc42503          	lw	a0,-36(s0)
     222:	00001097          	auipc	ra,0x1
     226:	bea080e7          	jalr	-1046(ra) # e0c <close>
      runcmd(pcmd->right);
     22a:	6888                	ld	a0,16(s1)
     22c:	00000097          	auipc	ra,0x0
     230:	e7e080e7          	jalr	-386(ra) # aa <runcmd>
    close(p[0]);
     234:	fd842503          	lw	a0,-40(s0)
     238:	00001097          	auipc	ra,0x1
     23c:	bd4080e7          	jalr	-1068(ra) # e0c <close>
    close(p[1]);
     240:	fdc42503          	lw	a0,-36(s0)
     244:	00001097          	auipc	ra,0x1
     248:	bc8080e7          	jalr	-1080(ra) # e0c <close>
    wait(0);
     24c:	4501                	li	a0,0
     24e:	00001097          	auipc	ra,0x1
     252:	b9e080e7          	jalr	-1122(ra) # dec <wait>
    wait(0);
     256:	4501                	li	a0,0
     258:	00001097          	auipc	ra,0x1
     25c:	b94080e7          	jalr	-1132(ra) # dec <wait>
    break;
     260:	bd55                	j	114 <runcmd+0x6a>
    if(fork1() == 0)
     262:	00000097          	auipc	ra,0x0
     266:	e1a080e7          	jalr	-486(ra) # 7c <fork1>
     26a:	ea0515e3          	bnez	a0,114 <runcmd+0x6a>
      runcmd(bcmd->cmd);
     26e:	6488                	ld	a0,8(s1)
     270:	00000097          	auipc	ra,0x0
     274:	e3a080e7          	jalr	-454(ra) # aa <runcmd>

0000000000000278 <execcmd>:
//PAGEBREAK!
// Constructors

struct cmd*
execcmd(void)
{
     278:	1101                	addi	sp,sp,-32
     27a:	ec06                	sd	ra,24(sp)
     27c:	e822                	sd	s0,16(sp)
     27e:	e426                	sd	s1,8(sp)
     280:	1000                	addi	s0,sp,32
  struct execcmd *cmd;

  cmd = malloc(sizeof(*cmd));
     282:	0a800513          	li	a0,168
     286:	00001097          	auipc	ra,0x1
     28a:	f98080e7          	jalr	-104(ra) # 121e <malloc>
     28e:	84aa                	mv	s1,a0
  memset(cmd, 0, sizeof(*cmd));
     290:	0a800613          	li	a2,168
     294:	4581                	li	a1,0
     296:	00001097          	auipc	ra,0x1
     29a:	954080e7          	jalr	-1708(ra) # bea <memset>
  cmd->type = EXEC;
     29e:	4785                	li	a5,1
     2a0:	c09c                	sw	a5,0(s1)
  return (struct cmd*)cmd;
}
     2a2:	8526                	mv	a0,s1
     2a4:	60e2                	ld	ra,24(sp)
     2a6:	6442                	ld	s0,16(sp)
     2a8:	64a2                	ld	s1,8(sp)
     2aa:	6105                	addi	sp,sp,32
     2ac:	8082                	ret

00000000000002ae <redircmd>:

struct cmd*
redircmd(struct cmd *subcmd, char *file, char *efile, int mode, int fd)
{
     2ae:	7139                	addi	sp,sp,-64
     2b0:	fc06                	sd	ra,56(sp)
     2b2:	f822                	sd	s0,48(sp)
     2b4:	f426                	sd	s1,40(sp)
     2b6:	f04a                	sd	s2,32(sp)
     2b8:	ec4e                	sd	s3,24(sp)
     2ba:	e852                	sd	s4,16(sp)
     2bc:	e456                	sd	s5,8(sp)
     2be:	e05a                	sd	s6,0(sp)
     2c0:	0080                	addi	s0,sp,64
     2c2:	8b2a                	mv	s6,a0
     2c4:	8aae                	mv	s5,a1
     2c6:	8a32                	mv	s4,a2
     2c8:	89b6                	mv	s3,a3
     2ca:	893a                	mv	s2,a4
  struct redircmd *cmd;

  cmd = malloc(sizeof(*cmd));
     2cc:	02800513          	li	a0,40
     2d0:	00001097          	auipc	ra,0x1
     2d4:	f4e080e7          	jalr	-178(ra) # 121e <malloc>
     2d8:	84aa                	mv	s1,a0
  memset(cmd, 0, sizeof(*cmd));
     2da:	02800613          	li	a2,40
     2de:	4581                	li	a1,0
     2e0:	00001097          	auipc	ra,0x1
     2e4:	90a080e7          	jalr	-1782(ra) # bea <memset>
  cmd->type = REDIR;
     2e8:	4789                	li	a5,2
     2ea:	c09c                	sw	a5,0(s1)
  cmd->cmd = subcmd;
     2ec:	0164b423          	sd	s6,8(s1)
  cmd->file = file;
     2f0:	0154b823          	sd	s5,16(s1)
  cmd->efile = efile;
     2f4:	0144bc23          	sd	s4,24(s1)
  cmd->mode = mode;
     2f8:	0334a023          	sw	s3,32(s1)
  cmd->fd = fd;
     2fc:	0324a223          	sw	s2,36(s1)
  return (struct cmd*)cmd;
}
     300:	8526                	mv	a0,s1
     302:	70e2                	ld	ra,56(sp)
     304:	7442                	ld	s0,48(sp)
     306:	74a2                	ld	s1,40(sp)
     308:	7902                	ld	s2,32(sp)
     30a:	69e2                	ld	s3,24(sp)
     30c:	6a42                	ld	s4,16(sp)
     30e:	6aa2                	ld	s5,8(sp)
     310:	6b02                	ld	s6,0(sp)
     312:	6121                	addi	sp,sp,64
     314:	8082                	ret

0000000000000316 <pipecmd>:

struct cmd*
pipecmd(struct cmd *left, struct cmd *right)
{
     316:	7179                	addi	sp,sp,-48
     318:	f406                	sd	ra,40(sp)
     31a:	f022                	sd	s0,32(sp)
     31c:	ec26                	sd	s1,24(sp)
     31e:	e84a                	sd	s2,16(sp)
     320:	e44e                	sd	s3,8(sp)
     322:	1800                	addi	s0,sp,48
     324:	89aa                	mv	s3,a0
     326:	892e                	mv	s2,a1
  struct pipecmd *cmd;

  cmd = malloc(sizeof(*cmd));
     328:	4561                	li	a0,24
     32a:	00001097          	auipc	ra,0x1
     32e:	ef4080e7          	jalr	-268(ra) # 121e <malloc>
     332:	84aa                	mv	s1,a0
  memset(cmd, 0, sizeof(*cmd));
     334:	4661                	li	a2,24
     336:	4581                	li	a1,0
     338:	00001097          	auipc	ra,0x1
     33c:	8b2080e7          	jalr	-1870(ra) # bea <memset>
  cmd->type = PIPE;
     340:	478d                	li	a5,3
     342:	c09c                	sw	a5,0(s1)
  cmd->left = left;
     344:	0134b423          	sd	s3,8(s1)
  cmd->right = right;
     348:	0124b823          	sd	s2,16(s1)
  return (struct cmd*)cmd;
}
     34c:	8526                	mv	a0,s1
     34e:	70a2                	ld	ra,40(sp)
     350:	7402                	ld	s0,32(sp)
     352:	64e2                	ld	s1,24(sp)
     354:	6942                	ld	s2,16(sp)
     356:	69a2                	ld	s3,8(sp)
     358:	6145                	addi	sp,sp,48
     35a:	8082                	ret

000000000000035c <listcmd>:

struct cmd*
listcmd(struct cmd *left, struct cmd *right)
{
     35c:	7179                	addi	sp,sp,-48
     35e:	f406                	sd	ra,40(sp)
     360:	f022                	sd	s0,32(sp)
     362:	ec26                	sd	s1,24(sp)
     364:	e84a                	sd	s2,16(sp)
     366:	e44e                	sd	s3,8(sp)
     368:	1800                	addi	s0,sp,48
     36a:	89aa                	mv	s3,a0
     36c:	892e                	mv	s2,a1
  struct listcmd *cmd;

  cmd = malloc(sizeof(*cmd));
     36e:	4561                	li	a0,24
     370:	00001097          	auipc	ra,0x1
     374:	eae080e7          	jalr	-338(ra) # 121e <malloc>
     378:	84aa                	mv	s1,a0
  memset(cmd, 0, sizeof(*cmd));
     37a:	4661                	li	a2,24
     37c:	4581                	li	a1,0
     37e:	00001097          	auipc	ra,0x1
     382:	86c080e7          	jalr	-1940(ra) # bea <memset>
  cmd->type = LIST;
     386:	4791                	li	a5,4
     388:	c09c                	sw	a5,0(s1)
  cmd->left = left;
     38a:	0134b423          	sd	s3,8(s1)
  cmd->right = right;
     38e:	0124b823          	sd	s2,16(s1)
  return (struct cmd*)cmd;
}
     392:	8526                	mv	a0,s1
     394:	70a2                	ld	ra,40(sp)
     396:	7402                	ld	s0,32(sp)
     398:	64e2                	ld	s1,24(sp)
     39a:	6942                	ld	s2,16(sp)
     39c:	69a2                	ld	s3,8(sp)
     39e:	6145                	addi	sp,sp,48
     3a0:	8082                	ret

00000000000003a2 <backcmd>:

struct cmd*
backcmd(struct cmd *subcmd)
{
     3a2:	1101                	addi	sp,sp,-32
     3a4:	ec06                	sd	ra,24(sp)
     3a6:	e822                	sd	s0,16(sp)
     3a8:	e426                	sd	s1,8(sp)
     3aa:	e04a                	sd	s2,0(sp)
     3ac:	1000                	addi	s0,sp,32
     3ae:	892a                	mv	s2,a0
  struct backcmd *cmd;

  cmd = malloc(sizeof(*cmd));
     3b0:	4541                	li	a0,16
     3b2:	00001097          	auipc	ra,0x1
     3b6:	e6c080e7          	jalr	-404(ra) # 121e <malloc>
     3ba:	84aa                	mv	s1,a0
  memset(cmd, 0, sizeof(*cmd));
     3bc:	4641                	li	a2,16
     3be:	4581                	li	a1,0
     3c0:	00001097          	auipc	ra,0x1
     3c4:	82a080e7          	jalr	-2006(ra) # bea <memset>
  cmd->type = BACK;
     3c8:	4795                	li	a5,5
     3ca:	c09c                	sw	a5,0(s1)
  cmd->cmd = subcmd;
     3cc:	0124b423          	sd	s2,8(s1)
  return (struct cmd*)cmd;
}
     3d0:	8526                	mv	a0,s1
     3d2:	60e2                	ld	ra,24(sp)
     3d4:	6442                	ld	s0,16(sp)
     3d6:	64a2                	ld	s1,8(sp)
     3d8:	6902                	ld	s2,0(sp)
     3da:	6105                	addi	sp,sp,32
     3dc:	8082                	ret

00000000000003de <gettoken>:
char whitespace[] = " \t\r\n\v";
char symbols[] = "<|>&;()";

int
gettoken(char **ps, char *es, char **q, char **eq)
{
     3de:	7139                	addi	sp,sp,-64
     3e0:	fc06                	sd	ra,56(sp)
     3e2:	f822                	sd	s0,48(sp)
     3e4:	f426                	sd	s1,40(sp)
     3e6:	f04a                	sd	s2,32(sp)
     3e8:	ec4e                	sd	s3,24(sp)
     3ea:	e852                	sd	s4,16(sp)
     3ec:	e456                	sd	s5,8(sp)
     3ee:	e05a                	sd	s6,0(sp)
     3f0:	0080                	addi	s0,sp,64
     3f2:	8a2a                	mv	s4,a0
     3f4:	892e                	mv	s2,a1
     3f6:	8ab2                	mv	s5,a2
     3f8:	8b36                	mv	s6,a3
  char *s;
  int ret;

  s = *ps;
     3fa:	6104                	ld	s1,0(a0)
  while(s < es && strchr(whitespace, *s))
     3fc:	00002997          	auipc	s3,0x2
     400:	c0c98993          	addi	s3,s3,-1012 # 2008 <whitespace>
     404:	00b4fe63          	bgeu	s1,a1,420 <gettoken+0x42>
     408:	0004c583          	lbu	a1,0(s1)
     40c:	854e                	mv	a0,s3
     40e:	00000097          	auipc	ra,0x0
     412:	7fe080e7          	jalr	2046(ra) # c0c <strchr>
     416:	c509                	beqz	a0,420 <gettoken+0x42>
    s++;
     418:	0485                	addi	s1,s1,1
  while(s < es && strchr(whitespace, *s))
     41a:	fe9917e3          	bne	s2,s1,408 <gettoken+0x2a>
    s++;
     41e:	84ca                	mv	s1,s2
  if(q)
     420:	000a8463          	beqz	s5,428 <gettoken+0x4a>
    *q = s;
     424:	009ab023          	sd	s1,0(s5)
  ret = *s;
     428:	0004c783          	lbu	a5,0(s1)
     42c:	00078a9b          	sext.w	s5,a5
  switch(*s){
     430:	03c00713          	li	a4,60
     434:	06f76663          	bltu	a4,a5,4a0 <gettoken+0xc2>
     438:	03a00713          	li	a4,58
     43c:	00f76e63          	bltu	a4,a5,458 <gettoken+0x7a>
     440:	cf89                	beqz	a5,45a <gettoken+0x7c>
     442:	02600713          	li	a4,38
     446:	00e78963          	beq	a5,a4,458 <gettoken+0x7a>
     44a:	fd87879b          	addiw	a5,a5,-40
     44e:	0ff7f793          	zext.b	a5,a5
     452:	4705                	li	a4,1
     454:	06f76d63          	bltu	a4,a5,4ce <gettoken+0xf0>
  case '(':
  case ')':
  case ';':
  case '&':
  case '<':
    s++;
     458:	0485                	addi	s1,s1,1
    ret = 'a';
    while(s < es && !strchr(whitespace, *s) && !strchr(symbols, *s))
      s++;
    break;
  }
  if(eq)
     45a:	000b0463          	beqz	s6,462 <gettoken+0x84>
    *eq = s;
     45e:	009b3023          	sd	s1,0(s6)

  while(s < es && strchr(whitespace, *s))
     462:	00002997          	auipc	s3,0x2
     466:	ba698993          	addi	s3,s3,-1114 # 2008 <whitespace>
     46a:	0124fe63          	bgeu	s1,s2,486 <gettoken+0xa8>
     46e:	0004c583          	lbu	a1,0(s1)
     472:	854e                	mv	a0,s3
     474:	00000097          	auipc	ra,0x0
     478:	798080e7          	jalr	1944(ra) # c0c <strchr>
     47c:	c509                	beqz	a0,486 <gettoken+0xa8>
    s++;
     47e:	0485                	addi	s1,s1,1
  while(s < es && strchr(whitespace, *s))
     480:	fe9917e3          	bne	s2,s1,46e <gettoken+0x90>
    s++;
     484:	84ca                	mv	s1,s2
  *ps = s;
     486:	009a3023          	sd	s1,0(s4)
  return ret;
}
     48a:	8556                	mv	a0,s5
     48c:	70e2                	ld	ra,56(sp)
     48e:	7442                	ld	s0,48(sp)
     490:	74a2                	ld	s1,40(sp)
     492:	7902                	ld	s2,32(sp)
     494:	69e2                	ld	s3,24(sp)
     496:	6a42                	ld	s4,16(sp)
     498:	6aa2                	ld	s5,8(sp)
     49a:	6b02                	ld	s6,0(sp)
     49c:	6121                	addi	sp,sp,64
     49e:	8082                	ret
  switch(*s){
     4a0:	03e00713          	li	a4,62
     4a4:	02e79163          	bne	a5,a4,4c6 <gettoken+0xe8>
    s++;
     4a8:	00148693          	addi	a3,s1,1
    if(*s == '>'){
     4ac:	0014c703          	lbu	a4,1(s1)
     4b0:	03e00793          	li	a5,62
      s++;
     4b4:	0489                	addi	s1,s1,2
      ret = '+';
     4b6:	02b00a93          	li	s5,43
    if(*s == '>'){
     4ba:	faf700e3          	beq	a4,a5,45a <gettoken+0x7c>
    s++;
     4be:	84b6                	mv	s1,a3
  ret = *s;
     4c0:	03e00a93          	li	s5,62
     4c4:	bf59                	j	45a <gettoken+0x7c>
  switch(*s){
     4c6:	07c00713          	li	a4,124
     4ca:	f8e787e3          	beq	a5,a4,458 <gettoken+0x7a>
    while(s < es && !strchr(whitespace, *s) && !strchr(symbols, *s))
     4ce:	00002997          	auipc	s3,0x2
     4d2:	b3a98993          	addi	s3,s3,-1222 # 2008 <whitespace>
     4d6:	00002a97          	auipc	s5,0x2
     4da:	b2aa8a93          	addi	s5,s5,-1238 # 2000 <symbols>
     4de:	0324f663          	bgeu	s1,s2,50a <gettoken+0x12c>
     4e2:	0004c583          	lbu	a1,0(s1)
     4e6:	854e                	mv	a0,s3
     4e8:	00000097          	auipc	ra,0x0
     4ec:	724080e7          	jalr	1828(ra) # c0c <strchr>
     4f0:	e50d                	bnez	a0,51a <gettoken+0x13c>
     4f2:	0004c583          	lbu	a1,0(s1)
     4f6:	8556                	mv	a0,s5
     4f8:	00000097          	auipc	ra,0x0
     4fc:	714080e7          	jalr	1812(ra) # c0c <strchr>
     500:	e911                	bnez	a0,514 <gettoken+0x136>
      s++;
     502:	0485                	addi	s1,s1,1
    while(s < es && !strchr(whitespace, *s) && !strchr(symbols, *s))
     504:	fc991fe3          	bne	s2,s1,4e2 <gettoken+0x104>
      s++;
     508:	84ca                	mv	s1,s2
  if(eq)
     50a:	06100a93          	li	s5,97
     50e:	f40b18e3          	bnez	s6,45e <gettoken+0x80>
     512:	bf95                	j	486 <gettoken+0xa8>
    ret = 'a';
     514:	06100a93          	li	s5,97
     518:	b789                	j	45a <gettoken+0x7c>
     51a:	06100a93          	li	s5,97
     51e:	bf35                	j	45a <gettoken+0x7c>

0000000000000520 <peek>:

int
peek(char **ps, char *es, char *toks)
{
     520:	7139                	addi	sp,sp,-64
     522:	fc06                	sd	ra,56(sp)
     524:	f822                	sd	s0,48(sp)
     526:	f426                	sd	s1,40(sp)
     528:	f04a                	sd	s2,32(sp)
     52a:	ec4e                	sd	s3,24(sp)
     52c:	e852                	sd	s4,16(sp)
     52e:	e456                	sd	s5,8(sp)
     530:	0080                	addi	s0,sp,64
     532:	8a2a                	mv	s4,a0
     534:	892e                	mv	s2,a1
     536:	8ab2                	mv	s5,a2
  char *s;

  s = *ps;
     538:	6104                	ld	s1,0(a0)
  while(s < es && strchr(whitespace, *s))
     53a:	00002997          	auipc	s3,0x2
     53e:	ace98993          	addi	s3,s3,-1330 # 2008 <whitespace>
     542:	00b4fe63          	bgeu	s1,a1,55e <peek+0x3e>
     546:	0004c583          	lbu	a1,0(s1)
     54a:	854e                	mv	a0,s3
     54c:	00000097          	auipc	ra,0x0
     550:	6c0080e7          	jalr	1728(ra) # c0c <strchr>
     554:	c509                	beqz	a0,55e <peek+0x3e>
    s++;
     556:	0485                	addi	s1,s1,1
  while(s < es && strchr(whitespace, *s))
     558:	fe9917e3          	bne	s2,s1,546 <peek+0x26>
    s++;
     55c:	84ca                	mv	s1,s2
  *ps = s;
     55e:	009a3023          	sd	s1,0(s4)
  return *s && strchr(toks, *s);
     562:	0004c583          	lbu	a1,0(s1)
     566:	4501                	li	a0,0
     568:	e991                	bnez	a1,57c <peek+0x5c>
}
     56a:	70e2                	ld	ra,56(sp)
     56c:	7442                	ld	s0,48(sp)
     56e:	74a2                	ld	s1,40(sp)
     570:	7902                	ld	s2,32(sp)
     572:	69e2                	ld	s3,24(sp)
     574:	6a42                	ld	s4,16(sp)
     576:	6aa2                	ld	s5,8(sp)
     578:	6121                	addi	sp,sp,64
     57a:	8082                	ret
  return *s && strchr(toks, *s);
     57c:	8556                	mv	a0,s5
     57e:	00000097          	auipc	ra,0x0
     582:	68e080e7          	jalr	1678(ra) # c0c <strchr>
     586:	00a03533          	snez	a0,a0
     58a:	b7c5                	j	56a <peek+0x4a>

000000000000058c <parseredirs>:
  return cmd;
}

struct cmd*
parseredirs(struct cmd *cmd, char **ps, char *es)
{
     58c:	7159                	addi	sp,sp,-112
     58e:	f486                	sd	ra,104(sp)
     590:	f0a2                	sd	s0,96(sp)
     592:	eca6                	sd	s1,88(sp)
     594:	e8ca                	sd	s2,80(sp)
     596:	e4ce                	sd	s3,72(sp)
     598:	e0d2                	sd	s4,64(sp)
     59a:	fc56                	sd	s5,56(sp)
     59c:	f85a                	sd	s6,48(sp)
     59e:	f45e                	sd	s7,40(sp)
     5a0:	f062                	sd	s8,32(sp)
     5a2:	ec66                	sd	s9,24(sp)
     5a4:	1880                	addi	s0,sp,112
     5a6:	8a2a                	mv	s4,a0
     5a8:	89ae                	mv	s3,a1
     5aa:	8932                	mv	s2,a2
  int tok;
  char *q, *eq;

  while(peek(ps, es, "<>")){
     5ac:	00001b97          	auipc	s7,0x1
     5b0:	e4cb8b93          	addi	s7,s7,-436 # 13f8 <lock_release+0x86>
    tok = gettoken(ps, es, 0, 0);
    if(gettoken(ps, es, &q, &eq) != 'a')
     5b4:	06100c13          	li	s8,97
      panic("missing file for redirection");
    switch(tok){
     5b8:	03c00c93          	li	s9,60
  while(peek(ps, es, "<>")){
     5bc:	a02d                	j	5e6 <parseredirs+0x5a>
      panic("missing file for redirection");
     5be:	00001517          	auipc	a0,0x1
     5c2:	e1a50513          	addi	a0,a0,-486 # 13d8 <lock_release+0x66>
     5c6:	00000097          	auipc	ra,0x0
     5ca:	a90080e7          	jalr	-1392(ra) # 56 <panic>
    case '<':
      cmd = redircmd(cmd, q, eq, O_RDONLY, 0);
     5ce:	4701                	li	a4,0
     5d0:	4681                	li	a3,0
     5d2:	f9043603          	ld	a2,-112(s0)
     5d6:	f9843583          	ld	a1,-104(s0)
     5da:	8552                	mv	a0,s4
     5dc:	00000097          	auipc	ra,0x0
     5e0:	cd2080e7          	jalr	-814(ra) # 2ae <redircmd>
     5e4:	8a2a                	mv	s4,a0
    switch(tok){
     5e6:	03e00b13          	li	s6,62
     5ea:	02b00a93          	li	s5,43
  while(peek(ps, es, "<>")){
     5ee:	865e                	mv	a2,s7
     5f0:	85ca                	mv	a1,s2
     5f2:	854e                	mv	a0,s3
     5f4:	00000097          	auipc	ra,0x0
     5f8:	f2c080e7          	jalr	-212(ra) # 520 <peek>
     5fc:	c925                	beqz	a0,66c <parseredirs+0xe0>
    tok = gettoken(ps, es, 0, 0);
     5fe:	4681                	li	a3,0
     600:	4601                	li	a2,0
     602:	85ca                	mv	a1,s2
     604:	854e                	mv	a0,s3
     606:	00000097          	auipc	ra,0x0
     60a:	dd8080e7          	jalr	-552(ra) # 3de <gettoken>
     60e:	84aa                	mv	s1,a0
    if(gettoken(ps, es, &q, &eq) != 'a')
     610:	f9040693          	addi	a3,s0,-112
     614:	f9840613          	addi	a2,s0,-104
     618:	85ca                	mv	a1,s2
     61a:	854e                	mv	a0,s3
     61c:	00000097          	auipc	ra,0x0
     620:	dc2080e7          	jalr	-574(ra) # 3de <gettoken>
     624:	f9851de3          	bne	a0,s8,5be <parseredirs+0x32>
    switch(tok){
     628:	fb9483e3          	beq	s1,s9,5ce <parseredirs+0x42>
     62c:	03648263          	beq	s1,s6,650 <parseredirs+0xc4>
     630:	fb549fe3          	bne	s1,s5,5ee <parseredirs+0x62>
      break;
    case '>':
      cmd = redircmd(cmd, q, eq, O_WRONLY|O_CREATE|O_TRUNC, 1);
      break;
    case '+':  // >>
      cmd = redircmd(cmd, q, eq, O_WRONLY|O_CREATE, 1);
     634:	4705                	li	a4,1
     636:	20100693          	li	a3,513
     63a:	f9043603          	ld	a2,-112(s0)
     63e:	f9843583          	ld	a1,-104(s0)
     642:	8552                	mv	a0,s4
     644:	00000097          	auipc	ra,0x0
     648:	c6a080e7          	jalr	-918(ra) # 2ae <redircmd>
     64c:	8a2a                	mv	s4,a0
      break;
     64e:	bf61                	j	5e6 <parseredirs+0x5a>
      cmd = redircmd(cmd, q, eq, O_WRONLY|O_CREATE|O_TRUNC, 1);
     650:	4705                	li	a4,1
     652:	60100693          	li	a3,1537
     656:	f9043603          	ld	a2,-112(s0)
     65a:	f9843583          	ld	a1,-104(s0)
     65e:	8552                	mv	a0,s4
     660:	00000097          	auipc	ra,0x0
     664:	c4e080e7          	jalr	-946(ra) # 2ae <redircmd>
     668:	8a2a                	mv	s4,a0
      break;
     66a:	bfb5                	j	5e6 <parseredirs+0x5a>
    }
  }
  return cmd;
}
     66c:	8552                	mv	a0,s4
     66e:	70a6                	ld	ra,104(sp)
     670:	7406                	ld	s0,96(sp)
     672:	64e6                	ld	s1,88(sp)
     674:	6946                	ld	s2,80(sp)
     676:	69a6                	ld	s3,72(sp)
     678:	6a06                	ld	s4,64(sp)
     67a:	7ae2                	ld	s5,56(sp)
     67c:	7b42                	ld	s6,48(sp)
     67e:	7ba2                	ld	s7,40(sp)
     680:	7c02                	ld	s8,32(sp)
     682:	6ce2                	ld	s9,24(sp)
     684:	6165                	addi	sp,sp,112
     686:	8082                	ret

0000000000000688 <parseexec>:
  return cmd;
}

struct cmd*
parseexec(char **ps, char *es)
{
     688:	7159                	addi	sp,sp,-112
     68a:	f486                	sd	ra,104(sp)
     68c:	f0a2                	sd	s0,96(sp)
     68e:	eca6                	sd	s1,88(sp)
     690:	e8ca                	sd	s2,80(sp)
     692:	e4ce                	sd	s3,72(sp)
     694:	e0d2                	sd	s4,64(sp)
     696:	fc56                	sd	s5,56(sp)
     698:	f85a                	sd	s6,48(sp)
     69a:	f45e                	sd	s7,40(sp)
     69c:	f062                	sd	s8,32(sp)
     69e:	ec66                	sd	s9,24(sp)
     6a0:	1880                	addi	s0,sp,112
     6a2:	8a2a                	mv	s4,a0
     6a4:	8aae                	mv	s5,a1
  char *q, *eq;
  int tok, argc;
  struct execcmd *cmd;
  struct cmd *ret;

  if(peek(ps, es, "("))
     6a6:	00001617          	auipc	a2,0x1
     6aa:	d5a60613          	addi	a2,a2,-678 # 1400 <lock_release+0x8e>
     6ae:	00000097          	auipc	ra,0x0
     6b2:	e72080e7          	jalr	-398(ra) # 520 <peek>
     6b6:	e905                	bnez	a0,6e6 <parseexec+0x5e>
     6b8:	89aa                	mv	s3,a0
    return parseblock(ps, es);

  ret = execcmd();
     6ba:	00000097          	auipc	ra,0x0
     6be:	bbe080e7          	jalr	-1090(ra) # 278 <execcmd>
     6c2:	8c2a                	mv	s8,a0
  cmd = (struct execcmd*)ret;

  argc = 0;
  ret = parseredirs(ret, ps, es);
     6c4:	8656                	mv	a2,s5
     6c6:	85d2                	mv	a1,s4
     6c8:	00000097          	auipc	ra,0x0
     6cc:	ec4080e7          	jalr	-316(ra) # 58c <parseredirs>
     6d0:	84aa                	mv	s1,a0
  while(!peek(ps, es, "|)&;")){
     6d2:	008c0913          	addi	s2,s8,8
     6d6:	00001b17          	auipc	s6,0x1
     6da:	d4ab0b13          	addi	s6,s6,-694 # 1420 <lock_release+0xae>
    if((tok=gettoken(ps, es, &q, &eq)) == 0)
      break;
    if(tok != 'a')
     6de:	06100c93          	li	s9,97
      panic("syntax");
    cmd->argv[argc] = q;
    cmd->eargv[argc] = eq;
    argc++;
    if(argc >= MAXARGS)
     6e2:	4ba9                	li	s7,10
  while(!peek(ps, es, "|)&;")){
     6e4:	a0b1                	j	730 <parseexec+0xa8>
    return parseblock(ps, es);
     6e6:	85d6                	mv	a1,s5
     6e8:	8552                	mv	a0,s4
     6ea:	00000097          	auipc	ra,0x0
     6ee:	1bc080e7          	jalr	444(ra) # 8a6 <parseblock>
     6f2:	84aa                	mv	s1,a0
    ret = parseredirs(ret, ps, es);
  }
  cmd->argv[argc] = 0;
  cmd->eargv[argc] = 0;
  return ret;
}
     6f4:	8526                	mv	a0,s1
     6f6:	70a6                	ld	ra,104(sp)
     6f8:	7406                	ld	s0,96(sp)
     6fa:	64e6                	ld	s1,88(sp)
     6fc:	6946                	ld	s2,80(sp)
     6fe:	69a6                	ld	s3,72(sp)
     700:	6a06                	ld	s4,64(sp)
     702:	7ae2                	ld	s5,56(sp)
     704:	7b42                	ld	s6,48(sp)
     706:	7ba2                	ld	s7,40(sp)
     708:	7c02                	ld	s8,32(sp)
     70a:	6ce2                	ld	s9,24(sp)
     70c:	6165                	addi	sp,sp,112
     70e:	8082                	ret
      panic("syntax");
     710:	00001517          	auipc	a0,0x1
     714:	cf850513          	addi	a0,a0,-776 # 1408 <lock_release+0x96>
     718:	00000097          	auipc	ra,0x0
     71c:	93e080e7          	jalr	-1730(ra) # 56 <panic>
    ret = parseredirs(ret, ps, es);
     720:	8656                	mv	a2,s5
     722:	85d2                	mv	a1,s4
     724:	8526                	mv	a0,s1
     726:	00000097          	auipc	ra,0x0
     72a:	e66080e7          	jalr	-410(ra) # 58c <parseredirs>
     72e:	84aa                	mv	s1,a0
  while(!peek(ps, es, "|)&;")){
     730:	865a                	mv	a2,s6
     732:	85d6                	mv	a1,s5
     734:	8552                	mv	a0,s4
     736:	00000097          	auipc	ra,0x0
     73a:	dea080e7          	jalr	-534(ra) # 520 <peek>
     73e:	e131                	bnez	a0,782 <parseexec+0xfa>
    if((tok=gettoken(ps, es, &q, &eq)) == 0)
     740:	f9040693          	addi	a3,s0,-112
     744:	f9840613          	addi	a2,s0,-104
     748:	85d6                	mv	a1,s5
     74a:	8552                	mv	a0,s4
     74c:	00000097          	auipc	ra,0x0
     750:	c92080e7          	jalr	-878(ra) # 3de <gettoken>
     754:	c51d                	beqz	a0,782 <parseexec+0xfa>
    if(tok != 'a')
     756:	fb951de3          	bne	a0,s9,710 <parseexec+0x88>
    cmd->argv[argc] = q;
     75a:	f9843783          	ld	a5,-104(s0)
     75e:	00f93023          	sd	a5,0(s2)
    cmd->eargv[argc] = eq;
     762:	f9043783          	ld	a5,-112(s0)
     766:	04f93823          	sd	a5,80(s2)
    argc++;
     76a:	2985                	addiw	s3,s3,1
    if(argc >= MAXARGS)
     76c:	0921                	addi	s2,s2,8
     76e:	fb7999e3          	bne	s3,s7,720 <parseexec+0x98>
      panic("too many args");
     772:	00001517          	auipc	a0,0x1
     776:	c9e50513          	addi	a0,a0,-866 # 1410 <lock_release+0x9e>
     77a:	00000097          	auipc	ra,0x0
     77e:	8dc080e7          	jalr	-1828(ra) # 56 <panic>
  cmd->argv[argc] = 0;
     782:	098e                	slli	s3,s3,0x3
     784:	9c4e                	add	s8,s8,s3
     786:	000c3423          	sd	zero,8(s8)
  cmd->eargv[argc] = 0;
     78a:	040c3c23          	sd	zero,88(s8)
  return ret;
     78e:	b79d                	j	6f4 <parseexec+0x6c>

0000000000000790 <parsepipe>:
{
     790:	7179                	addi	sp,sp,-48
     792:	f406                	sd	ra,40(sp)
     794:	f022                	sd	s0,32(sp)
     796:	ec26                	sd	s1,24(sp)
     798:	e84a                	sd	s2,16(sp)
     79a:	e44e                	sd	s3,8(sp)
     79c:	1800                	addi	s0,sp,48
     79e:	892a                	mv	s2,a0
     7a0:	89ae                	mv	s3,a1
  cmd = parseexec(ps, es);
     7a2:	00000097          	auipc	ra,0x0
     7a6:	ee6080e7          	jalr	-282(ra) # 688 <parseexec>
     7aa:	84aa                	mv	s1,a0
  if(peek(ps, es, "|")){
     7ac:	00001617          	auipc	a2,0x1
     7b0:	c7c60613          	addi	a2,a2,-900 # 1428 <lock_release+0xb6>
     7b4:	85ce                	mv	a1,s3
     7b6:	854a                	mv	a0,s2
     7b8:	00000097          	auipc	ra,0x0
     7bc:	d68080e7          	jalr	-664(ra) # 520 <peek>
     7c0:	e909                	bnez	a0,7d2 <parsepipe+0x42>
}
     7c2:	8526                	mv	a0,s1
     7c4:	70a2                	ld	ra,40(sp)
     7c6:	7402                	ld	s0,32(sp)
     7c8:	64e2                	ld	s1,24(sp)
     7ca:	6942                	ld	s2,16(sp)
     7cc:	69a2                	ld	s3,8(sp)
     7ce:	6145                	addi	sp,sp,48
     7d0:	8082                	ret
    gettoken(ps, es, 0, 0);
     7d2:	4681                	li	a3,0
     7d4:	4601                	li	a2,0
     7d6:	85ce                	mv	a1,s3
     7d8:	854a                	mv	a0,s2
     7da:	00000097          	auipc	ra,0x0
     7de:	c04080e7          	jalr	-1020(ra) # 3de <gettoken>
    cmd = pipecmd(cmd, parsepipe(ps, es));
     7e2:	85ce                	mv	a1,s3
     7e4:	854a                	mv	a0,s2
     7e6:	00000097          	auipc	ra,0x0
     7ea:	faa080e7          	jalr	-86(ra) # 790 <parsepipe>
     7ee:	85aa                	mv	a1,a0
     7f0:	8526                	mv	a0,s1
     7f2:	00000097          	auipc	ra,0x0
     7f6:	b24080e7          	jalr	-1244(ra) # 316 <pipecmd>
     7fa:	84aa                	mv	s1,a0
  return cmd;
     7fc:	b7d9                	j	7c2 <parsepipe+0x32>

00000000000007fe <parseline>:
{
     7fe:	7179                	addi	sp,sp,-48
     800:	f406                	sd	ra,40(sp)
     802:	f022                	sd	s0,32(sp)
     804:	ec26                	sd	s1,24(sp)
     806:	e84a                	sd	s2,16(sp)
     808:	e44e                	sd	s3,8(sp)
     80a:	e052                	sd	s4,0(sp)
     80c:	1800                	addi	s0,sp,48
     80e:	892a                	mv	s2,a0
     810:	89ae                	mv	s3,a1
  cmd = parsepipe(ps, es);
     812:	00000097          	auipc	ra,0x0
     816:	f7e080e7          	jalr	-130(ra) # 790 <parsepipe>
     81a:	84aa                	mv	s1,a0
  while(peek(ps, es, "&")){
     81c:	00001a17          	auipc	s4,0x1
     820:	c14a0a13          	addi	s4,s4,-1004 # 1430 <lock_release+0xbe>
     824:	a839                	j	842 <parseline+0x44>
    gettoken(ps, es, 0, 0);
     826:	4681                	li	a3,0
     828:	4601                	li	a2,0
     82a:	85ce                	mv	a1,s3
     82c:	854a                	mv	a0,s2
     82e:	00000097          	auipc	ra,0x0
     832:	bb0080e7          	jalr	-1104(ra) # 3de <gettoken>
    cmd = backcmd(cmd);
     836:	8526                	mv	a0,s1
     838:	00000097          	auipc	ra,0x0
     83c:	b6a080e7          	jalr	-1174(ra) # 3a2 <backcmd>
     840:	84aa                	mv	s1,a0
  while(peek(ps, es, "&")){
     842:	8652                	mv	a2,s4
     844:	85ce                	mv	a1,s3
     846:	854a                	mv	a0,s2
     848:	00000097          	auipc	ra,0x0
     84c:	cd8080e7          	jalr	-808(ra) # 520 <peek>
     850:	f979                	bnez	a0,826 <parseline+0x28>
  if(peek(ps, es, ";")){
     852:	00001617          	auipc	a2,0x1
     856:	be660613          	addi	a2,a2,-1050 # 1438 <lock_release+0xc6>
     85a:	85ce                	mv	a1,s3
     85c:	854a                	mv	a0,s2
     85e:	00000097          	auipc	ra,0x0
     862:	cc2080e7          	jalr	-830(ra) # 520 <peek>
     866:	e911                	bnez	a0,87a <parseline+0x7c>
}
     868:	8526                	mv	a0,s1
     86a:	70a2                	ld	ra,40(sp)
     86c:	7402                	ld	s0,32(sp)
     86e:	64e2                	ld	s1,24(sp)
     870:	6942                	ld	s2,16(sp)
     872:	69a2                	ld	s3,8(sp)
     874:	6a02                	ld	s4,0(sp)
     876:	6145                	addi	sp,sp,48
     878:	8082                	ret
    gettoken(ps, es, 0, 0);
     87a:	4681                	li	a3,0
     87c:	4601                	li	a2,0
     87e:	85ce                	mv	a1,s3
     880:	854a                	mv	a0,s2
     882:	00000097          	auipc	ra,0x0
     886:	b5c080e7          	jalr	-1188(ra) # 3de <gettoken>
    cmd = listcmd(cmd, parseline(ps, es));
     88a:	85ce                	mv	a1,s3
     88c:	854a                	mv	a0,s2
     88e:	00000097          	auipc	ra,0x0
     892:	f70080e7          	jalr	-144(ra) # 7fe <parseline>
     896:	85aa                	mv	a1,a0
     898:	8526                	mv	a0,s1
     89a:	00000097          	auipc	ra,0x0
     89e:	ac2080e7          	jalr	-1342(ra) # 35c <listcmd>
     8a2:	84aa                	mv	s1,a0
  return cmd;
     8a4:	b7d1                	j	868 <parseline+0x6a>

00000000000008a6 <parseblock>:
{
     8a6:	7179                	addi	sp,sp,-48
     8a8:	f406                	sd	ra,40(sp)
     8aa:	f022                	sd	s0,32(sp)
     8ac:	ec26                	sd	s1,24(sp)
     8ae:	e84a                	sd	s2,16(sp)
     8b0:	e44e                	sd	s3,8(sp)
     8b2:	1800                	addi	s0,sp,48
     8b4:	84aa                	mv	s1,a0
     8b6:	892e                	mv	s2,a1
  if(!peek(ps, es, "("))
     8b8:	00001617          	auipc	a2,0x1
     8bc:	b4860613          	addi	a2,a2,-1208 # 1400 <lock_release+0x8e>
     8c0:	00000097          	auipc	ra,0x0
     8c4:	c60080e7          	jalr	-928(ra) # 520 <peek>
     8c8:	c12d                	beqz	a0,92a <parseblock+0x84>
  gettoken(ps, es, 0, 0);
     8ca:	4681                	li	a3,0
     8cc:	4601                	li	a2,0
     8ce:	85ca                	mv	a1,s2
     8d0:	8526                	mv	a0,s1
     8d2:	00000097          	auipc	ra,0x0
     8d6:	b0c080e7          	jalr	-1268(ra) # 3de <gettoken>
  cmd = parseline(ps, es);
     8da:	85ca                	mv	a1,s2
     8dc:	8526                	mv	a0,s1
     8de:	00000097          	auipc	ra,0x0
     8e2:	f20080e7          	jalr	-224(ra) # 7fe <parseline>
     8e6:	89aa                	mv	s3,a0
  if(!peek(ps, es, ")"))
     8e8:	00001617          	auipc	a2,0x1
     8ec:	b6860613          	addi	a2,a2,-1176 # 1450 <lock_release+0xde>
     8f0:	85ca                	mv	a1,s2
     8f2:	8526                	mv	a0,s1
     8f4:	00000097          	auipc	ra,0x0
     8f8:	c2c080e7          	jalr	-980(ra) # 520 <peek>
     8fc:	cd1d                	beqz	a0,93a <parseblock+0x94>
  gettoken(ps, es, 0, 0);
     8fe:	4681                	li	a3,0
     900:	4601                	li	a2,0
     902:	85ca                	mv	a1,s2
     904:	8526                	mv	a0,s1
     906:	00000097          	auipc	ra,0x0
     90a:	ad8080e7          	jalr	-1320(ra) # 3de <gettoken>
  cmd = parseredirs(cmd, ps, es);
     90e:	864a                	mv	a2,s2
     910:	85a6                	mv	a1,s1
     912:	854e                	mv	a0,s3
     914:	00000097          	auipc	ra,0x0
     918:	c78080e7          	jalr	-904(ra) # 58c <parseredirs>
}
     91c:	70a2                	ld	ra,40(sp)
     91e:	7402                	ld	s0,32(sp)
     920:	64e2                	ld	s1,24(sp)
     922:	6942                	ld	s2,16(sp)
     924:	69a2                	ld	s3,8(sp)
     926:	6145                	addi	sp,sp,48
     928:	8082                	ret
    panic("parseblock");
     92a:	00001517          	auipc	a0,0x1
     92e:	b1650513          	addi	a0,a0,-1258 # 1440 <lock_release+0xce>
     932:	fffff097          	auipc	ra,0xfffff
     936:	724080e7          	jalr	1828(ra) # 56 <panic>
    panic("syntax - missing )");
     93a:	00001517          	auipc	a0,0x1
     93e:	b1e50513          	addi	a0,a0,-1250 # 1458 <lock_release+0xe6>
     942:	fffff097          	auipc	ra,0xfffff
     946:	714080e7          	jalr	1812(ra) # 56 <panic>

000000000000094a <nulterminate>:

// NUL-terminate all the counted strings.
struct cmd*
nulterminate(struct cmd *cmd)
{
     94a:	1101                	addi	sp,sp,-32
     94c:	ec06                	sd	ra,24(sp)
     94e:	e822                	sd	s0,16(sp)
     950:	e426                	sd	s1,8(sp)
     952:	1000                	addi	s0,sp,32
     954:	84aa                	mv	s1,a0
  struct execcmd *ecmd;
  struct listcmd *lcmd;
  struct pipecmd *pcmd;
  struct redircmd *rcmd;

  if(cmd == 0)
     956:	c521                	beqz	a0,99e <nulterminate+0x54>
    return 0;

  switch(cmd->type){
     958:	4118                	lw	a4,0(a0)
     95a:	4795                	li	a5,5
     95c:	04e7e163          	bltu	a5,a4,99e <nulterminate+0x54>
     960:	00056783          	lwu	a5,0(a0)
     964:	078a                	slli	a5,a5,0x2
     966:	00001717          	auipc	a4,0x1
     96a:	b5270713          	addi	a4,a4,-1198 # 14b8 <lock_release+0x146>
     96e:	97ba                	add	a5,a5,a4
     970:	439c                	lw	a5,0(a5)
     972:	97ba                	add	a5,a5,a4
     974:	8782                	jr	a5
  case EXEC:
    ecmd = (struct execcmd*)cmd;
    for(i=0; ecmd->argv[i]; i++)
     976:	651c                	ld	a5,8(a0)
     978:	c39d                	beqz	a5,99e <nulterminate+0x54>
     97a:	01050793          	addi	a5,a0,16
      *ecmd->eargv[i] = 0;
     97e:	67b8                	ld	a4,72(a5)
     980:	00070023          	sb	zero,0(a4)
    for(i=0; ecmd->argv[i]; i++)
     984:	07a1                	addi	a5,a5,8
     986:	ff87b703          	ld	a4,-8(a5)
     98a:	fb75                	bnez	a4,97e <nulterminate+0x34>
     98c:	a809                	j	99e <nulterminate+0x54>
    break;

  case REDIR:
    rcmd = (struct redircmd*)cmd;
    nulterminate(rcmd->cmd);
     98e:	6508                	ld	a0,8(a0)
     990:	00000097          	auipc	ra,0x0
     994:	fba080e7          	jalr	-70(ra) # 94a <nulterminate>
    *rcmd->efile = 0;
     998:	6c9c                	ld	a5,24(s1)
     99a:	00078023          	sb	zero,0(a5)
    bcmd = (struct backcmd*)cmd;
    nulterminate(bcmd->cmd);
    break;
  }
  return cmd;
}
     99e:	8526                	mv	a0,s1
     9a0:	60e2                	ld	ra,24(sp)
     9a2:	6442                	ld	s0,16(sp)
     9a4:	64a2                	ld	s1,8(sp)
     9a6:	6105                	addi	sp,sp,32
     9a8:	8082                	ret
    nulterminate(pcmd->left);
     9aa:	6508                	ld	a0,8(a0)
     9ac:	00000097          	auipc	ra,0x0
     9b0:	f9e080e7          	jalr	-98(ra) # 94a <nulterminate>
    nulterminate(pcmd->right);
     9b4:	6888                	ld	a0,16(s1)
     9b6:	00000097          	auipc	ra,0x0
     9ba:	f94080e7          	jalr	-108(ra) # 94a <nulterminate>
    break;
     9be:	b7c5                	j	99e <nulterminate+0x54>
    nulterminate(lcmd->left);
     9c0:	6508                	ld	a0,8(a0)
     9c2:	00000097          	auipc	ra,0x0
     9c6:	f88080e7          	jalr	-120(ra) # 94a <nulterminate>
    nulterminate(lcmd->right);
     9ca:	6888                	ld	a0,16(s1)
     9cc:	00000097          	auipc	ra,0x0
     9d0:	f7e080e7          	jalr	-130(ra) # 94a <nulterminate>
    break;
     9d4:	b7e9                	j	99e <nulterminate+0x54>
    nulterminate(bcmd->cmd);
     9d6:	6508                	ld	a0,8(a0)
     9d8:	00000097          	auipc	ra,0x0
     9dc:	f72080e7          	jalr	-142(ra) # 94a <nulterminate>
    break;
     9e0:	bf7d                	j	99e <nulterminate+0x54>

00000000000009e2 <parsecmd>:
{
     9e2:	7179                	addi	sp,sp,-48
     9e4:	f406                	sd	ra,40(sp)
     9e6:	f022                	sd	s0,32(sp)
     9e8:	ec26                	sd	s1,24(sp)
     9ea:	e84a                	sd	s2,16(sp)
     9ec:	1800                	addi	s0,sp,48
     9ee:	fca43c23          	sd	a0,-40(s0)
  es = s + strlen(s);
     9f2:	84aa                	mv	s1,a0
     9f4:	00000097          	auipc	ra,0x0
     9f8:	1cc080e7          	jalr	460(ra) # bc0 <strlen>
     9fc:	1502                	slli	a0,a0,0x20
     9fe:	9101                	srli	a0,a0,0x20
     a00:	94aa                	add	s1,s1,a0
  cmd = parseline(&s, es);
     a02:	85a6                	mv	a1,s1
     a04:	fd840513          	addi	a0,s0,-40
     a08:	00000097          	auipc	ra,0x0
     a0c:	df6080e7          	jalr	-522(ra) # 7fe <parseline>
     a10:	892a                	mv	s2,a0
  peek(&s, es, "");
     a12:	00001617          	auipc	a2,0x1
     a16:	a5e60613          	addi	a2,a2,-1442 # 1470 <lock_release+0xfe>
     a1a:	85a6                	mv	a1,s1
     a1c:	fd840513          	addi	a0,s0,-40
     a20:	00000097          	auipc	ra,0x0
     a24:	b00080e7          	jalr	-1280(ra) # 520 <peek>
  if(s != es){
     a28:	fd843603          	ld	a2,-40(s0)
     a2c:	00961e63          	bne	a2,s1,a48 <parsecmd+0x66>
  nulterminate(cmd);
     a30:	854a                	mv	a0,s2
     a32:	00000097          	auipc	ra,0x0
     a36:	f18080e7          	jalr	-232(ra) # 94a <nulterminate>
}
     a3a:	854a                	mv	a0,s2
     a3c:	70a2                	ld	ra,40(sp)
     a3e:	7402                	ld	s0,32(sp)
     a40:	64e2                	ld	s1,24(sp)
     a42:	6942                	ld	s2,16(sp)
     a44:	6145                	addi	sp,sp,48
     a46:	8082                	ret
    fprintf(2, "leftovers: %s\n", s);
     a48:	00001597          	auipc	a1,0x1
     a4c:	a3058593          	addi	a1,a1,-1488 # 1478 <lock_release+0x106>
     a50:	4509                	li	a0,2
     a52:	00000097          	auipc	ra,0x0
     a56:	6e6080e7          	jalr	1766(ra) # 1138 <fprintf>
    panic("syntax");
     a5a:	00001517          	auipc	a0,0x1
     a5e:	9ae50513          	addi	a0,a0,-1618 # 1408 <lock_release+0x96>
     a62:	fffff097          	auipc	ra,0xfffff
     a66:	5f4080e7          	jalr	1524(ra) # 56 <panic>

0000000000000a6a <main>:
{
     a6a:	7139                	addi	sp,sp,-64
     a6c:	fc06                	sd	ra,56(sp)
     a6e:	f822                	sd	s0,48(sp)
     a70:	f426                	sd	s1,40(sp)
     a72:	f04a                	sd	s2,32(sp)
     a74:	ec4e                	sd	s3,24(sp)
     a76:	e852                	sd	s4,16(sp)
     a78:	e456                	sd	s5,8(sp)
     a7a:	0080                	addi	s0,sp,64
  while((fd = open("console", O_RDWR)) >= 0){
     a7c:	00001497          	auipc	s1,0x1
     a80:	a0c48493          	addi	s1,s1,-1524 # 1488 <lock_release+0x116>
     a84:	4589                	li	a1,2
     a86:	8526                	mv	a0,s1
     a88:	00000097          	auipc	ra,0x0
     a8c:	39c080e7          	jalr	924(ra) # e24 <open>
     a90:	00054963          	bltz	a0,aa2 <main+0x38>
    if(fd >= 3){
     a94:	4789                	li	a5,2
     a96:	fea7d7e3          	bge	a5,a0,a84 <main+0x1a>
      close(fd);
     a9a:	00000097          	auipc	ra,0x0
     a9e:	372080e7          	jalr	882(ra) # e0c <close>
  while(getcmd(buf, sizeof(buf)) >= 0){
     aa2:	00001497          	auipc	s1,0x1
     aa6:	57e48493          	addi	s1,s1,1406 # 2020 <buf.0>
    if(buf[0] == 'c' && buf[1] == 'd' && buf[2] == ' '){
     aaa:	06300913          	li	s2,99
     aae:	02000993          	li	s3,32
      if(chdir(buf+3) < 0)
     ab2:	00001a17          	auipc	s4,0x1
     ab6:	571a0a13          	addi	s4,s4,1393 # 2023 <buf.0+0x3>
        fprintf(2, "cannot cd %s\n", buf+3);
     aba:	00001a97          	auipc	s5,0x1
     abe:	9d6a8a93          	addi	s5,s5,-1578 # 1490 <lock_release+0x11e>
     ac2:	a819                	j	ad8 <main+0x6e>
    if(fork1() == 0)
     ac4:	fffff097          	auipc	ra,0xfffff
     ac8:	5b8080e7          	jalr	1464(ra) # 7c <fork1>
     acc:	c925                	beqz	a0,b3c <main+0xd2>
    wait(0);
     ace:	4501                	li	a0,0
     ad0:	00000097          	auipc	ra,0x0
     ad4:	31c080e7          	jalr	796(ra) # dec <wait>
  while(getcmd(buf, sizeof(buf)) >= 0){
     ad8:	06400593          	li	a1,100
     adc:	8526                	mv	a0,s1
     ade:	fffff097          	auipc	ra,0xfffff
     ae2:	522080e7          	jalr	1314(ra) # 0 <getcmd>
     ae6:	06054763          	bltz	a0,b54 <main+0xea>
    if(buf[0] == 'c' && buf[1] == 'd' && buf[2] == ' '){
     aea:	0004c783          	lbu	a5,0(s1)
     aee:	fd279be3          	bne	a5,s2,ac4 <main+0x5a>
     af2:	0014c703          	lbu	a4,1(s1)
     af6:	06400793          	li	a5,100
     afa:	fcf715e3          	bne	a4,a5,ac4 <main+0x5a>
     afe:	0024c783          	lbu	a5,2(s1)
     b02:	fd3791e3          	bne	a5,s3,ac4 <main+0x5a>
      buf[strlen(buf)-1] = 0;  // chop \n
     b06:	8526                	mv	a0,s1
     b08:	00000097          	auipc	ra,0x0
     b0c:	0b8080e7          	jalr	184(ra) # bc0 <strlen>
     b10:	fff5079b          	addiw	a5,a0,-1
     b14:	1782                	slli	a5,a5,0x20
     b16:	9381                	srli	a5,a5,0x20
     b18:	97a6                	add	a5,a5,s1
     b1a:	00078023          	sb	zero,0(a5)
      if(chdir(buf+3) < 0)
     b1e:	8552                	mv	a0,s4
     b20:	00000097          	auipc	ra,0x0
     b24:	334080e7          	jalr	820(ra) # e54 <chdir>
     b28:	fa0558e3          	bgez	a0,ad8 <main+0x6e>
        fprintf(2, "cannot cd %s\n", buf+3);
     b2c:	8652                	mv	a2,s4
     b2e:	85d6                	mv	a1,s5
     b30:	4509                	li	a0,2
     b32:	00000097          	auipc	ra,0x0
     b36:	606080e7          	jalr	1542(ra) # 1138 <fprintf>
     b3a:	bf79                	j	ad8 <main+0x6e>
      runcmd(parsecmd(buf));
     b3c:	00001517          	auipc	a0,0x1
     b40:	4e450513          	addi	a0,a0,1252 # 2020 <buf.0>
     b44:	00000097          	auipc	ra,0x0
     b48:	e9e080e7          	jalr	-354(ra) # 9e2 <parsecmd>
     b4c:	fffff097          	auipc	ra,0xfffff
     b50:	55e080e7          	jalr	1374(ra) # aa <runcmd>
  exit(0);
     b54:	4501                	li	a0,0
     b56:	00000097          	auipc	ra,0x0
     b5a:	28e080e7          	jalr	654(ra) # de4 <exit>

0000000000000b5e <_main>:
//
// wrapper so that it's OK if main() does not call exit().
//
void
_main()
{
     b5e:	1141                	addi	sp,sp,-16
     b60:	e406                	sd	ra,8(sp)
     b62:	e022                	sd	s0,0(sp)
     b64:	0800                	addi	s0,sp,16
  extern int main();
  main();
     b66:	00000097          	auipc	ra,0x0
     b6a:	f04080e7          	jalr	-252(ra) # a6a <main>
  exit(0);
     b6e:	4501                	li	a0,0
     b70:	00000097          	auipc	ra,0x0
     b74:	274080e7          	jalr	628(ra) # de4 <exit>

0000000000000b78 <strcpy>:
}

char*
strcpy(char *s, const char *t)
{
     b78:	1141                	addi	sp,sp,-16
     b7a:	e422                	sd	s0,8(sp)
     b7c:	0800                	addi	s0,sp,16
  char *os;

  os = s;
  while((*s++ = *t++) != 0)
     b7e:	87aa                	mv	a5,a0
     b80:	0585                	addi	a1,a1,1
     b82:	0785                	addi	a5,a5,1
     b84:	fff5c703          	lbu	a4,-1(a1)
     b88:	fee78fa3          	sb	a4,-1(a5)
     b8c:	fb75                	bnez	a4,b80 <strcpy+0x8>
    ;
  return os;
}
     b8e:	6422                	ld	s0,8(sp)
     b90:	0141                	addi	sp,sp,16
     b92:	8082                	ret

0000000000000b94 <strcmp>:

int
strcmp(const char *p, const char *q)
{
     b94:	1141                	addi	sp,sp,-16
     b96:	e422                	sd	s0,8(sp)
     b98:	0800                	addi	s0,sp,16
  while(*p && *p == *q)
     b9a:	00054783          	lbu	a5,0(a0)
     b9e:	cb91                	beqz	a5,bb2 <strcmp+0x1e>
     ba0:	0005c703          	lbu	a4,0(a1)
     ba4:	00f71763          	bne	a4,a5,bb2 <strcmp+0x1e>
    p++, q++;
     ba8:	0505                	addi	a0,a0,1
     baa:	0585                	addi	a1,a1,1
  while(*p && *p == *q)
     bac:	00054783          	lbu	a5,0(a0)
     bb0:	fbe5                	bnez	a5,ba0 <strcmp+0xc>
  return (uchar)*p - (uchar)*q;
     bb2:	0005c503          	lbu	a0,0(a1)
}
     bb6:	40a7853b          	subw	a0,a5,a0
     bba:	6422                	ld	s0,8(sp)
     bbc:	0141                	addi	sp,sp,16
     bbe:	8082                	ret

0000000000000bc0 <strlen>:

uint
strlen(const char *s)
{
     bc0:	1141                	addi	sp,sp,-16
     bc2:	e422                	sd	s0,8(sp)
     bc4:	0800                	addi	s0,sp,16
  int n;

  for(n = 0; s[n]; n++)
     bc6:	00054783          	lbu	a5,0(a0)
     bca:	cf91                	beqz	a5,be6 <strlen+0x26>
     bcc:	0505                	addi	a0,a0,1
     bce:	87aa                	mv	a5,a0
     bd0:	4685                	li	a3,1
     bd2:	9e89                	subw	a3,a3,a0
     bd4:	00f6853b          	addw	a0,a3,a5
     bd8:	0785                	addi	a5,a5,1
     bda:	fff7c703          	lbu	a4,-1(a5)
     bde:	fb7d                	bnez	a4,bd4 <strlen+0x14>
    ;
  return n;
}
     be0:	6422                	ld	s0,8(sp)
     be2:	0141                	addi	sp,sp,16
     be4:	8082                	ret
  for(n = 0; s[n]; n++)
     be6:	4501                	li	a0,0
     be8:	bfe5                	j	be0 <strlen+0x20>

0000000000000bea <memset>:

void*
memset(void *dst, int c, uint n)
{
     bea:	1141                	addi	sp,sp,-16
     bec:	e422                	sd	s0,8(sp)
     bee:	0800                	addi	s0,sp,16
  char *cdst = (char *) dst;
  int i;
  for(i = 0; i < n; i++){
     bf0:	ca19                	beqz	a2,c06 <memset+0x1c>
     bf2:	87aa                	mv	a5,a0
     bf4:	1602                	slli	a2,a2,0x20
     bf6:	9201                	srli	a2,a2,0x20
     bf8:	00a60733          	add	a4,a2,a0
    cdst[i] = c;
     bfc:	00b78023          	sb	a1,0(a5)
  for(i = 0; i < n; i++){
     c00:	0785                	addi	a5,a5,1
     c02:	fee79de3          	bne	a5,a4,bfc <memset+0x12>
  }
  return dst;
}
     c06:	6422                	ld	s0,8(sp)
     c08:	0141                	addi	sp,sp,16
     c0a:	8082                	ret

0000000000000c0c <strchr>:

char*
strchr(const char *s, char c)
{
     c0c:	1141                	addi	sp,sp,-16
     c0e:	e422                	sd	s0,8(sp)
     c10:	0800                	addi	s0,sp,16
  for(; *s; s++)
     c12:	00054783          	lbu	a5,0(a0)
     c16:	cb99                	beqz	a5,c2c <strchr+0x20>
    if(*s == c)
     c18:	00f58763          	beq	a1,a5,c26 <strchr+0x1a>
  for(; *s; s++)
     c1c:	0505                	addi	a0,a0,1
     c1e:	00054783          	lbu	a5,0(a0)
     c22:	fbfd                	bnez	a5,c18 <strchr+0xc>
      return (char*)s;
  return 0;
     c24:	4501                	li	a0,0
}
     c26:	6422                	ld	s0,8(sp)
     c28:	0141                	addi	sp,sp,16
     c2a:	8082                	ret
  return 0;
     c2c:	4501                	li	a0,0
     c2e:	bfe5                	j	c26 <strchr+0x1a>

0000000000000c30 <gets>:

char*
gets(char *buf, int max)
{
     c30:	711d                	addi	sp,sp,-96
     c32:	ec86                	sd	ra,88(sp)
     c34:	e8a2                	sd	s0,80(sp)
     c36:	e4a6                	sd	s1,72(sp)
     c38:	e0ca                	sd	s2,64(sp)
     c3a:	fc4e                	sd	s3,56(sp)
     c3c:	f852                	sd	s4,48(sp)
     c3e:	f456                	sd	s5,40(sp)
     c40:	f05a                	sd	s6,32(sp)
     c42:	ec5e                	sd	s7,24(sp)
     c44:	1080                	addi	s0,sp,96
     c46:	8baa                	mv	s7,a0
     c48:	8a2e                	mv	s4,a1
  int i, cc;
  char c;

  for(i=0; i+1 < max; ){
     c4a:	892a                	mv	s2,a0
     c4c:	4481                	li	s1,0
    cc = read(0, &c, 1);
    if(cc < 1)
      break;
    buf[i++] = c;
    if(c == '\n' || c == '\r')
     c4e:	4aa9                	li	s5,10
     c50:	4b35                	li	s6,13
  for(i=0; i+1 < max; ){
     c52:	89a6                	mv	s3,s1
     c54:	2485                	addiw	s1,s1,1
     c56:	0344d863          	bge	s1,s4,c86 <gets+0x56>
    cc = read(0, &c, 1);
     c5a:	4605                	li	a2,1
     c5c:	faf40593          	addi	a1,s0,-81
     c60:	4501                	li	a0,0
     c62:	00000097          	auipc	ra,0x0
     c66:	19a080e7          	jalr	410(ra) # dfc <read>
    if(cc < 1)
     c6a:	00a05e63          	blez	a0,c86 <gets+0x56>
    buf[i++] = c;
     c6e:	faf44783          	lbu	a5,-81(s0)
     c72:	00f90023          	sb	a5,0(s2)
    if(c == '\n' || c == '\r')
     c76:	01578763          	beq	a5,s5,c84 <gets+0x54>
     c7a:	0905                	addi	s2,s2,1
     c7c:	fd679be3          	bne	a5,s6,c52 <gets+0x22>
  for(i=0; i+1 < max; ){
     c80:	89a6                	mv	s3,s1
     c82:	a011                	j	c86 <gets+0x56>
     c84:	89a6                	mv	s3,s1
      break;
  }
  buf[i] = '\0';
     c86:	99de                	add	s3,s3,s7
     c88:	00098023          	sb	zero,0(s3)
  return buf;
}
     c8c:	855e                	mv	a0,s7
     c8e:	60e6                	ld	ra,88(sp)
     c90:	6446                	ld	s0,80(sp)
     c92:	64a6                	ld	s1,72(sp)
     c94:	6906                	ld	s2,64(sp)
     c96:	79e2                	ld	s3,56(sp)
     c98:	7a42                	ld	s4,48(sp)
     c9a:	7aa2                	ld	s5,40(sp)
     c9c:	7b02                	ld	s6,32(sp)
     c9e:	6be2                	ld	s7,24(sp)
     ca0:	6125                	addi	sp,sp,96
     ca2:	8082                	ret

0000000000000ca4 <stat>:

int
stat(const char *n, struct stat *st)
{
     ca4:	1101                	addi	sp,sp,-32
     ca6:	ec06                	sd	ra,24(sp)
     ca8:	e822                	sd	s0,16(sp)
     caa:	e426                	sd	s1,8(sp)
     cac:	e04a                	sd	s2,0(sp)
     cae:	1000                	addi	s0,sp,32
     cb0:	892e                	mv	s2,a1
  int fd;
  int r;

  fd = open(n, O_RDONLY);
     cb2:	4581                	li	a1,0
     cb4:	00000097          	auipc	ra,0x0
     cb8:	170080e7          	jalr	368(ra) # e24 <open>
  if(fd < 0)
     cbc:	02054563          	bltz	a0,ce6 <stat+0x42>
     cc0:	84aa                	mv	s1,a0
    return -1;
  r = fstat(fd, st);
     cc2:	85ca                	mv	a1,s2
     cc4:	00000097          	auipc	ra,0x0
     cc8:	178080e7          	jalr	376(ra) # e3c <fstat>
     ccc:	892a                	mv	s2,a0
  close(fd);
     cce:	8526                	mv	a0,s1
     cd0:	00000097          	auipc	ra,0x0
     cd4:	13c080e7          	jalr	316(ra) # e0c <close>
  return r;
}
     cd8:	854a                	mv	a0,s2
     cda:	60e2                	ld	ra,24(sp)
     cdc:	6442                	ld	s0,16(sp)
     cde:	64a2                	ld	s1,8(sp)
     ce0:	6902                	ld	s2,0(sp)
     ce2:	6105                	addi	sp,sp,32
     ce4:	8082                	ret
    return -1;
     ce6:	597d                	li	s2,-1
     ce8:	bfc5                	j	cd8 <stat+0x34>

0000000000000cea <atoi>:

int
atoi(const char *s)
{
     cea:	1141                	addi	sp,sp,-16
     cec:	e422                	sd	s0,8(sp)
     cee:	0800                	addi	s0,sp,16
  int n;

  n = 0;
  while('0' <= *s && *s <= '9')
     cf0:	00054683          	lbu	a3,0(a0)
     cf4:	fd06879b          	addiw	a5,a3,-48
     cf8:	0ff7f793          	zext.b	a5,a5
     cfc:	4625                	li	a2,9
     cfe:	02f66863          	bltu	a2,a5,d2e <atoi+0x44>
     d02:	872a                	mv	a4,a0
  n = 0;
     d04:	4501                	li	a0,0
    n = n*10 + *s++ - '0';
     d06:	0705                	addi	a4,a4,1
     d08:	0025179b          	slliw	a5,a0,0x2
     d0c:	9fa9                	addw	a5,a5,a0
     d0e:	0017979b          	slliw	a5,a5,0x1
     d12:	9fb5                	addw	a5,a5,a3
     d14:	fd07851b          	addiw	a0,a5,-48
  while('0' <= *s && *s <= '9')
     d18:	00074683          	lbu	a3,0(a4)
     d1c:	fd06879b          	addiw	a5,a3,-48
     d20:	0ff7f793          	zext.b	a5,a5
     d24:	fef671e3          	bgeu	a2,a5,d06 <atoi+0x1c>
  return n;
}
     d28:	6422                	ld	s0,8(sp)
     d2a:	0141                	addi	sp,sp,16
     d2c:	8082                	ret
  n = 0;
     d2e:	4501                	li	a0,0
     d30:	bfe5                	j	d28 <atoi+0x3e>

0000000000000d32 <memmove>:

void*
memmove(void *vdst, const void *vsrc, int n)
{
     d32:	1141                	addi	sp,sp,-16
     d34:	e422                	sd	s0,8(sp)
     d36:	0800                	addi	s0,sp,16
  char *dst;
  const char *src;

  dst = vdst;
  src = vsrc;
  if (src > dst) {
     d38:	02b57463          	bgeu	a0,a1,d60 <memmove+0x2e>
    while(n-- > 0)
     d3c:	00c05f63          	blez	a2,d5a <memmove+0x28>
     d40:	1602                	slli	a2,a2,0x20
     d42:	9201                	srli	a2,a2,0x20
     d44:	00c507b3          	add	a5,a0,a2
  dst = vdst;
     d48:	872a                	mv	a4,a0
      *dst++ = *src++;
     d4a:	0585                	addi	a1,a1,1
     d4c:	0705                	addi	a4,a4,1
     d4e:	fff5c683          	lbu	a3,-1(a1)
     d52:	fed70fa3          	sb	a3,-1(a4)
    while(n-- > 0)
     d56:	fee79ae3          	bne	a5,a4,d4a <memmove+0x18>
    src += n;
    while(n-- > 0)
      *--dst = *--src;
  }
  return vdst;
}
     d5a:	6422                	ld	s0,8(sp)
     d5c:	0141                	addi	sp,sp,16
     d5e:	8082                	ret
    dst += n;
     d60:	00c50733          	add	a4,a0,a2
    src += n;
     d64:	95b2                	add	a1,a1,a2
    while(n-- > 0)
     d66:	fec05ae3          	blez	a2,d5a <memmove+0x28>
     d6a:	fff6079b          	addiw	a5,a2,-1
     d6e:	1782                	slli	a5,a5,0x20
     d70:	9381                	srli	a5,a5,0x20
     d72:	fff7c793          	not	a5,a5
     d76:	97ba                	add	a5,a5,a4
      *--dst = *--src;
     d78:	15fd                	addi	a1,a1,-1
     d7a:	177d                	addi	a4,a4,-1
     d7c:	0005c683          	lbu	a3,0(a1)
     d80:	00d70023          	sb	a3,0(a4)
    while(n-- > 0)
     d84:	fee79ae3          	bne	a5,a4,d78 <memmove+0x46>
     d88:	bfc9                	j	d5a <memmove+0x28>

0000000000000d8a <memcmp>:

int
memcmp(const void *s1, const void *s2, uint n)
{
     d8a:	1141                	addi	sp,sp,-16
     d8c:	e422                	sd	s0,8(sp)
     d8e:	0800                	addi	s0,sp,16
  const char *p1 = s1, *p2 = s2;
  while (n-- > 0) {
     d90:	ca05                	beqz	a2,dc0 <memcmp+0x36>
     d92:	fff6069b          	addiw	a3,a2,-1
     d96:	1682                	slli	a3,a3,0x20
     d98:	9281                	srli	a3,a3,0x20
     d9a:	0685                	addi	a3,a3,1
     d9c:	96aa                	add	a3,a3,a0
    if (*p1 != *p2) {
     d9e:	00054783          	lbu	a5,0(a0)
     da2:	0005c703          	lbu	a4,0(a1)
     da6:	00e79863          	bne	a5,a4,db6 <memcmp+0x2c>
      return *p1 - *p2;
    }
    p1++;
     daa:	0505                	addi	a0,a0,1
    p2++;
     dac:	0585                	addi	a1,a1,1
  while (n-- > 0) {
     dae:	fed518e3          	bne	a0,a3,d9e <memcmp+0x14>
  }
  return 0;
     db2:	4501                	li	a0,0
     db4:	a019                	j	dba <memcmp+0x30>
      return *p1 - *p2;
     db6:	40e7853b          	subw	a0,a5,a4
}
     dba:	6422                	ld	s0,8(sp)
     dbc:	0141                	addi	sp,sp,16
     dbe:	8082                	ret
  return 0;
     dc0:	4501                	li	a0,0
     dc2:	bfe5                	j	dba <memcmp+0x30>

0000000000000dc4 <memcpy>:

void *
memcpy(void *dst, const void *src, uint n)
{
     dc4:	1141                	addi	sp,sp,-16
     dc6:	e406                	sd	ra,8(sp)
     dc8:	e022                	sd	s0,0(sp)
     dca:	0800                	addi	s0,sp,16
  return memmove(dst, src, n);
     dcc:	00000097          	auipc	ra,0x0
     dd0:	f66080e7          	jalr	-154(ra) # d32 <memmove>
}
     dd4:	60a2                	ld	ra,8(sp)
     dd6:	6402                	ld	s0,0(sp)
     dd8:	0141                	addi	sp,sp,16
     dda:	8082                	ret

0000000000000ddc <fork>:
# generated by usys.pl - do not edit
#include "kernel/syscall.h"
.global fork
fork:
 li a7, SYS_fork
     ddc:	4885                	li	a7,1
 ecall
     dde:	00000073          	ecall
 ret
     de2:	8082                	ret

0000000000000de4 <exit>:
.global exit
exit:
 li a7, SYS_exit
     de4:	4889                	li	a7,2
 ecall
     de6:	00000073          	ecall
 ret
     dea:	8082                	ret

0000000000000dec <wait>:
.global wait
wait:
 li a7, SYS_wait
     dec:	488d                	li	a7,3
 ecall
     dee:	00000073          	ecall
 ret
     df2:	8082                	ret

0000000000000df4 <pipe>:
.global pipe
pipe:
 li a7, SYS_pipe
     df4:	4891                	li	a7,4
 ecall
     df6:	00000073          	ecall
 ret
     dfa:	8082                	ret

0000000000000dfc <read>:
.global read
read:
 li a7, SYS_read
     dfc:	4895                	li	a7,5
 ecall
     dfe:	00000073          	ecall
 ret
     e02:	8082                	ret

0000000000000e04 <write>:
.global write
write:
 li a7, SYS_write
     e04:	48c1                	li	a7,16
 ecall
     e06:	00000073          	ecall
 ret
     e0a:	8082                	ret

0000000000000e0c <close>:
.global close
close:
 li a7, SYS_close
     e0c:	48d5                	li	a7,21
 ecall
     e0e:	00000073          	ecall
 ret
     e12:	8082                	ret

0000000000000e14 <kill>:
.global kill
kill:
 li a7, SYS_kill
     e14:	4899                	li	a7,6
 ecall
     e16:	00000073          	ecall
 ret
     e1a:	8082                	ret

0000000000000e1c <exec>:
.global exec
exec:
 li a7, SYS_exec
     e1c:	489d                	li	a7,7
 ecall
     e1e:	00000073          	ecall
 ret
     e22:	8082                	ret

0000000000000e24 <open>:
.global open
open:
 li a7, SYS_open
     e24:	48bd                	li	a7,15
 ecall
     e26:	00000073          	ecall
 ret
     e2a:	8082                	ret

0000000000000e2c <mknod>:
.global mknod
mknod:
 li a7, SYS_mknod
     e2c:	48c5                	li	a7,17
 ecall
     e2e:	00000073          	ecall
 ret
     e32:	8082                	ret

0000000000000e34 <unlink>:
.global unlink
unlink:
 li a7, SYS_unlink
     e34:	48c9                	li	a7,18
 ecall
     e36:	00000073          	ecall
 ret
     e3a:	8082                	ret

0000000000000e3c <fstat>:
.global fstat
fstat:
 li a7, SYS_fstat
     e3c:	48a1                	li	a7,8
 ecall
     e3e:	00000073          	ecall
 ret
     e42:	8082                	ret

0000000000000e44 <link>:
.global link
link:
 li a7, SYS_link
     e44:	48cd                	li	a7,19
 ecall
     e46:	00000073          	ecall
 ret
     e4a:	8082                	ret

0000000000000e4c <mkdir>:
.global mkdir
mkdir:
 li a7, SYS_mkdir
     e4c:	48d1                	li	a7,20
 ecall
     e4e:	00000073          	ecall
 ret
     e52:	8082                	ret

0000000000000e54 <chdir>:
.global chdir
chdir:
 li a7, SYS_chdir
     e54:	48a5                	li	a7,9
 ecall
     e56:	00000073          	ecall
 ret
     e5a:	8082                	ret

0000000000000e5c <dup>:
.global dup
dup:
 li a7, SYS_dup
     e5c:	48a9                	li	a7,10
 ecall
     e5e:	00000073          	ecall
 ret
     e62:	8082                	ret

0000000000000e64 <getpid>:
.global getpid
getpid:
 li a7, SYS_getpid
     e64:	48ad                	li	a7,11
 ecall
     e66:	00000073          	ecall
 ret
     e6a:	8082                	ret

0000000000000e6c <sbrk>:
.global sbrk
sbrk:
 li a7, SYS_sbrk
     e6c:	48b1                	li	a7,12
 ecall
     e6e:	00000073          	ecall
 ret
     e72:	8082                	ret

0000000000000e74 <sleep>:
.global sleep
sleep:
 li a7, SYS_sleep
     e74:	48b5                	li	a7,13
 ecall
     e76:	00000073          	ecall
 ret
     e7a:	8082                	ret

0000000000000e7c <uptime>:
.global uptime
uptime:
 li a7, SYS_uptime
     e7c:	48b9                	li	a7,14
 ecall
     e7e:	00000073          	ecall
 ret
     e82:	8082                	ret

0000000000000e84 <clone>:
.global clone
clone:
 li a7, SYS_clone
     e84:	48d9                	li	a7,22
 ecall
     e86:	00000073          	ecall
 ret
     e8a:	8082                	ret

0000000000000e8c <putc>:

static char digits[] = "0123456789ABCDEF";

static void
putc(int fd, char c)
{
     e8c:	1101                	addi	sp,sp,-32
     e8e:	ec06                	sd	ra,24(sp)
     e90:	e822                	sd	s0,16(sp)
     e92:	1000                	addi	s0,sp,32
     e94:	feb407a3          	sb	a1,-17(s0)
  write(fd, &c, 1);
     e98:	4605                	li	a2,1
     e9a:	fef40593          	addi	a1,s0,-17
     e9e:	00000097          	auipc	ra,0x0
     ea2:	f66080e7          	jalr	-154(ra) # e04 <write>
}
     ea6:	60e2                	ld	ra,24(sp)
     ea8:	6442                	ld	s0,16(sp)
     eaa:	6105                	addi	sp,sp,32
     eac:	8082                	ret

0000000000000eae <printint>:

static void
printint(int fd, int xx, int base, int sgn)
{
     eae:	7139                	addi	sp,sp,-64
     eb0:	fc06                	sd	ra,56(sp)
     eb2:	f822                	sd	s0,48(sp)
     eb4:	f426                	sd	s1,40(sp)
     eb6:	f04a                	sd	s2,32(sp)
     eb8:	ec4e                	sd	s3,24(sp)
     eba:	0080                	addi	s0,sp,64
     ebc:	84aa                	mv	s1,a0
  char buf[16];
  int i, neg;
  uint x;

  neg = 0;
  if(sgn && xx < 0){
     ebe:	c299                	beqz	a3,ec4 <printint+0x16>
     ec0:	0805c963          	bltz	a1,f52 <printint+0xa4>
    neg = 1;
    x = -xx;
  } else {
    x = xx;
     ec4:	2581                	sext.w	a1,a1
  neg = 0;
     ec6:	4881                	li	a7,0
     ec8:	fc040693          	addi	a3,s0,-64
  }

  i = 0;
     ecc:	4701                	li	a4,0
  do{
    buf[i++] = digits[x % base];
     ece:	2601                	sext.w	a2,a2
     ed0:	00000517          	auipc	a0,0x0
     ed4:	66050513          	addi	a0,a0,1632 # 1530 <digits>
     ed8:	883a                	mv	a6,a4
     eda:	2705                	addiw	a4,a4,1
     edc:	02c5f7bb          	remuw	a5,a1,a2
     ee0:	1782                	slli	a5,a5,0x20
     ee2:	9381                	srli	a5,a5,0x20
     ee4:	97aa                	add	a5,a5,a0
     ee6:	0007c783          	lbu	a5,0(a5)
     eea:	00f68023          	sb	a5,0(a3)
  }while((x /= base) != 0);
     eee:	0005879b          	sext.w	a5,a1
     ef2:	02c5d5bb          	divuw	a1,a1,a2
     ef6:	0685                	addi	a3,a3,1
     ef8:	fec7f0e3          	bgeu	a5,a2,ed8 <printint+0x2a>
  if(neg)
     efc:	00088c63          	beqz	a7,f14 <printint+0x66>
    buf[i++] = '-';
     f00:	fd070793          	addi	a5,a4,-48
     f04:	00878733          	add	a4,a5,s0
     f08:	02d00793          	li	a5,45
     f0c:	fef70823          	sb	a5,-16(a4)
     f10:	0028071b          	addiw	a4,a6,2

  while(--i >= 0)
     f14:	02e05863          	blez	a4,f44 <printint+0x96>
     f18:	fc040793          	addi	a5,s0,-64
     f1c:	00e78933          	add	s2,a5,a4
     f20:	fff78993          	addi	s3,a5,-1
     f24:	99ba                	add	s3,s3,a4
     f26:	377d                	addiw	a4,a4,-1
     f28:	1702                	slli	a4,a4,0x20
     f2a:	9301                	srli	a4,a4,0x20
     f2c:	40e989b3          	sub	s3,s3,a4
    putc(fd, buf[i]);
     f30:	fff94583          	lbu	a1,-1(s2)
     f34:	8526                	mv	a0,s1
     f36:	00000097          	auipc	ra,0x0
     f3a:	f56080e7          	jalr	-170(ra) # e8c <putc>
  while(--i >= 0)
     f3e:	197d                	addi	s2,s2,-1
     f40:	ff3918e3          	bne	s2,s3,f30 <printint+0x82>
}
     f44:	70e2                	ld	ra,56(sp)
     f46:	7442                	ld	s0,48(sp)
     f48:	74a2                	ld	s1,40(sp)
     f4a:	7902                	ld	s2,32(sp)
     f4c:	69e2                	ld	s3,24(sp)
     f4e:	6121                	addi	sp,sp,64
     f50:	8082                	ret
    x = -xx;
     f52:	40b005bb          	negw	a1,a1
    neg = 1;
     f56:	4885                	li	a7,1
    x = -xx;
     f58:	bf85                	j	ec8 <printint+0x1a>

0000000000000f5a <vprintf>:
}

// Print to the given fd. Only understands %d, %x, %p, %s.
void
vprintf(int fd, const char *fmt, va_list ap)
{
     f5a:	7119                	addi	sp,sp,-128
     f5c:	fc86                	sd	ra,120(sp)
     f5e:	f8a2                	sd	s0,112(sp)
     f60:	f4a6                	sd	s1,104(sp)
     f62:	f0ca                	sd	s2,96(sp)
     f64:	ecce                	sd	s3,88(sp)
     f66:	e8d2                	sd	s4,80(sp)
     f68:	e4d6                	sd	s5,72(sp)
     f6a:	e0da                	sd	s6,64(sp)
     f6c:	fc5e                	sd	s7,56(sp)
     f6e:	f862                	sd	s8,48(sp)
     f70:	f466                	sd	s9,40(sp)
     f72:	f06a                	sd	s10,32(sp)
     f74:	ec6e                	sd	s11,24(sp)
     f76:	0100                	addi	s0,sp,128
  char *s;
  int c, i, state;

  state = 0;
  for(i = 0; fmt[i]; i++){
     f78:	0005c903          	lbu	s2,0(a1)
     f7c:	18090f63          	beqz	s2,111a <vprintf+0x1c0>
     f80:	8aaa                	mv	s5,a0
     f82:	8b32                	mv	s6,a2
     f84:	00158493          	addi	s1,a1,1
  state = 0;
     f88:	4981                	li	s3,0
      if(c == '%'){
        state = '%';
      } else {
        putc(fd, c);
      }
    } else if(state == '%'){
     f8a:	02500a13          	li	s4,37
     f8e:	4c55                	li	s8,21
     f90:	00000c97          	auipc	s9,0x0
     f94:	548c8c93          	addi	s9,s9,1352 # 14d8 <lock_release+0x166>
        printptr(fd, va_arg(ap, uint64));
      } else if(c == 's'){
        s = va_arg(ap, char*);
        if(s == 0)
          s = "(null)";
        while(*s != 0){
     f98:	02800d93          	li	s11,40
  putc(fd, 'x');
     f9c:	4d41                	li	s10,16
    putc(fd, digits[x >> (sizeof(uint64) * 8 - 4)]);
     f9e:	00000b97          	auipc	s7,0x0
     fa2:	592b8b93          	addi	s7,s7,1426 # 1530 <digits>
     fa6:	a839                	j	fc4 <vprintf+0x6a>
        putc(fd, c);
     fa8:	85ca                	mv	a1,s2
     faa:	8556                	mv	a0,s5
     fac:	00000097          	auipc	ra,0x0
     fb0:	ee0080e7          	jalr	-288(ra) # e8c <putc>
     fb4:	a019                	j	fba <vprintf+0x60>
    } else if(state == '%'){
     fb6:	01498d63          	beq	s3,s4,fd0 <vprintf+0x76>
  for(i = 0; fmt[i]; i++){
     fba:	0485                	addi	s1,s1,1
     fbc:	fff4c903          	lbu	s2,-1(s1)
     fc0:	14090d63          	beqz	s2,111a <vprintf+0x1c0>
    if(state == 0){
     fc4:	fe0999e3          	bnez	s3,fb6 <vprintf+0x5c>
      if(c == '%'){
     fc8:	ff4910e3          	bne	s2,s4,fa8 <vprintf+0x4e>
        state = '%';
     fcc:	89d2                	mv	s3,s4
     fce:	b7f5                	j	fba <vprintf+0x60>
      if(c == 'd'){
     fd0:	11490c63          	beq	s2,s4,10e8 <vprintf+0x18e>
     fd4:	f9d9079b          	addiw	a5,s2,-99
     fd8:	0ff7f793          	zext.b	a5,a5
     fdc:	10fc6e63          	bltu	s8,a5,10f8 <vprintf+0x19e>
     fe0:	f9d9079b          	addiw	a5,s2,-99
     fe4:	0ff7f713          	zext.b	a4,a5
     fe8:	10ec6863          	bltu	s8,a4,10f8 <vprintf+0x19e>
     fec:	00271793          	slli	a5,a4,0x2
     ff0:	97e6                	add	a5,a5,s9
     ff2:	439c                	lw	a5,0(a5)
     ff4:	97e6                	add	a5,a5,s9
     ff6:	8782                	jr	a5
        printint(fd, va_arg(ap, int), 10, 1);
     ff8:	008b0913          	addi	s2,s6,8
     ffc:	4685                	li	a3,1
     ffe:	4629                	li	a2,10
    1000:	000b2583          	lw	a1,0(s6)
    1004:	8556                	mv	a0,s5
    1006:	00000097          	auipc	ra,0x0
    100a:	ea8080e7          	jalr	-344(ra) # eae <printint>
    100e:	8b4a                	mv	s6,s2
      } else {
        // Unknown % sequence.  Print it to draw attention.
        putc(fd, '%');
        putc(fd, c);
      }
      state = 0;
    1010:	4981                	li	s3,0
    1012:	b765                	j	fba <vprintf+0x60>
        printint(fd, va_arg(ap, uint64), 10, 0);
    1014:	008b0913          	addi	s2,s6,8
    1018:	4681                	li	a3,0
    101a:	4629                	li	a2,10
    101c:	000b2583          	lw	a1,0(s6)
    1020:	8556                	mv	a0,s5
    1022:	00000097          	auipc	ra,0x0
    1026:	e8c080e7          	jalr	-372(ra) # eae <printint>
    102a:	8b4a                	mv	s6,s2
      state = 0;
    102c:	4981                	li	s3,0
    102e:	b771                	j	fba <vprintf+0x60>
        printint(fd, va_arg(ap, int), 16, 0);
    1030:	008b0913          	addi	s2,s6,8
    1034:	4681                	li	a3,0
    1036:	866a                	mv	a2,s10
    1038:	000b2583          	lw	a1,0(s6)
    103c:	8556                	mv	a0,s5
    103e:	00000097          	auipc	ra,0x0
    1042:	e70080e7          	jalr	-400(ra) # eae <printint>
    1046:	8b4a                	mv	s6,s2
      state = 0;
    1048:	4981                	li	s3,0
    104a:	bf85                	j	fba <vprintf+0x60>
        printptr(fd, va_arg(ap, uint64));
    104c:	008b0793          	addi	a5,s6,8
    1050:	f8f43423          	sd	a5,-120(s0)
    1054:	000b3983          	ld	s3,0(s6)
  putc(fd, '0');
    1058:	03000593          	li	a1,48
    105c:	8556                	mv	a0,s5
    105e:	00000097          	auipc	ra,0x0
    1062:	e2e080e7          	jalr	-466(ra) # e8c <putc>
  putc(fd, 'x');
    1066:	07800593          	li	a1,120
    106a:	8556                	mv	a0,s5
    106c:	00000097          	auipc	ra,0x0
    1070:	e20080e7          	jalr	-480(ra) # e8c <putc>
    1074:	896a                	mv	s2,s10
    putc(fd, digits[x >> (sizeof(uint64) * 8 - 4)]);
    1076:	03c9d793          	srli	a5,s3,0x3c
    107a:	97de                	add	a5,a5,s7
    107c:	0007c583          	lbu	a1,0(a5)
    1080:	8556                	mv	a0,s5
    1082:	00000097          	auipc	ra,0x0
    1086:	e0a080e7          	jalr	-502(ra) # e8c <putc>
  for (i = 0; i < (sizeof(uint64) * 2); i++, x <<= 4)
    108a:	0992                	slli	s3,s3,0x4
    108c:	397d                	addiw	s2,s2,-1
    108e:	fe0914e3          	bnez	s2,1076 <vprintf+0x11c>
        printptr(fd, va_arg(ap, uint64));
    1092:	f8843b03          	ld	s6,-120(s0)
      state = 0;
    1096:	4981                	li	s3,0
    1098:	b70d                	j	fba <vprintf+0x60>
        s = va_arg(ap, char*);
    109a:	008b0913          	addi	s2,s6,8
    109e:	000b3983          	ld	s3,0(s6)
        if(s == 0)
    10a2:	02098163          	beqz	s3,10c4 <vprintf+0x16a>
        while(*s != 0){
    10a6:	0009c583          	lbu	a1,0(s3)
    10aa:	c5ad                	beqz	a1,1114 <vprintf+0x1ba>
          putc(fd, *s);
    10ac:	8556                	mv	a0,s5
    10ae:	00000097          	auipc	ra,0x0
    10b2:	dde080e7          	jalr	-546(ra) # e8c <putc>
          s++;
    10b6:	0985                	addi	s3,s3,1
        while(*s != 0){
    10b8:	0009c583          	lbu	a1,0(s3)
    10bc:	f9e5                	bnez	a1,10ac <vprintf+0x152>
        s = va_arg(ap, char*);
    10be:	8b4a                	mv	s6,s2
      state = 0;
    10c0:	4981                	li	s3,0
    10c2:	bde5                	j	fba <vprintf+0x60>
          s = "(null)";
    10c4:	00000997          	auipc	s3,0x0
    10c8:	40c98993          	addi	s3,s3,1036 # 14d0 <lock_release+0x15e>
        while(*s != 0){
    10cc:	85ee                	mv	a1,s11
    10ce:	bff9                	j	10ac <vprintf+0x152>
        putc(fd, va_arg(ap, uint));
    10d0:	008b0913          	addi	s2,s6,8
    10d4:	000b4583          	lbu	a1,0(s6)
    10d8:	8556                	mv	a0,s5
    10da:	00000097          	auipc	ra,0x0
    10de:	db2080e7          	jalr	-590(ra) # e8c <putc>
    10e2:	8b4a                	mv	s6,s2
      state = 0;
    10e4:	4981                	li	s3,0
    10e6:	bdd1                	j	fba <vprintf+0x60>
        putc(fd, c);
    10e8:	85d2                	mv	a1,s4
    10ea:	8556                	mv	a0,s5
    10ec:	00000097          	auipc	ra,0x0
    10f0:	da0080e7          	jalr	-608(ra) # e8c <putc>
      state = 0;
    10f4:	4981                	li	s3,0
    10f6:	b5d1                	j	fba <vprintf+0x60>
        putc(fd, '%');
    10f8:	85d2                	mv	a1,s4
    10fa:	8556                	mv	a0,s5
    10fc:	00000097          	auipc	ra,0x0
    1100:	d90080e7          	jalr	-624(ra) # e8c <putc>
        putc(fd, c);
    1104:	85ca                	mv	a1,s2
    1106:	8556                	mv	a0,s5
    1108:	00000097          	auipc	ra,0x0
    110c:	d84080e7          	jalr	-636(ra) # e8c <putc>
      state = 0;
    1110:	4981                	li	s3,0
    1112:	b565                	j	fba <vprintf+0x60>
        s = va_arg(ap, char*);
    1114:	8b4a                	mv	s6,s2
      state = 0;
    1116:	4981                	li	s3,0
    1118:	b54d                	j	fba <vprintf+0x60>
    }
  }
}
    111a:	70e6                	ld	ra,120(sp)
    111c:	7446                	ld	s0,112(sp)
    111e:	74a6                	ld	s1,104(sp)
    1120:	7906                	ld	s2,96(sp)
    1122:	69e6                	ld	s3,88(sp)
    1124:	6a46                	ld	s4,80(sp)
    1126:	6aa6                	ld	s5,72(sp)
    1128:	6b06                	ld	s6,64(sp)
    112a:	7be2                	ld	s7,56(sp)
    112c:	7c42                	ld	s8,48(sp)
    112e:	7ca2                	ld	s9,40(sp)
    1130:	7d02                	ld	s10,32(sp)
    1132:	6de2                	ld	s11,24(sp)
    1134:	6109                	addi	sp,sp,128
    1136:	8082                	ret

0000000000001138 <fprintf>:

void
fprintf(int fd, const char *fmt, ...)
{
    1138:	715d                	addi	sp,sp,-80
    113a:	ec06                	sd	ra,24(sp)
    113c:	e822                	sd	s0,16(sp)
    113e:	1000                	addi	s0,sp,32
    1140:	e010                	sd	a2,0(s0)
    1142:	e414                	sd	a3,8(s0)
    1144:	e818                	sd	a4,16(s0)
    1146:	ec1c                	sd	a5,24(s0)
    1148:	03043023          	sd	a6,32(s0)
    114c:	03143423          	sd	a7,40(s0)
  va_list ap;

  va_start(ap, fmt);
    1150:	fe843423          	sd	s0,-24(s0)
  vprintf(fd, fmt, ap);
    1154:	8622                	mv	a2,s0
    1156:	00000097          	auipc	ra,0x0
    115a:	e04080e7          	jalr	-508(ra) # f5a <vprintf>
}
    115e:	60e2                	ld	ra,24(sp)
    1160:	6442                	ld	s0,16(sp)
    1162:	6161                	addi	sp,sp,80
    1164:	8082                	ret

0000000000001166 <printf>:

void
printf(const char *fmt, ...)
{
    1166:	711d                	addi	sp,sp,-96
    1168:	ec06                	sd	ra,24(sp)
    116a:	e822                	sd	s0,16(sp)
    116c:	1000                	addi	s0,sp,32
    116e:	e40c                	sd	a1,8(s0)
    1170:	e810                	sd	a2,16(s0)
    1172:	ec14                	sd	a3,24(s0)
    1174:	f018                	sd	a4,32(s0)
    1176:	f41c                	sd	a5,40(s0)
    1178:	03043823          	sd	a6,48(s0)
    117c:	03143c23          	sd	a7,56(s0)
  va_list ap;

  va_start(ap, fmt);
    1180:	00840613          	addi	a2,s0,8
    1184:	fec43423          	sd	a2,-24(s0)
  vprintf(1, fmt, ap);
    1188:	85aa                	mv	a1,a0
    118a:	4505                	li	a0,1
    118c:	00000097          	auipc	ra,0x0
    1190:	dce080e7          	jalr	-562(ra) # f5a <vprintf>
}
    1194:	60e2                	ld	ra,24(sp)
    1196:	6442                	ld	s0,16(sp)
    1198:	6125                	addi	sp,sp,96
    119a:	8082                	ret

000000000000119c <free>:
static Header base;
static Header *freep;

void
free(void *ap)
{
    119c:	1141                	addi	sp,sp,-16
    119e:	e422                	sd	s0,8(sp)
    11a0:	0800                	addi	s0,sp,16
  Header *bp, *p;

  bp = (Header*)ap - 1;
    11a2:	ff050693          	addi	a3,a0,-16
  for(p = freep; !(bp > p && bp < p->s.ptr); p = p->s.ptr)
    11a6:	00001797          	auipc	a5,0x1
    11aa:	e6a7b783          	ld	a5,-406(a5) # 2010 <freep>
    11ae:	a02d                	j	11d8 <free+0x3c>
    if(p >= p->s.ptr && (bp > p || bp < p->s.ptr))
      break;
  if(bp + bp->s.size == p->s.ptr){
    bp->s.size += p->s.ptr->s.size;
    11b0:	4618                	lw	a4,8(a2)
    11b2:	9f2d                	addw	a4,a4,a1
    11b4:	fee52c23          	sw	a4,-8(a0)
    bp->s.ptr = p->s.ptr->s.ptr;
    11b8:	6398                	ld	a4,0(a5)
    11ba:	6310                	ld	a2,0(a4)
    11bc:	a83d                	j	11fa <free+0x5e>
  } else
    bp->s.ptr = p->s.ptr;
  if(p + p->s.size == bp){
    p->s.size += bp->s.size;
    11be:	ff852703          	lw	a4,-8(a0)
    11c2:	9f31                	addw	a4,a4,a2
    11c4:	c798                	sw	a4,8(a5)
    p->s.ptr = bp->s.ptr;
    11c6:	ff053683          	ld	a3,-16(a0)
    11ca:	a091                	j	120e <free+0x72>
    if(p >= p->s.ptr && (bp > p || bp < p->s.ptr))
    11cc:	6398                	ld	a4,0(a5)
    11ce:	00e7e463          	bltu	a5,a4,11d6 <free+0x3a>
    11d2:	00e6ea63          	bltu	a3,a4,11e6 <free+0x4a>
{
    11d6:	87ba                	mv	a5,a4
  for(p = freep; !(bp > p && bp < p->s.ptr); p = p->s.ptr)
    11d8:	fed7fae3          	bgeu	a5,a3,11cc <free+0x30>
    11dc:	6398                	ld	a4,0(a5)
    11de:	00e6e463          	bltu	a3,a4,11e6 <free+0x4a>
    if(p >= p->s.ptr && (bp > p || bp < p->s.ptr))
    11e2:	fee7eae3          	bltu	a5,a4,11d6 <free+0x3a>
  if(bp + bp->s.size == p->s.ptr){
    11e6:	ff852583          	lw	a1,-8(a0)
    11ea:	6390                	ld	a2,0(a5)
    11ec:	02059813          	slli	a6,a1,0x20
    11f0:	01c85713          	srli	a4,a6,0x1c
    11f4:	9736                	add	a4,a4,a3
    11f6:	fae60de3          	beq	a2,a4,11b0 <free+0x14>
    bp->s.ptr = p->s.ptr->s.ptr;
    11fa:	fec53823          	sd	a2,-16(a0)
  if(p + p->s.size == bp){
    11fe:	4790                	lw	a2,8(a5)
    1200:	02061593          	slli	a1,a2,0x20
    1204:	01c5d713          	srli	a4,a1,0x1c
    1208:	973e                	add	a4,a4,a5
    120a:	fae68ae3          	beq	a3,a4,11be <free+0x22>
    p->s.ptr = bp->s.ptr;
    120e:	e394                	sd	a3,0(a5)
  } else
    p->s.ptr = bp;
  freep = p;
    1210:	00001717          	auipc	a4,0x1
    1214:	e0f73023          	sd	a5,-512(a4) # 2010 <freep>
}
    1218:	6422                	ld	s0,8(sp)
    121a:	0141                	addi	sp,sp,16
    121c:	8082                	ret

000000000000121e <malloc>:
  return freep;
}

void*
malloc(uint nbytes)
{
    121e:	7139                	addi	sp,sp,-64
    1220:	fc06                	sd	ra,56(sp)
    1222:	f822                	sd	s0,48(sp)
    1224:	f426                	sd	s1,40(sp)
    1226:	f04a                	sd	s2,32(sp)
    1228:	ec4e                	sd	s3,24(sp)
    122a:	e852                	sd	s4,16(sp)
    122c:	e456                	sd	s5,8(sp)
    122e:	e05a                	sd	s6,0(sp)
    1230:	0080                	addi	s0,sp,64
  Header *p, *prevp;
  uint nunits;

  nunits = (nbytes + sizeof(Header) - 1)/sizeof(Header) + 1;
    1232:	02051493          	slli	s1,a0,0x20
    1236:	9081                	srli	s1,s1,0x20
    1238:	04bd                	addi	s1,s1,15
    123a:	8091                	srli	s1,s1,0x4
    123c:	0014899b          	addiw	s3,s1,1
    1240:	0485                	addi	s1,s1,1
  if((prevp = freep) == 0){
    1242:	00001517          	auipc	a0,0x1
    1246:	dce53503          	ld	a0,-562(a0) # 2010 <freep>
    124a:	c515                	beqz	a0,1276 <malloc+0x58>
    base.s.ptr = freep = prevp = &base;
    base.s.size = 0;
  }
  for(p = prevp->s.ptr; ; prevp = p, p = p->s.ptr){
    124c:	611c                	ld	a5,0(a0)
    if(p->s.size >= nunits){
    124e:	4798                	lw	a4,8(a5)
    1250:	02977f63          	bgeu	a4,s1,128e <malloc+0x70>
    1254:	8a4e                	mv	s4,s3
    1256:	0009871b          	sext.w	a4,s3
    125a:	6685                	lui	a3,0x1
    125c:	00d77363          	bgeu	a4,a3,1262 <malloc+0x44>
    1260:	6a05                	lui	s4,0x1
    1262:	000a0b1b          	sext.w	s6,s4
  p = sbrk(nu * sizeof(Header));
    1266:	004a1a1b          	slliw	s4,s4,0x4
        p->s.size = nunits;
      }
      freep = prevp;
      return (void*)(p + 1);
    }
    if(p == freep)
    126a:	00001917          	auipc	s2,0x1
    126e:	da690913          	addi	s2,s2,-602 # 2010 <freep>
  if(p == (char*)-1)
    1272:	5afd                	li	s5,-1
    1274:	a895                	j	12e8 <malloc+0xca>
    base.s.ptr = freep = prevp = &base;
    1276:	00001797          	auipc	a5,0x1
    127a:	e1278793          	addi	a5,a5,-494 # 2088 <base>
    127e:	00001717          	auipc	a4,0x1
    1282:	d8f73923          	sd	a5,-622(a4) # 2010 <freep>
    1286:	e39c                	sd	a5,0(a5)
    base.s.size = 0;
    1288:	0007a423          	sw	zero,8(a5)
    if(p->s.size >= nunits){
    128c:	b7e1                	j	1254 <malloc+0x36>
      if(p->s.size == nunits)
    128e:	02e48c63          	beq	s1,a4,12c6 <malloc+0xa8>
        p->s.size -= nunits;
    1292:	4137073b          	subw	a4,a4,s3
    1296:	c798                	sw	a4,8(a5)
        p += p->s.size;
    1298:	02071693          	slli	a3,a4,0x20
    129c:	01c6d713          	srli	a4,a3,0x1c
    12a0:	97ba                	add	a5,a5,a4
        p->s.size = nunits;
    12a2:	0137a423          	sw	s3,8(a5)
      freep = prevp;
    12a6:	00001717          	auipc	a4,0x1
    12aa:	d6a73523          	sd	a0,-662(a4) # 2010 <freep>
      return (void*)(p + 1);
    12ae:	01078513          	addi	a0,a5,16
      if((p = morecore(nunits)) == 0)
        return 0;
  }
}
    12b2:	70e2                	ld	ra,56(sp)
    12b4:	7442                	ld	s0,48(sp)
    12b6:	74a2                	ld	s1,40(sp)
    12b8:	7902                	ld	s2,32(sp)
    12ba:	69e2                	ld	s3,24(sp)
    12bc:	6a42                	ld	s4,16(sp)
    12be:	6aa2                	ld	s5,8(sp)
    12c0:	6b02                	ld	s6,0(sp)
    12c2:	6121                	addi	sp,sp,64
    12c4:	8082                	ret
        prevp->s.ptr = p->s.ptr;
    12c6:	6398                	ld	a4,0(a5)
    12c8:	e118                	sd	a4,0(a0)
    12ca:	bff1                	j	12a6 <malloc+0x88>
  hp->s.size = nu;
    12cc:	01652423          	sw	s6,8(a0)
  free((void*)(hp + 1));
    12d0:	0541                	addi	a0,a0,16
    12d2:	00000097          	auipc	ra,0x0
    12d6:	eca080e7          	jalr	-310(ra) # 119c <free>
  return freep;
    12da:	00093503          	ld	a0,0(s2)
      if((p = morecore(nunits)) == 0)
    12de:	d971                	beqz	a0,12b2 <malloc+0x94>
  for(p = prevp->s.ptr; ; prevp = p, p = p->s.ptr){
    12e0:	611c                	ld	a5,0(a0)
    if(p->s.size >= nunits){
    12e2:	4798                	lw	a4,8(a5)
    12e4:	fa9775e3          	bgeu	a4,s1,128e <malloc+0x70>
    if(p == freep)
    12e8:	00093703          	ld	a4,0(s2)
    12ec:	853e                	mv	a0,a5
    12ee:	fef719e3          	bne	a4,a5,12e0 <malloc+0xc2>
  p = sbrk(nu * sizeof(Header));
    12f2:	8552                	mv	a0,s4
    12f4:	00000097          	auipc	ra,0x0
    12f8:	b78080e7          	jalr	-1160(ra) # e6c <sbrk>
  if(p == (char*)-1)
    12fc:	fd5518e3          	bne	a0,s5,12cc <malloc+0xae>
        return 0;
    1300:	4501                	li	a0,0
    1302:	bf45                	j	12b2 <malloc+0x94>

0000000000001304 <thread_create>:
#include "user/user.h"
#include "user/thread.h"


int thread_create(void *(*start_routine)(void*), void *arg) 
{
    1304:	1101                	addi	sp,sp,-32
    1306:	ec06                	sd	ra,24(sp)
    1308:	e822                	sd	s0,16(sp)
    130a:	e426                	sd	s1,8(sp)
    130c:	e04a                	sd	s2,0(sp)
    130e:	1000                	addi	s0,sp,32
    1310:	84aa                	mv	s1,a0
    1312:	892e                	mv	s2,a1
	int stksz = 4096 * sizeof(void);
	void* stk_addr = (void*) malloc(stksz);
    1314:	6505                	lui	a0,0x1
    1316:	00000097          	auipc	ra,0x0
    131a:	f08080e7          	jalr	-248(ra) # 121e <malloc>
	
	int tid  = clone(stk_addr,stksz);
    131e:	6585                	lui	a1,0x1
    1320:	00000097          	auipc	ra,0x0
    1324:	b64080e7          	jalr	-1180(ra) # e84 <clone>
	
	if(tid == 0) {
    1328:	c901                	beqz	a0,1338 <thread_create+0x34>
		(*start_routine) (arg);
		exit(0);
	}
	return 0;
}
    132a:	4501                	li	a0,0
    132c:	60e2                	ld	ra,24(sp)
    132e:	6442                	ld	s0,16(sp)
    1330:	64a2                	ld	s1,8(sp)
    1332:	6902                	ld	s2,0(sp)
    1334:	6105                	addi	sp,sp,32
    1336:	8082                	ret
		(*start_routine) (arg);
    1338:	854a                	mv	a0,s2
    133a:	9482                	jalr	s1
		exit(0);
    133c:	4501                	li	a0,0
    133e:	00000097          	auipc	ra,0x0
    1342:	aa6080e7          	jalr	-1370(ra) # de4 <exit>

0000000000001346 <lock_init>:

void lock_init(lock_t *lock)
{
    1346:	1141                	addi	sp,sp,-16
    1348:	e422                	sd	s0,8(sp)
    134a:	0800                	addi	s0,sp,16
	*lock = 0;
    134c:	00052023          	sw	zero,0(a0) # 1000 <vprintf+0xa6>
}
    1350:	6422                	ld	s0,8(sp)
    1352:	0141                	addi	sp,sp,16
    1354:	8082                	ret

0000000000001356 <lock_acquire>:
void lock_acquire(lock_t *lock)
{
    1356:	1141                	addi	sp,sp,-16
    1358:	e422                	sd	s0,8(sp)
    135a:	0800                	addi	s0,sp,16
	while(__sync_lock_test_and_set(lock, 1) != 0);
    135c:	4705                	li	a4,1
    135e:	87ba                	mv	a5,a4
    1360:	0cf527af          	amoswap.w.aq	a5,a5,(a0)
    1364:	2781                	sext.w	a5,a5
    1366:	ffe5                	bnez	a5,135e <lock_acquire+0x8>
	__sync_synchronize();
    1368:	0ff0000f          	fence
}
    136c:	6422                	ld	s0,8(sp)
    136e:	0141                	addi	sp,sp,16
    1370:	8082                	ret

0000000000001372 <lock_release>:
void lock_release(lock_t *lock)
{
    1372:	1141                	addi	sp,sp,-16
    1374:	e422                	sd	s0,8(sp)
    1376:	0800                	addi	s0,sp,16
	__sync_synchronize();
    1378:	0ff0000f          	fence
	__sync_lock_release(lock,0);
    137c:	0f50000f          	fence	iorw,ow
    1380:	0805202f          	amoswap.w	zero,zero,(a0)
}
    1384:	6422                	ld	s0,8(sp)
    1386:	0141                	addi	sp,sp,16
    1388:	8082                	ret
