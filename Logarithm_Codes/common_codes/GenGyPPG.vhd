----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date:    19:43:23 02/05/2009 
-- Design Name: 
-- Module Name:    GenGyPPG - Behavioral 
-- Project Name: 
-- Target Devices: 
-- Tool versions: 

library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.STD_LOGIC_ARITH.ALL;
use IEEE.STD_LOGIC_UNSIGNED.ALL;

--use work.mipackage.all;

Library UNISIM;
use UNISIM.vcomponents.all;

entity GenGyPPG is
    Port ( x : in  STD_LOGIC_VECTOR (3 downto 0);
           y : in  STD_LOGIC_VECTOR (3 downto 0);
			  
           pp, gg : out  STD_LOGIC);
end GenGyPPG;


architecture Behavioral of GenGyPPG is


begin


	LUT6_PP : LUT6
   generic map (
      INIT => X"0000000102040810") -- (k1 and p3 and k2) or (k3 and k1 and g2) or (p2 and g1 and k3)
   port map (
      O => pp,
      I0 => y(1),
      I1 => y(2),
      I2 => y(3),
      I3 => x(1),
      I4 => x(2),
      I5 => x(3));
		

	LUT6_GG : LUT6
   generic map (
      INIT => X"FFFFFFFEFCF8F0E0") -- g3 or (p3 and p2) or (p3 and p1) ( p1 and g2) or (g2 and g1)
   port map (
      O => gg,
      I0 => y(1),
      I1 => y(2),
      I2 => y(3),
      I3 => x(1),
      I4 => x(2),
      I5 => x(3));	
		
		

end Behavioral;


