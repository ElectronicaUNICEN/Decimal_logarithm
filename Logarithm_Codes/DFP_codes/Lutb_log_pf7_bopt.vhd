


library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.STD_LOGIC_ARITH.ALL;
use IEEE.STD_LOGIC_UNSIGNED.ALL;
use work.my_package.all;

Library UNISIM;
use UNISIM.vcomponents.all;

entity Lutb_log_pf7_bopt is
	generic (P: integer:=7);
    port ( 
 			step : in std_logic_vector(log2sup(P+2)-1 downto 0);
			offset_step : in std_logic_vector(log2sup(P+1)-1 downto 0);
			true_step: in std_logic_vector(log2sup(2*P+1)-1 downto 0);
           d : in  STD_LOGIC_VECTOR (3 downto 0);-- corresponde a xi
			  x_greater_1: in std_logic; -- indica si x es mayor a uno
           log : out  STD_LOGIC_VECTOR (4*P+8 downto 0)); -- en SVA, por eso un bit más
end Lutb_log_pf7_bopt;


architecture Behavioral of Lutb_log_pf7_bopt is



	
-- ====== Comienzo declaración
-- declaracion de meomria de log para la parte de x>1
--

type mlut_LogShP is array (0 to P+2) of std_logic_vector (8*P+7 downto 0);

signal lut_LogShP1: mlut_LogShP := (
		x"0000000000000000", -- LUT(0), No usada
		x"0457574905606751", -- LUT(1) = log (0.9) = -0.045757490560675125
		x"0043648054024500", -- LUT(2) = log (0.99) = -0.0043648054024500847
		x"0004345117740176", -- LUT(3) = log (0.999) = -0.00043451177401769131
		x"0000434316198075", -- LUT(4) = log (0.9999) = -0.000043431619807510385
		x"0000043429665339", -- LUT(5) = log (0.99999) = -0.0000043429665339013794
		x"0000004342946990", -- LUT(6) = log (0.999999) = -4.3429469905063754E-7
		x"0000000434294503", -- LUT(7) = log (0.9999999) = -4.3429450361797737E-8
		x"0000000043429448", -- LUT(8) = log (0.99999999) = -4.3429448407472425E-9
		x"0000000004342944"); -- LUT(9) = log (0.999999999) = 
		

signal lut_LogShP2: mlut_LogShP := (
		x"0000000000000000", -- LUT(0), No usada
		x"0969100130080561", -- LUT(1) = log (0.8) = -0.096910013008056414
		x"0087739243075051", -- LUT(2) = log (0.98) = -0.0087739243075051434
		x"0008694587126288", -- LUT(3) = log (0.998) = -0.00086945871262889062
		x"0000868675834285", -- LUT(4) = log (0.9998) = -0.000086867583428580795
		x"0000086859764981", -- LUT(5) = log (0.99998) = -0.0000086859764981195532
		x"0000008685898323", -- LUT(6) = log (0.999998) = -8.6858983239662558E-7
		x"0000000868589050", -- LUT(7) = log (0.9999998) = -8.6858905066541162E-8
		x"0000000086858897", -- LUT(8) = log (0.99999998) = -8.6858897249239341E-9
		x"0000000008685889"); -- LUT(9) = log (0.999999998) = 
		
signal lut_LogShP3: mlut_LogShP := (
		x"0000000000000000", -- LUT(0), No usada
		x"1549019599857431", -- LUT(1) = log (0.7) = -0.15490195998574317
		x"0132282657337551", -- LUT(2) = log (0.97) = -0.013228265733755148
		x"0013048416883442", -- LUT(3) = log (0.997) = -0.0013048416883442801
		x"0001303078917321", -- LUT(4) = log (0.9997) = -0.00013030789173219119
		x"0000130290298935", -- LUT(5) = log (0.99997) = -0.000013029029893523150
		x"0000013028854000", -- LUT(6) = log (0.999997) = -0.0000013028854000388327
		x"0000001302883641", -- LUT(7) = log (0.9999997) = -1.3028836411423114E-7
		x"0000000130288346", -- LUT(8) = log (0.99999997) = -1.3028834652530076E-8
		x"0000000013028834"); -- LUT(9) = log (0.999999997) = 

