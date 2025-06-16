library ieee;
use ieee.std_logic_1164.all;

entity CPU is
	port(clk, reset : in std_logic;
			IR_ins,PC_ins,T1_ins,T2_ins,ALU_C_ins,ALU_A_ins,ALU_B_ins,mad_ins,min_ins,mout_ins : out std_logic_vector(15 downto 0);
			cflag_ins, zflag_ins : out std_logic;
			O0,O1,O2,O3,O4,O5,O6,O7 : out std_logic_vector(15 downto 0));
end entity CPU;

architecture bhv of CPU is
	
	
	component REG is
		port (
			clk   : in std_logic;                     
			Din   : in std_logic_vector(15 downto 0); 
			enable: in std_logic;                     
			Dout  : out std_logic_vector(15 downto 0) 
		);
	end component REG;
	
	component Register_file is
		port ( clk, Enable : in std_logic;
				Data3 : in std_logic_vector(15 downto 0);
				A1, A2, A3 : in std_logic_vector(2 downto 0);
				Data1 : out std_logic_vector(15 downto 0);
				Data2 : out std_logic_vector(15 downto 0);
				O0,O1,O2,O3,O4,O5,O6,O7 : out std_logic_vector(15 downto 0)
				);
	end component Register_file;
	
	component SE_9_to_16 is
		port( A : in std_logic_vector(8 downto 0);
				Y : out std_logic_vector(15 downto 0));
	end component SE_9_to_16;
	
	component SE_6_to_16 is
		port( A : in std_logic_vector(5 downto 0);
				Y : out std_logic_vector(15 downto 0));
	end component SE_6_to_16;
	
	component SE_8_to_16 is
		port( A : in std_logic_vector(7 downto 0);
				Y : out std_logic_vector(15 downto 0));
	end component SE_8_to_16;
	
	component SHIFT8 is
		port( A : in std_logic_vector(7 downto 0);
				Y : out std_logic_vector(15 downto 0));
	end component SHIFT8;
	
	component SHIFT1 is
		port( A : in std_logic_vector(15 downto 0);
				Y : out std_logic_vector(15 downto 0));
	end component SHIFT1;
	
	component ALU is 
		port (A, B: in std_logic_vector(15 downto 0);
				sel: in std_logic_vector(2 downto 0);
				C: out std_logic_vector(15 downto 0);
				zflag,cflag: out std_logic);
	end component ALU;
	
	component Memory is 
		port( 
			clk       : in  std_logic;
			m_wr      : in  std_logic;                
			m_rd      : in  std_logic;                
			mem_addr  : in  std_logic_vector(15 downto 0); 
			mem_in    : in  std_logic_vector(15 downto 0); 
			mem_out   : out std_logic_vector(15 downto 0)  
		); 
	end component Memory;
	
	type state is (RST,S0A,S0B,S1,S2,S3,S4,S5,S6,S7,S8,S9,S10,S11,S12,S13,S14,S15,S16);
	signal y_present, y_next : state := rst;
	
	signal IR_en, PC_en, RF_en, T1_en, T2_en, mem_wr, mem_rd : std_logic;
	signal zflag, cflag : std_logic;
	
	signal PC_in, mem_addr, PC_out, ALU_A, ALU_B, ALU_C, mem_in, IR_out, mem_out, IR_in : std_logic_vector(15 downto 0);
	signal RF_D3, RF_D1, RF_D2, T1_in, T1_out, T2_out, T2_in                            : std_logic_vector(15 downto 0);
	signal RF_A3, RF_A2, RF_A1, ALU_sel                                                 : std_logic_vector(2 downto 0);
	signal opcode                                                                       : std_logic_vector(3 downto 0);
	signal sf1_out, sf2_out, sf3_out, sf2_in, sf3_in, se1_out, se2_out, se3_out         : std_logic_vector(15 downto 0); --intermediate signals
	signal sf1_in, se1_in : std_logic_vector(7 downto 0);
	signal se2_in : std_logic_vector(5 downto 0);
	signal se3_in : std_logic_vector(8 downto 0);
	
