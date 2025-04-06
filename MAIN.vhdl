library ieee;
use ieee.std_logic_1164.all;


entity MainCirucit is 
port
(
    clk : in std_logic;


    -- byte_press : in std_logic_vector(7 downto)

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
signal count_clk : integer range 0 to 20000000 := 0;


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

    process(clk)
    begin
        case (count_clk) is
            when 0 to 10000000 =>
                signal_byte_send <= X"30" & X"31" & X"32" & X"33" & X"34" & X"35" & X"36" & X"37" & X"38" & X"39"
                                    & X"41" & X"42" & X"20" & X"20" & X"20" & X"20";

            when others =>
                signal_byte_send <= X"30" & X"31" & X"32" & X"33" & X"34" & X"35" & X"36" & X"37" & X"38" & X"39"
                                    & X"30" & X"31" & X"32" & X"33" & X"34" & X"35";
        end case;
    end process;



    process(clk)
    begin
        if rising_edge(clk) then
            if count_clk = 20000000 then
                count_clk <= 0;
            else
                count_clk <= count_clk + 1;
            end if;
        end if;
    end process;

end architecture arch;
            

