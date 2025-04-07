

library ieee;
use ieee.std_logic_1164.all;


entity InterfaceLCD is 
port
(
    clk : in std_logic;

    byte_in : in std_logic_vector(127 downto 0);

    lcd_rw : out std_logic;
    lcd_rs : out std_logic;
    lcd_e : out std_logic;
    data_out : out std_logic_vector(7 downto 0);


    clock_d_1 : in  std_logic_vector(7 downto 0);
    clock_d_2 : in  std_logic_vector(7 downto 0);
    clock_d_3 : in  std_logic_vector(7 downto 0);
    clock_d_4 : in  std_logic_vector(7 downto 0)
);
end entity;


architecture arch of InterfaceLCD is

    type arr_command is array(1 to 6) of std_logic_vector(7 downto 0);
    constant command_rom : arr_command := (X"38", X"0E", X"06", X"01", X"C0", X"C0");



    type arr_char is array(1 to 16) of std_logic_vector(7 downto 0);


    type arr_icon is array(1 to 8) of std_logic_vector(7 downto 0);
    
    signal en_timing : integer range 0 to 100000 := 0;

    signal command_pos : integer range 1 to 6 := 1;
    signal byte_pos : integer range 1 to 17 := 1;

    signal state : integer range 1 to 59 := 1;


    signal arr_line_clock : std_logic_vector(127 downto 0) := X"59" & X"6F" & X"75" & X"20" & X"50"
                                    & X"72" & X"65" & X"73" & X"73" & X"20"
                                    & X"72" & X"20" & X"20" & X"20" & X"20"
                                    & X"20";


    constant lock_icon : arr_icon := 
    (
    X"04",
    X"0A",
    X"11",
    X"11",
    X"1F",
    X"1F",
    X"1B",
    X"1F"
    );

    constant unlock_icon : arr_icon := 
    (
        X"1F",
        X"10",
        X"10",
        X"10",
        X"1F",
        X"1F",
        X"1B",
        X"1F"
    );


begin

    arr_line_clock <= clock_d_1 & clock_d_2 & X"20" & clock_d_3 & clock_d_4 
                & X"20" & X"20" & X"20" & X"20" & X"20"
                & X"00" & X"20" & X"20" & X"20" & X"20"
                & X"20";

    process(clk)
    
    begin
        if rising_edge(clk) then
            en_timing <= en_timing + 1;

            if en_timing <= 10000 then
                lcd_e <= '0';
            elsif en_timing <= 50000 then
                lcd_e <= '1';

            elsif (en_timing > 50000 and en_timing < 100000) then 
                lcd_e <= '0';

            elsif (en_timing = 100000) then
                en_timing <= 0;
				state <= state + 1;

                if(state <= 5) then
                    command_pos <= command_pos + 1;
                    
                elsif (state >= 24 and state <= 40) then
                    byte_pos <= byte_pos + 1;
                end if;
                
                if (state = 59) then
                    command_pos <= 5;
                    byte_pos <= 1;
                    state <= 23;
                end if;

            end if;


            if state <= 5 then      -- send command
                lcd_rw <= '0';
                lcd_rs <= '0';

                data_out <= command_rom(command_pos);

---------------------------------------------------------------------
            elsif state = 6  then           -- direct to CG ram
                lcd_rw <= '0';
                lcd_rs <= '0';
                data_out <= "01000000";
            elsif state >= 7 and state <= 14 then
                lcd_rs <= '1';
                lcd_rw <= '0';
                data_out <= lock_icon(state - 7 + 1);

            elsif state >= 15 and state <= 22 then
                lcd_rs <= '1';
                lcd_rw <= '0';
                data_out <= unlock_icon(state - 15 + 1);

            elsif state = 23 then     -- go to second line
                lcd_rw <= '0';
                lcd_rs <= '0';
                data_out <= X"C0";

            elsif state >= 24 then    -- send data
                lcd_rw <= '0';
                lcd_rs <= '1';
                
                data_out <= byte_in( 136 - (8*byte_pos) - 1  downto  136 - (8*byte_pos)- 8 );

            elsif state = 41 then  -- go to return home
                lcd_rw <= '0';
                lcd_rs <= '0';
                data_out <= "00000010";


            elsif state = 42 then  -- set cursor to first line
                lcd_rw <= '0';
                lcd_rs <= '0';
                data_out <= "10000000";
            
            elsif state >= 43 and state <= 57 then 
                data_out <= arr_line_clock(136 - (8*(state - 43 + 1)) - 1 downto 136 - (8*(state - 43 + 1)) - 8);

            end if;

        end if;

    end process;


end architecture arch;



 