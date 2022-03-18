library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity top is
  generic (
    clk_hz : integer := 100e6;
    sclk_hz : integer := 4e6;
    clk_counter_bits : integer := 24; --for ready_fsm to periodically generate ready signal for chip
    total_bits : integer := 16; --total bits tx by sensor chip
    leading_z : integer := 3;
    trailing_z : integer := 4
  );
  port (
    clk : in std_logic;
    rst : in std_logic;
    miso : in std_logic;
    cs : out std_logic;
    sclk : out std_logic;
    led_out : out std_logic_vector(7 downto 0)
  );
end top;

architecture rtl of top is

  -- SPI controller signals
  signal ready : std_logic := '0';
  signal valid : std_logic := '0';
  signal data : std_logic_vector(total_bits-leading_z-trailing_z-2 downto 0);

  --prescaler
  signal clock_out : std_logic;

  --pwm signals
  signal pwm_res : integer := 8;
  --signal fpga_clk : integer := 100e6;
  --signal pwm_clk : integer := 4e6;

  signal debounced_rst : std_logic := '0';

  --------------    READY FSM PROCESS SIGNALS   -------------------------
  -- This counter controls how often samples are fetched and sent
  signal clk_counter : unsigned(clk_counter_bits - 1 downto 0);

  type state_type is (WAITING, RECEIVING, SENDING); 
  signal state : state_type;

begin
  
  --port map DUT/ instantiate components here -----------------------
  
  DUT : entity work.spi_master(rtl)
  generic map(
    clk_hz => clk_hz,
    total_bits => total_bits,
    leading_z => leading_z,
    trailing_z => trailing_z,
    sclk_hz => sclk_hz
  )
  port map (
      clk => clk,
      rst => debounced_rst,
      valid => valid,
      cs => cs,
      sclk => sclk,
      miso => miso,
      ready => ready,
      data => data
  );

  DUT2 : entity work.prescaler(rtl)
  generic map(
   -- clk_hz => fpga_clk,
    --sclk_hz => pwm_clk,
    fpga_clk => clk_hz,
    clk => sclk_hz,
    pwm_res => pwm_res
  )
  port map(
    clk => clk,
    rst => debounced_rst,
    clock_out => clock_out
  );

  DUT4 : entity work.reset_sync(rtl)
  port map(
    clk => clk,
    rst_in => rst,
    rst_out => debounced_rst
  );

   READY_FSM_PROC : process(clk)
    begin
      if rising_edge(clk) then
        if rst = '1' then
          clk_counter <= (others => '0');
          state <= WAITING;
          ready <= '0';
          
        else
          clk_counter <= clk_counter + 1;
        
          case state is
            
            -- Wait for some time
            when WAITING =>
              -- If every bit in clk_counter is a '1'
              if signed(clk_counter) = to_signed(-1, clk_counter'length) then
                state <= RECEIVING;
                ready <= '1';
              end if;

            -- Fetch the results from the ambient light sensor
            when RECEIVING =>
              if valid = '1' then
                state <= WAITING;
                ready <= '0';
              end if;
            
            -- Wait until the UART module acknowledges the transfer
            when SENDING =>
              -- If timed out
              if clk_counter = 0 then
                state <= WAITING;
              end if;       
          end case;
        end if;
      end if;
    end process;

end architecture;