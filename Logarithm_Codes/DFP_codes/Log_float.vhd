

-- Para decimal32, P=7 y Ne=8 y bias=101 
-- Para decimal64, P=16 y Ne=10 y bias=398 
-- Para decimal128, P=34 y Ne=14 y bias=6176 


library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.STD_LOGIC_ARITH.ALL;
use IEEE.STD_LOGIC_UNSIGNED.ALL;
use work.my_package.all;

library UNISIM;
use UNISIM.VComponents.all;


entity Log_float is
		generic (TAdd: integer:=2; TAddSub: integer:= 2;P: integer:=7; Ne: integer :=8);
--		generic (TAdd: integer:= 2; TAddSub: integer:= 2;P: integer:=16; Ne: integer :=10);
--		generic (TAdd: integer:= 2; TAddSub: integer:= 2;P: integer:=34; Ne: integer :=14);
		port ( 
           clk, rst: in std_logic;
			  start: in std_logic;

			  x : in  std_logic_vector (4*P-1 downto 0);
			  e : in std_logic_vector (Ne-1 downto 0);
			  
			  done: out std_logic; 
			  
           exp_log_o : out std_logic_vector (Ne-1 downto 0);
			  s_log_o: out std_logic; -- signo del resultado
			  v_log_o : out std_logic_vector (4*P-1 downto 0)); -- valor del resultado
end Log_float;

architecture Behavioral of Log_float is
	
	component BinToBCD_K 
	generic (N: integer:= 8; K: integer:= 3);
    Port ( clk, rst: std_logic;
		   start: in std_logic; 
			en_converter: std_logic;
			a : in  STD_LOGIC_VECTOR (N-1 downto 0);
         s : out  STD_LOGIC_VECTOR (4*K-1 downto 0));
	end component;
	
	
	component adder_BCD_L6 
   Generic (TAdd: integer:= 1; NDigit : integer:=7);    
    Port ( 
	        a, b : in  STD_LOGIC_VECTOR (NDigit*4-1 downto 0);
           cin : in  STD_LOGIC;
           cout : out  STD_LOGIC;
           s : out  STD_LOGIC_VECTOR (NDigit*4-1 downto 0));
	end component;

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


	component LeadingNines 
			generic (P: integer:=16);
			Port ( a : in  STD_LOGIC_VECTOR (4*P-1 downto 0);
					c : out  STD_LOGIC_VECTOR (log2sup(P+1)-1 downto 0));
	end component;
	
	component LeadingZeros 
		generic (P: integer:=16);
		Port ( a : in  STD_LOGIC_VECTOR (4*P-1 downto 0);
			 c : out  STD_LOGIC_VECTOR (log2sup(P+1)-1 downto 0));
	end component;
	
	component Lut2_c 
    port ( d: in STD_LOGIC_VECTOR (3 downto 0);
			  c : out  STD_LOGIC_VECTOR (3 downto 0)); 
	end component;
	
	component Lutb_log_pf7_bopt 
	generic (P: integer:=7);
    port ( 
  			step : in std_logic_vector(log2sup(P+2)-1 downto 0);
			offset_step : in std_logic_vector(log2sup(P+1)-1 downto 0);
			true_step: in std_logic_vector(log2sup(2*P+1)-1 downto 0);
          d : in  STD_LOGIC_VECTOR (3 downto 0);-- corresponde a xi
		  x_greater_1: in std_logic; -- infdica si x es mayor a uno
          log : out  STD_LOGIC_VECTOR (4*P+8 downto 0)); -- en SVA, por eso un bit más
	end component;


	component Lutb_log_pf16_bopt 
	generic (P: integer:=7);
    port (
  			step : in std_logic_vector(log2sup(P+2)-1 downto 0);
			offset_step : in std_logic_vector(log2sup(P+1)-1 downto 0);
			true_step: in std_logic_vector(log2sup(2*P+1)-1 downto 0);
          d : in  STD_LOGIC_VECTOR (3 downto 0);-- corresponde a xi
		  x_greater_1: in std_logic; -- infdica si x es mayor a uno
          log : out  STD_LOGIC_VECTOR (4*P+8 downto 0)); -- en SVA, por eso un bit más
	end component;


	component Lutb_log_pf34_bopt 
	generic (P: integer:=7);
    port ( 
  			step : in std_logic_vector(log2sup(P+2)-1 downto 0);
			offset_step : in std_logic_vector(log2sup(P+1)-1 downto 0);
			true_step: in std_logic_vector(log2sup(2*P+1)-1 downto 0);
          d : in  STD_LOGIC_VECTOR (3 downto 0);-- corresponde a xi
		  x_greater_1: in std_logic; -- infdica si x es mayor a uno
          log : out  STD_LOGIC_VECTOR (4*P+8 downto 0)); -- en SVA, por eso un bit más
	end component;

	
	component Lutb_log_pf7_ini 
	generic (P: integer:=7);
    port ( 
      d : in  STD_LOGIC_VECTOR (3 downto 0);-- corresponde a xi
      log : out  STD_LOGIC_VECTOR (4*P+8 downto 0)); -- en SVA, por eso un bit más
	end component;
	
	component Lutb_log_pf16_ini 
	generic (P: integer:=16);
    port ( 
      d : in  STD_LOGIC_VECTOR (3 downto 0);-- corresponde a xi
      log : out  STD_LOGIC_VECTOR (4*P+8 downto 0)); -- en SVA, por eso un bit más
	end component;

	component Lutb_log_pf34_ini 
	generic (P: integer:=34);
    port ( 
      d : in  STD_LOGIC_VECTOR (3 downto 0);-- corresponde a xi
      log : out  STD_LOGIC_VECTOR (4*P+8 downto 0)); -- en SVA, por eso un bit más
	end component;



	component Ctrlb_log_float
		generic (P: integer:=7; Ne: integer:=8);
		Port ( clk, rst : in  std_logic;
				  start : in  std_logic;
				  ctrl_x, en_x, ctrl_y, en_y, ctrl_x2, en_x2, ctrl_x_gr_one, en_x_gr_one, en_ini, en_rlog, en_exp: out std_logic;
				  done : out  std_logic;
				  step: out std_logic_vector(log2sup(P+2)-1 downto 0));
	end component;
	
	
	
	component C9_Chen 
    Port ( a : in  STD_LOGIC_VECTOR (3 downto 0);
           b : out  STD_LOGIC_VECTOR (3 downto 0));
	end component;
	
	constant Ke:integer:= 3; -- Para P=7 o 16 es de Ke=3, para P=34 Ke=4

   signal cnt_zeros: std_logic_vector(log2sup(P+1)-1 downto 0); -- la cantidad de 0's iniciales que puede haber en x
	signal x_ld_zeros: std_logic_vector(4*P-1 downto 0); -- corresponde al valor de x sin los 0's iniciales
	signal sh_exp: std_logic_vector(Ne-1 downto 0); -- es el valor que debo sumarle al exponente por normalización	
	signal e_true_cd, e_true_cb, v_exp_sva: std_logic_vector(Ne-1 downto 0); -- para trataiento de exponente
	signal s_exp_sva: std_logic;-- signo del exponente uego de la normalización 
	
	signal ff_s_exp: std_logic; 
	signal exp_sva_bcd: std_logic_vector(4*Ke-1 downto 0);-- operando que se le debe sumar al resultado final, tiene que ver con el tratamiento del exponente
	
	
	signal cnt_nines: std_logic_vector(log2sup(P+1)-1 downto 0); -- la cantidad de 9's iniciales que puede haber en x
	signal there_nines:  std_logic; -- para saber sdi existen 9's iniciales
	
	signal zeros, nines: std_logic_vector(4*P-1 downto 0);	
	signal op_bsh_i: std_logic_vector(4*P-1 downto 0);	
	
	signal oper_a_m: std_logic_vector(4*P-1 downto 0);	
	signal oper_b_m: std_logic_vector(3 downto 0); 
	signal r_mult, r_mult_ini: std_logic_vector(4*P+3 downto 0); 

	signal oper_a_add, oper_b_add : std_logic_vector(4*P-1 downto 0);
	

	signal co_add_sub: std_logic;
	signal r_add_sub: std_logic_vector(4*P-1 downto 0);
	
	signal step: std_logic_vector(log2sup(P+2)-1 downto 0);
	
	signal true_step, true_step_1, true_step_2 : std_logic_vector(log2sup(2*P+1)-1 downto 0); -- para acceso a LUT	
	signal true_step_sh:std_logic_vector(log2sup(2*P+1)-1 downto 0);-- para desplazar operando antres de multiplicar. solo en esta alternativa de opción V

	signal ff_there_nines, next_there_nines: std_logic;
	signal reg_offset_step, next_offset_step : std_logic_vector(log2sup(P+1)-1 downto 0);	

	signal c: std_logic_vector(3 downto 0); 
	signal log, log_ini: std_logic_vector(4*P+8 downto 0);  

			
	signal d, cb: std_logic_vector(3 downto 0);
		
	signal res_x, reg_x, next_x : std_logic_vector(4*P-1 downto 0);
	signal reg_x2, next_x2 : std_logic_vector(4*P-1 downto 0);
	signal x_ld_nines: std_logic_vector(4*P-1 downto 0); -- corresponde a x sin los nueves iniciales
	
	signal oper_log_ini, oper_log, res_sub, reg_y, next_y: std_logic_vector(4*P+12 downto 0); 
	-- un bit más que representa el signo, resultado en SVA
	
	signal step_eq_0, step_eq_1: std_logic; 

	-- señales de control
	signal ctrl_x, en_x, ctrl_y, en_y, ctrl_x2, en_x2, ctrl_x_gr_one, en_x_gr_one, en_ini, en_rlog, en_exp:  std_logic;
	
	signal ff_x_gr_one, next_x_gr_one: std_logic; -- corresponde a si el valor de x es mayor a uno
	
	signal reg_rlog, next_rlog: std_logic_vector(4*P-1 downto 0);
	signal reg_explog, next_explog: std_logic_vector(Ne-1 downto 0); -- lo hago de 7 bits para esta versión
	signal ff_slog, next_slog: std_logic;
	
	
	signal exp_eq_0: std_logic;	
	signal expadd, explog0, explog_t2, explog_t, explog1: std_logic_vector(Ne-1 downto 0);


	signal oper0_frac, oper_frac, sh_reg_y, n_sh_reg_y: std_logic_vector(4*P+7 downto 0);
	
	signal oper_int, oper_res, oper_one: std_logic_vector(4*Ke-1 downto 0);
	signal s_log, operation: std_logic;
	signal log_ext: std_logic_vector (4*(P+Ke+2)-1 downto 0);


	signal ze: std_logic_vector(2 downto 0); -- ceros iniciales que puede haber en el resultado Qs.p+2
	signal log2_ext: std_logic_vector (4*(P+Ke+2)-1 downto 0);
	signal s1_corr, s2_corr: std_logic;
	signal s_addRound, s0_addRound, s1_addRound: std_logic;
	signal res_corr: std_logic_vector(4*(Ke+2)-1 downto 0); 
	
	signal r_log: std_logic_vector (4*P-1 downto 0); 
	
	signal exp_log : std_logic_vector(Ne-1 downto 0);		
			
		
