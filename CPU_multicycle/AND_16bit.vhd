library ieee;
use ieee.std_logic_1164.all;

entity AND_16bit is
	port ( A, B : in std_logic_vector(15 downto 0);
			 Y    : out std_logic_vector(15 downto 0));
end entity AND_16bit;

architecture bhv of AND_16bit is

begin

n16 : for i in 0 to 15 generate

		Y(i) <= A(i) and B(i);
		
		end generate;
		
end architecture bhv;