-- Implementación punto fijo
-- Logaritmo decimal de números representados en decimal (BCD)

-- Basado en IMplementación IV de ln

-- La presición deseada es P, los números está, normalizados en 0.1x y 1
-- No es segmentado el camino de datos, termina es P pasos o ciclos de reloj

-- el resultado es de la forma 0.xxxx (P dígitos de precisión)... puede haber un 1.xxx

library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.STD_LOGIC_ARITH.ALL;
use IEEE.STD_LOGIC_UNSIGNED.ALL;
use work.my_package.all;

library UNISIM;
use UNISIM.VComponents.all;


entity Log_fixed is
		generic (TAdd: integer:= 2; TAddSub: integer:=2;P: integer:=7);
		port ( 
           clk, rst: in std_logic;
			  start: in std_logic;
			  x : in  std_logic_vector (4*P-1 downto 0);
			  done: out std_logic; 	
           s_log_o: out std_logic; -- signo del resultado
			  v_log_o : out std_logic_vector (4*P-1 downto 0)); -- valor del resultado
end Log_fixed;

architecture Behavioral of Log_fixed is
		
	
	

	component Mult_Nx1_vaz 
    Generic (TAdd: integer:= 2; NDigit :integer:=34);
    Port ( d: in  std_logic_vector (NDigit*4-1 downto 0);
	        y : in  std_logic_vector (3 downto 0);
			  p : out std_logic_vector((NDigit+1)*4-1 downto 0)); 
	end component;


	component addsub_BCD_L6 
   Generic (TAddSub: integer:= 1; NDigit : integer:=7);    
    Port ( 
	        a, b : in  STD_LOGIC_VECTOR (NDigit*4-1 downto 0);
           cin, sub : in  STD_LOGIC;
           cout : out  STD_LOGIC;
           s : out  STD_LOGIC_VECTOR (NDigit*4-1 downto 0));
	end component;
		

	component AS_SVA_CB_I 
		generic (TAddSub: integer:= 0; N : integer:=7);  
		port ( 
			  op, s_a, s_b : in  std_logic;
           a, b : in  std_logic_vector (4*N-1 downto 0);
           co, s_r: out std_logic;
           r : out std_logic_vector (4*N-1 downto 0));
	end component;
	
	component AS_SVA_IV 
	generic (TAddSub: integer:= 0; N : integer:=7);  
		port ( 
			  op, s_a, s_b : in  std_logic;
           a, b : in  std_logic_vector (4*N-1 downto 0);
           co, s_r: out std_logic;
           r : out std_logic_vector (4*N-1 downto 0));
	end component;
			
	component Lut_c 
    port ( d: in STD_LOGIC_VECTOR (3 downto 0);
			  c : out  STD_LOGIC_VECTOR (3 downto 0)); 
	end component;
	
	component Lut_log 
	generic (P: integer:=7);
    port ( step : in  STD_LOGIC_VECTOR (log2sup(P)-1 downto 0); 
           d : in  STD_LOGIC_VECTOR (3 downto 0);-- corresponde a xi
			  step_eq_0: in std_logic; -- indica si step es igual a 0
			  x_greater_1: in std_logic; -- infdica si x es mayor a uno
           log : out  STD_LOGIC_VECTOR (4*P downto 0)); -- en SVA, por eso un bit más
	end component;


	component Ctrl_sec_sh_I
	generic (P: integer:=2);
   Port ( clk, rst : in  std_logic;
           start : in  std_logic;
			  ctrl_x, ctrl_y: out std_logic;
			  done : out  std_logic;
			  step: out std_logic_vector(log2sup(P)-1 downto 0));
	end component;

	signal zeros, nines: std_logic_vector(4*P-1 downto 0);	
	signal op_bsh_i: std_logic_vector(4*P-1 downto 0);	
	
	signal oper_a_m: std_logic_vector(4*P-1 downto 0);	
	signal oper_b_m: std_logic_vector(3 downto 0); 
	signal r_mult: std_logic_vector(4*P+3 downto 0); 

	signal oper_a_add, oper_b_add: std_logic_vector(4*P-1 downto 0);
	
	signal co_add_sub: std_logic;
	signal r_add_sub: std_logic_vector(4*P-1 downto 0);
	
	signal step: std_logic_vector(log2sup(P)-1 downto 0);
	signal step_sh: std_logic_vector(log2sup(P)-1 downto 0);
	signal step_1, step_2: std_logic_vector(log2sup(P)-1 downto 0); -- corresponde a step-1 y step-2 respectivamente 
	

	signal c: std_logic_vector(3 downto 0); 
	signal log: std_logic_vector(4*P downto 0); -- en SVA
		
	signal d, cb: std_logic_vector(3 downto 0);
	
	signal res_x, reg_x, next_x : std_logic_vector(4*P-1 downto 0);
	signal oper_log, res_sub, reg_y, next_y: std_logic_vector(4*P+4 downto 0); 
	-- un bit más que representa el signo, resultado en SVA
	
	signal step_eq_0, step_eq_1: std_logic; 

	signal ctrl_x, ctrl_y: std_logic;
	
	signal ff_b_hi_x, next_ff_b_hi_x: std_logic; -- corresponde al bit más significativo de x que se encuentra 0culto
	

	
