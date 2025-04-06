library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;


entity MainCirucit is 
port
(
    clk : in std_logic;

    byte_press : in std_logic_vector(7 downto 0);
    clk_read_byte : in std_logic;

    lcd_rw : out std_logic;
    lcd_rs : out std_logic;
    lcd_e : out std_logic;
    data_out : out std_logic_vector(7 downto 0)

);
end entity;


architecture arch of MainCirucit is

component InterfaceLCD
port
(
    clk : in std_logic;
    byte_in : in std_logic_vector(127 downto 0);

    lcd_rw : out std_logic;
    lcd_rs : out std_logic;
    lcd_e : out std_logic;
    data_out : out std_logic_vector(7 downto 0)
);
end component;


signal signal_byte_send : std_logic_vector(127 downto 0);
signal count_clk : integer range 0 to 40000000 := 0;
signal signal_current_byte_press : std_logic_vector(7 downto 0);

signal signal_main_state : integer range 0 to 10 := 0;
signal signal_main_next_state : integer range 0 to 10 := 0;


signal press_fir_digit : std_logic_vector(7 downto 0);
signal press_sec_digit : std_logic_vector(7 downto 0);

constant CORRECT_FIR_DIGIT : std_logic_vector(7 downto 0) := X"32";
constant CORRECT_SEC_DIGIT : std_logic_vector(7 downto 0) := X"35";


signal display_debug : std_logic := '1';
signal sentence_display : std_logic_vector(127 downto 0);


signal count_2sec : integer range 0 to 40000000 := 0;
constant ORIGINAL_CLK_HZ : integer := 20000000




-- X"59",X"6F",X"75",X"20",X"50",X"72",X"65",X"73",X"73",X"20",X"41"
-- You Press A

