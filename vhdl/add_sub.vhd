library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity add_sub is
    port(
        a        : in  std_logic_vector(31 downto 0);
        b        : in  std_logic_vector(31 downto 0);
        sub_mode : in  std_logic;
        carry    : out std_logic;
        zero     : out std_logic;
        r        : out std_logic_vector(31 downto 0)
    );
end add_sub;

architecture synth of add_sub is

signal result_add : std_logic_vector(32 downto 0);
signal carry_in : std_logic_vector(31 downto 0);
signal b_S : std_logic_vector(31 downto 0);


begin
	carry_in <= (31 downto 1 => '0') & sub_mode;
	b_s <= (31 downto 0 => sub_mode) xor b;
	result_add <= std_logic_vector(unsigned('0' & a) + unsigned('0' & b_s) + unsigned('0' & carry_in));
	carry <= result_add(32);
	r <= result_add(31 downto 0);
	zero <= '1' when unsigned(result_add(31 downto 0)) = 0 else '0';

end synth;
