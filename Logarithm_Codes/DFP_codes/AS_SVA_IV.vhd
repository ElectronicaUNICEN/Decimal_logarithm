-- Implementación IV - Es la version AS_SVA_Mx del reporte

-- Usa el sumdor y el restador de números naturales con signo
-- Realiza la suma y la resta en paralelo y luego elige mediante multiplexor cual es el necesario

-- Para el sumador utiliza uno configurable 
-- TAdd = 0 => p y g a partir de la suma inicial
-- TAdd = 1 => p y g a partir de las entradas
-- TAdd = 2 => basado en Vazquez

-- para el resador, se trae todo el codigo debido a que la etapa de corrección se la fusiona con el mux que elige entre suma o resta

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

entity AS_SVA_IV is
		generic (TAdd: integer:= 2; N : integer:=7);    
		port ( 
			  op : in  std_logic;
			  s_a : in  std_logic;
           a : in  std_logic_vector (4*N-1 downto 0);
			  s_b : in  std_logic;
           b : in  std_logic_vector (4*N-1 downto 0);
           co: out std_logic; -- co está asociado al overflow
			  s_r : out std_logic;
           r : out std_logic_vector (4*N-1 downto 0));
end AS_SVA_IV;

architecture Behavioral of AS_SVA_IV is
	
	
   component adder_BCD_L6 
   Generic (TAdd: integer:= 1; NDigit : integer:=7);    
    Port ( 
	        a, b : in  STD_LOGIC_VECTOR (NDigit*4-1 downto 0);
           cin : in  STD_LOGIC;
           cout : out  STD_LOGIC;
           s : out  STD_LOGIC_VECTOR (NDigit*4-1 downto 0));
	end component;



	signal ope: std_logic; -- es la operación efectiva
	
	signal s_add: std_logic_vector (4*N-1 downto 0);
	signal s_co:std_logic;

signal re: std_logic_vector (4*N-1 downto 0);
	
	-- señales involucradas en resta con signo
	signal ab, p, pp, kp, kg: std_logic_vector(4*N-1 downto 0);
	signal ci, cci: std_logic_vector(4*N downto 0);
	
	

	
begin

   ope <= s_a xor s_b xor op;
	
	--s_r <= (s_a and (not ope)) or ((s_a xor ci(4*N))  and ope);
	s_r <= s_a xor (ci(4*N)and ope);
	
	co <= s_co and (not ope);
	
	-- =========================
	-- Instanciación de suma
	add: adder_BCD_L6 
		Generic map (TAdd => TAdd,
					NDigit => N)    
		Port map(a => a, b => b, cin => '0', cout => s_co, s => s_add); 
   -- =========================        


           
	-- =========================
	-- Desarrollo de resta con signo, sin la corrección

	ci(0) <= '0';
	cci(0) <= '0';
	
	genSub: for I in 0 to N-1 generate
			
-- ========== Primera etapa		
-- corresponde a primer restador binario
		ab(4*(I+1)-1 downto 4*I) <= not (a(4*(I+1)-1 downto 4*I)xor b(4*(I+1)-1 downto 4*I));
  		
		Xor_1: XORCY port map (O => p(4*I), CI => ci(4*I), LI => ab(4*I));
		Mxcy_1: MUXCY port map (DI => b(4*i),CI => ci(4*i),S => ab(4*i),O => ci(4*i+1));	

		Xor_2: XORCY port map (O => p(4*I+1), CI => ci(4*I+1), LI => ab(4*I+1));
		Mxcy_2: MUXCY port map (DI => b(4*i+1),CI => ci(4*i+1),S => ab(4*i+1),O => ci(4*i+2));	
		
		Xor_3: XORCY port map (O => p(4*I+2), CI => ci(4*I+2), LI => ab(4*I+2));
		Mxcy_3: MUXCY port map (DI => b(4*i+2),CI => ci(4*i+2),S => ab(4*i+2),O => ci(4*i+3));	

		Xor_4: XORCY port map (O => p(4*I+3), CI => ci(4*I+3), LI => ab(4*I+3));
		Mxcy_4: MUXCY port map (DI => b(4*i+3),CI => ci(4*i+3),S => ab(4*i+3),O => ci(4*(i+1)));	
-- ========== FIN Primera etapa

