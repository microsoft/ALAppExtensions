// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------

namespace Microsoft.DemoData.Finance;

codeunit 11636 "Create Allocation Account CH"
{
    InherentEntitlements = X;
    InherentPermissions = X;

    trigger OnRun()
    var
        FinanceModuleSetup: Record "Finance Module Setup";
        CreateCHGLAccounts: Codeunit "Create CH GL Accounts";
    begin
        FinanceModuleSetup.Get();
        FinanceModuleSetup."Yearly License All. GLAcc No." := CreateCHGLAccounts.ItHardwareAndSoftware();
        FinanceModuleSetup.Modify();
    end;
}