begin

	--Instruction register
	IR : REG port map(clk => clk, Din => IR_in, enable => IR_en, Dout => IR_out);

	-- Register File
	registerfile : Register_file port map(	clk => clk,
														Enable => RF_en,
														Data3 => RF_D3,
														A1 => RF_A1,
														A2 => RF_A2,
														A3 => RF_A3,
														Data1 => RF_D1,
														Data2 => RF_D2,
														O0=>O0,O1=>O1,O2=>O2,O3=>O3,O4=>O4,O5=>O5,O6=>O6,O7=>O7
														);
													
	--bit shifting
	sf1 : SHIFT8 port map(A=>sf1_in, Y=>sf1_out);
	sf2 : SHIFT1 port map(A=>sf2_in, Y=>sf2_out);
	sf3 : SHIFT1 port map(A=>sf3_in, Y=>sf3_out);
	--sign extension
	se1 : SE_8_to_16 port map(A=>se1_in, Y=>se1_out);	
	se2 : SE_6_to_16 port map(A=>se2_in, Y=>se2_out);
	se3 : SE_9_to_16 port map(A=>se3_in, Y=>se3_out);
	
	
	--Temparary storage
	T1 : REG port map(clk=>clk, Din=>T1_in, Dout=>T1_out, enable=>T1_en);
	T2 : REG port map(clk=>clk, Din=>T2_in, Dout=>T2_out, enable=>T2_en);
	
	--ALU
	op : ALU port map(A=>ALU_A, B=>ALU_B, sel=>ALU_sel, zflag=>zflag, cflag=>cflag, c=>ALU_C);
	
	
	--Memory
	mem : Memory port map(m_wr=>mem_wr, m_rd=>mem_rd, clk=>clk, mem_out=>mem_out, mem_addr=>mem_addr, mem_in=>mem_in);

	-- Program Counter
	PC : REG port map(Din => PC_in, Dout => PC_out, clk => clk, enable => PC_en);
	
	opcode <= IR_out(15 downto 12) ;

	clock_proc: process(clk)
    begin
        if (clk = '1' and clk'event) then
				if reset ='1' then
					y_present <= rst;
				else
					y_present <= y_next;
				end if;
        end if;
    end process;
	 
	 state_transition_proc: process(opcode, zflag, y_present)
	 begin
        y_next <= y_present;  
		  
        case y_present is
				
				when rst =>
						y_next <= s0a;
						
				
				when s0a =>
					case opcode is
						when "1101" =>		--JAL
								y_next <= s13;
						when "1111" =>		--JLR
								y_next <= s12;
						when "1110" =>   --J
								y_next <= s1;
						when "1100" =>   --BEQ
								y_next <= s1;
						when others =>
								y_next <= s0b;
					END CASE;
			
            when s0b =>
                case opcode is 
						when "1000" =>		--LHI
								y_next <= s14;
						when "1001" =>		--LLI
								y_next <= s15;
						when "0000"|"0010"|"0011"|"0100"|"0101"|"0110"|"0001" =>
								y_next <= s1;
						when "1010"|"1011" =>
								y_next <= s16;
                  when others =>
								y_next <= s0a;
					end case;
					
				when s1 =>
					case opcode is
						when "1110" => 	--J
							y_next <= s13;
						when "1100" =>		--BEQ
							y_next <= s8;
						when "0001"|"1010"|"1011" => --ADI,LOAD,STORE
							y_next <= s4;
						when "0000"|"0010"|"0011"|"0100"|"0101"|"0110" =>
							y_next <= s2;
						when others =>
							y_next <= s0a;
					end case;
					
				when s2 =>
					case opcode is
						when "0000"|"0010"|"0011"|"0100"|"0101"|"0110" =>  --ADD/SUB/MUL/AND/ORA/IMP
							y_next <= s3;
						when others =>
							null;
					end case;
					
				when s3 =>
					y_next <= s0a;
					
				when s16 =>
						y_next <= s4;
				
				when s4 =>
					case opcode is
						when "1010" =>    --LOAD
							y_next <= s5;
						when "1011" =>		--STORE
							y_next <= s7;
						when "0001" =>		--ADI
							y_next <= s10;
						when others =>
							null;
					end case;
				
				when s5 =>     --LOAD
					y_next <= s6;
				
				
				when s6 =>
					y_next <= s0a;
				
				when s7 =>
					y_next <= s0a;
					
				when s8 =>
					if zflag = '1' then
						y_next <= s9;
					else
						y_next <= s0b;
					end if;
				
				when s9 =>
					if opcode = "1101" then
						y_next <= s11;		--JAL
					else
						y_next <= s0a;
					end if;
					
				when s10 =>
					y_next <= s0a;
					
				when s11 =>
					y_next <= s0a;
				
				when s12 =>
					y_next <= s11;
				
				when s13 =>
					if opcode = "1101" then
						y_next <= s11;
					else 
						y_next <= s0a;
					end if;
				
				when s14 =>
					y_next <= s0a;
				
				when s15 =>
					y_next <= s0a;
					
				when others =>
					null;
			end case;
		end process;
	
	
	-- State Machine Logic
	state_pr : process(y_present, IR_en, PC_en, RF_en, T1_en, T2_en, mem_wr, mem_rd, RF_D1, RF_D2, ALU_C, zflag, mem_out, T1_out, T2_out, IR_out,PC_out, sf1_out, sf2_out, sf3_out, se1_out, se2_out, se3_out)
	begin
		
		-- Initialize signals
		se1_in <= (others => '0');
		se2_in <= (others => '0');
		se3_in <= (others => '0');
		sf1_in <= (others => '0');
		sf2_in <= (others => '0');
		sf3_in <= (others => '0');
		IR_in <= (others => '0');
		PC_in <= (others => '0');
		T1_in <= (others => '0');
		T2_in <= (others => '0');
		RF_A1 <= (others => '0');
		RF_A2 <= (others => '0');
		RF_A3 <= (others => '0');
		RF_D3 <= (others => '0');
		mem_addr <= (others => '0');
		mem_in <= (others => '0');
		--ALU_A <= (others => '0');
		--ALU_B <= (others => '0');
		--ALU_sel <= "000";
		
	
		IR_en <= '0';
		PC_en <= '0';
		RF_en <= '0';
		T1_en <= '0';
		T2_en <= '0';
		mem_rd <= '0';
		mem_wr <= '0';
		
		case y_present is
				
			when rst => --rst
					PC_en  <= '1';  
					IR_en  <= '0';	RF_en <= '0';	T1_en <= '0'; T2_en <= '0';
					mem_rd <= '0';	mem_wr <= '0';
					PC_in <= "0000000000000000";
										
			when s0a => --s0a
					PC_en  <= '0';  
					IR_en  <= '1';	RF_en <= '0';	T1_en <= '0'; T2_en <= '0';
					mem_rd <= '1';	mem_wr <= '0';
					mem_addr <= PC_out;
					IR_in <= mem_out;
													
			when s0b => --s0b
					PC_en  <= '1';  
					IR_en  <= '0';	RF_en <= '0';	T1_en <= '0'; T2_en <= '0';
					mem_rd <= '0';	mem_wr <= '0';
					ALU_A <= PC_out;
					ALU_B <= "0000000000000010";
					ALU_sel <= "000";
					PC_in <= ALU_C;
							
			when s1 => --s1
					PC_en  <= '0';  
					IR_en  <= '0';	RF_en <= '0';	T1_en <= '1'; T2_en <= '1';
					mem_rd <= '0';	mem_wr <= '0';
					RF_A1 <= IR_out(11 downto 9);
					RF_A2 <= IR_out(8 downto 6);
					T1_in <= RF_D1;
					T2_in <= RF_D2;
					
			when s2 => --s2
					PC_en  <= '0';  
					IR_en  <= '0';	RF_en <= '0';	T1_en <= '1'; T2_en <= '0';
					mem_rd <= '0';	mem_wr <= '0';
					ALU_A <= T1_out;
					ALU_B <= T2_out;
					ALU_sel <= IR_out(14 downto 12);
					T1_in <= ALU_C;
					
				
			when s3 => --s3
					PC_en  <= '0';  
					IR_en  <= '0';	RF_en <= '1';	T1_en <= '0'; T2_en <= '0';
					mem_rd <= '0';	mem_wr <= '0';
					RF_D3 <= T1_out;
					RF_A3 <= IR_out(5 downto 3);
					
			when s16 => --s16
					PC_en  <= '0';  
					IR_en  <= '0';	RF_en <= '0';	T1_en <= '1'; T2_en <= '1';
					mem_rd <= '0';	mem_wr <= '0';
					RF_A2 <= IR_out(8 downto 6);
					T1_in <= RF_D2;
					RF_A1 <= IR_out(11 downto 9);
					T2_in <= RF_D1;
					
					
			when s4 => --s4
					PC_en  <= '0';  
					IR_en  <= '0';	RF_en <= '0';	T1_en <= '1'; T2_en <= '0';
					mem_rd <= '0';	mem_wr <= '0';
					ALU_A <= T1_out;
					se2_in <= IR_out(5 downto 0);
					ALU_B <= se2_out;
					T1_in <= ALU_C;
					ALU_sel <= "000";
					
			when s5 => --s5
					PC_en  <= '0';  
					IR_en  <= '0';	RF_en <= '0';	T1_en <= '1'; T2_en <= '0';
					mem_rd <= '1';	mem_wr <= '0';
					mem_addr <= T1_out;
					T1_in <= mem_out;
			
			when s6 => --s6
					PC_en  <= '0';  
					IR_en  <= '0';	RF_en <= '1';	T1_en <= '0'; T2_en <= '0';
					mem_rd <= '0';	mem_wr <= '0';
					RF_A3 <= IR_out(11 downto 9);
					RF_D3 <= T1_out;		
			
			when s7 => --s7
					PC_en  <= '0';  
					IR_en  <= '0';	RF_en <= '0';	T1_en <= '0'; T2_en <= '0';
					mem_rd <= '0';	mem_wr <= '1';
					mem_addr <= T1_out;
					mem_in <= T2_out;
			
			when s8 => --s8
					PC_en  <= '0';  
					IR_en  <= '0';	RF_en <= '0';	T1_en <= '0'; T2_en <= '0';
					mem_rd <= '0';	mem_wr <= '0';
					ALU_A <= T1_out;
					ALU_B <= T2_out;
					ALU_sel <= "010";
					
			
			when s9 => --s9
					PC_en  <= '1';  
					IR_en  <= '0';	RF_en <= '0';	T1_en <= '0'; T2_en <= '0';
					mem_rd <= '0';	mem_wr <= '0';
					ALU_A <= PC_out;
					se2_in <= IR_out(5 downto 0);
					sf2_in <= se2_out;
					ALU_B <= sf2_out;
					ALU_sel <= "000";
					PC_in <= ALU_C;	
								
			when s10 => --s10
					PC_en  <= '0';  
					IR_en  <= '0';	RF_en <= '1';	T1_en <= '0'; T2_en <= '0';
					mem_rd <= '0';	mem_wr <= '0';
					RF_A3 <= IR_out(8 downto 6);
					RF_D3 <= T1_out;
			
			when s11 => --s11
					PC_en  <= '0';  
					IR_en  <= '0';	RF_en <= '1';	T1_en <= '0'; T2_en <= '0';
					mem_rd <= '0';	mem_wr <= '0';
					RF_A3 <= IR_out(11 downto 9);
					RF_D3 <= PC_out;
			
			when s12 => --s12
					PC_en  <= '1';  
					IR_en  <= '0';	RF_en <= '0';	T1_en <= '0'; T2_en <= '0';
					mem_rd <= '0';	mem_wr <= '0';
					RF_A2 <= IR_out(8 downto 6);
					PC_in <= RF_D2;
			
			when s13 => --s13
					PC_en  <= '1';  
					IR_en  <= '0';	RF_en <= '0';	T1_en <= '0'; T2_en <= '0';
					mem_rd <= '0';	mem_wr <= '0';
					ALU_A <= PC_out;
					se3_in <= IR_out(8 downto 0);
					sf3_in <= se3_out;
					ALU_B <= sf3_out;
					ALU_sel <= "000";
					PC_in <= ALU_C;
			
			when s14 => --s14
					PC_en  <= '0';  
					IR_en  <= '0';	RF_en <= '1';	T1_en <= '0'; T2_en <= '0';
					mem_rd <= '0';	mem_wr <= '0';
					RF_A3 <= IR_out(11 downto 9);
					sf1_in <= IR_out(7 downto 0);
					RF_D3 <= sf1_out;
			
			when s15 => --s15
					PC_en  <= '0';  
					IR_en  <= '0';	RF_en <= '1';	T1_en <= '0'; T2_en <= '0';
					mem_rd <= '0';	mem_wr <= '0';
					RF_A3 <= IR_out(11 downto 9);
					se1_in <= IR_out(7 downto 0);
					RF_D3 <= se1_out;
					
			when others =>
					null;
		
		end case;
	end process;
	
	IR_ins<=IR_out;
	PC_ins<=PC_out;
	cflag_ins<=cflag;
	zflag_ins<=zflag;
	T1_ins<=T1_out;
	T2_ins<=T2_out;
	ALU_A_ins<=ALU_A;
	ALU_B_ins<=ALU_B;
	ALU_C_ins<=ALU_C;
	mad_ins<=mem_addr;
	min_ins<=mem_in;
	mout_ins<=mem_out;
	
	
	
end architecture bhv;