// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------
namespace Microsoft.FixedAssets;

using Microsoft.Finance.Dimension;
using Microsoft.Finance.GeneralLedger.Account;
using Microsoft.Finance.GeneralLedger.Journal;
using Microsoft.FixedAssets.Depreciation;
using Microsoft.FixedAssets.FixedAsset;
using Microsoft.FixedAssets.Journal;
using Microsoft.FixedAssets.Ledger;
using Microsoft.FixedAssets.Maintenance;
using Microsoft.FixedAssets.Posting;
using Microsoft.Foundation.AuditCodes;
using System.Utilities;

#pragma warning disable AL0603
codeunit 31235 "FA Disposal Handler CZF"
{
    var
        FixedAsset: Record "Fixed Asset";
        FADepreciationBook: Record "FA Depreciation Book";
        DepreciationCalculation: Codeunit "Depreciation Calculation";
        DimensionManagement: Codeunit DimensionManagement;
        FADimensionManagement: Codeunit FADimensionManagement;
        DeprBookCode: Code[10];
        ResultOnDisposal: Integer;
        FAPostingType: Option " ",AcqCost,BookVal,Apprec,WrDown;

    procedure GetAccNo(var FALedgerEntry: Record "FA Ledger Entry"): Code[20]
    var
        FAPostingGroup: Record "FA Posting Group";
        GLAccNo: Code[20];
    begin
        FAPostingGroup.GetPostingGroup(FALedgerEntry."FA Posting Group", FALedgerEntry."Depreciation Book Code");
        GLAccNo := '';
        if FALedgerEntry."FA Posting Category" = FALedgerEntry."FA Posting Category"::" " then
            case FALedgerEntry."FA Posting Type" of
                FALedgerEntry."FA Posting Type"::"Acquisition Cost":
                    GLAccNo := FAPostingGroup.GetAcquisitionCostAccount();
                FALedgerEntry."FA Posting Type"::Depreciation:
                    GLAccNo := FAPostingGroup.GetAccumDepreciationAccount();
                FALedgerEntry."FA Posting Type"::"Write-Down":
                    GLAccNo := FAPostingGroup.GetWriteDownAccount();
                FALedgerEntry."FA Posting Type"::Appreciation:
                    GLAccNo := FAPostingGroup.GetAppreciationAccount();
                FALedgerEntry."FA Posting Type"::"Custom 1":
                    GLAccNo := FAPostingGroup.GetCustom1Account();
                FALedgerEntry."FA Posting Type"::"Custom 2":
                    GLAccNo := FAPostingGroup.GetCustom2Account();
                FALedgerEntry."FA Posting Type"::"Proceeds on Disposal":
                    GLAccNo := FAPostingGroup.GetSalesAccountOnDisposalGainCZF(FALedgerEntry."Reason Code");
                FALedgerEntry."FA Posting Type"::"Gain/Loss":
                    begin
                        if FALedgerEntry."Result on Disposal" = FALedgerEntry."Result on Disposal"::Gain then
                            GLAccNo := FAPostingGroup.GetGainsAccountOnDisposal();
                        if FALedgerEntry."Result on Disposal" = FALedgerEntry."Result on Disposal"::Loss then
                            GLAccNo := FAPostingGroup.GetLossesAccountOnDisposal();
                    end;
            end;

        if FALedgerEntry."FA Posting Category" = FALedgerEntry."FA Posting Category"::Disposal then
            case FALedgerEntry."FA Posting Type" of
                FALedgerEntry."FA Posting Type"::"Acquisition Cost":
                    GLAccNo := FAPostingGroup.GetAcquisitionCostAccountOnDisposal();
                FALedgerEntry."FA Posting Type"::Depreciation:
                    begin
                        if FAPostingGroup.UseStandardDisposalCZF(FALedgerEntry."Reason Code") then
                            FAPostingGroup.TestField("Accum. Depr. Acc. on Disposal");
                        GLAccNo := FAPostingGroup."Accum. Depr. Acc. on Disposal";
                    end;
                FALedgerEntry."FA Posting Type"::"Write-Down":
                    GLAccNo := FAPostingGroup.GetWriteDownAccountOnDisposal();
                FALedgerEntry."FA Posting Type"::Appreciation:
                    GLAccNo := FAPostingGroup.GetAppreciationAccountOnDisposal();
                FALedgerEntry."FA Posting Type"::"Custom 1":
                    GLAccNo := FAPostingGroup.GetCustom1AccountOnDisposal();
                FALedgerEntry."FA Posting Type"::"Custom 2":
                    GLAccNo := FAPostingGroup.GetCustom2AccountOnDisposal();
                FALedgerEntry."FA Posting Type"::"Book Value on Disposal":
                    begin
                        if FALedgerEntry."Result on Disposal" = FALedgerEntry."Result on Disposal"::Gain then
                            GLAccNo := FAPostingGroup.GetBookValueAccountOnDisposalGainCZF(FALedgerEntry."Reason Code");
                        if FALedgerEntry."Result on Disposal" = FALedgerEntry."Result on Disposal"::Loss then
                            GLAccNo := FAPostingGroup.GetBookValueAccountOnDisposalLossCZF(FALedgerEntry."Reason Code");
                        FALedgerEntry."Result on Disposal" := FALedgerEntry."Result on Disposal"::" ";
                    end;
            end;

        if FALedgerEntry."FA Posting Category" = FALedgerEntry."FA Posting Category"::"Bal. Disposal" then
            case FALedgerEntry."FA Posting Type" of
                FALedgerEntry."FA Posting Type"::"Acquisition Cost":
                    exit(FAPostingGroup.GetAcquisitionCostBalanceAccountOnDisposalCZF());
                FALedgerEntry."FA Posting Type"::"Write-Down":
                    exit(FAPostingGroup.GetWriteDownBalAccountOnDisposal());
                FALedgerEntry."FA Posting Type"::Appreciation:
                    exit(FAPostingGroup.GetAppreciationBalAccountOnDisposal());
                FALedgerEntry."FA Posting Type"::"Custom 1":
                    exit(FAPostingGroup.GetCustom1BalAccountOnDisposal());
                FALedgerEntry."FA Posting Type"::"Custom 2":
                    exit(FAPostingGroup.GetCustom2BalAccountOnDisposal());
                FALedgerEntry."FA Posting Type"::"Book Value on Disposal":
                    exit(FAPostingGroup.GetBookValueBalAccountOnDisposalCZF());
            end;

        OnAfterGetAccNo(FALedgerEntry, GLAccNo);
        exit(GLAccNo);
    end;

    procedure GetMaintenanceAccNo(var MaintenanceLedgerEntry: Record "Maintenance Ledger Entry"): Code[20]
    var
        FAPostingGroup: Record "FA Posting Group";
    begin
        FAPostingGroup.GetPostingGroup(MaintenanceLedgerEntry."FA Posting Group", MaintenanceLedgerEntry."Depreciation Book Code");
        exit(FAPostingGroup.GetMaintenanceExpenseAccountCZF(MaintenanceLedgerEntry."Maintenance Code"));
    end;

    local procedure GetGLAccNoFromFAPostingGroup(FAPostingGroup: Record "FA Posting Group"; FAPostingType2: Enum "FA Posting Group Account Type"; ReasonMaintenanceCode: Code[10]) GLAccNo: Code[20]
    var
        FAExtendedPostingGroupCZF: Record "FA Extended Posting Group CZF";
        FieldErrorText: Text[50];
        NotMoreThan100Err: Label 'must not be more than 100';
    begin
        FieldErrorText := NotMoreThan100Err;
        case FAPostingType2 of
            FAPostingType2::"Acquisition Cost":
                begin
                    GLAccNo := FAPostingGroup.GetAcquisitionCostBalanceAccount();
                    FAPostingGroup.CalcFields(FAPostingGroup."Allocated Acquisition Cost %");
                    if FAPostingGroup."Allocated Acquisition Cost %" > 100 then
                        FAPostingGroup.FieldError(FAPostingGroup."Allocated Acquisition Cost %", FieldErrorText);
                end;
            FAPostingType2::Depreciation:
                begin
                    GLAccNo := FAPostingGroup.GetDepreciationExpenseAccount();
                    FAPostingGroup.CalcFields(FAPostingGroup."Allocated Depreciation %");
                    if FAPostingGroup."Allocated Depreciation %" > 100 then
                        FAPostingGroup.FieldError(FAPostingGroup."Allocated Depreciation %", FieldErrorText);
                end;
            FAPostingType2::"Write-Down":
                begin
                    GLAccNo := FAPostingGroup.GetWriteDownExpenseAccount();
                    FAPostingGroup.CalcFields(FAPostingGroup."Allocated Write-Down %");
                    if FAPostingGroup."Allocated Write-Down %" > 100 then
                        FAPostingGroup.FieldError(FAPostingGroup."Allocated Write-Down %", FieldErrorText);
                end;
            FAPostingType2::Appreciation:
                begin
                    GLAccNo := FAPostingGroup.GetAppreciationBalanceAccount();
                    FAPostingGroup.CalcFields(FAPostingGroup."Allocated Appreciation %");
                    if FAPostingGroup."Allocated Appreciation %" > 100 then
                        FAPostingGroup.FieldError(FAPostingGroup."Allocated Appreciation %", FieldErrorText);
                end;
            FAPostingType2::"Custom 1":
                begin
                    GLAccNo := FAPostingGroup.GetCustom1ExpenseAccount();
                    FAPostingGroup.CalcFields(FAPostingGroup."Allocated Custom 1 %");
                    if FAPostingGroup."Allocated Custom 1 %" > 100 then
                        FAPostingGroup.FieldError(FAPostingGroup."Allocated Custom 1 %", FieldErrorText);
                end;
            FAPostingType2::"Custom 2":
                begin
                    GLAccNo := FAPostingGroup.GetCustom2ExpenseAccount();
                    FAPostingGroup.CalcFields(FAPostingGroup."Allocated Custom 2 %");
                    if FAPostingGroup."Allocated Custom 2 %" > 100 then
                        FAPostingGroup.FieldError(FAPostingGroup."Allocated Custom 2 %", FieldErrorText);
                end;
            FAPostingType2::"Proceeds on Disposal":
                begin
                    GLAccNo := FAPostingGroup.GetSalesBalanceAccount();
                    FAPostingGroup.CalcFields(FAPostingGroup."Allocated Sales Price %");
                    if FAPostingGroup."Allocated Sales Price %" > 100 then
                        FAPostingGroup.FieldError(FAPostingGroup."Allocated Sales Price %", FieldErrorText);
                end;
            FAPostingType2::Maintenance:
                if not FAPostingGroup.UseStandardMaintenanceCZF(ReasonMaintenanceCode) then begin
                    FAExtendedPostingGroupCZF.Get(FAPostingGroup.Code, FAExtendedPostingGroupCZF."FA Posting Type"::Maintenance, ReasonMaintenanceCode);
                    GLAccNo := FAExtendedPostingGroupCZF.GetExtendedMaintenanceBalanceAccount();
                    FAExtendedPostingGroupCZF.CalcFields("Allocated Maintenance %");
                    if FAExtendedPostingGroupCZF."Allocated Maintenance %" > 100 then
                        FAPostingGroup.FieldError(FAPostingGroup."Allocated Maintenance %", FieldErrorText);
                end else begin
                    GLAccNo := FAPostingGroup.GetMaintenanceBalanceAccount();
                    FAPostingGroup.CalcFields(FAPostingGroup."Allocated Maintenance %");
                    if FAPostingGroup."Allocated Maintenance %" > 100 then
                        FAPostingGroup.FieldError(FAPostingGroup."Allocated Maintenance %", FieldErrorText);
                end;
            FAPostingType2::Gain:
                begin
                    GLAccNo := FAPostingGroup.GetGainsAccountOnDisposal();
                    FAPostingGroup.CalcFields(FAPostingGroup."Allocated Gain %");
                    if FAPostingGroup."Allocated Gain %" > 100 then
                        FAPostingGroup.FieldError(FAPostingGroup."Allocated Gain %", FieldErrorText);
                end;
            FAPostingType2::Loss:
                begin
                    GLAccNo := FAPostingGroup.GetLossesAccountOnDisposal();
                    FAPostingGroup.CalcFields(FAPostingGroup."Allocated Loss %");
                    if FAPostingGroup."Allocated Loss %" > 100 then
                        FAPostingGroup.FieldError(FAPostingGroup."Allocated Loss %", FieldErrorText);
                end;
            FAPostingType2::"Book Value Gain":
                if not FAPostingGroup.UseStandardDisposalCZF(ReasonMaintenanceCode) then begin
                    FAExtendedPostingGroupCZF.Get(FAPostingGroup.Code, FAExtendedPostingGroupCZF."FA Posting Type"::Disposal, ReasonMaintenanceCode);
                    GLAccNo := FAExtendedPostingGroupCZF.GetBookValueAccountOnDisposalGain();
                    FAExtendedPostingGroupCZF.CalcFields("Allocated Book Value % (Gain)");
                    if FAExtendedPostingGroupCZF."Allocated Book Value % (Gain)" > 100 then
                        FAExtendedPostingGroupCZF.FieldError("Allocated Book Value % (Gain)", FieldErrorText);
                end else begin
                    GLAccNo := FAPostingGroup.GetBookValueAccountOnDisposalGain();
                    FAPostingGroup.CalcFields(FAPostingGroup."Allocated Book Value % (Gain)");
                    if FAPostingGroup."Allocated Book Value % (Gain)" > 100 then
                        FAPostingGroup.FieldError(FAPostingGroup."Allocated Book Value % (Gain)", FieldErrorText);
                end;
            FAPostingType2::"Book Value Loss":
                if not FAPostingGroup.UseStandardDisposalCZF(ReasonMaintenanceCode) then begin
                    FAExtendedPostingGroupCZF.Get(FAPostingGroup.Code, FAExtendedPostingGroupCZF."FA Posting Type"::Disposal, ReasonMaintenanceCode);
                    GLAccNo := FAExtendedPostingGroupCZF.GetBookValueAccountOnDisposalLoss();
                    FAExtendedPostingGroupCZF.CalcFields("Allocated Book Value % (Loss)");
                    if FAExtendedPostingGroupCZF."Allocated Book Value % (Loss)" > 100 then
                        FAExtendedPostingGroupCZF.FieldError("Allocated Book Value % (Loss)", FieldErrorText);
                end else begin
                    GLAccNo := FAPostingGroup.GetBookValueAccountOnDisposalLoss();
                    FAPostingGroup.CalcFields(FAPostingGroup."Allocated Book Value % (Loss)");
                    if FAPostingGroup."Allocated Book Value % (Loss)" > 100 then
                        FAPostingGroup.FieldError(FAPostingGroup."Allocated Book Value % (Loss)", FieldErrorText);
                end;
        end;
        exit(GLAccNo);
    end;

    [IntegrationEvent(false, false)]
    local procedure OnAfterGetAccNo(var FALedgerEntry: Record "FA Ledger Entry"; var GLAccNo: Code[20])
    begin
    end;

    [EventSubscriber(ObjectType::Codeunit, Codeunit::"FA Jnl.-Post Line", 'OnBeforePostDisposalEntry', '', false, false)]
    local procedure PostDisposalEntryOnBeforePostDisposalEntry(var FALedgEntry: Record "FA Ledger Entry"; DeprBook: Record "Depreciation Book"; FANo: Code[20]; ErrorEntryNo: Integer; var FAInsertLedgEntry: Codeunit "FA Insert Ledger Entry"; var IsHandled: Boolean)
    var
        FAPostingGroup: Record "FA Posting Group";
        CalculateDisposal: Codeunit "Calculate Disposal";
        MaxDisposalNo, SalesEntryNo : Integer;
        DisposalType: Option FirstDisposal,SecondDisposal,ErrorDisposal,LastErrorDisposal;
        OldDisposalMethod: Option " ",Net,Gross;
        EntryAmounts: array[14] of Decimal;
        EntryNumbers: array[14] of Integer;
        i, j : Integer;
        DisposalMethodErr: Label '%2 must not be %3 in %4 %5 = %6 for %1.', Comment = '%1 = FA Name, %2 = Disposal Calculation Method FieldCaption, %3 = Disposal Calculation Method, %4 = Depreciation Book TableCaption, %5 = Depreciation Book Code FieldCaption, %6 = %5 = Depreciation Book Code';
        FirstDisposalErr: Label '%2 = %3 must be canceled first for %1.', Comment = '%1 = FA Name, %2 = Disposal Entry No. FieldCaption, %3 = Disposal Entry No.';
    begin
        DeprBookCode := DeprBook.Code;
        FADepreciationBook.Get(FANo, DeprBookCode);
        FixedAsset.Get(FANo);
        if DeprBook."G/L Integration - Disposal" then
            FAPostingGroup.Get(FADepreciationBook."FA Posting Group");

        FALedgEntry."Disposal Calculation Method" := DeprBook."Disposal Calculation Method" + 1;
        CalculateDisposal.GetDisposalType(
          FANo, DeprBookCode, ErrorEntryNo, DisposalType,
          OldDisposalMethod, MaxDisposalNo, SalesEntryNo);
        if (MaxDisposalNo > 0) and (FALedgEntry."Disposal Calculation Method" <> OldDisposalMethod) then
            Error(
              DisposalMethodErr,
              FAName(), DeprBook.FieldCaption("Disposal Calculation Method"), FALedgEntry."Disposal Calculation Method",
              DeprBook.TableCaption, DeprBook.FieldCaption(Code), DeprBook.Code);
        if ErrorEntryNo = 0 then
            FALedgEntry."Disposal Entry No." := MaxDisposalNo + 1
        else
            if SalesEntryNo <> ErrorEntryNo then
                Error(FirstDisposalErr,
                  FAName(), FALedgEntry.FieldCaption(FALedgEntry."Disposal Entry No."), MaxDisposalNo);
        if DisposalType = DisposalType::FirstDisposal then
            PostReverseType(FALedgEntry, FAInsertLedgEntry, CalculateDisposal);
        if DeprBook."Disposal Calculation Method" = DeprBook."Disposal Calculation Method"::Gross then
            FAInsertLedgEntry.SetOrgGenJnlLine(true);
        FAInsertLedgEntry.InsertFA(FALedgEntry);
        FAInsertLedgEntry.SetOrgGenJnlLine(false);
        FALedgEntry."Automatic Entry" := true;
        FAInsertLedgEntry.SetNetdisposal(false);
        if (DeprBook."Disposal Calculation Method" =
            DeprBook."Disposal Calculation Method"::Net) and
           DeprBook."VAT on Net Disposal Entries"
        then
            FAInsertLedgEntry.SetNetdisposal(true);

        if DisposalType = DisposalType::FirstDisposal then begin
            CalculateDisposal.CalcGainLoss(FANo, DeprBookCode, EntryAmounts);
            for i := 1 to 14 do
                if EntryAmounts[i] <> 0 then begin
                    FALedgEntry."FA Posting Category" := CalculateDisposal.SetFAPostingCategory(i);
                    FALedgEntry."FA Posting Type" := "FA Ledger Entry FA Posting Type".FromInteger(CalculateDisposal.SetFAPostingType(i));
                    FALedgEntry.Amount := EntryAmounts[i];
                    if i = 1 then
                        FALedgEntry."Result on Disposal" := FALedgEntry."Result on Disposal"::Gain;
                    if i = 2 then
                        FALedgEntry."Result on Disposal" := FALedgEntry."Result on Disposal"::Loss;
                    if i > 2 then
                        FALedgEntry."Result on Disposal" := FALedgEntry."Result on Disposal"::" ";
                    if i = 10 then
                        SetResultOnDisposal(FALedgEntry);

                    if (DeprBook."Disposal Calculation Method" <> DeprBook."Disposal Calculation Method"::Net) and
                       not FAPostingGroup.UseStandardDisposalCZF(FALedgEntry."Reason Code")
                    then begin
                        if not DeprBook."Corresp. G/L Entries Disp. CZF" then
                            FAInsertLedgEntry.InsertFA(FALedgEntry)
                        else
                            if not DeprBook."Corresp. FA Entries Disp. CZF" then
                                FAInsertLedgEntry.InsertFA(FALedgEntry)
                            else
                                if FALedgEntry."FA Posting Type" <> FALedgEntry."FA Posting Type"::Depreciation then begin
                                    FAPostingType := FAPostingType::" ";
                                    FAInsertLedgEntry.InsertFA(FALedgEntry);
                                    if i in [3, 5, 6, 10] then begin
                                        case i of
                                            3:
                                                FAPostingType := FAPostingType::AcqCost;
                                            5:
                                                FAPostingType := FAPostingType::WrDown;
                                            6:
                                                FAPostingType := FAPostingType::Apprec;
                                            10:
                                                FAPostingType := FAPostingType::BookVal;
                                        end;
                                        FALedgEntry."FA Posting Category" := CalculateDisposal.SetFAPostingCategory(4);
                                        FALedgEntry."FA Posting Type" := CalculateDisposal.SetFAPostingType(4);
                                        FALedgEntry.Amount := -EntryAmounts[i];
                                        FAInsertLedgEntry.InsertFA(FALedgEntry);
                                        if i in [3, 5, 6, 10] then begin
                                            FALedgEntry."FA Posting Category" := CalculateDisposal.SetFAPostingCategory(i);
                                            FALedgEntry."FA Posting Type" := CalculateDisposal.SetFAPostingType(i);
                                            FALedgEntry.Amount := EntryAmounts[i];
                                        end;
                                    end;
                                    FAPostingType := FAPostingType::" ";
                                end;
                    end else
                        FAInsertLedgEntry.InsertFA(FALedgEntry);
                    PostAllocation(FALedgEntry, FAInsertLedgEntry);
                end;
        end;
        if DisposalType = DisposalType::SecondDisposal then begin
            CalculateDisposal.CalcSecondGainLoss(FANo, DeprBookCode, FALedgEntry.Amount, EntryAmounts);
            for i := 1 to 2 do
                if EntryAmounts[i] <> 0 then begin
                    FALedgEntry."FA Posting Category" := CalculateDisposal.SetFAPostingCategory(i);
                    FALedgEntry."FA Posting Type" := "FA Ledger Entry FA Posting Type".FromInteger(CalculateDisposal.SetFAPostingType(i));
                    FALedgEntry.Amount := EntryAmounts[i];
                    if i = 1 then
                        FALedgEntry."Result on Disposal" := FALedgEntry."Result on Disposal"::Gain;
                    if i = 2 then
                        FALedgEntry."Result on Disposal" := FALedgEntry."Result on Disposal"::Loss;
                    FAInsertLedgEntry.InsertFA(FALedgEntry);
                    PostAllocation(FALedgEntry, FAInsertLedgEntry);
                end;
        end;
        if DisposalType in
           [DisposalType::ErrorDisposal, DisposalType::LastErrorDisposal]
        then begin
            CalculateDisposal.GetErrorDisposal(
              FANo, DeprBookCode, DisposalType = DisposalType::ErrorDisposal, MaxDisposalNo,
              EntryAmounts, EntryNumbers);
            if DisposalType = DisposalType::ErrorDisposal then
                j := 2
            else begin
                j := 14;
                ResultOnDisposal := CalcResultOnDisposal(FANo, DeprBookCode);
            end;
            for i := 1 to j do
                if EntryNumbers[i] <> 0 then begin
                    FALedgEntry.Amount := EntryAmounts[i];
                    FALedgEntry."Entry No." := EntryNumbers[i];
                    FALedgEntry."FA Posting Category" := CalculateDisposal.SetFAPostingCategory(i);
                    FALedgEntry."FA Posting Type" := "FA Ledger Entry FA Posting Type".FromInteger(CalculateDisposal.SetFAPostingType(i));
                    if i = 1 then
                        FALedgEntry."Result on Disposal" := FALedgEntry."Result on Disposal"::Gain;
                    if i = 2 then
                        FALedgEntry."Result on Disposal" := FALedgEntry."Result on Disposal"::Loss;
                    if i > 2 then
                        FALedgEntry."Result on Disposal" := FALedgEntry."Result on Disposal"::" ";
                    if i = 10 then
                        FALedgEntry."Result on Disposal" := ResultOnDisposal;

                    if (DeprBook."Disposal Calculation Method" <> DeprBook."Disposal Calculation Method"::Net) and
                       not FAPostingGroup.UseStandardDisposalCZF(FALedgEntry."Reason Code")
                    then begin
                        if not DeprBook."Corresp. G/L Entries Disp. CZF" then
                            FAInsertLedgEntry.InsertFA(FALedgEntry)
                        else
                            if not DeprBook."Corresp. FA Entries Disp. CZF" then
                                FAInsertLedgEntry.InsertFA(FALedgEntry)
                            else
                                if FALedgEntry."FA Posting Type" <> FALedgEntry."FA Posting Type"::Depreciation then begin
                                    FAPostingType := FAPostingType::" ";
                                    FAInsertLedgEntry.InsertFA(FALedgEntry);
                                    if i in [3, 5, 6, 10] then begin
                                        case i of
                                            3:
                                                FAPostingType := FAPostingType::AcqCost;
                                            5:
                                                FAPostingType := FAPostingType::WrDown;
                                            6:
                                                FAPostingType := FAPostingType::Apprec;
                                            10:
                                                FAPostingType := FAPostingType::BookVal;
                                        end;
                                        FALedgEntry."FA Posting Category" := CalculateDisposal.SetFAPostingCategory(4);
                                        FALedgEntry."FA Posting Type" := CalculateDisposal.SetFAPostingType(4);
                                        FALedgEntry.Amount := -EntryAmounts[i];
                                        FALedgEntry."Entry No." := EntryNumbers[i] + 1;
                                        FAInsertLedgEntry.InsertFA(FALedgEntry);
                                        if i in [3, 5, 6, 10] then begin
                                            FALedgEntry."FA Posting Category" := CalculateDisposal.SetFAPostingCategory(i);
                                            FALedgEntry."FA Posting Type" := CalculateDisposal.SetFAPostingType(i);
                                            FALedgEntry.Amount := EntryAmounts[i];
                                        end;
                                    end;
                                    FAPostingType := FAPostingType::" ";
                                end;
                    end else
                        FAInsertLedgEntry.InsertFA(FALedgEntry);
                    PostAllocation(FALedgEntry, FAInsertLedgEntry);
                end;
        end;

        IsHandled := true;
    end;

    local procedure FAName(): Text[200]
    begin
        exit(DepreciationCalculation.FAName(FixedAsset, DeprBookCode));
    end;

    local procedure PostReverseType(FALedgerEntry: Record "FA Ledger Entry"; var FAInsertLedgerEntry: Codeunit "FA Insert Ledger Entry"; var CalculateDisposal: Codeunit "Calculate Disposal")
    var
        EntryAmounts: array[4] of Decimal;
        i: Integer;
    begin
        CalculateDisposal.CalcReverseAmounts(FALedgerEntry."FA No.", DeprBookCode, EntryAmounts);
        FALedgerEntry."FA Posting Category" := FALedgerEntry."FA Posting Category"::" ";
        FALedgerEntry."Automatic Entry" := true;
        for i := 1 to 4 do
            if EntryAmounts[i] <> 0 then begin
                FALedgerEntry.Amount := EntryAmounts[i];
                FALedgerEntry."FA Posting Type" := "FA Ledger Entry FA Posting Type".FromInteger(CalculateDisposal.SetReverseType(i));
                FAInsertLedgerEntry.InsertFA(FALedgerEntry);
                if FALedgerEntry."G/L Entry No." > 0 then
                    FAInsertLedgerEntry.InsertBalAcc(FALedgerEntry);
            end;
    end;

    local procedure PostAllocation(var FALedgerEntry: Record "FA Ledger Entry"; var FAInsertLedgerEntry: Codeunit "FA Insert Ledger Entry")
    var
        FAPostingGroup: Record "FA Posting Group";
        DepreciationBook: Record "Depreciation Book";
    begin
        if FALedgerEntry."G/L Entry No." = 0 then
            exit;

        case FALedgerEntry."FA Posting Type" of
            FALedgerEntry."FA Posting Type"::"Gain/Loss":
                begin
                    DepreciationBook.Get(DeprBookCode);
                    if DepreciationBook."Disposal Calculation Method" = DepreciationBook."Disposal Calculation Method"::Net then begin
                        FAPostingGroup.GetPostingGroup(FALedgerEntry."FA Posting Group", DepreciationBook.Code);
                        FAPostingGroup.CalcFields("Allocated Gain %", "Allocated Loss %");
                        if FALedgerEntry."Result on Disposal" = FALedgerEntry."Result on Disposal"::Gain then
                            PostGLBalAcc(FALedgerEntry, FAPostingGroup."Allocated Gain %", FAInsertLedgerEntry)
                        else
                            PostGLBalAcc(FALedgerEntry, FAPostingGroup."Allocated Loss %", FAInsertLedgerEntry);
                    end;
                end;
            FALedgerEntry."FA Posting Type"::"Book Value on Disposal":
                begin
                    FAPostingGroup.Get(FALedgerEntry."FA Posting Group");
                    if FALedgerEntry."Result on Disposal" = FALedgerEntry."Result on Disposal"::Gain then
                        PostGLBalAcc(FALedgerEntry, FAPostingGroup.CalcAllocatedBookValueGainCZF(FALedgerEntry."Reason Code"), FAInsertLedgerEntry)
                    else
                        PostGLBalAcc(FALedgerEntry, FAPostingGroup.CalcAllocatedBookValueLossCZF(FALedgerEntry."Reason Code"), FAInsertLedgerEntry);
                end;
        end;
    end;

    local procedure PostGLBalAcc(FALedgerEntry: Record "FA Ledger Entry"; AllocatedPct: Decimal; var FAInsertLedgerEntry: Codeunit "FA Insert Ledger Entry")
    begin
        if AllocatedPct > 0 then begin
            FALedgerEntry."Entry No." := 0;
            FALedgerEntry."Automatic Entry" := true;
            FALedgerEntry.Amount := -FALedgerEntry.Amount;
            FALedgerEntry.Correction := not FALedgerEntry.Correction;
            FAInsertLedgerEntry.InsertBalDisposalAcc(FALedgerEntry);
            FALedgerEntry.Correction := not FALedgerEntry.Correction;
            FAInsertLedgerEntry.InsertBalAcc(FALedgerEntry);
        end;
    end;

    local procedure SetResultOnDisposal(var FALedgerEntry: Record "FA Ledger Entry")
    begin
        FADepreciationBook."FA No." := FALedgerEntry."FA No.";
        FADepreciationBook."Depreciation Book Code" := FALedgerEntry."Depreciation Book Code";
        FADepreciationBook.CalcFields("Gain/Loss");
        if FADepreciationBook."Gain/Loss" <= 0 then
            FALedgerEntry."Result on Disposal" := FALedgerEntry."Result on Disposal"::Gain
        else
            FALedgerEntry."Result on Disposal" := FALedgerEntry."Result on Disposal"::Loss;
    end;

    local procedure CalcResultOnDisposal(FANo: Code[20]; DeprBookCode2: Code[10]): Integer
    var
        ResultOnDisposalFALedgerEntry: Record "FA Ledger Entry";
    begin
        FADepreciationBook."FA No." := FANo;
        FADepreciationBook."Depreciation Book Code" := DeprBookCode2;
        FADepreciationBook.CalcFields("Gain/Loss");
        if FADepreciationBook."Gain/Loss" <= 0 then
            exit(ResultOnDisposalFALedgerEntry."Result on Disposal"::Gain);
        exit(ResultOnDisposalFALedgerEntry."Result on Disposal"::Loss);
    end;

    [EventSubscriber(ObjectType::Codeunit, Codeunit::"FA Get G/L Account No.", 'OnBeforeGetMaintenanceAccNo', '', false, false)]
    local procedure GetMaintenanceExpenseAccountOnBeforeGetMaintenanceAccNo(var MaintenanceLedgEntry: Record "Maintenance Ledger Entry"; var AccountNo: Code[20]; var IsHandled: Boolean)
    var
        FAPostingGroup: Record "FA Posting Group";
    begin
        FAPostingGroup.GetPostingGroup(
            MaintenanceLedgEntry."FA Posting Group", MaintenanceLedgEntry."Depreciation Book Code");
        AccountNo := FAPostingGroup.GetMaintenanceExpenseAccountCZF(MaintenanceLedgEntry."Maintenance Code");
        IsHandled := true;
    end;

    [EventSubscriber(ObjectType::Codeunit, Codeunit::"FA Insert G/L Account", 'OnInsertMaintenanceAccNoOnBeforeInsertBufferEntry', '', false, false)]
    local procedure GetMaintenanceExpenseAccountOnInsertMaintenanceAccNoOnBeforeInsertBufferEntry(var FAGLPostBuf: Record "FA G/L Posting Buffer"; var MaintenanceLedgEntry: Record "Maintenance Ledger Entry")
    var
        FAPostingGroup: Record "FA Posting Group";
    begin
        FAPostingGroup.GetPostingGroup(
            MaintenanceLedgEntry."FA Posting Group", MaintenanceLedgEntry."Depreciation Book Code");
        FAGLPostBuf."Account No." := FAPostingGroup.GetMaintenanceExpenseAccountCZF(MaintenanceLedgEntry."Maintenance Code");
    end;

    [EventSubscriber(ObjectType::Codeunit, Codeunit::"FA Insert G/L Account", 'OnBeforeFAInsertGLAccount', '', false, false)]
    local procedure OnRunOnBeforeFAInsertGLAccount(var FALedgerEntry: Record "FA Ledger Entry"; var TempFAGLPostBuf: Record "FA G/L Posting Buffer"; var FAGLPostBuf: Record "FA G/L Posting Buffer"; DisposalEntry: Boolean; BookValueEntry: Boolean; var NextEntryNo: Integer; var GLEntryNo: Integer; var OrgGenJnlLine: Boolean; var NetDisp: Boolean; var NumberOfEntries: Integer; var DisposalEntryNo: Integer; var DisposalAmount: Decimal; var GainLossAmount: Decimal; var FAPostingGr2: Record "FA Posting Group"; var IsHandled: Boolean)
    var
        DepreciationBook: Record "Depreciation Book";
        DepreciationDisposalEntry: Boolean;
    begin
        DepreciationBook.Get(FALedgerEntry."Depreciation Book Code");
        DepreciationDisposalEntry :=
          (FALedgerEntry."FA Posting Category" = FALedgerEntry."FA Posting Category"::Disposal) and
          (FALedgerEntry."FA Posting Type" = FALedgerEntry."FA Posting Type"::Depreciation) and
          (DepreciationBook."Disposal Calculation Method" = DepreciationBook."Disposal Calculation Method"::Gross);
        if DepreciationDisposalEntry then
            if DepreciationBook."Corresp. G/L Entries Disp. CZF" then
                if not DepreciationBook."Corresp. FA Entries Disp. CZF" then begin
                    FALedgerEntry."G/L Entry No." := 0;
                    IsHandled := true;
                    exit;
                end;

        if not DisposalEntry and not DepreciationDisposalEntry then
            FAGLPostBuf."Account No." := GetAccNo(FALedgerEntry);
        if DepreciationDisposalEntry then begin
            case FAPostingType of
                FAPostingType::AcqCost:
                    FALedgerEntry."FA Posting Type" := FALedgerEntry."FA Posting Type"::"Acquisition Cost";
                FAPostingType::BookVal:
                    FALedgerEntry."FA Posting Type" := FALedgerEntry."FA Posting Type"::"Book Value on Disposal";
                FAPostingType::Apprec:
                    FALedgerEntry."FA Posting Type" := FALedgerEntry."FA Posting Type"::Appreciation;
                FAPostingType::WrDown:
                    FALedgerEntry."FA Posting Type" := FALedgerEntry."FA Posting Type"::"Write-Down";
            end;
            if FAPostingType <> FAPostingType::" " then
                FAGLPostBuf."Account No." := GetAccNo(FALedgerEntry)
            else
                FAGLPostBuf."Account No." := GetAccNo(FALedgerEntry);
            FALedgerEntry."FA Posting Type" := FALedgerEntry."FA Posting Type"::Depreciation;
        end;

        FAGLPostBuf.Amount := FALedgerEntry.Amount;
        FAGLPostBuf.Correction := FALedgerEntry.Correction;
        FAGLPostBuf."Global Dimension 1 Code" := FALedgerEntry."Global Dimension 1 Code";
        FAGLPostBuf."Global Dimension 2 Code" := FALedgerEntry."Global Dimension 2 Code";
        FAGLPostBuf."Dimension Set ID" := FALedgerEntry."Dimension Set ID";
        FAGLPostBuf."FA Entry No." := FALedgerEntry."Entry No.";

        if FALedgerEntry."Entry No." > 0 then
            FAGLPostBuf."FA Entry Type" := FAGLPostBuf."FA Entry Type"::"Fixed Asset";
        FAGLPostBuf."Automatic Entry" := FALedgerEntry."Automatic Entry";
        GLEntryNo := FALedgerEntry."G/L Entry No.";
        InsertBufferEntry(TempFAGLPostBuf, FAGLPostBuf, NextEntryNo, GLEntryNo, OrgGenJnlLine, NetDisp, NumberOfEntries);
        FALedgerEntry."G/L Entry No." := TempFAGLPostBuf."Entry No.";

        if (FALedgerEntry."FA Posting Category" = FALedgerEntry."FA Posting Category"::Disposal) and
           DepreciationBook."Corresp. G/L Entries Disp. CZF"
        then
            if not DepreciationBook."Corresp. FA Entries Disp. CZF" then
                case FALedgerEntry."FA Posting Type" of
                    FALedgerEntry."FA Posting Type"::"Acquisition Cost",
                    FALedgerEntry."FA Posting Type"::"Book Value on Disposal",
                    FALedgerEntry."FA Posting Type"::"Write-Down",
                    FALedgerEntry."FA Posting Type"::Appreciation,
                    FALedgerEntry."FA Posting Type"::"Custom 1",
                    FALedgerEntry."FA Posting Type"::"Custom 2":
                        begin
                            FAGLPostBuf."Account No." := GetAccNo(FALedgerEntry);
                            FAGLPostBuf.Amount := -FALedgerEntry.Amount;
                            InsertBufferEntry(TempFAGLPostBuf, FAGLPostBuf, NextEntryNo, GLEntryNo, OrgGenJnlLine, NetDisp, NumberOfEntries);
                            FALedgerEntry."G/L Entry No." := TempFAGLPostBuf."Entry No." - 1;
                        end;
                end
            else
                case FALedgerEntry."FA Posting Type" of
                    FALedgerEntry."FA Posting Type"::"Custom 1",
                    FALedgerEntry."FA Posting Type"::"Custom 2":
                        begin
                            FAGLPostBuf."Account No." := GetAccNo(FALedgerEntry);
                            FAGLPostBuf.Amount := -FALedgerEntry.Amount;
                            InsertBufferEntry(TempFAGLPostBuf, FAGLPostBuf, NextEntryNo, GLEntryNo, OrgGenJnlLine, NetDisp, NumberOfEntries);
                            FALedgerEntry."G/L Entry No." := TempFAGLPostBuf."Entry No." - 1;
                        end;
                end;

        if DisposalEntry then
            CalcDisposalAmount(FALedgerEntry, TempFAGLPostBuf, DisposalEntryNo, DisposalAmount, GainLossAmount, FAPostingGr2);

        if DisposalEntryNo <> 0 then begin
            CorrectDisposalEntry(FALedgerEntry, TempFAGLPostBuf, FAGLPostBuf, DisposalEntryNo, DisposalAmount, GainLossAmount, FAPostingGr2,
                                 NextEntryNo, GLEntryNo, OrgGenJnlLine, NetDisp, NumberOfEntries);
            if not BookValueEntry then
                CorrectBookValueEntry(FALedgerEntry, TempFAGLPostBuf, FAGLPostBuf, DisposalEntryNo, GainLossAmount, FAPostingGr2,
                                      NextEntryNo, GLEntryNo, OrgGenJnlLine, NetDisp, NumberOfEntries);
        end;

        IsHandled := true;
    end;

    local procedure InsertBufferEntry(var TempFAGLPostingBuffer: Record "FA G/L Posting Buffer" temporary; var FAGLPostingBuffer: Record "FA G/L Posting Buffer"; var NextEntryNo: Integer; GLEntryNo: Integer; OrgGenJnlLine: Boolean; NetDisp: Boolean; var NumberOfEntries: Integer)
    begin
        if TempFAGLPostingBuffer.IsEmpty() then
            NextEntryNo := GLEntryNo
        else
            NextEntryNo := TempFAGLPostingBuffer.GetLastEntryNo() + 1;

        TempFAGLPostingBuffer := FAGLPostingBuffer;
        TempFAGLPostingBuffer."Entry No." := NextEntryNo;
        TempFAGLPostingBuffer."Original General Journal Line" := OrgGenJnlLine;
        TempFAGLPostingBuffer."Net Disposal" := NetDisp;
        TempFAGLPostingBuffer.Insert();
        NumberOfEntries += 1;
    end;

    local procedure CalcDisposalAmount(FALedgerEntry: Record "FA Ledger Entry"; var TempFAGLPostingBuffer: Record "FA G/L Posting Buffer" temporary; var DisposalEntryNo: Integer; var DisposalAmount: Decimal; var GainLossAmount: Decimal; var FAPostingGroup2: Record "FA Posting Group")
    begin
        DisposalEntryNo := TempFAGLPostingBuffer."Entry No.";
        FADepreciationBook.Get(FALedgerEntry."FA No.", FALedgerEntry."Depreciation Book Code");
        FADepreciationBook.CalcFields("Proceeds on Disposal", "Gain/Loss");
        DisposalAmount := FADepreciationBook."Proceeds on Disposal";
        GainLossAmount := FADepreciationBook."Gain/Loss";
        FAPostingGroup2.Get(FALedgerEntry."FA Posting Group");
    end;

    local procedure CorrectDisposalEntry(var FALedgerEntry: Record "FA Ledger Entry"; var TempFAGLPostingBuffer: Record "FA G/L Posting Buffer" temporary; var FAGLPostingBuffer: Record "FA G/L Posting Buffer"; DisposalEntryNo: Integer; DisposalAmount: Decimal; GainLossAmount: Decimal; var FAPostingGroup2: Record "FA Posting Group"; var NextEntryNo: Integer; GLEntryNo: Integer; var OrgGenJnlLine: Boolean; NetDisp: Boolean; var NumberOfEntries: Integer)
    var
        LastDisposal: Boolean;
        GLAmount: Decimal;
        SalesAccountOnDisposalGain: Code[20];
        SalesAccountOnDisposalLoss: Code[20];
    begin
        FADepreciationBook.Get(FALedgerEntry."FA No.", FALedgerEntry."Depreciation Book Code");
        TempFAGLPostingBuffer.Get(DisposalEntryNo);
        FADepreciationBook.CalcFields("Gain/Loss");
        LastDisposal := CalcLastDisposal(FADepreciationBook);
        SalesAccountOnDisposalGain := FAPostingGroup2.GetSalesAccountOnDisposalGainCZF(FALedgerEntry."Reason Code");
        SalesAccountOnDisposalLoss := FAPostingGroup2.GetSalesAccountOnDisposalLossCZF(FALedgerEntry."Reason Code");
        if LastDisposal then
            GLAmount := GainLossAmount
        else
            GLAmount := FADepreciationBook."Gain/Loss";
        if GLAmount <= 0 then
            TempFAGLPostingBuffer."Account No." := SalesAccountOnDisposalGain
        else
            TempFAGLPostingBuffer."Account No." := SalesAccountOnDisposalLoss;
        TempFAGLPostingBuffer.Modify();
        FAGLPostingBuffer := TempFAGLPostingBuffer;
        if LastDisposal then
            exit;
        if IdenticalSign(FADepreciationBook."Gain/Loss", GainLossAmount, DisposalAmount) then
            exit;
        if SalesAccountOnDisposalGain = SalesAccountOnDisposalLoss then
            exit;

        FAGLPostingBuffer."FA Entry No." := 0;
        FAGLPostingBuffer."FA Entry Type" := FAGLPostingBuffer."FA Entry Type"::" ";
        FAGLPostingBuffer."Automatic Entry" := true;
        OrgGenJnlLine := false;

        if FADepreciationBook."Gain/Loss" <= 0 then begin
            FAGLPostingBuffer."Account No." := SalesAccountOnDisposalGain;
            FAGLPostingBuffer.Amount := DisposalAmount;
            InsertBufferEntry(TempFAGLPostingBuffer, FAGLPostingBuffer, NextEntryNo, GLEntryNo, OrgGenJnlLine, NetDisp, NumberOfEntries);
            FAGLPostingBuffer."Account No." := SalesAccountOnDisposalLoss;
            FAGLPostingBuffer.Amount := -DisposalAmount;
            FAGLPostingBuffer.Correction := not FAGLPostingBuffer.Correction;
            InsertBufferEntry(TempFAGLPostingBuffer, FAGLPostingBuffer, NextEntryNo, GLEntryNo, OrgGenJnlLine, NetDisp, NumberOfEntries);
        end else begin
            FAGLPostingBuffer."Account No." := SalesAccountOnDisposalLoss;
            FAGLPostingBuffer.Amount := DisposalAmount;
            InsertBufferEntry(TempFAGLPostingBuffer, FAGLPostingBuffer, NextEntryNo, GLEntryNo, OrgGenJnlLine, NetDisp, NumberOfEntries);
            FAGLPostingBuffer."Account No." := SalesAccountOnDisposalGain;
            FAGLPostingBuffer.Amount := -DisposalAmount;
            FAGLPostingBuffer.Correction := not FAGLPostingBuffer.Correction;
            InsertBufferEntry(TempFAGLPostingBuffer, FAGLPostingBuffer, NextEntryNo, GLEntryNo, OrgGenJnlLine, NetDisp, NumberOfEntries);
        end;
    end;

    local procedure CorrectBookValueEntry(var FALedgerEntry: Record "FA Ledger Entry"; var TempFAGLPostingBuffer: Record "FA G/L Posting Buffer" temporary; var FAGLPostingBuffer: Record "FA G/L Posting Buffer"; DisposalEntryNo: Integer; GainLossAmount: Decimal; var FAPostingGroup2: Record "FA Posting Group"; var NextEntryNo: Integer; GLEntryNo: Integer; var OrgGenJnlLine: Boolean; NetDisp: Boolean; var NumberOfEntries: Integer)
    var
        DisposalFALedgerEntry: Record "FA Ledger Entry";
        BookValueAmount: Decimal;
    begin
        FADepreciationBook.Get(FALedgerEntry."FA No.", FALedgerEntry."Depreciation Book Code");

        DepreciationCalculation.SetFAFilter(
          DisposalFALedgerEntry, FADepreciationBook."FA No.", FADepreciationBook."Depreciation Book Code", true);
        DisposalFALedgerEntry.SetRange("FA Posting Category", DisposalFALedgerEntry."FA Posting Category"::Disposal);
        DisposalFALedgerEntry.SetRange("FA Posting Type", DisposalFALedgerEntry."FA Posting Type"::"Book Value on Disposal");
        DisposalFALedgerEntry.CalcSums(Amount);
        BookValueAmount := DisposalFALedgerEntry.Amount;
        TempFAGLPostingBuffer.Get(DisposalEntryNo);
        FAGLPostingBuffer := TempFAGLPostingBuffer;
        if IdenticalSign(FADepreciationBook."Gain/Loss", GainLossAmount, BookValueAmount) then
            exit;
        if FAPostingGroup2.GetBookValueAccountOnDisposalGain() = FAPostingGroup2.GetBookValueAccountOnDisposalLoss() then
            exit;
        OrgGenJnlLine := false;
        if FADepreciationBook."Gain/Loss" <= 0 then begin
            InsertBufferBalAcc(
              FALedgerEntry,
              TempFAGLPostingBuffer,
              FAGLPostingBuffer,
              NextEntryNo,
              GLEntryNo,
              OrgGenJnlLine,
              NetDisp,
              NumberOfEntries,
              "FA Posting Group Account Type"::"Book Value Gain",
              BookValueAmount,
              FADepreciationBook."Depreciation Book Code",
              FAPostingGroup2.Code,
              FAGLPostingBuffer."Global Dimension 1 Code",
              FAGLPostingBuffer."Global Dimension 2 Code",
              FAGLPostingBuffer."Dimension Set ID",
              true, FAGLPostingBuffer.Correction);

            InsertBufferBalAcc(
              FALedgerEntry,
              TempFAGLPostingBuffer,
              FAGLPostingBuffer,
              NextEntryNo,
              GLEntryNo,
              OrgGenJnlLine,
              NetDisp,
              NumberOfEntries,
              "FA Posting Group Account Type"::"Book Value Loss",
              -BookValueAmount,
              FADepreciationBook."Depreciation Book Code",
              FAPostingGroup2.Code,
              FAGLPostingBuffer."Global Dimension 1 Code",
              FAGLPostingBuffer."Global Dimension 2 Code",
              FAGLPostingBuffer."Dimension Set ID",
              true, not FAGLPostingBuffer.Correction);
        end else begin
            InsertBufferBalAcc(
              FALedgerEntry,
              TempFAGLPostingBuffer,
              FAGLPostingBuffer,
              NextEntryNo,
              GLEntryNo,
              OrgGenJnlLine,
              NetDisp,
              NumberOfEntries,
              "FA Posting Group Account Type"::"Book Value Loss",
              BookValueAmount,
              FADepreciationBook."Depreciation Book Code",
              FAPostingGroup2.Code,
              FAGLPostingBuffer."Global Dimension 1 Code",
              FAGLPostingBuffer."Global Dimension 2 Code",
              FAGLPostingBuffer."Dimension Set ID",
              true, FAGLPostingBuffer.Correction);

            InsertBufferBalAcc(
              FALedgerEntry,
              TempFAGLPostingBuffer,
              FAGLPostingBuffer,
              NextEntryNo,
              GLEntryNo,
              OrgGenJnlLine,
              NetDisp,
              NumberOfEntries,
              "FA Posting Group Account Type"::"Book Value Gain",
              -BookValueAmount,
              FADepreciationBook."Depreciation Book Code",
              FAPostingGroup2.Code,
              FAGLPostingBuffer."Global Dimension 1 Code",
              FAGLPostingBuffer."Global Dimension 2 Code",
              FAGLPostingBuffer."Dimension Set ID",
              true, not FAGLPostingBuffer.Correction);
        end;
    end;

    local procedure IdenticalSign(A: Decimal; B: Decimal; C: Decimal): Boolean
    begin
        exit(((A <= 0) = (B <= 0)) or (C = 0));
    end;

    local procedure CalcLastDisposal(FADepreciationBook2: Record "FA Depreciation Book"): Boolean
    var
        ProceedsOnDisposalFALedgerEntry: Record "FA Ledger Entry";
    begin
        DepreciationCalculation.SetFAFilter(
          ProceedsOnDisposalFALedgerEntry, FADepreciationBook2."FA No.", FADepreciationBook2."Depreciation Book Code", true);
        ProceedsOnDisposalFALedgerEntry.SetRange("FA Posting Type", ProceedsOnDisposalFALedgerEntry."FA Posting Type"::"Proceeds on Disposal");
        exit(ProceedsOnDisposalFALedgerEntry.IsEmpty());
    end;

    local procedure InsertBufferBalAcc(var FALedgerEntry: Record "FA Ledger Entry"; var TempFAGLPostingBuffer: Record "FA G/L Posting Buffer" temporary; var FAGLPostingBuffer: Record "FA G/L Posting Buffer"; var NextEntryNo: Integer; GLEntryNo: Integer; OrgGenJnlLine: Boolean; NetDisp: Boolean; var NumberOfEntries: Integer; FAPostingType2: Enum "FA Posting Group Account Type"; AllocAmount: Decimal; DeprBookCode2: Code[10]; PostingGrCode: Code[20]; GlobalDim1Code: Code[20]; GlobalDim2Code: Code[20]; DimSetID: Integer; AutomaticEntry: Boolean; Correction: Boolean)
    var
        FAAllocation: Record "FA Allocation";
        FAPostingGroup: Record "FA Posting Group";
        SourceCodeSetup: Record "Source Code Setup";
        GLAccNo: Code[20];
        DimensionSetIDArr: array[10] of Integer;
        DefaultDimSource: List of [Dictionary of [Integer, Code[20]]];
        ReasonMaintenanceCode: Code[10];
        TotalAllocAmount, NewAmount, TotalPercent : Decimal;
    begin
        ReasonMaintenanceCode := FALedgerEntry."Reason Code";
        NumberOfEntries := 0;
        TotalAllocAmount := 0;
        NewAmount := 0;
        TotalPercent := 0;
        FAPostingGroup.GetPostingGroup(PostingGrCode, DeprBookCode2);
        GLAccNo := GetGLAccNoFromFAPostingGroup(FAPostingGroup, FAPostingType2, ReasonMaintenanceCode);
        DimensionSetIDArr[1] := DimSetID;

        FAAllocation.SetRange(Code, PostingGrCode);
        FAAllocation.SetRange("Allocation Type", FAPostingType2);
        if not FAPostingGroup.UseStandardDisposalCZF(ReasonMaintenanceCode) then
            FAAllocation.SetRange("Reason/Maintenance Code CZF", ReasonMaintenanceCode)
        else
            FAAllocation.SetRange("Reason/Maintenance Code CZF", '');
        if FAAllocation.FindSet() then
            repeat
                if (FAAllocation."Account No." = '') and (FAAllocation."Allocation %" > 0) then
                    FAAllocation.TestField("Account No.");
                TotalPercent += FAAllocation."Allocation %";
                NewAmount :=
                    DepreciationCalculation.CalcRounding(DeprBookCode2, AllocAmount * TotalPercent / 100) - TotalAllocAmount;
                TotalAllocAmount += NewAmount;
                if Abs(TotalAllocAmount) > Abs(AllocAmount) then
                    NewAmount := AllocAmount - (TotalAllocAmount - NewAmount);
                Clear(FAGLPostingBuffer);
                FAGLPostingBuffer."Account No." := FAAllocation."Account No.";

                DimensionSetIDArr[2] := FAAllocation."Dimension Set ID";
                FAGLPostingBuffer."Dimension Set ID" :=
                    DimensionManagement.GetCombinedDimensionSetID(
                        DimensionSetIDArr, FAGLPostingBuffer."Global Dimension 1 Code", FAGLPostingBuffer."Global Dimension 2 Code");

                FAGLPostingBuffer.Amount := NewAmount;
                FAGLPostingBuffer."Automatic Entry" := AutomaticEntry;
                FAGLPostingBuffer.Correction := Correction;
                FAGLPostingBuffer."FA Posting Group" := FAAllocation.Code;
                FAGLPostingBuffer."FA Allocation Type" := FAAllocation."Allocation Type";
                FAGLPostingBuffer."FA Allocation Line No." := FAAllocation."Line No.";
                if NewAmount <> 0 then begin
                    FADimensionManagement.CheckFAAllocDim(FAAllocation, FAGLPostingBuffer."Dimension Set ID");
                    InsertBufferEntry(TempFAGLPostingBuffer, FAGLPostingBuffer, NextEntryNo, GLEntryNo, OrgGenJnlLine, NetDisp, NumberOfEntries);
                end;
            until FAAllocation.Next() = 0;

        if Abs(TotalAllocAmount) < Abs(AllocAmount) then begin
            NewAmount := AllocAmount - TotalAllocAmount;
            Clear(FAGLPostingBuffer);
            FAGLPostingBuffer."Account No." := GLAccNo;
            FAGLPostingBuffer.Amount := NewAmount;
            FAGLPostingBuffer."Global Dimension 1 Code" := GlobalDim1Code;
            FAGLPostingBuffer."Global Dimension 2 Code" := GlobalDim2Code;
            SourceCodeSetup.Get();
            DimensionManagement.AddDimSource(DefaultDimSource, Database::"G/L Account", GLAccNo);
            FAGLPostingBuffer."Dimension Set ID" := DimensionManagement.GetDefaultDimID(
              DefaultDimSource, SourceCodeSetup."Fixed Asset G/L Journal", FAGLPostingBuffer."Global Dimension 1 Code",
              FAGLPostingBuffer."Global Dimension 2 Code", DimSetID, Database::"Fixed Asset");
            FAGLPostingBuffer."Automatic Entry" := AutomaticEntry;
            FAGLPostingBuffer.Correction := Correction;
            if NewAmount <> 0 then
                InsertBufferEntry(TempFAGLPostingBuffer, FAGLPostingBuffer, NextEntryNo, GLEntryNo, OrgGenJnlLine, NetDisp, NumberOfEntries);
        end;
    end;

    [EventSubscriber(ObjectType::Codeunit, Codeunit::"Calc. G/L Acc. Where-Used", 'OnAfterFillTableBuffer', '', false, false)]
    local procedure AddSetupTableOnAfterFillTableBuffer(var TableBuffer: Record "Integer")
    var
        CalcGLAccWhereUsed: Codeunit "Calc. G/L Acc. Where-Used";
    begin
        CalcGLAccWhereUsed.AddTable(TableBuffer, Database::"FA Extended Posting Group CZF");
    end;

    [EventSubscriber(ObjectType::Codeunit, Codeunit::"Calc. G/L Acc. Where-Used", 'OnShowExtensionPage', '', false, false)]
    local procedure ShowSetupPageOnGLAccWhereUsed(GLAccountWhereUsed: Record "G/L Account Where-Used")
    var
        FAExtendedPostingGroupCZF: Record "FA Extended Posting Group CZF";
    begin
        if GLAccountWhereUsed."Table ID" = Database::"FA Extended Posting Group CZF" then begin
            FAExtendedPostingGroupCZF."FA Posting Group Code" := CopyStr(GLAccountWhereUsed."Key 1", 1, MaxStrLen(FAExtendedPostingGroupCZF."FA Posting Group Code"));
            Evaluate(FAExtendedPostingGroupCZF."FA Posting Type", GLAccountWhereUsed."Key 2");
            FAExtendedPostingGroupCZF.Code := CopyStr(GLAccountWhereUsed."Key 3", 1, MaxStrLen(FAExtendedPostingGroupCZF.Code));
            Page.Run(Page::"FA Extended Posting Groups CZF", FAExtendedPostingGroupCZF);
        end;
    end;

    [EventSubscriber(ObjectType::Codeunit, Codeunit::"FA Insert G/L Account", 'OnGetBalAccAfterSaveGenJnlLineFields', '', false, false)]
    local procedure OnGetBalAccAfterSaveGenJnlLineFields(FromGenJnlLine: Record "Gen. Journal Line"; var SkipInsert: Boolean; var sender: Codeunit "FA Insert G/L Account")
    var
        FAInsertGLAccHandlerCZF: Codeunit "FA Insert G/L Acc. Handler CZF";
    begin
        FAInsertGLAccHandlerCZF.SetReasonMaintenanceCode(FromGenJnlLine."Reason Code");
        if FromGenJnlLine."FA Posting Type" = FromGenJnlLine."FA Posting Type"::Maintenance then
            FAInsertGLAccHandlerCZF.SetReasonMaintenanceCode(FromGenJnlLine."Maintenance Code");

        BindSubscription(FAInsertGLAccHandlerCZF);
        sender.InsertBufferBalAcc(
            "FA Posting Group Account Type".FromInteger(FromGenJnlLine."FA Posting Type".AsInteger() - 1), -FromGenJnlLine.Amount,
            FromGenJnlLine."Depreciation Book Code", FromGenJnlLine."Posting Group",
            FromGenJnlLine."Shortcut Dimension 1 Code", FromGenJnlLine."Shortcut Dimension 2 Code",
            FromGenJnlLine."Dimension Set ID", false, false);
        UnbindSubscription(FAInsertGLAccHandlerCZF);
        SkipInsert := true;
    end;
}