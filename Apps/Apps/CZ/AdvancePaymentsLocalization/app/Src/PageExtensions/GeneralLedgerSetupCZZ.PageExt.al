// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------
namespace Microsoft.Finance.AdvancePayments;

using Microsoft.Finance.GeneralLedger.Setup;

pageextension 31022 "General Ledger Setup CZZ" extends "General Ledger Setup"
{
    layout
    {
        addlast(General)
        {
            field("Adv. Deduction Exch. Rate CZZ"; Rec."Adv. Deduction Exch. Rate CZZ")
            {
                ApplicationArea = Basic, Suite;
                ToolTip = 'Specifies advance deduction exchange rate.';
                Importance = Additional;
                Visible = false;
            }
        }
    }
}
