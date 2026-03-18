// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------

namespace Microsoft.DemoData.Finance;

codeunit 13805 "Create Allocation Account DK"
{
    InherentEntitlements = X;
    InherentPermissions = X;

    trigger OnRun()
    var
        FinanceModuleSetup: Record "Finance Module Setup";
        CreateGLAccDK: Codeunit "Create GL Acc. DK";
    begin
        FinanceModuleSetup.Get();
        FinanceModuleSetup."Yearly License All. GLAcc No." := CreateGLAccDK.Itexpenses();
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
        YearlyLicenseFeeTok: Label 'Yearly license fee, design software', MaxLength = 100;
}