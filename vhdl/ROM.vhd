library ieee;
use ieee.std_logic_1164.all;

entity ROM is
    port(
        clk     : in  std_logic;
        cs      : in  std_logic;
        read    : in  std_logic;
        address : in  std_logic_vector(9 downto 0);
        rddata  : out std_logic_vector(31 downto 0)
    );
end ROM;

architecture synth of ROM is

component ROM_Block is
	port(
	address		: IN STD_LOGIC_VECTOR (9 DOWNTO 0);
	clock		: IN STD_LOGIC  := '1';
	q		: OUT STD_LOGIC_VECTOR (31 DOWNTO 0));
end component;

signal flag : std_logic;
signal temp_add : std_logic_vector(9 downto 0);
signal readdata: std_logic_vector(31 downto 0);

begin

rom_blck : ROM_Block port map(
	address => address,
	clock => clk,
	q => readdata
);

reading_save : process(clk, read, cs, address)
begin 
	if(rising_edge(clk)) then
		flag <= read and cs;
		temp_add <= address;
end if;
end process;

reading : process(flag, temp_add)
begin
   if(flag = '1') then
	rddata <= readdata;
   else 
       rddata <= (others => 'Z');
   end if;
end process;

end synth;
