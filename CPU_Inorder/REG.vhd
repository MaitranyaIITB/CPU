library ieee;
use ieee.std_logic_1164.all;

entity REG is
    port (
        clk   : in std_logic;                     -- Clock input
        Din   : in std_logic_vector(31 downto 0); -- Data input
        enable: in std_logic;                     -- Enable input
        Dout  : out std_logic_vector(31 downto 0); -- Data output
		  rst: in std_logic --makes register 000
    );
end entity REG;

architecture bhv of REG is

    component D_FlipFlop is
        port (
            D   : in  std_logic;  -- Data input
            clk : in  std_logic;  -- Clock input
            rst : in  std_logic;  -- Asynchronous reset input
            Q   : out std_logic   -- Output
        );
    end component D_FlipFlop;

    signal clk_en: std_logic; -- Signal for intermediate multiplexer input

begin
	
	
	
	clk_en <= (clk)  and enable;

    n16_bit : for i in 0 to 31 generate
        flp : D_FlipFlop
            port map (
                D   => Din(i), 
                clk => clk_en,    
                rst => rst,    
                Q   => Dout(i)    
            );
    end generate;

end architecture bhv;
