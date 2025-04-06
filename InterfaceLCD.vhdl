

library ieee;
use ieee.std_logic_1164.all;


entity InterfaceLCD is 
port
(
    clk : in std_logic;

    lcd_rw : out std_logic;
    lcd_rs : out std_logic;
    lcd_e : out std_logic;
    data_out : out std_logic_vector(7 downto 0)
);
end entity;


architecture arch of InterfaceLCD is

    type arr is array(1 to 21) of std_logic_vector(7 downto 0);
    constant data_rom : arr := (X"38", X"0C", X"06", X"01", X"C0", 
                            X"30", X"31", X"32", X"33", X"34", X"35", X"36", X"37", X"38", X"39",
                            X"41", X"42", X"43", X"44", X"45", X"46");
    
    signal en_timing : integer range 0 to 100000;

    signal data_pos : integer range 1 to 21;


begin

    process(clk)
    begin
        if rising_edge(clk) then
            en_timing <= en_timing + 1;
            if en_timing <= 50000 then
                lcd_e <= '1';
                data_out <= data_rom(data_pos);

            elsif (en_timing > 50000 and en_timing < 100000) then 
                lcd_e <= '0';


            elsif (en_timing = 100000) then
                en_timing <= 0;

            end if;


            if data_pos <= 5 then
                lcd_rw <= '0';
                lcd_rs <= '0';
            elsif data_pos > 5 then
                lcd_rw <= '0';
                lcd_rs <= '1';
            end if;

            if data_pos = 21 then
                data_pos <= 5;
            end if;
        end if;

    end process;


end architecture arch;



 