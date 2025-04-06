library ieee;
use ieee.std_logic_1164.all;

entity InterfaceStepperMotor is 
port
(
    clk : in std_logic;         -- 20MHz
    en : in std_logic;
    dir_in : in std_logic;

    dir_out: out std_logic;
    step: out std_logic
);
end entity;


architecture arch of InterfaceStepperMotor is

    signal signal_step : std_logic := '0';
    signal signal_dir : std_logic := '0'; 

    signal signal_500Hz : std_logic;

begin
	  i_20Hz_clk : entity work.clockDivider
	  generic map(g_FREQ => 500)
	  port map (
				 i_clk   => clk ,
				 i_reset => '1' ,  
				 o_clk   => signal_500Hz,
				 o_tick  => open);
	  -------------------------------------------

    process(signal_500Hz)
    begin
        if rising_edge(signal_500Hz) then
            if( en = '1') then
                signal_step <= not signal_step;
                signal_dir <= dir_in;
            else
                signal_step <= '0';
                signal_dir <= '0';
            end if;
        end if;

    end process;


    dir_out <= signal_dir;
    step <= signal_step;


end architecture arch;
 