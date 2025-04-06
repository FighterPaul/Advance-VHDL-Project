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

    process(clk)
    begin
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
                        press_fir_digit <= signal_current_byte_press;
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
                        press_sec_digit <= signal_current_byte_press;
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
                    signal_main_next_state <= 8;
                    
                when 9 =>
                    signal_main_next_state <= 9;
                        

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


            

end architecture arch;
            

