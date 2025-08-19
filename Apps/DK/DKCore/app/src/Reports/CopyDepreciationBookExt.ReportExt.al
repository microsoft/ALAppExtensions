// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------

namespace Microsoft.Finance.Core;

using Microsoft.FixedAssets.Depreciation;

reportextension 13602 CopyDepreciationBookExt extends "Copy Depreciation Book"
{
    requestpage
    {
        layout
        {
            modify("CopyChoices[5]")
            {
                Visible = false;
            }

            modify("CopyChoices[6]")
            {
                Visible = false;
            }
        }
    }

}
