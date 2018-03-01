----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date:    14:23:22 05/19/2016 
-- Design Name: 
-- Module Name:    C9_Chen - Behavioral 
-- Project Name: 
-- Target Devices: 
-- Tool versions: 
-- Description: 
--
-- Dependencies: 
--
-- Revision: 
-- Revision 0.01 - File Created
-- Additional Comments: 
--
----------------------------------------------------------------------------------
library IEEE;
use IEEE.STD_LOGIC_1164.ALL;

-- Uncomment the following library declaration if using
-- arithmetic functions with Signed or Unsigned values
--use IEEE.NUMERIC_STD.ALL;

-- Uncomment the following library declaration if instantiating
-- any Xilinx primitives in this code.
--library UNISIM;
--use UNISIM.VComponents.all;

entity C9_Chen is
    Port ( a : in  STD_LOGIC_VECTOR (3 downto 0);
           b : out  STD_LOGIC_VECTOR (3 downto 0));
end C9_Chen;

architecture Behavioral of C9_Chen is

begin

			b <= "0000" when a = "1001" else
					"0001" when a = "1000" else
					"0010" when a = "0111" else
					"0011" when a = "0110" else
					"0100" when a = "0101" else
					"0101" when a = "0100" else
					"0110" when a = "0011" else
					"0111" when a = "0010" else
					"1000" when a = "0001" else
					"1001" when a = "0000" else
					"0000";
					
end Behavioral;

