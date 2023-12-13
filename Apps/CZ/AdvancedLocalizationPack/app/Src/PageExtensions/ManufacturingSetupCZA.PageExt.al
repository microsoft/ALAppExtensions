// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------
namespace Microsoft.Manufacturing.Setup;

pageextension 31251 "Manufacturing Setup CZA" extends "Manufacturing Setup"
{
    layout
    {
        addlast(General)
        {
            field("Default Gen.Bus.Post. Grp. CZA"; Rec."Default Gen.Bus.Post. Grp. CZA")
            {
                ApplicationArea = Basic, Suite;
                ToolTip = 'Specifies the default general bussines posting group.';
            }
            field("Exact Cost Rev.Mand. Cons. CZA"; Rec."Exact Cost Rev.Mand. Cons. CZA")
            {
                ApplicationArea = Basic, Suite;
                ToolTip = 'Specifies that a storno transaction cannot be posted unless the Applies-from Entry field on the item journal line specifies an entry.';
            }
        }
    }
}
