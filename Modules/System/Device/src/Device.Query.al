// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------

/// <summary>
/// Displays a list of devices.
/// </summary>
query 776 Device
{
    Caption = 'Device';
    Permissions = tabledata Device = r;

    elements
    {
        dataitem(Device; Device)
        {
            column(MAC_Address; "MAC Address")
            {
            }
            column(Name; Name)
            {
            }
            column(Device_Type; "Device Type")
            {
            }
            column(Enabled; Enabled)
            {
            }
        }
    }
}