// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------
namespace Microsoft.Finance.VAT.Reporting;

using Microsoft.Purchases.History;

pageextension 10068 "IRS 1099 Pstd. P. CrMemo Sub." extends "Posted Purch. Cr. Memo Subform"
{
    layout
    {
        addafter("Units per Parcel")
        {
            field("1099 Liable"; Rec."1099 Liable")
            {
                ApplicationArea = BasicUS;
                Visible = false;
            }
        }
    }
}