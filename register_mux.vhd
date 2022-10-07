-- Greg Stitt
-- University of Florida

library ieee;
use ieee.std_logic_1164.all;

entity register_mux is
  generic (
    width  :     positive := 32);
  port (
    in0    : in  std_logic_vector(4 downto 0);
    in1    : in  std_logic_vector(4 downto 0);
    sel    : in  std_logic;
    output : out std_logic_vector(4 downto 0));
end register_mux;

architecture BHV of register_mux is
begin
  with sel select
    output <=
    in0 when '0',
    in1 when others;
end BHV;