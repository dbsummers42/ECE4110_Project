library   ieee;
use       ieee.std_logic_1164.all;
use 		 ieee.numeric_std.all; 
library work;
use 		 work.my_types.all;

package my_types is 
	type array3 is array (0 to 2) of integer range -100 to 1000;
	type array7 is array (0 to 6) of integer range -100 to 1000;
	type array10 is array (0 to 9) of integer range -100 to 1000;
	type array13 is array (0 to 12) of integer range -100 to 1000;
	type array20 is array (0 to 19) of integer range -100 to 1000;
end package;

library   ieee;
use       ieee.std_logic_1164.all;
use 		 ieee.numeric_std.all; 
library work;
use 		 work.my_types.all;

entity PROJ0 is
	
	port(
	
		-- Inputs for image generation
		
		pixel_clk_m		:	IN	STD_LOGIC;     -- pixel clock for VGA mode being used 
		
		-- Outputs for image generation 
		
		h_sync_m		:	OUT	STD_LOGIC;	--horiztonal sync pulse
		v_sync_m		:	OUT	STD_LOGIC;	--vertical sync pulse 
		
		red_m      :  OUT  STD_LOGIC_VECTOR(7 DOWNTO 0) := (OTHERS => '0');  --red magnitude output to DAC
		green_m    :  OUT  STD_LOGIC_VECTOR(7 DOWNTO 0) := (OTHERS => '0');  --green magnitude output to DAC
		blue_m     :  OUT  STD_LOGIC_VECTOR(7 DOWNTO 0) := (OTHERS => '0'); --blue magnitude output to DAC
	
		GSENSOR_CS_N : OUT	STD_LOGIC;
		GSENSOR_SCLK : OUT	STD_LOGIC;
		GSENSOR_SDI  : INOUT	STD_LOGIC;
		GSENSOR_SDO  : INOUT	STD_LOGIC;
		
		key0, key1 : in STD_LOGIC;
		sound_out : out STD_LOGIC
	);
	
end PROJ0;

