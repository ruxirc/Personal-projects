@echo off
REM ****************************************************************************
REM Vivado (TM) v2024.1 (64-bit)
REM
REM Filename    : simulate.bat
REM Simulator   : AMD Vivado Simulator
REM Description : Script for simulating the design by launching the simulator
REM
REM Generated by Vivado on Wed Nov 27 13:02:30 +0200 2024
REM SW Build 5076996 on Wed May 22 18:37:14 MDT 2024
REM
REM Copyright 1986-2022 Xilinx, Inc. All Rights Reserved.
REM Copyright 2022-2024 Advanced Micro Devices, Inc. All Rights Reserved.
REM
REM usage: simulate.bat
REM
REM ****************************************************************************
REM simulate design
echo "xsim rsa_uart_system_behav -key {Behavioral:sim_1:Functional:rsa_uart_system} -tclbatch rsa_uart_system.tcl -protoinst "protoinst_files/design_rsa.protoinst" -log simulate.log"
call xsim  rsa_uart_system_behav -key {Behavioral:sim_1:Functional:rsa_uart_system} -tclbatch rsa_uart_system.tcl -protoinst "protoinst_files/design_rsa.protoinst" -log simulate.log
if "%errorlevel%"=="0" goto SUCCESS
if "%errorlevel%"=="1" goto END
:END
exit 1
:SUCCESS
exit 0
