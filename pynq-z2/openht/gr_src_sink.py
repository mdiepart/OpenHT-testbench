#!/usr/bin/env python
# GnuRadio Source/Sink interface
# Sebastien Van Cauwenberghe, ON4SEB

import socket
import numpy as np

class GR:
    def __init__(self, in_port=10000, out_port=10001):
        UDP_IP = "0.0.0.0"
        self.TX_UDP_PORT = in_port
        self.TX_RESP_UDP_PORT = out_port
        self.TX_ADDR = None

        self._sock = socket.socket(socket.AF_INET, # Internet
                     socket.SOCK_DGRAM) # UDP
        self._sock.setsockopt(socket.SOL_SOCKET, socket.SO_REUSEADDR, 1)
        self._sock.bind((UDP_IP, self.TX_UDP_PORT))

    def get_in_buffer(self):
        data, udp_addr = self._sock.recvfrom(1500)
        self.TX_ADDR = udp_addr[0]
        float_data = np.frombuffer(data, dtype=np.single)
        return float_data

    def convert_f2fixed(self, data, bits=16, dtype=np.int16):
        float_data = data * ((2**(bits-1)) - 1)
        return float_data.astype(dtype)

    def convert_cplx2f(self, data):
        tx_data_i = data >> 16
        tx_data_q = data & 0xFFFF

        data_i = tx_data_i if tx_data_i < 32768 else tx_data_i - 65536
        data_q = tx_data_q if tx_data_q < 32768 else tx_data_q - 65536
        return (data_i, data_q)

    def convert_fixed2f(self, data, bits=16):
        float_data = np.asarray(data, dtype=np.single)
        float_data_normalized = float_data / (2**(bits-1))
        return float_data_normalized

    def send_out_buffer(self, data):
        if self.TX_ADDR:
            self._sock.sendto(data, (self.TX_ADDR, self.TX_RESP_UDP_PORT))
