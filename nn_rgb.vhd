-- nn_rgb.vhd
--
-- top level


library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;
use std.textio.all;
use ieee.std_logic_textio.all;
entity nn_rgb is
  port (clk       : in  std_logic;                      -- input clock 
        reset_n   : in  std_logic;                      -- reset (invoked during configuration)
        enable_in : in  std_logic_vector(2 downto 0);   -- three slide switches
        -- image in
        vs_in     : in  std_logic;                      -- vertical sync
        hs_in     : in  std_logic;                      -- horizontal sync
        de_in     : in  std_logic;                      -- data enable is '1' for valid pixel
        r_in      : in  std_logic_vector(7 downto 0);   -- red component of pixel
        g_in      : in  std_logic_vector(7 downto 0);   -- green component of pixel
        b_in      : in  std_logic_vector(7 downto 0);   -- blue component of pixel
        -- image out
        vs_out    : out std_logic;                      
        hs_out    : out std_logic;
        de_out    : out std_logic;
        r_out     : out std_logic_vector(7 downto 0);
        g_out     : out std_logic_vector(7 downto 0);
        b_out     : out std_logic_vector(7 downto 0);
        --
      -- additional output port for white pixel count
        white_pixel_count_out : out integer range 0 to 1000000;
       pixel_size_out: out integer range 0 to 1000000;
      
        clk_o     : out std_logic;                      -- output clock 
        led       : out std_logic_vector(2 downto 0));  
end nn_rgb;

architecture behave of nn_rgb is

    -- input FFs
    signal reset                   : std_logic;
    signal enable                  : std_logic_vector(2 downto 0);
    signal vs_0, hs_0, de_0        : std_logic;
    signal r_0, g_0, b_0           : integer;
    signal pixel_count_out : integer range 0 to 1000000;
    -- internal Signals between neurons
    signal h_0, h_1, h_2, output   : integer range 0 to 255;
    -- output of signal processing
    signal vs_1, hs_1, de_1        : std_logic;
    signal result                  : std_logic_vector(7 downto 0);
    signal white_pixel_count: integer:=0;
    signal pixel_size: integer:=0;

begin
              
                    
              
   
                  


hidden0: entity work.neuron 
    generic map ( w1 =>  -46,
                  w2 =>  -41 ,
                  w3 => -45,
                  bias => 24348)
     port map (   clk    => clk,
                  x1     => r_0,
                  x2     => g_0,
                  x3     => b_0,
                  output => h_0);    

hidden1: entity work.neuron 
    generic map ( w1 => -91,
                  w2 => -76,
                  w3 => -92,
                  bias =>43290)
     port map (   clk    => clk,
                  x1     => r_0,
                  x2     => g_0,
                  x3     => b_0,
                  output => h_1);    
    
hidden2: entity work.neuron 
    generic map ( w1 => -89,
                  w2 => -95,
                  w3 => -103 ,
                  bias => 47014)
     port map (   clk    => clk,
                  x1     => r_0,
                  x2     => g_0,
                  x3     => b_0,
                    output => h_2);        
                          
output0: entity work.neuron 
    generic map ( w1 =>   -23 ,
                  w2 => -75 ,
                  w3 => -89,
                  bias => 17216 )
     port map (   clk    => clk,
                  x1     => h_0,
                  x2     => h_1,
                  x3     => h_2,
                  output => output);     
                     
control: entity work.control
    generic map (delay => 9) 
    port map (  clk      => clk,
                reset    => reset,
                vs_in    => vs_0,
                hs_in    => hs_0,
                de_in    => de_0,
                vs_out   => vs_1,
                hs_out   => hs_1,
                de_out   => de_1);
               --pixel_count_out => pixel_count_out);
process
begin   
    wait until rising_edge(clk);
   
    -- input FFs for control
    reset <= not reset_n;
    enable <= enable_in;
    -- input FFs for video signal
    vs_0  <= vs_in;
    hs_0  <= hs_in;
    de_0  <= de_in;
    r_0   <= to_integer(unsigned(r_in)); 
    g_0   <= to_integer(unsigned(g_in));
    b_0   <= to_integer(unsigned(b_in));  

    
end process;
     
process
begin
    wait until rising_edge(clk);
  
    if(output > 127) then
        result <= (others => '1');
      white_pixel_count<= white_pixel_count + 1;
    else
        result <= (others => '0');
    end if;
      
    -- output FFs 
    vs_out  <= vs_1;
    hs_out  <= hs_1;
    de_out  <= de_1;
    r_out   <= result;
    g_out   <= result;
    b_out   <= result;
   


if white_pixel_count > 0 then
        pixel_size <= pixel_count_out / white_pixel_count;
    else
        pixel_size <= 0;
    end if;
   
    white_pixel_count_out <= white_pixel_count;
    pixel_size_out<= pixel_size;
  
end process;


clk_o <= clk;
led   <= "000";


end behave;