begin





-- ============================
-- Unidad de Control
	uctrl: Ctrlb_log_float generic map (P => P, Ne => Ne)
						port map (clk => clk, rst => rst, start => start, 
									ctrl_x => ctrl_x, en_x => en_x, en_y => en_y, ctrl_y => ctrl_y, en_ini => en_ini,
									ctrl_x2 => ctrl_x2, ctrl_x_gr_one => ctrl_x_gr_one, en_x2 => en_x2, en_exp => en_exp,
									en_x_gr_one => en_x_gr_one, en_rlog=> en_rlog,
									done => done, step => step);								
-- ============================


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


-- ============================ COMIENZO paso Inicial

	-- =========
	-- ==== Inicio de Normalización de operando de entrada

	eglz: LeadingZeros generic map (P => P)
			Port map ( a => reg_x, c => cnt_zeros);	
	
	-- Para P=7
	cg_ldzeros7_ini: if P=7 generate
						x_ld_zeros <= reg_x when (cnt_zeros="000") else 
										 (reg_x(4*P-5 downto 0)&x"0") when (cnt_zeros="001") else 
										 (reg_x(4*P-9 downto 0)&x"00") when (cnt_zeros="010") else 
										 (reg_x(4*P-13 downto 0)&x"000") when (cnt_zeros="011") else 
										 (reg_x(4*P-17 downto 0)&x"0000") when (cnt_zeros="100") else 
										 (reg_x(4*P-21 downto 0)&x"00000") when (cnt_zeros="101") else 
										 (reg_x(4*P-25 downto 0)&x"000000") when (cnt_zeros="110") else 
										 (others => '0'); 
										 
					   sh_exp <= "00000111" - ("00000"&cnt_zeros); -- P - #ceros_iniciales										 
	end generate;
	
