library IEEE;
use IEEE.STD_LOGIC_1164.ALL;

entity seg is
Port ( 
	BITS : in std_LOGIC_vector(3 downto 0);
	A_1,B_1,C_1,D_1,E_1,F_1,G_1 : out STD_LOGIC);
end seg;

architecture Behavioral of seg is
	signal B0,B1,B2,B3 : STD_LOGIC;
begin
B0 <= BITS(3);
B1 <= BITS(2);
B2 <= BITS(1);
B3 <= BITS(0);


A_1 <= (not B0 and not B1 and not B2 and B3) or (not B0 and B1 and not B2 and not B3) or ( B0 and not B1 and B2 and B3) or ( B0 and B1 and not B2 and B3);
B_1 <= (not B0 and B1 and not B2 and B3) or (B1 and  B2 and not B3) or (B0 and B2 and B3) or ( B0 and  B1 and not B3);
C_1 <= (B0 and B1 and not B3) or (B0 and B1 and B2) or (not B0 and not B1 and B2 and not B3);
D_1 <= (not B0 and B1 and not B2 and not B3) or (B0 and not B1 and B2 and not B3) or (not B1 and not B2 and B3) or (B1 and B2 and B3);
E_1 <= (not B0 and B3) or (not B1 and not B2 and B3) or (not B0 and B1 and not B2);
F_1 <= (not B0 and not B1 and B3) or (not B0 and not B1 and B2) or (not B0 and B2 and B3) or (B0 and B1 and not B2 and B3);
G_1 <= (not B0 and not B1 and not B2) or (not B0 and B1 and B2 and B3) or (B0 and B1 and not B2 and not B3);

end Behavioral;
