library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use work.decode_types.all;

entity inst_dec is
	port(
		instr1_ID: in std_logic_vector(31 downto 0);
		instr2_ID: in std_logic_vector(31 downto 0);
		PC1_ID   : in std_logic_vector(31 downto 0);
		PC2_ID   : in std_logic_vector(31 downto 0);
		stall_ID : in std_logic;
		flush_ID : in std_logic;
		reset_ID : in std_logic;
		fetch_valid : in std_logic;
		
		valid_decode1 : out std_logic;
		valid_decode2 : out std_logic;
		stall_fetch  : out std_logic;
		decoded1_out : out decoded_instruction;
      decoded2_out : out decoded_instruction
  );
end entity;

architecture bhv of inst_dec is 
	signal opcode1    : std_logic_vector(6 downto 0);
	signal imm1       : std_logic_vector(31 downto 0);
	signal alu_op1    : std_logic_vector(3 downto 0);
	signal IRtype1    : instr_type_enum;
	signal valid_bit1 : std_logic;
	signal reg_write1 : std_logic;
	signal mem_read1  : std_logic;
	signal mem_write1 : std_logic;
	signal alu_src1   : std_logic;
	signal branch1    : std_logic;
	signal jump1      : std_logic;	
	signal valid_bit1_flushed :std_logic;
	
	
	signal opcode2    : std_logic_vector(6 downto 0);
	signal imm2       : std_logic_vector(31 downto 0);
	signal alu_op2    : std_logic_vector(3 downto 0);
	signal IRtype2    : instr_type_enum;
	signal valid_bit2 : std_logic;
	signal reg_write2 : std_logic;
	signal mem_read2  : std_logic;
	signal mem_write2 : std_logic;
	signal alu_src2   : std_logic;
	signal branch2    : std_logic;
	signal jump2      : std_logic;	
	signal valid_bit2_flushed :std_logic;

