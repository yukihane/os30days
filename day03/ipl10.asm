; haribote-ipl
; TAB=4

CYLS	EQU		10				; 読み込むシリンダ番号上限

		ORG		0x7c00			; このプログラムがどこに読み込まれるのか

; 以下は標準的なFAT12フォーマットフロッピーディスクのための記述

		JMP		entry
		DB		0x90
		DB		"HELLOIPL"		; ブートセクタの名前を自由に書いてよい（8バイト）
		DW		512				; 1セクタの大きさ（512にしなければいけない）
		DB		1				; クラスタの大きさ（1セクタにしなければいけない）
		DW		1				; FATがどこから始まるか（普通は1セクタ目からにする）
		DB		2				; FATの個数（2にしなければいけない）
		DW		224				; ルートディレクトリ領域の大きさ（普通は224エントリにする）
		DW		2880			; このドライブの大きさ（2880セクタにしなければいけない）
		DB		0xf0			; メディアのタイプ（0xf0にしなければいけない）
		DW		9				; FAT領域の長さ（9セクタにしなければいけない）
		DW		18				; 1トラックにいくつのセクタがあるか（18にしなければいけない）
		DW		2				; ヘッドの数（2にしなければいけない）
		DD		0				; パーティションを使ってないのでここは必ず0
		DD		2880			; このドライブ大きさをもう一度書く
		DB		0,0,0x29		; よくわからないけどこの値にしておくといいらしい
		DD		0xffffffff		; たぶんボリュームシリアル番号
		DB		"HELLO-OS   "	; ディスクの名前（11バイト）
		DB		"FAT12   "		; フォーマットの名前（8バイト）
		TIMES	18	DB	0		; とりあえず18バイトあけておく

; プログラム本体

entry:
		MOV		AX,0			; レジスタ初期化
		MOV		SS,AX
		MOV		SP,0x7c00
		MOV		DS,AX

; ディスクを読む

		MOV		AX,0x0820
		MOV		ES,AX
		MOV		CH,0			; シリンダ0
		MOV		DH,0			; ヘッド0
		MOV		CL,2			; セクタ2
readloop:
		MOV		SI,0			; 失敗回数を数えるレジスタ
retry:
		MOV		AH,0x02			; AH=0x02 : ディスク読み込み
		MOV		AL,1			; 1セクタ
		MOV		BX,0
		MOV		DL,0x00			; Aドライブ
		INT		0x13			; ディスクBIOS呼び出し
		JNC		next			; エラーがおきなければnextへ
		ADD		SI,1			; エラーが起きた場合カウンタをインクリメント
		CMP		SI,5			; retryは5回までなので5と比較
		JAE		error			; 5回リトライ後はerror
		MOV		AH,0x00
		MOV		DL,0x00
		INT		0x13			; システムのリセット
		JMP		retry
next:
		MOV		AX,ES
		ADD		AX,0x0020		; アドレスを0x0200進める
		MOV		ES,AX
		ADD		CL,1			; セクタ番号を1進める
		CMP		CL,18			; セクタ番号は1から18までなので上限比較
		JBE		readloop		; 上限を超えていなければreadloopへ
		MOV		CL,1			; 上限を超えていればセクタ番号をリセットした後ヘッド移動
		ADD		DH,1
		CMP		DH,2
		JB		readloop		; ヘッド番号が上限に達していなければ読み込み処理
		MOV		DH,0			; 上限に達していればリセットしてシリンダ番号カウントアップ
		ADD		CH,1
		CMP		CH,CYLS
		JB		readloop		; シリンダ番号上限に達していなければ読み込み処理

; 読み終わったのでharibote.sysを実行だ！

		JMP		0xc200

error:
		MOV		SI,msg
putloop:
		MOV		AL,[SI]
		ADD		SI,1			; SIに1を足す
		CMP		AL,0
		JE		fin
		MOV		AH,0x0e			; 一文字表示ファンクション
		MOV		BX,15			; カラーコード
		INT		0x10			; ビデオBIOS呼び出し
		JMP		putloop
fin:
		HLT						; 何かあるまでCPUを停止させる
		JMP		fin				; 無限ループ
msg:
		DB		0x0a, 0x0a		; 改行を2つ
		DB		"load error"
		DB		0x0a			; 改行
		DB		0

		TIMES	510-($-$$) DB 0		; 0x7dfeまでを0x00で埋める命令

		DB		0x55, 0xaa
