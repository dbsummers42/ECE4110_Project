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
	 
	 score		:	IN INTEGER range 0 to 100000; --Score
			
	 player_left 	: IN INTEGER range 0 to 700;
	 player_right 	: IN INTEGER range 0 to 700;
	 player_top 	: IN INTEGER range 0 to 700;
	 player_bottom	: IN INTEGER range 0 to 700;
	 num_lives		: IN INTEGER range 0 to 5;
	 player_Blink	: IN STD_LOGIC;
			
	 enemyPosition_x, enemyPosition_y, enemySize : IN array10;
	 shotPosition_x, shotPosition_y: IN array7;
	 shotDirection: IN STD_LOGIC_VECTOR(0 to 6);
	 
	 player_face_right : IN STD_LOGIC;
	 exhaust_level, pulse_position : IN INTEGER range 0 to 700;
	 
    red      :  OUT  STD_LOGIC_VECTOR(7 DOWNTO 0) := (OTHERS => '0');  --red magnitude output to DAC
    green    :  OUT  STD_LOGIC_VECTOR(7 DOWNTO 0) := (OTHERS => '0');  --green magnitude output to DAC
    blue     :  OUT  STD_LOGIC_VECTOR(7 DOWNTO 0) := (OTHERS => '0')); --blue magnitude output to DAC
END hw_image_generator;

