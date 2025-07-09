library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use work.decode_types.all;

entity alu_ex is
	port(
		ex_instr1   : in decoded_instruction;
		ex_valid1   : in std_logic;
		
		ex_instr2   : in decoded_instruction;
		ex_valid2   : in std_logic;
		
		rs1_1_data  : in std_logic_vector(31 downto 0);
	   rs2_1_data  : in std_logic_vector(31 downto 0);
		rs1_2_data  : in std_logic_vector(31 downto 0);
		rs2_2_data  : in std_logic_vector(31 downto 0);
			
		rs1_1       : out  std_logic_vector(4 downto 0);
	   rs2_1       : out  std_logic_vector(4 downto 0);
	   rs1_2       : out  std_logic_vector(4 downto 0);
	   rs2_2       : out  std_logic_vector(4 downto 0);
		
		alu_res1    : out  std_logic_vector(31 downto 0);   
		alu_res2    : out  std_logic_vector(31 downto 0);  
		
		br_taken1   : out  std_logic;
		br_target1  : out  std_logic_vector(31 downto 0);
		
		br_taken2   : out  std_logic;
		br_target2  : out  std_logic_vector(31 downto 0);
		
		instr1_out  : out  decoded_instruction;
		instr2_out  : out  decoded_instruction;
		flush_ex1   : out  std_logic;
		flush_ex2   : out  std_logic;		
		
		flush_ex    : out std_logic;
		
		rs2_1_val   : out std_logic_vector(31 downto 0);
		rs2_2_val   : out std_logic_vector(31 downto 0)
		);
end entity;

architecture str of alu_ex is
	component alu is
	  port (
		 a, b : in std_logic_vector(31 downto 0);
		 sel  : in std_logic_vector(3 downto 0); -- ALU operation selector
		 s    : out std_logic_vector(31 downto 0)
	  );
	end component;
	
	component branch_unit is
	  port (
		 rs1    : in std_logic_vector(31 downto 0);
		 rs2    : in std_logic_vector(31 downto 0);
		 funct3 : in std_logic_vector(2 downto 0);
		 taken  : out std_logic
	  );
	end component;
	
	signal alu1_in1   : std_logic_vector(31 downto 0);
	signal alu1_in2    : std_logic_vector(31 downto 0);
	
	signal alu2_in1   : std_logic_vector(31 downto 0);
	signal alu2_in2   :  std_logic_vector(31 downto 0);
	
	signal alu1_out  : std_logic_vector(31 downto 0);
	signal alu2_out  :  std_logic_vector(31 downto 0);
	
	signal in_type1 : instr_type_enum;
	signal in_type2 : instr_type_enum;
	
	signal br_taken1_i : std_logic;
	signal br_taken2_i : std_logic;
	
	signal br_target1_i : std_logic_vector(31 downto 0);
	signal br_target2_i : std_logic_vector(31 downto 0);
	
