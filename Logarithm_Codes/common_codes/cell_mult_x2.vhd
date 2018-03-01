-- celda para realizar multiplicación de palablra BCD por 2
--proviene desde D:..\Doctorado\ProyMultNx1\codigos

library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.STD_LOGIC_ARITH.ALL;
use IEEE.STD_LOGIC_UNSIGNED.ALL;

library UNISIM;
use UNISIM.VComponents.all;

entity cell_mult_x2 is
    Port ( d : in  STD_LOGIC_VECTOR (3 downto 0);
           s : out  STD_LOGIC_VECTOR (3 downto 0);
           cin : in  STD_LOGIC;
           co : out  STD_LOGIC);
end cell_mult_x2;

architecture Behavioral of cell_mult_x2 is

signal t: std_logic;
signal sx: std_logic_vector(3 downto 0);

begin

	-- evalua si es mayor igual a 5
	t <= d(3) or (d(2) and (d(1) or d(0)));

	
	sx <= d + "0011";
	
	co <= sx(3) when t='1' else '0';
	s(3 downto 1) <= sx(2 downto 0) when t='1' else d(2 downto 0);
	
	s(0) <= cin;
	
end Behavioral;

