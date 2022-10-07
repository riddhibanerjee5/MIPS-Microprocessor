library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity controller is

	generic (
		WIDTH : positive := 32
	);
	
	port (
		PCWriteCond			: out std_logic;
		PCWrite				: out std_logic;
		IorD				: out std_logic;
		MemRead				: out std_logic;
		MemWrite			: out std_logic;
		MemToReg			: out std_logic;
		IRWrite				: out std_logic;
		JumpAndLink			: out std_logic;
		Is_Signed			: out std_logic;		
		PCSource			: out std_logic_vector(1 downto 0);
		ALUOp				: out std_logic_vector(5 downto 0);	-- says what type of instruction it is (R-type, I-type, etc) / is the same as OpCode coming into controller
		ALUSrcB				: out std_logic_vector(1 downto 0);
		ALUSrcA				: out std_logic;
		RegWrite			: out std_logic;
		RegDst				: out std_logic;
		Hard_OPSelect		: out std_logic;
--		PCLoad				: out std_logic;		-- (branch_taken and PCWriteCond) or PCWrite
		IR_5_0				: in std_logic_vector(5 downto 0);
		
		OpCode				: in std_logic_vector(5 downto 0);		-- this is IR[31-26] 
		
--		hi_lo_reset			: out std_logic;
		
		clk					: in std_logic;
		rst					: in std_logic
		
	);
	
end controller;


architecture BHV of controller is

	type state_t is (INSTR_FETCH_CYCLE_1, INSTR_FETCH_CYCLE_2, INSTR_DECODE, R_TYPE_STATE_CYCLE_1, R_TYPE_STATE_CYCLE_2, MULT_STATE_CYCLE_2,
					I_TYPE_STATE_CYCLE_1, I_TYPE_STATE_CYCLE_2, JUMP_TYPE_STATE_CYCLE_1, LDWRD_STATE_CYCLE_1, LDWRD_STATE_CYCLE_2,
					LDWRD_STATE_CYCLE_3, LDWRD_STATE_CYCLE_4, STWRD_STATE_CYCLE_1, STWRD_STATE_CYCLE_2, BRANCH_TYPE_CYCLE_1, BRANCH_TYPE_CYCLE_2,
					JUMPR_STATE_CYCLE_1);
						
	signal state_r, next_state : state_t;
	
	constant R_TYPE_OPCODE : std_logic_vector(5 downto 0) := "000000";
	
	constant ADDI_OPCODE : std_logic_vector(5 downto 0) := "001001"; --x"09";
	constant SUBI_OPCODE : std_logic_vector(5 downto 0) := "010000"; --x"10";
	constant ANDI_OPCODE : std_logic_vector(5 downto 0) := "001100"; --x"0C";
	constant ORI_OPCODE : std_logic_vector(5 downto 0) := "001101"; --x"0D";
	constant XORI_OPCODE : std_logic_vector(5 downto 0) := "001110"; --x"0E";
	constant SLTI_OPCODE : std_logic_vector(5 downto 0) := "001010"; --x"0A";
	constant SLTIU_OPCODE : std_logic_vector(5 downto 0) := "001011"; --x"0B";
	
	constant LDWRD_OPCODE : std_logic_vector(5 downto 0) := "100011"; --x"23"
	constant STWRD_OPCODE : std_logic_vector(5 downto 0) := "101011"; --x"2B"
	
	constant BRE_OPCODE : std_logic_vector(5 downto 0) := "000100"; --x"04"
	constant BRNE_OPCODE : std_logic_vector(5 downto 0) := "000101";
	constant BLTEZ_OPCODE : std_logic_vector(5 downto 0) := "000110";
	constant BGTZ_OPCODE : std_logic_vector(5 downto 0) := "000111";
	constant BLTZ_AND_BGTEZ_OPCODE : std_logic_vector(5 downto 0) := "000001";
	
	constant JUMPA_OPCODE : std_logic_vector(5 downto 0) := "000010";
	constant JUMPL_OPCODE : std_logic_vector(5 downto 0) := "000011";
--	constant JUMPR_OPCODE : std_logic_vector(5 downto 0) := "000011";
	
	constant ADD : std_logic_vector(5 downto 0) := "000000";
	
begin

	process(clk, rst)
	begin
		if(rst = '1') then
			state_r <= INSTR_FETCH_CYCLE_1;
			
		elsif(rising_edge(clk)) then
			state_r <= next_state;
			
		end if;
	end process;
	
	
	process(state_r, OpCode, IR_5_0)
	begin
	
		PCWriteCond <= '0';
		PCWrite <= '0';
		IorD <= '0';
		MemRead <= '0';	
		MemWrite <= '0';
		MemToReg <= '0';
		IRWrite	<= '0';
		JumpAndLink	<= '0';
		Is_Signed <= '0';		
		PCSource <= "00";
		ALUOp <= "111111";				
		ALUSrcB <= "00";
		ALUSrcA	<= '0';
		RegWrite <= '0';
		RegDst <= '0';	
		Hard_OPSelect <= '0';