-- Para P=16
	cg_ldzeros16_ini: if P=16 generate
						x_ld_zeros <= reg_x when (cnt_zeros=x"00000") else 
										 (reg_x(4*P-5 downto 0)&x"0") when (cnt_zeros="00001") else 
										 (reg_x(4*P-9 downto 0)&x"00") when (cnt_zeros="00010") else 
										 (reg_x(4*P-13 downto 0)&x"000") when (cnt_zeros="00011") else 
										 (reg_x(4*P-17 downto 0)&x"0000") when (cnt_zeros="00100") else 
										 (reg_x(4*P-21 downto 0)&x"00000") when (cnt_zeros="00101") else 
										 (reg_x(4*P-25 downto 0)&x"000000") when (cnt_zeros="00110") else 
										 (reg_x(4*P-29 downto 0)&x"0000000") when (cnt_zeros="00111") else 
										 (reg_x(4*P-33 downto 0)&x"00000000") when (cnt_zeros="01000") else 
										 (reg_x(4*P-37 downto 0)&x"000000000") when (cnt_zeros="01001") else 
										 (reg_x(4*P-41 downto 0)&x"0000000000") when (cnt_zeros="01010") else 
										 (reg_x(4*P-45 downto 0)&x"00000000000") when (cnt_zeros="01011") else 
										 (reg_x(4*P-49 downto 0)&x"000000000000") when (cnt_zeros="01100") else 
										 (reg_x(4*P-53 downto 0)&x"0000000000000") when (cnt_zeros="01101") else 
										 (reg_x(4*P-57 downto 0)&x"00000000000000") when (cnt_zeros="01110") else 
										 (reg_x(4*P-61 downto 0)&x"000000000000000") when (cnt_zeros="01111") else 					 
										 (others => '0'); 
										 
						sh_exp <= "0000010000" - ("00000"&cnt_zeros); -- P - #ceros_iniciales										 										 
	end generate;
	
	-- Para P=34	
	cg_ldzeros34_ini: if P=34 generate
						x_ld_zeros <= reg_x when (cnt_zeros=x"000000") else 
										 (reg_x(4*P-5 downto 0)&x"0") when (cnt_zeros="000001") else 
										 (reg_x(4*P-9 downto 0)&x"00") when (cnt_zeros="000010") else 
										 (reg_x(4*P-13 downto 0)&x"000") when (cnt_zeros="000011") else 
										 (reg_x(4*P-17 downto 0)&x"0000") when (cnt_zeros="000100") else 
										 (reg_x(4*P-21 downto 0)&x"00000") when (cnt_zeros="000101") else 
										 (reg_x(4*P-25 downto 0)&x"000000") when (cnt_zeros="000110") else 
										 (reg_x(4*P-29 downto 0)&x"0000000") when (cnt_zeros="000111") else 
										 (reg_x(4*P-33 downto 0)&x"00000000") when (cnt_zeros="001000") else 
										 (reg_x(4*P-37 downto 0)&x"000000000") when (cnt_zeros="001001") else 
										 (reg_x(4*P-41 downto 0)&x"0000000000") when (cnt_zeros="001010") else 
										 (reg_x(4*P-45 downto 0)&x"00000000000") when (cnt_zeros="001011") else 
										 (reg_x(4*P-49 downto 0)&x"000000000000") when (cnt_zeros="001100") else 
										 (reg_x(4*P-53 downto 0)&x"0000000000000") when (cnt_zeros="001101") else 
										 (reg_x(4*P-57 downto 0)&x"00000000000000") when (cnt_zeros="001110") else 
										 (reg_x(4*P-61 downto 0)&x"000000000000000") when (cnt_zeros="001111") else 					 
										(reg_x(4*P-65 downto 0)&x"0000000000000000") when (cnt_zeros="010000") else 					 
										(reg_x(4*P-69 downto 0)&x"00000000000000000") when (cnt_zeros="010001") else 					 										 
										(reg_x(4*P-73 downto 0)&x"000000000000000000") when (cnt_zeros="010010") else 					 
										(reg_x(4*P-77 downto 0)&x"0000000000000000000") when (cnt_zeros="010011") else 					 										 
										(reg_x(4*P-81 downto 0)&x"00000000000000000000") when (cnt_zeros="010100") else 					 										 
										(reg_x(4*P-85 downto 0)&x"000000000000000000000") when (cnt_zeros="010101") else 					 										 
										(reg_x(4*P-89 downto 0)&x"0000000000000000000000") when (cnt_zeros="010110") else 					 										 
										(reg_x(4*P-93 downto 0)&x"00000000000000000000000") when (cnt_zeros="010111") else 					 										 
										(reg_x(4*P-97 downto 0)&x"000000000000000000000000") when (cnt_zeros="011000") else 					 										 
										(reg_x(4*P-101 downto 0)&x"0000000000000000000000000") when (cnt_zeros="011001") else 					 										 
										(reg_x(4*P-105 downto 0)&x"00000000000000000000000000") when (cnt_zeros="011010") else 					 										 
										(reg_x(4*P-109 downto 0)&x"000000000000000000000000000") when (cnt_zeros="011011") else 					 										 
										(reg_x(4*P-113 downto 0)&x"0000000000000000000000000000") when (cnt_zeros="011100") else 					 										 
										(reg_x(4*P-117 downto 0)&x"00000000000000000000000000000") when (cnt_zeros="011101") else 					 										 
										(reg_x(4*P-121 downto 0)&x"000000000000000000000000000000") when (cnt_zeros="011110") else 					 										 
										(reg_x(4*P-125 downto 0)&x"0000000000000000000000000000000") when (cnt_zeros="011111") else 					 										 
										(reg_x(4*P-129 downto 0)&x"00000000000000000000000000000000") when (cnt_zeros="100000") else 					 										 
										(reg_x(4*P-133 downto 0)&x"000000000000000000000000000000000") when (cnt_zeros="100001") else 					 										 
										 (others => '0'); 
							
							sh_exp <= "00000000100010" - ("00000000"&cnt_zeros); -- P - #ceros_iniciales										 										 
	end generate;
	-- ==== Fin normalización del operando de entrada
	-- ========
	

	-- =========
	-- ==== Inicio de Tratamiento de exponente
	
	cg_doexp_7: if P=7 generate -- puede ser Ne=8
		e_true_cd <= e + sh_exp; -- exponmente de entrada mas ajuste por normalización, en cero desplazado
		e_true_cb <=e_true_cd + x"9b"; -- exponente + CB(bias), exponente + CB(101)
	
		s_exp_sva <= e_true_cb(Ne-1); -- signo del exponente representado en SVA
		v_exp_sva <= ((not e_true_cb)+ x"01") when s_exp_sva='1' else e_true_cb;-- valor del exponente representado en SVA
	
	end generate;
	

	cg_doexp_16: if P=16 generate -- puede ser Ne=10
		e_true_cd <= e + sh_exp; -- exponmente de entrada mas ajuste por normalización, en cero desplazado
		e_true_cb <=e_true_cd + "1001110010";--x"272"; -- exponente + CB(bias), exponente + CB(398)
	
		s_exp_sva <= e_true_cb(Ne-1); -- signo del exponente representado en SVA
		v_exp_sva <= ((not e_true_cb)+ x"01") when s_exp_sva='1' else e_true_cb;-- valor del exponente representado en SVA
	
	end generate;

	cg_doexp_34: if P=34 generate -- puede ser Ne=14
		e_true_cd <= e + sh_exp; -- exponmente de entrada mas ajuste por normalización, en cero desplazado
		e_true_cb <=e_true_cd + "10011111100000"; --x"27e0"; -- exponente + CB(bias), exponente + CB(398)
	
		s_exp_sva <= e_true_cb(Ne-1); -- signo del exponente representado en SVA
		v_exp_sva <= ((not e_true_cb)+ x"01") when s_exp_sva='1' else e_true_cb;-- valor del exponente representado en SVA
	
	end generate;
	-- ==== Fin de tratamiento de exponente
	-- ========
	
	
	etn: LeadingNines generic map (P => P)
			Port map ( a => x_ld_zeros, c => cnt_nines);

   next_offset_step <=  cnt_nines;
	
	next_there_nines <= '0' when (cnt_nines=0) else '1';


-- ==================	
-- ===== barrel shift 
-- Para P=7
	cg_bch7_ini: if P=7 generate
						x_ld_nines <= x_ld_zeros when (cnt_nines="000") else 
										 (x_ld_zeros(4*P-5 downto 0)&x"0") when (cnt_nines="001") else 
										 (x_ld_zeros(4*P-9 downto 0)&x"00") when (cnt_nines="010") else 
										 (x_ld_zeros(4*P-13 downto 0)&x"000") when (cnt_nines="011") else 
										 (x_ld_zeros(4*P-17 downto 0)&x"0000") when (cnt_nines="100") else 
										 (x_ld_zeros(4*P-21 downto 0)&x"00000") when (cnt_nines="101") else 
										 (x_ld_zeros(4*P-25 downto 0)&x"000000") when (cnt_nines="110") else 
										 (others => '0'); 
	end generate;
	
