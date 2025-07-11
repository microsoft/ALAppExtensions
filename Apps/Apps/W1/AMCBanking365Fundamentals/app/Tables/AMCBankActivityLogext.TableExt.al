// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------
namespace Microsoft.Bank.Payment;

using Microsoft.Utilities;

tableextension 20106 "AMC Bank Activity Log ext." extends "Activity Log"
{
    fields
    {
        field(20100; "AMC Bank WebLog Status"; Enum AMCBankWebLogStatus)
        {
            Caption = 'Status';
            DataClassification = CustomerContent;
        }
    }

}
