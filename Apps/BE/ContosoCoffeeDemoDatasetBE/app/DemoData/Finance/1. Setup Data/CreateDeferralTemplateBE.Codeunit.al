// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------
namespace Microsoft.DemoData.Finance;

codeunit 11455 "Create Deferral Template BE"
{
    Access = Internal;
    InherentEntitlements = X;
    InherentPermissions = X;

    trigger OnRun()
    var
        FinanceModuleSetup: Record "Finance Module Setup";
        CreateGLAccountBE: Codeunit "Create GL Account BE";
    begin
        FinanceModuleSetup.Get();
        FinanceModuleSetup."Deferral Account No." := CreateGLAccountBE.Transfers();
        FinanceModuleSetup.Modify();
    end;
}