// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------
namespace Microsoft.Finance.AuditFileExport;

using Microsoft.Finance.GeneralLedger.Account;
using System.Utilities;

codeunit 5260 "Audit Mapping Helper"
{
    TableNo = "G/L Account Mapping Header";

    var
        ConfirmMgt: Codeunit "Confirm Management";
        PreparingSourceForMappingLbl: label 'Preparing the source for mapping...';
        ChartOfAccountsDoesNotExistErr: label 'A chart of accounts does not exist in the current company.';
        StartingDateNotFilledErr: label 'You must specify a starting date.';
        EndingDateNotFilledErr: label 'You must specify an ending date.';
        StandardAccountsMatchedMsg: label '%1 of %2 standard accounts have been automatically matched to the chart of accounts.', Comment = '%1,%2 = both integer values';
        DifferentMappingTypeErr: label 'It is not possible to copy the mapping due to different standard account types.';
        MatchChartOfAccountsQst: label 'Do you want to match a chart of accounts with standard account codes?';
        CreateChartOfAccountsQst: label 'Do you want to create a chart of accounts based on standard account codes?';
        NoGLAccountMappingErr: label 'G/L account mapping %1 does not have any lines.', Comment = '%1 = G/L Account Mapping Header Code';
        MappingExistsErr: label 'A mapping line for category %1 with standard G/L account code %2 already exists for mapping %3.', Comment = '%1 = category no., %2 = standard G/L account code, %3 = G/L Account Mapping Header Code';
        MappingNotDoneErr: label 'One or more G/L accounts do not have a mapping setup. Open the G/L Account Mapping page for the selected mapping and map each G/L account either to the standard account or the grouping code.';
        MappingDoneErr: label 'One or more G/L accounts are already mapped. Create a new mapping with another standard account type.';
        ChartOfAccountsAlreadyExistsErr: label 'A chart of accounts must be empty to be created based on standard accounts.';
        StandardAccountsNotExistErr: label 'Standard accounts of type %1 do not exist.', Comment = '%1 - Standard Account Type';
        DefaultLbl: label 'DEFAULT';
        TwoStringsTxt: label '%1/%2', Comment = '%1, %2 - strings to concatenate';
        TwoStringsWithSpaceTxt: label '%1 %2', Comment = '%1, %2 - strings to concatenate';

    trigger OnRun()
    begin
        SetupGLAccountsForMapping(Rec);
    end;

    procedure GetDefaultGLAccountMappingHeader(var GLAccountMappingHeader: Record "G/L Account Mapping Header")
    begin
        if not GLAccountMappingHeader.FindLast() then begin
            GLAccountMappingHeader.Init();
            GLAccountMappingHeader.Code := DefaultLbl;
            GLAccountMappingHeader.Insert(true);
        end;
    end;

    procedure GetDefaultGLAccountMappingHeader(var GLAccountMappingHeader: Record "G/L Account Mapping Header"; AuditFileExportFormat: Enum "Audit File Export Format")
    begin
        GLAccountMappingHeader.SetRange("Audit File Export Format", AuditFileExportFormat);
        if not GLAccountMappingHeader.FindLast() then begin
            GLAccountMappingHeader.Init();
            GLAccountMappingHeader.Code :=
                CopyStr(StrSubstNo(TwoStringsWithSpaceTxt, DefaultLbl, AuditFileExportFormat), 1, MaxStrLen(GLAccountMappingHeader.Code));
            GLAccountMappingHeader.Insert(true);
        end;
    end;

    procedure ValidateGLAccMapping(var GLAccountMappingHeader: Record "G/L Account Mapping Header")
    begin
        if GLAccountMappingHeader."Starting Date" = 0D then
            Error(StartingDateNotFilledErr);
        if GLAccountMappingHeader."Ending Date" = 0D then
            Error(EndingDateNotFilledErr);
        GLAccountMappingHeader.Modify();
    end;

    procedure MatchChartOfAccounts(GLAccountMappingHeader: Record "G/L Account Mapping Header")
    begin
        MatchChartOfAccountsLocal(GLAccountMappingHeader, false);
    end;

    procedure CreateChartOfAccounts(GLAccountMappingHeader: Record "G/L Account Mapping Header")
    var
        GLAccount: Record "G/L Account";
        StandardAccount: Record "Standard Account";
    begin
        if not ConfirmMgt.GetResponseOrDefault(CreateChartOfAccountsQst, false) then
            exit;
        if not GLAccount.IsEmpty() then
            Error(ChartOfAccountsAlreadyExistsErr);

        StandardAccount.SetRange(Type, GLAccountMappingHeader."Standard Account Type");
        if StandardAccount.IsEmpty() then
            Error(StandardAccountsNotExistErr, GLAccountMappingHeader."Standard Account Type");
        StandardAccount.FindSet();
        repeat
            GLAccount.Init();
            GLAccount.Validate("No.", StandardAccount."No.");
            GLAccount.Validate(Name, CopyStr(StandardAccount.Description, 1, MaxStrLen(GLAccount.Name)));
            GLAccount.Validate("Account Type", GLAccount."Account Type"::Posting);
            GLAccount.Insert(true);
        until StandardAccount.Next() = 0;
        MatchChartOfAccountsLocal(GLAccountMappingHeader, true);
    end;

    procedure CopyMapping(FromGLAccountMappingCode: Code[20]; ToGLAccountMappingCode: Code[20]; Replace: Boolean)
    var
        FromGLAccountMapping: Record "G/L Account Mapping Header";
        ToGLAccountMapping: Record "G/L Account Mapping Header";
        FromGLAccountMappingLine: Record "G/L Account Mapping Line";
        ToGLAccountMappingLine: Record "G/L Account Mapping Line";
    begin
        FromGLAccountMapping.Get(FromGLAccountMappingCode);
        ToGLAccountMapping.Get(ToGLAccountMappingCode);
        if FromGLAccountMapping."Standard Account Type" <> ToGLAccountMapping."Standard Account Type" then
            Error(DifferentMappingTypeErr);

        FromGLAccountMappingLine.SetRange("G/L Account Mapping Code", FromGLAccountMappingCode);
        if not FromGLAccountMappingLine.FindSet() then
            Error(NoGLAccountMappingErr, FromGLAccountMappingCode);

        repeat
            ToGLAccountMappingLine := FromGLAccountMappingLine;
            ToGLAccountMappingLine."G/L Account Mapping Code" := ToGLAccountMappingCode;
            if not ToGLAccountMappingLine.Insert() then
                if Replace then
                    ToGLAccountMappingLine.Modify()
                else
                    Error(
                        MappingExistsErr, ToGLAccountMappingLine."Standard Account Category No.", ToGLAccountMappingLine."Standard Account No.",
                        ToGLAccountMappingLine."G/L Account Mapping Code");
        until FromGLAccountMappingLine.Next() = 0;
    end;

    procedure UpdateGLEntriesExistStateForGLAccMapping(GLAccountMappingCode: Code[20])
    var
        GLAccountMappingHeader: Record "G/L Account Mapping Header";
        GLAccountMappingLine: Record "G/L Account Mapping Line";
    begin
        if GLAccountMappingCode = '' then
            exit;
        if not GLAccountMappingHeader.get(GLAccountMappingCode) then
            exit;
        GLAccountMappingLine.SetRange("G/L Account Mapping Code", GLAccountMappingHeader.Code);
        if GLAccountMappingLine.FindSet() then
            repeat
                GLAccountMappingLine.Validate("G/L Entries Exists",
                    GLAccHasEntries(
                        GLAccountMappingLine."G/L Account No.", GLAccountMappingHeader."Starting Date",
                        GLAccountMappingHeader."Ending Date", GLAccountMappingHeader."Include Incoming Balance"));
                GLAccountMappingLine.Modify(true);
            until GLAccountMappingLine.Next() = 0;
    end;

    procedure AreStandardAccountsLoaded(StandardAccountType: enum "Standard Account Type"): Boolean;
    var
        StandardAccount: Record "Standard Account";
    begin
        StandardAccount.SetRange(Type, StandardAccountType);
        exit(not StandardAccount.IsEmpty());
    end;

    procedure VerifyMappingIsDone(GLAccountMappingCode: Code[20])
    var
        GLAccountMappingLine: Record "G/L Account Mapping Line";
        GLAccountMappingHeader: Record "G/L Account Mapping Header";
    begin
        UpdateGLEntriesExistStateForGLAccMapping(GLAccountMappingCode);
        GLAccountMappingLine.SetRange("G/L Account Mapping Code", GLAccountMappingCode);
        GLAccountMappingLine.SetRange("Standard Account No.", '');
        if not GLAccountMappingLine.IsEmpty() then begin
            GLAccountMappingHeader.Get(GLAccountMappingCode);
            LogError(GLAccountMappingHeader, MappingNotDoneErr);
        end;
    end;

    procedure VerifyNoMappingDone(GLAccountMappingHeader: Record "G/L Account Mapping Header")
    var
        GLAccountMappingLine: Record "G/L Account Mapping Line";
    begin
        GLAccountMappingLine.SetRange("G/L Account Mapping Code", GLAccountMappingHeader.Code);
        GLAccountMappingLine.SetFilter("Standard Account No.", '<>%1', '');
        if not GLAccountMappingLine.IsEmpty() then
            Error(MappingDoneErr);
    end;

    procedure GetGLAccountsMappedInfo(GLAccountMappingCode: Code[20]): Text[20]
    var
        GLAccountMappingLine: Record "G/L Account Mapping Line";
        TotalCount: Integer;
    begin
        GLAccountMappingLine.SetRange("G/L Account Mapping Code", GLAccountMappingCode);
        TotalCount := GLAccountMappingLine.Count();
        GLAccountMappingLine.SetFilter("Standard Account No.", '<>%1', '');
        exit(StrSubstNo(TwoStringsTxt, GLAccountMappingLine.Count(), TotalCount));
    end;

    procedure InsertDefaultNoSeriesInAuditFileExportSetup()
    var
        AuditFileExportSetup: Record "Audit File Export Setup";
    begin
        if not AuditFileExportSetup.Get() then begin
            AuditFileExportSetup.Init();
            AuditFileExportSetup.Insert();
        end;
    end;

    local procedure SetupGLAccountsForMapping(GLAccountMappingHeader: Record "G/L Account Mapping Header")
    var
        GLAccount: Record "G/L Account";
        GLAccountMappingLine: Record "G/L Account Mapping Line";
        ProgressDialog: Dialog;
    begin
        GLAccountMappingHeader.TestField("Standard Account Type");
        GLAccountMappingHeader.TestField("Starting Date");
        GLAccountMappingHeader.TestField("Ending Date");
        if GuiAllowed() then
            ProgressDialog.Open(PreparingSourceForMappingLbl);
        OnSetupGLAccountsForMappingOnBeforeGetGLAccountForMapping(GLAccount);
        GetGLAccountForMapping(GLAccount);
        repeat
            GLAccountMappingLine.Init();
            GLAccountMappingLine."G/L Account Mapping Code" := GLAccountMappingHeader.Code;
            GLAccountMappingLine."Standard Account Type" := GLAccountMappingHeader."Standard Account Type";
            GLAccountMappingLine."G/L Account No." := GLAccount."No.";
            GLAccountMappingLine."G/L Entries Exists" :=
                GLAccNetChangeIsNotZero(
                    GLAccount, GLAccountMappingHeader."Starting Date", GLAccountMappingHeader."Ending Date",
                    GLAccountMappingHeader."Include Incoming Balance");
            if not GLAccountMappingLine.Find() then
                GLAccountMappingLine.Insert();
        until GLAccount.Next() = 0;
        if GuiAllowed() then
            ProgressDialog.Close();
    end;

    local procedure GetGLAccountForMapping(var GLAccount: Record "G/L Account")
    begin
        GLAccount.SetRange("Account Type", GLAccount."Account Type"::Posting);
        if not GLAccount.FindSet() then
            Error(ChartOfAccountsDoesNotExistErr);
    end;

    local procedure MatchChartOfAccountsLocal(GLAccountMappingHeader: Record "G/L Account Mapping Header"; FromCreateChartOfAccounts: Boolean)
    var
        StandardAccount: Record "Standard Account";
        GLAccountMappingLine: Record "G/L Account Mapping Line";
        GLAccount: Record "G/L Account";
        MatchedCount: Integer;
    begin
        if not FromCreateChartOfAccounts then
            if not ConfirmMgt.GetResponseOrDefault(MatchChartOfAccountsQst, false) then
                exit;

        StandardAccount.SetRange(Type, GLAccountMappingHeader."Standard Account Type");
        if StandardAccount.IsEmpty() then
            exit;
        StandardAccount.FindSet();
        repeat
            if GLAccount.Get(StandardAccount."No.") and (GLAccount."Account Type" = GLAccount."Account Type"::Posting) then begin
                GLAccountMappingLine.Init();
                GLAccountMappingLine."Standard Account Type" := StandardAccount.Type;
                GLAccountMappingLine."Standard Account Category No." := StandardAccount."Category No.";
                GLAccountMappingLine."G/L Account No." := GLAccount."No.";
                GLAccountMappingLine."G/L Account Mapping Code" := GLAccountMappingHeader.Code;
                GLAccountMappingLine."Standard Account No." := StandardAccount."No.";
                if not GLAccountMappingLine.insert() then
                    GLAccountMappingLine.Modify();
                MatchedCount += 1;
            end;
        until StandardAccount.Next() = 0;
        if GuiAllowed() then begin
            GLAccount.SetRange("Account Type", GLAccount."Account Type"::Posting);
            Message(StandardAccountsMatchedMsg, MatchedCount, GLAccount.Count());
        end;
    end;

    local procedure GLAccHasEntries(GLAccNo: Code[20]; StartingDate: Date; EndingDate: Date; IncludeIncomingBalance: Boolean): Boolean
    var
        GLAccount: Record "G/L Account";
    begin
        if not GLAccount.Get(GLAccNo) then
            exit(false);
        exit(GLAccNetChangeIsNotZero(GLAccount, StartingDate, EndingDate, IncludeIncomingBalance));
    end;

    local procedure GLAccNetChangeIsNotZero(GLAccount: Record "G/L Account"; StartingDate: Date; EndingDate: Date; IncludeIncomingBalance: Boolean): Boolean
    begin
        if (GLAccount."Income/Balance" = GLAccount."Income/Balance"::"Income Statement") or (not IncludeIncomingBalance) then
            GLAccount.SetRange("Date Filter", StartingDate, EndingDate)
        else
            GLAccount.SetRange("Date Filter", 0D, ClosingDate(EndingDate));
        GLAccount.CalcFields("Net Change");
        exit(GLAccount."Net Change" <> 0);
    end;

    local procedure LogError(SourceVariant: Variant; ErrorMessage: Text)
    var
        ErrorMessageManagement: Codeunit "Error Message Management";
    begin
        if not GuiAllowed() then
            Error(ErrorMessage);
        ErrorMessageManagement.LogError(SourceVariant, ErrorMessage, '');
    end;

    [IntegrationEvent(false, false)]
    local procedure OnSetupGLAccountsForMappingOnBeforeGetGLAccountForMapping(var GLAccount: Record "G/L Account")
    begin
    end;
}
