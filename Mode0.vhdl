----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date:    17:15:16 02/16/2025 
-- Design Name: 
-- Module Name:    Mode0 - Behavioral 
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

entity Mode0 is
    Port (
        HrTc, 
        MinTc,
        SecTc,
        En,
        Clk : in std_logic;
        
        ClkHr,
        ClkMin,
        ClkSec : out std_logic
    );
end Mode0;

architecture Behavioral of Mode0 is

begin
    ClkHr <= MinTc and En;
    ClkMin <= SecTc and En;
    ClkSec <= En and Clk;
end Behavioral;

