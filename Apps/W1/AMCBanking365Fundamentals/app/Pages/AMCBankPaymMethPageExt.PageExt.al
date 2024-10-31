// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------
namespace Microsoft.Bank.Payment;

using Microsoft.Bank.BankAccount;

pageextension 20104 "AMC Bank Paym. Meth. Page Ext" extends "Payment Methods"
{

    ContextSensitiveHelpPage = '402';

    layout
    {
        addAfter("Pmt. Export Line Definition")
        {
            field("Bank Payment Type"; Rec."AMC Bank Pmt. Type")
            {
                ApplicationArea = Basic, Suite;
                ToolTip = 'Specifies the payment type that the AMC Banking 365 Fundamentals extension requires when you export payments that have the selected payment method.';
                Visible = IsAMCFundamentalsEnabled;
            }
        }
    }
    var
        AMCBankingMgt: Codeunit "AMC Banking Mgt.";
        IsAMCFundamentalsEnabled: Boolean;

    trigger OnOpenPage()
    begin
        IsAMCFundamentalsEnabled := AMCBankingMgt.IsAMCFundamentalsEnabled();
    end;
}
