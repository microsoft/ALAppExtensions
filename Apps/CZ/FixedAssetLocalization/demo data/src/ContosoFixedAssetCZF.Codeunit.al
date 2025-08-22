// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------

namespace Microsoft.DemoTool.Helpers;

using Microsoft.FixedAssets.Depreciation;
using Microsoft.FixedAssets;

codeunit 31216 "Contoso Fixed Asset CZF"
{
    InherentEntitlements = X;
    InherentPermissions = X;
    Permissions =
        tabledata "Depreciation Book" = rim,
        tabledata "FA Extended Posting Group CZF" = rim;

    var
        OverwriteData: Boolean;

    procedure SetOverwriteData(Overwrite: Boolean)
    begin
        OverwriteData := Overwrite;
    end;

    procedure InsertFAExtendedPostingGroup(GroupCode: Code[20]; FAExtendedPostigType: Enum "FA Extended Posting Type CZF"; Code: Code[20]; BookValAccOnDispGain: Code[20]; BookValAccOnDispLoss: Code[20]; SalesAccOnDispGain: Code[20]; SalesAccOnDispLoss: Code[20]; MaintenanceExpenseAccount: Code[20])
    var
        FAExtendedPosingGroupCZF: Record "FA Extended Posting Group CZF";
        Exists: Boolean;
    begin
        if FAExtendedPosingGroupCZF.Get(GroupCode, FAExtendedPostigType, Code) then begin
            Exists := true;

            if not OverwriteData then
                exit;
        end;

        FAExtendedPosingGroupCZF.Validate("FA Posting Group Code", GroupCode);
        FAExtendedPosingGroupCZF.Validate("FA Posting Type", FAExtendedPostigType);
        FAExtendedPosingGroupCZF.Validate(Code, Code);
        FAExtendedPosingGroupCZF.Validate("Book Val. Acc. on Disp. (Gain)", BookValAccOnDispGain);
        FAExtendedPosingGroupCZF.Validate("Book Val. Acc. on Disp. (Loss)", BookValAccOnDispLoss);
        FAExtendedPosingGroupCZF.Validate("Sales Acc. on Disp. (Gain)", SalesAccOnDispGain);
        FAExtendedPosingGroupCZF.Validate("Sales Acc. on Disp. (Loss)", SalesAccOnDispLoss);
        FAExtendedPosingGroupCZF.Validate("Maintenance Expense Account", MaintenanceExpenseAccount);

        if Exists then
            FAExtendedPosingGroupCZF.Modify(true)
        else
            FAExtendedPosingGroupCZF.Insert(true);
    end;

    procedure InsertTaxDepreciationGroup(Code: Code[20]; StartingDate: Date; Description: Text[100]; DepreciationType: Option; NoofDepreciationYears: Integer; NoofDepreciationMonths: Decimal; MinMonthsAfterAppreciation: Decimal; StraightFirstYear: Decimal; StraightNextYears: Decimal; StraightAppreciation: Decimal; DecliningFirstYear: Decimal; DecliningNextYears: Decimal; DecliningAppreciation: Decimal; DecliningDeprIncreasePer: Decimal)
    var
        TaxDepreciationGroupCZF: Record "Tax Depreciation Group CZF";
        Exists: Boolean;
    begin
        if TaxDepreciationGroupCZF.Get(Code, StartingDate) then begin
            Exists := true;

            if not OverwriteData then
                exit;
        end;

        TaxDepreciationGroupCZF.Validate(Code, Code);
        TaxDepreciationGroupCZF.Validate("Starting Date", StartingDate);
        TaxDepreciationGroupCZF.Validate(Description, Description);
        TaxDepreciationGroupCZF.Validate("Depreciation Type", DepreciationType);

        if NoofDepreciationYears <> 0 then
            TaxDepreciationGroupCZF.Validate("No. of Depreciation Years", NoofDepreciationYears)
        else
            TaxDepreciationGroupCZF.Validate("No. of Depreciation Months", NoofDepreciationMonths);

        TaxDepreciationGroupCZF.Validate("Min. Months After Appreciation", MinMonthsAfterAppreciation);
        TaxDepreciationGroupCZF.Validate("Straight First Year", StraightFirstYear);
        TaxDepreciationGroupCZF.Validate("Straight Next Years", StraightNextYears);
        TaxDepreciationGroupCZF.Validate("Straight Appreciation", StraightAppreciation);
        TaxDepreciationGroupCZF.Validate("Declining First Year", DecliningFirstYear);
        TaxDepreciationGroupCZF.Validate("Declining Next Years", DecliningNextYears);
        TaxDepreciationGroupCZF.Validate("Declining Appreciation", DecliningAppreciation);
        TaxDepreciationGroupCZF.Validate("Declining Depr. Increase %", DecliningDeprIncreasePer);

        if Exists then
            TaxDepreciationGroupCZF.Modify(true)
        else
            TaxDepreciationGroupCZF.Insert(true);
    end;

    procedure UpdateDepreciationBook(BookCode: Code[10]; CheckAcqApprBefDep: Boolean; AllAcquisitInSameYear: Boolean; CheckDeprecOnDisposal: Boolean; DeprecFrom1stYearDay: Boolean; DeprecFrom1stMonthDay: Boolean; CorrespGLEntriesDisp: Boolean; CorrespFAEntriesDisp: Boolean)
    var
        DepreciationBook: Record "Depreciation Book";
    begin
        if not DepreciationBook.Get(BookCode) then
            exit;

        DepreciationBook.Validate("Check Acq. Appr. bef. Dep. CZF", CheckAcqApprBefDep);
        DepreciationBook.Validate("All Acquisit. in same Year CZF", AllAcquisitInSameYear);
        DepreciationBook.Validate("Check Deprec. on Disposal CZF", CheckDeprecOnDisposal);
        DepreciationBook.Validate("Deprec. from 1st Year Day CZF", DeprecFrom1stYearDay);
        DepreciationBook.Validate("Deprec. from 1st Month Day CZF", DeprecFrom1stMonthDay);
        DepreciationBook.Validate("Corresp. G/L Entries Disp. CZF", CorrespGLEntriesDisp);
        DepreciationBook.Validate("Corresp. FA Entries Disp. CZF", CorrespFAEntriesDisp);
        DepreciationBook.Modify(true);
    end;
}
