----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date:    03:27:48 12/19/2015 
-- Design Name: 
-- Module Name:    ErrorPatternDetectionCircuit - Behavioral 
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

entity ErrorPattern_DetectionCircuit is
	Generic (K : integer range 0 to 31 := 4;
				N : integer range 0 to 31 := 7);
				
	Port (SyndromeVector : in STD_LOGIC_VECTOR (N-K-1 downto 0):=(Others => '0');
			Error : out STD_LOGIC:='0');
			
end ErrorPattern_DetectionCircuit;

architecture Behavioral of ErrorPattern_DetectionCircuit is

begin

	Error <= SyndromeVector(0) and (not SyndromeVector(1)) and SyndromeVector(2);

end Behavioral;