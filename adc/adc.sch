EESchema Schematic File Version 4
EELAYER 30 0
EELAYER END
$Descr A 11000 8500
encoding utf-8
Sheet 1 1
Title "Analog Front End"
Date ""
Rev ""
Comp "HMC Engineering 155"
Comment1 ""
Comment2 ""
Comment3 ""
Comment4 ""
$EndDescr
Text GLabel 3450 2050 0    50   Input ~ 0
+5V
$Comp
L custom_symbols:uMudd_40pin_conn J5
U 1 1 6173E180
P 3900 2650
F 0 "J5" H 3900 3667 50  0000 C CNN
F 1 "uMudd_40pin_conn" H 3900 3576 50  0000 C CNN
F 2 "custom_components:S9175-ND" H 3850 2550 50  0001 C CNN
F 3 "http://pages.hmc.edu/brake/class/e155/fa21/assets/doc/Breadboard_Adapter_Schematic_v2.pdf" H 3850 2550 50  0001 C CNN
	1    3900 2650
	1    0    0    -1  
$EndComp
Wire Wire Line
	3650 2050 3450 2050
Wire Wire Line
	3650 2750 3550 2750
Wire Wire Line
	3550 2750 3550 2550
Wire Wire Line
	3550 1950 3650 1950
Wire Wire Line
	3650 2150 3550 2150
Connection ~ 3550 2150
Wire Wire Line
	3550 2150 3550 1950
Wire Wire Line
	3650 2350 3550 2350
Connection ~ 3550 2350
Wire Wire Line
	3550 2350 3550 2150
Wire Wire Line
	3650 2550 3550 2550
Connection ~ 3550 2550
Wire Wire Line
	3550 2550 3550 2350
Wire Wire Line
	3550 1950 3050 1950
Wire Wire Line
	3050 1950 3050 2000
Connection ~ 3550 1950
$Comp
L power:GND #PWR0101
U 1 1 61742A70
P 3050 2000
F 0 "#PWR0101" H 3050 1750 50  0001 C CNN
F 1 "GND" H 3055 1827 50  0000 C CNN
F 2 "" H 3050 2000 50  0001 C CNN
F 3 "" H 3050 2000 50  0001 C CNN
	1    3050 2000
	1    0    0    -1  
$EndComp
Text GLabel 3450 2250 0    50   Input ~ 0
+3V3
Wire Wire Line
	3650 2250 3450 2250
$Comp
L custom_symbols:PCM1808 U1
U 1 1 6174E57A
P 5650 2250
F 0 "U1" H 5675 2915 50  0000 C CNN
F 1 "PCM1808" H 5675 2824 50  0000 C CNN
F 2 "Package_SO:TSSOP-14_4.4x5mm_P0.65mm" H 5650 2900 50  0001 C CNN
F 3 "https://www.ti.com/lit/ds/symlink/pcm1808.pdf" H 5650 2900 50  0001 C CNN
	1    5650 2250
	1    0    0    -1  
$EndComp
$Comp
L power:GND #PWR0102
U 1 1 6176421D
P 4950 2250
F 0 "#PWR0102" H 4950 2000 50  0001 C CNN
F 1 "GND" H 4850 2150 50  0000 C CNN
F 2 "" H 4950 2250 50  0001 C CNN
F 3 "" H 4950 2250 50  0001 C CNN
	1    4950 2250
	1    0    0    -1  
$EndComp
Wire Wire Line
	4950 2250 5350 2250
Wire Wire Line
	5350 2050 4800 2050
Text GLabel 4800 2050 0    50   Input ~ 0
+5V
Connection ~ 4950 2250
Text GLabel 4800 2150 0    50   Input ~ 0
+3V3
Wire Wire Line
	4800 2150 5350 2150
$Comp
L Device:CP1_Small C7
U 1 1 617848DA
P 5050 1650
F 0 "C7" V 4900 1450 50  0000 C CNN
F 1 "10uF" V 5000 1400 50  0000 C CNN
F 2 "Capacitor_SMD:C_0805_2012Metric_Pad1.18x1.45mm_HandSolder" H 5050 1650 50  0001 C CNN
F 3 "~" H 5050 1650 50  0001 C CNN
	1    5050 1650
	0    1    1    0   
$EndComp
$Comp
L Device:C_Small C8
U 1 1 617850CE
P 5050 1850
F 0 "C8" V 4950 1650 50  0000 C CNN
F 1 "0.1uF" V 5050 1600 50  0000 C CNN
F 2 "Capacitor_SMD:C_0805_2012Metric_Pad1.18x1.45mm_HandSolder" H 5050 1850 50  0001 C CNN
F 3 "~" H 5050 1850 50  0001 C CNN
	1    5050 1850
	0    1    1    0   
