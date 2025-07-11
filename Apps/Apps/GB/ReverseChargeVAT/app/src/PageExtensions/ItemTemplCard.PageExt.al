// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------
namespace Microsoft.Finance.VAT.Setup;

using Microsoft.Inventory.Item;

pageextension 10554 "Item Templ. Card" extends "Item Templ. Card"
{
    layout
    {
#if not CLEAN27
#pragma warning disable AL0432
        modify("Reverse Charge Applies")
#pragma warning restore  AL0432
        {
            Visible = not IsNewFeatureEnabled;
        }
#endif
        addafter("VAT Bus. Posting Gr. (Price)")
        {
            field("Reverse Charge Applies GB"; Rec."Reverse Charge Applies GB")
            {
                ApplicationArea = Basic, Suite;
                ToolTip = 'Specifies if this item is subject to reverse charge.';
#if not CLEAN27
                Visible = IsNewFeatureEnabled;
                Enabled = IsNewFeatureEnabled;
#endif
            }
        }
    }

#if not CLEAN27
    var
        IsNewFeatureEnabled: Boolean;
#endif

#if not CLEAN27
    trigger OnOpenPage()
    var
        ReverseChargeVAT: Codeunit "Reverse Charge VAT GB";
    begin
        IsNewFeatureEnabled := ReverseChargeVAT.IsEnabled();
    end;
#endif
}