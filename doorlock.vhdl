-----------------------------------------------------------------------------------

-- Module Name:    SerrureDigitale - Behavioral 


library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use ieee.numeric_std.all;

--declaration de l'entité de la serrure numerique

entity SerrureTP4 is   
port(
        --fermer :in std_logic:='0';
        clk: in std_logic;  -- entrée du signal d'horloge 

		row: out std_logic_vector(3 downto 0);
		column: in std_logic_vector(3 downto 0);

		rst_pin : in std_logic;

        --et12: out std_logic; 
        GateOpen : out std_logic;-- sortie qui represente l'GateOpen de la porte
        Alarm : out std_logic;

        state_debug : out std_logic_vector(4 downto 0);
        ok_debug : out std_logic;
        clk1Hz_debug : out std_logic;
		keypad_debug : out std_logic_vector(7 downto 0);
		digit_1_ok_debug : out std_logic;
		digit_2_ok_debug : out std_logic;
		digit_3_ok_debug : out std_logic;
		digit_4_ok_debug : out std_logic
); 
end SerrureTP4;

architecture Behavioral of SerrureTP4 is


component DIV20MHz_1Hz 
port
(
    ClkIn : in  std_logic;   -- 20 MHz input clock
    ClkOut : out std_logic    -- 10 Hz output clock
);
end component;


component keypadInterface
port
(
	-- Inputs --
	i_clk    : in std_logic;
	i_reset  : in std_logic;
	i_columns : in std_logic_vector (3 downto 0);

	-- Outputs -- 
	o_rows : out std_logic_vector (3 downto 0);
	o_keyPressed_Char : out character;
	o_keyPressed_Byte : out std_logic_vector (7 downto 0)
);
end component;


------------------------SIGNAL IS CORRECT PASSWORD----------
signal ok :std_logic;
-------------------------------------------------------------





---------------------------CORRECT PASSWORD-----------------
constant CHAR_U	: std_logic_vector(7 downto 0) := "01010101";
constant CORRECT_DIGIT_1 : std_logic_vector(7 downto 0) := "00110100";
constant CORRECT_DIGIT_2 : std_logic_vector(7 downto 0) := "00110100";
constant CORRECT_DIGIT_3 : std_logic_vector(7 downto 0) := "00110100";
constant CORRECT_DIGIT_4 : std_logic_vector(7 downto 0) := "00110100";


signal signal_digit_ok : std_logic_vector(3 downto 0);


-------------------------------------------------------------



------------------ SIGNAL FROM KEYPAD MODULE---------------------
signal signal_byte_press : std_logic_vector(7 downto 0);
-------------------------------------------------------------

---------------------- Number of WORONG PASSWORD-------------------------
subtype entier is integer range 0 to 3; 
signal number_error: entier;
-------------------------------------------------------------


-------------------------SIGNAL CLOCK------------------------------------ 
signal signal_clk_1Hz   : std_logic := '0';
signal signal_clk_20MHz : std_logic := '0';

-------------------------------------------------------------


-------------------------- SIGNAL STATE -----------------------------
subtype state_type is integer range 0 to 32; 
signal state : state_type;
signal next_state : state_type;
--------------------------------------------------------------------


--------------------------- SIGNAL Counter----------------------------
signal counter     : integer := 0;
constant MAX_COUNT : integer := 3;
--------------------------------------------------------------------

begin

-- place circuit
place_DIV20MHz_1Hz : DIV20MHz_1Hz
port map
(
    ClkIn => clk,
    ClkOut => signal_clk_1Hz
);

place_keypadInterface : keypadInterface
port map
(
	-- Inputs --
	i_clk => clk,
	i_reset  => rst_pin,
	i_columns => column,

	-- Outputs -- 
	o_rows => row,
	o_keyPressed_Char => open,
	o_keyPressed_Byte => signal_byte_press
);



