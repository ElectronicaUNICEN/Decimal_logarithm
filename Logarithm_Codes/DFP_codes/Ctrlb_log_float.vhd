
--
-- Unidad de control del Ln por método basado en desplazamientos  
-- Para logaritmo decimal en punto flotante
--

-- Es la versión para reducción inicial de latencia con el uso de dos multiplicadores 
-- y posterior incremento de latencia para resultados que inician con 0, eso hace que se deba hacer una iteración más..
-- Itera desde 1 a P+1, en convergencia

library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.STD_LOGIC_ARITH.ALL;
use IEEE.STD_LOGIC_UNSIGNED.ALL;
use work.my_package.all;

Library UNISIM;
use UNISIM.vcomponents.all;

entity Ctrlb_log_float is
	generic (P: integer:=7; Ne: integer:=8);
   Port ( clk, rst : in  std_logic;
           start : in  std_logic;
			  ctrl_x, en_x, ctrl_y, en_y, ctrl_x2, en_x2, ctrl_x_gr_one,en_x_gr_one, en_ini, en_rlog, en_exp: out std_logic;
			  done : out  std_logic;
			  step: out std_logic_vector(log2sup(P+2)-1 downto 0));
end Ctrlb_log_float;

-- step va desde 0 a P o desde 1 a P, Entonces
-- para P=7, de [0,7] o [1,7]. entonces va (3 downto 0)
-- para P=16, de [0,16] o [1,16]. entonces va (4 downto 0)
-- para P=34, de [0,34] o [1,34]. entonces  va (5 downto 0)

architecture Behavioral of Ctrlb_log_float is
	
	signal next_cnt, reg_cnt: std_logic_vector(log2sup(P+2)-1 downto 0);
	signal next_lim, reg_lim: std_logic_vector(log2sup(P+2)-1 downto 0);
	signal next_en_exp, ff_en_exp: std_logic;
	type states is (inactive, init_ln, do_ln, last_ln);
	
	signal next_state, state : states;		

begin 
 
					
	
	PCnt: process (clk, rst)
	begin
		if rst = '1' then
			reg_cnt <= (others => '0');
			reg_lim <= (others => '0');
			state <= inactive;
			ff_en_exp <= '0';
		elsif rising_edge(clk) then
			reg_cnt <= next_cnt;
			reg_lim <= next_lim;
			state <= next_state;
			
			ff_en_exp <= next_en_exp;
			
		end if;
	end process;


	state_mach: process(start, state, reg_cnt, reg_lim, ff_en_exp)

	begin
			
		en_x_gr_one	<= '0';
		ctrl_x_gr_one <= '0'; -- cuando es 0 carga 0's, si es uno funciona normalmente
		
		en_x <= '0';
		ctrl_x <= '0'; -- cuando es 0 mantiene el valor, cuando es uno toma  la entrada

		en_x2 <= '0';
		ctrl_x2 <= '0'; -- cuando es 0 carga x2 con el X sin los 9's iniciales, si es uno funciona normalmente.

		en_y <= '0';
		ctrl_y <= '0'; -- cuando es 0 carga y con 0's, si es uno funciona normalmente

		en_rlog <= '0'; -- para habilitar el registro con el resultado final
		
		next_state <= state;	
		next_cnt <= reg_cnt;
		next_en_exp <= ff_en_exp; -- Para realizar procesamiento del conversión de exponente binario a BCD
		
 		en_ini <= '0'; --para habilitar los registros de ff_there_nines y reg_offset_step, además inicialización de tratamiento de exponente en bcd
		
		
		case state is
			when inactive =>
			
				if start='1' then
					ctrl_x <= '1';
					en_x <= '1';
					next_state <=  init_ln;
					next_en_exp <= '1';				
				end if;

			when init_ln => -- ACA empieza la cosa
				
				en_x_gr_one	<= '1';
				en_x2 <= '1';
				ctrl_x2 <= '0'; -- toma el valo de x desplazado
				en_y <= '1';			
				ctrl_y <= '0'; -- para resetearlo
				ctrl_x_gr_one <= '0'; -- para resetearlo;
en_ini <= '1';
next_en_exp <= '1';				
				

-- para P=7, de [0,7] o [1,7]. entonces va (3 downto 0)
-- para P=16, de [0,16] o [1,16]. entonces va (4 downto 0)
-- para P=34, de [0,34] o [1,34]. entonces  va (5 downto 0)
				
				next_lim <= CONV_STD_LOGIC_VECTOR(P+1, log2sup(P+2));
				next_cnt <= (0 => '1', others => '0');	
				next_state <=  do_ln;
				
 		   when do_ln => 

				en_x2 <= '1';
				ctrl_x2 <= '1'; -- para que funcione normalmene
				en_y <= '1';			
				ctrl_y <= '1'; -- paea que funcione normalmente 
				en_x_gr_one	<= '1';
				ctrl_x_gr_one <= '1'; -- para que funcione normalmente
				
				if (reg_cnt=Ne/2) then
					next_en_exp <= '0';
				end if;
						
		
				
				if (reg_cnt = reg_lim) then
					next_state <= last_ln;
					next_cnt <= (others => '0');
				else
					next_state <= do_ln;
					next_cnt <= reg_cnt + 1;	
				end if;
				
			when last_ln => 
				
				en_rlog <= '1';	
				next_state <= inactive;
					
			when others => --finish
		end case;
	end process;
	
	en_exp <= ff_en_exp;
	
	step <= reg_cnt;
	done <= '0' when state/=inactive else '1';


end Behavioral;