--		hi_lo_reset <= '0';
--		PCLoad <= '0';
		
		case(state_r) is
--			when START =>
--				next_state <= INSTR_FETCH_CYCLE_1;
				
			when INSTR_FETCH_CYCLE_1 =>
			
				IorD <= '0';
				ALUSrcA <= '0';
				ALUSrcB <= "01";
--				ALUOp <= ADD;
				Hard_OPSelect <= '1';	-- tells ALU to do ADD operation
				PCSource <= "00";
				PCWrite <= '1';
				
--				ALUOp <= OpCode;		-- added this
				ALUOp <= "111111";
				next_state <= INSTR_FETCH_CYCLE_2;
				
			when INSTR_FETCH_CYCLE_2 =>
				ALUOp <= OpCode;			-- added new
				ALUOp <= "111111";			-- added 3:10
				IRWrite <= '1';
				
				next_state <= INSTR_DECODE;
				
			when INSTR_DECODE =>
				
				ALUSrcA <= '0';
				ALUSrcB <= "11";
				ALUOp <= OpCode;
				Is_Signed <= '1';      -- uncomment for bubble sort if it does not work
				
				case(OpCode) is
					when R_TYPE_OPCODE =>				-- R-Type opcodes
						next_state <= R_TYPE_STATE_CYCLE_1;
						
					-- I-Type opcodes are all different
					when ADDI_OPCODE =>
						next_state <= I_TYPE_STATE_CYCLE_1;
						
					when SUBI_OPCODE =>
						next_state <= I_TYPE_STATE_CYCLE_1;
						
					when ANDI_OPCODE =>
						next_state <= I_TYPE_STATE_CYCLE_1;
						
					when ORI_OPCODE =>
						next_state <= I_TYPE_STATE_CYCLE_1;
						
					when XORI_OPCODE =>
						next_state <= I_TYPE_STATE_CYCLE_1;
						
					when SLTI_OPCODE =>
						next_state <= I_TYPE_STATE_CYCLE_1;
						
					when SLTIU_OPCODE =>
						next_state <= I_TYPE_STATE_CYCLE_1;
						
					when JUMPA_OPCODE =>
						next_state <= JUMP_TYPE_STATE_CYCLE_1;
						
					when JUMPL_OPCODE =>
						next_state <= JUMP_TYPE_STATE_CYCLE_1;
						
					when LDWRD_OPCODE =>
						Hard_OPSelect <= '1';
						next_state <= LDWRD_STATE_CYCLE_1;
						
					when STWRD_OPCODE =>
						next_state <= STWRD_STATE_CYCLE_1;
						
					when BRE_OPCODE =>
						next_state <= BRANCH_TYPE_CYCLE_1;
						
					when BRNE_OPCODE =>
						next_state <= BRANCH_TYPE_CYCLE_1;
						
					when BLTEZ_OPCODE =>
						next_state <= BRANCH_TYPE_CYCLE_1;
						
					when BGTZ_OPCODE =>
						next_state <= BRANCH_TYPE_CYCLE_1;
						
					when BLTZ_AND_BGTEZ_OPCODE =>
						next_state <= BRANCH_TYPE_CYCLE_1;
						
					when others =>
						next_state <= INSTR_FETCH_CYCLE_1;				
				
				end case;
				
			when R_TYPE_STATE_CYCLE_1 =>
				ALUOp <= OpCode;
				ALUSrcA <= '1';		-- RegA as source
				ALUSrcB <= "00";	-- RegB as source
				
				if(IR_5_0 = "011000" or IR_5_0 = "011001") then		-- if mult or mult_u
