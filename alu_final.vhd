library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity alu_final is

	generic (
		WIDTH : positive := 32
	);

	port (
		input1 			: in std_logic_vector(WIDTH-1 downto 0);
		input2 			: in std_logic_vector(WIDTH-1 downto 0);
		OP_sel 			: in std_logic_vector(5 downto 0);
		shift_amount 	: in std_logic_vector(4 downto 0);
		result 			: out std_logic_vector(WIDTH-1 downto 0);
		result_h 		: out std_logic_vector(WIDTH-1 downto 0);
		branch 			: out std_logic
	);
	
end alu_final;

architecture BHV of alu_final is

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
	

begin

	process(input1, input2, OP_sel, shift_amount)
	
		variable temp 			: unsigned(WIDTH-1 downto 0);
--		variable temp_branch	: std_logic_vector(WIDTH-1 downto 0);
		variable mult_temp 		: std_logic_vector(((WIDTH*2)-1) downto 0);
		--variable mult_temp 		: signed(((WIDTH*2)-1) downto 0);
		variable mult_temp_L 	: std_logic_vector(WIDTH-1 downto 0);
		variable mult_temp_H 	: std_logic_vector(WIDTH-1 downto 0);
		
		variable temp_branch 	: std_logic;
		
	begin
	
		temp := (others => '0');
		mult_temp := (others => '0');
		mult_temp_L := (others => '0');
		mult_temp_H := (others => '0');
		temp_branch := '0';
	
	case OP_sel is
	
		when C_ADD =>
			temp := (unsigned(input1) + unsigned(input2));
			
		when C_ADDI =>
			temp := (unsigned(input1) + unsigned(input2));
			
		when C_SUB =>
			temp := (unsigned(input1) - unsigned(input2));
			
		when C_SUBI =>
			temp := (unsigned(input1) - unsigned(input2));
		
		when C_MULT =>
			mult_temp := std_logic_vector(signed(input1) * signed(input2));
			temp := unsigned(mult_temp(WIDTH-1 downto 0));	-- lower half in temp (temp is unsigned, mult_temp is std_logic_vector)
			mult_temp_H := std_logic_vector((mult_temp(((WIDTH*2)-1) downto WIDTH)));
			
		when C_MULT_U =>
			mult_temp := std_logic_vector(unsigned(input1) * unsigned(input2));
			temp := unsigned(mult_temp(WIDTH-1 downto 0));
			mult_temp_H := std_logic_vector(unsigned(mult_temp(((WIDTH*2)-1) downto WIDTH)));
			
		when C_AND =>
			temp := unsigned(input1) and unsigned(input2);
			
		when C_ANDI =>
			temp := unsigned(input1) and unsigned(input2);
			
		when C_OR =>
			temp := unsigned(input1) or unsigned(input2);
			
		when C_ORI =>
			temp := unsigned(input1) or unsigned(input2);
		
		when C_XOR =>
			temp := unsigned(input1) xor unsigned(input2);
			
		when C_XORI =>
			temp := unsigned(input1) xor unsigned(input2);
			
		-- unsigned is logical, signed is arithmetic
		when C_SRL =>
			temp := shift_right(unsigned(input2), to_integer(unsigned(shift_amount)));
			
		when C_SLL =>
			temp := shift_left(unsigned(input2), to_integer(unsigned(shift_amount)));
			
		when C_SRA =>
			temp := unsigned(shift_right(signed(input2), to_integer(unsigned(shift_amount))));		-- is shift amount signed?
			
--		when C_SLA =>
--			temp := shift_left(signed(input1), unsigned(shift_amount));
	
		when C_SLT =>
			if(signed(input1) < signed(input2)) then
				temp := to_unsigned(1, temp'length);
			else
				temp := to_unsigned(0, temp'length);
			end if;
				
		when C_SLTI =>
			if(signed(input1) < signed(input2)) then
				temp := to_unsigned(1, temp'length);
			else
				temp := to_unsigned(0, temp'length);
			end if;
		
		when C_SLTIU =>
			if(unsigned(input1) < unsigned(input2)) then
				temp := to_unsigned(1, temp'length);
			else
				temp := to_unsigned(0, temp'length);
			end if;
		
		when C_SLTU =>
			if(unsigned(input1) < unsigned(input2)) then
				temp := to_unsigned(1, temp'length);
			else
				temp := to_unsigned(0, temp'length);
			end if;
			
--		when C_MFHI =>
--			temp 
		
--		when C_MFLO =>
		
		
--		when C_STWRD =>
		
		
--		when C_LDWRD =>
		
		
		when C_BRE =>
			if(input1 = input2) then
				temp_branch := '1';
			else
				temp_branch := '0';
			end if;
			
		when C_BRNE =>
			if(input1 /= input2) then
				temp_branch := '1';
			else
				temp_branch := '0';
			end if;		

		when C_BRLTEZ =>
		
--			temp_branch := '1' when (input1 <= '0') else '0';
			
			if(signed(input1) <= 0) then
				temp_branch := '1';
			else
				temp_branch := '0';
			end if;
			
		when C_BRGTZ =>
			if(signed(input1) > 0) then
				temp_branch := '1';
			else
				temp_branch := '0';
			end if;
			
		when C_BRLTZ =>						-- same opcode
			if(signed(input1) < 0) then
				temp_branch := '1';
			else
				temp_branch := '0';
			end if;
			
		when C_BRGTEZ =>					-- same opcode
			if(signed(input1) >= 0) then
				temp_branch := '1';
			else
				temp_branch := '0';
			end if;
			
--		when C_JUMP =>
		
		
		when C_JUMPL =>
			temp := unsigned(input1);
		
		
--		when C_JUMPR =>
		
		
		when others =>
			temp := (others => '0');
			mult_temp := (others => '0');
			mult_temp_L := (others => '0');
			mult_temp_H := (others => '0');
			temp_branch := '0';
		
		end case;
		
		result <= std_logic_vector(temp);
		result_h <= std_logic_vector(mult_temp_H);
		branch <= temp_branch;
		
	end process;
	
end BHV;