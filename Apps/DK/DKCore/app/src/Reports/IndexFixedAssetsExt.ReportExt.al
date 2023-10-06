// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------

namespace Microsoft.Finance.Core;

using Microsoft.FixedAssets.FixedAsset;

reportextension 13605 IndexFixedAssetsExt extends "Index Fixed Assets"
{
    requestpage
    {
        layout
        {
            modify("IndexChoices[5]")
            {
                Visible = false;
            }

            modify("IndexChoices[6]")
            {
                Visible = false;
            }
        }
    }
}
