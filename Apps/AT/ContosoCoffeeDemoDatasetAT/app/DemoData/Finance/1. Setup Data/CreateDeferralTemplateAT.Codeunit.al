// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------
namespace Microsoft.DemoData.Finance;

codeunit 11146 "Create Deferral Template AT"
{
    Access = Internal;
    InherentEntitlements = X;
    InherentPermissions = X;

    trigger OnRun()
    var
        FinanceModuleSetup: Record "Finance Module Setup";
        CreateATGLAccount: Codeunit "Create AT GL Account";
    begin
        FinanceModuleSetup.Get();
        FinanceModuleSetup."Deferral Account No." := CreateATGLAccount.DeferredIncome();
        FinanceModuleSetup.Modify();
    end;
}
