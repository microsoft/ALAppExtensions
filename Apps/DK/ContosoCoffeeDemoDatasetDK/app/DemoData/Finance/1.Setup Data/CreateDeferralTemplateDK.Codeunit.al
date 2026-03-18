// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------
namespace Microsoft.DemoData.Finance;

codeunit 13735 "Create Deferral Template DK"
{
    Access = Internal;
    InherentEntitlements = X;
    InherentPermissions = X;

    trigger OnRun()
    var
        FinanceModuleSetup: Record "Finance Module Setup";
        CreateGLAccDK: Codeunit "Create GL Acc. DK";
    begin
        FinanceModuleSetup.Get();
        FinanceModuleSetup."Deferral Account No." := CreateGLAccDK.Deferrals();
        FinanceModuleSetup.Modify();
    end;
}