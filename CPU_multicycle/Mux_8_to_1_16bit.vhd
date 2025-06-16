library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity Mux_8_to_1_16bit is
    port (
        D0, D1, D2, D3, D4, D5, D6, D7  : in std_logic_vector(15 downto 0);
        Sel    : in std_logic_vector(2 downto 0);   
        Dout   : out std_logic_vector(15 downto 0) 
    );
end entity Mux_8_to_1_16bit;

architecture behavioral of Mux_8_to_1_16bit is
begin
    process(D0, D1, D2, D3, D4, D5, D6, D7, Sel)
    begin
        case Sel is
            when "000" => Dout <= D0;
            when "001" => Dout <= D1;
            when "010" => Dout <= D2;
            when "011" => Dout <= D3;
            when "100" => Dout <= D4;
            when "101" => Dout <= D5;
            when "110" => Dout <= D6;
            when "111" => Dout <= D7;
            when others => Dout <= (others => '0');
        end case;
    end process;
end architecture behavioral;
