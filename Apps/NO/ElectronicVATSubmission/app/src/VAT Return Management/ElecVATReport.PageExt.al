// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------
namespace Microsoft.Finance.VAT.Reporting;

pageextension 10697 "Elec. VAT Report" extends "VAT Report"
{
    layout
    {
        addlast(General)
        {
            field("Message Id"; "Message Id")
            {
                ApplicationArea = Basic, Suite;
                Editable = false;
                ToolTip = 'Specifies the unique reference of the submission attempt.';
            }
            field(KID; KID)
            {
                ApplicationArea = Basic, Suite;
                ToolTip = 'Specifies the number to identify the payment.';
            }
        }
    }
}
