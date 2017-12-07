LIBRARY IEEE;
USE  IEEE.STD_LOGIC_1164.all;
USE  IEEE.STD_LOGIC_ARITH.all;
USE  IEEE.STD_LOGIC_UNSIGNED.all;


ENTITY WhackAMole IS
   GENERIC( 
      num_hex_digits : integer := 2);
   
   PORT( 
      reset              : IN     std_logic;  -- Map this Port to a Switch within your [Port Declarations / Pin Planer]  
      clock_50           : IN     std_logic;  -- Using the DE2 50Mhz Clk, in order to Genreate the 400Hz signal... clk_count_400hz reset count value must be set to:  <= x"0F424"
		
      lcd_rs             : OUT    std_logic;
      lcd_e              : OUT    std_logic;
      lcd_rw             : OUT    std_logic;
      lcd_on             : OUT    std_logic;
      lcd_blon           : OUT    std_logic;
      
      
      data_bus_0         : INOUT  STD_LOGIC;
      data_bus_1         : INOUT  STD_LOGIC;
      data_bus_2         : INOUT  STD_LOGIC;
      data_bus_3         : INOUT  STD_LOGIC;
      data_bus_4         : INOUT  STD_LOGIC;
      data_bus_5         : INOUT  STD_LOGIC;
      data_bus_6         : INOUT  STD_LOGIC;
      data_bus_7         : INOUT  STD_LOGIC;
      
      Hex_Display_Data_0 : IN     STD_LOGIC;
      Hex_Display_Data_1 : IN     STD_LOGIC;
      Hex_Display_Data_2 : IN     STD_LOGIC;
      Hex_Display_Data_3 : IN     STD_LOGIC;
      Hex_Display_Data_4 : IN     STD_LOGIC;
      Hex_Display_Data_5 : IN     STD_LOGIC;
      Hex_Display_Data_6 : IN     STD_LOGIC;
      Hex_Display_Data_7 : IN     STD_LOGIC;
		
		Kyliereset,w,x,y,z: IN std_logic;
		A,B,C,D,A1,B1,C1,D1,E1,F1,G1,A2,B2,C2,D2,E2,F2,G2,A3,B3,C3,D3,E3,F3,G3: OUT std_logic);

-- Declarations

END WhackAMole ;

--
ARCHITECTURE WhackAMole_arch OF WhackAMole IS

	
	component lfsr --random generator 
		port(clk1 : in std_logic;
			  cout : out std_logic_vector(7 downto 0));
	end component;
	
	component seg --7 segment display
	Port( BITS : in std_LOGIC_vector(3 downto 0);
	A_1,B_1,C_1,D_1,E_1,F_1,G_1 : out STD_LOGIC);
	end component;
	
--	component clock_Divider
--	port ( clk,Kyliereset: in std_logic;
--		clock_out: out std_logic);
--	end component;

  type character_string is array ( 0 to 31 ) of STD_LOGIC_VECTOR( 7 downto 0 );

	type state_type is (hold, func_set, display_on, mode_set, print_string,
                      line2, return_home, drop_lcd_e, reset1, reset2,
                       reset3, display_off, display_clear);
							  
	signal state, next_command         : state_type;

  
  
							  
	type game_level_types is (State_A, State_B, State_C, State_D, state_E, state_F,State_g,State_H,State_I,State_J);
	
	signal game_state : game_level_types := State_A;
  
  
  signal lcd_display_string          : character_string;
  
  signal lcd_display_string_01       : character_string;
  signal lcd_display_string_02       : character_string;  
  signal lcd_display_string_03       : character_string;
 
  
  signal data_bus_value, next_char   : STD_LOGIC_VECTOR(7 downto 0);
  signal clk_count_400hz             : STD_LOGIC_VECTOR(19 downto 0);
  
  signal char_count                  : STD_LOGIC_VECTOR(4 downto 0);
  signal clk_400hz_enable,lcd_rw_int : std_logic;
  
  signal Hex_Display_Data            : STD_LOGIC_VECTOR(7 DOWNTO 0); 
  signal data_bus                    : STD_LOGIC_VECTOR(7 downto 0);	
  signal LCD_CHAR_ARRAY              : STD_LOGIC_VECTOR(3 DOWNTO 0);
  
  --SIGNAL SIG_ENABLE_count            : STD_LOGIC_VECTOR(19 DOWNTO 0) := "00000000000000000000";  
  --SIGNAL LCD_ENABLE_SET              : std_logic;
  --SIGNAL LCD_ENABLE_RESET            : std_logic;
  --SIGNAL ENABLE_LINE                 : std_logic := '0';
	
 signal timer: std_logic_vector(32 downto 0);
 signal rand_num: std_logic_vector(7 downto 0);
 signal points_1:std_logic_vector (3 downto 0);
 signal points_2:std_logic_vector (3 downto 0);
 
 begin
 
 randomgen: lfsr
		port map(
			clk1 => clock_50,
			cout => rand_num);
	
seg1:seg
			port map(Bits => points_1,
			A_1=>A1,
			B_1=>B1,
			C_1=>C1,
			D_1=>D1,
			E_1=>E1,
			F_1=>F1,
			G_1=>G1);