begin
	alu_1: alu port map(
		a    =>  alu1_in1,
		b    =>  alu1_in2, 
		sel  =>  ex_instr1.alu_op,
		s    =>  alu1_out 
	);
	
	alu_2: alu port map(
		a    =>   alu2_in1,
		b    =>   alu2_in2,
		sel  =>   ex_instr2.alu_op,
		s    =>   alu2_out 
	);
	
	br_cmp1: branch_unit
	  port map (
		 rs1    => rs1_1_data,
		 rs2    => rs2_1_data,
		 funct3 => ex_instr1.funct3,
		 taken  => br_taken1_i
	  );

	br_cmp2: branch_unit
	  port map (
		 rs1    => rs1_2_data,
		 rs2    => rs2_2_data,
		 funct3 => ex_instr2.funct3,
		 taken  => br_taken2_i
	  );
	
	in_type1 <= ex_instr1.instr_type;
	in_type2 <= ex_instr2.instr_type;
	
 ex1:  process(ex_instr1, ex_valid1, rs1_1_data, rs2_1_data)
  begin
   
    if ex_valid1 = '0' then
      alu_res1   <= (others => '0');

    else
      case in_type1 is
        when R =>
          alu1_in1   <= rs1_1_data;
          alu1_in2   <= rs2_1_data;
          alu_res1   <= alu1_out;
			 
        when I =>
          alu1_in1   <= rs1_1_data;
          alu1_in2   <= ex_instr1.imm;
          alu_res1   <= alu1_out;


        when S =>
          alu1_in1   <= rs1_1_data;
          alu1_in2   <= ex_instr1.imm;
          alu_res1   <= alu1_out;

         

        when B =>
          alu1_in1   <= ex_instr1.pc;
          alu1_in2   <= ex_instr1.imm;
          alu_res1   <= (others => '0');
			 br_target1_i <= alu1_out;
			 
        when J =>
          alu1_in1   <= ex_instr1.pc;
          alu1_in2   <= ex_instr1.imm;
          alu_res1   <= alu1_out;
          
			
		  when U_LUI =>
			  alu1_in1   <= (others => '0');
			  alu1_in2   <= ex_instr1.imm;
			  alu_res1   <= alu1_out;
			

		  when U_AUIPC =>
			  alu1_in1   <= ex_instr1.pc;
			  alu1_in2   <= ex_instr1.imm;
			  alu_res1   <= alu1_out;

			 
        when others =>
          alu1_in1   <= (others => '0');
          alu1_in2   <= (others => '0');
          alu_res1   <= (others => '0');
      end case;
    end if;
  end process;
	
ex2: process(ex_instr2, ex_valid2, rs1_2_data, rs2_2_data)
   begin

	 if ex_valid2 = '0' then
		alu_res2   <= (others => '0');
		
	 else
      case in_type2 is
        when R =>
          alu2_in1   <= rs1_2_data;
          alu2_in2   <= rs2_2_data;
          alu_res2   <= alu2_out;
        
        when I =>
          alu2_in1   <= rs1_2_data;
          alu2_in2   <= ex_instr2.imm;
          alu_res2   <= alu2_out;


        when S =>
          alu2_in1   <= rs1_2_data;
          alu2_in2   <= ex_instr2.imm;
          alu_res2   <= alu2_out;

        when B =>
          alu2_in1 <= rs1_2_data;
          alu2_in2 <= ex_instr2.imm;
          alu_res2 <= (others => '0');
		    br_target2_i <= alu2_out;

        when  J =>
          alu2_in1   <= ex_instr2.pc;
          alu2_in2   <= ex_instr2.imm;
          alu_res2   <= alu2_out;
						 
		  when U_LUI =>
			  alu2_in1   <= (others => '0');
			  alu2_in2   <= ex_instr2.imm;
			  alu_res2   <= alu2_out;


		  when U_AUIPC =>
			  alu2_in1   <= ex_instr2.pc;
			  alu2_in2   <= ex_instr2.imm;
			  alu_res2   <= alu2_out;


        when others =>
          alu2_in1   <= (others => '0');
          alu2_in2   <= (others => '0');
          alu_res2   <= (others => '0');

      end case;
    end if;
  end process;
  
   br_taken1  <= br_taken1_i  when in_type1 = B else '0';
   br_target1 <= br_target1_i when in_type1 = B else (others=>'0');
   rs1_1      <= ex_instr1.rs1;--for reg_file addr
   rs2_1      <= ex_instr1.rs2;
   instr1_out <= ex_instr1;
	flush_ex1  <= '1' when ex_valid1='0' or br_taken1_i='1' else '0';
	rs2_1_val  <= rs2_1_data;-- for mem_stage
		
	br_taken2  <= br_taken2_i  when in_type2 = B else '0';
   br_target2 <= br_target2_i when in_type2 = B else (others=>'0');
   rs1_2      <= ex_instr2.rs1;
   rs2_2      <= ex_instr2.rs2;
   instr2_out <= ex_instr2;
	flush_ex2  <= '1' when ex_valid2='0' or br_taken1_i='1' or br_taken2_i='1' else '0';
	rs2_2_val  <= rs2_2_data;-- for mem_stage

	flush_ex <= '1' when br_taken1_i='1' or br_taken2_i='1' else '0';
end str;