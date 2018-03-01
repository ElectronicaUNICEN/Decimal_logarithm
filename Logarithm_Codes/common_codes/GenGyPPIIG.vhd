
library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.STD_LOGIC_ARITH.ALL;
use IEEE.STD_LOGIC_UNSIGNED.ALL;

library UNISIM;
use UNISIM.VComponents.all;

use UNISIM.VComponents.all;

entity GenGyPPIIG is
 	 Port ( x : in  STD_LOGIC_VECTOR (3 downto 0);
           y : in  STD_LOGIC_VECTOR (3 downto 0);
			  sub: in std_logic;
            gg,pp: out std_logic); 
			 
end GenGyPPIIG;

architecture Behavioral of GenGyPPIIG is

signal gga, ggs, ppa, pps: std_logic;

begin


-- ==================
-- vinculado a propagador

	LUT6_PP_a : LUT6
   generic map (
      INIT => X"0000000102040810") -- (k1 and p3 and k2) or (k3 and k1 and g2) or (p2 and g1 and k3)
   port map (
      O => ppa,
      I0 => y(1),
      I1 => y(2),
      I2 => y(3),
      I3 => x(1),
      I4 => x(2),
      I5 => x(3));
		
		
	LUT6_PP_s : LUT6
   generic map (
      INIT => X"0804021008040201")  -- (k1 and p3 and k2) or (k3 and k1 and g2) or (p2 and g1 and k)
   port map (
      O => pps,
      I0 => x(1),
      I1 => x(2),
      I2 => x(3),
      I3 => y(1),
      I4 => y(2),
      I5 => y(3));	

	MUX7_pp : MUXF7
   port map (
      O => pp,    
      I0 => ppa,  
      I1 => pps,
      S => sub  
   );


-- ==================
-- vinculado a generador

	LUT6_GG_a : LUT6
   generic map (
      INIT => X"FFFFFFFEFCF8F0E0") -- g3 or (p3 and p2) or (p3 and p1) ( p1 and g2) or (g2 and g1)
   port map (
      O => gga,
      I0 => y(1),
      I1 => y(2),
      I2 => y(3),
      I3 => x(1),
      I4 => x(2),
      I5 => x(3));	


	LUT6_G0_s : LUT6
   generic map (
      INIT => X"D0B8FCE0D0B8FCFE")  -- g3 or (p3 and p2) or (p3 and p1) ( p1 and g2) or (g2 and g1)
   port map (
      O => ggs,
      I0 => x(1),
      I1 => x(2),
      I2 => x(3),
      I3 => y(1),
      I4 => y(2),
      I5 => y(3));
	

	MUX7_gg : MUXF7
   port map (
      O => gg,    
      I0 => gga,  
      I1 => ggs,
      S => sub  
   );



end Behavioral;

