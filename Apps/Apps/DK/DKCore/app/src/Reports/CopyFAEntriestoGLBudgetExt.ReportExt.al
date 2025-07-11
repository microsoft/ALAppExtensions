// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------

namespace Microsoft.Finance.Core;

using Microsoft.FixedAssets.FixedAsset;

reportextension 13603 CopyFAEntriestoGLBudgetExt extends "Copy FA Entries to G/L Budget"
{
    requestpage
    {
        layout
        {
            modify("TransferType[5]")
            {
                Visible = false;
            }

            modify("TransferType[6]")
            {
                Visible = false;
            }
        }
    }
}