-- Para P=16
	cg_bch16_ini: if P=16 generate
						x_ld_nines <= x_ld_zeros when (cnt_nines=x"00000") else 
										 (x_ld_zeros(4*P-5 downto 0)&x"0") when (cnt_nines="00001") else 
										 (x_ld_zeros(4*P-9 downto 0)&x"00") when (cnt_nines="00010") else 
										 (x_ld_zeros(4*P-13 downto 0)&x"000") when (cnt_nines="00011") else 
										 (x_ld_zeros(4*P-17 downto 0)&x"0000") when (cnt_nines="00100") else 
										 (x_ld_zeros(4*P-21 downto 0)&x"00000") when (cnt_nines="00101") else 
										 (x_ld_zeros(4*P-25 downto 0)&x"000000") when (cnt_nines="00110") else 
										 (x_ld_zeros(4*P-29 downto 0)&x"0000000") when (cnt_nines="00111") else 
										 (x_ld_zeros(4*P-33 downto 0)&x"00000000") when (cnt_nines="01000") else 
										 (x_ld_zeros(4*P-37 downto 0)&x"000000000") when (cnt_nines="01001") else 
										 (x_ld_zeros(4*P-41 downto 0)&x"0000000000") when (cnt_nines="01010") else 
										 (x_ld_zeros(4*P-45 downto 0)&x"00000000000") when (cnt_nines="01011") else 
										 (x_ld_zeros(4*P-49 downto 0)&x"000000000000") when (cnt_nines="01100") else 
										 (x_ld_zeros(4*P-53 downto 0)&x"0000000000000") when (cnt_nines="01101") else 
										 (x_ld_zeros(4*P-57 downto 0)&x"00000000000000") when (cnt_nines="01110") else 
										 (x_ld_zeros(4*P-61 downto 0)&x"000000000000000") when (cnt_nines="01111") else 					 
										 (others => '0'); 
	end generate;
	
	-- Para P=34	
	cg_bch34_ini: if P=34 generate
						x_ld_nines <= x_ld_zeros when (cnt_nines=x"000000") else 
										 (x_ld_zeros(4*P-5 downto 0)&x"0") when (cnt_nines="000001") else 
										 (x_ld_zeros(4*P-9 downto 0)&x"00") when (cnt_nines="000010") else 
										 (x_ld_zeros(4*P-13 downto 0)&x"000") when (cnt_nines="000011") else 
										 (x_ld_zeros(4*P-17 downto 0)&x"0000") when (cnt_nines="000100") else 
										 (x_ld_zeros(4*P-21 downto 0)&x"00000") when (cnt_nines="000101") else 
										 (x_ld_zeros(4*P-25 downto 0)&x"000000") when (cnt_nines="000110") else 
										 (x_ld_zeros(4*P-29 downto 0)&x"0000000") when (cnt_nines="000111") else 
										 (x_ld_zeros(4*P-33 downto 0)&x"00000000") when (cnt_nines="001000") else 
										 (x_ld_zeros(4*P-37 downto 0)&x"000000000") when (cnt_nines="001001") else 
										 (x_ld_zeros(4*P-41 downto 0)&x"0000000000") when (cnt_nines="001010") else 
										 (x_ld_zeros(4*P-45 downto 0)&x"00000000000") when (cnt_nines="001011") else 
										 (x_ld_zeros(4*P-49 downto 0)&x"000000000000") when (cnt_nines="001100") else 
										 (x_ld_zeros(4*P-53 downto 0)&x"0000000000000") when (cnt_nines="001101") else 
										 (x_ld_zeros(4*P-57 downto 0)&x"00000000000000") when (cnt_nines="001110") else 
										 (x_ld_zeros(4*P-61 downto 0)&x"000000000000000") when (cnt_nines="001111") else 					 
										(x_ld_zeros(4*P-65 downto 0)&x"0000000000000000") when (cnt_nines="010000") else 					 
										(x_ld_zeros(4*P-69 downto 0)&x"00000000000000000") when (cnt_nines="010001") else 					 										 
										(x_ld_zeros(4*P-73 downto 0)&x"000000000000000000") when (cnt_nines="010010") else 					 
										(x_ld_zeros(4*P-77 downto 0)&x"0000000000000000000") when (cnt_nines="010011") else 					 										 
										(x_ld_zeros(4*P-81 downto 0)&x"00000000000000000000") when (cnt_nines="010100") else 					 										 
										(x_ld_zeros(4*P-85 downto 0)&x"000000000000000000000") when (cnt_nines="010101") else 					 										 
										(x_ld_zeros(4*P-89 downto 0)&x"0000000000000000000000") when (cnt_nines="010110") else 					 										 
										(x_ld_zeros(4*P-93 downto 0)&x"00000000000000000000000") when (cnt_nines="010111") else 					 										 
										(x_ld_zeros(4*P-97 downto 0)&x"000000000000000000000000") when (cnt_nines="011000") else 					 										 
										(x_ld_zeros(4*P-101 downto 0)&x"0000000000000000000000000") when (cnt_nines="011001") else 					 										 
										(x_ld_zeros(4*P-105 downto 0)&x"00000000000000000000000000") when (cnt_nines="011010") else 					 										 
										(x_ld_zeros(4*P-109 downto 0)&x"000000000000000000000000000") when (cnt_nines="011011") else 					 										 
										(x_ld_zeros(4*P-113 downto 0)&x"0000000000000000000000000000") when (cnt_nines="011100") else 					 										 
										(x_ld_zeros(4*P-117 downto 0)&x"00000000000000000000000000000") when (cnt_nines="011101") else 					 										 
										(x_ld_zeros(4*P-121 downto 0)&x"000000000000000000000000000000") when (cnt_nines="011110") else 					 										 
										(x_ld_zeros(4*P-125 downto 0)&x"0000000000000000000000000000000") when (cnt_nines="011111") else 					 										 
										(x_ld_zeros(4*P-129 downto 0)&x"00000000000000000000000000000000") when (cnt_nines="100000") else 					 										 
										(x_ld_zeros(4*P-133 downto 0)&x"000000000000000000000000000000000") when (cnt_nines="100001") else 					 										 
										 (others => '0'); 
	end generate;
	
	
-- ==========================
-- =============== ACA ==============
-- ==========================	
	e_lut_c: Lut2_c port map ( d => x_ld_zeros(4*P-1 downto 4*(P-1)),
									c => c); 



	eMult_ini: Mult_Nx1_vaz Generic map (TAdd => TAdd, NDigit => P)
				port map ( d => x_ld_zeros, y => c, p => r_mult_ini);


	c_inst_lutLog7_ini: if P=7 generate
			e_lut_log7_ini: Lutb_log_pf7_ini generic map (P => P)
										port map ( d => x_ld_zeros(4*P-1 downto 4*(P-1)), log => log_ini);
	end generate;

	c_inst_lutLog16_ini: if P=16 generate
			e_lut_log16_ini: Lutb_log_pf16_ini generic map (P => P)
										port map ( d => x_ld_zeros(4*P-1 downto 4*(P-1)), log => log_ini);
	end generate;

	c_inst_lutLog34_ini: if P=34 generate
			e_lut_log34_ini: Lutb_log_pf34_ini generic map (P => P)
										port map ( d => x_ld_zeros(4*P-1 downto 4*(P-1)), log => log_ini);
	end generate;		


	oper_log_ini(4*P+12) <= '1';
	oper_log_ini(4*P+11 downto 0) <= (x"0"&log_ini(4*P+7 downto 0));
-- ==========================
-- =============== ACA ==============
-- ==========================	

	
	
-- ==================
-- ==================

-- ================================== FIN paso Inicial

--- ========
-- Módulo que pasa a BCD el exponente, trabaja en Ne/2+1 ciclos de relos, el primer ciclo es para inicializar el circuito, lo hace en paso inicial
-- el resto de los pasos (Ne/2), calcula el resultado en BCD del exponente determinado en SVA binario
	 instBinToBCD: BinToBCD_K generic map (N => Ne, K => Ke)
									  port map(clk => clk, rst => rst, start => en_ini, en_converter => en_exp, 
									           a => v_exp_sva, s => exp_sva_bcd);

-- ============================
-- Lógica relacionada con el paso 1..P+++

	cadd7:if (P=7) generate
		true_step <= reg_offset_step + step;	
	end generate;
	
	cadd16_34:if (P=16 or P=34) generate
		true_step <= ('0'&reg_offset_step) + step;	
	end generate;
	

	c_inst_lutLog7: if P=7 generate
			e_lut_log7: Lutb_log_pf7_bopt generic map (P => P)
										port map ( step => step,
													  offset_step => reg_offset_step,
													  true_step => true_step,
													  d => d,
													  x_greater_1 => ff_x_gr_one,
													  log => log);
	end generate;

	c_inst_lutLog16: if P=16 generate
			e_lut_log16: Lutb_log_pf16_bopt generic map (P => P)
										port map ( step => step,
													  offset_step => reg_offset_step,
													  true_step => true_step,
													  d => d,
													  x_greater_1 => ff_x_gr_one,
													  log => log);
	end generate;

	c_inst_lutLog34: if P=34 generate
			e_lut_log34: Lutb_log_pf34_bopt generic map (P => P)
										port map ( step => step,
													  offset_step => reg_offset_step,
													  true_step => true_step,
													  d => d,
													  x_greater_1 => ff_x_gr_one,
													  log => log);
	end generate;		

			
	d <= reg_x2(4*P-1 downto 4*(P-1));

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


	true_step_1 <= true_step - 1;
	true_step_2 <= true_step - 2;
	
		
	true_step_sh <= true_step_2 when (ff_x_gr_one ='0' and d=x"0") else true_step_1;				
	
	op_bsh_i <= zeros when (ff_x_gr_one='1') else nines;