-- ========== Segunda etapa
-- corresponde a segundo restador binario, fusionado con la corrección del primer restador
      pg3_LUT6 : LUT6_2
				generic map (
					INIT => X"01080000fef7fef7")  
				port map (
					O6 => kg(4*i+3),  
					O5 => kp(4*i+3),
					I0 => p(4*i+1),   
					I1 => p(4*i+2),   
					I2 => p(4*i+3),   
					I3 => ci(4*(i+1)),   
					I4 => ci(4*N),   
					I5 => '1');  		

      pg2_LUT6 : LUT6_2
   			generic map (
					INIT => X"0000630000009c9c")  
				port map (
					O6 => kg(4*i+2),  
					O5 => kp(4*i+2),
					I0 => p(4*i+1),   
					I1 => p(4*i+2),   
					I2 => ci(4*(i+1)),   
					I3 => ci(4*N),
					I4 => '0',					
					I5 => '1');  		

      pg1_LUT6 : LUT6_2
				generic map (
					INIT => X"0000009000000066")
				port map (
					O6 => kg(4*i+1),  
					O5 => kp(4*i+1),
					I0 => p(4*i+1),   
					I1 => ci(4*(i+1)),     
					I2 => ci(4*N),
					I3 => '0',
					I4 => '0',					
					I5 => '1');  		

      pg0_LUT6 : LUT6_2
				generic map (
					INIT => X"00000050000000aa")
				port map (
					O6 => kg(4*i),  
					O5 => kp(4*i),
					I0 => p(4*i),   
					I1 => ci(4*(i+1)),     
					I2 => ci(4*N),
					I3 => '0',
					I4 => '0',					
					I5 => '1');  		

 	  Xor_1b: XORCY port map (O => pp(4*I), CI => cci(4*I), LI => kp(4*I));
	  Mxcy_1b: MUXCY port map (DI => kg(4*i),CI => cci(4*i),S => kp(4*i),O => cci(4*i+1));	

	  Xor_2b: XORCY port map (O => pp(4*i+1), CI => cci(4*I+1), LI => kp(4*I+1));
	  Mxcy_2b: MUXCY port map (DI => kg(4*i+1),CI => cci(4*i+1),S => kp(4*i+1),O => cci(4*i+2));	

	  Xor_3b: XORCY port map (O => pp(4*i+2), CI => cci(4*I+2), LI => kp(4*I+2));
	  Mxcy_3b: MUXCY port map (DI => kg(4*i+2),CI => cci(4*i+2),S => kp(4*i+2),O => cci(4*i+3));	
		
	  Xor_4b: XORCY port map (O => pp(4*i+3), CI => cci(4*I+3), LI => kp(4*I+3));
	  Mxcy_4b: MUXCY port map (DI => kg(4*i+3),CI => cci(4*i+3),S => kp(4*i+3),O => cci(4*(i+1)));	
-- ==========FIN de segunda etapa
	
	end generate;

-- ==========================================
-- Multiplexor que escoge entre salida de suma y resta de acuerdo a la operación efectiva ope. El resultado de resta como entrada, no es el resultado real, sino es pp el cual no posee la corrección
-- estos multiplexores si la operación efectiva es suma toma <s_add>, pero si la operación efectiva es resta debe corregir pp

	GmuxCor: for I in 0 to N-1 generate
     
	  
---  re(4*I) <=	not pp(4*I); 
--	  re(4*I+1) <= not (pp(4*I+1) xor cci(4*(I+1)));
--	  re(4*I+2) <=	(pp(4*I+2) xor pp(4*I+1)) when (cci(4*(I+1))='1') else (not pp(4*I+2)); 
--	  re(4*I+3) <=	(not (pp(4*I+3) or pp(4*I+2) or pp(4*I+1))) when (cci(4*(I+1))='1') else (not pp(4*I+3));
--   r <= s_add(4*I+1 downto 4*I) when ope='0' else re(4*I+3 downto 4*I);
	  
		rc0_LUT6 : LUT6
				generic map (
					INIT => X"000000000000005c") 
				port map (
					O => r(4*i),  
					
					I0 => pp(4*i),   
					I1 => s_add(4*i),   
					I2 => ope,   
					I3 => '0',   
					I4 => '0',   
					I5 => '0');
		
		rc1_LUT6 : LUT6
				generic map (
					INIT => X"00000000000099f0") 
				port map (
					O => r(4*i+1),  
					I0 => pp(4*i+1),   
					I1 => cci(4*(i+1)),   
					I2 => s_add(4*i+1),   
					I3 => ope,   
					I4 => '0',   
					I5 => '0');
	
				 
	
			rc2_LUT6 : LUT6
				generic map (
					INIT => X"000000006363ff00") 
				port map (
					O => r(4*i+2),  
					I0 => pp(4*i+1),   
					I1 => pp(4*i+2),   
					I2 => cci(4*(i+1)),   
					I3 => s_add(4*i+2),   
					I4 => ope,
					I5 => '0');
		
			rc3_LUT6 : LUT6
				generic map (
					INIT => X"010f010fffff0000") 
				port map (
					O => r(4*i+3),  
					I0 => pp(4*i+1),   
					I1 => pp(4*i+2),   
					I2 => pp(4*i+3),   
					I3 => cci(4*(i+1)),   
					I4 => s_add(4*i+3),   
					I5 => ope);



	end generate;


	

end Behavioral;


