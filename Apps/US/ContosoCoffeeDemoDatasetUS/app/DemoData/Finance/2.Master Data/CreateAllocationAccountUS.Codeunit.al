// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------

namespace Microsoft.DemoData.Finance;

using Microsoft.DemoTool.Helpers;
using Microsoft.Finance.AllocationAccount;

codeunit 11458 "Create Allocation Account US"
{
    InherentEntitlements = X;
    InherentPermissions = X;

    trigger OnRun()
    var
        AllocationAccount: Record "Allocation Account";
        AllocAccountDistribution: Record "Alloc. Account Distribution";
        ContosoAllocationAccount: Codeunit "Contoso Allocation Account";
        CreateDimensionValue: Codeunit "Create Dimension Value";
        CreateUSGLAccounts: Codeunit "Create US GL Accounts";
    begin
        ContosoAllocationAccount.InsertAllocationAccount(
            Licenses(), YearlyLicenseFeeTok,
            AllocationAccount."Account Type"::Fixed, AllocationAccount."Document Lines Split"::"Split Amount");
        ContosoAllocationAccount.InsertAllocationAccountDistribution(
            Licenses(), 10000, AllocAccountDistribution."Account Type"::Fixed, 1, 50,
            AllocAccountDistribution."Destination Account Type"::"G/L Account", CreateUSGLAccounts.LicenseFeesRoyalties(), CreateDimensionValue.AdministrationDepartment(), '');
        ContosoAllocationAccount.InsertAllocationAccountDistribution(
            Licenses(), 20000, AllocAccountDistribution."Account Type"::Fixed, 1, 50,
            AllocAccountDistribution."Destination Account Type"::"G/L Account", CreateUSGLAccounts.LicenseFeesRoyalties(), CreateDimensionValue.SalesDepartment(), '');
    end;

    procedure Licenses(): Code[20]
    begin
        exit(LicensesTok);
    end;

    var
        LicensesTok: Label 'LICENSES', MaxLength = 20;
        YearlyLicenseFeeTok: Label 'Yearly license fee', MaxLength = 100;
}