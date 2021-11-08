LIBRARY IEEE;
USE IEEE.STD_LOGIC_1164.ALL;

entity CLK_50MHZ_to_60HZ is
	Port( CLK50MHZ: IN STD_LOGIC;
			CLK60HZ: OUT STD_LOGIC);
end entity;

architecture CLK_50MHZ_to_60HZ_ARCH of CLK_50MHZ_to_60HZ is
signal count: integer:=1;
signal tmp : std_logic := '0';
  
begin
	process(CLK50MHZ)
	begin
	if(rising_edge(CLK50MHZ)) then
		count <=count+1;
		if (count = 416666) then
			tmp <= NOT tmp;
			count <= 1;
		end if;
	end if;
	CLK60HZ <= tmp;
	end process;
end architecture;