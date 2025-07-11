// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------

namespace Microsoft.Bank.Payment;

using Microsoft.Finance.GeneralLedger.Setup;

pageextension 13624 GeneralLedgerSetup extends "General Ledger Setup"
{
    layout
    {
        addlast(General)
        {
            field("FIK Import Format"; "FIK Import Format")
            {
                ApplicationArea = Basic, Suite;
                ToolTip = 'Specifies the FIK import format.';
            }
        }
    }
}
