-- Implementación I de SVA basado en CB 

-- Implementoación I del reporte del negador, o complmentador a 10.

--  Por otro lado, esta alernativa posee para la suma/resta en CB la configuración de los tres realizados: 
--TAddSub = 0 -> G y P basado en suma inicial
--TAddSub = 1 -> G y P a partir de las entradas
--TAddSub = 2 -> Basado en el tio Vazquez

-- La señal <op> indica si es suma(0) o resta(1)

-- Cada operando de entrada está en SVA
-- operando a = <s_a>,<a>
-- y operando b = <s_b>,<b>


library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.STD_LOGIC_ARITH.ALL;
use IEEE.STD_LOGIC_UNSIGNED.ALL;

library UNISIM;
use UNISIM.VComponents.all;

entity AS_SVA_CB_I is
		generic (TAddSub: integer:= 1; N : integer:=7);  
		port ( 
			  op : in  std_logic;
			  s_a : in  std_logic;
           a : in  std_logic_vector (4*N-1 downto 0);
			  s_b : in  std_logic;
           b : in  std_logic_vector (4*N-1 downto 0);
           co: out std_logic;
			  s_r : out std_logic;
           r : out std_logic_vector (4*N-1 downto 0));
end AS_SVA_CB_I;

architecture Behavioral of AS_SVA_CB_I is
	
	component addsub_BCD_L6 is
   Generic (TAddSub: integer:= 1; NDigit : integer:=7);    
    Port ( 
	        a, b : in  STD_LOGIC_VECTOR (NDigit*4-1 downto 0);
           cin, sub : in  STD_LOGIC;
           cout : out  STD_LOGIC;
           s : out  STD_LOGIC_VECTOR (NDigit*4-1 downto 0));
	end component;
	
	signal l,ll: std_logic;
	signal zeros: std_logic_vector(4*N-1 downto 0);
	
	-- corresponde a resultado parcial (r y co) del primer sumador/restador
	signal r_par: std_logic_vector(4*N-1 downto 0);
	
	signal co_par: std_logic;
	
	signal cyin: std_logic_vector(N downto 0);
	signal p : std_logic_vector(N-1 downto 0);

	
begin


	l <= op xor s_a xor s_b;
	ll <= l and (not co_par);
	zeros <= (others => '0');

	s_r <= s_a xor ll;
	
	co <= (not l) and co_par; -- este corresponde al overflow del circuito
--co <= cyin(N);-- para no consumi LUT
	
	-- =========================
	-- Instanciación de sumador/restador
	addsub: addsub_BCD_L6 
		Generic map (TAddSub => TAddSub,	NDigit => N)    
		Port map(a => a, b => b, cin => '0', sub => l, cout => co_par, s => r_par); 
   -- =========================     

-- ===============
-- Correspondiente a segunda suma/resta en CB
	cyin(0) <= ll; 	
	

	GenCch1: for i in 0 to N-1 generate
				
			   -- p1(i) <=  (not(r_par(i*4+3))) and (not(r_par(i*4+2))) and (not(r_par(i*4+1))) and (not(r_par(i*4))); 
				-- si es igual a 0, ya que el complemento será 9   
					
			pn: LUT6
			generic map (
				INIT => X"0000000000000001") -- Specify LUT Contents
			port map (
				O => p(i),
				I0 => r_par(i*4),
				I1 => r_par(i*4+1),
				I2 => r_par(i*4+2),
				I3 => r_par(i*4+3),
				I4 => '0',
				I5 => '0');					
					
			
				Mxcy_11: MUXCY port map (
							DI => '0', --g1(i), '0'
							CI => cyin(i),
							S => p(i),
							O => cyin(i+1));										
				
	end generate;	


-- Suma restauradora del segundo CB
	GenAddRes1: for i in 0 to N-1 generate


--	 Para el nivel 0
--			res0: LUT6
--				generic map (
--					INIT => X"02aa015502aa02aa") 
--				port map (
--					O => r(4*i), 
--   				I0 =>r_par(i*4),
--					I1 => r_par(i*4+1),
--					I2 => r_par(i*4+2),
--					I3 => r_par(i*4+3),
--					I4 => cyin(i), 
--					I5 => ll);
--
--	 Para el nivel 1 del resultado
--			res1: LUT6
--				generic map (
--					INIT => X"019800cc00cc00cc") 
--				port map (
--					O => r(4*i+1),
--   				I0 =>r_par(i*4),
--					I1 => r_par(i*4+1),
--					I2 => r_par(i*4+2),
--					I3 => r_par(i*4+3),
--					I4 => cyin(i), 
--					I5 => ll);



-- Para el nivel 0 y el nivel 1
			res0_1: LUT6_2 generic map (INIT => X"98ccccccaa55aaaa") 
				port map (
					O6 => r(i*4+1),  
					O5 => r(i*4),  
   				I0 =>r_par(i*4),
					I1 => r_par(i*4+1),
					
I2 =>	r_par(i*4+2),
I3 => cyin(i),
I4 => ll,	
--					I2 => cyin(i),
--					I3 => ll,
--					I4 => '1',
					I5 => '1'); 
					

	
--		 Para el nivel 2 
			res2: LUT6
				generic map (
					INIT => X"0078003c00f000f0") 
				port map (
					O => r(4*i+2), 
   				I0 =>r_par(i*4),
					I1 => r_par(i*4+1),
					I2 => r_par(i*4+2),
					I3 => r_par(i*4+3),
					I4 => cyin(i), 
					I5 => ll);

--		 Para el nivel 3 
			res3: LUT6
				generic map (
					INIT => X"0006000303000300") 
				port map (
					O => r(4*i+3),  
   				I0 =>r_par(i*4),
					I1 => r_par(i*4+1),
					I2 => r_par(i*4+2),
					I3 => r_par(i*4+3),
					I4 => cyin(i), 
					I5 => ll);

	end generate;
	
	
	
	

end Behavioral;


