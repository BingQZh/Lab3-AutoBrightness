library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity spi_master is
    generic (
        clk_hz : integer := 100MHz?; --FPGA clock
        total_bits : integer := 16; --total bits tx by sensor chip
        leading_z : integer := 3;
        trailing_z : integer := 4;
        sclk_hz : integer := 4MHz?); --sensor’s frequency 
    port (
        --fpga system
        clk : in std_logic;
        rst : in std_logic;

        -- slave chip
        cs : out std_logic; -- slave select: master uses this to select an available slave
                            -- cs = '1' : slave chip is idle and master can control
                            -- cs = '0' : slave chip is busy
        sclk : out std_logic; -- sclk is high when cs is '1'
        miso : in std_logic; -- data is written on falling edge of sclk and read on rising edge of sclk

        -- Internal interface when obtaining data back from slave chip
        ready : in std_logic;
        valid : out std_logic;
        data : out std_logic_vector(total_bits-leading_z-trailing_z-2 downto 0));
end spi_master;

architecture rtl of spi_master is

    type STATES is (IDLE, TRANSMISSION); -- FSM states
    signal Master_State : STATES := IDLE;

    signal temp_data : std_logic_vector(total_bits-leading_z-trailing_z-2 downto 0);
    signal i : integer range 0 to total_bits-leading_z-trailing_z-2 := total_bits-leading_z-trailing_z-2;

    signal sclk_counter : integer range 0 to total_bits := 0;

    function Rising_Edge_Check(FF2 : std_logic;
            FF3 : std_logic) return std_logic is
        variable result : std_logic;
    begin
        if FF3 = '0' and FF2 = '1' then -- this is a rising edge
            result := '1';
        else
            result := '0';
        end if;
        return result;
    end function;

    function Falling_Edge_Check(FF2 : std_logic;
            FF3 : std_logic) return std_logic is
        variable result : std_logic;
    begin
        if FF3 = '1' and FF2 = '0' then -- this is a falling edge
            result := '1';
        else
            result := '0';
        end if;
        return result;
    end function;

begin

    SYNCHRONIZER: process(clk)
    begin

        if rising_edge(clk) then
            if rst = '1' then
                miso_ff1 <= '0';
                miso_ff2 <= '0';
                miso_ff3 <= '0';
                valid_miso <= '0';
            else
                miso_ff1 <= miso;
                miso_ff2 <= miso_ff1;
                miso_ff3 <= miso_ff2;
                valid_miso <= miso_ff3;
            end if;
        end if;
    end process;

    -- SYNCHRONIZER_COMPARISON: process(clk)
    -- begin
    --     if rising_edge(clk) then
    --         if rst = '1' then
    --             validSDin <= '0';
    --             validBCLK <= '0';
    --             validLRCLK <= '0';
    --         else

    --             -- if BCLK_q2d_1 = BCLK_q2d_2 and BCLK_q2d_1 = BCLK_q2d_3 then
    --                 validBCLK <= BCLK_q2d_3;
    --             -- end if;

    --             -- if LRCLK_q2d_1 = LRCLK_q2d_2 and LRCLK_q2d_1 = LRCLK_q2d_3 then
    --                 validLRCLK <= LRCLK_q2d_3;
    --             -- end if;

    --             -- if SDin_q2d_1 = SDin_q2d_2 and SDin_q2d_1 = SDin_q2d_3 then
    --                 validSDin <= SDin_q2d_3;
    --             -- end if;

    --         end if;
    --     end if;
    -- end process;

    MASTER_PROC: process(clk)
    begin
        if rising_edge(clk) then
            if rst = '1' then
                Master_State <= IDLE;
            else
            
                case Master_State is

                    when IDLE =>
                        sclk <= '1';
                        prev_sclk <= sclk;

                        if ready = '1' then
                            Master_State <= TRANSMISSION;
                        end if;

                    when TRANSMISSION =>
                        prev_sclk <= sclk;
                        sclk <= not sclk after sclk_hz / 2;
                        cs <= '0';

                        -- the following if statement checks if data is ready to output!
                        if i = 0 then
                            data <= temp_data;
                            i <= 0;
                            valid <= '1';
                        else
                            valid <= '0';
                        end if;

                        if Rising_Edge_Check(prev_sclk, sclk) = '1' then -- rising edge of B clk
                            if sclk_counter < leading_z then
                                sclk_counter <= sclk_counter + 1;
                            else    
                                temp_data(i) <= valid_miso;
                                sclk_counter <= sclk_counter + 1;
                                if sclk_counter > total_bits-trailing_z-1 then
                                    i <= i - 1;
                                else
                                    if sclk_counter < total_bits then
                                        sclk_counter <= sclk_counter + 1;
                                    else
                                        sclk_counter <= 0;
                                        sclk <= '1';
                                        Master_State <= IDLE;
                                    end if;
                                end if;
                            end if;
                        end if;

                end case;
            end if;
        end if;
    end process;

end architecture;