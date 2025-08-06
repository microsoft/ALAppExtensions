// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------

namespace Microsoft.DemoData.Finance;

using Microsoft.DemoTool.Helpers;
using Microsoft.Finance.AllocationAccount;

codeunit 10590 "Create Allocation Account GB"
{
    Access = Internal;
    InherentEntitlements = X;
    InherentPermissions = X;

    trigger OnRun()
    var
        AllocationAccount: Record "Allocation Account";
        AllocAccountDistribution: Record "Alloc. Account Distribution";
        ContosoAllocationAccount: Codeunit "Contoso Allocation Account";
        CreateDimensionValue: Codeunit "Create Dimension Value";
        CreateGBGLAccounts: Codeunit "Create GB GL Accounts";
    begin
        ContosoAllocationAccount.InsertAllocationAccount(
            Licenses(), 'Yearly license fee, design software',
            AllocationAccount."Account Type"::Fixed, AllocationAccount."Document Lines Split"::"Split Amount");
        ContosoAllocationAccount.InsertAllocationAccountDistribution(
            Licenses(), 10000, AllocAccountDistribution."Account Type"::Fixed, 1, 50,
            AllocAccountDistribution."Destination Account Type"::"G/L Account", CreateGBGLAccounts.LicenseFeesRoyalties(), CreateDimensionValue.AdministrationDepartment(), '');
        ContosoAllocationAccount.InsertAllocationAccountDistribution(
            Licenses(), 20000, AllocAccountDistribution."Account Type"::Fixed, 1, 50,
            AllocAccountDistribution."Destination Account Type"::"G/L Account", CreateGBGLAccounts.LicenseFeesRoyalties(), CreateDimensionValue.SalesDepartment(), '');
    end;

    procedure Licenses(): Code[20]
    begin
        exit('LICENSES');
    end;
}