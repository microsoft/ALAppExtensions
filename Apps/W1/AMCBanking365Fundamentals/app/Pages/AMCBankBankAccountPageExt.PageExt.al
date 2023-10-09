// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------
namespace Microsoft.Bank.Payment;

using Microsoft.Bank.BankAccount;

pageextension 20111 "AMC Bank Bank Account Page Ext" extends "Bank Account List"
{
    ContextSensitiveHelpPage = '304';

    actions
    {
        addAfter("C&ontact")
        {
            action(AMCShowServicePage)
            {
                ApplicationArea = Basic, Suite;
                Visible = IsAMCFundamentalsEnabled;
                Caption = 'AMC Bank Page';
                Image = SignUp;
                Promoted = true;
                ToolTip = 'Calls the AMC Bank Myaccount Page to be able to setup further informations for the bank accounts. External webpage will be opened by this button.';
                PromotedCategory = Category6;
                PromotedOnly = true;
                trigger OnAction();
                begin
                    AMCBankServiceRequestMgt.ShowServiceLinkPage('myaccount', true);
                end;
            }
        }
    }

    var
        AMCBankServiceRequestMgt: codeunit "AMC Bank Service Request Mgt.";
        AMCBankingMgt: Codeunit "AMC Banking Mgt.";
        IsAMCFundamentalsEnabled: Boolean;

    trigger OnOpenPage()
    begin
        IsAMCFundamentalsEnabled := AMCBankingMgt.IsAMCFundamentalsEnabled();

    end;

}
