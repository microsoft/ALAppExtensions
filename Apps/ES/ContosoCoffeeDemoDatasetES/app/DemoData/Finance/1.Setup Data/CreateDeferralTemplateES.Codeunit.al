// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------
namespace Microsoft.DemoData.Finance;

codeunit 10885 "Create Deferral Template ES"
{
    Access = Internal;
    InherentEntitlements = X;
    InherentPermissions = X;

    trigger OnRun()
    var
        FinanceModuleSetup: Record "Finance Module Setup";
        CreateESGLAccounts: Codeunit "Create ES GL Accounts";
    begin
        FinanceModuleSetup.Get();
        FinanceModuleSetup."Deferral Account No." := CreateESGLAccounts.OtherCreditors();
        FinanceModuleSetup.Modify();
    end;
}