-- ===========================
-- ============== barrel shift 2P
-- Para P=7
	c_bsh7: if P=7 generate
						oper_a_m <= reg_x2 when (true_step_sh="0000") else
								 (op_bsh_i(3 downto 0)&reg_x2(4*P-1 downto 4)) when (true_step_sh="0001") else				 	
								 (op_bsh_i(7 downto 0)&reg_x2(4*P-1 downto 8)) when (true_step_sh="0010") else				 	
								 (op_bsh_i(11 downto 0)&reg_x2(4*P-1 downto 12)) when (true_step_sh="0011") else				 	

								 (op_bsh_i(15 downto 0)&reg_x2(4*P-1 downto 16)) when (true_step_sh="0100") else				 	
								 (op_bsh_i(19 downto 0)&reg_x2(4*P-1 downto 20)) when (true_step_sh="0101") else				 	
								 (op_bsh_i(23 downto 0)&reg_x2(4*P-1 downto 24)) when (true_step_sh="0110") else 				 	
								 op_bsh_i(27 downto 0) when (true_step_sh="0111") else 				 	
								 op_bsh_i(27 downto 0);
	end generate;				


-- Para P=16
	c_bsh16: if P=16 generate
						oper_a_m <= reg_x2 when (true_step_sh="00000") else
								 (op_bsh_i(3 downto 0)&reg_x2(4*P-1 downto 4)) when (true_step_sh="000001") else				 	
								 (op_bsh_i(7 downto 0)&reg_x2(4*P-1 downto 8)) when (true_step_sh="000010") else				 	
								 (op_bsh_i(11 downto 0)&reg_x2(4*P-1 downto 12)) when (true_step_sh="000011") else				 	

								 (op_bsh_i(15 downto 0)&reg_x2(4*P-1 downto 16)) when (true_step_sh="000100") else				 	
								 (op_bsh_i(19 downto 0)&reg_x2(4*P-1 downto 20)) when (true_step_sh="000101") else				 	
								 (op_bsh_i(23 downto 0)&reg_x2(4*P-1 downto 24)) when (true_step_sh="000110") else				 	
								 (op_bsh_i(27 downto 0)&reg_x2(4*P-1 downto 28)) when (true_step_sh="000111") else				 	
					
								 (op_bsh_i(31 downto 0)&reg_x2(4*P-1 downto 32)) when (true_step_sh="001000") else				 	
								 (op_bsh_i(35 downto 0)&reg_x2(4*P-1 downto 36)) when (true_step_sh="001001") else				 	
								 (op_bsh_i(39 downto 0)&reg_x2(4*P-1 downto 40)) when (true_step_sh="001010") else				 	
								 (op_bsh_i(43 downto 0)&reg_x2(4*P-1 downto 44)) when (true_step_sh="001011") else				 	

								 (op_bsh_i(47 downto 0)&reg_x2(4*P-1 downto 48)) when (true_step_sh="001100") else				 	
								 (op_bsh_i(51 downto 0)&reg_x2(4*P-1 downto 52)) when (true_step_sh="001101") else				 	
								 (op_bsh_i(55 downto 0)&reg_x2(4*P-1 downto 56)) when (true_step_sh="001110") else				 	
								 (op_bsh_i(59 downto 0)&reg_x2(4*P-1 downto 60)) when (true_step_sh="001111") else				 	
								  op_bsh_i(63 downto 0) when (true_step_sh="10000") else				 	
								  op_bsh_i(63 downto 0);
	end generate;
	
	-- Para P=34
	c_bsh34: if P=34 generate
						oper_a_m <= reg_x2 when (true_step_sh="000000") else
								 (op_bsh_i(3 downto 0)&reg_x2(4*P-1 downto 4)) when (true_step_sh="0000001") else				 	
								 (op_bsh_i(7 downto 0)&reg_x2(4*P-1 downto 8)) when (true_step_sh="0000010") else				 	
								 (op_bsh_i(11 downto 0)&reg_x2(4*P-1 downto 12)) when (true_step_sh="0000011") else				 	
								 (op_bsh_i(15 downto 0)&reg_x2(4*P-1 downto 16)) when (true_step_sh="0000100") else				 	
								 (op_bsh_i(19 downto 0)&reg_x2(4*P-1 downto 20)) when (true_step_sh="0000101") else				 	
								 (op_bsh_i(23 downto 0)&reg_x2(4*P-1 downto 24)) when (true_step_sh="0000110") else				 	
								 (op_bsh_i(27 downto 0)&reg_x2(4*P-1 downto 28)) when (true_step_sh="0000111") else				 	
								 (op_bsh_i(31 downto 0)&reg_x2(4*P-1 downto 32)) when (true_step_sh="0001000") else				 	
								 (op_bsh_i(35 downto 0)&reg_x2(4*P-1 downto 36)) when (true_step_sh="0001001") else				 	
								 (op_bsh_i(39 downto 0)&reg_x2(4*P-1 downto 40)) when (true_step_sh="0001010") else				 	
								 (op_bsh_i(43 downto 0)&reg_x2(4*P-1 downto 44)) when (true_step_sh="0001011") else				 	
								 (op_bsh_i(47 downto 0)&reg_x2(4*P-1 downto 48)) when (true_step_sh="0001100") else				 	
								 (op_bsh_i(51 downto 0)&reg_x2(4*P-1 downto 52)) when (true_step_sh="0001101") else				 	
								 (op_bsh_i(55 downto 0)&reg_x2(4*P-1 downto 56)) when (true_step_sh="0001110") else				 	
								 (op_bsh_i(59 downto 0)&reg_x2(4*P-1 downto 60)) when (true_step_sh="0001111") else			
								 (op_bsh_i(63 downto 0)&reg_x2(4*P-1 downto 64)) when (true_step_sh="0010000") else				 	
								 (op_bsh_i(67 downto 0)&reg_x2(4*P-1 downto 68)) when (true_step_sh="0010001") else				 	
								 (op_bsh_i(71 downto 0)&reg_x2(4*P-1 downto 72)) when (true_step_sh="0010010") else				 	
								 (op_bsh_i(75 downto 0)&reg_x2(4*P-1 downto 76)) when (true_step_sh="0010011") else			
								 (op_bsh_i(79 downto 0)&reg_x2(4*P-1 downto 80)) when (true_step_sh="0010100") else				 	
								 (op_bsh_i(83 downto 0)&reg_x2(4*P-1 downto 84)) when (true_step_sh="0010101") else				 	
								 (op_bsh_i(87 downto 0)&reg_x2(4*P-1 downto 88)) when (true_step_sh="0010110") else				 	
								 (op_bsh_i(91 downto 0)&reg_x2(4*P-1 downto 92)) when (true_step_sh="0010111") else			
								 (op_bsh_i(95 downto 0)&reg_x2(4*P-1 downto 96)) when (true_step_sh="0011000") else				 	
								 (op_bsh_i(99 downto 0)&reg_x2(4*P-1 downto 100)) when (true_step_sh="0011001") else				 	
								 (op_bsh_i(103 downto 0)&reg_x2(4*P-1 downto 104)) when (true_step_sh="0011010") else				 	
								 (op_bsh_i(107 downto 0)&reg_x2(4*P-1 downto 108)) when (true_step_sh="0011011") else			
								 (op_bsh_i(111 downto 0)&reg_x2(4*P-1 downto 112)) when (true_step_sh="0011100") else				 	
								 (op_bsh_i(115 downto 0)&reg_x2(4*P-1 downto 116)) when (true_step_sh="0011101") else				 	
								 (op_bsh_i(119 downto 0)&reg_x2(4*P-1 downto 120)) when (true_step_sh="0011110") else				 	
								 (op_bsh_i(123 downto 0)&reg_x2(4*P-1 downto 124)) when (true_step_sh="0011111") else			
								 (op_bsh_i(127 downto 0)&reg_x2(4*P-1 downto 128)) when (true_step_sh="0100000") else				 	
								 (op_bsh_i(131 downto 0)&reg_x2(4*P-1 downto 132)) when (true_step_sh="0100001") else				 	
 								  op_bsh_i(135 downto 0) when (true_step_sh="0100010") else				 	
								  op_bsh_i(135 downto 0);
	end generate;

