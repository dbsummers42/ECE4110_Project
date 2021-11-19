library IEEE;
use ieee.std_logic_1164.all;

entity sounds_controller is
	port (sound_effect : in integer range 0 to 10 := 0;
			max10_clk: IN STD_LOGIC;
			sound_trigger : in STD_LOGIC;
			sound_pin: OUT STD_LOGIC := '0');
end entity;

architecture sounds_controller_arch of sounds_controller is

	signal sound1_frequency : integer range 0 to 50000 := 50000;
	
begin
	
	
	sound : process (max10_clk) 
	variable play : STD_LOGIC := '1';
	variable frequency_count : integer range 0 to 50000 := 0;
	variable duration : integer := 0;
	variable sound_pin_tmp : STD_LOGIC := '0';
	variable sound_frequency : integer := 0;
	
	begin 
if (max10_clk'event and max10_clk = '1') then
	
	if (sound_effect = 1) then
	sound_frequency := sound1_frequency;
	end if;
	
	if (sound_trigger = '1') then
		--if (duration = 0) then
			play := '1';
			duration := 1;
			frequency_count := 0;
		--end if;
	end if;
	
	if (play = '1') then
		if (frequency_count < sound_frequency) then
			frequency_count := frequency_count + 1;
		else
			sound_pin_tmp := not sound_pin_tmp;
			sound_pin <= sound_pin_tmp;
			frequency_count := 0;
		end if;
	end if;
	
	if (play = '1') then
		if (duration < 50000000) then
			duration := duration + 1;
		else
			play := '0';
			frequency_count := 0;
			duration := 0;
		end if;
	end if;
end if;
	
	end process;
		
		
	

end architecture;