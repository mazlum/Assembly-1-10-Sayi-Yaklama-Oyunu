; Mazlum Agar
; Kullanicidan 1 ile 10 arasinda sayi alan ve girilen sayi eger program icerisinde tutulan sayidan kucuk ise
; ekrana Y(YUKSELT) yazdiran buyuk ise A(AZALT) yazdiran 8051 mikro islemci programi.
; Kullanicinin 10 hakki vardir. Eger 10 hakta bilemez ise kaybettiniz yazdirilir. Eger 10 hak icerisinde bilirse
; ekrana TEBRIKLER yazdirilir.
; Programin Proteus'da simülasyon'u verilmistir.
; Programin proteus icerisinde calisabilmesi icin secilen mod Mhz'ine yani 11.0592Mhz getirilmesi unutulmamalidir. Bunun için;
; Keil icerisinde Project > Option for target .. >	Target > xtal(Mhz) degiri 11.0592Mhz yapilmalidir.
; Ayni sekilde 	Protesu icerisinde Mikroislemci cift tiklandiktan sonra Clock Frequency degeri 11.0592MHz yapilmalidir.
		 
	ORG 0H		 ; Programin baslangic adresi
	SJMP BASLA
	ORG 30H

BASLA: 
	MOV SCON, #01010010B ; Mod2 11.0592Mhz. Program baslamadan once Seri port modu ayarlanir. MOD hem okuma hem yazmak icin ayarlanmistir.
	MOV TMOD, #00100000B; Mod0, Timer MOD'u ayarlanir.
	MOV TH1, #-3 ; Timer Baslangic degeri
	MOV TL1, #-3 ; Timer bitis degeri
	SETB TR1 ; TR1 bir oldugu anda timer isleve gecer. Bundan dolayi 1 yapilmistir.
	MOV A, #-1 ; Akü'ye -1 atilmistir. 
	MOV R1, #0 ; Kullanicinin kac giris yaptigini tutan kaydediciye 0 degeri atilmistir.
	SJMP AL	; Programin baslamasi icin AL'a dallanilmistir.

; Program buraya dallandi ise kullanici tutulan sayiyi bilmistir ve kazanmistir. Ekrana TEBRIKLER yazilir
; Buranin aciklamasi KAYBETTINIZYAZ ile aynidir.
TEBRIKLERYAZ:
	JNB TI, TEBRIKLERYAZ  
	CLR TI
	INC A
	MOV B, A
	MOVC A,@A+DPTR
	MOV SBUF, A
	MOV A, B
	CJNE A, #8, TEBRIKLERYAZ ; esit degilse tebriklere git tekrar
	MOV A, #-1
	RET		

; Eger program buraya dallanirsa kullanici kaybetmis demektir.
KAYBETTINIZYAZ:
	JNB TI, KAYBETTINIZYAZ ; Eger seri port mesgul ise programin bekletilmesi saglanir.
	CLR TI	; TI temizlenir.
	INC A  ; Akü bir arttirilir.
	MOV B, A ; B'ye A atanir.
	MOVC A,@A+DPTR	; Aküye DPTR isaretcisinin gosterdigi dizideki eleman atanir.
	MOV SBUF, A	; Anin degeri seri porta gonderilir. Buda ekrana dizinin siradaki elemanin yazilmasini saglar.
	MOV A, B   ; A'nin degerinin kaybedilmemesi icin B'den geri alinir.
	CJNE A, #26, KAYBETTINIZYAZ ; esit degilse tebriklere git tekrar
	MOV A, #-1
	RET


; Eger program buraya dallanirsa R2'nin tutulan sayi ile esit olma olasiligi vardir.
SIFIRDEGIL:
	CJNE R2, #36H, KONTROL ; Eger r2 tutulan sayi ile 0'da olmadigi icin 0 olana kadar azaltilmaya devam eder. Bundan dolayi tekrar KONTROL'e dallan.
	MOV SBUF, #41H ; Eger program buraya gectiyse R2 tutulan sayi ile esit olmus demektir. Buda kullanicinin daha buyuk bir sayi girdigi anlamina gelir. Ekrana A(AZALT) yazilir.
	SJMP AL ; Tekrar sayi istenmesi icin AL'a dallan.

; 0X30 0in ascii karsiligi
KONTROL:
	DEC R2
	CJNE R2, #30H, SIFIRDEGIL ; EGER R2 0'a esit degilse SIFIRDEGIL'e dallan.
	MOV SBUF, #59H ; Eger R2 0 olduysa r2 hicbir zaman tutulan sayiya esit olmamis demektir. Buda kullanicinin daha kucuk bir sayi tuttugunu gosterir.
	SJMP AL 	 ; Bundan dolayi ekrana Y(Yükselt) yazdirilir ve AL'a dallanilir.

; Program buraya dallandi ise kullanicinin hala hakki var demektir.
HAKKIVAR:
	CJNE R2, #36H, KONTROL ; Sayilar esit degilse KONTROL'e dallan.	Not: 36 6 sayisinin ascii karsiligidir
	MOV DPTR, #TEBRIKLER ; Eger sayilar esit ise kullanici bildigi icin tebrikler yazidirlacaktir. DPTR isaretcisine TEBRIKLER atandi
	SJMP TEBRIKLERYAZ  ; Ekrana tebrikler yazmasi icin TEBRIKLERYAZ'a dallandi.

AL:
	JNB RI, Al ; Eger RI 0 ise hala alim islemi devam ettigi icin programi bekletir. 1 olursa alt satira gecer
	CLR RI	; RI temizlenir				  
	MOV R2, SBUF ; kullanicidan alinan deger r2 kaydedicisine atandi.
	INC R1 ; Kullanicinin hakki bir azaltildi.
	CJNE R1, #10 , HAKKIVAR ; Eger kullanicinin hakki  bitmediyse HAKKIVAR'a dallan. Bitiyse alt satira gec
	MOV DPTR, #KAYBETTINIZ	; DPTR isaretcisine KAYBETTINIZ dizisi atandi
	SJMP KAYBETTINIZYAZ	 ; KAYBETTINIZYAZ'a dallan
	
TEBRIKLER:
		 DB 54H,45H,42H,52H,49H,4bH,4cH,45H,52H	; tebrikler yazisi diziye atanmisitir

KAYBETTINIZ:
		DB 48H, 41H, 4bH, 4bH, 49H, 4eH, 49H, 5aH, 20H, 42H, 49H, 54H, 54H, 49H, 20H, 4bH, 41H, 59H, 42H, 45H, 54H, 54H, 49H, 4eH, 49H, 5aH
		; kabeybettiniz yazisi diziye atanmistir
END
