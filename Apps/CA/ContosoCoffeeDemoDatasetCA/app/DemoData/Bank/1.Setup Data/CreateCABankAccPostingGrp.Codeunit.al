// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------

namespace Microsoft.DemoData.Bank;

using Microsoft.DemoData.Finance;
using Microsoft.DemoTool.Helpers;

codeunit 27014 "Create CA Bank Acc Posting Grp"
{
    InherentPermissions = X;
    InherentEntitlements = X;

    trigger OnRun()
    var
        ContosoPostingGroup: Codeunit "Contoso Posting Group";
        CreateCAGLAccounts: Codeunit "Create CA GL Accounts";
    begin
        ContosoPostingGroup.InsertBankAccountPostingGroup(FCY(), CreateCAGLAccounts.BankCurrenciesFCYUSD());
        ContosoPostingGroup.InsertBankAccountPostingGroup(LCY(), CreateCAGLAccounts.BankCurrenciesLCY());
    end;

    procedure FCY(): Code[20]
    begin
        exit(FCYTok);
    end;

    procedure LCY(): Code[20]
    begin
        exit(LCYTok);
    end;

    var
        FCYTok: Label 'FCY', MaxLength = 20;
        LCYTok: Label 'LCY', MaxLength = 20;
}