architecture PROJ0_ARCH of PROJ0 is

	component vga_pll_25_175 is 
	
		port(
		
			inclk0		:	IN  STD_LOGIC := '0';  -- Input clock that gets divided (50 MHz for max10)
			c0			:	OUT STD_LOGIC          -- Output clock for vga timing (25.175 MHz)
		
		);
		
	end component;
	
	component vga_controller is 
	
		port(
		
			pixel_clk	:	IN	STD_LOGIC;	--pixel clock at frequency of VGA mode being used
			reset_n		:	IN	STD_LOGIC;	--active low asycnchronous reset
			h_sync		:	OUT	STD_LOGIC;	--horiztonal sync pulse
			v_sync		:	OUT	STD_LOGIC;	--vertical sync pulse
			disp_ena	:	OUT	STD_LOGIC;	--display enable ('1' = display time, '0' = blanking time)
			column		:	OUT	INTEGER;	--horizontal pixel coordinate
			row			:	OUT	INTEGER;	--vertical pixel coordinate
			n_blank		:	OUT	STD_LOGIC;	--direct blacking output to DAC
			n_sync		:	OUT	STD_LOGIC   --sync-on-green output to DAC
		
		);
		
	end component;
	
	component hw_image_generator is
	
		port(
			disp_ena :  IN  STD_LOGIC;  --display enable ('1' = display time, '0' = blanking time)
			row      :  IN  INTEGER range -100 to 1000;    --row pixel coordinate
			column   :  IN  INTEGER range -100 to 1000;    --column pixel coordinate
			
			score		:	IN INTEGER range 0 to 100000; --Score
			
			player_left 	: IN INTEGER range 0 to 700;
			player_right 	: IN INTEGER range 0 to 700;
			player_top 		: IN INTEGER range 0 to 700;
			player_bottom	: IN INTEGER range 0 to 700;
			num_lives		: IN INTEGER range 0 to 5;
			player_Blink	: IN STD_LOGIC;
			
			enemyPosition_x, enemyPosition_y, enemySize : IN array10;
			shotPosition_x, shotPosition_y: IN array7;
			shotDirection: IN STD_LOGIC_VECTOR(0 to 6);
			
			player_face_right : IN STD_LOGIC;
			exhaust_level, pulse_position : IN INTEGER range 0 to 700;
			
			red      :  OUT STD_LOGIC_VECTOR(7 DOWNTO 0) := (OTHERS => '0');  --red magnitude output to DAC
			green    :  OUT STD_LOGIC_VECTOR(7 DOWNTO 0) := (OTHERS => '0');  --green magnitude output to DAC
			blue     :  OUT STD_LOGIC_VECTOR(7 DOWNTO 0) := (OTHERS => '0')   --blue magnitude output to DAC
			
			
		
		);
		
	end component;
	
	component ADXL345_controller is
		port (reset_n     : IN STD_LOGIC;
			clk         : IN STD_LOGIC;
			data_valid  : OUT STD_LOGIC;
			data_x      : OUT STD_LOGIC_VECTOR(15 downto 0);
			data_y      : OUT STD_LOGIC_VECTOR(15 downto 0);
			data_z      : OUT STD_LOGIC_VECTOR(15 downto 0);
			SPI_SDI     : OUT STD_LOGIC;
			SPI_SDO     : IN STD_LOGIC;
			SPI_CSN     : OUT STD_LOGIC;
			SPI_CLK     : OUT STD_LOGIC);
	end component;
	
	component CLK_50MHZ_to_60HZ is
	Port( CLK50MHZ: IN STD_LOGIC;
			CLK60HZ: OUT STD_LOGIC);
	end component;
	
	component sounds_controller is
	port (sound_effect : in integer range 0 to 10 := 0;
			max10_clk: IN STD_LOGIC;
			sound_trigger : IN STD_LOGIC;
			sound_pin : OUT STD_LOGIC);
	end component;
	
	
	
	signal enemyPosition_x, enemyPosition_y, enemySize : array10 := (-20,-20,-20,-20,-20,-20,-20,-20,-20,-20);
	signal spawnPositions : array13 := (50, 150, 360, 75, 250, 315, 190, 60, 220, 125, 280, 100, 300);
	signal shotPosition_x, shotPosition_y	: array7 := (-99,-99,-99,-99,-99,-99,-99);
	signal shotDirection : STD_LOGIC_VECTOR (0 to 6) := "0000000";
	signal enemySizes : array7:= (10, 57, 20, 5, 32, 69, 40);
	signal currentEnemyIndex, currentSpawnIndex, currentSizeIndex, currentShotIndex, shotCounter: INTEGER range -1 to 31 := 0;
	signal spawnCounter	: INTEGER range 0 to 61:= 0;
	signal maxEnemyIndex : INTEGER range 9 to 9 := 9;--19 to 19 := 19;
	signal maxSizeIndex	: INTEGER range 6 to 6 := 6;
	signal maxSpawnIndex	: INTEGER range 12 to 12 := 12;
	signal maxShotIndex	: INTEGER range 6 to 6 := 6;--12 to 12 := 12;
	signal maxShotCounter	: INTEGER range 30 to 30 := 30;
	
	signal pll_OUT_to_vga_controller_IN, dispEn : STD_LOGIC;
	signal rowSignal, colSignal : INTEGER range -100 to 1000;
	signal data_x, data_y, data_z : STD_LOGIC_VECTOR (15 downto 0);
	signal player_left 	: INTEGER range 0 to 700 := 30;
	signal player_right 	: INTEGER range 0 to 700 := 70;
	signal player_top 	: INTEGER range 0 to 700 := 220;
	signal player_bottom	: INTEGER range 0 to 700 := 260;
	signal num_lives		: INTEGER range 0 to 700 := 3;
	signal player_Blink 	: STD_LOGIC := '0';
	signal invincible_counter, pauseCounter : INTEGER range -1 to 121 := 0;
	signal tilt_x, tilt_y : STD_LOGIC_VECTOR (3 downto 0);
	signal direction_x, direction_y, facingDirection : STD_LOGIC:= '1';
	signal clk_60HZ : STD_LOGIC;
	signal spawnRate : INTEGER range 0 to 100 := 60;
	signal enemySpeed : INTEGER range 0 to 10 := 1;
	signal pause, gameStart: STD_LOGIC := '0';
	signal player_face_right : STD_LOGIC := '1';
	signal exhaust_level, tilt_level_x, tilt_level_y, pulse_position : integer range 0 to 1000 := 0;
	signal sound_effect : integer range 0 to 10 := 0;
	signal sound_trigger : STD_LOGIC := '0';
	signal score : integer range 0 to 100000 := 0;
	
	