signal lut_LogShP4: mlut_LogShP := (
		x"0000000000000000", -- LUT(0), No usada
		x"2218487496163563", -- LUT(1) = log (0.6) = -0.22184874961635637
		x"0177287669604315", -- LUT(2) = log (0.96) = -0.017728766960431587
		x"0017406615763012", -- LUT(3) = log (0.996) = -0.001740661576301268444
		x"0001737525455875", -- LUT(4) = log (0.9996) = -0.00017375254558758231
		x"0000173721267209", -- LUT(5) = log (0.99996) = -0.000017372126720980823
		x"0000017371814019", -- LUT(6) = log (0.999996) = -0.0000017371814019781275
		x"0000001737178275", -- LUT(7) = log (0.9999996) = -1.7371782750486855E-7
		x"0000000173717796", -- LUT(8) = log (0.99999996) = -1.7371779623565668E-8
		x"0000000017371779"); -- LUT(9) = log (0.999999996) = 

signal lut_LogShP5: mlut_LogShP := (
		x"0000000000000000", -- LUT(0), No usada
		x"3010299956639812", -- LUT(1) = log (0.5) = -0.30102999566398120
		x"0222763947111522", -- LUT(2) = log (0.95) = -0.022276394711152234
		x"0021769192542745", -- LUT(3) = log (0.995) = -0.0021769192542745451
		x"0002172015458642", -- LUT(4) = log (0.9995) = -0.00021720154586425580
		x"0000217152669813", -- LUT(5) = log (0.99995) = -0.000021715266981361252
		x"0000021714778382", -- LUT(6) = log (0.999995) = -0.0000021714778382153786
		x"0000002171472952", -- LUT(7) = log (0.9999995) = -2.1714729523845425E-7
		x"0000000217147246", -- LUT(8) = log (0.99999995) = -2.1714724638030712E-8
		x"0000000021714724"); -- LUT(9) = log (0.999999995) = 

signal lut_LogShP6: mlut_LogShP := (
		x"0000000000000000", -- LUT(0), No usada
		x"3979400086720376", -- LUT(1) = log (0.4) = -0.39794000867203761
		x"0268721464003013", -- LUT(2) = log (0.94) = -0.026872146400301340
		x"0026136156026866", -- LUT(3) = log (0.994) = -0.0026136156026866880
		x"0002606548934319", -- LUT(4) = log (0.9994) = -0.00026065489343197428
		x"0000260584506755", -- LUT(5) = log (0.99994) = -0.000026058450675533145
		x"0000026057747087", -- LUT(6) = log (0.999994) = -0.0000026057747087514546
		x"0000002605767673", -- LUT(7) = log (0.9999994) = -2.6057676731498911E-7
		x"0000000260576696", -- LUT(8) = log (0.99999994) = -2.6057669695925208E-8
		x"0000000026057669"); -- LUT(9) = log (0.999999994) = 

signal lut_LogShP7: mlut_LogShP := (
		x"0000000000000000", -- LUT(0), No usada
		x"5228787452803375", -- LUT(1) = log (0.3) = -0.52287874528033756
		x"0315170514460648", -- LUT(2) = log (0.93) = -0.031517051446064883
		x"0030507515046188", -- LUT(3) = log (0.993) = -0.0030507515046188241
		x"0003041125891607", -- LUT(4) = log (0.9993) = -0.00030411258916076147
		x"0000304016778043", -- LUT(5) = log (0.99993) = -0.000030401677804365234
		x"0000030400720135", -- LUT(6) = log (0.999993) = -0.0000030400720135872240
		x"0000003040062437", -- LUT(7) = log (0.9999993) = -3.0400624373447400E-7
		x"0000000304006147", -- LUT(8) = log (0.99999993) = -3.0400614797249158E-8
		x"0000000030400614"); -- LUT(9) = log (0.999999993) = 


signal lut_LogShP8: mlut_LogShP := (
		x"0000000000000000", -- LUT(0), No usada
		x"6989700043360188", -- LUT(1) = log (0.2) = -0.69897000433601880
		x"0362121726544447", -- LUT(2) = log (0.92) = -0.036212172654444731
		x"0034883278458213", -- LUT(3) = log (0.992) = -0.0034883278458213443
		x"0003475746339209", -- LUT(4) = log (0.9992) = -0.00034757463392090232
		x"0000347449483687", -- LUT(5) = log (0.99992) = -0.000034744948368726276
		x"0000034743697527", -- LUT(6) = log (0.999992) = -0.0000034743697527235556
		x"0000003474357244", -- LUT(7) = log (0.9999992) = -3.4743572449690979E-7
		x"0000000347435599", -- LUT(8) = log (0.99999992) = -3.4743559942002562E-8
		x"0000000034743559"); -- LUT(9) = log (0.999999992) = 
		
