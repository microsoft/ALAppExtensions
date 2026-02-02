// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------

namespace Microsoft.DemoData.Finance;

codeunit 11458 "Create Allocation Account US"
{
    InherentEntitlements = X;
    InherentPermissions = X;

    trigger OnRun()
    var
        FinanceModuleSetup: Record "Finance Module Setup";
        CreateUSGLAccounts: Codeunit "Create US GL Accounts";
    begin
        FinanceModuleSetup.Get();
        FinanceModuleSetup."Yearly License All. GLAcc No." := CreateUSGLAccounts.LicenseFeesRoyalties();
        FinanceModuleSetup.Modify();
    end;

    procedure Licenses(): Code[20]
    begin
        exit(LicensesTok);
    end;

    procedure LicensesDescription(): Text[100]
    begin
        exit(YearlyLicenseFeeTok);
    end;

    var
        LicensesTok: Label 'LICENSES', MaxLength = 20;
        YearlyLicenseFeeTok: Label 'Yearly license fee', MaxLength = 100;
}