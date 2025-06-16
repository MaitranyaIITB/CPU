library ieee;
use ieee.std_logic_1164.all;

entity ADDER_SUBTRACTOR_16bit is
	port ( A, B : in std_logic_vector(15 downto 0);
			 sub  : in std_logic;
			 S    : out std_logic_vector(15 downto 0);
			 Cr   : out std_logic);
end entity ADDER_SUBTRACTOR_16bit;

architecture bhv of ADDER_SUBTRACTOR_16bit is
	
	component Full_adder is
		port( A, B, Cin : in std_logic;
				S, Cr : out std_logic);
	end component Full_adder;
	
	signal C  : std_logic_vector(16 downto 0);
	signal BS : std_logic_vector(15 downto 0);
	
begin

C(0) <= sub;

n16 : for i in 0 to 15 generate
		BS(i) <= B(i) xor sub;
		f : Full_adder port map (A => A(i), B=> BS(i) , Cin => C(i), S => S(i), Cr => C(i+1));
		
		end generate;
		
Cr <= C(16);

end architecture bhv;