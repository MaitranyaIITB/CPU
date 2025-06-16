library IEEE;
use IEEE.STD_LOGIC_1164.ALL;

entity D_FlipFlop is
    Port (
        D   : in  STD_LOGIC;     -- Data input
        clk : in  STD_LOGIC;     -- Clock input
        rst : in  STD_LOGIC;     -- Asynchronous reset input
        Q   : out STD_LOGIC      -- Output
    );
end D_FlipFlop;

architecture Behavioral of D_FlipFlop is


begin

    process(clk, rst)
    begin
        if rst = '1' then
            Q <= '0';                -- Reset output to 0
        elsif rising_edge(clk) then
            Q <= D;                  -- Transfer D to Q on clock rising edge
        end if;
    end process;
end Behavioral;