-- ============== barrel shift 				 
-- ===========================
	

	oper_b_m <= d when (ff_x_gr_one='1') else cb;					

	

	eMult: Mult_Nx1_vaz Generic map (TAdd => TAdd, NDigit => P)
							port map ( d => oper_a_m, y => oper_b_m, p => r_mult); 			  

			  
		 
	
	oper_b_add <= r_mult(4*P-1 downto 0);
	
--oper_a_add <= (reg_x2(4*P-5 downto 0)&"0000") when (step_eq_0 = '0') else reg_x2;
	
	oper_a_add <= (reg_x2(4*P-5 downto 0)&"0000");

	
	x_add_sub: addsub_BCD_L6  generic map(TAddSub => TAddSub, NDigit => P)
									port map (a => oper_a_add, b => oper_b_add, 
									cin => '0' , sub => ff_x_gr_one, cout => co_add_sub, s => r_add_sub);
						
-- cuando realiza la resta A-B, si pide uno, es decir B es mayor a A, entonce resultado es menor a 1 -> 0,9s, 
--   sino pide uno, el resultado es mayor a 1 -> 1.0's
--  Cuando realizo A+c9(B)+1, con A>0 y B>0, tiene acarreo si A es mayor a B. 
--
-- Cuando realiza la suma A+B, si hay acarreo, entonce resultado es mayor a 1 -> 1,0s, si no hay acarreo el resultado es menor a 1 -> 0.9's
						

	oper_log(4*P+12) <= log(4*P+8);
	oper_log(4*P+11 downto 0) <= (x"0"&log(4*P+7 downto 0));	

	
	e_sub_y: AS_SVA_CB_I 
 generic map(TAddSub => TAddSub, N => P+3)  
	port map (op => '1', s_a => reg_y(4*P+12), a => reg_y(4*P+11 downto 0),
					  s_b => oper_log(4*P+12), b => oper_log(4*P+11 downto 0), co => open,  
					 s_r => res_sub(4*P+12), r => res_sub(4*P+11 downto 0));



	next_x_gr_one <= 	r_mult_ini(4*P) when (ctrl_x_gr_one = '0' and next_there_nines='0') else
							'0' when ctrl_x_gr_one = '0' else
							(co_add_sub and  (not r_mult(4*P))) when (step_eq_1 = '1' and  ff_x_gr_one = '1') else
--En este caso,  es >1 cuanto hay acarreo en la suma (A+c9(B)+1) y no se produjo acarreo en la multiplicación,
							co_add_sub; 


	next_x <=	x when ctrl_x = '1' else 
					reg_x;
	

	next_y <=	(others => '0') when ((ctrl_y = '0') and (next_there_nines='1')) else 
					oper_log_ini	when ctrl_y = '0' else
					res_sub;

	
	
-- ==================
-- ================================== FIN tratamiento central


-- ==========================================
-- ==================  Paso Final


-- ==============================================
-- ==============================================
-- ACA algo importante que tienen que ver con la convwersion a BCD	
--oper_add_end <= reg_exp;-- connversión de binario a BCD
-- ==============================================
-- ==============================================

	c_gen_condexp7_16: if (P=7 or P=16)  generate -- significa que Ke=3
		exp_eq_0 <= '1' when (exp_sva_bcd = x"000") else '0';
		oper_one <= x"001";
	end generate;

	c_gen_condexp34: if P=34  generate -- significa que Ke=4
		exp_eq_0 <= '1' when (exp_sva_bcd = x"0000") else '0';
		oper_one <= x"0001";
	end generate;



-- ==================
-- =========== Parte nueva
-- ==================




	cgres_end_b_7: if P=7 generate
		sh_reg_y <= reg_y(4*P+7 downto 0) when (reg_offset_step="000") else
								(x"0"&reg_y(4*P+7 downto 4)) when (reg_offset_step="001") else
								(x"00"&reg_y(4*P+7 downto 8)) when (reg_offset_step="010") else
								(x"000"&reg_y(4*P+7 downto 12)) when (reg_offset_step="011") else
								(x"0000"&reg_y(4*P+7 downto 16)) when (reg_offset_step="100") else
								(x"00000"&reg_y(4*P+7 downto 20)) when (reg_offset_step="101") else
								(x"000000"&reg_y(4*P+7 downto 24)) when (reg_offset_step="110") else
								(x"0000000"&reg_y(4*P+7 downto 28)) when (reg_offset_step="111") else
								(others => '0');	
	end generate;
	
	cgres_end_b_16: if P=16 generate
		sh_reg_y <= reg_y(4*P+7 downto 0) when (reg_offset_step="00000") else
								(x"0"&reg_y(4*P+7 downto 4)) when (reg_offset_step="00001") else
								(x"00"&reg_y(4*P+7 downto 8)) when (reg_offset_step="00010") else
								(x"000"&reg_y(4*P+7 downto 12)) when (reg_offset_step="00011") else
								(x"0000"&reg_y(4*P+7 downto 16)) when (reg_offset_step="00100") else
								(x"00000"&reg_y(4*P+7 downto 20)) when (reg_offset_step="00101") else
								(x"000000"&reg_y(4*P+7 downto 24)) when (reg_offset_step="00110") else
								(x"0000000"&reg_y(4*P+7 downto 28)) when (reg_offset_step="00111") else
								(x"00000000"&reg_y(4*P+7 downto 32)) when (reg_offset_step="01000") else
								(x"000000000"&reg_y(4*P+7 downto 36)) when (reg_offset_step="01001") else
								(x"0000000000"&reg_y(4*P+7 downto 40)) when (reg_offset_step="01010") else
								(x"00000000000"&reg_y(4*P+7 downto 44)) when (reg_offset_step="01011") else
								(x"000000000000"&reg_y(4*P+7 downto 48)) when (reg_offset_step="01100") else
								(x"0000000000000"&reg_y(4*P+7 downto 52)) when (reg_offset_step="01101") else
								(x"00000000000000"&reg_y(4*P+7 downto 56)) when (reg_offset_step="01110") else
								(x"000000000000000"&reg_y(4*P+7 downto 60)) when (reg_offset_step="01111") else
								(x"0000000000000000"&reg_y(4*P+7 downto 64)) when (reg_offset_step="10000") else
								(others => '0');	
	end generate;	

	cgres_end_b_34: if P=34 generate
		sh_reg_y <= reg_y(4*P+7 downto 0) when (reg_offset_step="000000") else
								(x"0"&reg_y(4*P+7 downto 4)) when (reg_offset_step="000001") else
								(x"00"&reg_y(4*P+7 downto 8)) when (reg_offset_step="000010") else
								(x"000"&reg_y(4*P+7 downto 12)) when (reg_offset_step="000011") else
								(x"0000"&reg_y(4*P+7 downto 16)) when (reg_offset_step="000100") else
								(x"00000"&reg_y(4*P+7 downto 20)) when (reg_offset_step="000101") else
								(x"000000"&reg_y(4*P+7 downto 24)) when (reg_offset_step="000110") else
								(x"0000000"&reg_y(4*P+7 downto 28)) when (reg_offset_step="000111") else
								(x"00000000"&reg_y(4*P+7 downto 32)) when (reg_offset_step="001000") else
								(x"000000000"&reg_y(4*P+7 downto 36)) when (reg_offset_step="001001") else
								(x"0000000000"&reg_y(4*P+7 downto 40)) when (reg_offset_step="001010") else
								(x"00000000000"&reg_y(4*P+7 downto 44)) when (reg_offset_step="001011") else
								(x"000000000000"&reg_y(4*P+7 downto 48)) when (reg_offset_step="001100") else
								(x"0000000000000"&reg_y(4*P+7 downto 52)) when (reg_offset_step="001101") else
								(x"00000000000000"&reg_y(4*P+7 downto 56)) when (reg_offset_step="001110") else
								(x"000000000000000"&reg_y(4*P+7 downto 60)) when (reg_offset_step="001111") else
								(x"0000000000000000"&reg_y(4*P+7 downto 64)) when (reg_offset_step="010000") else
								(x"00000000000000000"&reg_y(4*P+7 downto 68)) when (reg_offset_step="010001") else
								(x"000000000000000000"&reg_y(4*P+7 downto 72)) when (reg_offset_step="010010") else
								(x"0000000000000000000"&reg_y(4*P+7 downto 76)) when (reg_offset_step="010011") else
								(x"00000000000000000000"&reg_y(4*P+7 downto 80)) when (reg_offset_step="010100") else
								(x"000000000000000000000"&reg_y(4*P+7 downto 84)) when (reg_offset_step="010101") else
								(x"0000000000000000000000"&reg_y(4*P+7 downto 88)) when (reg_offset_step="010110") else
								(x"00000000000000000000000"&reg_y(4*P+7 downto 92)) when (reg_offset_step="010111") else
								(x"000000000000000000000000"&reg_y(4*P+7 downto 96)) when (reg_offset_step="011000") else
								(x"0000000000000000000000000"&reg_y(4*P+7 downto 100)) when (reg_offset_step="011001") else
								(x"00000000000000000000000000"&reg_y(4*P+7 downto 104)) when (reg_offset_step="011010") else
								(x"000000000000000000000000000"&reg_y(4*P+7 downto 108)) when (reg_offset_step="011011") else
								(x"0000000000000000000000000000"&reg_y(4*P+7 downto 112)) when (reg_offset_step="011100") else
								(x"00000000000000000000000000000"&reg_y(4*P+7 downto 116)) when (reg_offset_step="011101") else
								(x"000000000000000000000000000000"&reg_y(4*P+7 downto 120)) when (reg_offset_step="011110") else
								(x"0000000000000000000000000000000"&reg_y(4*P+7 downto 124)) when (reg_offset_step="011111") else
								(x"00000000000000000000000000000000"&reg_y(4*P+7 downto 128)) when (reg_offset_step="100000") else
								(x"000000000000000000000000000000000"&reg_y(4*P+7 downto 132)) when (reg_offset_step="100001") else
								(x"0000000000000000000000000000000000"&reg_y(4*P+7 downto 136)) when (reg_offset_step="100010") else
								(others => '0');	
	end generate;	

	oper0_frac <= reg_y(4*P+7 downto 0) when (exp_eq_0 = '1') else sh_reg_y;


	-- =====
	-- Esto es para negar... se debe sumar uno, para ello se aprovecha lógica de redondeo
	neg_sh_reg_y:  for I in 0 to P+1 generate
		neg_y_inst: C9_Chen port map (a => sh_reg_y(4*I+3 downto 4*I), b => n_sh_reg_y(4*I+3 downto 4*I));	
	end generate;
	-- =====
	

	operation <= ff_s_exp xor reg_y(4*P+12);

	oper_frac <= n_sh_reg_y when (exp_eq_0 = '0' and operation = '1' and reg_y(4*P+8)='0') else oper0_frac;

	s_log <= ff_s_exp when (exp_eq_0 = '0') else reg_y(4*P+12);
	
		
						
	 e_addsub_ent: addsub_BCD_L6 
						--Generic map (TAddSub => TAddSub, NDigit => Ke)   
						Generic map (TAddSub => 2, NDigit => Ke)   
						Port map( a => exp_sva_bcd, b => oper_one, 
									cin => '0', sub => operation,
									cout => open, s => oper_res);
	
						

