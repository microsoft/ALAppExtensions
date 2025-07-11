// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------
namespace Microsoft.Service.Document;

pageextension 31090 "Service Quotes CZL" extends "Service Quotes"
{
    layout
    {
        addlast(Control1)
        {
            field("Variable Symbol CZL"; Rec."Variable Symbol CZL")
            {
                ApplicationArea = Basic, Suite;
                ToolTip = 'Specifies the detail information for payment.';
            }
            field("Constant Symbol CZL"; Rec."Constant Symbol CZL")
            {
                ApplicationArea = Basic, Suite;
                ToolTip = 'Specifies the additional symbol of bank payments.';
                Visible = false;
            }
            field("Specific Symbol CZL"; Rec."Specific Symbol CZL")
            {
                ApplicationArea = Basic, Suite;
                ToolTip = 'Specifies the additional symbol of bank payments.';
                Visible = false;
            }
            field("Bank Account Code CZL"; Rec."Bank Account Code CZL")
            {
                ApplicationArea = Basic, Suite;
                ToolTip = 'Specifies a code to idenfity bank account of company.';
                Visible = false;
            }
            field("Bank Account No. CZL"; Rec."Bank Account No. CZL")
            {
                ApplicationArea = Basic, Suite;
                ToolTip = 'Specifies the number used by the bank for the bank account.';
            }
            field("IBAN CZL"; Rec."IBAN CZL")
            {
                ApplicationArea = Basic, Suite;
                ToolTip = 'Specifies the bank account''s international bank account number.';
            }
        }
    }
}
