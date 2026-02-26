// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------
namespace Microsoft.DemoData.Finance;

codeunit 13425 "Create Deferral Template FI"
{
    Access = Internal;
    InherentEntitlements = X;
    InherentPermissions = X;

    trigger OnRun()
    var
        FinanceModuleSetup: Record "Finance Module Setup";
        CreateFIGLAccounts: Codeunit "Create FI GL Accounts";
    begin
        FinanceModuleSetup.Get();
        FinanceModuleSetup."Deferral Account No." := CreateFIGLAccounts.Accrualsanddeferredincome5();
        FinanceModuleSetup.Modify();
    end;
}