-- oper_one(4*Ke-1 downto 4) son todos 0's
	oper_int <= (oper_one(4*Ke-1 downto 4)&reg_y(4*P+11 downto 4*P+8)) when (exp_eq_0 = '1') else 
					oper_res when (operation = '1' or reg_y(4*P+8) = '1') else
					exp_sva_bcd;


	log_ext <= oper_int&oper_frac;
	
	


	gen_ze_7_16: if (P=7 or P=16) generate -- Ke=3
			
		ze <= "100" when (log_ext(4*(Ke+P+2)-1 downto 4*(P+1))=x"0000") else 
				"011"  when (log_ext(4*(Ke+P+2)-1 downto 4*(P+2))=x"000") else 
				"010"  when (log_ext(4*(Ke+P+2)-1 downto 4*(P+3))=x"00") else 
				"001"  when (log_ext(4*(Ke+P+2)-1 downto 4*(P+4))=x"0") else  "000"; 
		
		log2_ext <= (log_ext(4*(Ke+P-2)-1 downto 0)&x"9999") when ze="100" else
						(log_ext(4*(Ke+P-1)-1 downto 0)&x"999") when ze="011" else
						(log_ext(4*(Ke+P)-1 downto 0)&x"99") when ze="010" else
						(log_ext(4*(Ke+P+1)-1 downto 0)&x"9") when ze="001" else
						log_ext;
				
	end generate;
	

	gen_ze_34: if (P=34) generate -- Ke=4
			
		ze <= "101" when (log_ext(4*(Ke+P+2)-1 downto 4*(P+1))=x"00000") else 
				"100" when (log_ext(4*(Ke+P+2)-1 downto 4*(P+2))=x"0000") else 
				"011"  when (log_ext(4*(Ke+P+2)-1 downto 4*(P+3))=x"000") else 
				"010"  when (log_ext(4*(Ke+P+2)-1 downto 4*(P+4))=x"00") else 
				"001"  when (log_ext(4*(Ke+P+2)-1 downto 4*(P+5))=x"0") else  "000"; 
		
		log2_ext <= (log_ext(4*(Ke+P-3)-1 downto 0)&x"99999") when ze="101" else
						(log_ext(4*(Ke+P-2)-1 downto 0)&x"9999") when ze="100" else
						(log_ext(4*(Ke+P-1)-1 downto 0)&x"999") when ze="011" else
						(log_ext(4*(Ke+P)-1 downto 0)&x"99") when ze="010" else
						(log_ext(4*(Ke+P+1)-1 downto 0)&x"9") when ze="001" else
						log_ext;
		
	end generate;
	
	
	
-- ====================
-- ========  Fin primer cambio versión  nueva			
-- ====================

	
	gen_exp_7: if P=7 generate
		exp_log <= 	"01011101" when (log_ext(4*(Ke+P+2)-1 downto 4*(P+1))=x"0000") else -- forma 0,0x..x, entonces en CD es 101+0 - 8
						"01011110" when (log_ext(4*(Ke+P+2)-1 downto 4*(P+2))=x"000") else -- forma 0,x..x entonces en CD es 101+0 -7
					  "01011111" when (log_ext(4*(Ke+P+2)-1 downto 4*(P+3))=x"00") else -- y,x..x, entonces en CD es 101+1-7
					 "01100000" when (log_ext(4*(Ke+P+2)-1 downto 4*(P+4))=x"0") else  -- yy,x..x, entonces en CD es 101+2-7
					 "01100001";  -- -- yyy,x..x, entonces en CD es 101+3-7
-- a todos les resta  7 (Precisión P), (o 8 o 6 o 5 o 4) para que no esté normalizado
	end generate;
	
	gen_exp_16: if P=16 generate

		exp_log <= "0110001101" when (log_ext(4*(Ke+P+2)-1 downto 4*(P+1))=x"0000") else -- forma 0,0x..x entonces en CD es 398+0-17
						"0110001110" when (log_ext(4*(Ke+P+2)-1 downto 4*(P+2))=x"000") else -- forma 0,x..x entonces en CD es 398+0-16
					  "0110001111" when (log_ext(4*(Ke+P+2)-1 downto 4*(P+3))=x"00") else -- forma y,x..x entonces en CD es 398+1-16
					 "0110010000" when (log_ext(4*(Ke+P+2)-1 downto 4*(P+4))=x"0") else  -- forma yy,x..x entonces en CD es 398+2-16
					 "0110010001";  -- forma yyy,x..x entonces en CD es 398+3-16
