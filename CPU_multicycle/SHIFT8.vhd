library ieee;
use ieee.std_logic_1164.all;

entity SHIFT8 is
	port(A : in std_logic_vector(7 downto 0);
		  Y : out std_logic_vector(15 downto 0));
end entity SHIFT8;

architecture bhv of SHIFT8 is

begin

Y(15 downto 8) <= A(7 downto 0);
Y(7 downto 0)  <= "00000000";

end architecture bhv;