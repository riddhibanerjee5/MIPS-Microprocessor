library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity ALU_Control is

	port(
		ALU_Op 		: in std_logic_vector(5 downto 0);
		IR_5_0  	: in std_logic_vector(5 downto 0);
		IR_20_16	: in std_logic_vector(4 downto 0);
		Hard_Op		: in std_logic;
		HI_en 		: out std_logic;
		LO_en 		: out std_logic;
		ALU_LO_HI	: out std_logic_vector(1 downto 0);
		OP_Select	: out std_logic_vector(5 downto 0)		-- is the same as IR[5 downto 0]
		
--		hi_lo_reset	: in std_logic
	);
	
end ALU_Control;

architecture BHV of ALU_Control is

	constant R_TYPE_OPCODE : std_logic_vector(5 downto 0) := "000000";
	constant ADD 		   : std_logic_vector(5 downto 0) := "000000";
	
	constant C_ADD : std_logic_vector(5 downto 0) := "000000";
	constant C_ADDI : std_logic_vector(5 downto 0) := "000001";
	constant C_SUB : std_logic_vector(5 downto 0) := "000010";
	constant C_SUBI : std_logic_vector(5 downto 0) := "000011";
	constant C_MULT : std_logic_vector(5 downto 0) := "000100";
	constant C_MULT_U : std_logic_vector(5 downto 0) := "000101";
--	constant C_NOR : std_logic_vector(3 downto 0) := "000110";
	constant C_AND : std_logic_vector(5 downto 0) := "000110";
	constant C_ANDI	: std_logic_vector(5 downto 0) := "000111";
	constant C_OR : std_logic_vector(5 downto 0) := "001000";
	constant C_ORI : std_logic_vector(5 downto 0) := "001001";
	constant C_XOR : std_logic_vector(5 downto 0) := "001010";
	constant C_XORI : std_logic_vector(5 downto 0) := "001011";
	constant C_SRL : std_logic_vector(5 downto 0) := "001100";
	constant C_SLL : std_logic_vector(5 downto 0) := "001101";
	constant C_SRA : std_logic_vector(5 downto 0) := "001110";  -- change value
	constant C_SLT : std_logic_vector(5 downto 0) := "001111";
	constant C_SLTI : std_logic_vector(5 downto 0) := "010000";
	constant C_SLTIU : std_logic_vector(5 downto 0) := "010001";
	constant C_SLTU : std_logic_vector(5 downto 0) := "010010";
	constant C_MFHI : std_logic_vector(5 downto 0) := "010011";
	constant C_MFLO : std_logic_vector(5 downto 0) := "010100";
	constant C_LDWRD : std_logic_vector(5 downto 0) := "010101";
	constant C_STWRD : std_logic_vector(5 downto 0) := "010110";
	constant C_BRE : std_logic_vector(5 downto 0) := "010111";
	constant C_BRNE : std_logic_vector(5 downto 0) := "011000";
	constant C_BRLTEZ : std_logic_vector(5 downto 0) := "011001";
	constant C_BRGTZ : std_logic_vector(5 downto 0) := "011010";
	constant C_BRLTZ : std_logic_vector(5 downto 0) := "011011";
	constant C_BRGTEZ : std_logic_vector(5 downto 0) := "011100";
	constant C_JUMP : std_logic_vector(5 downto 0) := "011101";
	constant C_JUMPL : std_logic_vector(5 downto 0) := "011110";
	constant C_JUMPR : std_logic_vector(5 downto 0) := "011111";
	constant C_FAKE : std_logic_vector(5 downto 0) := "100000";
	
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
	
	

	
begin

	process(ALU_Op, IR_5_0, Hard_Op)
	begin
	
		ALU_LO_HI <= "00";
		HI_en <= '0';
		LO_en <= '0';
		OP_Select <= C_ADD;
	
		if(Hard_Op = '1') then
			OP_Select <= C_ADD;
		
		else
		
			case(ALU_Op) is
			
				when "111111" =>
					OP_Select <= "111111";
		
				when R_TYPE_OPCODE =>
					if(IR_5_0 = "100001") then				--0x21
						OP_Select <= C_ADD;
					
					elsif(IR_5_0 = "100011") then			--0x23
						OP_Select <= C_SUB;
					
					elsif(IR_5_0 = "011000") then		    --0x18
						OP_Select <= C_MULT;
						HI_en <= '1';
						LO_en <= '1';
					
					elsif(IR_5_0 = "011001") then			--0x19
						OP_Select <= C_MULT_U;
						HI_en <= '1';
						LO_en <= '1';
						