begin
	
	direction_x <= data_x(11);
	tilt_x <= data_x(7 downto 4);
	direction_y <= data_y(11);
	tilt_y <= data_y(7 downto 4);
	tilt_level_x <= to_integer(unsigned(tilt_x));
	tilt_level_y <= to_integer(unsigned(tilt_y));

	
-- Just need 3 components for VGA system 
	U1	:	vga_pll_25_175 port map(pixel_clk_m, pll_OUT_to_vga_controller_IN);
	U2	:	vga_controller port map(pll_OUT_to_vga_controller_IN, '1', h_sync_m, v_sync_m, dispEn, colSignal, rowSignal, open, open);
	U3	:	hw_image_generator port map(dispEn, rowSignal, colSignal, score, player_left, player_right, player_top, player_bottom, num_lives, player_Blink, enemyPosition_x, enemyPosition_y, enemySize, shotPosition_x, shotPosition_y, shotDirection, facingDirection, exhaust_level, pulse_position, red_m, green_m, blue_m);
	U4 : ADXL345_controller port map ('1', pixel_clk_m, open, data_x, data_y, data_z, GSENSOR_SDI, GSENSOR_SDO, GSENSOR_CS_N, GSENSOR_SCLK);
	U5 : CLK_50MHZ_to_60HZ port map(pixel_clk_m, clk_60HZ);
	U6	: sounds_controller port map (sound_effect, pixel_clk_m, sound_trigger, sound_out);
	
	
	HZ60_Update: Process(clk_60HZ)
	variable score_tmp : integer range 0 to 100000 := 0;
	begin
		
		if(clk_60HZ'event and clk_60HZ = '1') then
				score_tmp := score;
				sound_trigger <= '0';
			if(gameStart = '1' and pause = '0') then
			
				facingDirection <= direction_x;
				
				if(pauseCounter = 0) then
					if(key1 = '0') then
						pause <= '1';
						pauseCounter <= 1;
					end if;
				elsif(pauseCounter = 60) then
					pauseCounter <= 0;
				else 
					pauseCounter <= pauseCounter + 1;
				end if;
				if(direction_x = '1') then
					player_face_right <= '1';
					if (tilt_level_x >= 0 and tilt_level_x <= 4) then
						exhaust_level <= 3;
						if(player_right < 320) then
							player_right <= player_right + 5;
							player_left <= player_left + 5;
						end if;
					elsif (tilt_level_x >= 5 and tilt_level_x <= 9) then
						exhaust_level <= 2;
						if(player_right < 320) then
							player_right <= player_right + 3;
							player_left <= player_left + 3;
						end if;
					elsif (tilt_level_x >= 10 and tilt_level_x <= 14) then
						exhaust_level <= 1;
						if(player_right < 320) then
							player_right <= player_right + 1;
							player_left <= player_left + 1;
						end if;
					else
						exhaust_level <= 0;
					end if;
				else
					player_face_right <= '0';
					if (tilt_level_x >= 1 and tilt_level_x <= 5) then
						exhaust_level <= 1;
						if(player_left >= 1) then
							player_right <= player_right - 1;
							player_left <= player_left - 1;
						end if;
					elsif (tilt_level_x >= 6 and tilt_level_x <= 10) then
						exhaust_level <= 2;
						if(player_left >= 3) then
							player_right <= player_right - 3;
							player_left <= player_left - 3;
						end if;
					elsif (tilt_level_x >= 11 and tilt_level_x <= 15) then
						exhaust_level <= 3;
						if(player_left >= 5) then
							player_right <= player_right - 5;
							player_left <= player_left - 5;
						end if;
					else
						exhaust_level <= 0;
					end if;
				end if;
				
				if(direction_y = '0') then
					if (tilt_level_y >= 1 and tilt_level_y <= 5) then
						if(player_bottom + 1 < 439) then
							player_bottom <= player_bottom + 1;
							player_top <= player_top + 1;
						end if;
					elsif (tilt_level_y >= 6 and tilt_level_y <= 10) then
						if(player_bottom + 3 < 439) then
							player_bottom <= player_bottom + 3;
							player_top <= player_top + 3;
						end if;
					elsif (tilt_level_y >= 11 and tilt_level_y <= 15) then
						if(player_bottom + 5 < 439) then
							player_bottom <= player_bottom + 5;
							player_top <= player_top + 5;
						end if;
					end if;
				else
					if (tilt_level_y >= 0 and tilt_level_y <= 4) then
						if(player_top - 5 > 41) then
							player_top <= player_top - 5;
							player_bottom <= player_bottom - 5;
						end if;
					elsif (tilt_level_y >= 5 and tilt_level_y <= 9) then
						if(player_top - 3 > 41) then
							player_top <= player_top - 3;
							player_bottom <= player_bottom - 3;
						end if;
					elsif (tilt_level_y >= 10 and tilt_level_y <= 14) then
						if(player_top - 1 > 41) then
							player_top <= player_top - 1;
							player_bottom <= player_bottom - 1;
						end if;
					end if;
				end if;
				
				if (direction_x = '1') then
					if (exhaust_level = 0) then
						pulse_position <= Player_Left - 2;
					elsif (exhaust_level = 1 and pulse_position >= Player_Left - 15) then
						pulse_position <= pulse_position - 1;
					elsif (exhaust_level = 2 and pulse_position >= Player_Left - 25) then
						pulse_position <= pulse_position - 3;
					elsif (exhaust_level = 3 and pulse_position >= Player_Left - 35) then
						pulse_position <= pulse_position - 5;
					else 
						pulse_position <= Player_Left - 1;
					end if;
				else
					if (exhaust_level = 0) then
						pulse_position <= Player_Right + 2;
					elsif (exhaust_level = 1 and pulse_position <= Player_Right + 15) then
						pulse_position <= pulse_position + 1;
					elsif (exhaust_level = 2 and pulse_position <= Player_Right + 25) then
						pulse_position <= pulse_position + 3;
					elsif (exhaust_level = 3 and pulse_position <= Player_Right + 35) then
						pulse_position <= pulse_position + 5;
					else 
						pulse_position <= Player_Right + 1;
					end if;
				end if;
				
				if(spawnCounter = 0) then
					if(enemyPosition_x(currentEnemyIndex) = -20) then
						enemyPosition_y(currentEnemyIndex) <= spawnPositions(currentSpawnIndex);
						enemyPosition_x(currentEnemyIndex) <= 700;
						enemySize(currentEnemyIndex) <= enemySizes(currentSizeIndex);
						
						if(currentEnemyIndex = maxEnemyIndex) then
							currentEnemyIndex <= 0;
						else 
							currentEnemyIndex <= currentEnemyIndex + 1;
						end if;
						
						if(currentSpawnIndex = maxSpawnIndex) then
							currentSpawnIndex <= 0;
						else 
							currentSpawnIndex <= currentSpawnIndex + 1;
						end if;
						
						if(currentSizeIndex = maxSizeIndex) then
							currentSizeIndex <= 0;
						else 
							currentSizeIndex <= currentSizeIndex + 1;
						end if;
					end if;
					spawnCounter <= spawnCounter + 1;
				elsif(spawnCounter = spawnRate) then
					spawnCounter <= 0;
				else
					spawnCounter <= spawnCounter + 1;
				end if;
				
				for J in 0 to maxShotIndex loop
					if(shotPosition_x(J) /= -99) then
						if(shotDirection(J) = '0') then
							if(shotPosition_x(J) <= 0) then
								shotPosition_x(J) <= -99;
							else
								shotPosition_x(J) <= shotPosition_x(J) - 7;
							end if;
						else
							if(shotPosition_x(J) >= 650) then
								shotPosition_x(J) <= -99;
							else
								shotPosition_x(J) <= shotPosition_x(J) + 7;
							end if;
						end if;
					end if;
				end loop;
				
				if(shotCounter = 0) then
					if( key0 = '0') then
						if( shotPosition_x(currentShotIndex) = -99) then
							if(direction_x = '1') then
								shotPosition_x(currentShotIndex) <= player_Right + 12;
								shotPosition_y(currentShotIndex) <= player_Bottom;
								shotDirection(currentShotIndex) <= '1';
							else
								shotPosition_x(currentShotIndex) <= player_Left;
								shotPosition_y(currentShotIndex) <= player_Bottom;
								shotDirection(currentShotIndex) <= '0';
							end if; 
							
							if(currentShotIndex = maxShotIndex) then
								currentShotIndex <= 0;
							else
								currentShotIndex <= currentShotIndex + 1;
							end if;
							shotCounter <= 1;
							sound_effect <= 4;
							sound_trigger <= '1';
						end if;
					end if;
				elsif(shotCounter = maxShotCounter) then
					shotCounter <= 0;
				else
					shotCounter <= shotCounter + 1;
				end if;
				
				
				for I in 0 to maxEnemyIndex loop
					if(enemyPosition_x(I) <= 0 and enemyPosition_x(I) /= -20) then
						enemyPosition_x(I) <= -20;
					elsif(enemyPosition_x(I) /= -20) then
						enemyPosition_x(i) <= enemyPosition_x(I) - enemySpeed;
					end if;
					
					for J in 0 to maxShotIndex loop
						if(shotPosition_x(J) /= -99) then
							if(shotDirection(J) = '0') then
								if((((shotPosition_x(J) - 12) <= enemyPosition_x(i)) and ((shotPosition_x(J) - 12) >= (enemyPosition_x(i) - enemySize(I))))) then
									if(((shotPosition_y(J) >= enemyPosition_y(I)) and ((shotPosition_y(J) + 2) <= (enemyPosition_y(I) + enemySize(I)))) or ((shotPosition_y(J) <= enemyPosition_y(I)) and ((shotPosition_y(J) + 2) >= enemyPosition_y(I))) or ((shotPosition_y(J) <= (enemyPosition_y(I) + enemySize(I))) and ((shotPosition_y(J) + 2) >= (enemyPosition_y(I) + enemySize(I))))) then
										enemyPosition_x(I) <= -20;
										shotPosition_x(J) <= -99;
										sound_effect <= 2;
										sound_trigger <= '1';
										-- Higher score for smaller size
										if(enemySize(I) = 5) then
											score_tmp := score_tmp + 500;
											if(num_Lives < 3) then
												num_Lives <= num_Lives + 1; -- Award extra life if kill smallest enemy
											end if;
										elsif(enemySize(I) <= 20) then
											score_tmp := score_tmp + 250;
										elsif(enemySize(I) <= 40) then
											score_tmp := score_tmp + 150;
										else
											score_tmp := score_tmp + 75;
										end if;
									end if;
								end if;
							else
								if(((shotPosition_x(J) >= (enemyPosition_x(i) - enemySize(I))) and ((shotPosition_x(J) <= enemyPosition_x(I))))) then
									if(((shotPosition_y(J) >= enemyPosition_y(I)) and ((shotPosition_y(J) + 2) <= (enemyPosition_y(I) + enemySize(I)))) or ((shotPosition_y(J) <= enemyPosition_y(I)) and ((shotPosition_y(J) + 2) >= enemyPosition_y(I))) or ((shotPosition_y(J) <= (enemyPosition_y(I) + enemySize(I))) and ((shotPosition_y(J) + 2) >= (enemyPosition_y(I) + enemySize(I))))) then
										enemyPosition_x(I) <= -20;
										shotPosition_x(J) <= -99;
										sound_effect <= 2;
										sound_trigger <= '1';
										-- Higher score for smaller size
										if(enemySize(I) = 5) then
											score_tmp := score_tmp + 500;
											if(num_Lives < 3) then
												num_Lives <= num_Lives + 1; -- Award extra life if kill smallest enemy
											end if;
										elsif(enemySize(I) <= 20) then
											score_tmp := score_tmp + 250;
										elsif(enemySize(I) <= 40) then
											score_tmp := score_tmp + 150;
										else
											score_tmp := score_tmp + 75;
										end if;
									end if;
								end if;
							end if;
						end if;
					end loop;
					
					if(invincible_counter = 0) then
						player_Blink <= '0';
--						if( key1 = '0' and num_lives < 3) then
--							num_lives <= num_lives + 1;
--							invincible_counter <= invincible_counter + 1;
--						end if;)
						if((player_Right >= (enemyPosition_x(I) - enemySize(I))) and (player_Right <= enemyPosition_x(i))) then
							if (((player_Top >= enemyPosition_y(I)) and ((player_Top <= (enemyPosition_y(I) + enemySize(I))))) or ((player_Bottom <= (enemyPosition_y(i) + enemySize(I))) and (player_Bottom >= enemyPosition_y(I))) or ((player_Bottom >= (enemyPosition_y(i) + enemySize(I))) and (player_Top <= enemyPosition_y(I)))) then
								num_lives <= num_lives -1;
								enemyPosition_x(I) <= -20;
								invincible_counter <= 1;
								sound_effect <= 3;
								sound_trigger <= '1';
								if(num_lives = 1) then
									gamestart <= '0';
									sound_effect <= 5;
									sound_trigger <= '1';
								end if;
							end if;
						elsif((player_Left >= (enemyPosition_x(I) - enemySize(I))) and (player_Left <= enemyPosition_x(i))) then
							if(((player_Top >= enemyPosition_y(I)) and ((player_Top <= (enemyPosition_y(I) + enemySize(I))))) or ((player_Bottom <= (enemyPosition_y(i) + enemySize(I))) and (player_Bottom >= enemyPosition_y(I))) or ((player_Bottom >= (enemyPosition_y(i) + enemySize(I))) and (player_Top <= enemyPosition_y(I)))) then
								num_lives <= num_lives -1;
								enemyPosition_x(I) <= -20;
								invincible_counter <= 1;
								sound_effect <= 3;
								sound_trigger <= '1';
								if(num_lives = 1) then
									gamestart <= '0';
									sound_effect <= 5;
									sound_trigger <= '1';
								end if;
							end if;
						elsif((player_Top <= (enemyPosition_y(I) + enemySize(I))) and (player_Top >= enemyPosition_y(i))) then 
							if(((player_Left <= enemyPosition_x(I)) and ((player_Left >= (enemyPosition_x(I) - enemySize(I))))) or ((player_Right >= (enemyPosition_x(i) - enemySize(I))) and (player_Right <= enemyPosition_x(I))) or ((player_Left <= (enemyPosition_x(i) - enemySize(I))) and (player_Right >= enemyPosition_x(I)))) then
								num_lives <= num_lives -1;
								enemyPosition_x(I) <= -20;
								invincible_counter <= 1;
								sound_effect <= 3;
								sound_trigger <= '1';
								if(num_lives = 1) then
									gamestart <= '0';
									sound_effect <= 5;
									sound_trigger <= '1';
								end if;
							end if;
						elsif((player_Bottom <= (enemyPosition_y(I) + enemySize(I))) and (player_Bottom >= enemyPosition_y(i))) then
							if(((player_Left <= enemyPosition_x(I)) and ((player_Left >= (enemyPosition_x(I) - enemySize(I))))) or ((player_Right >= (enemyPosition_x(i) - enemySize(I))) and (player_Right <= enemyPosition_x(I))) or ((player_Left <= (enemyPosition_x(i) - enemySize(I))) and (player_Right >= enemyPosition_x(I)))) then
								num_lives <= num_lives -1;
								enemyPosition_x(I) <= -20;
								invincible_counter <= 1;
								sound_effect <= 3;
								sound_trigger <= '1';
								if(num_lives = 1) then
									gamestart <= '0';
									sound_effect <= 5;
									sound_trigger <= '1';
								end if;
							end if;
						end if;
					elsif(invincible_counter = 120) then
						player_Blink <= '0';
						invincible_counter <= 0;
					else
						player_Blink <= not player_Blink;
						invincible_counter <= invincible_counter + 1;