signal lut_LogShP9: mlut_LogShP := (
		x"0000000000000000", -- LUT(0), No usada
		x"2787536009528280", -- LUT(1) = log (0.1) = -1 ... creo que nunca es usada
		x"0409586076789064", -- LUT(2) = log (0.91) = -0.040958607678906400
		x"0039263455147246", -- LUT(3) = log (0.991) = -0.0039263455147246716
		x"0003910410285829", -- LUT(4) = log (0.9991) = -0.00039104102858294304
		x"0000390882623694", -- LUT(5) = log (0.99991) = -0.000039088262369485056
		x"0000039086679261", -- LUT(6) = log (0.999991) = -0.0000039086679261613178
		x"0000003908652096", -- LUT(7) = log (0.9999991) = -3.9086520960229735E-7
		x"0000000390865051", -- LUT(8) = log (0.99999991) = -3.9086505130185422E-8
		x"0000000039086505"); -- LUT(9) = log (0.999999991) = -3.9086505130185422E-9


-- ====== FIN declaración
-- declaracion de meomria de log para la parte de x>1

-- ====== Comienzo declaración
-- declaracion de meomria de log para la parte de x<1

type mlut_LogShN is array (0 to P+2) of std_logic_vector (8*P+7 downto 0);

signal lut_LogShN9: mlut_LogShN := (
		x"0000000000000000", -- LUT(0), No usada
		x"0413926851582250", -- LUT(1) = log (1.1) = 0.041392685158225041
		x"0043213737826425", -- LUT(2) = log (1.01) = 0.0043213737826425743
		x"0004340774793186", -- LUT(3) = log (1.001) = 0.00043407747931864067
		x"0000434272768626", -- LUT(4) = log (1.0001) = 0.000043427276862669637
		x"0000043429231044", -- LUT(5) = log (1.00001) = 0.0000043429231044531869
		x"0000004342942647", -- LUT(6) = log (1.000001) = 4.3429426475615564E-7
		x"0000000434294460", -- LUT(7) = log (1.0000001) = 4.3429446018852918E-8
		x"0000000043429447", -- LUT(8) = log (1.00000001) = 4.3429447973177943E-9
		x"0000000004342944"); -- LUT(9) = log (1.000000001) = 4.3429447973177943E-10


signal lut_LogShN8: mlut_LogShN := (
		x"0000000000000000", -- LUT(0), No usada
		x"0791812460476248", -- LUT(1) = log (1.2) = 0.079181246047624828
		x"0086001717619175", -- LUT(2) = log (1.02) = 0.0086001717619175610
		x"0008677215312269", -- LUT(3) = log (1.002) = 0.00086772153122691249
		x"0000868502116489", -- LUT(4) = log (1.0002) = 0.000086850211648957229
		x"0000086858027803", -- LUT(5) = log (1.00002) = 0.0000086858027803267571
		x"0000008685880952", -- LUT(6) = log (1.000002) = 8.6858809521869797E-7
		x"0000000868588876", -- LUT(7) = log (1.0000002) = 8.6858887694761886E-8
		x"0000000086858895", -- LUT(8) = log (1.00000002) = 8.6858895512061413E-9
		x"0000000008685889"); -- LUT(9) = log (1.000000002) = 8.6858895512061413E-10
		

signal lut_LogShN7: mlut_LogShN := (
		x"0000000000000000", -- LUT(0), No usada
		x"1139433523068367", -- LUT(1) = log (1.3) = 0.11394335230683677
		x"0128372247051722", -- LUT(2) = log (1.03) = 0.012837224705172205
		x"0013009330204181", -- LUT(3) = log (1.003) = 0.0013009330204181188
		x"0001302688052270", -- LUT(4) = log (1.0003) = 0.00013026880522706100
		x"0000130286390284", -- LUT(5) = log (1.00003) = 0.000013028639028489261
		x"0000013028814913", -- LUT(6) = log (1.000003) = 0.0000013028814913884956
		x"0000001302883250", -- LUT(7) = log (1.0000003) = 1.3028832502772777E-7
		x"0000000130288342", -- LUT(8) = log (1.00000003) = 1.3028834261665042E-8
		x"0000000013028834"); -- LUT(9) = log (1.000000003) = 1.3028834261665042E-9

