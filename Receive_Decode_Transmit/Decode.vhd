----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date:    03:27:07 12/19/2015 
-- Design Name: 
-- Module Name:    Decode - Behavioral 
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

entity Decode is
	Generic (K : integer range 0 to 31 := 4;
				N : integer range 0 to 31 := 7);
	
	Port    (Clock : in STD_LOGIC;
				Reset : in STD_LOGIC:='0';
				Input_Ready : in STD_LOGIC:='0';
				Output_Ready : out STD_LOGIC:='0';	
				V : in STD_LOGIC_VECTOR ((N-1) downto 0);
				U : out STD_LOGIC_VECTOR ((K-1) downto 0));
end Decode;

architecture Behavioral of Decode is
--==============================================================================================
--Component Declaration

Component Decoder 
	Generic (K : integer range 0 to 31 := 4;
				N : integer range 0 to 31 := 7);
	Port    (clock : in STD_LOGIC;
				reset : in STD_LOGIC;
				Valid_in : in STD_LOGIC;
				Valid_out : out STD_LOGIC;
				Data_in : in STD_LOGIC;
				Data_out : out STD_LOGIC;
				
				Error_Happened : in STD_LOGIC:='0';
				Syndrome : out STD_LOGIC_VECTOR(2 downto 0):=(Others => '0'));
end Component;

--==============================================================================================

Component ErrorPattern_DetectionCircuit 
	Generic (K : integer range 0 to 31 := 4;
				N : integer range 0 to 31 := 7);
	Port (SyndromeVector : in STD_LOGIC_VECTOR (N-K-1 downto 0):=(Others => '0');
			Error : out STD_LOGIC:='0');
			
end Component;

--==============================================================================================

-- Signal Declaration
Signal U_Reg,U_Reg_Buffer : STD_LOGIC_VECTOR((K-1) downto 0);
Signal V_Reg,V_Reg_Buffer : STD_LOGIC_VECTOR((N-1) downto 0);

Signal Input_Ready_Reg,Start : STD_LOGIC :='0';
Signal Valid_out_Wire,Valid_out_Reg,Output_Ready_Reg : STD_LOGIC:='0';

Signal i : integer range 0 to K-1 := 0;
Signal j : integer range 0 to N-1 := 0;

Signal Data_in_Reg : STD_LOGIC;
Signal Data_out_Reg,Data_out_Wire : STD_LOGIC;

Type States is (Idle , Busy_Decoding , Output , Preparing );
Signal Current : States := Idle;

Signal Start_Counter : integer range 0 to N:=0;
----------------------------------------------------
-- Error Patteren Detector

Signal Syndrome_Wire : std_logic_vector(N-K-1 downto 0):=(Others => '0');
Signal Error_Wire : std_logic:='0';

----------------------------------------------------
begin

----------------------------------------------------
--Component Instatiation
	Unit_Decoder : Decoder Port Map (Clock,Reset, Start , Valid_out_Wire , Data_in_Reg , Data_out_Wire ,
								    Error_Wire , Syndrome_Wire );
	Unit_ErrorDetector : ErrorPattern_DetectionCircuit Port Map ( Syndrome_Wire , Error_Wire );
	
	U <= U_Reg_Buffer;
	Output_Ready <= Output_Ready_Reg;
	
Process(Clock)
Begin 
	if rising_edge(Clock) then 
		if reset = '1' then 
			-- reset all assigned signals
			Start_Counter <= 0;
			i <= 0;
			j <= 0;
			Start <= '0';
			Input_Ready_Reg <='0';
					
			Valid_out_Reg <= '0';
			Output_Ready_Reg <= '0';
			Data_in_Reg <= '0';
			Data_out_Reg <= '0';
					
			U_Reg <= (Others => '0');
			U_Reg_Buffer <= (Others => '0');
			V_Reg <= (Others => '0');
			V_Reg_Buffer <= (Others => '0');
						
			Output_Ready_Reg <= '0';
						
			Current <= Idle;
			
		else
			-- default assignments
			Input_Ready_Reg <= Input_Ready;
			
			V_Reg <= V;
			
			Valid_out_Reg <= Valid_out_Wire;
			Data_out_Reg <= Data_out_Wire;
			
			Case Current is 
--------------------------------------------------------------------------------------------------				
				
				When Idle => 
				
					if Input_Ready_Reg = '1' then 
						V_Reg_Buffer <= V_Reg;
						Current <= Busy_Decoding;
					else 
						Current <= Idle;
					end if;
					
--------------------------------------------------------------------------------------------------
				
				When Busy_Decoding => 
					-- Sending the Message to the Encoder_2	
					if Start_Counter /= N then 
						
						Start_Counter <= Start_Counter + 1;
						Start <= '1';
						if j /= N-1 then
							Data_in_Reg <= V_Reg_Buffer(j);
							j <= j + 1;
						else
							Data_in_Reg<= V_Reg_Buffer(j);
						end if;
				
					else
						
						Start <= '0';
						
					end if;
					
					-- Receiving the Codeword from the Encoder_2
					if Valid_out_Reg ='1' then 
						if i /= K-1 then 
							i <= i + 1;
							U_Reg(i) <= Data_out_Reg;
						else
							U_Reg(i) <= Data_out_Reg;
						end if;
					elsif Valid_out_Reg ='0' and i = K-1 then 
						Current <= Output;
					end if;
				
--------------------------------------------------------------------------------------------------				
				
				When Output => 
					
					U_Reg_Buffer <= U_Reg;
					Output_Ready_Reg <= '1';
					Current <= Preparing;
					
--------------------------------------------------------------------------------------------------				
				
				When Preparing => 
				
					Start_Counter <= 0;
					i <= 0;
					j <= 0;
					Start <= '0';
					Input_Ready_Reg <='0';
					
					Valid_out_Reg <= '0';
					Output_Ready_Reg <= '0';
					Data_in_Reg <= '0';
					Data_out_Reg <= '0';
					
					U_Reg <= (Others => '0');
					U_Reg_Buffer <= (Others => '0');
					V_Reg <= (Others => '0');
					V_Reg_Buffer <= (Others => '0');
						
					Output_Ready_Reg <= '0';
						
					Current <= Idle;

--------------------------------------------------------------------------------------------------
			end Case;
			
			
		end if;
	end if;
end Process;


end Behavioral;