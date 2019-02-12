// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------

tableextension 13640 "OIOUBL-Payment Terms" extends "Payment Terms"
{
    fields
    {
        field(13630; "OIOUBL-Code"; Option)
        {
            Caption = 'Code';
            OptionMembers = " ",Contract,Specific;
        }
    }
    keys
    {
    }
}