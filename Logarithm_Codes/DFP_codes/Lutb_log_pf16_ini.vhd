-- Para reducción de latencia del algorimo, solo posee los logaritmos del paso 0
-- en la alternativa b, con shift a la salida de la LUT

library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.STD_LOGIC_ARITH.ALL;
use IEEE.STD_LOGIC_UNSIGNED.ALL;
use work.my_package.all;

Library UNISIM;
use UNISIM.vcomponents.all;

entity Lutb_log_pf16_ini is
	generic (P: integer:=16);
    port ( 
      d : in  STD_LOGIC_VECTOR (3 downto 0);-- corresponde a xi
      log : out  STD_LOGIC_VECTOR (4*P+8 downto 0)); -- en SVA, por eso un bit más
end Lutb_log_pf16_ini;


architecture Behavioral of Lutb_log_pf16_ini is


-- == Comienzo declaración

-- =============== Memoria LUT correspondiente a los ln c(i), usado solo en step=0 
-- Precisión 8 
type mlut_Log_0 is array (0 to 9) of std_logic_vector (4*P+7 downto 0);
---- los resultados están normalizados en x.yyyyyyyyyyyyy (para precisión 7),
---- en x.yyyyyyyyyyyyyyy yyyyyyyyyyyyyyyy(para precisión 16)
---- en x.yyyyyyyyyyyyyyyyyyyyyyyyyyyyyyyyy yyyyyyyyyyyyyyyyyyyyyyyyyyyyyyyyyy(para precisión 34)

signal lut_Log: mlut_Log_0 := ( 
		x"000000000000000000", -- LUT(0), No usada
		x"845098040014256830", -- LUT(1), log 7 = 0.84509804001425683071221625859264
		x"602059991327962390", -- LUT(2), log 4 = 0.60205999132796239042747778944899
		x"477121254719662437", -- LUT(3), log 3 = 0.47712125471966243729502790325512
		x"301029995663981195", -- LUT(4), log 2 = 0.30102999566398119521373889472449
		x"301029995663981195", -- LUT(5), log 2 = 0.30102999566398119521373889472449
		x"301029995663981195", -- LUT(6), log 2 = 0.30102999566398119521373889472449
		x"000000000000000000", -- LUT(7), log 1 = 0.000000
		x"000000000000000000", -- LUT(8), log 1 = 0.000000
		x"000000000000000000"); -- LUT(9), log 1 = 0.000000


begin

	log(4*P+8) <= '0';
	log(4*P+7 downto 0) <= lut_Log(conv_integer(d));
	
	
end Behavioral;

