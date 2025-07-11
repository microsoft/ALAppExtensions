// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------

namespace Microsoft.Finance.Core;

using Microsoft.Finance.GeneralLedger.Setup;

pageextension 13602 GeneralLedgerSetupExt extends "General Ledger Setup"
{
    layout
    {

        modify("Tax Invoice Renaming Threshold")
        {
            Visible = false;
        }

        modify("Payroll Transaction Import")
        {
            Visible = true;
        }

        modify("Payroll Trans. Import Format")
        {
            Visible = true;
        }
    }
}
