library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity alu is
  port (
    a, b : in std_logic_vector(31 downto 0);
    sel  : in std_logic_vector(3 downto 0); -- ALU operation selector
    s    : out std_logic_vector(31 downto 0)
  );
end alu;

architecture struct of alu is

  function add(a, b: std_logic_vector(31 downto 0)) return std_logic_vector is
  begin
    return std_logic_vector(signed(a) + signed(b));
  end;

  function sub(a, b: std_logic_vector(31 downto 0)) return std_logic_vector is
  begin
    return std_logic_vector(signed(a) - signed(b));
  end;

  function and_2(a, b: std_logic_vector(31 downto 0)) return std_logic_vector is
  begin
    return a and b;
  end;

  function or_2(a, b: std_logic_vector(31 downto 0)) return std_logic_vector is
  begin
    return a or b;
  end;

  function xor_2(a, b: std_logic_vector(31 downto 0)) return std_logic_vector is
  begin
    return a xor b;
  end;

  function sll_2(a, b: std_logic_vector(31 downto 0)) return std_logic_vector is
    variable amt : integer := to_integer(unsigned(b(4 downto 0)));
  begin
    return std_logic_vector(shift_left(unsigned(a), amt));
  end;

  function srl_2(a, b: std_logic_vector(31 downto 0)) return std_logic_vector is
    variable amt : integer := to_integer(unsigned(b(4 downto 0)));
  begin
    return std_logic_vector(shift_right(unsigned(a), amt));
  end;

  function sra_2(a, b: std_logic_vector(31 downto 0)) return std_logic_vector is
    variable amt : integer := to_integer(unsigned(b(4 downto 0)));
  begin
    return std_logic_vector(shift_right(signed(a), amt));
  end;

  function slt_2(a, b: std_logic_vector(31 downto 0)) return std_logic_vector is
  begin
    if signed(a) < signed(b) then
      return (31 downto 1 => '0') & '1';
    else
      return (others => '0');
    end if;
  end;

  function sltu_2(a, b: std_logic_vector(31 downto 0)) return std_logic_vector is
  begin
    if unsigned(a) < unsigned(b) then
      return (31 downto 1 => '0') & '1';
    else
      return (others => '0');
    end if;
  end;

begin

  process(a, b, sel)
  begin
    case sel is
      when "0000" => s <= add(a, b);       -- ADD
      when "0001" => s <= sub(a, b);       -- SUB
      when "0010" => s <= and_2(a, b);     -- AND
      when "0011" => s <= or_2(a, b);      -- OR
      when "0100" => s <= xor_2(a, b);     -- XOR
      when "0101" => s <= sll_2(a, b);     -- SLL
      when "0110" => s <= srl_2(a, b);     -- SRL
      when "0111" => s <= sra_2(a, b);     -- SRA
      when "1000" => s <= slt_2(a, b);     -- SLT
      when "1001" => s <= sltu_2(a, b);    -- SLTU
      when others => s <= (others => '0');
    end case;
  end process;

end struct;
