
-- Esta implementación se integra el complemento a 9 con las entradas para determinar el p y g
-- los p y g se determinan a partir de las entradas

library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.STD_LOGIC_ARITH.ALL;
use IEEE.STD_LOGIC_UNSIGNED.ALL;

library UNISIM;
use UNISIM.VComponents.all;

entity AddSubBCDII is
	generic (NDigit: integer:=16);
	  Port ( 
           a, b : in  STD_LOGIC_VECTOR (NDigit*4-1 downto 0);
           cin, sub : in  STD_LOGIC;
		     cout : out  STD_LOGIC;
           s : out  STD_LOGIC_VECTOR (NDigit*4-1 downto 0));
end AddSubBCDII;


architecture Behavioral of AddSubBCDII is

component AddSub4V5II 
		Port ( a : in  STD_LOGIC_VECTOR (3 downto 0);
           b : in  STD_LOGIC_VECTOR (3 downto 0);
           cin : in  STD_LOGIC;
           sub: in std_logic;
			  c : out  STD_LOGIC_VECTOR (3 downto 0);
           cout : out  STD_LOGIC);
end component;


component GenGyPPIIG 
    Port ( x : in  STD_LOGIC_VECTOR (3 downto 0);
           y : in  STD_LOGIC_VECTOR (3 downto 0);
			  sub: in std_logic;
				gg, pp : out  STD_LOGIC);
			  
end component;


signal ss: std_logic_vector(NDigit*4-1 downto 0);
signal cyin: std_logic_vector(NDigit downto 0);

signal pp, gg: std_logic_vector(NDigit-1 downto 0);
signal p, g: std_logic_vector(NDigit-1 downto 0);

begin

	cyin(0) <= sub; 	
	
	GenAdd: for i in 0 to NDigit-1 generate

		GAddSub: AddSub4V5II Port map( a => a((i+1)*4-1 downto i*4),
										b => b((i+1)*4-1 downto i*4),
										sub => sub,
										cin => '0',
										c => ss((i+1)*4-1 downto i*4),
										cout => open);
	end generate;	
	
	
	
	GyPP: for i in 0 to NDigit-1 generate
		
		EGyPPAddSub: GenGyPPIIG Port map ( x => a((i+1)*4-1 downto i*4),
											y => b((i+1)*4-1 downto i*4), 
											sub => sub,
											gg => gg(i),
											pp => pp(i));
           
    	GP_LUT6 : LUT6_2
		generic map (
			INIT => X"96009600FFFF6000") 
		-- p = pp.(x xor y xor sub) (96009600)
		-- g = gg + pp.x.(y xor sub)  (FFFF6000)
		  port map (
				O6 => p(i),  
				O5 => g(i),  
				I0 => sub,
				I1 => b(4*i),   
				I2 => a(4*i),   
				I3 => pp(i),   
				I4 => gg(i),   
				I5 => '1'    
			);

			Mxcy: MUXCY port map (
						DI => g(i),
						CI => cyin(i),
						S => p(i),
						O => cyin(i+1));
	
	
	
	end generate;
	

--	GyCChAddSub: for i in 0 to NDigit/4-1 generate
--		
--			aa(i*4+3 downto i*4) <= (a(i*16+12)&a(i*16+8)&a(i*16+4)&a(i*16));
--			bb(i*4+3 downto i*4) <= (b(i*16+12)&b(i*16+8)&b(i*16+4)&b(i*16));
--		
--		
--			ECChAddSub:  CyChV5IIGsub Port map ( 	x => aa(i*4+3 downto i*4),
--											y => bb(i*4+3 downto i*4),
--										
--											pp => pp(i*4+3 downto i*4),
--																						
--											gg => gg(i*4+3 downto i*4),
--											sub => sub,
--											cin =>cyin(4*i),
--											cout =>cyin((i+1)*4 downto i*4+1) );
--           
--				
--	end generate;

	
-- obviamente que esto se puede hacer en 4 LUTs por dígito, con profundidad lógica de una LUTS	
--	GenAddRes: for i in 0 to NDigit-1 generate
--      s((i+1)*4-1 downto i*4) <= ss((i+1)*4-1 downto i*4) + (cyin(i+1) & cyin(i+1) & cyin(i));
--	end generate;

	
-- La LUTs correspondientes al peso 0 y peso uno se pueden implemetar en una LUT6:2	
-- se reduce el área
	GenAddRes: for i in 0 to NDigit-1 generate
      	
-- para la corrección del bit de peso 0 y 1

       s01_LUT6 : LUT6_2
				generic map (
					INIT => X"0000936c00005a5a")  
				port map (
					O6 => s(4*i+1),  
					O5 => s(4*i),
					I0 => ss(4*i),   
					I1 => ss(4*i+1),   
					I2 => cyin(i),   
					I3 => cyin(i+1),   
					I4 => '0',   
					I5 => '1'); 	


-- para la corrección del bit de peso 2			
			LUT6_s2 : LUT6
			generic map (
				INIT => X"e001c003007800f0") 
-- desde más significativo a menos significativo
			port map (
				O => s(i*4+2),
				I4 => cyin(i),
				I5 => cyin(i+1),
				I0 => ss(4*i),
				I1 => ss(4*i+1),
				I2 => ss(4*i+2),
				I3 => ss(4*i+3));		


-- para la corrección del bit de peso 3			
			LUT6_s3 : LUT6
			generic map (
				INIT => X"0006000401800300") 
-- desde más significativo a menos significativo
			port map (
				O => s(i*4+3),
				I4 => cyin(i),
				I5 => cyin(i+1),
				I0 => ss(4*i),
				I1 => ss(4*i+1),
				I2 => ss(4*i+2),
				I3 => ss(4*i+3));		

	end generate;


	cout <= cyin(NDigit); 
	
end Behavioral;

