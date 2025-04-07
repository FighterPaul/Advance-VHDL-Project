----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date:    05:47:28 02/17/2025 
-- Design Name: 
-- Module Name:    ClockCount - Behavioral 
-- Project Name: 
-- Target Devices: 
-- Tool versions: 
-- Description: 
--
-- Dependencies: 
--
-- Revision: 
-- Revision 0.01 - File Created
-- Additional Comments: 
--
----------------------------------------------------------------------------------
library IEEE;
use IEEE.STD_LOGIC_1164.ALL;

-- Uncomment the following library declaration if using
-- arithmetic functions with Signed or Unsigned values
--use IEEE.NUMERIC_STD.ALL;

-- Uncomment the following library declaration if instantiating
-- any Xilinx primitives in this code.
--library UNISIM;
--use UNISIM.VComponents.all;

entity ClockCountV2 is
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
end ClockCountV2;

architecture Behavioral of ClockCountV2 is
    component Set_Time
    port
    (
        SetTime,
        HrTc,
        MinTc,
        SecTc,
        Clk1Hz : in std_logic;

        ClkHr,
        ClkMin,
        ClkSec : out std_logic
    );
    end component;

    component DIV20MHz_1Hz
    port
    (
        Clkin : in std_logic;
        ClkOut : out std_logic
    );
    end component;

    component Count_Hr
    port (
        Clk : in std_logic;


        Tc : out std_logic;

        Hr1,
        Hr2 : out std_logic_vector( 3 downto 0)
    );
    end component;

    component Count_min
    port (
        Clk : in std_logic;


        Tc : out std_logic;

        Min1,
        Min2 : out std_logic_vector( 3 downto 0)
    );
    end component;

    component Count_Sec
    port (
        Clk : in std_logic;


        Tc : out std_logic;

        Sec1,
        Sec2 : out std_logic_vector( 3 downto 0)
    );
    end Component;

    Component Selector
    port (
        Hr1,
        Hr2,
        Min1,
        Min2,
        Sec1,
        Sec2 : in std_logic_vector(3 downto 0);

        Mode : in std_logic;

        Digit1,
        Digit2,
        Digit3,
        Digit4 : out std_logic_vector(3 downto 0)
    );
    end Component;

    signal Clk1HzSig : std_logic;

    signal TcSig : std_logic_vector(2 downto 0) := "000";

    signal ClkHrSig : std_logic;
    signal ClkMinSig : std_logic;
    signal ClkSecSig : std_logic;
    
    signal Hr1Sig : std_logic_vector(3 downto 0);
    signal Hr2Sig : std_logic_vector(3 downto 0);
    signal Min1Sig : std_logic_vector(3 downto 0);
    signal Min2Sig : std_logic_vector(3 downto 0);
    signal Sec1Sig : std_logic_vector(3 downto 0);
    signal Sec2Sig : std_logic_vector(3 downto 0);



    signal signal_digit_1 : std_logic_vector(3 downto 0);
    signal signal_digit_2 : std_logic_vector(3 downto 0);
    signal signal_digit_3 : std_logic_vector(3 downto 0);
    signal signal_digit_4 : std_logic_vector(3 downto 0);

    
begin

    place_SET_TIME : SET_TIME
    port map
    (
        SetTime => SetTime,
        HrTc => TcSig(2),
        MinTc => TcSig(1),
        SecTc => TcSig(0),
        Clk1Hz => Clk1HzSig,

        ClkHr => ClkHrSig,
        ClkMin => ClkMinSig,
        ClkSec => ClkSecSig
    );

    place_DIV_FREQ : DIV20MHz_1Hz
    port map
    (
        ClkIn => Clk,
        ClkOut => Clk1HzSig
    );

    place_Count_Hr: Count_Hr
    port map
    (
        Clk => ClkHrSig,

        Tc => TcSig(2),

        Hr1 => Hr1Sig,
        Hr2 => Hr2Sig
    );

    place_Count_Min: Count_Min
    port map
    (
        Clk => ClkMinSig,

        Tc => TcSig(1),

        Min1 => Min1Sig,
        Min2 => Min2Sig
    );

    place_Count_Sec: Count_Sec
    port map
    (
        Clk => ClkSecSig,

        Tc => TcSig(0),

        Sec1 => Sec1Sig,
        Sec2 => Sec2Sig
    );

    place_Selector : Selector
    port map
    (
        Hr1 => Hr1Sig,
        Hr2 => Hr2Sig,
        Min1 => Min1Sig,
        Min2 => Min2Sig,
        Sec1 => Sec1Sig,
        Sec2 => Sec2Sig,

        Mode => ShowSec,

        Digit1 => signal_digit_1,
        Digit3 => signal_digit_2,
        Digit2 => signal_digit_3,
        Digit4 => signal_digit_4
    );


    Digit1 <= 
                X"30" when signal_digit_1 = "0000" else
                X"31" when signal_digit_1 = "0001" else
                X"32" when signal_digit_1 = "0010" else
                X"33" when signal_digit_1 = "0011" else
                X"34" when signal_digit_1 = "0100" else
                X"35" when signal_digit_1 = "0101" else
                X"36" when signal_digit_1 = "0110" else
                X"37" when signal_digit_1 = "0111" else
                X"38" when signal_digit_1 = "1000" else
                X"39" when signal_digit_1 = "1001" else
                X"3F";  -- fallback '?'

    Digit2 <= 
                X"30" when signal_digit_2 = "0000" else
                X"31" when signal_digit_2 = "0001" else
                X"32" when signal_digit_2 = "0010" else
                X"33" when signal_digit_2 = "0011" else
                X"34" when signal_digit_2 = "0100" else
                X"35" when signal_digit_2 = "0101" else
                X"36" when signal_digit_2 = "0110" else
                X"37" when signal_digit_2 = "0111" else
                X"38" when signal_digit_2 = "1000" else
                X"39" when signal_digit_2 = "1001" else
                X"3F";  -- fallback '?'


    Digit3 <= 
                X"30" when signal_digit_3 = "0000" else
                X"31" when signal_digit_3 = "0001" else
                X"32" when signal_digit_3 = "0010" else
                X"33" when signal_digit_3 = "0011" else
                X"34" when signal_digit_3 = "0100" else
                X"35" when signal_digit_3 = "0101" else
                X"36" when signal_digit_3 = "0110" else
                X"37" when signal_digit_3 = "0111" else
                X"38" when signal_digit_3 = "1000" else
                X"39" when signal_digit_3 = "1001" else
                X"3F";  -- fallback '?'


    Digit4 <= 
                X"30" when signal_digit_4 = "0000" else
                X"31" when signal_digit_4 = "0001" else
                X"32" when signal_digit_4 = "0010" else
                X"33" when signal_digit_4 = "0011" else
                X"34" when signal_digit_4 = "0100" else
                X"35" when signal_digit_4 = "0101" else
                X"36" when signal_digit_4 = "0110" else
                X"37" when signal_digit_4 = "0111" else
                X"38" when signal_digit_4 = "1000" else
                X"39" when signal_digit_4 = "1001" else
                X"3F";  -- fallback '?'




end Behavioral;