library ieee;
use ieee.std_logic_1164.all;

entity MUL_4bit is
	port ( A, B : in std_logic_vector(3 downto 0);
			 Y    : out std_logic_vector(15 downto 0));
end entity MUL_4bit;

architecture bhv of MUL_4bit is

	component ADDER_4bit is
		port( A, B : in std_logic_vector(3 downto 0);
				S    : out std_logic_vector(3 downto 0);
				Cr   : out std_logic);
	end component ADDER_4bit;
	
	signal m : std_logic_vector(15 downto 0);
	signal n : std_logic_vector(7 downto 0);
	
begin

m(0)  <= A(0) and B(0); m(1)  <= A(1) and B(0); m(2)  <= A(2) and B(0); m(3)  <= A(3) and B(0);
m(4)  <= A(0) and B(1); m(5)  <= A(1) and B(1); m(6)  <= A(2) and B(1); m(7)  <= A(3) and B(1);
m(8)  <= A(0) and B(2); m(9)  <= A(1) and B(2); m(10) <= A(2) and B(2); m(11) <= A(3) and B(2);
m(12) <= A(0) and B(3); m(13) <= A(1) and B(3); m(14) <= A(2) and B(3); m(15) <= A(3) and B(3);

Y(0) <= m(0);

a1 : ADDER_4bit port map(A(0)=>m(4), A(1)=>m(5), A(2)=>m(6), A(3)=>m(7),
								 B(0)=>m(1), B(1)=>m(2), B(2)=>m(3), B(3)=>'0',
								 S(0)=>Y(1), S(1)=>n(0), S(2)=>n(1), S(3)=>n(2), Cr=>n(3));

a2 : ADDER_4bit port map(A(0)=>m(8), A(1)=>m(9), A(2)=>m(10), A(3)=>m(11),
								 B(0)=>n(0), B(1)=>n(1), B(2)=>n(2),  B(3)=>n(3),
								 S(0)=>Y(2), S(1)=>n(4), S(2)=>n(5),  S(3)=>n(6), Cr=>n(7));
								 
a3 : ADDER_4bit port map(A(0)=>m(12), A(1)=>m(13), A(2)=>m(14), A(3)=>m(15),
								 B(0)=>n(4),  B(1)=>n(5),  B(2)=>n(6),  B(3)=>n(7),
								 S(0)=>Y(3),  S(1)=>Y(4),  S(2)=>Y(5),  S(3)=>Y(6), Cr=>Y(7));
								 
Y(15 downto 8) <= "00000000";

end architecture bhv;