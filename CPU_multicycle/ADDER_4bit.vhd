library ieee;
use ieee.std_logic_1164.all;

entity ADDER_4bit is
	port ( A, B : in std_logic_vector(3 downto 0);
			 S    : out std_logic_vector(3 downto 0);
			 Cr   : out std_logic);
end entity ADDER_4bit;

architecture bhv of ADDER_4bit is
	
	component Full_adder is
		port( A, B, Cin : in std_logic;
				S, Cr : out std_logic);
	end component Full_adder;
	
	signal C : std_logic_vector(4 downto 0);
	
begin

C(0) <= '0';

n16 : for i in 0 to 3 generate
		
		f : Full_adder port map (A => A(i), B=> B(i), Cin => C(i), S => S(i), Cr => C(i+1));
		
		end generate;
		
Cr <= C(4);

end architecture bhv;