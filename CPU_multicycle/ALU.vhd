library ieee;
use ieee.std_logic_1164.all;

entity ALU is
    port(
        A, B  : in std_logic_vector(15 downto 0);
        sel   : in std_logic_vector(2 downto 0);
        C     : out std_logic_vector(15 downto 0);
		  cflag : out std_logic;
		  zflag : out std_logic
    );
end entity ALU;

architecture bhv of ALU is

    component ADDER_SUBTRACTOR_16bit is
        port (
            A, B : in std_logic_vector(15 downto 0);
            sub  : in std_logic;
            S    : out std_logic_vector(15 downto 0);
            Cr   : out std_logic
        );
    end component ADDER_SUBTRACTOR_16bit;

    component MUL_4bit is
        port (
            A, B : in std_logic_vector(3 downto 0);
            Y    : out std_logic_vector(15 downto 0)
        );
    end component MUL_4bit;

    component AND_16bit is
        port (
            A, B : in std_logic_vector(15 downto 0);
            Y    : out std_logic_vector(15 downto 0)
        );
    end component AND_16bit;

    component OR_16bit is
        port (
            A, B : in std_logic_vector(15 downto 0);
            Y    : out std_logic_vector(15 downto 0)
        );
    end component OR_16bit;

    component IMP_16bit is
        port (
            A, B : in std_logic_vector(15 downto 0);
            Y    : out std_logic_vector(15 downto 0)
        );
    end component IMP_16bit;

    -- Intermediate Signals
    signal add_sub_result : std_logic_vector(15 downto 0);
    signal mul_result     : std_logic_vector(15 downto 0);
    signal and_result     : std_logic_vector(15 downto 0);
    signal or_result      : std_logic_vector(15 downto 0);
    signal imp_result     : std_logic_vector(15 downto 0);
    signal carry_out      : std_logic;
	 signal C_temp         : std_logic_vector(15 downto 0);

begin

    -- ADD/SUB Component
    ADDER_SUB: ADDER_SUBTRACTOR_16bit
        port map (
            A    => A,
            B    => B,
            sub  => sel(1), -- Select ADD (0) or SUB (1)
            S    => add_sub_result,
            Cr   => carry_out
        );

    -- MUL Component
    MUL: MUL_4bit
        port map (
            A => A(3 downto 0),
            B => B(3 downto 0),
            Y => mul_result
        );

    -- AND Component
    AND_OP: AND_16bit
        port map (
            A => A,
            B => B,
            Y => and_result
        );

    -- OR Component
    OR_OP: OR_16bit
        port map (
            A => A,
            B => B,
            Y => or_result
        );

    -- IMP Component
    IMP_OP: IMP_16bit
        port map (
            A => A,
            B => B,
            Y => imp_result
        );

    -- Multiplexer Logic to Select the Output
    process(sel, add_sub_result, mul_result, and_result, or_result, imp_result, c_temp)
    begin
        case sel is
            when "000" =>  -- ADD
                C_temp <= add_sub_result;
					 cflag  <= carry_out;

            when "010" =>  -- SUB
                C_temp <= add_sub_result;
					 cflag  <= carry_out;

            when "011" =>  -- MUL
                C_temp <= mul_result;
					 cflag  <= '0';

            when "100" =>  -- AND
                C_temp <= and_result;
					 cflag  <= '0';

            when "101" =>  -- OR
                C_temp <= or_result;
					 cflag  <= '0';

            when "110" =>  -- IMP
                C_temp <= imp_result;
					 cflag  <= '0';

            when others =>
                C_temp <= (others => '0');  -- Default case
        end case;
    end process;
	 
	 C <= C_temp;
	 zflag <= '1' when C_temp = "0000000000000000" else '0';

end architecture bhv;
