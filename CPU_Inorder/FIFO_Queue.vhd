library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use work.decode_types.all;

entity FIFO_Queue is
	generic (
		queue_size : integer := 8
	);
	port(
		FIFO_clk      : in std_logic;
		FIFO_reset    : in std_logic;
		decoded_instr1: in decoded_instruction;
		decoded_instr2: in decoded_instruction;
		decoded_valid1: in std_logic;
		decoded_valid2: in std_logic;
		
		stall_FIFO    : in std_logic;
		flush_FIFO    : in std_logic;
		
		FIFO_out1     : out decoded_instruction;
		FIFO_out2     : out decoded_instruction;
		FIFO_valid1   : out std_logic;
		FIFO_valid2   : out std_logic;
		
		stall_dec     : out std_logic
	);
	
end entity;

architecture behv of FIFO_Queue is 
   type queue_type is array (0 to queue_size - 1) of decoded_instruction;
	signal queue : queue_type;
	signal head  : integer :=0;
	signal tail  : integer :=0;
	signal count : integer :=0;
	signal valid_queue : std_logic;
	signal full  : std_logic;
	signal empty : std_logic;
	
begin
	process(FIFO_clk,FIFO_reset,flush_FIFO)
	begin
		if FIFO_reset = '1' or flush_FIFO ='1' then
					head  <= 0;
					tail  <= 0;
					count <= 0;
				
		elsif rising_edge(FIFO_clk) then
					if count >= 2 and stall_FIFO='0' then
						FIFO_out1 <= queue(head);
						FIFO_out2 <= queue((head+1) mod queue_size);
						head <= (head + 2) mod queue_size;
						count <= count - 2;
					end if;
					
					if count <=queue_size-2 and stall_FIFO='0' then 
						queue(tail) <= decoded_instr1;
						queue((tail+1) mod queue_size) <= decoded_instr2;
						tail<= (tail+2) mod queue_size;
						count <= count +2;
					end if;					
		end if;
	end process;
	
	empty <= '1' when count < 2 else '0';
	full  <= '1' when count > queue_size-2 else '0';
	valid_queue <= '1' when FIFO_reset='0' and flush_FIFO ='0' and stall_FIFO ='0' else '0';
	
	FIFO_valid1 <= decoded_valid1 when valid_queue ='1' else '0';
	FIFO_valid2 <= decoded_valid2 when valid_queue ='1' else '0';
	stall_dec <= '1' when full = '1' else stall_FIFO;
	
end behv;
			