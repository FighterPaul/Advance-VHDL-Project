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
        K: in std_logic_vector(0 to 3):= (others => '0'); -- entrée de l'utilisateur ligne
        R: in std_logic_vector(0 to 3):= (others => '0'); -- entrée de l'utilisateur Colonne
        valider: in std_logic; -- entrée pour valider l'input
        conf: in std_logic; -- entrée pour configurer le mot de passe
        --et12: out std_logic; 
        GateOpen : out std_logic;-- sortie qui represente l'GateOpen de la porte
        Alarme : out std_logic;

        state_debug : out std_logic_vector(4 downto 0);
        ok_debug : out std_logic;
        clk10Hz_debug : out std_logic;
        counter_debug : out std_logic_vector(4 downto 0)
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



-- code initial est 0000 (r=k=1000)

signal ok :std_logic;

signal k1 : std_logic_vector(0 to 3):="1000";
signal k2 : std_logic_vector(0 to 3):="1000";
signal k3 : std_logic_vector(0 to 3):="1000";
signal k4 : std_logic_vector(0 to 3):="1000";

signal r1 : std_logic_vector(0 to 3):="1000";
signal r2 : std_logic_vector(0 to 3):="1000";
signal r3 : std_logic_vector(0 to 3):="1000";
signal r4 : std_logic_vector(0 to 3):="1000";

signal signal_column : std_logic_vector(0 to 3);
signal signal_row : std_logic_vector(0 to 3);

subtype entier is integer range 0 to 3; 
signal number_error: entier;-- nombre d'erreur successives


-- declaration d'un nouveau type state_type qui repesente une intervalle d'entiers entre 0 et 15
subtype state_type is integer range 0 to 32; 
signal state, next_state: state_type;


signal signal_clk_1Hz   : std_logic := '0';
signal counter     : integer := 0;
constant MAX_COUNT : integer := 3;

begin
-- place circuit

place_DIV20MHz_1Hz : DIV20MHz_1Hz
port map
(
    ClkIn => clk,
    ClkOut => signal_clk_1Hz
);

-- premier process pour determiner les states et les condition des transition d'un state a un autre
process(signal_clk_1Hz) 
    begin
		 case state is 
            when 0 => 
                ok <= '1';
                if (conf='1') then next_state<=12; 
                else
                    if (( signal_column /= "0000" ) and (signal_row /= "0000")) then -- si bouton est pressed 
                        if (( signal_column /= k1 ) and ( signal_row /= r1)) then  -- verifier code : si faux ok <= 0
                            ok <= '0';
                        end if;
                        next_state <= 1;
                        else next_state <= 0;
                    end if; 
                end if;
		 
		 --premier digit : attendre release du bouton 
		 when 1 =>
		 if (( signal_column = "0000" ) and ( signal_row = "0000" )) then
            if counter < MAX_COUNT then
                counter <= counter + 1;
            else 
                counter <= 0;
		        next_state <= 2;
            end if;
		 else 
		 	next_state <= 1;
		 end if;


		 -- attendre 2eme digit : s'il ya un input alors verifier si l'input est ok 
		 when 2 =>
		 if (( signal_column /= "0000" )and (signal_row /= "0000")) then -- si bouton est pressed 
                if counter < MAX_COUNT then
                    counter <= counter + 1;
                else 
                    counter <= 0;
                    if (( signal_column /= k2 ) and (signal_row /= r2)) then  -- verifier code : si faux ok <= 0
				        ok<='0';
				    end if;
                end if;
		    next_state <= 3;
		 else 
            next_state <= 2;
		 end if; 
		 
		 --2eme digit : attendre release du bouton 
		 when 3 => if (( signal_column ="0000" )and (signal_row ="0000")) then
		 next_state <= 4;
		 else next_state <= 3;
		 end if;


		 -- attendre 3eme digit : s'il ya un input alors verifier si l'input est ok 
		 when 4 => if (( signal_column /="0000" )and (signal_row /="0000")) then -- si bouton est pressed 
				if (( signal_column /= k3 )and (signal_row /= r3)) then  -- verifier code : si faux ok <= 0
				ok<='0';
				end if;
		 next_state <= 5;
		 else next_state <= 4;
		 end if; 
		 
		 --3eme digit : attendre release du bouton 
		 when 5 => if (( signal_column ="0000" )and (signal_row ="0000")) then
		 next_state <= 6;
		 else next_state <= 5;
		 end if;

		 -- attendre 4eme digit : s'il ya un input alors verifier si l'input est ok 
		 when 6 => if (( signal_column /="0000" )and (signal_row /="0000")) then -- si bouton est pressed 
				if (( signal_column /=k4 )and (signal_row /=r4)) then  -- verifier code : si faux ok <= 0
				ok<='0';
				end if;
		 next_state <= 7;
		 else next_state <= 6;
		 end if; 
		 
		 --4eme digit : attendre release du bouton 
		 when 7 => if (( signal_column ="0000" )and (signal_row ="0000")) then
		 next_state <= 8;
		 else next_state <= 7;
		 end if;
		 
		 
		 -- 8eme state attente du press du bouton valider
		 
		 when 8 => if (valider='1') then next_state <= 9;	 
		 else next_state <= 8;
		 end if;
		
		-- 9eme state attente du release du bouton valider
		 
		 when 9 => if (valider='0')then  -- si valider released 
				if (ok='1') then 
					number_error <=0; -- reset le nombre de fois d'erreurs
					next_state <= 10;  -- si code vrai et pas de changement de mot de passe par utilisateur alors etape d'GateOpen
				else 
				
				number_error <= number_error+1 after 150 ms;
				
				
				next_state <= 10; -- sinion yarja3 mil loul
				end if;
		 else next_state <= 9; -- si valider pressed on reste dans 9 cette etape
		 end if;
		 
		 -- 10eme state : GateOpen de la porte
		 
		  when 10 => 
            if counter < MAX_COUNT then
                counter <= counter + 1;
            else
                next_state <= 11;
                state <= 11;
                counter <= 0;
            end if;
		  
			--si on arrive ay dernier state on retourne a l'state initial d'attente d'un input d'utilisateur
  
		  when 11 => next_state<=0 ;
		  
		

		  when 12 => if (conf ='0') then
						next_state<=23; -- il faut que le bouton configuration soit ralaché pour changer le mot de passe
		             else next_state<=12;
						 end if;

		
