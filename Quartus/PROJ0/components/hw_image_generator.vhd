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

ENTITY hw_image_generator IS
  GENERIC(
    
	col_a : INTEGER := 80;
	col_b : INTEGER := 160;
	col_c : INTEGER := 240;
	col_d : INTEGER := 320;
	col_e : INTEGER := 400;
	col_f : INTEGER := 480;
	col_g : INTEGER := 560;
	col_h : INTEGER := 640

	);  
  PORT(
	
	 disp_ena :  IN  STD_LOGIC;  --display enable ('1' = display time, '0' = blanking time)
    row      :  IN   INTEGER;    --row pixel coordinate
    column   :  IN   INTEGER;    --column pixel coordinate
	 
	 player_left 	: IN INTEGER;
	 player_right 	: IN INTEGER;
	 player_top 	: IN INTEGER;
	 player_bottom	: IN INTEGER;
	 num_lives		: IN INTEGER;
	 
    red      :  OUT  STD_LOGIC_VECTOR(7 DOWNTO 0) := (OTHERS => '0');  --red magnitude output to DAC
    green    :  OUT  STD_LOGIC_VECTOR(7 DOWNTO 0) := (OTHERS => '0');  --green magnitude output to DAC
    blue     :  OUT  STD_LOGIC_VECTOR(7 DOWNTO 0) := (OTHERS => '0')); --blue magnitude output to DAC
END hw_image_generator;

ARCHITECTURE behavior OF hw_image_generator IS
signal Diagonal: INTEGER;
signal tilt_int, red_mult : integer := 0;

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
		
		if(row >= player_top and row <= player_bottom) then
			if(column >= player_left and column <= player_right) then
				if((row - player_top) >= (column - player_left)) then
					red <= (OTHERS => '1');
					blue <= (OTHERS => '0');
					green <= (OTHERS => '0');
				else
					red <= (OTHERS => '1');
					blue <= (OTHERS => '1');
					green <= (OTHERS => '1');
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
				
					
		
    ELSE                           --blanking time
      red <= (OTHERS => '0');
      green <= (OTHERS => '0');
      blue <= (OTHERS => '0');
    END IF;
		
			
  
  END PROCESS;
		
END behavior;
