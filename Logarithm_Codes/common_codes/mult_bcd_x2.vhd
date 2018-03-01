--
--  Multilicador de N dígitos por 2
--proviene desde D:..\Doctorado\ProyMultNx1\codigos


library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.STD_LOGIC_ARITH.ALL;
use IEEE.STD_LOGIC_UNSIGNED.ALL;


library UNISIM;
use UNISIM.VComponents.all;

entity mult_bcd_x2 is
	 	 Generic (P:integer:=4);
	     Port ( d : in  STD_LOGIC_VECTOR (4*P-1 downto 0);
           r : out  STD_LOGIC_VECTOR (4*P+3 downto 0));
end mult_bcd_x2;

architecture Behavioral of mult_bcd_x2 is


	component cell_mult_x2 
    Port ( d : in  STD_LOGIC_VECTOR (3 downto 0);
           s : out  STD_LOGIC_VECTOR (3 downto 0);
           cin : in  STD_LOGIC;
           co : out  STD_LOGIC);
	end component;

	signal c: std_logic_vector(P downto 0);

begin

	c(0) <= '0';
	
	genMul5t: for I in 0 to P-1 generate
		ecell: cell_mult_x2 port map( d => d(4*(I+1)-1 downto 4*I),  s => r(4*(I+1)-1 downto 4*I), cin =>c(I),  co  =>c(I+1));
	end generate;

	r(4*P+3 downto 4*P) <= "000"&c(P);

end Behavioral;

