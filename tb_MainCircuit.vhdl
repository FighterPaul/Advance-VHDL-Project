--------------------------------------------------------------------------------
-- Company: 
-- Engineer:
--
-- Create Date:   06:53:45 04/07/2025
-- Design Name:   
-- Module Name:   D:/KMITL/Year_3/term2/Advanced Digital Design Using HDL/Projects/CLOCK/tb_MainCircuit.vhd
-- Project Name:  CLOCK
-- Target Device:  
-- Tool versions:  
-- Description:   
-- 
-- VHDL Test Bench Created by ISE for module: MainCirucit
-- 
-- Dependencies:
-- 
-- Revision:
-- Revision 0.01 - File Created
-- Additional Comments:
--
-- Notes: 
-- This testbench has been automatically generated using types std_logic and
-- std_logic_vector for the ports of the unit under test.  Xilinx recommends
-- that these types always be used for the top-level I/O of a design in order
-- to guarantee that the testbench will bind correctly to the post-implementation 
-- simulation model.
--------------------------------------------------------------------------------
LIBRARY ieee;
USE ieee.std_logic_1164.ALL;
 
-- Uncomment the following library declaration if using
-- arithmetic functions with Signed or Unsigned values
--USE ieee.numeric_std.ALL;
 
ENTITY tb_MainCircuit IS
END tb_MainCircuit;
 
ARCHITECTURE behavior OF tb_MainCircuit IS 
 
    -- Component Declaration for the Unit Under Test (UUT)
 
    COMPONENT MainCirucit
    PORT(
         clk : IN  std_logic;
         row : OUT  std_logic_vector(3 downto 0);
         col : IN  std_logic_vector(3 downto 0);
         dir_motor_out : OUT  std_logic;
         step_motor_out : OUT  std_logic;
         lcd_rw : OUT  std_logic;
         lcd_rs : OUT  std_logic;
         lcd_e : OUT  std_logic;
         data_out : OUT  std_logic_vector(7 downto 0)
        );
    END COMPONENT;
    

   --Inputs
   signal clk : std_logic := '0';
   signal col : std_logic_vector(3 downto 0) := (others => '0');

 	--Outputs
   signal row : std_logic_vector(3 downto 0);
   signal dir_motor_out : std_logic;
   signal step_motor_out : std_logic;
   signal lcd_rw : std_logic;
   signal lcd_rs : std_logic;
   signal lcd_e : std_logic;
   signal data_out : std_logic_vector(7 downto 0);

   -- Clock period definitions
   constant clk_period : time := 50 ns;
 
BEGIN
 
	-- Instantiate the Unit Under Test (UUT)
   uut: MainCirucit PORT MAP (
          clk => clk,
          row => row,
          col => col,
          dir_motor_out => dir_motor_out,
          step_motor_out => step_motor_out,
          lcd_rw => lcd_rw,
          lcd_rs => lcd_rs,
          lcd_e => lcd_e,
          data_out => data_out
        );

   -- Clock process definitions
   clk_process :process
   begin
		clk <= '0';
		wait for clk_period/2;
		clk <= '1';
		wait for clk_period/2;
   end process;
 

   -- Stimulus process
   stim_proc: process
   begin		
      -- hold reset state for 100 ns.
      wait for 100 ns;	

      wait for clk_period*10;

      col <= "0001";
      wait for clk_period*1000000;
      col <= "0000";
      wait for clk_period*1000000;

      col <= "0010";
      wait for clk_period*1000000;
      col <= "0000";
      wait for clk_period*1000000;

      col <= "0100";
      wait for clk_period*1000000;
      col <= "0000";
      wait for clk_period*1000000;

      -- insert stimulus here 

      wait;
   end process;

END;
