// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------
namespace Microsoft.EServices.EDocument;

using Microsoft.Finance.GeneralLedger.Ledger;

pageextension 5583 "Digital Voucher G/L Entries" extends "General Ledger Entries"
{
    layout
    {
        // Notes systempart
        modify(Control1905767507)
        {
            Visible = true;
        }
    }
}