process(signal_byte_press) 
    begin
		case state is 

            when 0 => 

				ok <= '0';
				signal_digit_ok <= "0000";


				if(signal_byte_press /= CHAR_U) then
					next_state <= 0;
				else
					next_state <= 1;
				end if;



			when 1 =>
					if(signal_byte_press /= CHAR_U and signal_byte_press /= CORRECT_DIGIT_1) then
						signal_digit_ok(0) <= '0';
						next_state <= 2;
					elsif (signal_byte_press = CORRECT_DIGIT_1) then
						signal_digit_ok(0) <= '0';
						next_state <= 2;
					else
						next_state <= 1;
					end if;

					
			when 2 =>
				if (signal_byte_press = CHAR_U) then
					next_state <= 3;
				else
					if (signal_byte_press = CORRECT_DIGIT_1) then
						signal_digit_ok(0) <= '1';
					end if;
					next_state <= 2;
				end if;





			when 3 =>
				if(signal_byte_press /= CHAR_U and signal_byte_press /= CORRECT_DIGIT_2) then
					signal_digit_ok(1) <= '0';
					next_state <= 4;
				elsif (signal_byte_press = CORRECT_DIGIT_2) then
					signal_digit_ok(1) <= '1';
					next_state <= 4;
				else
					next_state <= 3;
				end if;
				
			when 4 =>
				if (signal_byte_press = CHAR_U) then
					next_state <= 5;
				else
					if (signal_byte_press = CORRECT_DIGIT_2) then
						signal_digit_ok(1) <= '1';
					end if;
					next_state <= 4;
				end if;






			when 5 =>
				if(signal_byte_press /= CHAR_U and signal_byte_press /= CORRECT_DIGIT_3) then
					signal_digit_ok(2) <= '0';
					next_state <= 6;
				elsif (signal_byte_press = CORRECT_DIGIT_3) then
					signal_digit_ok(2) <= '1';
					next_state <= 6;
				else
					next_state <= 5;
				end if;
		
			when 6 =>
				if (signal_byte_press = CHAR_U) then
					next_state <= 7;
				else
					if (signal_byte_press = CORRECT_DIGIT_3) then
						signal_digit_ok(2) <= '1';
					end if;
					next_state <= 6;
				end if;





			when 7 =>
				if(signal_byte_press /= CHAR_U and signal_byte_press /= CORRECT_DIGIT_4) then
					signal_digit_ok(3) <= '0';
					next_state <= 8;
				elsif (signal_byte_press = CORRECT_DIGIT_4) then
					signal_digit_ok(3) <= '1';
					next_state <= 8;
				else
					next_state <= 7;
				end if;
				
			when 8 =>
				if (signal_byte_press = CHAR_U) then
					next_state <= 9;
				else
				if (signal_byte_press = CORRECT_DIGIT_4) then
					signal_digit_ok(3) <= '1';
				end if;
					next_state <= 8;
				end if;




			when 9 =>
				next_state <= 0;
				
			when others =>
				next_state <= 0;
	
		 end case;
end process;

--process pour determiner les operation a faire pendant chaque state
process(state)
begin
    case state is
		   when 0 to 32 =>
		   		GateOpen <= '0';
				Alarm <= '0';
		-- when 0 to 9 =>  
		-- 	GateOpen <= '0';
	    --     if (number_error <3) then Alarm <='0';
		-- 	    else  Alarm<='1';   
		-- 	end if;			
						
						
		-- when 10 to 11 => GateOpen <= '1';
		--                   Alarm<='0';
		-- 						--et12<='0'; 
								
		-- when 12 to 32  => GateOpen <= '0';
		--                   Alarm<='0';
		-- 						--et12<='0';
	
		 end case;
end process;
-- process qui represente un registre a decalage pour la transition de l'state n a l'state n+1
process(signal_clk_1Hz)
begin
		if rising_edge(signal_clk_1Hz) then
		 	state <= next_state;
 		end if;
end process;





------------------------------DEBUG zone--------------------------------------------------
state_debug <= std_logic_vector(to_unsigned(state, state_debug'length));
ok_debug <= ok;
clk1Hz_debug <= signal_clk_1Hz;
keypad_debug <= signal_byte_press;
digit_1_ok_debug <= signal_digit_ok(0);
digit_2_ok_debug <= signal_digit_ok(1);
digit_3_ok_debug <= signal_digit_ok(2);
digit_4_ok_debug <= signal_digit_ok(3);
------------------------------DEBUG zone--------------------------------------------------


end Behavioral;