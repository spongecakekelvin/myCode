
import sys
import config_utils
import file_utils
import os
import os.path
import time
import tool_encrypt
import tool_icon
import tool_splash


try: input = raw_input
except NameError: pass

def main():
    
    file_utils.printF("-------------------------all start------------------------\r\n")
    tool_encrypt.main()
    tool_icon.main()
    tool_splash.main()
    
    file_utils.printF("-------------------------all over------------------------")

if __name__ == '__main__':
    main()