begin


	step_eq_0 <= '1' when (conv_integer(step)=0) else '0';
	step_eq_1 <= '1' when (conv_integer(step)=1) else '0';


	e_lut_ln: Lut_log
		generic map (P => P)
		port map ( step => step,
           d => d,
 			  step_eq_0 => step_eq_0,
			  x_greater_1 => ff_b_hi_x,
           log  => log);

	e_lut_c: Lut_c port map ( d => reg_x(4*P-1 downto 4*(P-1)),
									c => c); 
		
			
	d <= reg_x(4*P-1 downto 4*(P-1));

-- commplemento a 10 de d, usado cunado 
	cb <= "1001" when d="0001" else 
			"1000" when d="0010" else 
			"0111" when d="0011" else 
			"0110" when d="0100" else 
			"0101" when d="0101" else 
			"0100" when d="0110" else 
			"0011" when d="0111" else 
			"0010" when d="1000" else 
			"0001" when d="1001" else 
			"0001" when d="0000" else -- para que multipleque por uno, ya que luego desplaza multiplicando por 10
			"1111"; -- nunca es usado este



-- ==================
-- Para reaizar el barrel shift

	zeros <= (others => '0');
	
	cg_nines7: if P=7 generate   
		nines <= x"9999999";
   end generate;

	cg_nines16: if P=16 generate   
		nines <= x"9999999999999999";
   end generate;

	cg_nines34: if P=34 generate   
		nines <= x"9999999999999999999999999999999999";
   end generate;

	step_1 <= step - 1;
	step_2 <= step - 2;
	
	step_sh <= step when (step_eq_0='1') else 
				  step_2 when (ff_b_hi_x='0' and d=x"0") else 
				  step_1;
	
	op_bsh_i <= zeros when (ff_b_hi_x='1') else nines;

