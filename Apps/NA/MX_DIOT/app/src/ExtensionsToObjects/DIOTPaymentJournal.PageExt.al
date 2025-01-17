// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------
namespace Microsoft.Finance.GeneralLedger.Journal;

pageextension 27036 "DIOT Payment Journal" extends "Payment Journal"
{
    layout
    {
        addafter(Description)
        {
            field("DIOT Type of Operation"; "DIOT Type of Operation")
            {
                ApplicationArea = BasicMX;
                Caption = 'DIOT Type of Operation';
                ToolTip = 'Specifies the DIOT operation type for this document.';
            }
        }
    }
}
