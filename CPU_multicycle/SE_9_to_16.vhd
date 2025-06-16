library ieee;
use ieee.std_logic_1164.all;

entity SE_9_to_16 is
	port(A : in std_logic_vector(8 downto 0);
		  Y : out std_logic_vector(15 downto 0));
end entity SE_9_to_16;

architecture bhv of SE_9_to_16 is

begin

Y(8 downto 0)  <= A;
Y(15 downto 9) <= "0000000";

end architecture bhv;