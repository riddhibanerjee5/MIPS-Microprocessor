library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity top_level is
    generic (WIDTH : positive := 32);
    port (
        clk    : in  std_logic;
        rst    : in  std_logic;
		
		inport0			: in std_logic_vector(WIDTH-1 downto 0);
		inport1			: in std_logic_vector(WIDTH-1 downto 0);
		inport0_en		: in std_logic;
		outport			: out std_logic_vector(WIDTH-1 downto 0);
		inport1_en		: in std_logic
	);
end top_level;

architecture BHV of top_level is

--	signal PC_Load : std_logic;
--	signal PCWriteCond : std_logic;
--	signal PCWrite : std_logic;
--	signal branch_taken : std_logic;

	signal PCWriteCond		: std_logic;
	signal PCWrite			: std_logic;
	signal IorD				: std_logic;				
	signal MemRead			: std_logic;			
	signal MemWrite 		: std_logic;			
	signal MemToReg 		: std_logic;			
	signal IRWrite 			: std_logic;				
	signal JumpAndLink 		: std_logic;		
	signal Is_Signed 		: std_logic;					
	signal PCSource 		: std_logic_vector(1 downto 0);		
	signal ALUOp 			: std_logic_vector(5 downto 0);				
	signal ALUSrcB 			: std_logic_vector(1 downto 0);				
	signal ALUSrcA			: std_logic;		
	signal RegWrite 		: std_logic;			
	signal RegDst 			: std_logic;		
	signal Hard_OPSelect 	: std_logic;	
	signal PCLoad 			: std_logic;				
	signal IR_5_0 			: std_logic_vector(5 downto 0);				
	signal OpCode			: std_logic_vector(5 downto 0);
	signal branch_taken		: std_logic;
	
--	signal hi_lo_reset		: std_logic;
	
begin

--	PCLoad <= (branch_taken and PCWriteCond) or PCWrite;

	U_CONTROLLER : entity work.controller
	generic map ( WIDTH => WIDTH)
	port map(
		clk => clk,
		rst => rst,
		
		PCWriteCond => PCWriteCond,
		PCWrite => PCWrite,
		IorD => IorD,				
		MemRead	=> MemRead,			
		MemWrite => MemWrite,			
		MemToReg => MemToReg,			
		IRWrite => IRWrite,				
		JumpAndLink => JumpAndLink,			
		Is_Signed => Is_Signed,					
		PCSource => PCSource,			
		ALUOp => ALUOp,				
		ALUSrcB => ALUSrcB,				
		ALUSrcA	=> ALUSrcA,			
		RegWrite => RegWrite,			
		RegDst => RegDst,		
		Hard_OPSelect => Hard_OPSelect,		
--		PCLoad => PCLoad,				
		IR_5_0 => IR_5_0,		
		
		OpCode => OpCode
		
--		hi_lo_reset => hi_lo_reset
	);
	
	U_DATAPATH : entity work.datapath
	generic map ( WIDTH => WIDTH)
	port map(
		clk => clk,
		rst => rst,
		
		PCWriteCond => PCWriteCond,
		PCWrite => PCWrite,
		IorD => IorD,				
		MemRead	=> MemRead,			
		MemWrite => MemWrite,			
		MemToReg => MemToReg,			
		IRWrite => IRWrite,				
		JumpAndLink => JumpAndLink,			
		Is_Signed => Is_Signed,					
		PCSource => PCSource,			
		ALUOp => ALUOp,				
		ALUSrcB => ALUSrcB,				
		ALUSrcA	=> ALUSrcA,			
		RegWrite => RegWrite,			
		RegDst => RegDst,		
		Hard_OPSelect => Hard_OPSelect,		
		PCLoad => PCLoad,				
		IR_5_0 => IR_5_0,
		branch_taken => branch_taken,
		inport0 => inport0,
		inport1 => inport1,
		inport0_en => inport0_en,
		inport1_en => inport1_en,
		outport => outport,
		
		OpCode => OpCode
		
--		hi_lo_reset => hi_lo_reset
	);
	
	PCLoad <= (branch_taken and PCWriteCond) or PCWrite;

end BHV;