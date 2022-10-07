library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity datapath is

	generic (
		WIDTH : positive := 32
	);
	
	port (
		PCWriteCond			: in std_logic;
		PCWrite				: in std_logic;
		IorD				: in std_logic;
		MemRead				: in std_logic;
		MemWrite			: in std_logic;
		MemToReg			: in std_logic;
		IRWrite				: in std_logic;
		JumpAndLink			: in std_logic;
		Is_Signed			: in std_logic;		
		PCSource			: in std_logic_vector(1 downto 0);
		ALUOp				: in std_logic_vector(5 downto 0);
		ALUSrcB				: in std_logic_vector(1 downto 0);
		ALUSrcA				: in std_logic;
		RegWrite			: in std_logic;
		RegDst				: in std_logic;
		Hard_OPSelect		: in std_logic;
		PCLoad				: in std_logic;		-- (branch_taken and PCWriteCond) or PCWrite
		IR_5_0				: out std_logic_vector(5 downto 0);
		branch_taken        : out std_logic;
		
		inport0				: in std_logic_vector(WIDTH-1 downto 0);
		inport1				: in std_logic_vector(WIDTH-1 downto 0);
		outport				: out std_logic_vector(WIDTH-1 downto 0);
		
		inport0_en			: in std_logic;
		inport1_en			: in std_logic;
		
--		hi_lo_reset			: in std_logic;		-- for alu control
		
--		PC_input_mux 		: out std_logic_vector(WIDTH-1 downto 0);
		
		OpCode				: out std_logic_vector(5 downto 0);
		
		clk					: in std_logic;
		rst					: in std_logic
		
	);
	
end datapath;


architecture BHV of datapath is

--	signal clk    						: std_logic;
--	signal rst							: std_logic;
	signal PC_input_mux 				: std_logic_vector(WIDTH-1 downto 0);
	signal PC_out 						: std_logic_vector(WIDTH-1 downto 0);
--	signal ALU_out 						: std_logic_vector(WIDTH-1 downto 0);
	signal PC_mux_output 				: std_logic_vector(WIDTH-1 downto 0);
--	signal inport0_en					: std_logic;
--	signal inport1_en					: std_logic;
--	signal inport0						: std_logic_vector(WIDTH-1 downto 0);
--	signal inport1						: std_logic_vector(WIDTH-1 downto 0);
--	signal RegB							: std_logic_vector(WIDTH-1 downto 0);
--	signal outport						: std_logic_vector(WIDTH-1 downto 0);
	signal memory_out					: std_logic_vector(WIDTH-1 downto 0);
	signal memory_data_register_out 	: std_logic_vector(WIDTH-1 downto 0);
	signal instruction_register_out 	: std_logic_vector(WIDTH-1 downto 0);
	signal ALU_mux_output				: std_logic_vector(WIDTH-1 downto 0);
	signal memory_data_regsiter_mux_out : std_logic_vector(WIDTH-1 downto 0);
	signal instruction_register_mux_out : std_logic_vector(4 downto 0);
	signal rd_data0						: std_logic_vector(WIDTH-1 downto 0);
	signal rd_data1						: std_logic_vector(WIDTH-1 downto 0);
	signal reg_a_output					: std_logic_vector(WIDTH-1 downto 0);
	signal reg_b_output					: std_logic_vector(WIDTH-1 downto 0);
	signal sign_extend_output			: std_logic_vector(WIDTH-1 downto 0);
	signal shift_left_bottom_output		: std_logic_vector(WIDTH-1 downto 0);
	signal reg_a_mux_output				: std_logic_vector(WIDTH-1 downto 0);
	signal reg_b_mux_output				: std_logic_vector(WIDTH-1 downto 0);
	signal shift_left_top_output		: std_logic_vector(27 downto 0);
	signal concat_out					: std_logic_vector(WIDTH-1 downto 0);
	signal OPSelect						: std_logic_vector(5 downto 0);
	signal alu_result					: std_logic_vector(WIDTH-1 downto 0);
	signal alu_high_result				: std_logic_vector(WIDTH-1 downto 0);
--	signal branch_taken					: std_logic_vector(WIDTH-1 downto 0);
	signal alu_out_output				: std_logic_vector(WIDTH-1 downto 0);
	signal lo_output					: std_logic_vector(WIDTH-1 downto 0);
	signal hi_output					: std_logic_vector(WIDTH-1 downto 0);
	signal HI_en						: std_logic;
	signal LO_en						: std_logic;
	signal ALU_LO_HI					: std_logic_vector(1 downto 0);
--	signal outport						: std_logic_vector(WIDTH-1 downto 0);