--					next_state <= MULT_STATE_CYCLE_2;
--					hi_lo_reset <= '1';
--					ALUOp <= "111111";
					next_state <= INSTR_FETCH_CYCLE_1;
					
				elsif(IR_5_0 = "001000") then
				
					next_state <= JUMPR_STATE_CYCLE_1;
				
				else
					next_state <= R_TYPE_STATE_CYCLE_2;				-- if regular r-type
					
				end if;
				
				
			when MULT_STATE_CYCLE_2 =>
				MemToReg <= '0';
				RegDst <= '1';
				RegWrite <= '0';		-- don't write to register file
				
				
				next_state <= INSTR_FETCH_CYCLE_1;
				
			when R_TYPE_STATE_CYCLE_2 =>
				-- make sure ALU_LO_HI selects ALU_OUT
				
				if(IR_5_0 = "001000") then						-- if jump and register
					PCSource <= "01";
					PCWrite <= '1';
					
				else					
					MemToReg <= '0';
					RegDst <= '1';
					RegWrite <= '1';
					ALUOp <= OpCode;
					
				end if;
				
				
				next_state <= INSTR_FETCH_CYCLE_1;
				
			when I_TYPE_STATE_CYCLE_1 =>
				ALUOp <= OpCode;
				ALUSrcA <= '1';
				ALUSrcB <= "10";
				
				if(OpCode = ANDI_OPCODE or OpCode = ORI_OPCODE or OpCode = XORI_OPCODE) then
					Is_Signed <= '0';
					
				else 
					Is_Signed <= '1';
					
				end if;
				
				next_state <= I_TYPE_STATE_CYCLE_2;
				
			when I_TYPE_STATE_CYCLE_2 =>
				MemToReg <= '0';
				RegDst <= '0';
				RegWrite <= '1';
				
				next_state <= INSTR_FETCH_CYCLE_1;
				
			when JUMP_TYPE_STATE_CYCLE_1 =>
				PCSource <= "10";
				PCWrite <= '1';
				
				if(OpCode = JUMPL_OPCODE) then			-- if it is jump and link
					
					ALUOp <= "001001";
					ALUSrcB <= "01";
					RegWrite <= '1';	-- added 4/12
					JumpAndLink <= '1';
				
				end if;
				
				next_state <= INSTR_FETCH_CYCLE_1;
				
			when JUMPR_STATE_CYCLE_1 =>
				RegDst <= '1';
				RegWrite <= '1';
				
				next_state <= INSTR_FETCH_CYCLE_1;
		
				
--			when JUMP_TYPE_STATE_CYCLE_2 =>
			
				-- TO DO
				
--				next_state <= INSTR_FETCH_CYCLE_1;
				
			when LDWRD_STATE_CYCLE_1 =>
				Is_Signed <= '0';
				ALUSrcB <= "10";
				ALUSrcA <= '1';
				Hard_OPSelect <= '1';
				
				next_state <= LDWRD_STATE_CYCLE_2;
				
			when LDWRD_STATE_CYCLE_2 =>
				Hard_OPSelect <= '1';		-- ADD
				IorD <= '1';
				MemWrite <= '0';
				
				ALUSrcB <= "10";
				ALUSrcA <= '1';
				ALUOp <= ADD;
				
				next_state <= LDWRD_STATE_CYCLE_3;
				
			when LDWRD_STATE_CYCLE_3 =>
				
				IorD <= '1';    -- change 4/11
				next_state <= LDWRD_STATE_CYCLE_4;
				
			when LDWRD_STATE_CYCLE_4 =>
				MemToReg <= '1';
				RegDst <= '0';
				RegWrite <= '1';
				
				next_state <= INSTR_FETCH_CYCLE_1;
				
			when STWRD_STATE_CYCLE_1 =>
				Is_Signed <= '0';
				ALUSrcB <= "10";
				ALUSrcA <= '1';
				Hard_OPSelect <= '1';		-- ADD
				
				next_state <= STWRD_STATE_CYCLE_2;
				
			when STWRD_STATE_CYCLE_2 =>
--				Hard_OPSelect <= '1';		-- ADD
--				Is_Signed <= '0';		-- added now
				IorD <= '1';
				MemRead <= '0';
				MemWrite <= '1';			-- new
				RegDst <= '0';
				RegWrite <= '0';
				
--				next_state <= STWRD_STATE_CYCLE_3;
				next_state <= INSTR_FETCH_CYCLE_1;
				
			when BRANCH_TYPE_CYCLE_1 =>
				ALUSrcA <= '0';
				ALUSrcB <= "11";
				Is_Signed <= '1';
				Hard_OPSelect <= '1';
--				ALUOp <= ADD;
			
				next_state <= BRANCH_TYPE_CYCLE_2;
				
			when BRANCH_TYPE_CYCLE_2 =>
				ALUOp <= OpCode;
				ALUSrcA <= '1';
				ALUSrcB <= "00";
				PCSource <= "01";
				PCWriteCond <= '1';
							
				next_state <= INSTR_FETCH_CYCLE_1;
				
--			when STWRD_STATE_CYCLE_3 =>
			
--				next_state <= STWRD_STATE_CYCLE_4;
				
--			when STWRD_STATE_CYCLE_4 =>
--				RegDst <= '0';
--				RegWrite <= '0';
				
--				next_state <= INSTR_FETCH_CYCLE_1;	
				
	
	
		end case;
	end process;
end BHV;