----changement premier digit
			
			when 13 => 
							if (( K /="0000" )and (R /="0000")) then -- si un bouton est pressed 
								k1<=k; --affectation du 1er digit du nouveau password
								r1<=r;
								next_state <= 14;
							else next_state <= 13;
							end if; 
							
			when 14 => if (( K ="0000" )and (R ="0000")) then --attend relachement du bouton
		 next_state <= 15;
		 else next_state <= 14;
		 end if;

			when 15 => 
					if (( K /="0000" )and (R /="0000")) then -- si un bouton est pressed 
						k2<=k; --affectation du 1er digit du nouveau password
						r2<=r;
						next_state <= 16;
					else next_state <= 15;
					end if; 
					
		when 16 => if (( K ="0000" )and (R ="0000")) then --attend relachement du bouton
		 next_state <= 17;
		 else next_state <= 16;
		 end if;
						
		when 17 => 
				if (( K /="0000" )and (R /="0000")) then -- si un bouton est pressed 
					k3<=k; --affectation du 1er digit du nouveau password
					r3<=r;
					next_state <= 18;
				else next_state <= 17;
					end if; 
					
		when 18 => if (( K ="0000" )and (R ="0000")) then --attend relachement du bouton
		 next_state <= 19;
		 else next_state <= 18;
		 end if;
		 
		-- dernier digit				
		when 19 => 
				if (( K /="0000" )and (R /="0000")) then -- si un bouton est pressed 
					k4<=k; --affectation du 1er digit du nouveau password
					r4<=r;
					next_state <= 20;
				else next_state <= 19;
					end if; 
					
		when 20 => if (( K ="0000" )and (R ="0000")) then --attend relachement du bouton
		 next_state <= 21;
		 else next_state <= 20;
		 end if;
		 
		 -- Validation du nouveau mot de passe
		 
			 when 21 => if (valider='1') then next_state <= 22;	 
		 else next_state <= 21;
		 end if;	
		 
			when 22 => if (valider='0') then next_state <= 0;	 
		 else next_state <= 22;
		 end if;	



 when 23 =>	     	
				if (( K /="0000" )and (R /="0000")) then -- si bouton est pressed 
					if (( K /=k1 )and (R /=r1)) then  -- verifier code : si faux ok <= 0
					ok<='0';
				end if;
		 next_state <= 24;
		 else next_state <= 23;
		 end if; 

	 --premier digit : attendre release du bouton 
		 when 24 =>
		 if (( K ="0000" )and (R ="0000")) then
		 next_state <= 25;
		 else next_state <= 24;
		 end if;
		 
		 
		 	 -- attendre 2eme digit : s'il ya un input alors verifier si l'input est ok 
		 when 25 =>
		 if (( K /="0000" )and (R /="0000")) then -- si bouton est pressed 
				if (( K /=k2 )and (R /=r2)) then  -- verifier code : si faux ok <= 0
				ok<='0';
				end if;
		 next_state <= 26;
		 else next_state <= 25;
		 end if; 
		 
		 --2eme digit : attendre release du bouton 
		 when 26 => if (( K ="0000" )and (R ="0000")) then
		 next_state <= 27;
		 else next_state <= 26;
		 end if;


		 -- attendre 3eme digit : s'il ya un input alors verifier si l'input est ok 
		 when 27 => if (( K /="0000" )and (R /="0000")) then -- si bouton est pressed 
				if (( K /=k3 )and (R /=r3)) then  -- verifier code : si faux ok <= 0
				ok<='0';
				end if;
		 next_state <= 28;
		 else next_state <= 27;
		 end if; 
		 
		 --3eme digit : attendre release du bouton 
		 when 28 => if (( K ="0000" )and (R ="0000")) then
		 next_state <= 29;
		 else next_state <= 28;
		 end if;

		 -- attendre 4eme digit : s'il ya un input alors verifier si l'input est ok 
		 when 29 => if (( K /="0000" )and (R /="0000")) then -- si bouton est pressed 
				if (( K /=k4 )and (R /=r4)) then  -- verifier code : si faux ok <= 0
				ok<='0';
				end if;
		 next_state <= 30;
		 else next_state <= 29;
		 end if; 
		 
		 --4eme digit : attendre release du bouton 
		 when 30 => if (( K ="0000" )and (R ="0000")) then
		 next_state <= 31;
		 else next_state <= 30;
		 end if;
		 
		 
		 -- 8eme state attente du press du bouton valider
		 
		 when 31 => if (valider='1') then next_state <= 32;	 
		 else next_state <= 31;
		 end if;
		
		-- 9eme state attente du release du bouton valider
		 
		 when 32 => if (valider='0')then  -- si valider released 
				if (ok='1') then 
							
					number_error <=0; -- reset le nombre de fois d'erreurs
					next_state <= 13;  -- si code vrai et pas de changement de mot de passe par utilisateur alors etape d'GateOpen
				else 
				
				number_error <= number_error+1 after 300 ms;
				
				
				next_state <= 0; -- sinion yarja3 mil loul
				end if;
		 else next_state <= 32; -- si valider pressed on reste dans cette etape
		 end if;
	
	
	
		 end case;

    if rising_edge(clk) then
            state <= next_state;
    end if;

end process;

--process pour determiner les operation a faire pendant chaque state
process(state)
begin
    case state is
		when 0 to 9 =>  GateOpen <= '0';
		 								--et12<='1';
	        if (number_error <3) then alarme <='0';
			    else  alarme<='1';   
			end if;			
						
						
		when 10 to 11 => GateOpen <= '1';
		                  Alarme<='0';
								--et12<='0'; 
								
		when 12 to 32  => GateOpen <= '0';
		                  Alarme<='0';
								--et12<='0';


	
		 end case;
end process;
-- process qui represente un registre a decalage pour la transition de l'state n a l'state n+1
-- process(clk)
-- begin
-- 		 if rising_edge(clk) then
-- 		 state <= next_state;
--  end if;
-- end process;


signal_column <= K;
signal_row <= R;


------------------------------DEBUG zone--------------------------------------------------
state_debug <= std_logic_vector(to_unsigned(state, state_debug'length));
ok_debug <= ok;
clk10Hz_debug <= signal_clk_1Hz;
counter_debug <= std_logic_vector(to_unsigned(counter, counter_debug'length));
------------------------------DEBUG zone--------------------------------------------------


end Behavioral;