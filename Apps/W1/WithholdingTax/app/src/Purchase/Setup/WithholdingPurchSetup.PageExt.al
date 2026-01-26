// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------
pageextension 6794 "Withholding Purch Setup" extends "Purchases & Payables Setup"
{
    layout
    {
        addafter("Posted Prepmt. Cr. Memo Nos.")
        {
            field("Wthldg. Tax Certificate Nos."; Rec."Wthldg. Tax Certificate Nos.")
            {
                ApplicationArea = Basic, Suite;
                ToolTip = 'Specifies the No. Series for the Withholding Tax Certificates.';
            }
        }
    }
}