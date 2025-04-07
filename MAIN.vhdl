library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;


entity MainCirucit is 
port
(
    clk : in std_logic;

    row : out std_logic_vector(3 downto 0);
    col : in std_logic_vector(3 downto 0);


    dir_motor_out : out std_logic;
    step_motor_out : out std_logic;

    lcd_rw : out std_logic;
    lcd_rs : out std_logic;
    lcd_e : out std_logic;
    data_out : out std_logic_vector(7 downto 0);


-----------------------------FOR  CLOCK MODULE-----------------------
    ShowSec : in std_logic;
    SetTime : in std_logic;

    --  DUBUG Proposs----------------------------
    debug_byte_press : out std_logic_vector(7 downto 0)

);
end entity;


architecture arch of MainCirucit is

component ClockCountV2
port
(
    SetTime,
    ShowSec,
    Clk : in std_logic;

    Digit1,
    Digit2,
    Digit3,
    Digit4 : out std_logic_vector(7 downto 0)
);
end component;

component InterfaceLCD
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
end component;

component InterfaceStepperMotor
port
(
    clk : in std_logic;         -- 20MHz
    en : in std_logic;
    dir_in : in std_logic;

    dir_out: out std_logic;
    step: out std_logic
);
end component;


component InterfaceKeyPad
port
(
    clk : in  std_logic;		-- 20MHz
		
    row : out std_logic_vector(3 downto 0);		--
    col : in  std_logic_vector(3 downto 0);

    byte_out : out std_logic_vector(7 downto 0);		--
    pulse_out : out std_logic	
);
end component;


signal byte_press : std_logic_vector(7 downto 0);
signal clk_read_byte : std_logic;


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
constant ORIGINAL_CLK_HZ : integer := 20000000;



-----------------control stepper motor--------------------
signal signal_en_motor : std_logic := '0';
signal signal_dir_motor : std_logic := '0';

signal signal_is_door_open : std_logic := '0';




----------------------signal CLOCK CNT-----------------
signal signal_clock_d_1 : std_logic_vector(7 downto 0);
signal signal_clock_d_2 : std_logic_vector(7 downto 0);
signal signal_clock_d_3 : std_logic_vector(7 downto 0);
signal signal_clock_d_4 : std_logic_vector(7 downto 0);
-------------------------------------------------------



-- X"59",X"6F",X"75",X"20",X"50",X"72",X"65",X"73",X"73",X"20",X"41"
-- You Press A

