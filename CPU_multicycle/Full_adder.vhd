library ieee;
use ieee.std_logic_1164.all;

entity Full_adder is
	port(A, B, Cin : in std_logic;
			S, Cr : out std_logic);
end entity Full_adder;

architecture bhv of Full_adder is

begin

S  <= A xor B xor Cin;
Cr <= ( A and B ) or (Cin and ( A xor B ));

end architecture bhv;