library   ieee;
use       ieee.std_logic_1164.all;
library work;
use 		 work.my_types.all;

package my_types is 
	type array3 is array (0 to 2) of integer;
	type array7 is array (0 to 6) of integer;
	type array20 is array (0 to 19) of integer;
end package;

library   ieee;
use       ieee.std_logic_1164.all;
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
		
		key0, key1 : in STD_LOGIC
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
			row      :  IN  INTEGER;    --row pixel coordinate
			column   :  IN  INTEGER;    --column pixel coordinate
			
			player_left 	: IN INTEGER;
			player_right 	: IN INTEGER;
			player_top 		: IN INTEGER;
			player_bottom	: IN INTEGER;
			num_lives		: IN INTEGER;
			
			enemyPosition_x, enemyPosition_y, enemySize : IN array20;
			
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
	
	
	
	signal enemyPosition_x, enemyPosition_y, enemySize : array20 := (-1,-1,-1,-1,-1,-1,-1,-1,-1,-1,-1,-1,-1,-1,-1,-1,-1,-1,-1,-1);
	signal spawnPositions : array7 := (50, 150, 360, 75, 250, 315, 190);
	signal enemySizes : array7:= (10, 57, 20, 5, 32, 69, 40);
	signal currentEnemyIndex, currentSpawnIndex, currentSizeIndex, spawnCounter: INTEGER := 0;
	signal maxEnemyIndex : INTEGER := 19;
	signal maxSizeIndex	: INTEGER := 2;
	signal maxSpawnIndex	: INTEGER := 6;
	
	signal pll_OUT_to_vga_controller_IN, dispEn : STD_LOGIC;
	signal rowSignal, colSignal : INTEGER;
	signal data_x, data_y, data_z : STD_LOGIC_VECTOR (15 downto 0);
	signal player_left 	: INTEGER := 30;
	signal player_right 	: INTEGER := 70;
	signal player_top 	: INTEGER := 220;
	signal player_bottom	: INTEGER := 260;
	signal num_lives		: INTEGER := 3;
	signal invincible_counter : INTEGER := 0;
	signal tilt_x, tilt_y : STD_LOGIC_VECTOR (3 downto 0);
	signal direction_x, direction_y : STD_LOGIC;
	signal clk_60HZ : STD_LOGIC;
	
begin
	
	direction_x <= data_x(11);
	tilt_x <= data_x(7 downto 4);
	direction_y <= data_y(11);
	tilt_y <= data_y(7 downto 4);
	
-- Just need 3 components for VGA system 
	U1	:	vga_pll_25_175 port map(pixel_clk_m, pll_OUT_to_vga_controller_IN);
	U2	:	vga_controller port map(pll_OUT_to_vga_controller_IN, '1', h_sync_m, v_sync_m, dispEn, colSignal, rowSignal, open, open);
	U3	:	hw_image_generator port map(dispEn, rowSignal, colSignal, player_left, player_right, player_top, player_bottom, num_lives, enemyPosition_x, enemyPosition_y, enemySize, red_m, green_m, blue_m);
	U4 : ADXL345_controller port map ('1', pixel_clk_m, open, data_x, data_y, data_z, GSENSOR_SDI, GSENSOR_SDO, GSENSOR_CS_N, GSENSOR_SCLK);
	U5 : CLK_50MHZ_to_60HZ port map(pixel_clk_m, clk_60HZ);
	
	
	HZ60_Update: Process(clk_60HZ)
	begin
		if(clk_60HZ'event and clk_60HZ = '1') then
			if(direction_x = '1') then
				if(tilt_x /= "1111") then
					if(player_right < 351) then
						player_right <= player_right + 1;
						player_left <= player_left + 1;
					end if;
				end if;
			else
				if(tilt_x /= "0000") then
					if(player_left > 0) then
							player_right <= player_right - 1;
							player_left <= player_left - 1;
						end if;
					end if;
			end if;
			
			if(direction_y = '0') then
				if(tilt_y /= "0000") then
					if(player_bottom < 439) then
						player_bottom <= player_bottom + 2;
						player_top <= player_top + 2;
					end if;
				end if;
			else
				if(tilt_y /= "1111") then
					if(player_top > 41) then
							player_top <= player_top - 2;
							player_bottom <= player_bottom - 2;
						end if;
					end if;
			end if;
			
			if(spawnCounter = 0) then
				if(enemyPosition_x(currentEnemyIndex) = -1) then
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
			elsif(spawnCounter = 15) then
				spawnCounter <= 0;
			else
				spawnCounter <= spawnCounter + 1;
			end if;
			
			for I in 0 to maxEnemyIndex loop
				if(enemyPosition_x(I) = 0) then
					enemyPosition_x(I) <= -1;
				elsif(enemyPosition_x(I) /= -1) then
					enemyPosition_x(i) <= enemyPosition_x(I) - 2;
				end if;
			end loop;
			
			if( invincible_counter = 0) then 
--				if( key0 = '0') then
--					num_lives <= num_lives - 1;
--					invincible_counter <= invincible_counter + 1;
				if( key1 = '0' and num_lives < 3) then
					num_lives <= num_lives + 1;
					invincible_counter <= invincible_counter + 1;
				end if;
				for I in 0 to maxEnemyIndex loop
					if((player_Right >= (enemyPosition_x(I) - enemySize(I))) and (player_Right <= enemyPosition_x(i)) and ((player_Top >= enemyPosition_y(I)) and ((player_Top <= (enemyPosition_y(I) + enemySize(I))) or ((player_Bottom <= (enemyPosition_y(i) + enemySize(I))) and (player_Bottom >= enemyPosition_y(I)))))) then
						num_lives <= num_lives -1;
						enemyPosition_x(I) <= -1;
						invincible_counter <= 1;
					end if;
				end loop;
			elsif(invincible_counter = 120) then
				invincible_counter <= 0;
			else
				for I in 0 to maxEnemyIndex loop
					if((player_Right >= (enemyPosition_x(I) - enemySize(I))) and (player_Right <= enemyPosition_x(i)) and ((player_Top >= enemyPosition_y(I)) and ((player_Top <= (enemyPosition_y(I) + enemySize(I))) or ((player_Bottom <= (enemyPosition_y(i) + enemySize(I))) and (player_Bottom >= enemyPosition_y(I)))))) then
						enemyPosition_x(I) <= -1;
					end if;
				end loop;
				invincible_counter <= invincible_counter + 1;
			end if;
				
			
		end if;
	end Process;

	
end architecture;