seg2:seg
			port map(Bits => points_2,
			A_1=>A2,
			B_1=>B2,
			C_1=>C2,
			D_1=>D2,
			E_1=>E2,
			F_1=>F2,
			G_1=>G2);
		
  


--===================================================--  
-- SIGNAL STD_LOGIC_VECTORS assigned to OUTPUT PORTS 
--===================================================--    
Hex_Display_Data(0) <= Hex_Display_Data_0;
Hex_Display_Data(1) <= Hex_Display_Data_1;   
Hex_Display_Data(2) <= Hex_Display_Data_2;
Hex_Display_Data(3) <= Hex_Display_Data_3;  
Hex_Display_Data(4) <= Hex_Display_Data_4;
Hex_Display_Data(5) <= Hex_Display_Data_5;  
Hex_Display_Data(6) <= Hex_Display_Data_6;
Hex_Display_Data(7) <= Hex_Display_Data_7;  

data_bus_0 <= data_bus(0);
data_bus_1 <= data_bus(1);
data_bus_2 <= data_bus(2);
data_bus_3 <= data_bus(3);
data_bus_4 <= data_bus(4);
data_bus_5 <= data_bus(5);
data_bus_6 <= data_bus(6);
data_bus_7 <= data_bus(7);

--line 1     "BEGIN"
 lcd_display_string_01 <= (x"42",x"65",x"67",x"69",x"6E",x"20",x"20",x"20",x"20",x"20",x"20",x"20",x"20",x"20",x"20",x"20",
									x"20",x"20",x"20",x"20",x"20",x"20",x"20",x"20",x"20",x"20",x"20",x"20",x"20",x"20",x"20",x"20");
 
 --game over 
 lcd_display_string_02 <= (x"47",x"61",x"6D",x"65",x"20",x"4F",x"76",x"65",x"72",x"21",x"20",x"20",x"20",x"20",x"20",x"20",
									x"20",x"20",x"20",x"20",x"20",x"20",x"20",x"20",x"20",x"20",x"20",x"20",x"20",x"20",x"20",x"20");
 
 -- PLAY
 lcd_display_string_03 <= (x"20",x"50",x"6C",x"61",x"79",x"20",x"20",x"20",x"20",x"20",x"20",x"20",x"20",x"20",x"20",x"20",
									x"20",x"20",x"20",x"20",x"20",x"20",x"20",x"20",x"20",x"20",x"20",x"20",x"20",x"20",x"20",x"20");
 
-- BIDIRECTIONAL TRI STATE LCD DATA BUS
   data_bus <= data_bus_value when lcd_rw_int = '0' else "ZZZZZZZZ";
   
-- LCD_RW PORT is assigned to it matching SIGNAL 
 lcd_rw <= lcd_rw_int;
 


			  
		
  CNT: process (clock_50,kyliereset,w,x,y,z)
