-- Greg Stitt
-- University of Florida

library ieee;
use ieee.std_logic_1164.all;

entity mux3x1 is
  generic (
    width  :     positive := 32);
  port (
    in1    : in  std_logic_vector(width-1 downto 0);
    in2    : in  std_logic_vector(width-1 downto 0);
	in3    : in  std_logic_vector(width-1 downto 0);
    sel    : in  std_logic_vector(1 downto 0);
    output : out std_logic_vector(width-1 downto 0));
end mux3x1;

architecture BHV of mux3x1 is
begin
  with sel select
    output <=
    in3 when "00",  -- ram_out
	in2 when "01",  -- inport0
	in1 when "10",	-- inport1
    (others => '0') when others;
end BHV;