ARCHITECTURE behavior OF hw_image_generator IS
--signal Diagonal: INTEGER range -100 to 1000;
signal tilt_int, red_mult : integer range -100 to 1000 := 0;
signal maxEnemyIndex : INTEGER range 9 to 9 := 9;--19 to 19 := 19;
signal maxShotIndex : INTEGER range 6 to 6 := 6;--12 to 12 := 12;
signal score10k, score1k, scoreHund, scoreTen, scoreOne : INTEGER range 0 to 10;
signal seg1 : STD_LOGIC_VECTOR(0 to 9) := "1011011111";
signal seg2 : STD_LOGIC_VECTOR(0 to 9) := "1111100111";
signal seg3 : STD_LOGIC_VECTOR(0 to 9) := "1101111111";
signal seg4 : STD_LOGIC_VECTOR(0 to 9) := "1011011010";
signal seg5 : STD_LOGIC_VECTOR(0 to 9) := "1010001010";
signal seg6 : STD_LOGIC_VECTOR(0 to 9) := "1000111011";
signal seg7 : STD_LOGIC_VECTOR(0 to 9) := "0011111011";
BEGIN
  score10k <= (score / 10000) mod 10;
  score1k <= ((score mod 10000) / 1000) mod 10;
  scoreHund <= ((score mod 1000) / 100) mod 10;
  scoreTen <= ((score mod 100) / 10) mod 10;
  scoreOne <= score mod 10;
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
		
		--Scoreboard
		-- Seg 1
		if( row >= 5 and row <= 8) then
			if(column >=500 and column <= 510) then
				red <= (OTHERS => seg1(score10k));
				blue <= (OTHERS => seg1(score10k));
				green <= (OTHERS => seg1(score10k));
			elsif(column >=520 and column <= 530) then
				red <= (OTHERS => seg1(score1k));
				blue <= (OTHERS => seg1(score1k));
				green <= (OTHERS => seg1(score1k));
			elsif(column >=540 and column <= 550) then
				red <= (OTHERS => seg1(scoreHund));
				blue <= (OTHERS => seg1(scoreHund));
				green <= (OTHERS => seg1(scoreHund));
			elsif(column >=560 and column <= 570) then
				red <= (OTHERS => seg1(scoreTen));
				blue <= (OTHERS => seg1(scoreTen));
				green <= (OTHERS => seg1(scoreTen));
			elsif(column >=580 and column <= 590) then
				red <= (OTHERS => seg1(scoreOne));
				blue <= (OTHERS => seg1(scoreOne));
				green <= (OTHERS => seg1(scoreOne));
			end if;
		end if;
		--Seg 2
		if( row >= 5 and row <= 20) then
			if(column >=511 and column <= 514) then
				red <= (OTHERS => seg2(score10k));
				blue <= (OTHERS => seg2(score10k));
				green <= (OTHERS => seg2(score10k));
			elsif(column >=531 and column <= 534) then
				red <= (OTHERS => seg2(score1k));
				blue <= (OTHERS => seg2(score1k));
				green <= (OTHERS => seg2(score1k));
			elsif(column >=551 and column <= 554) then
				red <= (OTHERS => seg2(scoreHund));
				blue <= (OTHERS => seg2(scoreHund));
				green <= (OTHERS => seg2(scoreHund));
			elsif(column >=571 and column <= 574) then
				red <= (OTHERS => seg2(scoreTen));
				blue <= (OTHERS => seg2(scoreTen));
				green <= (OTHERS => seg2(scoreTen));
			elsif(column >=591 and column <= 594) then
				red <= (OTHERS => seg2(scoreOne));
				blue <= (OTHERS => seg2(scoreOne));
				green <= (OTHERS => seg2(scoreOne));
			end if;
		end if;
		--Seg 3
		if( row >= 21 and row <= 34) then
			if(column >=511 and column <= 514) then
				red <= (OTHERS => seg3(score10k));
				blue <= (OTHERS => seg3(score10k));
				green <= (OTHERS => seg3(score10k));
			elsif(column >=531 and column <= 534) then
				red <= (OTHERS => seg3(score1k));
				blue <= (OTHERS => seg3(score1k));
				green <= (OTHERS => seg3(score1k));
			elsif(column >=551 and column <= 554) then
				red <= (OTHERS => seg3(scoreHund));
				blue <= (OTHERS => seg3(scoreHund));
				green <= (OTHERS => seg3(scoreHund));
			elsif(column >=571 and column <= 574) then
				red <= (OTHERS => seg3(scoreTen));
				blue <= (OTHERS => seg3(scoreTen));
				green <= (OTHERS => seg3(scoreTen));
			elsif(column >=591 and column <= 594) then
				red <= (OTHERS => seg3(scoreOne));
				blue <= (OTHERS => seg3(scoreOne));
				green <= (OTHERS => seg3(scoreOne));
			end if;
		end if;
		-- Seg 4
		if( row >= 31 and row <= 34) then
			if(column >=500 and column <= 510) then
				red <= (OTHERS => seg4(score10k));
				blue <= (OTHERS => seg4(score10k));
				green <= (OTHERS => seg4(score10k));
			elsif(column >=520 and column <= 530) then
				red <= (OTHERS => seg4(score1k));
				blue <= (OTHERS => seg4(score1k));
				green <= (OTHERS => seg4(score1k));
			elsif(column >=540 and column <= 550) then
				red <= (OTHERS => seg4(scoreHund));
				blue <= (OTHERS => seg4(scoreHund));
				green <= (OTHERS => seg4(scoreHund));
			elsif(column >=560 and column <= 570) then
				red <= (OTHERS => seg4(scoreTen));
				blue <= (OTHERS => seg4(scoreTen));
				green <= (OTHERS => seg4(scoreTen));
			elsif(column >=580 and column <= 590) then
				red <= (OTHERS => seg4(scoreOne));
				blue <= (OTHERS => seg4(scoreOne));
				green <= (OTHERS => seg4(scoreOne));
			end if;
		end if;
		-- Seg 5
		if( row >= 21 and row <= 34) then
			if(column >=496 and column <= 499) then
				red <= (OTHERS => seg5(score10k));
				blue <= (OTHERS => seg5(score10k));
				green <= (OTHERS => seg5(score10k));
			elsif(column >=516 and column <= 519) then
				red <= (OTHERS => seg5(score1k));
				blue <= (OTHERS => seg5(score1k));
				green <= (OTHERS => seg5(score1k));
			elsif(column >=536 and column <= 539) then
				red <= (OTHERS => seg5(scoreHund));
				blue <= (OTHERS => seg5(scoreHund));
				green <= (OTHERS => seg5(scoreHund));
			elsif(column >=556 and column <= 559) then
				red <= (OTHERS => seg5(scoreTen));
				blue <= (OTHERS => seg5(scoreTen));
				green <= (OTHERS => seg5(scoreTen));
			elsif(column >=576 and column <= 579) then
				red <= (OTHERS => seg5(scoreOne));
				blue <= (OTHERS => seg5(scoreOne));
				green <= (OTHERS => seg5(scoreOne));
			end if;
		end if;
		-- Seg 6
		if( row >= 5 and row <= 20) then
			if(column >=496 and column <= 499) then
				red <= (OTHERS => seg6(score10k));
				blue <= (OTHERS => seg6(score10k));
				green <= (OTHERS => seg6(score10k));
			elsif(column >=516 and column <= 519) then
				red <= (OTHERS => seg6(score1k));
				blue <= (OTHERS => seg6(score1k));
				green <= (OTHERS => seg6(score1k));
			elsif(column >=536 and column <= 539) then
				red <= (OTHERS => seg6(scoreHund));
				blue <= (OTHERS => seg6(scoreHund));
				green <= (OTHERS => seg6(scoreHund));
			elsif(column >=556 and column <= 559) then
				red <= (OTHERS => seg6(scoreTen));
				blue <= (OTHERS => seg6(scoreTen));
				green <= (OTHERS => seg6(scoreTen));
			elsif(column >=576 and column <= 579) then
				red <= (OTHERS => seg6(scoreOne));
				blue <= (OTHERS => seg6(scoreOne));
				green <= (OTHERS => seg6(scoreOne));
			end if;
		end if;
		-- Seg 7
		if( row >= 18 and row <= 20) then
			if(column >=500 and column <= 510) then
				red <= (OTHERS => seg7(score10k));
				blue <= (OTHERS => seg7(score10k));
				green <= (OTHERS => seg7(score10k));
			elsif(column >=520 and column <= 530) then
				red <= (OTHERS => seg7(score1k));
				blue <= (OTHERS => seg7(score1k));
				green <= (OTHERS => seg7(score1k));
			elsif(column >=540 and column <= 550) then
				red <= (OTHERS => seg7(scoreHund));
				blue <= (OTHERS => seg7(scoreHund));
				green <= (OTHERS => seg7(scoreHund));
			elsif(column >=560 and column <= 570) then
				red <= (OTHERS => seg7(scoreTen));
				blue <= (OTHERS => seg7(scoreTen));
				green <= (OTHERS => seg7(scoreTen));
			elsif(column >=580 and column <= 590) then
				red <= (OTHERS => seg7(scoreOne));
				blue <= (OTHERS => seg7(scoreOne));
				green <= (OTHERS => seg7(scoreOne));
			end if;
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
							blue <= "11111100";
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
				if((row >= shotPosition_y(J)) and (row <= (shotPosition_y(J) + 2))) then
					if(shotDirection(J) = '0') then
						if( (column >= (shotPosition_x(J) - 12)) and (column <= shotPosition_x(J) - 9)) then
							red <= (OTHERS => '1');
							blue <= (OTHERS => '0');
							green <= (OTHERS => '0');
						elsif( (column >= (shotPosition_x(J) - 9)) and (column <= shotPosition_x(J) - 3)) then
							red <= "11111100";
							blue <= "11111100";
							green <= "11111100";
						elsif( (column >= (shotPosition_x(J) - 3)) and (column <= shotPosition_x(J))) then
							red <= (OTHERS => '1');
							blue <= (OTHERS => '0');
							green <= "11111100";
						end if;
					else
						if( (column >= (shotPosition_x(J) - 12)) and (column <= shotPosition_x(J) - 9)) then
							red <= (OTHERS => '1');
							blue <= (OTHERS => '0');
							green <= "11111100";
						elsif( (column >= (shotPosition_x(J) - 9)) and (column <= shotPosition_x(J) - 3)) then
							red <= "11111100";
							blue <= "11111100";
							green <= "11111100";
						elsif( (column >= (shotPosition_x(J) - 3)) and (column <= shotPosition_x(J))) then
							red <= (OTHERS => '1');
							blue <= (OTHERS => '0');
							green <= (OTHERS => '0');
						end if;
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
