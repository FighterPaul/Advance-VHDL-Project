library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity MOD20MHzTo10Hz is
    port (
        clk_in_20MHz      : in  std_logic;   -- 20 MHz input clock
        clk_out_10Hz : out std_logic    -- 10 Hz output clock
    );
end entity;

architecture Behavioral of MOD20MHzTo10Hz is
    constant MAX_COUNT : integer := 1_000_000; -- toggle every 1 million cycles
    signal counter     : integer range 0 to MAX_COUNT := 0;
    signal clk_out     : std_logic := '0';
begin
    process(clk_in_20MHz)
    begin
        if rising_edge(clk) then
            if counter = MAX_COUNT - 1 then
                counter <= 0;
                clk_out <= not clk_out;
            else
                counter <= counter + 1;
            end if;
        end if;
    end process;

    clk_out_10Hz <= clk_out;
end architecture;