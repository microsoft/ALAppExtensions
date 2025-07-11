// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------
namespace Microsoft.Finance.GeneralLedger.Setup;

pageextension 18940 "GL Setup Ext" extends "General Ledger Setup"
{
    layout
    {
        addafter("Check G/L Account Usage")
        {
            field("Activate Cheque No."; "Activate Cheque No.")
            {
                ApplicationArea = Basic, Suite;
                Importance = Additional;
                ToolTip = 'Specifies if you want to activate cheque number functionality.';
            }
        }
    }
}