BEGIN

			if points_1<="0000" and points_2<="0000" then
				next_char <= lcd_display_string_01(CONV_INTEGER(char_count));
			elsif points_1 >="1001" and points_2 >="1001" then
				next_char <= lcd_display_string_02(CONV_INTEGER(char_count));
			else 
				next_char <= lcd_display_string_03(CONV_INTEGER(char_count));
			end if;
			
		if Kyliereset= '1' then
			points_1<="0000";
			points_2<="0000";
			game_state <= State_A;

		elsif clock_50'event and clock_50 = '1' then 
			

			CASE (game_state) IS
	  
			when State_A =>
			A<='1';
			B<='0';
			C<='0';
			D<='0';
			A3<='1';
			B3<='0';
			C3<='0';
			D3<='1';
			E3<='1';
			F3<='1';
			G3<='1';
			if w = '0' then
				points_1<=points_1 + 1;
				if points_1>="1001" then
					points_2<=points_2+1;
					points_1<="0000";
				end if;
				if (rand_num(2 downto 0)="000" or rand_num(2 downto 0)="001" or rand_num(2 downto 0)="010") and points_2<="0001" then
					game_state <= State_B;
				elsif (rand_num(2 downto 0)="011" or rand_num(2 downto 0)="100" or rand_num(2 downto 0)="101") and points_2<="0001" then
					game_state <= State_C;
				elsif (rand_num(2 downto 0)="110" or rand_num(2 downto 0)="111") and points_2<="0001" then
					game_state <= State_D;
				elsif (rand_num(2 downto 0)="000" or rand_num(2 downto 0)="001") and points_2>"0001" then
					game_state <= State_E;
				elsif (rand_num(2 downto 0)="010" or rand_num(2 downto 0)="011") and points_2>"0001" then
					game_state <= State_F;
				elsif (rand_num(2 downto 0)="100" or rand_num(2 downto 0)="101") and  points_2>"0001" then
					game_state <= State_G;
				elsif (rand_num(2 downto 0)="110" or rand_num(2 downto 0)="111") and points_2>"0001" then
					game_state <= State_H;
				end if;
				timer <= (others => '0');
			elsif timer < "11101110011010110010100000000" then
				if points_2<="011" then
					timer <= timer + 1;
				else
					timer <= timer +5;
				end if;
			 else 
				if (rand_num(2 downto 0)="000" or rand_num(2 downto 0)="001" or rand_num(2 downto 0)="010") and points_2<="0001" then
					game_state <= State_B;
				elsif (rand_num(2 downto 0)="011" or rand_num(2 downto 0)="100" or rand_num(2 downto 0)="101") and points_2<="0001" then
					game_state <= State_C;
				elsif (rand_num(2 downto 0)="110" or rand_num(2 downto 0)="111") and points_2<="0001" then
					game_state <= State_D;
				elsif rand_num(2 downto 0)="000" or rand_num(2 downto 0)="001" or rand_num(2 downto 0)="010" then
					game_state<=State_H;
				elsif rand_num(2 downto 0)="011" or rand_num(2 downto 0)="100" or rand_num(2 downto 0)="101" then
					game_state<=State_I;
				elsif rand_num(2 downto 0)="110" or rand_num(2 downto 0)="111" then
					game_state<=State_J;
				end if; 
				timer <= (others => '0');
			end if;
			
			when State_B =>
		A<='0';
		B<='1';
		C<='0';
		D<='0';
		A3<='1';
		B3<='0';
		C3<='0';
		D3<='1';
		E3<='1';
		F3<='1';
		G3<='1';
		if x = '0' then
			points_1<=points_1 + 1;
			if points_1>="1001" then
				points_2<=points_2+1;
				points_1<="0000";
			end if;
			if (rand_num(2 downto 0)="000" or rand_num(2 downto 0)="001" or rand_num(2 downto 0)="010") and points_2<="0001" then
					game_state <= State_A;
				elsif (rand_num(2 downto 0)="011" or rand_num(2 downto 0)="100" or rand_num(2 downto 0)="101") and points_2<="0001" then
					game_state <= State_C;
				elsif (rand_num(2 downto 0)="110" or rand_num(2 downto 0)="111") and points_2<="0001" then
					game_state <= State_D;
				elsif rand_num(2 downto 0)="000" or rand_num(2 downto 0)="001" or rand_num(2 downto 0)="010" then
					game_state<=State_F;
				elsif rand_num(2 downto 0)="011" or rand_num(2 downto 0)="100" or rand_num(2 downto 0)="101" then
					game_state<=State_G;
				elsif rand_num(2 downto 0)="110" or rand_num(2 downto 0)="111" then
					game_state<=State_J;
				end if;
			timer <= (others => '0');
		elsif timer < "11101110011010110010100000000" then
		 if points_2<="011" then
					timer <= timer + 1;
				else
					timer <= timer +5;
				end if;
		 else 
		  if (rand_num(2 downto 0)="000" or rand_num(2 downto 0)="001" or rand_num(2 downto 0)="010") and points_2<="0001" then
					game_state <= State_A;
				elsif (rand_num(2 downto 0)="011" or rand_num(2 downto 0)="100" or rand_num(2 downto 0)="101") and points_2<="0001" then
					game_state <= State_C;
				elsif (rand_num(2 downto 0)="110" or rand_num(2 downto 0)="111") and points_2<="0001" then
					game_state <= State_D;
				elsif rand_num(2 downto 0)="000" or rand_num(2 downto 0)="001" or rand_num(2 downto 0)="010" then
					game_state<=State_F;
				elsif rand_num(2 downto 0)="011" or rand_num(2 downto 0)="100" or rand_num(2 downto 0)="101" then
					game_state<=State_G;
				elsif rand_num(2 downto 0)="110" or rand_num(2 downto 0)="111" then
					game_state<=State_J;
				end if; 
		  timer <= (others => '0');
		end if;
		
		when State_C =>
		A<='0';
		B<='0';
		C<='1';
		D<='0';
		A3<='1';
		B3<='0';
		C3<='0';
		D3<='1';
		E3<='1';
		F3<='1';
		G3<='1';
		if y = '0' then
			points_1<=points_1 + 1;
			if points_1>="1001" then
				points_2<=points_2+1;
				points_1<="0000";
			end if;
			if (rand_num(2 downto 0)="000" or rand_num(2 downto 0)="001" or rand_num(2 downto 0)="010") and points_2<="0001" then
					game_state <= State_A;
				elsif (rand_num(2 downto 0)="011" or rand_num(2 downto 0)="100" or rand_num(2 downto 0)="101") and points_2<="0001" then
					game_state <= State_B;
				elsif (rand_num(2 downto 0)="110" or rand_num(2 downto 0)="111") and points_2<="0001" then
					game_state <= State_D;
				elsif rand_num(2 downto 0)="000" or rand_num(2 downto 0)="001" or rand_num(2 downto 0)="010" then
					game_state<=State_E;
				elsif rand_num(2 downto 0)="011" or rand_num(2 downto 0)="100" or rand_num(2 downto 0)="101" then
					game_state<=State_G;
				elsif rand_num(2 downto 0)="110" or rand_num(2 downto 0)="111" then
					game_state<=State_I;
				end if;
			timer <= (others => '0');
		elsif timer < "11101110011010110010100000000" then
		 if points_2<="011" then
					timer <= timer + 1;
				else
					timer <= timer +5;
				end if;
		 else 
		  if (rand_num(2 downto 0)="000" or rand_num(2 downto 0)="001" or rand_num(2 downto 0)="010") and points_2<="0001" then
					game_state <= State_A;
				elsif (rand_num(2 downto 0)="011" or rand_num(2 downto 0)="100" or rand_num(2 downto 0)="101") and points_2<="0001" then
					game_state <= State_B;
				elsif (rand_num(2 downto 0)="110" or rand_num(2 downto 0)="111") and points_2<="0001" then
					game_state <= State_D;
				elsif rand_num(2 downto 0)="000" or rand_num(2 downto 0)="001" or rand_num(2 downto 0)="010" then
					game_state<=State_E;
				elsif rand_num(2 downto 0)="011" or rand_num(2 downto 0)="100" or rand_num(2 downto 0)="101" then
					game_state<=State_G;
				elsif rand_num(2 downto 0)="110" or rand_num(2 downto 0)="111" then
					game_state<=State_I;
				end if; 
		  timer <= (others => '0');
		end if;
	 
	  when State_D =>
		A<='0';
		B<='0';
		C<='0';
		D<='1';
		A3<='1';
		B3<='0';
		C3<='0';
		D3<='1';
		E3<='1';
		F3<='1';
		G3<='1';
		if z = '0' then
		points_1<=points_1 + 1;
		if points_1>="1001" then
			points_2<=points_2+1;
			points_1<="0000";
			end if;
			if (rand_num(2 downto 0)="000" or rand_num(2 downto 0)="001" or rand_num(2 downto 0)="010") and points_2<="0001" then
					game_state <= State_A;
				elsif (rand_num(2 downto 0)="011" or rand_num(2 downto 0)="100" or rand_num(2 downto 0)="101") and points_2<="0001" then
					game_state <= State_B;
				elsif (rand_num(2 downto 0)="110" or rand_num(2 downto 0)="111") and points_2<="0001" then
					game_state <= State_C;
				elsif rand_num(2 downto 0)="000" or rand_num(2 downto 0)="001" or rand_num(2 downto 0)="010" then
					game_state<=State_E;
				elsif rand_num(2 downto 0)="011" or rand_num(2 downto 0)="100" or rand_num(2 downto 0)="101" then
					game_state<=State_F;
				elsif rand_num(2 downto 0)="110" or rand_num(2 downto 0)="111" then
					game_state<=State_H;
				end if;
			timer <= (others => '0');
		elsif timer < "11101110011010110010100000000" then
		 if points_2<="011" then
					timer <= timer + 1;
				else
					timer <= timer +5;
				end if;
		 else 
		  if (rand_num(2 downto 0)="000" or rand_num(2 downto 0)="001" or rand_num(2 downto 0)="010") and points_2<="0001" then
					game_state <= State_A;
				elsif (rand_num(2 downto 0)="011" or rand_num(2 downto 0)="100" or rand_num(2 downto 0)="101") and points_2<="0001" then
					game_state <= State_B;
				elsif (rand_num(2 downto 0)="110" or rand_num(2 downto 0)="111") and points_2<="0001" then
					game_state <= State_C;
				elsif rand_num(2 downto 0)="000" or rand_num(2 downto 0)="001" or rand_num(2 downto 0)="010" then
					game_state<=State_E;
				elsif rand_num(2 downto 0)="011" or rand_num(2 downto 0)="100" or rand_num(2 downto 0)="101" then
					game_state<=State_F;
				elsif rand_num(2 downto 0)="110" or rand_num(2 downto 0)="111" then
					game_state<=State_H;
				end if; 
		  timer <= (others => '0');
		end if;
		
		
		when State_E =>
			A<='1';
			B<='1';
			C<='0';
			D<='0';
			if points_2<"0100" then
				A3<='0';
				B3<='0';
				C3<='1';
				D3<='0';
				E3<='0';
				F3<='1';
				G3<='0';
			elsif points_2<"1010" then
				A3<='0';
				B3<='0';
				C3<='0';
				D3<='0';
				E3<='1';
				F3<='1';
				G3<='0';
			else
				A3<='0';
				B3<='1';
				C3<='1';
				D3<='1';
				E3<='0';
				F3<='0';
				G3<='0';
				points_1<="1111";
				points_2<="1111";
			end if;
			if w ='0' then
				points_1<=points_1 + 1;
				if points_1>="1001" then
					points_2<=points_2+1;
					points_1<="0000";
				end if;
				if rand_num(2 downto 0)="000" or rand_num(2 downto 0)="001" or rand_num(2 downto 0)="010" then
					game_state<=State_H;
				elsif rand_num(2 downto 0)="011" or rand_num(2 downto 0)="100" or rand_num(2 downto 0)="101" then
					game_state<=State_I;
				elsif rand_num(2 downto 0)="110" or rand_num(2 downto 0)="111" then
					game_state<=State_J;
				end if;
			elsif x ='0' then
				points_1<=points_1 + 1;
				if points_1>="1001" then
					points_2<=points_2+1;
					points_1<="0000";
				end if;
				if rand_num(2 downto 0)="000" or rand_num(2 downto 0)="001" or rand_num(2 downto 0)="010" then
					game_state<=State_F;
				elsif rand_num(2 downto 0)="011" or rand_num(2 downto 0)="100" or rand_num(2 downto 0)="101" then
					game_state<=State_G;
				elsif rand_num(2 downto 0)="110" or rand_num(2 downto 0)="111" then
					game_state<=State_J;
				end if;
				timer <= (others => '0');
			elsif timer < "11101110011010110010100000000" then
				if points_2<="011" then
					timer <= timer + 1;
				else
					timer <= timer +5;
				end if;
			 else 
				if rand_num(2 downto 0)="000" or rand_num(2 downto 0)="001" then
					game_state<=State_F;
				elsif rand_num(2 downto 0)="010" or rand_num(2 downto 0)="011" then
					game_state<=State_G;
				elsif rand_num(2 downto 0)="100" or rand_num(2 downto 0)="101" then
					game_state<=State_H;
				elsif rand_num(2 downto 0)="110" then
					game_state<=State_I;
				elsif rand_num(2 downto 0)="111" then
					game_state<=State_J;
				end if;
				timer <= (others => '0');
			end if;
			when State_F =>
		A<='1';
		B<='0';
		C<='1';
		D<='0';
		if points_2<"0100" then
				A3<='0';
				B3<='0';
				C3<='1';
				D3<='0';
				E3<='0';
				F3<='1';
				G3<='0';
			elsif points_2<"1010" then
				A3<='0';
				B3<='0';
				C3<='0';
				D3<='0';
				E3<='1';
				F3<='1';
				G3<='0';
			else
				A3<='0';
				B3<='1';
				C3<='1';
				D3<='1';
				E3<='0';
				F3<='0';
				G3<='0';
				points_1<="1111";
				points_2<="1111";
			end if;
			
			
		if w = '0' then
			points_1<=points_1 + 1;
			if points_1>="1001" then
				points_2<=points_2+1;
				points_1<="0000";
			end if;
			if rand_num(2 downto 0)="000" or rand_num(2 downto 0)="001" or rand_num(2 downto 0)="010" then
					game_state<=State_H;
				elsif rand_num(2 downto 0)="011" or rand_num(2 downto 0)="100" or rand_num(2 downto 0)="101" then
					game_state<=State_I;
				elsif rand_num(2 downto 0)="110" or rand_num(2 downto 0)="111" then
					game_state<=State_J;
				end if;
			elsif y = '0' then
			points_1<=points_1 + 1;
			if points_1>="1001" then
				points_2<=points_2+1;
				points_1<="0000";
			end if;
			if rand_num(2 downto 0)="000" or rand_num(2 downto 0)="001" then
					game_state<=State_E;
				elsif rand_num(2 downto 0)="010" or rand_num(2 downto 0)="011" then
					game_state<=State_G;
				elsif rand_num(2 downto 0)="100" or rand_num(2 downto 0)="101" then
					game_state<=State_H;
				elsif rand_num(2 downto 0)="110" then
					game_state<=State_I;
				elsif rand_num(2 downto 0)="111" then
					game_state<=State_J;
				end if;
			timer <= (others => '0');
		elsif timer < "11101110011010110010100000000" then
		 if points_2<="011" then
					timer <= timer + 1;
				else
					timer <= timer +5;
				end if;
		 else 
		  game_state <= State_E; 
		  timer <= (others => '0');
		end if;
		
	when State_G =>
		A<='1';
		B<='0';
		C<='0';
		D<='1';
		if points_2<"0100" then
				A3<='0';
				B3<='0';
				C3<='1';
				D3<='0';
				E3<='0';
				F3<='1';
				G3<='0';
			elsif points_2<"1010" then
				A3<='0';
				B3<='0';
				C3<='0';
				D3<='0';
				E3<='1';
				F3<='1';
				G3<='0';
			else
				A3<='0';
				B3<='1';
				C3<='1';
				D3<='1';
				E3<='0';
				F3<='0';
				G3<='0';
				points_1<="1111";
				points_2<="1111";
			end if;
		if w = '0' then
		points_1<=points_1 + 1;
		if points_1>="1001" then
			points_2<=points_2+1;
			points_1<="0000";
			end if;
			if rand_num(2 downto 0)="000" or rand_num(2 downto 0)="001" or rand_num(2 downto 0)="010" then
					game_state<=State_H;
				elsif rand_num(2 downto 0)="011" or rand_num(2 downto 0)="100" or rand_num(2 downto 0)="101" then
					game_state<=State_I;
				elsif rand_num(2 downto 0)="110" or rand_num(2 downto 0)="111" then
					game_state<=State_J;
				end if;
		elsif z = '0' then
		points_1<=points_1 + 1;
		if points_1>="1001" then
			points_2<=points_2+1;
			points_1<="0000";
			end if;
			if rand_num(2 downto 0)="000" or rand_num(2 downto 0)="001" or rand_num(2 downto 0)="010" then
					game_state<=State_E;
				elsif rand_num(2 downto 0)="011" or rand_num(2 downto 0)="100" or rand_num(2 downto 0)="101" then
					game_state<=State_F;
				elsif rand_num(2 downto 0)="110" or rand_num(2 downto 0)="111" then
					game_state<=State_H;
				end if;
			timer <= (others => '0');
		elsif timer < "11101110011010110010100000000" then
		 if points_2<="011" then
					timer <= timer + 1;
				else
					timer <= timer +5;
				end if;
		 else 
		  if rand_num(2 downto 0)="000" or rand_num(2 downto 0)="001" then
					game_state<=State_E;
				elsif rand_num(2 downto 0)="010" or rand_num(2 downto 0)="011" then
					game_state<=State_F;
				elsif rand_num(2 downto 0)="100" or rand_num(2 downto 0)="101" then
					game_state<=State_H;
				elsif rand_num(2 downto 0)="110" then
					game_state<=State_I;
				elsif rand_num(2 downto 0)="111" then
					game_state<=State_J;
				end if; 
		  timer <= (others => '0');
		end if;
		
		
			when State_H =>
		A<='0';
		B<='1';
		C<='1';
		D<='0';
		if points_2<"0100" then
				A3<='0';
				B3<='0';
				C3<='1';
				D3<='0';
				E3<='0';
				F3<='1';
				G3<='0';
			elsif points_2<"1010" then
				A3<='0';
				B3<='0';
				C3<='0';
				D3<='0';
				E3<='1';
				F3<='1';
				G3<='0';
			else
				A3<='0';
				B3<='1';
				C3<='1';
				D3<='1';
				E3<='0';
				F3<='0';
				G3<='0';
				points_1<="1111";
				points_2<="1111";
			end if;
		if x = '0' then
		points_1<=points_1 + 1;
		if points_1>="1001" then
			points_2<=points_2+1;
			points_1<="0000";
			end if;
			if rand_num(2 downto 0)="000" or rand_num(2 downto 0)="001" or rand_num(2 downto 0)="010" then
					game_state<=State_F;
				elsif rand_num(2 downto 0)="011" or rand_num(2 downto 0)="100" or rand_num(2 downto 0)="101" then
					game_state<=State_G;
				elsif rand_num(2 downto 0)="110" or rand_num(2 downto 0)="111" then
					game_state<=State_J;
				end if;
		elsif y = '0' then
		points_1<=points_1 + 1;
		if points_1>="1001" then
			points_2<=points_2+1;
			points_1<="0000";
			end if;
			if rand_num(2 downto 0)="000" or rand_num(2 downto 0)="001" or rand_num(2 downto 0)="010" then
					game_state<=State_E;
				elsif rand_num(2 downto 0)="011" or rand_num(2 downto 0)="100" or rand_num(2 downto 0)="101" then
					game_state<=State_G;
				elsif rand_num(2 downto 0)="110" or rand_num(2 downto 0)="111" then
					game_state<=State_I;
				end if;
			timer <= (others => '0');
		elsif timer < "11101110011010110010100000000" then
		 if points_2<="011" then
					timer <= timer + 1;
				else
					timer <= timer +5;
				end if;
		 else 
		  if rand_num(2 downto 0)="000" or rand_num(2 downto 0)="001" then
					game_state<=State_E;
				elsif rand_num(2 downto 0)="010" or rand_num(2 downto 0)="011" then
					game_state<=State_G;
				elsif rand_num(2 downto 0)="100" or rand_num(2 downto 0)="101" then
					game_state<=State_G;
				elsif rand_num(2 downto 0)="110" then
					game_state<=State_I;
				elsif rand_num(2 downto 0)="111" then
					game_state<=State_J;
				end if;
		  timer <= (others => '0');
		end if;
		when State_I =>
		A<='0';
		B<='1';
		C<='0';
		D<='1';
		if points_2<"0100" then
				A3<='0';
				B3<='0';
				C3<='1';
				D3<='0';
				E3<='0';
				F3<='1';
				G3<='0';
			elsif points_2<"1010" then
				A3<='0';
				B3<='0';
				C3<='0';
				D3<='0';
				E3<='1';
				F3<='1';
				G3<='0';
			else
				A3<='0';
				B3<='1';
				C3<='1';
				D3<='1';
				E3<='0';
				F3<='0';
				G3<='0';
				points_1<="1111";
				points_2<="1111";
			end if;
		if x = '0' then
		points_1<=points_1 + 1;
		if points_1>="1001" then
			points_2<=points_2+1;
			points_1<="0000";
			end if;
			if rand_num(2 downto 0)="000" or rand_num(2 downto 0)="001" or rand_num(2 downto 0)="010" then
					game_state<=State_F;
				elsif rand_num(2 downto 0)="011" or rand_num(2 downto 0)="100" or rand_num(2 downto 0)="101" then
					game_state<=State_G;
				elsif rand_num(2 downto 0)="110" or rand_num(2 downto 0)="111" then
					game_state<=State_J;
				end if;
		elsif z = '0' then
		points_1<=points_1 + 1;
		if points_1>="1001" then
			points_2<=points_2+1;
			points_1<="0000";
			end if;
			if rand_num(2 downto 0)="000" or rand_num(2 downto 0)="001" or rand_num(2 downto 0)="010" then
					game_state<=State_E;
				elsif rand_num(2 downto 0)="011" or rand_num(2 downto 0)="100" or rand_num(2 downto 0)="101" then
					game_state<=State_F;
				elsif rand_num(2 downto 0)="110" or rand_num(2 downto 0)="111" then
					game_state<=State_H;
				end if;
			timer <= (others => '0');
		elsif timer < "11101110011010110010100000000" then
		 if points_2<="011" then
					timer <= timer + 1;
				else
					timer <= timer +5;
				end if;
		 else 
		  if rand_num(2 downto 0)="000" or rand_num(2 downto 0)="001" then
					game_state<=State_E;
				elsif rand_num(2 downto 0)="010" or rand_num(2 downto 0)="011" then
					game_state<=State_G;
				elsif rand_num(2 downto 0)="100" or rand_num(2 downto 0)="101" then
					game_state<=State_G;
				elsif rand_num(2 downto 0)="110" then
					game_state<=State_H;
				elsif rand_num(2 downto 0)="111" then
					game_state<=State_J;
				end if; 
		  timer <= (others => '0');
		end if;
		
		
		
		when State_J =>
		A<='0';
		B<='0';
		C<='1';
		D<='1';
		if points_2<"0100" then
				A3<='0';
				B3<='0';
				C3<='1';
				D3<='0';
				E3<='0';
				F3<='1';
				G3<='0';
			elsif points_2<"1010" then
				A3<='0';
				B3<='0';
				C3<='0';
				D3<='0';
				E3<='1';
				F3<='1';
				G3<='0';
			else
				A3<='0';
				B3<='1';
				C3<='1';
				D3<='1';
				E3<='0';
				F3<='0';
				G3<='0';
				points_1<="1111";
				points_2<="1111";
			end if;
		if y = '0' then
		points_1<=points_1 + 1;
		if points_1>="1001" then
			points_2<=points_2+1;
			points_1<="0000";
			end if;
			if rand_num(2 downto 0)="000" or rand_num(2 downto 0)="001" or rand_num(2 downto 0)="010" then
					game_state<=State_E;
				elsif rand_num(2 downto 0)="011" or rand_num(2 downto 0)="100" or rand_num(2 downto 0)="101" then
					game_state<=State_G;
				elsif rand_num(2 downto 0)="110" or rand_num(2 downto 0)="111" then
					game_state<=State_I;
				end if;
		elsif z = '0' then
		points_1<=points_1 + 1;
		if points_1>="1001" then
			points_2<=points_2+1;
			points_1<="0000";
			end if;
			if rand_num(2 downto 0)="000" or rand_num(2 downto 0)="001" or rand_num(2 downto 0)="010" then
					game_state<=State_E;
				elsif rand_num(2 downto 0)="011" or rand_num(2 downto 0)="100" or rand_num(2 downto 0)="101" then
					game_state<=State_F;
				elsif rand_num(2 downto 0)="110" or rand_num(2 downto 0)="111" then
					game_state<=State_H;
				end if;
			timer <= (others => '0');
		elsif timer < "11101110011010110010100000000" then
		 if points_2<="011" then
					timer <= timer + 1;
				else
					timer <= timer +5;
				end if;
		 else 
		  if rand_num(2 downto 0)="000" or rand_num(2 downto 0)="001" then
					game_state<=State_E;
				elsif rand_num(2 downto 0)="010" or rand_num(2 downto 0)="011" then
					game_state<=State_F;
				elsif rand_num(2 downto 0)="100" or rand_num(2 downto 0)="101" then
					game_state<=State_G;
				elsif rand_num(2 downto 0)="110" then
					game_state<=State_H;
				elsif rand_num(2 downto 0)="111" then
					game_state<=State_I;
				end if; 
		  timer <= (others => '0');
		end if;

 end case;
			