signal lut_LogShN6: mlut_LogShN := (
		x"0000000000000000", -- LUT(0), No usada
		x"1461280356782380", -- LUT(1) = log (1.4) = 0.14612803567823803
		x"0170333392987803", -- LUT(2) = log (1.04) = 0.017033339298780355
		x"0017337128090005", -- LUT(3) = log (1.004) = 0.0017337128090005298
		x"0001736830584649", -- LUT(4) = log (1.0004) = 0.00017368305846491882
		x"0000173714318498", -- LUT(5) = log (1.00004) = 0.000017371431849809222
		x"0000017371744532", -- LUT(6) = log (1.000004) = 0.0000017371744532664170
		x"0000001737177580", -- LUT(7) = log (1.0000004) = 1.7371775801775144E-7
		x"0000000173717789", -- LUT(8) = log (1.00000004) = 1.7371778928694497E-8
		x"0000000017371778"); -- LUT(9) = log (1.000000004) = 1.7371778928694497E-9


signal lut_LogShN5: mlut_LogShN := (
		x"0000000000000000", -- LUT(0), No usada
		x"1760912590556812", -- LUT(1) = log (1.5) = 0.17609125905568124
		x"0211892990699380", -- LUT(2) = log (1.05) = 0.021189299069938073
		x"0021660617565076", -- LUT(3) = log (1.005) = 0.0021660617565076762
		x"0002170929722302", -- LUT(4) = log (1.0005) = 0.00021709297223020828
		x"0000217141812451", -- LUT(5) = log (1.00005) = 0.000021714181245155137
		x"0000021714669808", -- LUT(6) = log (1.000005) = 0.0000021714669808533309
		x"0000002171471866", -- LUT(7) = log (1.0000005) = 2.1714718666483377E-7
		x"0000000217147235", -- LUT(8) = log (1.00000005) = 2.1714723552294507E-8
		x"0000000021714723"); -- LUT(9) = log (1.000000005) = 2.1714723552294507E-9

signal lut_LogShN4: mlut_LogShN := (
		x"0000000000000000", -- LUT(0), No usada
		x"2041199826559247", -- LUT(1) = log (1.6) = 0.20411998265592478
		x"0253058652647702", -- LUT(2) = log (1.06) = 0.025305865264770241
		x"0025979807199085", -- LUT(3) = log (1.006) = 0.0025979807199085923
		x"0002604985473903", -- LUT(4) = log (1.0006) = 0.00026049854739034682
		x"0000260568872153", -- LUT(5) = log (1.00006) = 0.000026056887215395479
		x"0000026057590741", -- LUT(6) = log (1.000006) = 0.0000026057590741501058
		x"0000002605766109", -- LUT(7) = log (1.0000006) = 2.6057661096897562E-7
		x"0000000260576681", -- LUT(8) = log (1.00000006) = 2.6057668132465074E-8
		x"0000000026057668"); -- LUT(9) = log (1.000000006) = 2.6057668132465074E-9
		
signal lut_LogShN3: mlut_LogShN := (
		x"0000000000000000", -- LUT(0), No usada
		x"2304489213782739", -- LUT(1) = log (1.7) = 0.23044892137827393
		x"0293837776852096", -- LUT(2) = log (1.07) = 0.029383777685209641
		x"0030294705536180", -- LUT(3) = log (1.007) = 0.0030294705536180072
		x"0003038997848124", -- LUT(4) = log (1.0007) = 0.00030389978481249181
		x"0000303995497613", -- LUT(5) = log (1.00007) = 0.000030399549761398694
		x"0000030400507331", -- LUT(6) = log (1.000007) = 0.0000030400507331576102
		x"0000003040060309", -- LUT(7) = log (1.0000007) = 3.0400603093017787E-7
		x"0000000304006126", -- LUT(8) = log (1.00000007) = 3.0400612669206197E-8
		x"0000000030400612"); -- LUT(9) = log (1.000000007) = 3.0400612669206197E-9

signal lut_LogShN2: mlut_LogShN := (
		x"0000000000000000", -- LUT(0), No usada
		x"2552725051033060", -- LUT(1) = log (1.8) = 0.25527250510330607
		x"0334237554869497", -- LUT(2) = log (1.08) = 0.033423755486949702
		x"0034605321095064", -- LUT(3) = log (1.008) = 0.0034605321095064862
		x"0003472966853635", -- LUT(4) = log (1.0008) = 0.00034729668536354069
		x"0000347421688840", -- LUT(5) = log (1.00008) = 0.000034742168884033200
		x"0000034743419578", -- LUT(6) = log (1.000008) = 0.0000034743419578767129
		x"0000003474354465", -- LUT(7) = log (1.0000008) = 3.4743544654844137E-7
		x"0000000347435571", -- LUT(8) = log (1.00000008) = 3.4743557162517878E-8
		x"0000000034743557"); -- LUT(9) = log (1.000000008) = 3.4743557162517878E-9