begin

    place_ClockCountV2 : ClockCountV2
    port map
    (
        SetTime => SetTime,
        ShowSec => ShowSec,
        Clk => clk,

        Digit1 => signal_clock_d_1,
        Digit2 => signal_clock_d_3,
        Digit3 => signal_clock_d_2,
        Digit4 => signal_clock_d_4
    );

    place_InterfaceKeyPad : InterfaceKeyPad
    port map
    (
        clk => clk,
        row => row,
        col => col,

        byte_out => byte_press,
        pulse_out => clk_read_byte
    );



    place_InterfaceLCD : InterfaceLCD
    port map
    (
        clk => clk,
        byte_in => signal_byte_send,
    
        lcd_rw => lcd_rw,
        lcd_rs => lcd_rs,
        lcd_e  => lcd_e,
        data_out => data_out,

        clock_d_1 => signal_clock_d_1,
        clock_d_2 => signal_clock_d_3,
        clock_d_3 => signal_clock_d_2,
        clock_d_4 => signal_clock_d_4
    );

    place_InterfaceStepperMotor : InterfaceStepperMotor
    port map
    (
        clk => clk,
        en => signal_en_motor,
        dir_in => signal_dir_motor,
    
        dir_out => dir_motor_out,
        step => step_motor_out
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


    process(clk)
    begin 
            if rising_edge(clk) then
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

                    when 5 =>               -- wait for press '*'  
                        if(signal_current_byte_press = X"2A") then
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
                            signal_main_next_state <= 10;
                        else 
                            signal_main_next_state <= 8;
                        end if;

                    when 9 =>
                        if(count_2sec = 40000000) then 
                            signal_main_next_state <= 0;
                        else 
                            signal_main_next_state <= 9;
                        end if; 

                    when 10 =>
                        if signal_is_door_open = '0' then 
                            signal_main_next_state <= 0;
                        else
                            signal_main_next_state <= 10;
                        end if;

                    when others =>
                        signal_main_next_state <= 0;
                end case;
            end if;
        end process;


    process(clk)
    begin
        if rising_edge(clk) then
            signal_main_state <= signal_main_next_state;
        end if;
    end process;


    process(clk_read_byte)          -- process for first_digit press
    begin
        if rising_edge(clk_read_byte) then
            case(signal_main_state) is
                when 0 =>
                    press_fir_digit <= X"00";
                when 1 =>
                    if(byte_press /= X"55") then
                        press_fir_digit <= byte_press;
                    else
                        press_fir_digit <= press_fir_digit;
                    end if;
                when others =>
                        press_fir_digit <= press_fir_digit;
            end case;
        end if;
    end process;


    process(clk_read_byte)          -- process for second_digit press
    begin
        if rising_edge(clk_read_byte) then
            case(signal_main_state) is
                when 0 =>
                    press_sec_digit <= X"00";
                when 3 =>
                    if(byte_press /= X"55") then
                        press_sec_digit <= byte_press;
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
                when 0 | 1 =>
                    display_debug <= '0';
                when 2 | 3 =>
                    display_debug <= '0';
                when 4 =>
                    display_debug <= '0';
                when 5 | 6 | 7 =>
                    display_debug <= '0';
                when 8 | 9 => 
                    display_debug <= '0';
                when others =>
                    display_debug <= '0';
            end case;
        end if;
    end process;

    process(clk)        -- process sentence_display

    -- Initial ...
    -- X"49" & X"6E" & X"69" & X"74" & X"69" & X"61" & X"6C" & X"20" & X"2E" & X"2E" & X"2E" & X"20" & X"20" & X"20" & X"20" & X"20"
    -- Enter Password  
    -- X"45" & X"6E" & X"74" & X"65" & X"72" & X"20" & X"50" & X"61" & X"73" & X"73" & X"77" & X"6F" & X"72" & X"64" & X"20" & X"20"
    -- welcome
    -- x"57" & x"65" & x"6C" & x"63" & x"6F" 
    -- & x"6D" & x"65" & X"20" & X"20" & X"20"
    -- & X"01" & X"20" & X"20" & X"20" & X"20"
    -- & X"20"

    begin
        if rising_edge(clk) then

            case(signal_main_state) is
                when 0 =>
                    sentence_display <= X"49" & X"6E" & X"69" & X"74" & X"69" 
                                        & X"61" & X"6C" & X"20" & X"2E" & X"2E" 
                                        & X"2E" & X"20" & X"20" & X"20" & X"20" 
                                        & X"20";
                when 1 =>
                    sentence_display <= signal_clock_d_1 & signal_clock_d_2 & X"3A" & signal_clock_d_3 & signal_clock_d_4 
                                        & X"20" & X"20" & X"20" & X"20" & X"20"
                                        & X"00" & X"20" & X"20" & X"20" & X"20"
                                        & X"20";
                when 2 =>
                    sentence_display <= press_fir_digit & X"20" & X"20" & X"20" & X"20" 
                                        & X"20" & X"20" & X"20" & X"20" & X"20"
                                        & X"20" & X"20" & X"20" & X"20" & X"20"
                                        & X"20";
                when 3 =>
                    sentence_display <= press_fir_digit & X"20" & X"20" & X"20" & X"20" 
                                        & X"20" & X"20" & X"20" & X"20" & X"20"
                                        & X"20" & X"20" & X"20" & X"20" & X"20"
                                        & X"20";
                when 4 =>
                    sentence_display <= press_fir_digit & press_sec_digit & X"20" & X"20" & X"20" 
                                        & X"20" & X"20" & X"20" & X"20" & X"20"
                                        & X"20" & X"20" & X"20" & X"20" & X"20"
                                        & X"20";
                when 5 | 6 | 7 =>
                    sentence_display <= press_fir_digit & press_sec_digit & X"20" & X"20" & X"20" 
                                        & X"20" & X"20" & X"20" & X"20" & X"20"
                                        & X"20" & X"20" & X"20" & X"20" & X"20"
                                        & X"20";
                
                when 8 => 
                    sentence_display <= x"57" & x"65" & x"6C" & x"63" & x"6F" 
                                        & x"6D" & x"65" & X"20" & X"20" & X"20"
                                        & X"01" & X"20" & X"20" & X"20" & X"20"
                                        & X"20";
                when 9 =>
                    sentence_display <= X"57" & X"52" & X"4F" & X"4E" & X"47"
                                        & X"20" & X"20" & X"20" & X"20" & X"20"
                                        & X"20" & X"20" & X"20" & X"20" & X"20"
                                        & X"20";

                when others =>
                    sentence_display <= X"20" & X"20" & X"20" & X"20" & X"20"
                                        & X"20" & X"20" & X"20" & X"20" & X"20"
                                        & X"20" & X"20" & X"20" & X"20" & X"20"
                                        & X"20";
            end case;
        end if;
    end process;


    process(clk)                -- process for count_2sec
    begin
        if rising_edge(clk) then
            case(signal_main_state) is
                when 8 | 9 => 
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


    process(clk)
        variable count_open_50_clk : integer range 0 to 4000000 := 0;            -- make stepper motor rotate 90 deg
        variable count_close_50_clk : integer range 0 to 4000000 := 0;            -- make stepper motor rotate 90 deg

    begin
        if rising_edge(clk) then
            case(signal_main_state) is
                when 8 =>
                    if count_open_50_clk < 4000000 then
                        signal_dir_motor <= '1';
                        signal_en_motor <= '1';
                        count_open_50_clk := count_open_50_clk + 1;
                        signal_is_door_open <= '1';   -- DOOR  OPEN !!!
                    else
                        signal_dir_motor <= '0';
                        signal_en_motor <= '0';
                        count_open_50_clk := count_open_50_clk;
                        signal_is_door_open <= '1';     -- DOOR  OPEN !!!
                    end if;
                
                when 10 =>
                    if count_close_50_clk < 4000000 then
                        signal_dir_motor <= '0';
                        signal_en_motor <= '1';
                        count_close_50_clk := count_close_50_clk + 1;
                        signal_is_door_open <= '1';         -- DOOR STILL OPEN !!!
                    else
                        signal_dir_motor <= '0';
                        signal_en_motor <= '0';
                        count_close_50_clk := count_close_50_clk;
                        signal_is_door_open <= '0';         -- DOOR CLOSE!!
                    end if;
                when others =>
                    signal_dir_motor <= '0';
                    signal_en_motor <= '0';
                    count_open_50_clk := 0;
                    count_close_50_clk := 0;
                    signal_is_door_open <= '0';         -- DOOR CLOSE

            end case;
        end if;
    end process;


    debug_byte_press <= signal_current_byte_press;
            

end architecture arch;
            


