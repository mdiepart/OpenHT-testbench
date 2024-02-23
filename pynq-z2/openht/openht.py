#!/usr/bin/env python
# GnuRadio Pynq OpenHT interface
# Sebastien Van Cauwenberghe, ON4SEB

from pynq import Overlay
from pynq import MMIO

class OpenHT:
    def __init__(self):
        self.ol = Overlay("openht.bit")

        self._baseaddr_oht = int(self.ol.ip_dict['openht_wrapper_0']['parameters']['C_BASEADDR'], 16)
        self._baseaddr_rx = int(self.ol.ip_dict['rx_driver/rx_fifo2apb_0']['parameters']['C_BASEADDR'], 16)
        self._baseaddr_tx = int(self.ol.ip_dict['tx_driver/tx_fifo2apb_0']['parameters']['C_BASEADDR'], 16)

        self.openht = MMIO(self._baseaddr_oht, 65536)
        self.tx = MMIO(self._baseaddr_tx, 65536)
        self.rx = MMIO(self._baseaddr_rx, 65536)
        print("OpenHT successfully initialized")
