// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------
namespace Microsoft.Finance.VAT.Reporting;

using Microsoft.Purchases.Document;

pageextension 10069 "IRS 1099 Purch. Ret.Order Sub." extends "Purchase Return Order Subform"
{
    layout
    {
        addafter(ShortcutDimCode8)
        {
            field("1099 Liable"; Rec."1099 Liable")
            {
                ApplicationArea = BasicUS;
                Visible = false;
            }
        }
    }
}