-- a todos les resta  16 (Precisión P), (o 17 o 15 o 14 o 13) para que no esté normalizado
	end generate;
	

	gen_exp_34: if P=34 generate
		exp_log <= "01100001100001" when (log_ext(4*(Ke+P+2)-1 downto 4*(P+1))=x"00000") else -- forma 0,0x..x entonces en CD es  6276-35
						"01100001100010" when (log_ext(4*(Ke+P+2)-1 downto 4*(P+2))=x"0000") else -- forma 0,x..x entonces en CD es 6276-34
					  "01100001100011" when (log_ext(4*(Ke+P+2)-1 downto 4*(P+3))=x"000") else -- forma y,x..x entonces en CD es 6276+1-34
					 "01100001100100" when (log_ext(4*(Ke+P+2)-1 downto 4*(P+4))=x"00") else  -- forma yy,x..x entonces en CD es 6276+2-34
					 "01100001100101" when (log_ext(4*(Ke+P+2)-1 downto 4*(P+5))=x"0") else  -- forma yyy,x..x entonces en CD es 6276+3-34
					 "01100001100110";  -- forma yyyy,x..x entonces en CD es  6276+4-34
-- a todos les resta  34 (Precisión P), (o 35 o 33 o 32 o 31 0 30) para que no esté normalizado
	end generate;



	cg_exp0_7: if P=7 generate --"01100101"  x"65"
		expadd <= (("00000"&reg_offset_step)+1) when (reg_y(4*P+7 downto 4*P+4) = "0000") else ("00000"&reg_offset_step);
		explog_t2 <= (not expadd)+1;
		explog_t <=  "01011110" + explog_t2;  
		-- considero frontera - 7, que es la precisión, para que no este normalizado en 0.
		explog0 <= "01011111" when (reg_y(4*P+8)= '1') else explog_t; 
		--1 cuando el resultado es 1.0000, resto 6 (P-1) a la frontera, al exponente para que no esté normalizado
	end generate;

	cg_exp0_16: if P=16 generate -- "0110001110" x"18e"
		expadd <= (("00000"&reg_offset_step)+1) when (reg_y(4*P+7 downto 4*P+4) = "0000") else ("00000"&reg_offset_step);
		explog_t2 <= (not expadd)+1;
		explog_t <=  "0101111110" + explog_t2;
		-- considero frontera - 16, que es la precisión, para que no este normalizado en 0.
		explog0 <= "0101111111" when (reg_y(4*P+8)= '1') else explog_t; 
		--1 cuando el resultado es 1.0000, resto 15 (P-1) a la frontera, al exponente para que no esté normalizado
	end generate;

	cg_exp0_34: if P=34 generate -- "01100010000100" x"1884"
		expadd <= (("00000000"&reg_offset_step)+1) when (reg_y(4*P+7 downto 4*P+4) = "0000") else ("00000000"&reg_offset_step);
		explog_t2 <= (not expadd)+1;
		explog_t <=  "01100001100010"+ explog_t2;		
		-- considero frontera - 16, que es la precisión, para que no este normalizado en 0.
		explog0 <=  "01100001100011" when (reg_y(4*P+8)= '1') else explog_t; 
		--1 cuando el resultado es 1.0000, resto 33 (P-1) a la frontera, al exponente para que no esté normalizado
	end generate;


-- =======================



	adder_corrEct: adder_BCD_L6 
							Generic map (TAdd => 2, NDigit => Ke+2)    
							Port map ( a => log2_ext(4*(Ke+2)-1 downto 0), b => zeros(4*(Ke+2)-1 downto 0), cin => '1', cout => s1_corr, s => res_corr);


	s2_corr <=  '1' when (res_corr(4*(Ke+2)-1 downto 4*(Ke+1))= x"6" or res_corr(4*(Ke+2)-1 downto 4*(Ke+1))= x"7" or res_corr(4*(Ke+2)-1 downto 4*(Ke+1))= x"8" 
								or res_corr(4*(Ke+2)-1 downto 4*(Ke+1))= x"9") or 
									(
									(res_corr(4*(Ke+2)-1 downto 4*(Ke+1))= x"5") and 
								
									((log2_ext(4*(Ke+3)-1 downto 4*(Ke+2))= x"1") or (log2_ext(4*(Ke+3)-1 downto 4*(Ke+2))= x"3") or 
									(log2_ext(4*(Ke+3)-1 downto 4*(Ke+2))= x"5") or (log2_ext(4*(Ke+3)-1 downto 4*(Ke+2))= x"7") or 
									(log2_ext(4*(Ke+3)-1 downto 4*(Ke+2))= x"9"))) else '0';
	
	s1_addRound <= s1_corr or s2_corr;
	
	s0_addRound <=  '1' when (log2_ext(4*(Ke+2)-1 downto 4*(Ke+1))= x"6" or log2_ext(4*(Ke+2)-1 downto 4*(Ke+1))= x"7" or log2_ext(4*(Ke+2)-1 downto 4*(Ke+1))= x"8" 
								or log2_ext(4*(Ke+2)-1 downto 4*(Ke+1))= x"9") or 
									(
									(log2_ext(4*(Ke+2)-1 downto 4*(Ke+1))= x"5") and 
									
									((log2_ext(4*(Ke+3)-1 downto 4*(Ke+2))= x"1") or (log2_ext(4*(Ke+3)-1 downto 4*(Ke+2))= x"3") or 
									(log2_ext(4*(Ke+3)-1 downto 4*(Ke+2))= x"5") or (log2_ext(4*(Ke+3)-1 downto 4*(Ke+2))= x"7") or 
									(log2_ext(4*(Ke+3)-1 downto 4*(Ke+2))= x"9"))) else '0';
	
	
	s_addRound <=  s1_addRound when (exp_eq_0 = '0' and operation = '1' and reg_y(4*P+8)='0') else s0_addRound;
	
	
	
	adder_corrround: adder_BCD_L6 
							--Generic map (TAdd => TAdd, NDigit => P)    
							Generic map (TAdd => 2, NDigit => P)    
							Port map ( a => log2_ext(4*(Ke+P+2)-1 downto 4*(Ke+2)), b => zeros(4*P-1 downto 0), cin => s_addRound, cout => open, s => r_log);


	
	next_rlog <= r_log;	
	next_explog <= explog0 when exp_eq_0='1' else exp_log;
	next_slog <= s_log;


	
-- ==================
-- ================================== FIN paso Final


					
	next_x2 <=	r_mult_ini(4*P-1 downto 0) when ((ctrl_x2 = '0') and (next_there_nines='0')) else 
					x_ld_nines	when ctrl_x2 = '0' else
					r_add_sub(4*P-1 downto 0);					
	

-- ==========================
-- Almacenamientos de circuito

	PRegs: process (clk, rst)
	begin
		if rst = '1' then
			
			reg_x <= (others=>'0');
			reg_x2 <= (others=>'0');
			reg_y <= (others=>'0');
			ff_x_gr_one <= '0';
			ff_there_nines <= '0';
			reg_offset_step <= (others => '0');	
			reg_rlog <= (others => '0');
			reg_explog <= (others => '0');
			ff_slog <= '0';
		

ff_s_exp <= '1';			
	
		elsif rising_edge(clk) then
			
			if (en_x='1') then
				reg_x <= next_x;
			end if;
			
			if (en_x2='1') then 
				reg_x2 <= next_x2;
			end if;
			
			if (en_y = '1') then 
			   reg_y <= next_y;
			end if;
			
			if (en_x_gr_one = '1') then
				ff_x_gr_one <= next_x_gr_one;
			end if;	

			if (en_ini = '1') then

				ff_there_nines <= next_there_nines;
				reg_offset_step <= next_offset_step;	


ff_s_exp <= s_exp_sva;
			end if;

			if (en_rlog='1') then
				reg_rlog <= next_rlog;
				reg_explog <= next_explog;
				ff_slog <= next_slog;
			end if;	

		end if;
	end process;

-- ==========================
-- ==========================

	s_log_o <= ff_slog; 		
	v_log_o <= reg_rlog(4*P-1 downto 0);
   exp_log_o <= reg_explog;

end Behavioral;



