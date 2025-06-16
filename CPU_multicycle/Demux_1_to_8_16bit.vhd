library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity Demux_1_to_8_16bit is
    port (
        Din    : in std_logic_vector(15 downto 0); 
        Sel    : in std_logic_vector(2 downto 0);  
        D0, D1, D2, D3, D4, D5, D6, D7 : out std_logic_vector(15 downto 0)
    );
end entity Demux_1_to_8_16bit;

architecture behavioral of Demux_1_to_8_16bit is
begin
    process(Din, Sel)
    begin
            case Sel is
                when "000" => D0 <= Din;
                when "001" => D1 <= Din;
                when "010" => D2 <= Din;
                when "011" => D3 <= Din;
                when "100" => D4 <= Din;
                when "101" => D5 <= Din;
                when "110" => D6 <= Din;
                when "111" => D7 <= Din;
                when others => null;
            end case;
    end process;
end architecture behavioral;
