
library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.STD_LOGIC_ARITH.ALL;
use IEEE.STD_LOGIC_UNSIGNED.ALL;




library UNISIM;
use UNISIM.vcomponents.all;

entity Add4V5 is
--	 Generic (InitX : integer:=0;
--	  		InitY : integer:=0
--	          );
    Port ( a : in std_logic_vector(3 downto 0);
           b : in std_logic_vector(3 downto 0);
           c : out std_logic_vector(3 downto 0);
           cin : in std_logic;
           cout : out std_logic);
end Add4V5;

architecture Behavioral of Add4V5 is

--
--attribute RLOC of P1_LUT2: label is "X"&itoa(InitX)&"Y"&itoa(InitY);
--attribute RLOC of P2_LUT2: label is "X"&itoa(InitX)&"Y"&itoa(InitY);
--attribute RLOC of P3_LUT2: label is "X"&itoa(InitX)&"Y"&itoa(InitY);
--attribute RLOC of P4_LUT2: label is "X"&itoa(InitX)&"Y"&itoa(InitY);
--
--attribute RLOC of Mxcy_1: label is "X"&itoa(InitX)&"Y"&itoa(InitY);
--attribute RLOC of Mxcy_2: label is "X"&itoa(InitX)&"Y"&itoa(InitY);
--attribute RLOC of Mxcy_3: label is "X"&itoa(InitX)&"Y"&itoa(InitY);
--attribute RLOC of Mxcy_4: label is "X"&itoa(InitX)&"Y"&itoa(InitY);
--
--attribute RLOC of XORCY_1: label is "X"&itoa(InitX)&"Y"&itoa(InitY);
--attribute RLOC of XORCY_2: label is "X"&itoa(InitX)&"Y"&itoa(InitY);
--attribute RLOC of XORCY_3: label is "X"&itoa(InitX)&"Y"&itoa(InitY);
--attribute RLOC of XORCY_4: label is "X"&itoa(InitX)&"Y"&itoa(InitY);



signal o: std_logic_vector(3 downto 0);
signal omx: std_logic_vector(3 downto 1);


begin


		  P1_LUT2 : LUT2
		   generic map (
		      INIT => "0110")
		   port map (
		      O => o(0),   
		      I0 => a(0), 
		      I1 => b(0)  
		   );

		   P2_LUT2 : LUT2
		   generic map (
		      INIT => "0110")
		   port map (
		      O => o(1),   
		      I0 => a(1), 
		      I1 => b(1)  
		   );

		  P3_LUT2 : LUT2
		   generic map (
		      INIT => "0110")
		   port map (
		      O => o(2),   
		      I0 => a(2), 
		      I1 => b(2)  
		   );

		   P4_LUT2 : LUT2
		   generic map (
		      INIT => "0110")
		   port map (
		      O => o(3),   
		      I0 => a(3), 
		      I1 => b(3)  
		   );



			Mxcy_1: MUXCY port map (
		    	DI => b(0),
		    	CI => cin,
		    	S => o(0),
		    	O => omx(1));

			Mxcy_2: MUXCY port map (
		    	DI => b(1),
		    	CI => omx(1),
		   	S => o(1),
		    	O => omx(2));

			Mxcy_3: MUXCY port map (
		    	DI => b(2),
		    	CI => omx(2),
		    	S => o(2),
		    	O => omx(3));

			Mxcy_4: MUXCY port map (
		    	DI => b(3),
		    	CI => omx(3),
		   	S => o(3),
		    	O => cout);


			 XORCY_1 : XORCY
			   port map (
			      O => c(0), 
			      CI => cin, 
			      LI => o(0) 
			   );


			 XORCY_2 : XORCY
			   port map (
			      O => c(1), 
			      CI => omx(1), 
			      LI => o(1) 
			   );

			XORCY_3 : XORCY
			   port map (
			      O => c(2), 
			      CI => omx(2), 
			      LI => o(2) 
			   );

			XORCY_4 : XORCY
			   port map (
			      O => c(3), 
			      CI => omx(3), 
			      LI => o(3) 
			   );

end Behavioral;