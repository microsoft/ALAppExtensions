// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------

namespace Microsoft.Finance.Core;

using Microsoft.FixedAssets.Ledger;

reportextension 13601 CancelFALedgerEntriesExt extends "Cancel FA Ledger Entries"
{
    requestpage
    {
        layout
        {
            modify("CancelChoices[5]")
            {
                Visible = false;
            }

            modify("CancelChoices[6]")
            {
                Visible = false;
            }
        }
    }
}
