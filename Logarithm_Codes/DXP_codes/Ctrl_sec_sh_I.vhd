
--
-- Unidad de control del Ln por método basado en desplazamientos, version uso de multiplicaciones Nx1 combinacional
--


library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.STD_LOGIC_ARITH.ALL;
use IEEE.STD_LOGIC_UNSIGNED.ALL;
use work.my_package.all;

Library UNISIM;
use UNISIM.vcomponents.all;

entity Ctrl_sec_sh_I is
	generic (P: integer:=2);
   Port ( clk, rst : in  std_logic;
           start : in  std_logic;
			  ctrl_x, ctrl_y: out std_logic;
			  done : out  std_logic;
			  step: out std_logic_vector(log2sup(P)-1 downto 0));
end Ctrl_sec_sh_I;

architecture Behavioral of Ctrl_sec_sh_I is
	
	signal next_cnt, reg_cnt: std_logic_vector(log2sup(P)-1 downto 0);
	
	signal inc_cnt: std_logic;
	signal rs_cnt: std_logic;
	
	type states is (inactive, do_ln);
	
	signal next_state, state : states;		

begin 
 

	next_cnt <= (others => '0') when rs_cnt='1' else
					reg_cnt+1 when inc_cnt='1'else
					reg_cnt;				
					
	
	PCnt: process (clk, rst)
	begin
		if rst = '1' then
			reg_cnt <= (others => '0');
			state <= inactive;
		elsif rising_edge(clk) then
			reg_cnt <= next_cnt;
			state <= next_state;
		end if;
	end process;


	state_mach: process(start, state, reg_cnt)
	begin
			
		rs_cnt <= '0';
		inc_cnt <= '0';
		ctrl_x <= '0';
		ctrl_y <= '0';
		next_state <= state;	
		
		case state is
			when inactive =>
				if start='1' then
					next_state <= do_ln;
					ctrl_x <= '1';
					ctrl_y <= '1';				
					rs_cnt <= '1';
				end if;
			when do_ln => 
				if (reg_cnt = P-1) then
					next_state <= inactive;
					rs_cnt <= '1';
				else
					next_state <= do_ln;
					inc_cnt <= '1';	
				end if;
			when others => --finish
		end case;
	end process;
 
	step <= reg_cnt;
	done <= '0' when state/=inactive else '1';

end Behavioral;

