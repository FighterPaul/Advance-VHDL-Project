library ieee;
use ieee.std_logic_1164.all;
use IEEE.STD_LOGIC_UNSIGNED.all;


entity InterfaceKeyPad is
Port (
		clk : in  std_logic;		-- 20MHz
		
		row : out std_logic_vector(3 downto 0);		--
		col : in  std_logic_vector(3 downto 0);

		byte_out : out std_logic_vector(7 downto 0);		--
		pulse_out : out std_logic			--

	);
end entity InterfaceKeyPad;

architecture arch of InterfaceKeyPad is

	signal state : integer range 0 to 8 := 0;				--

	signal index_row_scan : integer range 0 to 3 := 0;		--
	signal cnt_no_press : integer range 0 to 100_000 := 0;	--
	signal col_last : std_logic_vector(3 downto 0);		--
	signal cnt_press : integer range 0 to 50_000 := 0; 		--


	signal signal_row : std_logic_vector(3 downto 0);
	signal signal_byte_out : std_logic_vector(7 downto 0) := "00000000";


  begin

	process(clk, state)		-- state
		begin
			if rising_edge(clk) then

				case(state) is
					when 0 =>
						if(cnt_no_press = 100_000) then		-- SURE that user dont press anything?
							state <= 7;
						else
							state <= 1;
						end if;

					when 1 =>
						if(col /= "0000") then 		-- check press some button is the row?
							state <= 2;
						else
							state <= 0;
						end if;

					when 2 =>
						if(cnt_press = 50_000) then		-- Cnt time to re-scan for prevent debouce
							state <= 3;
						else
							state <= 2;
						end if;
					

					when 3 => 
						if(col = col_last) then			-- rescan and check that still press?
							state <= 4;
						else
							state <= 0;
						end if;
					
					when 4 =>
						if(cnt_press = 50_000) then 		-- Cnt time to re-scan for prevent debouce
							state <= 5;
						else
							state <= 4;
						end if;

					when 5 =>
						if(col = col_last) then			-- rescan and check that still press?
							state <= 6;
						else
							state <= 0;
						end if;
					
					when 6 =>					-- send Byte out  and pulse
						state <= 8;

					when 7 =>					-- send Byte 'U' out  and pulse
						state <= 8;
					
					when 8 =>					-- hold send Byte and pulse
						state <= 0;

					when others =>
						state <= 0;

				end case;
			end if;
	end process;


	process(clk, state)		-- cnt_no_press
		begin
			if rising_edge(clk) then
				case(state) is
					when 1 =>
						if(col = "0000") then
							cnt_no_press <= cnt_no_press + 1;
						else
							cnt_no_press <= 0;
						end if;

					when 7 =>
						cnt_no_press <= 0;

					when others => 
						cnt_no_press <= cnt_no_press;
				end case;
			end if;
	end process;




	process(clk, state)		-- index_row_scan
	begin
		if rising_edge(clk) then
			case(state) is
				when 1 =>
					if(col = "0000") then
						if index_row_scan = 3 then
							index_row_scan <= 0;
						else
							index_row_scan <= index_row_scan + 1;
						end if;
					end if;

				when others => 
					index_row_scan <= index_row_scan;
			end case;
		end if;
	end process;


	process(clk, state)		-- col_last
	begin
		if rising_edge(clk) then
			case(state) is
				when 1 | 3 =>
					if(col /= "0000") then
						col_last <= col;
					end if;

				when others => 
					col_last <= col_last;
			end case;
		end if;
	end process;
  
	process(clk, state)		-- cnt_press
	begin
		if rising_edge(clk) then
			case(state) is
				when 2 | 4 =>
					if(cnt_press < 50_000) then
						cnt_press <= cnt_press + 1;
					else
						cnt_press <= cnt_press;
					end if;

				when 3 | 5 =>
					cnt_press <= 0;

				when others => 
						cnt_press <= cnt_press;
			end case;
		end if;
	end process;
  

	process(clk, state)		-- signal_row
	    variable temp_row : std_logic_vector(3 downto 0) := "0000";
	begin
		if rising_edge(clk) then
			case(state) is
				when 0 =>
					temp_row := "0000";
					temp_row(index_row_scan) := '1';
					signal_row <= temp_row;
				when others =>
					signal_row <= signal_row;
			end case;
		end if;
	end process;

	process(clk, state)		-- signal_byte_out
	begin
		if rising_edge(clk) then
			case(state) is
				when 6  => 
					case(index_row_scan) is
						when 0 =>
							if col_last = "0001" then
								signal_byte_out <= X"31";
							elsif col_last = "0010" then
								signal_byte_out <= X"32";
							elsif col_last = "0100" then
								signal_byte_out <= X"33";
							else
								signal_byte_out <= X"41";
							end if;
						when 1 =>
							if col_last = "0001" then
								signal_byte_out <= X"34";
							elsif col_last = "0010" then
								signal_byte_out <= X"35";
							elsif col_last = "0100" then
								signal_byte_out <= X"36";
							else
								signal_byte_out <= X"42";
							end if;

						when 2 =>
							if col_last = "0001" then
								signal_byte_out <= X"37";
							elsif col_last = "0010" then
								signal_byte_out <= X"38";
							elsif col_last = "0100" then
								signal_byte_out <= X"39";
							else
								signal_byte_out <= X"43";
							end if;

						when 3 =>
							if col_last = "0001" then
								signal_byte_out <= X"2A";
							elsif col_last = "0010" then
								signal_byte_out <= X"30";
							elsif col_last = "0100" then
								signal_byte_out <= X"23";
							else
								signal_byte_out <= X"44";
							end if;
					end case;

				when 7 =>
					signal_byte_out <= X"55";

				when others =>
					signal_byte_out <= signal_byte_out; 	

			end case;
		end if;
	end process;
  
	process(clk, state)		-- pulse_out
	begin
		if rising_edge(clk) then
			case(state) is
				when 8 =>
					pulse_out <= '1';
				when others => 
					pulse_out <= '0';
			end case;
		end if;
	end process;


	
	row <= signal_row;
	byte_out <= signal_byte_out;
  
end architecture arch;
  