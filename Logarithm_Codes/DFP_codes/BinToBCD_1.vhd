
-- Este modulo es usado por <BinToBCD_K> para convertir un número binario de N bits a un número decimal de K digitos BCD.
-- Basado en solución secuencial de algoritmo Shift-and-add-3.

-- Es para arquitectura digit-serial. Procesa dos sígitos binarios y arma el resultado r de un dígio BCD

-- se maneja desde una máquina de estados externa, mediante en_converter y start

library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.STD_LOGIC_ARITH.ALL;
use IEEE.STD_LOGIC_UNSIGNED.ALL;

--library UNISIM;
--use UNISIM.VComponents.all;


entity BinToBCD_1 is
    Port ( clk, rst: std_logic;
		   start: in std_logic; 
			en_converter: std_logic;
			s_in : in  STD_LOGIC_VECTOR (1 downto 0);
			s_out : out  STD_LOGIC_VECTOR (1 downto 0);
         r : out  STD_LOGIC_VECTOR (3 downto 0));
end BinToBCD_1;

architecture Behavioral of BinToBCD_1 is

	signal ss_out: std_logic_vector(1 downto 0);
	signal sum1, sum0: std_logic_vector(2 downto 0);
	signal reg_r, next_r: std_logic_vector(3 downto 0);
	


begin


	ss_out(1) <= reg_r(3) or (reg_r(2) and (reg_r(1) or reg_r(0)));
	
	sum1 <= reg_r(2 downto 0) + ('0'&ss_out(1)&ss_out(1));
	
	ss_out(0) <= sum1(2) or (sum1(1) and (sum1(0) or s_in(1))); 
	
	sum0 <= (sum1(1 downto 0)&s_in(1)) + ('0'&ss_out(0)&ss_out(0));			
			
	next_r <= (others => '0') when (start='1') else (sum0&s_in(0));
	
	process (clk, rst)
	begin 
		if rst='1' then 
			reg_r <= "0000";
		elsif rising_edge(clk) then
			if (en_converter='1') then 
				reg_r <= next_r;
			end if;	
		end if;
	end process;

	s_out(1) <= ss_out(1);
	s_out(0) <= ss_out(0); 

	r <= reg_r;

end Behavioral;

