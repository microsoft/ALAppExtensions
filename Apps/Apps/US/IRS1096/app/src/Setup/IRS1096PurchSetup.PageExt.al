// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------
namespace Microsoft.Purchases.Setup;

pageextension 10017 "IRS 1096 Purch. Setup" extends "Purchases & Payables Setup"
{
    layout
    {
        addafter("Posted Prepmt. Cr. Memo Nos.")
        {
            field("IRS 1096 Form No. Series"; Rec."IRS 1096 Form No. Series")
            {
                ApplicationArea = BasicUS;
                ToolTip = 'Specifies the code for the number series that will be used to assign numbers for 1096 forms.';
            }
        }
    }
}