$EndComp
Wire Wire Line
	5150 1850 5350 1850
Wire Wire Line
	5150 1850 5150 1650
Connection ~ 5150 1850
Wire Wire Line
	4950 1650 4950 1850
Wire Wire Line
	4950 1850 4950 1950
Connection ~ 4950 1850
Wire Wire Line
	4950 1950 5350 1950
Connection ~ 4950 1950
Wire Wire Line
	4950 1950 4950 2250
Wire Notes Line
	2000 2450 2000 1700
Wire Notes Line
	2000 3250 2000 2500
$Comp
L Device:C C2
U 1 1 617ED50B
P 7100 2050
F 0 "C2" V 7050 1900 50  0000 C CNN
F 1 "1uF" V 7050 2200 50  0000 C CNN
F 2 "Capacitor_SMD:C_0805_2012Metric_Pad1.18x1.45mm_HandSolder" H 7138 1900 50  0001 C CNN
F 3 "~" H 7100 2050 50  0001 C CNN
	1    7100 2050
	0    1    1    0   
$EndComp
Wire Wire Line
	6950 2050 6750 2050
Wire Wire Line
	6750 2050 6750 1950
Wire Wire Line
	6750 1950 6050 1950
$Comp
L Device:C C1
U 1 1 61810797
P 7100 1750
F 0 "C1" V 7050 1600 50  0000 C CNN
F 1 "1uF" V 7050 1900 50  0000 C CNN
F 2 "Capacitor_SMD:C_0805_2012Metric_Pad1.18x1.45mm_HandSolder" H 7138 1600 50  0001 C CNN
F 3 "~" H 7100 1750 50  0001 C CNN
	1    7100 1750
	0    1    -1   0   
$EndComp
Wire Wire Line
	6950 1750 6750 1750
Wire Wire Line
	6750 1750 6750 1850
Wire Wire Line
	6050 1850 6750 1850
$Comp
L Connector:AudioJack3 J3
U 1 1 6181E3D3
P 8100 1250
F 0 "J3" H 7820 1183 50  0000 R CNN
F 1 "SJ-3523-SMT-TR" H 7820 1274 50  0000 R CNN
F 2 "Connector_Audio:Jack_3.5mm_CUI_SJ-3523-SMT_Horizontal" H 8100 1250 50  0001 C CNN
F 3 "https://www.cuidevices.com/product/resource/sj-352x-smt.pdf" H 8100 1250 50  0001 C CNN
	1    8100 1250
	-1   0    0    1   
$EndComp
Wire Wire Line
	5350 2450 5200 2450
Wire Wire Line
	5200 2450 5200 2550
Wire Wire Line
	5100 2350 5100 2450
Wire Wire Line
	5100 2350 5350 2350
Wire Wire Line
	6050 2450 6150 2450
Wire Wire Line
	6150 2450 6150 2650
Wire Wire Line
	6050 2350 6250 2350
Wire Wire Line
	6250 2350 6250 2750
Wire Wire Line
	6050 2250 6350 2250
Wire Wire Line
	6350 2250 6350 2850
Wire Wire Line
	6050 2150 6450 2150
Wire Wire Line
	6450 2150 6450 2950
Wire Wire Line
	6050 2050 6550 2050
Wire Wire Line
	6550 2050 6550 3050
Wire Wire Line
	4150 2450 5100 2450
Wire Wire Line
	4150 2550 5200 2550
Wire Wire Line
	4150 2650 6150 2650
Wire Wire Line
	4150 2750 6250 2750
Wire Wire Line
	4150 2850 6350 2850
Wire Wire Line
	4150 2950 6450 2950
Wire Wire Line
	4150 3050 6550 3050
Text Label 4500 2450 2    50   ~ 0
PA5_H4
Text Label 4500 2550 2    50   ~ 0
PA6_J1
Text Label 4500 2650 2    50   ~ 0
PA7_J2
Text Label 4500 2750 2    50   ~ 0
PB6_G12
Text Label 4500 2850 2    50   ~ 0
PC7_H13
Text Label 4500 2950 2    50   ~ 0
PA9_H10
Text Label 4500 3050 2    50   ~ 0
PA8_J10
$Comp
L Connector:AudioJack3 J4
U 1 1 618ACC78
P 8100 1650
F 0 "J4" H 7820 1583 50  0000 R CNN
F 1 "SJ-3523-SMT-TR" H 7820 1674 50  0000 R CNN
F 2 "Connector_Audio:Jack_3.5mm_CUI_SJ-3523-SMT_Horizontal" H 8100 1650 50  0001 C CNN
F 3 "https://www.cuidevices.com/product/resource/sj-352x-smt.pdf" H 8100 1650 50  0001 C CNN
	1    8100 1650
	-1   0    0    1   
