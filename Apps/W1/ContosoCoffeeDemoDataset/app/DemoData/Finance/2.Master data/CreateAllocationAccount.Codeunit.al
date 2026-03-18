// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------

namespace Microsoft.DemoData.Finance;

using Microsoft.DemoTool.Helpers;
using Microsoft.Finance.AllocationAccount;

codeunit 5426 "Create Allocation Account"
{
    InherentEntitlements = X;
    InherentPermissions = X;

    trigger OnRun()
    var
        FinanceModuleSetup: Record "Finance Module Setup";
        AllocationAccount: Record "Allocation Account";
        AllocAccountDistribution: Record "Alloc. Account Distribution";
        ContosoAllocationAccount: Codeunit "Contoso Allocation Account";
        CreateDimensionValue: Codeunit "Create Dimension Value";
        CreateGLAccount: Codeunit "Create G/L Account";
    begin
        FinanceModuleSetup.Get();
        ContosoAllocationAccount.InsertAllocationAccount(
            Licenses(), LicensesDescription(),
            AllocationAccount."Account Type"::Fixed, AllocationAccount."Document Lines Split"::"Split Amount");
        ContosoAllocationAccount.InsertAllocationAccountDistribution(
            Licenses(), 10000, AllocAccountDistribution."Account Type"::Fixed, 1, 50,
            AllocAccountDistribution."Destination Account Type"::"G/L Account",
            GetGLAccForAllocationDistribution(CreateGLAccount.Software(), FinanceModuleSetup."Yearly License All. GLAcc No."), CreateDimensionValue.AdministrationDepartment(), '');
        ContosoAllocationAccount.InsertAllocationAccountDistribution(
            Licenses(), 20000, AllocAccountDistribution."Account Type"::Fixed, 1, 50,
            AllocAccountDistribution."Destination Account Type"::"G/L Account",
            GetGLAccForAllocationDistribution(CreateGLAccount.Software(), FinanceModuleSetup."Yearly License All. GLAcc No."), CreateDimensionValue.SalesDepartment(), '');
    end;

    procedure Licenses(): Code[20]
    begin
        exit(LicensesTok);
    end;

    procedure LicensesDescription(): Text[100]
    begin
        exit(YearlyLicenseFeeTok);
    end;

    local procedure GetGLAccForAllocationDistribution(DefaultAccountNo: Code[20]; FinModuleAccountNo: Code[20]): Code[20]
    begin
        if FinModuleAccountNo <> '' then
            exit(FinModuleAccountNo)
        else
            exit(DefaultAccountNo);
    end;

    var
        LicensesTok: Label 'LICENSES', MaxLength = 20;
        YearlyLicenseFeeTok: Label 'Yearly license fee', MaxLength = 100;
}
