----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date:    23:15:45 12/31/2015 
-- Design Name: 
-- Module Name:    FIFOReceiver - Behavioral 
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

entity FIFOReceiver is
	Generic (Byte : integer := 8;
				Bit_Time : integer :=5460;
				FIFO_Length : integer := 1);
				
	Port    (Clock :  in std_logic;
				Reset : in std_logic:='0';
				
				RxD : in std_logic:='1';
				
				Data : out std_logic_vector(31 downto 0):=(Others => '0');
				Data_Valid : out std_logic:='0');

end FIFOReceiver;

architecture Behavioral of FIFOReceiver is

-------------------------------------------------------------------------------------

Signal RxD_Buffer : std_logic_vector((Byte -1) downto 0):=(Others => '0');
Signal RxD_Reg : std_logic :='1';
Signal Data_Valid_Reg : std_logic :='0';

Signal Time_counter : integer range 0 to Bit_Time-1 := 0;
Signal Bit_Counter : integer range 0 to Byte + 1 :=0; 

Type States is (Pre_Idle , Idle , Receive , Store_in_Queue , Continue_Stop , Output);
Signal Current : States := Pre_Idle;

type Queue is array (0 to 3) of std_logic_vector(7 downto 0);
signal Data_Queue : Queue := (others => x"00");

Signal i : integer Range 0 to FIFO_Length-1:=FIFO_Length-1;

Signal Data_Reg : std_logic_vector(31 downto 0):=(Others => '0');

-------------------------------------------------------------------------------------

begin

Data_Valid <= Data_Valid_Reg;

Data <= Data_Reg;

Process(Clock)
Begin
	if rising_edge(Clock) then
		if reset='1' then 
			-- reset
		else
			--default
			RxD_Reg <= RxD;
			
			
			Case Current is 
			
-------------------------------------------------------------------------------------			

				When Pre_Idle => 
					
				
					
					Data_Queue(0) <= (Others => '0');
					Data_Queue(1) <= (Others => '0');
					Data_Queue(2) <= (Others => '0');
					Data_Queue(3) <= (Others => '0');
					
					i <= FIFO_Length - 1;
					
					Current <= Idle;

-------------------------------------------------------------------------------------

				When Idle => 
					if RxD_Reg ='0' then 
						Current <= Receive;
						Time_Counter <= (Bit_Time-1) / 2;
							Data_Valid_Reg <= '0';
					else
						Current <= Idle;
					end if;
					
-------------------------------------------------------------------------------------
				
				When Receive =>
					if (Time_Counter /= Bit_Time-1) then
						Time_Counter <= Time_Counter + 1 ;
					else
						Time_Counter <= 0;
						if (Bit_Counter /= Byte + 1) then 
							Bit_Counter <= Bit_Counter + 1;
							if (Bit_Counter > 0) then 
								RxD_Buffer(Bit_Counter - 1) <= RxD_Reg;
							end if;
						else  
							Current <= Store_in_Queue;
							Bit_Counter <= 0;
						end if;
					end if;
					
-------------------------------------------------------------------------------------
				
				When Store_in_Queue => 
					Data_Queue(i) <= RxD_Buffer;
					
					Current <= Continue_Stop;
					
-------------------------------------------------------------------------------------		

				When Continue_Stop =>
					if i = 0 then 
						Current <= Output;
					else
						Current <= Idle;
						i <= i - 1;
					end if;
					
-------------------------------------------------------------------------------------

				When Output => 
					Data_Reg <= Data_Queue(3) & Data_Queue(2) & Data_Queue(1) & Data_Queue(0);
					Data_Valid_Reg <= '1';
					
					Current <= Pre_Idle;
					
-------------------------------------------------------------------------------------
			End Case;

			
		end if;
	end if;
End Process;

end Behavioral;

