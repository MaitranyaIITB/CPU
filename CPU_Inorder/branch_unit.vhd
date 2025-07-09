library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity branch_unit is
  port (
    rs1      : in std_logic_vector(31 downto 0);
    rs2      : in std_logic_vector(31 downto 0);
    funct3   : in std_logic_vector(2 downto 0);
    taken    : out std_logic
  );
end entity;

architecture rtl of branch_unit is
begin
  process(rs1, rs2, funct3)
  begin
    case funct3 is
      when "000" =>  -- BEQ
        if rs1 = rs2 then taken <= '1'; else taken <= '0'; end if;

      when "001" =>  -- BNE
        if rs1 /= rs2 then taken <= '1'; else taken <= '0'; end if;

      when "100" =>  -- BLT
        if signed(rs1) < signed(rs2) then taken <= '1'; else taken <= '0'; end if;

      when "101" =>  -- BGE
        if signed(rs1) >= signed(rs2) then taken <= '1'; else taken <= '0'; end if;

      when "110" =>  -- BLTU
        if unsigned(rs1) < unsigned(rs2) then taken <= '1'; else taken <= '0'; end if;

      when "111" =>  -- BGEU
        if unsigned(rs1) >= unsigned(rs2) then taken <= '1'; else taken <= '0'; end if;

      when others =>
        taken <= '0';
    end case;
  end process;
end rtl;