$EndComp
$Comp
L Connector:Conn_01x03_Male J8
U 1 1 61729B74
P 2700 3050
F 0 "J8" H 2808 3331 50  0000 C CNN
F 1 "Servo Header" H 2808 3240 50  0000 C CNN
F 2 "Connector_PinHeader_2.54mm:PinHeader_1x03_P2.54mm_Vertical" H 2700 3050 50  0001 C CNN
F 3 "~" H 2700 3050 50  0001 C CNN
	1    2700 3050
	1    0    0    -1  
$EndComp
Text GLabel 2950 3050 2    50   Input ~ 0
+5V
Wire Wire Line
	2950 3050 2900 3050
$Comp
L power:GND #PWR0110
U 1 1 6172CFAD
P 2950 3150
F 0 "#PWR0110" H 2950 2900 50  0001 C CNN
F 1 "GND" H 2955 2977 50  0000 C CNN
F 2 "" H 2950 3150 50  0001 C CNN
F 3 "" H 2950 3150 50  0001 C CNN
	1    2950 3150
	1    0    0    -1  
$EndComp
Wire Wire Line
	2950 3150 2900 3150
Text Notes 3200 3050 0    50   ~ 0
TIM2_CH1
Wire Wire Line
	2900 2950 3650 2950
Text Label 3400 2950 0    50   ~ 0
PA0
$Comp
L custom_symbols:RCJ-2123 J1
U 1 1 61743C70
P 8350 2250
F 0 "J1" H 7970 2204 50  0000 R CNN
F 1 "RCJ-2123" H 7970 2295 50  0000 R CNN
F 2 "custom_components:Coaxial-RCJ-2123" H 8000 2750 50  0001 L BNN
F 3 "http://datasheets.diptrace.com/con_rca_jack/rcj-21xx.pdf" H 8350 2250 50  0001 L BNN
F 4 "CUI" H 8000 1750 50  0001 L BNN "MANUFACTURER"
	1    8350 2250
	-1   0    0    1   
$EndComp
$Comp
L custom_symbols:RCJ-2123 J2
U 1 1 6174F8A9
P 8350 3000
F 0 "J2" H 7970 2954 50  0000 R CNN
F 1 "RCJ-2123" H 7970 3045 50  0000 R CNN
F 2 "custom_components:Coaxial-RCJ-2123" H 8000 3500 50  0001 L BNN
F 3 "http://datasheets.diptrace.com/con_rca_jack/rcj-21xx.pdf" H 8350 3000 50  0001 L BNN
F 4 "CUI" H 8000 2500 50  0001 L BNN "MANUFACTURER"
	1    8350 3000
	-1   0    0    1   
$EndComp
Wire Wire Line
	7850 1950 7900 1950
Wire Wire Line
	7850 1950 7850 2550
Wire Wire Line
	7850 2550 7900 2550
Wire Wire Line
	7850 2550 7850 2700
Wire Wire Line
	7850 2700 7900 2700
Connection ~ 7850 2550
Wire Wire Line
	7850 2700 7850 3300
Wire Wire Line
	7850 3300 7900 3300
Connection ~ 7850 2700
$Comp
L power:GND #PWR0105
U 1 1 61769AE6
P 7850 3400
F 0 "#PWR0105" H 7850 3150 50  0001 C CNN
F 1 "GND" H 7855 3227 50  0000 C CNN
F 2 "" H 7850 3400 50  0001 C CNN
F 3 "" H 7850 3400 50  0001 C CNN
	1    7850 3400
	1    0    0    -1  
$EndComp
Wire Wire Line
	7850 3400 7850 3300
Connection ~ 7850 3300
Wire Wire Line
	7850 1950 7850 1750
Wire Wire Line
	7850 1750 7900 1750
Connection ~ 7850 1950
Wire Wire Line
	7850 1750 7850 1350
Wire Wire Line
	7850 1350 7900 1350
Connection ~ 7850 1750
Wire Wire Line
	7900 1650 7750 1650
Wire Wire Line
	7750 1650 7750 1750
Wire Wire Line
	7750 2350 7900 2350
Wire Wire Line
	7750 2350 7750 3100
Wire Wire Line
	7750 3100 7900 3100
Connection ~ 7750 2350
Wire Wire Line
	7900 1250 7750 1250
Wire Wire Line
	7750 1250 7750 1650
Connection ~ 7750 1650
Wire Wire Line
	7900 1150 7650 1150
Wire Wire Line
	7650 1150 7650 1550
Wire Wire Line
	7650 1550 7900 1550
Wire Wire Line
	7650 1550 7650 2050
Wire Wire Line
	7650 2150 7900 2150
Connection ~ 7650 1550
Wire Wire Line
	7650 2150 7650 2900
