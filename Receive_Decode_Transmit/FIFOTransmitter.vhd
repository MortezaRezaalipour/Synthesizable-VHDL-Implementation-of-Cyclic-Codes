----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date:    19:32:37 01/02/2016 
-- Design Name: 
-- Module Name:    FIFOTransmitter - Behavioral 
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

entity FIFOTransmitter is
	
	Generic (Transmitter_FIFO_Length : integer := 4;
				Byte : integer := 8;
				Bit_Time : integer :=5460);

	Port    (Clock : in STD_LOGIC;
				Reset : in STD_LOGIC:='0';
				
				Data : in STD_LOGIC_VECTOR(31 downto 0):=(Others => '0');
				Send : in STD_LOGIC:='0';
				
				TxD : out STD_LOGIC:='1';
				TxD_Valid : out STD_LOGIC:='0');

end FIFOTransmitter;

architecture Behavioral of FIFOTransmitter is

------------------------------------------------------------------------------

Type States is (Idle , Store_in_Queue , Set_Data , Start , Transmit , Continue_Stop );
Signal Current : States := Idle;

Signal Send_Reg : std_logic:='0';
Signal Data_Reg,Data_Reg_Buffer : std_logic_vector(31 downto 0):=(Others => '0');

type Queue is array (0 to 3) of std_logic_vector(7 downto 0);
signal Data_Queue : Queue := (others => x"00");

Signal i : integer range 0 to Transmitter_FIFO_Length-1 := Transmitter_FIFO_Length-1;
Signal TxD_Buffer : std_logic_vector((Byte-1) downto 0):=(Others =>'0');

Signal Time_Counter : integer range 0 to Bit_time - 1:=0; 
Signal Bit_Counter : integer range 0 to Byte+1 :=0;

Constant Stop_bit : std_logic :='1';
Constant Start_bit : std_logic :='0';

Signal TxD_Reg : std_logic :='1';
Signal TxD_Valid_Reg : std_logic:='0';

----------------------------------------------------------------------------------

begin

TxD <= TxD_Reg;
TxD_Valid <= TxD_Valid_Reg;

Process (Clock)
Begin 
	if rising_edge(Clock) then 
		if reset = '1' then
			--  reset all assigned signals
			Send_Reg <= '0';
			Data_Reg <= (Others => '0');
			
			TxD_Reg <= '1';
			TxD_Valid_Reg <= '0';
			
			Current <= Idle;
			
			Time_Counter <=0;
			Bit_Counter <=0;
			
			i <= Transmitter_FIFO_Length - 1;
			
			
		else 	
			-- default assignments
			Send_Reg <= Send;
			Data_Reg <= Data;
			
			Case Current is 
-----------------------------------------------------------------------			

				When Idle => 
					if Send_Reg = '1' then 
						Current <= Store_in_Queue;
						i <= Transmitter_FIFO_Length-1;
						Data_Reg_Buffer <= Data_Reg;
					else 
						Current <= Idle;
					end if;
					
-----------------------------------------------------------------------

				When Store_in_Queue =>
					Data_Queue (0) <= Data_Reg_Buffer(7  downto  0);
					Data_Queue (1) <= Data_Reg_Buffer(15 downto  8);
					Data_Queue (2) <= Data_Reg_Buffer(23 downto 16);
					Data_Queue (3) <= Data_Reg_Buffer(31 downto 24);
					
					Current <= Set_Data;
				
-----------------------------------------------------------------------					
				
				When Set_Data =>
					TxD_Buffer <= Data_Queue(i);
					Bit_Counter <= 0;
					Current <= Start;
					
-----------------------------------------------------------------------

				When Start => 
					TxD_Reg <= Start_Bit;
					TxD_Valid_Reg <= '1';
					Current <= Transmit;

-----------------------------------------------------------------------

				When Transmit =>
					
					if (Time_Counter /= Bit_Time-1) then
						Time_Counter <= Time_Counter + 1 ;
					else
						Time_Counter <= 0;
						if (Bit_Counter /= Byte) then 
								Bit_Counter <= Bit_Counter + 1;
								TxD_Reg <= TxD_Buffer(Bit_Counter);
								TxD_Valid_Reg <= '1';	
						else
							Current <= Continue_Stop;
							TxD_Reg <= Stop_Bit;
							TxD_Valid_Reg <= '0';
						end if;
					end if;

-----------------------------------------------------------------------
				
				When Continue_Stop => 
					if i = 0 then 
						Current <= Idle;
					else
						i <= i - 1;
						Current <= Set_data;
					end if;
				
-----------------------------------------------------------------------

			End Case;
		end if;
	end if;
end Process;

end Behavioral;
