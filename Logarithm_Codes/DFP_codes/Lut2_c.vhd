-- Lut que ofrece el factor para que el dato entre [0.1,1) entre en [0.7,1.4)


library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.STD_LOGIC_ARITH.ALL;
use IEEE.STD_LOGIC_UNSIGNED.ALL;
use work.my_package.all;

Library UNISIM;
use UNISIM.vcomponents.all;

entity Lut2_c is
    port ( d: in STD_LOGIC_VECTOR (3 downto 0); 
			  c : out  STD_LOGIC_VECTOR (3 downto 0)); 
end Lut2_c;

architecture Behavioral of Lut2_c is


type mlut_c is array (0 to 9) of std_logic_vector (3 downto 0);

signal lut_c: mlut_c := ( 
		x"0", -- LUT(0), No usada
		x"7", -- LUT(1), 
		x"4", -- LUT(2), 
		x"3", -- LUT(3), 
		x"2", -- LUT(4), 
		x"2", -- LUT(5), 
		x"2", -- LUT(6), 
		x"1", -- LUT(7), 
		x"1", -- LUT(8), 
		x"1"); -- LUT(9), 
--		

begin
	
	c <= lut_c(conv_integer(d));
	
--	c  <= x"7" when (d=x"1") else -- en [0.1,0.2) multiplico por 7
--			x"4" when (d=x"2") else -- en [0.2,0.3) multiplico por 4
--			x"3" when (d=x"3") else -- en [0.3,0.4) multiplico por 3
--			x"2" when ((d=x"4") or (d=x"5") or (d=x"6")) else -- en [0.4,0.7) multiplico por 2
--			x"1"; -- en [0.7,1) multiplico por 1
	
end Behavioral;