end if;
                                                                                   
end process CNT;



 
 process(clock_50)
begin
      if (rising_edge(clock_50)) then
         if (reset = '0') then
            clk_count_400hz <= x"00000";
            clk_400hz_enable <= '0';
         else
            if (clk_count_400hz <= x"0F424") then             
                   clk_count_400hz <= clk_count_400hz + 1;                                   
                   clk_400hz_enable <= '0';                
            else
                   clk_count_400hz <= x"00000";
                   clk_400hz_enable <= '1';
            end if;
         end if;
      end if;
end process;  

process (clock_50, reset)
begin
 
  
        if reset = '0' then
           state <= reset1;
           data_bus_value <= x"38"; -- RESET
           next_command <= reset2;
           lcd_e <= '1';
           lcd_rs <= '0';
           lcd_rw_int <= '0';  
        
    
    
        elsif rising_edge(clock_50) then
             if clk_400hz_enable = '1' then  
                 
                 
                 
              --========================================================--                 
              -- State Machine to send commands and data to LCD DISPLAY
              --========================================================--
                 case state is
                 -- Set Function to 8-bit transfer and 2 line display with 5x8 Font size
                 -- see Hitachi HD44780 family data sheet for LCD command and timing details
                       
                       
                       
--======================= INITIALIZATION START ============================--
                       when reset1 =>
                            lcd_e <= '1';
                            lcd_rs <= '0';
                            lcd_rw_int <= '0';
                            data_bus_value <= x"38"; -- EXTERNAL RESET
                            state <= drop_lcd_e;
                            next_command <= reset2;
                            char_count <= "00000";
  
                       when reset2 =>
                            lcd_e <= '1';
                            lcd_rs <= '0';
                            lcd_rw_int <= '0';
                            data_bus_value <= x"38"; -- EXTERNAL RESET
                            state <= drop_lcd_e;
                            next_command <= reset3;
                            
                       when reset3 =>
                            lcd_e <= '1';
                            lcd_rs <= '0';
                            lcd_rw_int <= '0';
                            data_bus_value <= x"38"; -- EXTERNAL RESET
                            state <= drop_lcd_e;
                            next_command <= func_set;
            
            
                       -- Function Set
                       --==============--
                       when func_set =>                
                            lcd_e <= '1';
                            lcd_rs <= '0';
                            lcd_rw_int <= '0';
                            data_bus_value <= x"38";  -- Set Function to 8-bit transfer, 2 line display and a 5x8 Font size
                            state <= drop_lcd_e;
                            next_command <= display_off;
                            
                            
                            
                       -- Turn off Display
                       --==============-- 
                       when display_off =>
                            lcd_e <= '1';
                            lcd_rs <= '0';
                            lcd_rw_int <= '0';
                            data_bus_value <= x"08"; -- Turns OFF the Display, Cursor OFF and Blinking Cursor Position OFF.......(0F = Display ON and Cursor ON, Blinking cursor position ON)
                            state <= drop_lcd_e;
                            next_command <= display_clear;
                           
                           
                       -- Clear Display 
                       --==============--
                       when display_clear =>
                            lcd_e <= '1';
                            lcd_rs <= '0';
                            lcd_rw_int <= '0';
                            data_bus_value <= x"01"; -- Clears the Display    
                            state <= drop_lcd_e;
                            next_command <= display_on;
                           
                           
                           
                       -- Turn on Display and Turn off cursor
                       --===================================--
                       when display_on =>
                            lcd_e <= '1';
                            lcd_rs <= '0';
                            lcd_rw_int <= '0';
                            data_bus_value <= x"0C"; -- Turns on the Display (0E = Display ON, Cursor ON and Blinking cursor OFF) 
                            state <= drop_lcd_e;
                            next_command <= mode_set;
                          
                          
                       -- Set write mode to auto increment address and move cursor to the right
                       --====================================================================--
                       when mode_set =>
                            lcd_e <= '1';
                            lcd_rs <= '0';
                            lcd_rw_int <= '0';
                            data_bus_value <= x"06"; -- Auto increment address and move cursor to the right
                            state <= drop_lcd_e;
                            next_command <= print_string; 
                            
                                