begin

	U_PC : entity work.reg 
	generic map( width => WIDTH)
	port map(
		clk => clk,
		rst => rst,
		load => PCLoad,  -- PC_load
		input => PC_input_mux,
		output => PC_out
	);
	
	
	U_PC_MUX : entity work.mux2x1
	generic map( width => WIDTH)
	port map(
		in0 => PC_out,
		in1 => alu_out_output,
		sel => IorD,
		output => PC_mux_output
	);
	
	
	U_MEMORY : entity work.memory
	generic map( WIDTH => WIDTH)
	port map(
		clk => clk,
		rst => rst,
		wr_en => MemWrite,
		inport0 => inport0,
		inport1 => inport1,
		inport0_en => inport0_en,
		inport1_en => inport1_en,
--		wr_data => RegB,
		wr_data => reg_b_output,
		byte_address => PC_mux_output,
		out_data => memory_out,
		outport => outport
	);
	
	
	U_MEMORY_DATA_REGISTER : entity work.reg 
	generic map( width => WIDTH)
	port map(
		clk => clk,
		rst => rst,
		load => '1',
		input => memory_out,
		output => memory_data_register_out
	);
	
	
	U_INSTRUCTION_REGISTER : entity work.reg 
	generic map( width => WIDTH)
	port map(
		clk => clk,
		rst => rst,
		load => IRWrite,
		input => memory_out,
		output => instruction_register_out
	);
	
	OpCode <= instruction_register_out(31 downto 26);
		
		
	U_MEMORY_DATA_REGISTER_MUX : entity work.mux2x1
	generic map( width => WIDTH)
	port map(
		in0 => ALU_mux_output,
		in1 => memory_data_register_out,
		sel => MemToReg,
		output => memory_data_regsiter_mux_out
	);
		
		
	U_INSTRUCTION_REGISTER_MUX : entity work.register_mux
	generic map( width => WIDTH)
	port map(
		in0 => instruction_register_out(20 downto 16),
		in1 => instruction_register_out(15 downto 11),
		sel => RegDst,
		output => instruction_register_mux_out
	);
	
	
	U_REGISTER_FILE : entity work.register_file
	generic map( WIDTH => WIDTH)
	port map(
		clk => clk,
		rst => rst,
		rd_addr0 => instruction_register_out(25 downto 21),
		rd_addr1 => instruction_register_out(20 downto 16),
		wr_addr => instruction_register_mux_out,
		wr_en => RegWrite,
		jump_and_link => JumpAndLink,
		wr_data => memory_data_regsiter_mux_out,
		rd_data0 => rd_data0,
		rd_data1 => rd_data1
	);
	
	
	U_REG_A : entity work.reg 
	generic map( width => WIDTH)
	port map(
		clk => clk,
		rst => rst,
		load => '1',
		input => rd_data0,
		output => reg_a_output
	);
	
	
	U_REG_B : entity work.reg 
	generic map( width => WIDTH)
	port map(
		clk => clk,
		rst => rst,
		load => '1',
		input => rd_data1,
		output => reg_b_output
	);
	
	
	U_SIGN_EXTEND : entity work.sign_extend
	port map(
		input => instruction_register_out(15 downto 0),
		output => sign_extend_output,
		is_Signed => Is_Signed
	);
	
	
	U_SHIFT_LEFT_BOTTOM : entity work.sh_left
	port map(
		input => sign_extend_output,
		output => shift_left_bottom_output
	);
	
	
	U_REG_A_MUX : entity work.mux2x1
	generic map( width => WIDTH)
	port map(
		in0 => PC_out,
		in1 => reg_a_output,
		sel => ALUSrcA,
		output => reg_a_mux_output
	);
	
	
	U_REG_B_MUX : entity work.mux4x1
	generic map ( width => WIDTH)
	port map(
		in0 => reg_b_output,
		in1 => std_logic_vector(to_unsigned(4, WIDTH)),
		in2 => sign_extend_output,
		in3 => shift_left_bottom_output,
		sel => ALUSrcB,
		output => reg_b_mux_output
	);
	
	
	U_SHIFT_LEFT_TOP : entity work.sh_left_concat
	port map(
		input => instruction_register_out(25 downto 0),
		output => shift_left_top_output
	);
	
	
	U_CONCAT : entity work.concat
	port map(
		input => shift_left_top_output,
		concat_amt => PC_out(31 downto 28),
		output => concat_out
	);
	
	
	U_ALU : entity work.alu_final
	generic map( WIDTH => WIDTH)
	port map(
		input1 => reg_a_mux_output, 			
		input2 => reg_b_mux_output, 			
		OP_sel => OPSelect,	
		shift_amount => instruction_register_out(10 downto 6),
		result => alu_result,	
		result_h => alu_high_result,
		branch => branch_taken
	);
	
	
	U_ALU_OUT : entity work.reg 
	generic map( width => WIDTH)
	port map(
		clk => clk,
		rst => rst,
		load => '1',
		input => alu_result,
		output => alu_out_output
	);
	
	
	U_LO : entity work.reg 
	generic map( width => WIDTH)
	port map(
		clk => clk,
		rst => rst,
		load => LO_en,	-- from ALU_Control
		input => alu_result,
		output => lo_output
	);
	
	
	U_HI : entity work.reg 
	generic map( width => WIDTH)
	port map(
		clk => clk,
		rst => rst,
		load => HI_en,	-- from ALU_Control
		input => alu_high_result,
		output => hi_output
	);
	
	
	U_ALU_OUT_MUX : entity work.mux3x1
	generic map( width => WIDTH)
	port map(
		in3 => alu_out_output,
		in2 => lo_output,
		in1 => hi_output,
		sel => ALU_LO_HI,		-- from ALU_Control
		output => ALU_mux_output
	);
	
	
	U_TOP_RIGHT_MUX : entity work.mux3x1
	generic map( width => WIDTH)
	port map(
--		in3 => std_logic_vector(to_unsigned(branch_taken, WIDTH)),
		in3 => alu_result,
		in2 => alu_out_output,
		in1 => concat_out,
		sel => PCSource,
		output => PC_input_mux
	);
	
	
	U_ALU_CONTROL : entity work.ALU_Control
	port map(
		ALU_Op => ALUOp,
		IR_5_0 => instruction_register_out(5 downto 0),
		IR_20_16 => instruction_register_out(20 downto 16),
		HI_en => HI_en,
		LO_en => LO_en,
		ALU_LO_HI => ALU_LO_HI,
		OP_Select => OPSelect,
		Hard_Op => Hard_OPSelect
--		hi_lo_reset => hi_lo_reset
	);	
	
	IR_5_0 <= instruction_register_out(5 downto 0);



end BHV;