Wire Wire Line
	7650 2900 7900 2900
Connection ~ 7650 2150
Wire Wire Line
	7250 2050 7650 2050
Connection ~ 7650 2050
Wire Wire Line
	7650 2050 7650 2150
Wire Wire Line
	7250 1750 7750 1750
Connection ~ 7750 1750
Wire Wire Line
	7750 1750 7750 2350
Wire Notes Line
	700  1700 2000 1700
Wire Notes Line
	700  2450 2000 2450
Wire Notes Line
	700  2500 2000 2500
Wire Notes Line
	700  3250 2000 3250
Text Notes 1700 2600 2    50   ~ 0
VCC (Analog) Decoupling
Wire Notes Line
	700  2500 700  3250
Connection ~ 1200 2950
Wire Wire Line
	1200 2950 1600 2950
Wire Wire Line
	1000 2950 1200 2950
Wire Wire Line
	1200 2750 1600 2750
Connection ~ 1200 2750
Wire Wire Line
	1000 2750 1200 2750
$Comp
L Device:C_Small C6
U 1 1 617A9644
P 1600 2850
F 0 "C6" H 1692 2896 50  0000 L CNN
F 1 "0.1uF" H 1692 2805 50  0000 L CNN
F 2 "Capacitor_SMD:C_0805_2012Metric_Pad1.18x1.45mm_HandSolder" H 1600 2850 50  0001 C CNN
F 3 "~" H 1600 2850 50  0001 C CNN
	1    1600 2850
	1    0    0    -1  
$EndComp
$Comp
L Device:CP1_Small C5
U 1 1 617A963E
P 1200 2850
F 0 "C5" H 1291 2896 50  0000 L CNN
F 1 "10uF" H 1291 2805 50  0000 L CNN
F 2 "Capacitor_SMD:C_0805_2012Metric_Pad1.18x1.45mm_HandSolder" H 1200 2850 50  0001 C CNN
F 3 "~" H 1200 2850 50  0001 C CNN
	1    1200 2850
	1    0    0    -1  
$EndComp
$Comp
L power:GND #PWR0104
U 1 1 617A9638
P 1000 2950
F 0 "#PWR0104" H 1000 2700 50  0001 C CNN
F 1 "GND" H 1005 2777 50  0000 C CNN
F 2 "" H 1000 2950 50  0001 C CNN
F 3 "" H 1000 2950 50  0001 C CNN
	1    1000 2950
	1    0    0    -1  
$EndComp
Text GLabel 1000 2750 0    50   Input ~ 0
+3V3
Text Notes 1700 1800 2    50   ~ 0
VDD (Digital) Decoupling
Wire Notes Line
	700  1700 700  2450
Connection ~ 1200 2150
Wire Wire Line
	1200 2150 1600 2150
Wire Wire Line
	1000 2150 1200 2150
Wire Wire Line
	1200 1950 1600 1950
Connection ~ 1200 1950
Wire Wire Line
	1000 1950 1200 1950
$Comp
L Device:C_Small C4
U 1 1 61796B46
P 1600 2050
F 0 "C4" H 1692 2096 50  0000 L CNN
F 1 "0.1uF" H 1692 2005 50  0000 L CNN
F 2 "Capacitor_SMD:C_0805_2012Metric_Pad1.18x1.45mm_HandSolder" H 1600 2050 50  0001 C CNN
F 3 "~" H 1600 2050 50  0001 C CNN
	1    1600 2050
	1    0    0    -1  
$EndComp
$Comp
L Device:CP1_Small C3
U 1 1 61795EFE
P 1200 2050
F 0 "C3" H 1291 2096 50  0000 L CNN
F 1 "10uF" H 1291 2005 50  0000 L CNN
F 2 "Capacitor_SMD:C_0805_2012Metric_Pad1.18x1.45mm_HandSolder" H 1200 2050 50  0001 C CNN
F 3 "~" H 1200 2050 50  0001 C CNN
	1    1200 2050
	1    0    0    -1  
$EndComp
$Comp
L power:GND #PWR0103
U 1 1 61795A92
P 1000 2150
F 0 "#PWR0103" H 1000 1900 50  0001 C CNN
F 1 "GND" H 1005 1977 50  0000 C CNN
F 2 "" H 1000 2150 50  0001 C CNN
F 3 "" H 1000 2150 50  0001 C CNN
	1    1000 2150
	1    0    0    -1  
$EndComp
Text GLabel 1000 1950 0    50   Input ~ 0
+5V
Text Label 5150 1850 0    50   ~ 0
VREF
Text Label 6150 1850 0    50   ~ 0
VINR
Text Label 6150 1950 0    50   ~ 0
VINL
$EndSCHEMATC
