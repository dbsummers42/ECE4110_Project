--------------------------------------------------------------------------------
--
--   FileName:         hw_image_generator.vhd
--   Dependencies:     none
--   Design Software:  Quartus II 64-bit Version 12.1 Build 177 SJ Full Version
--
--   HDL CODE IS PROVIDED "AS IS."  DIGI-KEY EXPRESSLY DISCLAIMS ANY
--   WARRANTY OF ANY KIND, WHETHER EXPRESS OR IMPLIED, INCLUDING BUT NOT
--   LIMITED TO, THE IMPLIED WARRANTIES OF MERCHANTABILITY, FITNESS FOR A
--   PARTICULAR PURPOSE, OR NON-INFRINGEMENT. IN NO EVENT SHALL DIGI-KEY
--   BE LIABLE FOR ANY INCIDENTAL, SPECIAL, INDIRECT OR CONSEQUENTIAL
--   DAMAGES, LOST PROFITS OR LOST DATA, HARM TO YOUR EQUIPMENT, COST OF
--   PROCUREMENT OF SUBSTITUTE GOODS, TECHNOLOGY OR SERVICES, ANY CLAIMS
--   BY THIRD PARTIES (INCLUDING BUT NOT LIMITED TO ANY DEFENSE THEREOF),
--   ANY CLAIMS FOR INDEMNITY OR CONTRIBUTION, OR OTHER SIMILAR COSTS.
--
--   Version History
--   Version 1.0 05/10/2013 Scott Larson
--     Initial Public Release
--    
--------------------------------------------------------------------------------
--
-- Altered 10/13/19 - Tyler McCormick 
-- Test pattern is now 8 equally spaced 
-- different color vertical bars, from black (left) to white (right)


LIBRARY ieee;
USE ieee.std_logic_1164.all;
USE ieee.numeric_STD.all;
USE ieee.math_real.all;

LIBRARY work;
use work.my_types.all;

ENTITY hw_image_generator IS
 
  PORT(
	
	 disp_ena :  IN  STD_LOGIC;  --display enable ('1' = display time, '0' = blanking time)
    row      :  IN   INTEGER range -100 to 1000;    --row pixel coordinate
    column   :  IN   INTEGER range -100 to 1000;    --column pixel coordinate
	 
	 player_left 	: IN INTEGER range 0 to 700;
	 player_right 	: IN INTEGER range 0 to 700;
	 player_top 	: IN INTEGER range 0 to 700;
	 player_bottom	: IN INTEGER range 0 to 700;
	 num_lives		: IN INTEGER range 0 to 5;
	 player_Blink	: IN STD_LOGIC;
			
	 enemyPosition_x, enemyPosition_y, enemySize : IN array20;
	 shotPosition_x, shotPosition_y: IN array13;
	 
	 player_face_right : IN STD_LOGIC;
	 exhaust_level, pulse_position : IN INTEGER range 0 to 700;
	 
    red      :  OUT  STD_LOGIC_VECTOR(7 DOWNTO 0) := (OTHERS => '0');  --red magnitude output to DAC
    green    :  OUT  STD_LOGIC_VECTOR(7 DOWNTO 0) := (OTHERS => '0');  --green magnitude output to DAC
    blue     :  OUT  STD_LOGIC_VECTOR(7 DOWNTO 0) := (OTHERS => '0')); --blue magnitude output to DAC
END hw_image_generator;

ARCHITECTURE behavior OF hw_image_generator IS
signal Diagonal: INTEGER range -100 to 1000;
signal tilt_int, red_mult : integer range -100 to 1000 := 0;
signal maxEnemyIndex : INTEGER range -100 to 1000 := 19;
signal maxShotIndex : INTEGER range -100 to 1000 := 12;

