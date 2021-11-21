library IEEE;
use ieee.std_logic_1164.all;

entity sounds_controller is
	port (sound_effect : in integer range 0 to 10 := 0;
			max10_clk: IN STD_LOGIC;
			sound_trigger : in STD_LOGIC;
			sound_pin: OUT STD_LOGIC := '0');
end entity;

architecture sounds_controller_arch of sounds_controller is

	signal sound1_frequency : integer range 0 to 50000 := 50000; -- Sound 1 Start
	signal sound1_duration : integer range 0 to 30000000 := 30000000;
	signal sound2_duration : integer range 0 to 50000000:= 5000000;
	signal sound2_frequency : integer range 0 to 15000 := 15000;	-- Sound 2 destroy enemy
	signal sound3_frequency : integer range 0 to 50000 := 50000;	-- Sound 3 lose life
	signal sound3_duration: integer range 0 to 25000000 := 25000000;	
	signal sound4_frequency : integer range 0 to 30000 := 30000;	-- Sound 4 Shoot
	signal sound4_duration : integer range 0 to 14000000 := 14000000;
	signal sound5_frequency : integer range 0 to 50000 := 10000;	-- Sound 5 Game over
	signal sound5_duration : integer range 0 to 30000000 := 30000000;
	
begin
	
	
	sound : process (max10_clk) 
	variable play : STD_LOGIC := '1';
	variable frequency_count : integer range 0 to 50000 := 0;
	variable duration : integer := 0;
	variable sound_duration : integer := 0;
	variable sound_frequency : integer := 0;
	variable sound_pin_tmp : STD_LOGIC := '0';
	
	begin 
	if (max10_clk'event and max10_clk = '1') then
		
		if (sound_effect = 1) then
			sound_duration := sound1_duration;
			sound_frequency := sound1_frequency;
		elsif (sound_effect = 2) then
			sound_duration := sound2_duration;
			sound_frequency := sound2_frequency;
		elsif (sound_effect = 3) then
			sound_duration := sound3_duration;
			sound_frequency := sound3_frequency;
		elsif (sound_effect = 4) then
			sound_duration := sound4_duration;
			sound_frequency := sound4_frequency;
		elsif (sound_effect = 5) then
			sound_duration := sound5_duration;
			sound_frequency := sound5_frequency;
		end if;
		
		if (sound_effect = 1) then
			if ((duration >= sound_duration / 4) and (duration < sound_duration/ 2)) then
				sound_frequency := sound_frequency / 2;
			elsif (duration > sound_duration / 2) and (duration < sound_duration * 3 / 4) then
				sound_frequency := sound_frequency / 4;
			elsif (duration > sound_duration * 3 / 4) then
				sound_frequency := sound_frequency / 8;
			end if;
		elsif (sound_effect = 2) then
			if ((duration >= sound_duration / 3) and (duration < sound_duration * 2 / 3)) then
				sound_frequency := sound_frequency / 2;
			elsif (duration >= sound_duration * 2 / 3) then
				sound_frequency := sound_frequency / 2;
			end if;
		elsif (sound_effect = 3) then
			if (duration = sound_duration / 3) then
				frequency_count := 0;
			elsif (duration = sound_duration * 2 / 3) then
				frequency_count := 0;
			end if;
		elsif (sound_effect = 4) then
			if ((duration >= sound_duration / 4) and (duration < sound_duration/ 2)) then
				sound_frequency := sound_frequency + 10000;
			elsif (duration > sound_duration / 2) and (duration < sound_duration * 3 / 4) then
				sound_frequency := sound_frequency + 15000;
			elsif (duration > sound_duration * 3 / 4) then
				sound_frequency := sound_frequency + 20000;
			end if;
		elsif (sound_effect = 5) then
			if ((duration >= sound_duration / 4) and (duration < sound_duration/ 2)) then
				sound_frequency := sound_frequency + 15000;
			elsif (duration > sound_duration / 2) and (duration < sound_duration * 3 / 4) then
				sound_frequency := sound_frequency + 25000;
			elsif (duration > sound_duration * 3 / 4) then
				sound_frequency := sound_frequency + 30000;
			end if;
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
			if (duration < sound_duration) then
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