-- barrel shift 

	c_ldnine_7: if P=7 generate
			oper_a_m <= reg_x when (step_sh="0000") else
						 (op_bsh_i(3 downto 0)&reg_x(4*P-1 downto 4)) when (step_sh="001") else				 	
						 (op_bsh_i(7 downto 0)&reg_x(4*P-1 downto 8)) when (step_sh="010") else				 	
						 (op_bsh_i(11 downto 0)&reg_x(4*P-1 downto 12)) when (step_sh="011") else				 	

						 (op_bsh_i(15 downto 0)&reg_x(4*P-1 downto 16)) when (step_sh="100") else				 	
						 (op_bsh_i(19 downto 0)&reg_x(4*P-1 downto 20)) when (step_sh="101") else				 	
						 (op_bsh_i(23 downto 0)&reg_x(4*P-1 downto 24)) when (step_sh="110") else --- creo que nunca llega a este!				 	
						 (others => '0');
	end generate;

	c_ldnine_16: if P=16 generate
			oper_a_m <= reg_x when (step_sh="0000") else
						 (op_bsh_i(3 downto 0)&reg_x(4*P-1 downto 4)) when (step_sh="0001") else				 	
						 (op_bsh_i(7 downto 0)&reg_x(4*P-1 downto 8)) when (step_sh="0010") else				 	
						 (op_bsh_i(11 downto 0)&reg_x(4*P-1 downto 12)) when (step_sh="0011") else				 	

						 (op_bsh_i(15 downto 0)&reg_x(4*P-1 downto 16)) when (step_sh="0100") else				 	
						 (op_bsh_i(19 downto 0)&reg_x(4*P-1 downto 20)) when (step_sh="0101") else				 	
						 (op_bsh_i(23 downto 0)&reg_x(4*P-1 downto 24)) when (step_sh="0110") else				 	
						 (op_bsh_i(27 downto 0)&reg_x(4*P-1 downto 28)) when (step_sh="0111") else				 	
			
						 (op_bsh_i(31 downto 0)&reg_x(4*P-1 downto 32)) when (step_sh="1000") else				 	
						 (op_bsh_i(35 downto 0)&reg_x(4*P-1 downto 36)) when (step_sh="1001") else				 	
						 (op_bsh_i(39 downto 0)&reg_x(4*P-1 downto 40)) when (step_sh="1010") else				 	
						 (op_bsh_i(43 downto 0)&reg_x(4*P-1 downto 44)) when (step_sh="1011") else				 	

						 (op_bsh_i(47 downto 0)&reg_x(4*P-1 downto 48)) when (step_sh="1100") else				 	
						 (op_bsh_i(51 downto 0)&reg_x(4*P-1 downto 52)) when (step_sh="1101") else				 	
						 (op_bsh_i(55 downto 0)&reg_x(4*P-1 downto 56)) when (step_sh="1110") else				 	
						 (op_bsh_i(59 downto 0)&reg_x(4*P-1 downto 60)) when (step_sh="1111") else	 -- creo que nunca llega a este 			 	
						 (others => '0');
	end generate;			 
	

	c_ldnine_34: if P=34 generate
			oper_a_m <= reg_x when (step_sh="000000") else
						 (op_bsh_i(3 downto 0)&reg_x(4*P-1 downto 4)) when (step_sh="000001") else				 	
						 (op_bsh_i(7 downto 0)&reg_x(4*P-1 downto 8)) when (step_sh="000010") else				 	
						 (op_bsh_i(11 downto 0)&reg_x(4*P-1 downto 12)) when (step_sh="000011") else				 	

						 (op_bsh_i(15 downto 0)&reg_x(4*P-1 downto 16)) when (step_sh="000100") else				 	
						 (op_bsh_i(19 downto 0)&reg_x(4*P-1 downto 20)) when (step_sh="000101") else				 	
						 (op_bsh_i(23 downto 0)&reg_x(4*P-1 downto 24)) when (step_sh="000110") else				 	
						 (op_bsh_i(27 downto 0)&reg_x(4*P-1 downto 28)) when (step_sh="000111") else				 	
			
						 (op_bsh_i(31 downto 0)&reg_x(4*P-1 downto 32)) when (step_sh="001000") else				 	
						 (op_bsh_i(35 downto 0)&reg_x(4*P-1 downto 36)) when (step_sh="001001") else				 	
						 (op_bsh_i(39 downto 0)&reg_x(4*P-1 downto 40)) when (step_sh="001010") else				 	
						 (op_bsh_i(43 downto 0)&reg_x(4*P-1 downto 44)) when (step_sh="001011") else				 	

						 (op_bsh_i(47 downto 0)&reg_x(4*P-1 downto 48)) when (step_sh="001100") else				 	
						 (op_bsh_i(51 downto 0)&reg_x(4*P-1 downto 52)) when (step_sh="001101") else				 	
						 (op_bsh_i(55 downto 0)&reg_x(4*P-1 downto 56)) when (step_sh="001110") else				 	
						 (op_bsh_i(59 downto 0)&reg_x(4*P-1 downto 60)) when (step_sh="001111") else	 

							(op_bsh_i(63 downto 0)&reg_x(4*P-1 downto 64)) when (step_sh="010000") else	 
							(op_bsh_i(67 downto 0)&reg_x(4*P-1 downto 68)) when (step_sh="010001") else	 						 
							(op_bsh_i(71 downto 0)&reg_x(4*P-1 downto 72)) when (step_sh="010010") else	 
							(op_bsh_i(75 downto 0)&reg_x(4*P-1 downto 76)) when (step_sh="010011") else	 						 
							(op_bsh_i(79 downto 0)&reg_x(4*P-1 downto 80)) when (step_sh="010100") else	 
							(op_bsh_i(83 downto 0)&reg_x(4*P-1 downto 84)) when (step_sh="010101") else	 						 
							(op_bsh_i(87 downto 0)&reg_x(4*P-1 downto 88)) when (step_sh="010110") else	 
							(op_bsh_i(91 downto 0)&reg_x(4*P-1 downto 92)) when (step_sh="010111") else	 						
							(op_bsh_i(95 downto 0)&reg_x(4*P-1 downto 96)) when (step_sh="011000") else	 
							(op_bsh_i(99 downto 0)&reg_x(4*P-1 downto 100)) when (step_sh="011001") else	 						 
							(op_bsh_i(103 downto 0)&reg_x(4*P-1 downto 104)) when (step_sh="011010") else	 
							(op_bsh_i(107 downto 0)&reg_x(4*P-1 downto 108)) when (step_sh="011011") else	 						
							(op_bsh_i(111 downto 0)&reg_x(4*P-1 downto 112)) when (step_sh="011100") else	 
							(op_bsh_i(115 downto 0)&reg_x(4*P-1 downto 116)) when (step_sh="011101") else	 						 
							(op_bsh_i(119 downto 0)&reg_x(4*P-1 downto 120)) when (step_sh="011110") else	 
							(op_bsh_i(123 downto 0)&reg_x(4*P-1 downto 124)) when (step_sh="011111") else	 						
							(op_bsh_i(127 downto 0)&reg_x(4*P-1 downto 128)) when (step_sh="100000") else	 
							(op_bsh_i(131 downto 0)&reg_x(4*P-1 downto 132)) when (step_sh="100001") else	-- Nunca llega a este 						 
						 (others => '0');
	end generate;	
				 
