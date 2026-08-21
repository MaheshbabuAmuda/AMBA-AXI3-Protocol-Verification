# AXI3 Protocol Verification using SystemVerilog & UVM

## 📌 Project Overview

This project implements a complete **AXI3 Protocol Verification Environment** using **SystemVerilog and UVM**.

The objective of this project is to develop a modular, reusable, and scalable **AXI3 Verification IP (VIP)** that can generate, drive, monitor, verify, and measure coverage for AXI3 read and write transactions.

The verification environment contains independent **Master and Slave UVCs**, a **Virtual Sequencer**, **Scoreboard**, **TLM communication**, functional coverage, and SystemVerilog assertions.

The project was developed as part of my **ASIC Design Verification learning journey**.

---

## 🏗️ Verification Architecture
<img width="1044" height="635" alt="image" src="https://github.com/user-attachments/assets/21a15e09-a9fe-4946-ad2b-1e4e774ede95" />

📁 Project Structure

<img width="458" height="639" alt="image" src="https://github.com/user-attachments/assets/15037a64-9b80-4c42-a39f-3f923aff3c8d" />


The overall transaction flow is:

<img width="564" height="814" alt="image" src="https://github.com/user-attachments/assets/2f21a521-81e9-47bf-adf8-f0009cf657f2" />

🔹 **AXI3 Features Verified**

The verification environment covers the major AXI3 transaction scenarios:

**Write Transactions**

Write Address Channel

Write Data Channel

Write Response Channel

AWVALID / AWREADY handshake

WVALID / WREADY handshake

BVALID / BREADY handshake

Write response checking

Write strobes (WSTRB)

**Read Transactions**

Read Address Channel

Read Data Channel

ARVALID / ARREADY handshake

RVALID / RREADY handshake

Read response checking

Read data verification

**Burst Types**

FIXED burst

INCR burst

WRAP burst

**Transfer Types**

Aligned transfers

Unaligned transfers

Narrow transfers

Multiple-beat burst transfers

<img width="556" height="252" alt="image" src="https://github.com/user-attachments/assets/9270b891-386f-48d9-a0c8-4c96a7a4565d" />


🔍 **Scoreboard**

Master Monitor

      │
      ▼
      
Analysis FIFO

      │
      ▼
      
Scoreboard

      ▲
      │
      
Analysis FIFO

      ▲
      │
      
Slave Monitor


✅ **Verification Results**

The final verification environment achieved:

**🛡️ Assertions**

Functional / Covergroup Coverage : 98.99%

Assertion Coverage               : 100%

Assertion Failures               : 0

**Scoreboard Results**

Total Transactions Compared : 92

Matched                     : 92

Mismatched                  : 0

Match Rate                  : 100%

**UVM Report**:
UVM_ERROR  : 0,
UVM_FATAL  : 0

These results demonstrate successful end-to-end transaction generation, driving, monitoring, comparison, and protocol checking.

<img width="511" height="546" alt="image" src="https://github.com/user-attachments/assets/a5e7d630-df35-4249-8037-8e4476dbe66e" />


👨‍💻 Author

Mahesh Amudha

Aspiring ASIC Design Verification Engineer

Focus Areas:
SystemVerilog | UVM | AXI3 Protocol Verification | Functional Verification | Assertion-Based Verification | ASIC Design Verification
