library ieee;
use ieee.std_logic_1164.all;
--use ieee.std_logic_arith.all;
use ieee.std_logic_unsigned.all;
use ieee.numeric_std.all;

entity alu_exhaustive_tb is
end alu_exhaustive_tb;

architecture TB of alu_exhaustive_tb is

    component alu_final

        generic (
            WIDTH : positive := 8
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

    end component;

    constant WIDTH  	: positive                           := 8;
    signal input1   	: std_logic_vector(WIDTH-1 downto 0) := (others => '0');
    signal input2   	: std_logic_vector(WIDTH-1 downto 0) := (others => '0');
    signal OP_sel   	: std_logic_vector(5 downto 0)       := (others => '0');
	signal shift_amount : std_logic_vector(4 downto 0)		 := (others => '0');
    signal result   	: std_logic_vector(WIDTH-1 downto 0);
	signal result_h 	: std_logic_vector(WIDTH-1 downto 0);
    signal branch 		: std_logic;
	
	signal tempSignal	: unsigned(WIDTH-1 downto 0);
	
--	variable temp		: std_logic_vector(WIDTH-1 downto 0);

begin  -- TB

    UUT : alu_final
        generic map (WIDTH => WIDTH)
        port map (
            input1   	 => input1,
            input2   	 => input2,
            OP_sel   	 => OP_sel,
			shift_amount => shift_amount,
            result   	 => result,
			result_h  	 => result_h,
            branch 	 	 => branch
		);
		
	

    process
	
	variable temp			: 	unsigned(WIDTH-1 downto 0);
	variable mult_temp 		: 	std_logic_vector(((WIDTH*2)-1) downto 0);
	variable mult_temp_L 	: 	std_logic_vector(WIDTH-1 downto 0);
	variable mult_temp_H 	:	std_logic_vector(WIDTH-1 downto 0);
	variable temp_branch 	:	std_logic;
	
    begin

		for i in 0 to 255 loop
			for j in 0 to 255 loop
--				input1 <= conv_std_logic_vector(j, input1'length);
--				input2 <= conv_std_logic_vector(i, input2'length);

				input1 <= std_logic_vector(to_unsigned(j, input1'length));
				input2 <= std_logic_vector(to_unsigned(i, input2'length));
			
		-- test add
				OP_sel    <= "000000";
				
				temp := unsigned(to_unsigned(i, temp'length) + to_unsigned(j, temp'length));
				
				wait for 40 ns;
				
				assert(result = std_logic_vector(temp)) report "Error (add) : = " & integer'image(conv_integer(result)) & "" severity warning;

		-- test sub
				OP_sel    <= "000010";
				
				temp := unsigned(to_unsigned(j, temp'length) - to_unsigned(i, temp'length));
				
				wait for 40 ns;
				
				assert(result = std_logic_vector(temp)) report "Error (sub) : = " & integer'image(conv_integer(result)) & "" severity warning;

        -- test mult (signed)
				OP_sel    <= "000100";
				
				mult_temp := std_logic_vector(to_signed(i, temp'length) * to_signed(j, temp'length));
				temp := unsigned(mult_temp(WIDTH-1 downto 0));	-- lower half in temp (temp is unsigned, mult_temp is std_logic_vector)
				mult_temp_H := std_logic_vector((mult_temp(((WIDTH*2)-1) downto WIDTH)));
				
				wait for 40 ns;
				
				assert(result_h = std_logic_vector(mult_temp_H)) report "Error : (high result) = " & integer'image(conv_integer(result_h)) & "" severity warning;
				assert(result = std_logic_vector(temp)) report "Error : (low result) = " & integer'image(conv_integer(result)) & "" severity warning;


        -- test mult (unsigned)
				OP_sel    <= "000101";
				
				mult_temp := std_logic_vector(to_unsigned(j, temp'length) * to_unsigned(i, temp'length));
				temp := unsigned(mult_temp(WIDTH-1 downto 0));
				mult_temp_H := std_logic_vector(unsigned(mult_temp(((WIDTH*2)-1) downto WIDTH)));
			
				wait for 40 ns;
				
				assert(result_h = std_logic_vector(mult_temp_H)) report "Error : (high result) = " & integer'image(conv_integer(result_h)) & "" severity warning;
				assert(result = std_logic_vector(temp)) report "Error : (low result) = " & integer'image(conv_integer(result)) & "" severity warning;

        
		-- test and
				OP_sel    <= "000110";
				
				temp := to_unsigned(j, temp'length) and to_unsigned(i, temp'length);
				
				wait for 40 ns;
				
				assert(result = std_logic_vector(temp)) report "Error (and) : = " & integer'image(conv_integer(result)) & "" severity warning;
				
		
		-- test shift right logical
				shift_amount <= std_logic_vector(to_unsigned(j, shift_amount'length));
							
				OP_sel    <= "001100";
			
				temp := shift_right(to_unsigned(i, temp'length), to_integer(unsigned(shift_amount)));
--				tempSignal <= temp;
								
				wait for 40 ns;
				
				assert(result = std_logic_vector(temp)) report "Error (SRL) : = " & integer'image(to_integer(unsigned(result))) & "" severity warning;
		
		
		-- test shift left logical
				shift_amount <= std_logic_vector(to_unsigned(j, shift_amount'length));
				
				OP_sel    <= "001101";
				
				temp := shift_left(to_unsigned(i, temp'length), to_integer(unsigned(shift_amount)));
--				tempSignal <= temp;
								
				wait for 40 ns;
				
				assert(result = std_logic_vector(temp)) report "Error (SLL) : = " & integer'image(to_integer(unsigned(result))) & "" severity warning;
		
		
		-- test shift right arithmetic
				shift_amount <= std_logic_vector(to_unsigned(j, shift_amount'length));
				
				OP_sel    <= "001110";
				
				temp := unsigned(shift_right(to_signed(i, temp'length), to_integer(unsigned(shift_amount))));
--				tempSignal <= temp;
				
				wait for 40 ns;
				
				assert(result = std_logic_vector(temp)) report "Error (SRA) : = " & integer'image(to_integer(unsigned(result))) & "" severity warning;
		
		
		-- test set on less than (input1 < input2)
				OP_sel    <= "001111";
				
				if(to_signed(j, temp'length) < to_signed(i, temp'length)) then
					temp := to_unsigned(1, temp'length);
				else
					temp := to_unsigned(0, temp'length);
				end if;
				
				wait for 40 ns;
				
				assert(result = std_logic_vector(temp)) report "Error (SLT input1 < input2) : = " & integer'image(conv_integer(result)) & "" severity warning;
		
		
		-- test branch taken (BRLTEZ)
				OP_sel    <= "011001";
				
				if(to_signed(j, temp'length) <= 0) then
					temp_branch := '1';
				else
					temp_branch := '0';
				end if;
				
				wait for 40 ns;
				
				assert (branch = temp_branch) report "Error (BRLTEZ) : = " & integer'image(to_integer(unsigned'('0' & branch))) & "" severity warning;
		
		
		-- test branch taken (BRGTZ)
				OP_sel    <= "011010";
				
				if(to_signed(j, temp'length) > 0) then
					temp_branch := '1';
				else
					temp_branch := '0';
				end if;
			
				wait for 40 ns;
				
				assert (branch = temp_branch) report "Error (BRGTZ) : = " & integer'image(to_integer(unsigned'('0' & branch))) & "" severity warning;
				
				
		-- test branch taken (BRLTZ)
				OP_sel    <= "011011";
				
				if(to_signed(j, temp'length) < 0) then
					temp_branch := '1';
				else
					temp_branch := '0';
				end if;
			
				wait for 40 ns;
				
				assert (branch = temp_branch) report "Error (BRLTZ) : = " & integer'image(to_integer(unsigned'('0' & branch))) & "" severity warning;
				
				
		-- test branch taken (BRGTEZ)
				OP_sel    <= "011100";
				
				if(to_signed(j, temp'length) >= 0) then
					temp_branch := '1';
				else
					temp_branch := '0';
				end if;
			
				wait for 40 ns;
				
				assert (branch = temp_branch) report "Error (BRGTEZ) : = " & integer'image(to_integer(unsigned'('0' & branch))) & "" severity warning;
						
			end loop;
		end loop;
	

		report "Simulation Finished" severity note;
        wait;

    end process;



end TB;