signal lut_LogShN1: mlut_LogShN := (
		x"0000000000000000", -- LUT(0), No usada
		x"2787536009528289", -- LUT(1) = log (1.9) = 0.27875360095282896
		x"0374264979406236", -- LUT(2) = log (1.09) = 0.037426497940623635
		x"0038911662369105", -- LUT(3) = log (1.009) = 0.0038911662369105217
		x"0003906892499101", -- LUT(4) = log (1.0009) = 0.00039068924991013103
		x"0000390847445841", -- LUT(5) = log (1.00009) = 0.000039084744584167392
		x"0000039086327483", -- LUT(6) = log (1.000009) = 0.0000039086327483082822
		x"0000003908648578", -- LUT(7) = log (1.0000009) = 3.9086485782376701E-7
		x"0000000390865016", -- LUT(8) = log (1.00000009) = 3.9086501612400118E-8
		x"0000000039086501"); -- LUT(9) = log (1.000000009) = 3.9086501612400118E-9

signal lut_LogShN0: mlut_LogShN := (
		x"0000000000000000", -- LUT(0), No usada
		x"3010299956639812", -- LUT(1) = log (2.0) = 0.30102999566398120
		x"0413926851582250", -- LUT(2) = log (1.10) = 0.041392685158225041
		x"0043213737826425", -- LUT(3) = log (1.010) = 0.0043213737826425743
		x"0004340774793186", -- LUT(4) = log (1.0010) = 0.00043407747931864067
		x"0000434272768626", -- LUT(5) = log (1.00010) = 0.000043427276862669637
		x"0000043429231044", -- LUT(6) = log (1.000010) = 0.0000043429231044531869
		x"0000004342942647", -- LUT(7) = log (1.0000010) = 4.3429426475615564E-7
		x"0000000434294460", -- LUT(8) = log (1.00000010) = 4.3429446018852918E-8
		x"0000000043429446"); -- LUT(9) = log (1.000000010) = 4.3429446018852918E-9


-- ====== FIN declaración
-- declaracion de meomria de log para la parte de x<1


type mem_logSh_P is array (0 to 9) of STD_LOGIC_VECTOR (8*P+7 downto 0); 
type mem_logSh_N is array (0 to 9) of STD_LOGIC_VECTOR (8*P+7 downto 0); 

signal vlog_ShP: mem_LogSh_P;
signal vlog_ShN: mem_LogSh_N;

signal log_lut: std_logic_vector(8*P+7 downto 0); 
signal log_lut_sh: std_logic_vector(4*P+7 downto 0);

signal log_lut_optP, log_lut_optN, log_lut_opt: std_logic_vector(8*P+7 downto 0); 
signal log_lut_opt_sh: std_logic_vector(4*P+7 downto 0);

signal index:std_logic_vector(log2sup(2*P+1)-1 downto 0);