BEGIN
  
  PROCESS(disp_ena, row, column)
  BEGIN
  IF(disp_ena = '1') THEN 
		if(row <= 40) then
			red <= (OTHERS => '0');
			blue <= (OTHERS => '0');
			green <= (OTHERS => '0');
		elsif(row >= 440) then
			red <= (OTHERS => '0');
			blue <= (OTHERS => '0');
			green <= (OTHERS => '0');
		else
			red <= (OTHERS => '1');
			blue <= (OTHERS => '1');
			green <= (OTHERS => '1');
		end if;
		
	if (player_face_right = '1') then
		if(row >= player_top and row <= player_bottom) then
			if(column >= player_left and column <= player_right) then
				if((row - player_top) >= (column - player_left)) then
					if( player_Blink = '0') then
						red <= (OTHERS => '1');
						blue <= (OTHERS => '0');
						green <= (OTHERS => '0');
					else
						red <= (OTHERS => '1');
						blue <= (OTHERS => '1');
						green <= (OTHERS => '1');
					end if;
				else
					red <= (OTHERS => '1');
					blue <= (OTHERS => '1');
					green <= (OTHERS => '1');
				end if;
			end if;
		end if;
	elsif (player_face_right = '0') then	
		if(row >= player_top and row <= player_bottom) then
			if(column >= player_left and column <= player_right) then
				if((row - player_top) >= (player_right - column)) then
					if( player_Blink = '0') then
						red <= (OTHERS => '1');
						blue <= (OTHERS => '0');
						green <= (OTHERS => '0');
					else
						red <= (OTHERS => '1');
						blue <= (OTHERS => '1');
						green <= (OTHERS => '1');
					end if;
				else
					red <= (OTHERS => '1');
					blue <= (OTHERS => '1');
					green <= (OTHERS => '1');
				end if;
			end if;
		end if;
	end if;
	
			if (Player_Blink = '0') then
				if (row >= player_top + 10 and row <= player_bottom - 10) then
					if (player_face_right = '1') then
						if (exhaust_level = 1) then
							if (column >= player_left - 15 and column <= Player_left - 2) then
								red <= "00001111";
								blue <= (others => '1');
								green <= (others => '0');
							end if;
						elsif (exhaust_level = 2) then
							if (column >= player_left - 25 and column <= Player_left - 2) then
								red <= "00001111";
								blue <= (others => '1');
								green <= (others => '0');
							end if;
						elsif (exhaust_level = 3) then
							if (column >= player_left - 35 and column <= Player_left - 2) then
								red <= "00001111";
								blue <= (others => '1');
								green <= (others => '0');
							end if;
						end if;
					else
						if (exhaust_level = 1) then
							if (column <= player_right + 15 and column >= Player_Right + 2) then
								red <= "00001111";
								blue <= (others => '1');
								green <= (others => '0');
								end if;
							elsif (exhaust_level = 2) then
								if (column <= player_right + 25 and column >= Player_Right + 2) then
									red <= "00001111";
									blue <= (others => '1');
									green <= (others => '0');
								end if;
							elsif (exhaust_level = 3) then
								if (column <= player_right + 35 and column >= Player_Right + 2) then
									red <= "00001111";
									blue <= (others => '1');
									green <= (others => '0');
								end if;
						end if;
					end if;
				end if;
			end if;
			
		if (player_face_right = '1') then
			if (row >= player_top + 10 and row <= player_bottom - 10) then
				if (column <= pulse_position and column >= pulse_position - 3) then
					red <= (others => '1');
					blue <= (others => '1');
					green <= (others => '1');
				end if;
			end if;
		else
			if (row >= player_top + 10 and row <= player_bottom - 10) then
				if (column >= pulse_position and column <= pulse_position + 3) then
					red <= (others => '1');
					blue <= (others => '1');
					green <= (others => '1');
				end if;
			end if;
		end if;
						
				
		if(row >= 15 and row <= 35 and num_lives >= 1) then 
			if (column > 25 and column < 50) then
				if( (row - 15) > (column - 25 ) ) then 
					red <= (OTHERS => '1');
					blue <= (OTHERS => '0');
					green <= (OTHERS => '0');
				else
					red <= (OTHERS => '0');
					blue <= (OTHERS => '0');
					green <= (OTHERS => '0');
				end if;
			end if;
		end if;
		
		if(row >= 15 and row <= 35 and num_lives >= 2) then 
			if (column > 75 and column < 100) then
				if( (row - 15) > (column - 75)) then 
					red <= (OTHERS => '1');
					blue <= (OTHERS => '0');
					green <= (OTHERS => '0');
				else
					red <= (OTHERS => '0');
					blue <= (OTHERS => '0');
					green <= (OTHERS => '0');
				end if;
			end if;
		end if;
		
		if(row >= 15 and row <= 35 and num_lives >= 3) then 
			if (column > 125 and column < 150) then
				if( (row - 15) > (column - 125) ) then 
					red <= (OTHERS => '1');
					blue <= (OTHERS => '0');
					green <= (OTHERS => '0');
				else
					red <= (OTHERS => '0');
					blue <= (OTHERS => '0');
					green <= (OTHERS => '0');
				end if;
			end if;
		end if;
		
		for I in 0 to maxEnemyIndex loop
				if((row >= enemyPosition_y(I)) and (row <= (enemyPosition_y(I) + enemySize(I)))) then
					if( (column >= (enemyPosition_x(I) - enemySize(I))) and (column <= enemyPosition_x(I))) then
						if( ((maxEnemyIndex + 1) mod (I + 1) ) = 0) then 
							red <= (OTHERS => '0');
							blue <= (OTHERS => '0');
							green <= (OTHERS => '1');
						elsif( ((maxEnemyIndex + 1) mod (I + 1) ) = 1) then 
							red <= (OTHERS => '0');
							blue <= (OTHERS => '1');
							green <= (OTHERS => '0');
						elsif( ((maxEnemyIndex + 1) mod (I + 1) ) = 2) then 
							red <= (OTHERS => '0');
							blue <= (OTHERS => '1');
							green <= (OTHERS => '1');
						elsif( ((maxEnemyIndex + 1) mod (I + 1) ) = 3) then 
							red <= (OTHERS => '1');
							blue <= (OTHERS => '0');
							green <= (OTHERS => '0');
						elsif( ((maxEnemyIndex + 1) mod (I + 1) ) = 4) then 
							red <= (OTHERS => '1');
							blue <= (OTHERS => '0');
							green <= (OTHERS => '1');
						else 
							red <= (OTHERS => '1');
							blue <= (OTHERS => '1');
							green <= (OTHERS => '0');
						end if;
					end if;
				end if;
		end loop;
		
		for J in 0 to maxShotIndex loop
				if((row >= shotPosition_y(J)) and (row <= (shotPosition_y(J) + 3))) then
					if( (column >= (shotPosition_x(J) - 5)) and (column <= shotPosition_x(J))) then
						red <= (OTHERS => '0');
						blue <= (OTHERS => '0');
						green <= (OTHERS => '0');
					end if;
				end if;
		end loop;
				
					
		
    ELSE                           --blanking time
      red <= (OTHERS => '0');
      green <= (OTHERS => '0');
      blue <= (OTHERS => '0');
    END IF;
		
			
  
  END PROCESS;
		
END behavior;
