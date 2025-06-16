library ieee;
use ieee.std_logic_1164.all;

entity SHIFT1 is
	port(A : in std_logic_vector(15 downto 0);
		  Y : out std_logic_vector(15 downto 0));
end entity SHIFT1;

architecture bhv of SHIFT1 is

begin

Y(15 downto 1)  <= A(14 downto 0);
Y(0) <= '0';

end architecture bhv;