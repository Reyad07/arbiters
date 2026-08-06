# test_fp_arb.py

import cocotb
from cocotb.triggers import Timer
import random
import logging
from colorama import Fore, Style

logger = logging.getLogger(__name__)
logger.setLevel(logging.INFO)

@cocotb.test()
async def basic_fp_test(dut):
    """ Test Fixed Point Arbiter with fixed values """
    
    logger.info(f"\n\n{Fore.CYAN}********** TEST 1 Started ***********{Style.RESET_ALL}\n")
    #logger.info(f"RTL dir {dir(dut)}")

    #parameter
    n = int(dut.N.value)
    logger.info(f"RTL instantiated with parameter N = {int(dut.N.value)}")
    
    # Run the test for 100 time
    for i in range (100):
        # Drivig the values
        req_i = random.randint(0,2**n-1)
        #req_i = 4
        dut.req_i.value = req_i 
        await Timer(1,unit="ns")

        logger.info(f"{Fore.GREEN} TB: reqester value {req_i}{Style.RESET_ALL}")
        logger.info(f"{Fore.GREEN}DUT: reqester value {dut.req_i.value}{Style.RESET_ALL}")

        result = dut.grant_o.value

        # this will find the the first appearance of '1' from the list rest of the 1 will get droppped
        if req_i != 0:
            expected = req_i & (-req_i)
            #print(f"First set bit vector: {first_one}")
            
        #check output
        assert dut.grant_o.value == expected, f"expected {expected}, but got {dut.grant_o.value}"