--						if((player_Right >= (enemyPosition_x(I) - enemySize(I))) and (player_Right <= enemyPosition_x(i))) then 
--							if(((player_Top >= enemyPosition_y(I)) and ((player_Top <= (enemyPosition_y(I) + enemySize(I))))) or ((player_Bottom <= (enemyPosition_y(i) + enemySize(I))) and (player_Bottom >= enemyPosition_y(I))) or ((player_Bottom >= (enemyPosition_y(i) + enemySize(I))) and (player_Top <= enemyPosition_y(I)))) then
--								enemyPosition_x(I) <= -1;
--							end if;
--						elsif((player_Left >= (enemyPosition_x(I) - enemySize(I))) and (player_Left <= enemyPosition_x(i))) then 
--							if(((player_Top >= enemyPosition_y(I)) and ((player_Top <= (enemyPosition_y(I) + enemySize(I))))) or ((player_Bottom <= (enemyPosition_y(i) + enemySize(I))) and (player_Bottom >= enemyPosition_y(I))) or ((player_Bottom >= (enemyPosition_y(i) + enemySize(I))) and (player_Top <= enemyPosition_y(I)))) then
--								enemyPosition_x(I) <= -1;
--							end if;
--						elsif((player_Top <= (enemyPosition_y(I) + enemySize(I))) and (player_Top >= enemyPosition_y(i))) then
--							if(((player_Left <= enemyPosition_x(I)) and ((player_Left >= (enemyPosition_x(I) - enemySize(I))))) or ((player_Right >= (enemyPosition_x(i) - enemySize(I))) and (player_Right <= enemyPosition_x(I))) or ((player_Left <= (enemyPosition_x(i) - enemySize(I))) and (player_Right >= enemyPosition_x(I)))) then
--								enemyPosition_x(I) <= -1;
--							end if;
--						elsif((player_Bottom <= (enemyPosition_y(I) + enemySize(I))) and (player_Bottom >= enemyPosition_y(i))) then
--							if(((player_Left <= enemyPosition_x(I)) and ((player_Left >= (enemyPosition_x(I) - enemySize(I))))) or ((player_Right >= (enemyPosition_x(i) - enemySize(I))) and (player_Right <= enemyPosition_x(I))) or ((player_Left <= (enemyPosition_x(i) - enemySize(I))) and (player_Right >= enemyPosition_x(I)))) then
--								(I) <= -1;
--							end if;
--						end if;
					end if;
				end loop;
				
				if((score_tmp / 5000) > (score / 5000)) then -- every time we cross a 5000 checkpoint, increase enemy speed
					if(enemySpeed < 6) then
						enemySpeed <= enemySpeed + 1;
						sound_effect <= 1;
						sound_trigger <= '1';
					end if;
					if(spawnRate > 15) then
						spawnRate <= spawnRate - 15;
					end if;
				end if;
			elsif(gamestart = '0') then
				if(key0 = '0') then
					gamestart <= '1';
					enemyPosition_x<= (-20,-20,-20,-20,-20,-20,-20,-20,-20,-20); 
					enemyPosition_y<= (-20,-20,-20,-20,-20,-20,-20,-20,-20,-20);
					enemySize <= (-20,-20,-20,-20,-20,-20,-20,-20,-20,-20);
					player_left <= 30;
					player_right <= 70;
					player_top 	<= 220;
					player_bottom	<= 260;
					num_lives <= 3;
					sound_effect <= 1;
					sound_trigger <= '1';
					score_tmp := 0;
					enemySpeed <= 1;
					spawnRate <= 60;
					
				end if;
			else
				if(pauseCounter = 0) then
					if(key1 = '0') then
						pause <= '0';
						pauseCounter <= 1;
					end if;
				elsif(pauseCounter = 60) then
					pauseCounter <= 0;
				else 
					pauseCounter <= pauseCounter + 1;
				end if;
			end if;
					
			
		end if;
		
		
		
		score <= score_tmp;
		
	end Process;
	
	
end architecture;