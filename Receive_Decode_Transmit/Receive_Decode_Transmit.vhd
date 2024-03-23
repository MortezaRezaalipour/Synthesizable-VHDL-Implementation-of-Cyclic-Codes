----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date:    10:41:34 01/11/2016 
-- Design Name: 
-- Module Name:    Receive_Decode_Transmit - Behavioral 
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

entity Receive_Decode_Transmit is
	Generic (Byte : integer := 8;
				Bit_Time : integer :=5460;
				
				Receiver_FIFO_Length : integer := 1;
				Transmitter_FIFO_Length : integer := 1;
				
				K	: integer range 0 to 31 :=4;
				N	: integer range 0 to 31 :=7);
				
	Port     (Clock : in std_logic;
				 Reset : in std_logic:='1';
				 
				 RxD : in std_logic:='1';
				 TxD : out std_logic:='1';
				 
				 TxD_Valid : out std_logic:='0');

end Receive_Decode_Transmit;

architecture Behavioral of Receive_Decode_Transmit is

--================================================================================

--Component Declaration
--1st
Component FIFOReceiver 
	Generic (Byte : integer := 8;
				Bit_Time : integer :=5460;
				Receiver_FIFO_Length : integer := 1);
				
	Port    (Clock :  in std_logic;
				Reset : in std_logic:='0';
				
				RxD : in std_logic:='1';
				
				Data : out std_logic_vector(31 downto 0):=(Others => '0');
				Data_Valid : out std_logic:='0');

end Component;


-------------------------------------------------------------------------------------------
--2nd
Component Decode 
	Generic (K : integer range 0 to 31 := 4;
				N : integer range 0 to 31 := 7);
	
	Port    (Clock : in STD_LOGIC;
				Reset : in STD_LOGIC:='0';
				Input_Ready : in STD_LOGIC:='0';
				Output_Ready : out STD_LOGIC:='0';	
				V : in STD_LOGIC_VECTOR ((N-1) downto 0);
				U : out STD_LOGIC_VECTOR ((K-1) downto 0));
end Component;

-------------------------------------------------------------------------------------------

--3rd
Component FIFOTransmitter 
	
	Generic (Transmitter_FIFO_Length : integer := 1;
				Byte : integer := 8;
				Bit_Time : integer :=5460);

	Port    (Clock : in STD_LOGIC;
				Reset : in STD_LOGIC:='0';
				
				Data : in STD_LOGIC_VECTOR(31 downto 0):=(Others => '0');
				Send : in STD_LOGIC:='0';
				
				TxD : out STD_LOGIC:='1';
				TxD_Valid : out STD_LOGIC:='0');

end Component;

--================================================================================
--Signal Declaration

-- Top Module Outputs
Signal TxD_Reg : std_logic:='1';
Signal TxD_Valid_Reg : std_logic:='0';

-------------------------------------------------------------------------------------------

-- Receiver's Signals
Signal RxD_Reg : std_logic:='1';
Signal Data_Wire : std_logic_vector(31 downto 0):=(Others => '0');
Signal Data_Valid_Wire : std_logic:='0';

-------------------------------------------------------------------------------------------

-- Decoder's Signals
Signal Input_Ready_Reg : std_logic:='0';
Signal V_Reg : std_logic_vector(N-1 downto 0):=(Others => '0');
Signal U_Wire : std_logic_vector(K-1 downto 0):=(Others => '0');
Signal Output_Ready_Wire : std_logic:='0';

-------------------------------------------------------------------------------------------

-- Transmitter's Signals 
Signal Data_Reg : std_logic_vector (31 downto 0):=(Others => '0');
Signal Send_Reg : std_logic := '0';
Signal TxD_Wire : std_logic := '1';
Signal TxD_Valid_Wire : std_logic := '0'; 

--================================================================================

begin

-- Combinatorial parts

Unit_Receiver : FIFOReceiver Port Map (Clock,Reset, RxD_Reg , Data_Wire , Data_Valid_Wire);

Unit_Decoder  : Decode Port Map (Clock,Reset, Input_Ready_Reg , Output_Ready_Wire , V_Reg , U_Wire );

Unit_Transmitter : FIFOTransmitter Port Map (Clock,Reset, Data_Reg , Send_Reg , TxD_Wire , TxD_Valid_Wire );

-- Top Module's Outputs
TxD <= TxD_Reg;
TxD_Valid <= TxD_Valid_Reg;

Process(Clock)
Begin
	if rising_edge(Clock) then 
		if Reset = '1' then
			-- Reset all
			RxD_Reg <= '0';
			
			V_Reg <= (Others => '0');
			Input_Ready_Reg <= '0';
			
			Data_Reg(N-1 downto 0) <= (Others => '0');
			Send_Reg <= '0';
			
			TxD_Reg <= '1';
			TxD_Valid_Reg <= '0';
			
		else
			-- Default
			-- Receiver's Inputs
			RxD_Reg <= RxD;
			
			-- Receiver's Outputs and Encoder's Inputs
			V_Reg <= Data_Wire(N-1 downto 0);
			Input_Ready_Reg <= Data_Valid_Wire;
			
			-- Encoder's Outputs and Transmitter's Inputs
			Data_Reg(K-1 downto 0) <= U_Wire;
			Send_Reg <= Output_Ready_Wire;
			
			-- Transmitter's Outputs
			TxD_Reg <= TxD_Wire;
			TxD_Valid_Reg <= TxD_Valid_Wire;
			
		end if;
	end if;
End Process;

end Behavioral;

