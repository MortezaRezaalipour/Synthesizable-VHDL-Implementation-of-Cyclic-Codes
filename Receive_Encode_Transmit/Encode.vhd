----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date:    19:32:06 01/02/2016 
-- Design Name: 
-- Module Name:    Encode - Behavioral 
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

entity Encode is

	Generic	(K	: integer range 0 to 10 :=4;-- K bits for Message
				 N	: integer range 0 to 20 :=7);-- N bits for Codeword 
				 
	Port 		(Clock : in STD_LOGIC;
				 ReSeT : in STD_LOGIC:='0';
				 
				 Val_in : in STD_LOGIC:='0';
				 Val_out : out STD_LOGIC:='0';
				 
				 U : in STD_LOGIC_VECTOR((K-1) downto 0):=(Others => '0');
				 V : out STD_LOGIC_VECTOR((N-1) downto 0):=(Others => '0'));
				 
end Encode;

architecture Behavioral of Encode is

--================================================================================
--Component Declaration

Component Encoder 
	Generic	(K	: integer range 0 to 10 :=4;-- K bits for Message
				 N	: integer range 0 to 20 :=7);-- N bits for Codeword 	 
    Port ( Data_in : in STD_LOGIC;
			  Data_out : out STD_LOGIC;
			  
           Clk : in  STD_LOGIC;
			  Rst : in STD_LOGIC;
			  
			  Valid_in : in STD_LOGIC;
			  Valid_out : out STD_LOGIC);
end Component;

--================================================================================

--Signal Declaration 
Signal Utemp : STD_LOGIC_VECTOR((K-1) downto 0):=(Others => '0');
Signal Vtemp : STD_LOGIC_VECTOR((N-1) downto 0):=(Others => '0');

Signal Val_in_Reg : STD_LOGIC:='0';
Signal Val_out_Wire : STD_LOGIC:='0';

Signal i : integer range 0 to K := 0;
Signal j : integer range 0 to N := 0;

Signal Serial_U_in : STD_LOGIC;
Signal Serial_V_out : STD_LOGIC;

begin
----------------------------------------------------
--Component Instatiation
	Unit : Encoder		  Port Map (Data_in => Serial_U_in, 
											Data_out => Serial_V_out,
											Clk => clock,
											rst => reset,
											Valid_in => Val_in_Reg,
											Valid_out => Val_out_wire);
-----------------------------------------------------
--Other Combinatorial parts
	V <= Vtemp;
	Serial_U_in <= Utemp(i);

-----------------------------------------------------------------------	

Process(Clock)
Begin 
	if rising_edge(Clock) then 
		if reset = '1' then 
			-- reset all assigned signals
			i <= 0;
			j <= 0;
			Val_in_Reg <= '0';
			Utemp <= (Others => '0');
			Vtemp <= (Others => '0');
			
		else
			
			-- default assignments
			Val_in_Reg <= Val_in;
			Utemp <= U;

-----------------------------------------------------------------------
			
			if (J = N-1) then 
				Val_out <= Val_out_Wire;
			end if;
			
-----------------------------------------------------------------------			
			
			if( i < K - 1 and Val_in_Reg = '1') then 
				i <= i + 1;
			end if;
		
-----------------------------------------------------------------------			
			
			if (Val_out_Wire = '1') then 
				VTemp(j) <= Serial_V_out;
				if(j < N-1) then
					j <= j + 1;
				end if;
			end if;
			
-----------------------------------------------------------------------			
			
		end if;--Reset
	end if;--Clock
end Process;
end Behavioral;

