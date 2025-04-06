
library IEEE;
use IEEE.STD_LOGIC_1164.all;
use IEEE.STD_LOGIC_ARITH.all;
use IEEE.STD_LOGIC_UNSIGNED.all;
USE STD.TEXTIO.ALL;

Entity TbInterfaceLCD Is
End Entity TbInterfaceLCD;

Architecture HTWTestBench Of TbInterfaceLCD Is

--------------------------------------------------------------------------------------------
-- Constant Declaration
--------------------------------------------------------------------------------------------

	constant	tClk			: time := 50 ns;
	
-------------------------------------------------------------------------
-- Component Declaration
-------------------------------------------------------------------------
	
	Component InterfaceLCD Is
	Port(
        clk : in std_logic;

        lcd_rw : out std_logic;
        lcd_rs : out std_logic;
        lcd_e : out std_logic;
        data_out : out std_logic_vector(7 downto 0)
	);
	End Component InterfaceLCD;
	
-------------------------------------------------------------------------
-- Signal Declaration
-------------------------------------------------------------------------
	
	signal	TM			: integer	range 0 to 65535;
	signal 	TT			: integer	range 0 to 65535;
	
	signal	RstB		: std_logic;
	signal	Clk			: std_logic;


    signal signal_lcd_rw : out std_logic;
    signal signal_lcd_rs : out std_logic;
    signal lcd_e : out std_logic;
    signal signal_data_out : out std_logic_vector(7 downto 0)
	
Begin

----------------------------------------------------------------------------------
-- Concurrent signal
----------------------------------------------------------------------------------
	

	u_Clk : Process
	Begin
		Clk		<= '1';
		wait for tClk/2;
		Clk		<= '0';
		wait for tClk/2;
	End Process u_Clk;
	
	u_TbInterfaceLCD : InterfaceLCD
	Port map
	(	
		clk			=> Clk,
		lcd_rw	    => signal_lcd_rw,	
		lcd_rs	    => signal_lcd_rs,
		lcd_e	    => lcd_e,
		data_out	=> signal_data_out	
	);
	
-------------------------------------------------------------------------
-- Testbench
-------------------------------------------------------------------------

	u_Test : Process
	variable	iSerData	: std_logic_vector( 9 downto 0 );
	Begin
		-------------------------------------------
		-- TM=0 : Reset
		-------------------------------------------
		RstB	<= '0';
		wait for 20*tClk;
		RstB	<= '1';
		
		
		TM <= 0; wait for 1 ns;
		Report "TM=" & integer'image(TM); 
		wait for 10*tClk;

		-------------------------------------------
		-- TM=1 : Check counter value
		-------------------------------------------	
		TM <= 1; wait for 1 ns;
		Report "TM=" & integer'image(TM); 

		
		wait for 20000000*tClk;
		wait until rising_edge(clk);
	
		
		--------------------------------------------------------
		TM <= 255; wait for 1 ns;
		wait for 20*tClk;
		Report "##### End Simulation #####" Severity Failure;		
		wait;
		
	End Process u_Test;

End Architecture HTWTestBench;
