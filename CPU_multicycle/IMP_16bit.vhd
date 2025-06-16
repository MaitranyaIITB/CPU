library ieee;
use ieee.std_logic_1164.all;

entity IMP_16bit is
	port ( A, B : in std_logic_vector(15 downto 0);
			 Y    : out std_logic_vector(15 downto 0));
end entity IMP_16bit;

architecture bhv of IMP_16bit is

begin

n16 : for i in 0 to 15 generate

		Y(i) <= (not A(i)) or B(i);
		
		end generate;
		
end architecture bhv;