--======================= INITIALIZATION END ============================--                          
                          
                          
                          
                          
--=======================================================================--                           
--               Write ASCII hex character Data to the LCD
--=======================================================================--
                       when print_string =>          
                            state <= drop_lcd_e;
                            lcd_e <= '1';
                            lcd_rs <= '1';
                            lcd_rw_int <= '0';
                          
                          
                               -- ASCII character to output
                               if (next_char(7 downto 4) /= x"0") then
                                  data_bus_value <= next_char;
                               else
                             
                                    -- Convert 4-bit value to an ASCII hex digit
                                    if next_char(3 downto 0) >9 then 
                              
                                    -- ASCII A...F
                                      data_bus_value <= x"4" & (next_char(3 downto 0)-9); 
                                    else 
                                
                                    -- ASCII 0...9
                                      data_bus_value <= x"3" & next_char(3 downto 0);
                                    end if;
                               end if;
                          
                            state <= drop_lcd_e; 
                          
                          
                            -- Loop to send out 32 characters to LCD Display (16 by 2 lines)
                               if (char_count < 31) AND (next_char /= x"fe") then
                                   char_count <= char_count +1;                            
                               else
                                   char_count <= "00000";
                               end if;
                  
                  
                  
                            -- Jump to second line?
                               if char_count = 15 then 
                                  next_command <= line2;
                   
                   
                   
                            -- Return to first line?
                               elsif (char_count = 31) or (next_char = x"fe") then
                                     next_command <= return_home;
                               else 
                                     next_command <= print_string; 
                               end if; 
                 
                 
                 
                       -- Set write address to line 2 character 1
                       --======================================--
                       when line2 =>
                            lcd_e <= '1';
                            lcd_rs <= '0';
                            lcd_rw_int <= '0';
                            data_bus_value <= x"c0";
                            state <= drop_lcd_e;
                            next_command <= print_string;      
                     
                     
                       -- Return write address to first character position on line 1
                       --=========================================================--
                       when return_home =>
                            lcd_e <= '1';
                            lcd_rs <= '0';
                            lcd_rw_int <= '0';
                            data_bus_value <= x"80";
                            state <= drop_lcd_e;
                            next_command <= print_string; 
                    
                    
                       -- lcd_e will match clk_CUSTOM_hz_enable line when instructed to go LOW, however, if the clk_CUSTOM_hz_enable source clock must be a lower count value or it will reset LOW anyhow.
                       -- The next states occur at the end of each command or data transfer to the LCD
                       -- Drop LCD E line - falling edge loads inst/data to LCD controller
                       --============================================================================--
                       when drop_lcd_e =>
                            lcd_e <= '0';
                            lcd_blon <= '1';
                            lcd_on   <= '1';
                            state <= hold;
                   
                       -- Hold LCD inst/data valid after falling edge of E line
                       --====================================================--
                       when hold =>
                            state <= next_command;
                            lcd_blon <= '1';
                            lcd_on   <= '1';
                       end case;




             end if;-- CLOSING STATEMENT FOR "IF clk_400hz_enable = '1' THEN"
             
      end if;-- CLOSING STATEMENT FOR "IF reset = '0' THEN" 
      
end process;                                                            
  
END ARCHITECTURE WhackAMole_arch;

