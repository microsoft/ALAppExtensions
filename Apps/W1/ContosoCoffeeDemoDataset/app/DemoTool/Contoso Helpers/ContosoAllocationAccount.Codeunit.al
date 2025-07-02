// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------
namespace Microsoft.DemoTool.Helpers;

using Microsoft.Finance.AllocationAccount;
using Microsoft.DemoTool;

codeunit 5183 "Contoso Allocation Account"
{
    InherentEntitlements = X;
    InherentPermissions = X;
    Permissions =
        tabledata "Allocation Account" = rim;

    var
        OverwriteData: Boolean;

    procedure SetOverwriteData(Overwrite: Boolean)
    begin
        OverwriteData := Overwrite;
    end;

    procedure InsertAllocationAccount(AllocationAccountNo: Code[20]; Name: Text[100]; AccountType: Option; DocumentLineSplit: Option)
    var
        ContosoCoffeeDemoDataSetup: Record "Contoso Coffee Demo Data Setup";
        AllocationAccount: Record "Allocation Account";
        Exists: Boolean;
    begin
        ContosoCoffeeDemoDataSetup.Get();

        if AllocationAccount.Get(AllocationAccountNo) then begin
            Exists := true;

            if not OverwriteData then
                exit;
        end;
        AllocationAccount.Validate("No.", AllocationAccountNo);
        AllocationAccount.Validate(Name, Name);
        AllocationAccount.Validate("Account Type", AccountType);
        AllocationAccount.Validate("Document Lines Split", DocumentLineSplit);
        if Exists then
            AllocationAccount.Modify(true)
        else
            AllocationAccount.Insert(true);
    end;

    procedure InsertAllocationAccountDistribution(AllocationAccountNo: Code[20]; LineNo: Integer; AccountType: Option; Share: Decimal; Percent: Decimal; DesinationAccountType: Enum "Destination Account Type"; DestinationAccountNo: Code[20]; GlobalDimension1Code: Code[20]; GlobalDimension2Code: Code[20])
    var
        ContosoCoffeeDemoDataSetup: Record "Contoso Coffee Demo Data Setup";
        AllocAccountDistribution: Record "Alloc. Account Distribution";
        Exists: Boolean;
    begin
        ContosoCoffeeDemoDataSetup.Get();

        if AllocAccountDistribution.Get(AllocationAccountNo, LineNo) then begin
            Exists := true;

            if not OverwriteData then
                exit;
        end;

        AllocAccountDistribution.Validate("Allocation Account No.", AllocationAccountNo);
        AllocAccountDistribution.Validate("Line No.", LineNo);
        AllocAccountDistribution.Validate("Account Type", AccountType);
        AllocAccountDistribution.Validate(Share, Share);
        AllocAccountDistribution.Validate(Percent, Percent);
        AllocAccountDistribution.Validate("Destination Account Type", DesinationAccountType);
        AllocAccountDistribution.Validate("Destination Account Number", DestinationAccountNo);
        AllocAccountDistribution.Validate("Global Dimension 1 Code", GlobalDimension1Code);
        AllocAccountDistribution.Validate("Global Dimension 2 Code", GlobalDimension2Code);
        if Exists then
            AllocAccountDistribution.Modify(true)
        else
            AllocAccountDistribution.Insert(true);
    end;
}