begin

    place_InterfaceLCD : InterfaceLCD
    port map
    (
        clk => clk,
        byte_in => signal_byte_send,
    
        lcd_rw => lcd_rw,
        lcd_rs => lcd_rs,
        lcd_e  => lcd_e,
        data_out => data_out
    );


    -- X"4D" & X"41" & X"49" & X"4E" & X"20" & X"53" & X"54" & X"41" & X"54" & X"45" & X"20"
    -- -- MAIN STATE 

    -- X"50"  & X"72" & X"65" & X"73" & X"73" & X"20" & X"46" & X"69" & X"72" & X"20" & X"44" & X"69" & X"20" & X"20"
    -- Press Fir Di  

    -- X"50" & X"72" & X"65" & X"73" & X"73" & X"20" & X"53" & X"65" & X"63" & X"20" & X"44" & X"69" & X"20" & X"20"
    --Press Sec Di  


    -- X"57" & X"52" & X"4F" & X"4E" & X"47" & X"20" & X"20" & X"20" & X"20" & X"20" & X"20" & X"20" & X"20" & X"20" & X"20" & X"20"
    -- WRONG

    --COR
    process(clk)
    begin
        if display_debug = '1' then
            case (count_clk) is
                when 0 to 10000000 =>
                    signal_byte_send <= X"59" & X"6F" & X"75" & X"20" & X"50"
                                    & X"72" & X"65" & X"73" & X"73" & X"20"
                                    & signal_current_byte_press & X"20" & X"20" & X"20" & X"20"
                                    & X"20";

                when 10000001 to 20000000 =>
                    signal_byte_send <= X"4D" & X"41" & X"49" & X"4E" & X"20" 
                                        & X"53" & X"54" & X"41" & X"54" & X"45" 
                                        & X"20" & std_logic_vector(to_unsigned(signal_main_state + 48, 8)) & X"20" & X"20" & X"20"
                                        & X"20";

                when 20000001 to 30000000 => 
                    signal_byte_send <= X"50"  & X"72" & X"65" & X"73" & X"73" 
                                        & X"20" & X"46" & X"69" & X"72" & X"20" 
                                        & X"44" & X"69" & X"20" & X"20" & press_fir_digit
                                        & X"20";

                when others =>
                    signal_byte_send <= X"50" & X"72" & X"65" & X"73" & X"73" 
                                        & X"20" & X"53" & X"65" & X"63" & X"20" 
                                        & X"44" & X"69" & X"20" & X"20" & press_sec_digit
                                        & X"20";
                    
            end case;
        else
            signal_byte_send <= sentence_display;
        end if;


    end process;


    process(clk)
    begin
        if rising_edge(clk) then
            if count_clk = 40000000 then
                count_clk <= 0;
            else
                count_clk <= count_clk + 1;
            end if;
        end if;
    end process;


    process(clk_read_byte)
    begin
        if rising_edge(clk_read_byte) then
            signal_current_byte_press <= byte_press;
        end if;
    end process;


    process(signal_current_byte_press)
    begin 
            case (signal_main_state) is

                when 0 =>                       -- state reset everything

                    if (signal_current_byte_press = X"55") then        -- wait for unpress   ->  go to state 1
                        signal_main_next_state <= 1;
                    else
                        signal_main_next_state <= 0;
                    end if;
                
                when 1 =>                       -- wait for press first digit

                    if(signal_current_byte_press /= X"55") then        -- if user press some but -> go to state 2
                        signal_main_next_state <= 2;
                    else
                    
                        signal_main_next_state <= 1;
                    end if;

                when 2 =>
                    if (signal_current_byte_press = X"55") then        -- wait for unpress 'U'  ->  go to state 1
                        signal_main_next_state <= 3;
                    else
                        signal_main_next_state <= 2;
                    end if;

                when 3 =>                       -- wait for press second digit

                    if(signal_current_byte_press /= X"55") then        -- if user press some but -> go to state 2
                        signal_main_next_state <= 4;
                    else
                        signal_main_next_state <= 3;
                    end if;


                when 4 =>                       -- wait for unpress 'U'
                    if (signal_current_byte_press = X"55") then        -- wait for unpress 'U'  ->  go to state 1
                        signal_main_next_state <= 5;
                    else
                        signal_main_next_state <= 4;
                    end if;

                when 5 =>               -- wait for press 'u'  "01110101"
                    if(signal_current_byte_press = X"75") then
                        signal_main_next_state <= 6;
                    else
                        signal_main_next_state <= 5;
                    end if;

                when 6 =>                   -- wait for unpress 'U'
                    if(signal_current_byte_press = X"55") then
                        signal_main_next_state <= 7;
                    else
                        signal_main_next_state <= 6;
                    end if;
                
                when 7 =>
                    if (press_fir_digit = CORRECT_FIR_DIGIT and press_sec_digit = CORRECT_SEC_DIGIT) then
                        signal_main_next_state <= 8;
                    else
                        signal_main_next_state <= 9;
                    end if;

                when 8 =>
                    if(count_2sec = 40000000) then 
                        signal_main_next_state <= 0;
                    else 
                        signal_main_next_state <= 8;
                    end if;

                when 9 =>
                    if(count_2sec = 40000000) then 
                        signal_main_next_state <= 0;
                    else 
                        signal_main_next_state <= 9;
                    end if; 

                when others =>
                    signal_main_next_state <= 0;
            end case;
        end process;


    process(clk)
    begin
        if rising_edge(clk) then
            signal_main_state <= signal_main_next_state;
        end if;
    end process;


    process(clk)          -- process for first_digit press
    begin
        if rising_edge(clk) then
            case(signal_main_state) is
                when 0 =>
                    press_fir_digit <= X"00";
                when 1 =>
                    if(signal_current_byte_press /= X"55") then
                        press_fir_digit <= signal_current_byte_press;
                    else
                        press_fir_digit <= press_fir_digit;
                    end if;
                when others =>
                        press_fir_digit <= press_fir_digit;
            end case;
        end if;
    end process;


    process(clk)          -- process for second_digit press
    begin
        if rising_edge(clk) then
            case(signal_main_state) is
                when 0 =>
                    press_sec_digit <= X"00";
                when 3 =>
                    if(signal_current_byte_press /= X"55") then
                        press_sec_digit <= signal_current_byte_press;
                    else
                        press_sec_digit <= press_sec_digit;
                    end if;
                when others =>
                        press_sec_digit <= press_sec_digit;
            end case;
        end if;
    end process;

    process(clk)              -- process display_debug
    begin
        if rising_edge(clk) then

            case(signal_main_state) is
                when 8 | 9 => 
                    display_debug <= '0';
                when others =>
                    display_debug <= '1';
            end case;
        end if;
    end process;

    process(clk)        -- process sentence_display
    begin
        if rising_edge(clk) then

            case(signal_main_state) is
                when 8 => 
                    sentence_display <= X"43" & X"4F" & X"52" & X"20" & X"20"
                                        & X"20" & X"20" & X"20" & X"20" & X"20"
                                        & X"20" & X"20" & X"20" & X"20" & X"20"
                                        & X"20";
                when 9 =>
                    sentence_display <= X"57" & X"52" & X"4F" & X"4E" & X"47"
                                        & X"20" & X"20" & X"20" & X"20" & X"20"
                                        & X"20" & X"20" & X"20" & X"20" & X"20"
                                        & X"20";

                when others =>
                    sentence_display <= X"57" & X"57" & X"57" & X"57" & X"57"
                                        & X"57" & X"57" & X"57" & X"57" & X"57"
                                        & X"57" & X"57" & X"57" & X"57" & X"57"
                                        & X"57";
            end case;
        end if;
    end process;


    process(clk)
    begin
        if rising_edge(clk) then
            case(signal_main_state) is
                when 8 | 9=> 
                    if(count_2sec = 40000000) then
                        count_2sec <= count_2sec;
                    else
                        count_2sec <= count_2sec + 1;
                    end if;
                when others =>
                    count_2sec <= 0;
            end case;
        end if;
    end process;
            

end architecture arch;
            

