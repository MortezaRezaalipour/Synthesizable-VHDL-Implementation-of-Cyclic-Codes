----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date:    03:27:17 12/19/2015 
-- Design Name: 
-- Module Name:    Decoder - Behavioral 
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


entity Decoder is
	Generic (K : integer range 0 to 31 := 4;
				N : integer range 0 to 31 := 7);
	Port    (clock : in STD_LOGIC;
				reset : in STD_LOGIC;
				Valid_in : in STD_LOGIC;
				Valid_out : out STD_LOGIC;
				Data_in : in STD_LOGIC;
				Data_out : out STD_LOGIC;
				
				Error_Happened : in STD_LOGIC:='0';
				Syndrome : out STD_LOGIC_VECTOR(N-K-1 downto 0):=(Others => '0'));
end Decoder;

architecture Behavioral of Decoder is

--==============================================================================================
--Constant Declaration
--Generator Polynomials

Constant GP : STD_LOGIC_VECTOR ((N-K) downto 0) :="1011";	-- Generator Polynomial of (N-K) Degree

------------------------------------------------------------------------------------------------
--Signal Declaration

Signal D_Syndrome,Q_Syndrome : STD_LOGIC_VECTOR ((N-K-1) downto 0) :=(Others => '0');
Signal ClockCounter_1,ClockCounter_2,ClockCounter_3 : integer range 0 to N:=0;
Signal Temp : STD_LOGIC:='0';
Signal Data_in_Reg,Valid_in_Reg : STD_LOGIC:='0';

--New Signals
Signal D_Buffer,Q_Buffer : STD_LOGIC_VECTOR ((N-1) downto 0) := (Others => '0');
Signal Temp2 : STD_LOGIC:='0';
Signal Data_out_Reg,Valid_out_Reg : STD_LOGIC:='0';
Signal Continue : STD_LOGIC:='0';

------------------------------------------------------------------------------------------------


begin

--1)- taking care of  Syndrome Register
--CHECKED
	Gen1:for i in 1 to N-K-1 generate 
		D_Syndrome(i) <= (temp xor Q_Syndrome(i-1)) when GP(i)='1' else Q_Syndrome(i-1);
	end generate;
--------------------------------------------------------------------------
--------------------------------------------------------------------------
--2)- taking care of (GATE-4) for temp 
--CHECKED
	Temp <= Q_Syndrome(N-K-1) When (Valid_in_Reg = '1' or Continue = '1') else '0';
--------------------------------------------------------------------------
--------------------------------------------------------------------------
--3)- taking care of (GATE-1) for Syndrome Register
--CHECKED
	D_Syndrome(0) <=  ( temp xor Error_Happened ) When ( Continue = '1' and ClockCounter_1 = N ) else 
							( temp xor Data_in_Reg ) When  ( Valid_in_Reg = '1'  ) else
							'0';
	--Syndrome_out <= Q_Syndrome(N-K-1);	-- Right now it is optional
--------------------------------------------------------------------------
--------------------------------------------------------------------------
--4)- taking care of Buffer Register
--CHECKED
	Gen2: for j in  1 to N-1 generate 
		D_Buffer(j) <= Q_Buffer( j-1 );
	end generate;
--------------------------------------------------------------------------
--------------------------------------------------------------------------
--5) - taking care of (GATE_3) for temp2
--CHECKED	
	Temp2 <=  Error_Happened xor Q_Buffer(N-1);
--------------------------------------------------------------------------
--------------------------------------------------------------------------
--6) - taking care of (GATE-2) & (GATE-3) for 	Buffer Register
--CHECKED	
	D_Buffer(0) <= Temp2 when ( Valid_in_Reg = '0' ) else
						Data_in_Reg when( Valid_in_Reg = '1') else
						'0';
--------------------------------------------------------------------------
--------------------------------------------------------------------------
--7) - taking care of Error pattern detection circuit
	
	Syndrome <= Q_Syndrome;
	
--------------------------------------------------------------------------
--------------------------------------------------------------------------
--8) - taking care of the Data_out and Valid_out
	
	Data_out <= Data_out_Reg;
	
	Valid_out <= Valid_out_Reg;


--------------------------------------------------------------------------
--------------------------------------------------------------------------

Process(CLOCK)
Begin 
	if rising_edge(CLOCK) then 
		if reset = '1' then 
			--reset all assigned signals
			Q_Syndrome <= (Others => '0');
			Q_Buffer <= (Others => '0');
			
			Valid_in_Reg <= '0';
			Valid_out_Reg <= '0';
			Continue <= '0';
			
			Data_in_Reg <= '0';
			Data_out_Reg <= '0';
			
			ClockCounter_1 <= 0;
			ClockCounter_2 <= 0;
			ClockCounter_3 <= 0;
			
		else 
			--default assignments 
			Q_Syndrome <= D_Syndrome;
			Q_Buffer <= D_Buffer;
			
			Valid_in_Reg <= Valid_in;
			
			Data_in_Reg <= Data_in;
			Data_out_Reg <= Q_Buffer(N-1) xor Error_Happened;

--------------------------------------------------------------------------			

			if (Valid_in_Reg = '1') then 
				if (ClockCounter_1 < N) then 
					ClockCounter_1 <= ClockCounter_1 + 1;
					if ClockCounter_1 = N-1 then 
						Continue <= '1';
					end if;
				end if;
			end if;

--------------------------------------------------------------------------			

			if (Continue = '1' and ClockCounter_1 = N ) then 
				if (ClockCounter_2 <N) then 
					ClockCounter_2 <= ClockCounter_2 + 1;
				end if;
			end if;

--------------------------------------------------------------------------		
	
			if (Continue = '1' and ClockCounter_1 = N and ClockCounter_2 = N) then 
				if (ClockCounter_3 < K ) then 
					ClockCounter_3 <= ClockCounter_3 + 1;
					Valid_out_Reg <= '1';
				elsif (ClockCounter_3 = K) then 
					Valid_out_Reg <= '0';
					--Return to initial values in order to receive another string 
					Q_Syndrome <= (Others => '0');
					Q_Buffer <= (Others => '0');
			
					Valid_in_Reg <= '0';
					Valid_out_Reg <= '0';
					Continue <= '0';
			
					Data_in_Reg <= '0';
					Data_out_Reg <= '0';
			
					ClockCounter_1 <= 0;
					ClockCounter_2 <= 0;
					ClockCounter_3 <= 0;
				
				end if;
			end if;

--------------------------------------------------------------------------			
			
		end if;--RST
	end if;--CLK
End Process;
end Behavioral;