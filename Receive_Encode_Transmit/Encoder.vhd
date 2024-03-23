----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date:    19:31:58 01/02/2016 
-- Design Name: 
-- Module Name:    Encoder - Behavioral 
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

entity Encoder is
	Generic	(K	: integer range 0 to 10 :=4;-- K bits for Message
				 N	: integer range 0 to 20 :=7);-- N bits for Codeword 
			 
    Port ( 
			  Data_in : in STD_LOGIC;
			  Data_out : out STD_LOGIC;
			  
          			 Clk : in  STD_LOGIC;
			  Rst : in STD_LOGIC;
			  
			  Valid_in : in STD_LOGIC;
			  Valid_out : out STD_LOGIC);
end Encoder;

architecture Behavioral of Encoder is

--Constant Declaration
Constant GP : STD_LOGIC_VECTOR ((N-K) downto 0) :="1011";	-- Generator Polynomial of (N-K) Degree

--Signal Declaration
Signal D,Q : STD_LOGIC_VECTOR ((N-K-1) downto 0) :=(Others => '0'); -- Flip flop's Inputs
Signal ClockCounter : integer range 0 to N;
Signal GTemp,UQX : STD_LOGIC;
Signal Data_in_Reg,Valid_in_Reg : STD_LOGIC;



Type Sw is ( Parity , message );
Signal Switch : Sw := Message;

begin

--Combinatorial Part
	
--1)- taking care of FF's Input and XORs
--***CHECKED***
	Gen1:for i in 1 to N-K-1 generate 
		D(i) <= (Gtemp xor Q(i-1)) when GP(i)='1' else
					 Q(i-1);
	end generate;
	D(0) <= Gtemp;
-------------------------------------------------------------------------------------------	

--2) taking care of FF's Outputs
--***CHECKED***
	UQX <= (Data_in_Reg xor Q(N-K-1)) When (Valid_in_Reg = '1') else '0';
--------------------------------------------------------------------------------------------
	
--3) taking care of GATE
--***CHECKED*** 
	Gtemp <= UQX when Switch = Message else '0'; -- Gtemp <= UQX and Switch2
--------------------------------------------------------------------------------------------

-- taking care of Switch 2
--4)***CHECKED***
	Data_out <= Data_in_Reg When Switch = Message else Q(N-K-1);
--------------------------------------------------------------------------------------------
	Valid_out <= '0' When ClockCounter = N else Valid_in_Reg;
-- Sequential part Va

Process(Clk)
begin
	if rising_edge(clk) then 
	
		if Rst='1' then 
	
			-- reset all assigned signals here
			Q <= (Others => '0');
			ClockCounter <= 0;
			Data_in_Reg <= '0';
			Valid_in_Reg <= '0';
			Switch <= Message;
			
		else

-----------------------------------------------------------------------
			-- Default assignments
			
			Q <= D;
			Valid_in_Reg <= Valid_in;
			Data_in_Reg <= Data_in;

-----------------------------------------------------------------------
			
			if Valid_in_Reg ='1' then 
				if ClockCounter < N then
					ClockCounter <= ClockCounter + 1;
				end if;
			end if; 
			
-----------------------------------------------------------------------			
			
			if ClockCounter = K-1 then 
				Switch <= Parity;
			end if;
			
-----------------------------------------------------------------------		
				
		end if;--Reset
	end if;--Clock
end Process;
end Behavioral;