begin 
	opcode1   <= instr1_ID(6 downto 0);	
	opcode2   <= instr2_ID(6 downto 0);

	proc1: process(opcode1,instr1_ID)
	begin
		case opcode1 is
			when "0110111" => 
				imm1       <=(instr1_ID(31 downto 12))& "000000000000";
				IRtype1    <= U_LUI;
				valid_bit1 <='1';
				alu_src1   <='1';
				reg_write1 <='1';
				mem_read1  <='0';
				mem_write1 <='0';
				branch1    <='0';
				jump1      <='0';
				alu_op1    <="0000";
				
			
			when "0010111" =>
				imm1       <=(instr1_ID(31 downto 12))& "000000000000";
				IRtype1    <= U_AUIPC;
				valid_bit1 <='1';
				alu_src1   <='1';
				reg_write1 <='1';
				mem_read1  <='0';
				mem_write1 <='0';
				branch1    <='0';
				jump1      <='1';
				alu_op1    <="0000";	
				
				
			
			when "1101111" =>
				imm1       <=(11 downto 0=>instr1_ID(31))&(instr1_ID(19 downto 12))&instr1_ID(20)&(instr1_ID(30 downto 21))&"0";
				IRtype1    <= J;
				valid_bit1 <='1';
				alu_src1   <='1';
				reg_write1 <='1';
				mem_read1  <='0';
				mem_write1 <='0';
				branch1    <='0';
				jump1      <='1';
				alu_op1    <="0000";
				
			
			when "1100011" =>
				imm1       <=(19 downto 0=>instr1_ID(31))&instr1_ID(7)&(instr1_ID(30 downto 25))&(instr1_ID(11 downto 8))&"0";
				IRtype1    <= B;
				valid_bit1 <='1';
				alu_src1   <='0';
				reg_write1 <='0';
				mem_read1  <='0';
				mem_write1 <='0';
				branch1    <='1';
				jump1      <='0';
				alu_op1    <="0000";
				
			when "1100111" =>--JALR
				imm1       <=(19 downto 0=>instr1_ID(31))&(instr1_ID(31 downto 20));
				IRtype1    <= I;
				valid_bit1 <='1';
				alu_src1   <='1';
				reg_write1 <='1';
				mem_read1  <='0';
				mem_write1 <='0';
				branch1    <='0';
				jump1      <='1';
				alu_op1    <="0000";
				
			when "0000011" =>--LOAD
				imm1       <=(19 downto 0=>instr1_ID(31))&(instr1_ID(31 downto 20));
				IRtype1    <= I;
				valid_bit1 <='1';
				alu_src1   <='1';
				reg_write1 <='1';
				mem_read1  <='1';
				mem_write1 <='0';
				branch1    <='0';
				jump1      <='1';
				alu_op1    <="0000";

			
			when "0010011" =>
				imm1       <=(19 downto 0=>instr1_ID(31))&(instr1_ID(31 downto 20));
				IRtype1    <= I;
				valid_bit1 <='1';
				alu_src1   <='1';
				reg_write1 <='1';
				mem_read1  <='0';
				mem_write1 <='0';
				branch1    <='0';
				jump1      <='1';
				
					case instr1_ID(14 downto 12) is
						when "000" => 
							if instr1_ID(30) = '0' then
								 alu_op1 <= "0000"; -- ADDI
							  else
								 alu_op1 <= "0001"; -- SUBI
							end if;
						
						when "101" => 
							if instr1_ID(30) = '0' then
								 alu_op1 <= "0110"; -- SRLI
							  else
								 alu_op1 <= "0111"; -- SRAI
							end if;
							
						when "001" => alu_op1 <= "0101";--SLLI
						when "010" => alu_op1 <= "1000";--SLTI
						when "011" => alu_op1 <= "1001";--SLTUI
						when "100" => alu_op1 <= "0100";--XORI
						when "110" => alu_op1 <= "0011";--ORI
						when "111" => alu_op1 <= "0010";--ANDI
						when others=> alu_op1 <= "0000";
					end case;
				
				
			when "0100011"=>
				imm1       <=(19 downto 0=>instr1_ID(31))&(instr1_ID(31 downto 25))&(instr1_ID(11 downto 7));
				IRtype1    <= S;
				valid_bit1 <='1';
				alu_src1   <='1';
				reg_write1 <='0';
				mem_read1  <='0';
				mem_write1 <='1';
				branch1    <='0';
				jump1      <='0';
				alu_op1    <="0000";		
				
			
			when "0110011"=>
				imm1       <=(others=>'0');
				IRtype1    <=R;
				valid_bit1 <='1';
				alu_src1   <='0';
				reg_write1 <='1';
				mem_read1  <='0';
				mem_write1 <='0';
				branch1    <='0';
				jump1      <='0';
				
				case instr1_ID(14 downto 12) is
					when "000" => 
							if instr1_ID(30) = '0' then
								 alu_op1 <= "0000"; -- ADD
							  else
								 alu_op1 <= "0001"; -- SUB
							end if;
						
					when "101" => 
						if instr1_ID(30) = '0' then
							 alu_op1 <= "0110"; -- SRL
						  else
							 alu_op1 <= "0111"; -- SRA
						end if;
						
					when "001" => alu_op1 <= "0101";--SLL
					when "010" => alu_op1 <= "1000";--SLT
					when "011" => alu_op1 <= "1001";--SLTU
					when "100" => alu_op1 <= "0100";--XOR
					when "110" => alu_op1 <= "0011";--OR
					when "111" => alu_op1 <= "0010";--AND
					when others=> alu_op1 <= "0000";
				end case;
				
			
			when "0001111"|"1110011"=>
				imm1       <=(19 downto 0=>instr1_ID(31))&(instr1_ID(31 downto 20));
				IRtype1    <=I;
				valid_bit1 <='1';
				alu_src1   <='1';
				reg_write1 <='0';
				mem_read1  <='1';
				mem_write1 <='0';
				branch1    <='0';
				jump1      <='0';
				alu_op1    <="0000";		
			
			when others=>
				imm1       <=(others=>'0');
			   IRtype1    <=INVALID;	
				valid_bit1 <='0';
				alu_src1   <='0';
				reg_write1 <='0';
				mem_read1  <='0';
				mem_write1 <='0';
				branch1    <='0';
				jump1      <='0';
				alu_op1    <="0000";		
				

		end case;
	end process;
	
	proc2: process(opcode2,instr2_ID)
	begin
		 case opcode2 is

			  when "0110111" =>  -- LUI
					imm2       <= instr2_ID(31 downto 12) & "000000000000";
					IRtype2    <= U_LUI;
					valid_bit2 <= '1';
					alu_src2   <= '1';
					reg_write2 <= '1';
					mem_read2  <= '0';
					mem_write2 <= '0';
					branch2    <= '0';
					jump2      <= '0';
					alu_op2    <="0000";	

			  when "0010111" =>  -- AUIPC
					imm2       <= instr2_ID(31 downto 12) & "000000000000";
					IRtype2    <= U_AUIPC;
					valid_bit2 <= '1';
					alu_src2   <= '1';
					reg_write2 <= '1';
					mem_read2  <= '0';
					mem_write2 <= '0';
					branch2    <= '0';
					jump2      <= '1';
					alu_op2    <="0000";	

			  when "1101111" =>  -- JAL
					imm2       <= (11 downto 0 => instr2_ID(31)) & instr2_ID(19 downto 12) & instr2_ID(20) & instr2_ID(30 downto 21) & '0';
					IRtype2    <= J;
					valid_bit2 <= '1';
					alu_src2   <= '1';
					reg_write2 <= '1';
					mem_read2  <= '0';
					mem_write2 <= '0';
					branch2    <= '0';
					jump2      <= '1';
					alu_op2    <="0000";	

			  when "1100011" =>  -- Branch (BEQ, etc.)
					imm2       <= (19 downto 0 => instr2_ID(31)) & instr2_ID(7) & instr2_ID(30 downto 25) & instr2_ID(11 downto 8) & '0';
					IRtype2    <= B;
					valid_bit2 <= '1';
					alu_src2   <= '0';
					reg_write2 <= '0';
					mem_read2  <= '0';
					mem_write2 <= '0';
					branch2    <= '1';
					jump2      <= '0';
					alu_op2    <= "0000";

			  when "1100111" =>  -- JALR
					imm2       <= (19 downto 0 => instr2_ID(31)) & instr2_ID(31 downto 20);
					IRtype2    <= I;
					valid_bit2 <= '1';
					alu_src2   <= '1';
					reg_write2 <= '1';
					mem_read2  <= '0';
					mem_write2 <= '0';
					branch2    <= '0';
					jump2      <= '1';
			      alu_op2    <="0000";	

			  when "0000011" =>  -- Load
					imm2       <= (19 downto 0 => instr2_ID(31)) & instr2_ID(31 downto 20);
					IRtype2    <= I;
					valid_bit2 <= '1';
					alu_src2   <= '1';
					reg_write2 <= '1';
					mem_read2  <= '1';
					mem_write2 <= '0';
					branch2    <= '0';
					jump2      <= '0';
					alu_op2    <="0000";

			  when "0010011" =>  -- I-type ALU
					imm2       <= (19 downto 0 => instr2_ID(31)) & instr2_ID(31 downto 20);
					IRtype2    <= I;
					valid_bit2 <= '1';
					alu_src2   <= '1';
					reg_write2 <= '1';
					mem_read2  <= '0';
					mem_write2 <= '0';
					branch2    <= '0';
					jump2      <= '0';
					
					case instr2_ID(14 downto 12) is
						when "000" => 
							if instr2_ID(30) = '0' then
								 alu_op2 <= "0000"; -- ADDI
							  else
								 alu_op2 <= "0001"; -- SUBI
							end if;
						
						when "101" => 
							if instr2_ID(30) = '0' then
								 alu_op2 <= "0110"; -- SRLI
							  else
								 alu_op2 <= "0111"; -- SRAI
							end if;
							
						when "001" => alu_op2 <= "0101";--SLLI
						when "010" => alu_op2 <= "1000";--SLTI
						when "011" => alu_op2 <= "1001";--SLTUI
						when "100" => alu_op2 <= "0100";--XORI
						when "110" => alu_op2 <= "0011";--ORI
						when "111" => alu_op2 <= "0010";--ANDI
						when others=> alu_op2 <= "0000";
					end case;
				

			  when "0100011" =>  -- Store
					imm2       <= (19 downto 0 => instr2_ID(31)) & instr2_ID(31 downto 25) & instr2_ID(11 downto 7);
					IRtype2    <= S;
					valid_bit2 <= '1';
					alu_src2   <= '1';
					reg_write2 <= '0';
					mem_read2  <= '0';
					mem_write2 <= '1';
					branch2    <= '0';
					jump2      <= '0';
					alu_op2    <="0000";

			  when "0110011" =>  -- R-type
					imm2       <= (others => '0');
					IRtype2    <= R;
					valid_bit2 <= '1';
					alu_src2   <= '0';
					reg_write2 <= '1';
					mem_read2  <= '0';
					mem_write2 <= '0';
					branch2    <= '0';
					jump2      <= '0';
						
					case instr2_ID(14 downto 12) is
					
						when "000" => 
							if instr2_ID(30) = '0' then
								 alu_op2 <= "0000"; -- ADD
							  else
								 alu_op2 <= "0001"; -- SUB
							end if;
						
						when "101" => 
							if instr2_ID(30) = '0' then
								 alu_op2 <= "0110"; -- SRL
							  else
								 alu_op2 <= "0111"; -- SRA
							end if;
						
						when "001" => alu_op2 <= "0101";--SLL
						when "010" => alu_op2 <= "1000";--SLT
						when "011" => alu_op2 <= "1001";--SLTU
						when "100" => alu_op2 <= "0100";--XOR
						when "110" => alu_op2 <= "0011";--OR
						when "111" => alu_op2 <= "0010";--AND
						when others=> alu_op2 <= "0000";
					end case;
					

			  when "0001111" | "1110011" =>  -- FENCE/SYSTEM
					imm2       <= (19 downto 0 => instr2_ID(31)) & instr2_ID(31 downto 20);
					IRtype2    <= I;
					valid_bit2 <= '1';
					alu_src2   <= '1';
					reg_write2 <= '0';
					mem_read2  <= '1';
					mem_write2 <= '0';
					branch2    <= '0';
					jump2      <= '0';
					alu_op2    <="0000";

			  when others =>
					imm2       <= (others => '0');
					IRtype2    <= INVALID;
					valid_bit2 <= '0';
					alu_src2   <= '0';
					reg_write2 <= '0';
					mem_read2  <= '0';
					mem_write2 <= '0';
					branch2    <= '0';
					jump2      <= '0';
					alu_op2    <="0000";

		 end case;
	end process;
		

	
	 valid_bit1_flushed   <= valid_bit1 and not flush_ID and not stall_ID and not reset_ID and fetch_valid;
	 valid_bit2_flushed   <= valid_bit2 and not flush_ID and not stall_ID and not reset_ID and fetch_valid;
	
	stall_fetch <= stall_ID;
	valid_decode1 <= valid_bit1_flushed; 
	valid_decode2 <= valid_bit2_flushed; 
	
	decoded1_out.opcode     <= instr1_ID(6 downto 0)   ;
	decoded1_out.rs1        <= instr1_ID(19 downto 15) ;
	decoded1_out.rs2        <= instr1_ID(24 downto 20) ;
	decoded1_out.rd         <= instr1_ID(11 downto 7)  ;
	decoded1_out.funct3     <= instr1_ID(14 downto 12) ;
	decoded1_out.funct7     <= instr1_ID(31 downto 25) ;
	decoded1_out.alu_op     <= alu_op1                 ;
	decoded1_out.pc         <= PC1_ID                  ;
	decoded1_out.imm        <= imm1                    ;
	decoded1_out.instr_type <= IRtype1                 ;
	decoded1_out.valid      <= valid_bit1_flushed      ;
	decoded1_out.reg_write  <= reg_write1              ;
	decoded1_out.alu_src    <= alu_src1                ;
	decoded1_out.mem_read   <= mem_read1               ;
	decoded1_out.mem_write  <= mem_write1              ;
	decoded1_out.branch     <= branch1                 ;
	decoded1_out.jump       <= jump1                   ;

	 
	 

	decoded2_out.opcode     <= instr2_ID(6 downto 0)   ;
	decoded2_out.rs1        <= instr2_ID(19 downto 15) ;
	decoded2_out.rs2        <= instr2_ID(24 downto 20) ;
	decoded2_out.rd         <= instr2_ID(11 downto 7)  ;
	decoded2_out.funct3     <= instr2_ID(14 downto 12) ;
	decoded2_out.funct7     <= instr2_ID(31 downto 25) ;
	decoded2_out.alu_op     <= alu_op2                 ;
	decoded2_out.pc         <= PC2_ID                  ;
	decoded2_out.imm        <= imm2                    ;
	decoded2_out.instr_type <= IRtype2                 ;
	decoded2_out.valid      <= valid_bit2_flushed      ;
	decoded2_out.reg_write  <= reg_write2              ;
	decoded2_out.alu_src    <= alu_src2                ;
	decoded2_out.mem_read   <= mem_read2               ;
	decoded2_out.mem_write  <= mem_write2              ;
	decoded2_out.branch     <= branch2                 ;
	decoded2_out.jump       <= jump2                   ;

		
end bhv;			
	