--						OP_Select <= "111111";
					
					elsif(IR_5_0 = "100100") then			--0x24
						OP_Select <= C_AND;
	
					elsif(IR_5_0 = "100101") then			--0x25
						OP_Select <= C_OR;
					
					elsif(IR_5_0 = "100110") then			--0x26
						OP_Select <= C_XOR;
					
					elsif(IR_5_0 = "000010") then			--0x02
						OP_Select <= C_SRL;
					
					elsif(IR_5_0 = "000000") then			--0x00
						OP_Select <= C_SLL;
					
					elsif(IR_5_0 = "000011") then			--0x03
						OP_Select <= C_SRA;
					
					elsif(IR_5_0 = "101010") then			--0x2A
						OP_Select <= C_SLT;
					
					elsif(IR_5_0 = "101011") then			--0x2B
						OP_Select <= C_SLTU;
					
					elsif(IR_5_0 = "010000") then			--0x10
--						OP_Select <= C_MFHI;
--						OP_Select <= "111111";
						HI_en <= '0';
						LO_en <= '0';
						ALU_LO_HI <= "10";
					
					elsif(IR_5_0 = "010010") then			--0x12
--						OP_Select <= C_MFLO;
--						OP_Select <= "111111";
						HI_en <= '0';
						LO_en <= '0';
						ALU_LO_HI <= "01";
					
					elsif(IR_5_0 = "001000") then			--0x08
						OP_Select <= C_JUMPR;
					
					else
						OP_Select <= C_ADD;
						
					end if;
				
				when ADDI_OPCODE =>
					OP_Select <= C_ADDI;
				
				when SUBI_OPCODE =>
					OP_Select <= C_SUBI;
				
				when ANDI_OPCODE =>
					OP_Select <= C_ANDI;
				
				when ORI_OPCODE =>
					OP_Select <= C_ORI;
				
				when XORI_OPCODE =>
					OP_Select <= C_XORI;
				
				when SLTI_OPCODE =>
					OP_Select <= C_SLTI;
				
				when SLTIU_OPCODE =>
					OP_Select <= C_SLTIU;
				
				when LDWRD_OPCODE =>
					OP_Select <= C_LDWRD;
				
				when STWRD_OPCODE =>
					OP_Select <= C_STWRD;
				
				when BRE_OPCODE =>
					OP_Select <= C_BRE;
				
				when BRNE_OPCODE =>
					OP_Select <= C_BRNE;
				
				when BLTEZ_OPCODE =>
					OP_Select <= C_BRLTEZ;
				
				when BGTZ_OPCODE =>
					OP_Select <= C_BRGTZ;
				
				when BLTZ_AND_BGTEZ_OPCODE =>
					if(IR_20_16 = "00000") then
						OP_Select <= C_BRLTZ;
					
					elsif(IR_20_16 = "00001") then
						OP_Select <= C_BRGTEZ;
					
					end if;
			
				when JUMPA_OPCODE =>
					OP_Select <= C_JUMP;
				
				when JUMPL_OPCODE =>
					OP_Select <= C_JUMPL;
				
				when others =>
					OP_Select <= "111111";	
		
			end case;
			
		end if;
	
	end process;



end BHV;