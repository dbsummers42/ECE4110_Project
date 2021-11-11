library IEEE;
use ieee.std_logic_1164.all;

entity sounds is
	port (sound_effect : inout integer range 0 to 10 := 0;
			max10_clk : IN STD_LOGIC;
			sound_pin : OUT STD_LOGIC);
end entity;

architecture sounds_arch of sounds is
	
signal frequency, sound_effect_temp : integer range 0 to 50000 := 0; 
signal sound_duration : integer := 0;
signal sound_pin_tmp : STD_LOGIC := '0';
signal play : STD_LOGIC := '0';

begin

	sound : process (max10_clk) begin 
	
		if (sound_effect /= 0) then
			if (sound_effect = 1) then
				if (sound_duration <= 50000000) then
					if (sound_effect_temp = 1) then
						if (frequency <= 3333) then
							frequency <= frequency + 1;
						else
							frequency <= 0;
							sound_pin_tmp <= not sound_pin_tmp;
							sound_pin <= sound_pin_tmp;
						end if;
						sound_duration <= sound_duration + 1;
					else
						sound_duration <= 0;
						sound_effect_temp <= 0;
						play <= '0';
						sound_effect <= 0;
					end if;
				end if;
			end if;
		end if;
	end process;
	

	
end architecture;