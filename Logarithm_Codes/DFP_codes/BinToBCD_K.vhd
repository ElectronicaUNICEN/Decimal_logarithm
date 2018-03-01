
-- Este modulo convierte un número binario de N bitsm a un número decimal de K digitos BCD.

-- Basado en solución secuencial de algoritmo Shift-and-add-3
-- la diferencia es que lo hago digit 2 para que poseea latencia N/2, 1 ciclo de start y N/2 ciclos de procesamiento

-- en ciclo 0 start=1, en_converter='1'
-- en ciclo 1 start=0, en_converter='1'
-- en ciclo 2 start=0, en_converter='1'
-- en ciclo 3 start=0, en_converter='1'
-- en ciclo 4 start=0, en_converter='1'

-- se maneja desde una máquina de estados externa, mediante en_converter y start

library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.STD_LOGIC_ARITH.ALL;
use IEEE.STD_LOGIC_UNSIGNED.ALL;

--library UNISIM;
--use UNISIM.VComponents.all;


entity BinToBCD_K is
	generic (N: integer:= 8; K: integer:= 3 );
    Port ( clk, rst: std_logic;
		   start: in std_logic; 
			en_converter: std_logic;
			a : in  STD_LOGIC_VECTOR (N-1 downto 0);
         s : out  STD_LOGIC_VECTOR (4*K-1 downto 0));
end BinToBCD_K;

architecture Behavioral of BinToBCD_K is

	component BinToBCD_1 
    Port ( clk, rst: std_logic;
		   start: in std_logic; 
			en_converter: std_logic;
			s_in : in  STD_LOGIC_VECTOR (1 downto 0);
			s_out : out  STD_LOGIC_VECTOR (1 downto 0);
         r : out  STD_LOGIC_VECTOR (3 downto 0));
	end component;

	signal reg_a, next_a: std_logic_vector(N-1 downto 0);
	
	type Tsin is array (0 to K) of std_logic_vector(1 downto 0);
	signal sin: Tsin;

begin

	sin(0) <= reg_a(N-1 downto N-2);
	
	gen_inst: for I in 1 to K generate
	
		inst_conv: BinToBCD_1 port map
							(clk => clk, rst => rst,
							start => start, en_converter => en_converter,
							s_in => sin(I-1),	s_out => sin(I),
							r => s(4*I-1 downto 4*(I-1)));
	end generate;



	next_a <= a when (start='1') else (reg_a(N-3 downto 0)&"00");
	
	
	process (clk, rst)
	begin 
		if rst='1' then 
			reg_a <= (others => '0');
		elsif rising_edge(clk) then
			if (en_converter='1') then 
				reg_a <=  next_a;
			end if;	
		end if;
	end process;

end Behavioral;