begin

	index <= (others => '0') when (conv_integer(true_step)>(P+2)) else true_step;


	vlog_ShP(0) <= (others => '0');
	vlog_ShP(1) <= lut_LogShP1(conv_integer(index));
	vlog_ShP(2) <= lut_LogShP2(conv_integer(index));
	vlog_ShP(3) <= lut_LogShP3(conv_integer(index));
	vlog_ShP(4) <= lut_LogShP4(conv_integer(index));
	vlog_ShP(5) <= lut_LogShP5(conv_integer(index));
	vlog_ShP(6) <= lut_LogShP6(conv_integer(index));
	vlog_ShP(7) <= lut_LogShP7(conv_integer(index));
	vlog_ShP(8) <= lut_LogShP8(conv_integer(index));
	vlog_ShP(9) <= lut_LogShP9(conv_integer(index));

	vlog_ShN(0) <= lut_LogShN0(conv_integer(index));
	vlog_ShN(1) <= lut_LogShN1(conv_integer(index));
	vlog_ShN(2) <= lut_LogShN2(conv_integer(index));
	vlog_ShN(3) <= lut_LogShN3(conv_integer(index));
	vlog_ShN(4) <= lut_LogShN4(conv_integer(index));
	vlog_ShN(5) <= lut_LogShN5(conv_integer(index));
	vlog_ShN(6) <= lut_LogShN6(conv_integer(index));
	vlog_ShN(7) <= lut_LogShN7(conv_integer(index));
	vlog_ShN(8) <= lut_LogShN8(conv_integer(index));
	vlog_ShN(9) <= lut_LogShN9(conv_integer(index));

	
	log_lut <= vlog_ShP(conv_integer(d)) when (x_greater_1='1') else vlog_ShN(conv_integer(d));

	log_lut_sh <= log_lut(8*P+7 downto 4*P) when (offset_step="000") else
					log_lut(8*P+3 downto 4*(P-1)) when (offset_step="001") else
					log_lut(8*P-1 downto 4*(P-2)) when (offset_step="010") else
					log_lut(8*P-5 downto 4*(P-3)) when (offset_step="011") else
					log_lut(8*(P-1)-1 downto 4*(P-4)) when (offset_step="100") else
					log_lut(8*(P-1)-5 downto 4*(P-5)) when (offset_step="101") else
					log_lut(8*(P-2)-1 downto 4*(P-6)) when (offset_step="110") else
					log_lut(8*(P-2)-5 downto 4*(P-7)) when (offset_step="111") else
					(others => '0');



	-- para LUT(P+2), se usa cuando hay 9's iniciales. 
	
	
	-- Lo que se debe hacer es desplazar a la derecha true_step - (P+2), por tema de patrón
	-- y luego desplazar a la izquierda offset_step por tema de 9's iniciales. 
	-- Entonces desplazo a izquierda offset_step - true_step + P + 2. eso es igual a 
	-- P+2-step. Es decir que desplaza a P+2-step lugares a la izquierda Lut(P+2)
	
	log_lut_optP <= lut_LogShP1(P+2) when d=x"1" else
							lut_LogShP2(P+2) when d=x"2" else
							lut_LogShP3(P+2) when d=x"3" else
							lut_LogShP4(P+2) when d=x"4" else
							lut_LogShP5(P+2) when d=x"5" else
							lut_LogShP6(P+2) when d=x"6" else
							lut_LogShP7(P+2) when d=x"7" else
							lut_LogShP8(P+2) when d=x"8" else
							lut_LogShP9(P+2) when d=x"9" else
							(others => '0');
	
	log_lut_optN <= lut_LogShN0(P+2) when d=x"1" else
							lut_LogShN1(P+2) when d=x"1" else
							lut_LogShN2(P+2) when d=x"2" else
							lut_LogShN3(P+2) when d=x"3" else
							lut_LogShN4(P+2) when d=x"4" else
							lut_LogShN5(P+2) when d=x"5" else
							lut_LogShN6(P+2) when d=x"6" else
							lut_LogShN7(P+2) when d=x"7" else
							lut_LogShN8(P+2) when d=x"8" else
							lut_LogShN9(P+2) when d=x"9" else
							(others => '0');

	
	log_lut_opt <= log_lut_optP when (x_greater_1='1') else log_lut_optN;


	
  log_lut_opt_sh <= (log_lut_opt(4*(P+1)-1 downto 0)&(x"0")) when step="0001" else -- desplazo P+1 lugares a la izquierda
							log_lut_opt(4*(P+2)-1 downto 0) when step="0010" else -- desplazo P lugares a la izquierda
							log_lut_opt(4*(P+3)-1 downto 4) when step="0011" else -- desplazo P-1 lugares a la izquierda
							log_lut_opt(4*(P+4)-1 downto 8) when step="0100" else -- desplazo P-2 lugares a la izquierda
							log_lut_opt(4*(P+5)-1 downto 12) when step="0101" else -- desplazo P-3 lugares a la izquierda
							log_lut_opt(4*(P+6)-1 downto 16) when step="0110" else -- desplazo P-4 lugares a la izquierda
							log_lut_opt(4*(P+7)-1 downto 20) when step="0111" else -- desplazo P-5 lugares a la izquierda
							(log_lut_opt(4*(P+8)-1 downto 24)) when step="1000" else -- desplazo P-6 lugares a la izquierda
							(others => '0'); -- nunca se da
	

	log(4*P+7 downto 0) <= log_lut_opt_sh when (conv_integer(true_step)>(P+2)) else log_lut_sh;
	log(4*P+8) <= x_greater_1;


end Behavioral;