-- ====================
	

	oper_b_m <= c when (step_eq_0='1') else 
					d when (ff_b_hi_x='1') else cb;					

	

	eMult: Mult_Nx1_vaz Generic map (TAdd => TAdd, NDigit => P)
								 Port map ( d => oper_a_m, y => oper_b_m, p => r_mult);
			  
			  

	oper_a_add <= (reg_x(4*P-5 downto 0)&"0000") when (step_eq_0 <= '0') else reg_x;
	oper_b_add <= r_mult(4*P-1 downto 0); 
	
	x_add_sub: addsub_BCD_L6  generic map(TAddSub => TAddSub, NDigit => P)
									port map (a => oper_a_add, b => oper_b_add, 
									cin => '0' , sub => ff_b_hi_x, cout => co_add_sub, s => r_add_sub);
						
-- cuando realiza la resta A-B, si pide uno, es decir B es mayor a A, entonce resultado es menor a 1 -> 0,9s, 
--   sino pide uno, el resultado es mayor a 1 -> 1.0's
--  Cuando realizo A+c9(B)+1, con A>0 y B>0, tiene acarreo si A es mayor a B. 

-- cuando realiza la suma A+B, si hay acarreo, entonce resultado es mayor a 1 -> 1,0s, si no hay acarreo el resultado es menor a 1 -> 0.9's
						
  					
   oper_log(4*P+4) <= log(4*P);
	oper_log(4*P+3 downto 0) <= (x"0"&log(4*P-1 downto 0));
					
	
	e_sub_y: AS_SVA_CB_I 

	--e_sub_y: AS_SVA_IV
		--generic map(TAddSub => 0, N => P+1)  
generic map(TAddSub => 2, N => P+1) -- no esta en el critico. por eso opcion de Vaz para que consuma menos area
		port map (op => '1', s_a => reg_y(4*P+4), a => reg_y(4*P+3 downto 0),
					  s_b => oper_log(4*P+4), b => oper_log(4*P+3 downto 0), co => open,
					 s_r => res_sub(4*P+4), r => res_sub(4*P+3 downto 0));
		

	
	
	uctrl: Ctrl_sec_sh_I generic map (P => P)
						port map (clk => clk, rst => rst, start => start, 
									ctrl_x => ctrl_x, ctrl_y => ctrl_y,
									done => done, step => step);									



	next_ff_b_hi_x <= '0' when ctrl_x = '1' else
							(co_add_sub or r_mult(4*P)) when (step_eq_0 = '1' ) else
	  	(co_add_sub and  (not r_mult(4*P))) when (step_eq_1 = '1' and  ff_b_hi_x = '1') else
--En este caso,  es >1 cuanto hay acarreo en la suma (A+c9(B)+1) y no se produjo acarreo en la multiplicación,
							co_add_sub; 


	next_x <=	x when ctrl_x = '1' else 
					r_add_sub(4*P-1 downto 0);
					
	next_y <=	(others=> '0') when ctrl_y = '1' else 
					res_sub; 
	
	
	PRegs: process (clk, rst)
	begin
		if rst = '1' then
			reg_x <= (others=>'0');
			reg_y <= (others=>'0');
			ff_b_hi_x <= '0';
		elsif rising_edge(clk) then
			reg_x <= next_x;
			reg_y <= next_y;
			ff_b_hi_x <= next_ff_b_hi_x;
		end if;
	end process;

	s_log_o <= reg_y(4*P+4); 	
	v_log_o <= reg_y(4*P+3 downto 4) when (reg_y(4*P)='1') else reg_y(4*P-1 downto 0); -- esto es para caso especial qeu log 0.1 = 1 



end Behavioral;


