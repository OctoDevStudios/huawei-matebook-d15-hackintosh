/*
 * Intel ACPI Component Architecture
 * AML/ASL+ Disassembler version 20260930 (64-bit version)
 * Copyright (c) 2000 - 2026 Intel Corporation
 * 
 * Disassembling to symbolic ASL+ operators
 *
 * Disassembly of /Volumes/EFI/EFI/OC/ACPI/SSDT-PS2K.aml
 *
 * Original Table Header:
 *     Signature        "SSDT"
 *     Length           0x00000093 (147)
 *     Revision         0x02
 *     Checksum         0x32
 *     OEM ID           "HUAWEI"
 *     OEM Table ID     "PS2K"
 *     OEM Revision     0x00000000 (0)
 *     Compiler ID      "INTL"
 *     Compiler Version 0x20200925 (538970405)
 */
DefinitionBlock ("", "SSDT", 2, "HUAWEI", "PS2K", 0x00000000)
{
    External (_SB_.PCI0.LPCB.PS2K, DeviceObj)

    Scope (\_SB.PCI0.LPCB.PS2K)
    {
        If (_OSI ("Darwin"))
        {
            Name (RMCF, Package (0x02)
            {
                "Keyboard", 
                Package (0x02)
                {
                    "Swap command and option", 
                    ">n"
                }
            })
        }
    }
}

