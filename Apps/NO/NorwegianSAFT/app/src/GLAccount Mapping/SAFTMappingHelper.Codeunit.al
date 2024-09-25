// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------
namespace Microsoft.Finance.AuditFileExport;

using Microsoft.Finance.Dimension;
using Microsoft.Finance.GeneralLedger.Account;
using Microsoft.Finance.VAT.Setup;
using Microsoft.Foundation.AuditCodes;
using Microsoft.Utilities;
#if not CLEAN24
using System.Environment.Configuration;
using System.Media;
#endif
using System.Utilities;

codeunit 10672 "SAF-T Mapping Helper"
{
    TableNo = "SAF-T Mapping Range";

    var
        PreparingSourceForMappingLbl: Label 'Preparing the source for mapping...';
        ChartOfAccountsDoesNotExistErr: Label 'A chart of accounts does not exist in the current company.';
        StartingDateNotFilledErr: Label 'You must specify a starting date.';
        EndingDateNotFilledErr: Label 'You must specify an ending date.';
        StandardAccountsMatchedMsg: Label '%1 of %2 standard accounts have been automatically matched to the chart of accounts.', Comment = '%1,%2 = both integer values';
        DifferentMappingTypeErr: Label 'It is not possible to copy the mapping due to different mapping types.';
        MatchChartOfAccountsQst: Label 'Do you want to match a chart of accounts with SAF-T standard account codes?';
        CreateChartOfAccountsQst: Label 'Do you want to create a chart of accounts based on SAF-T standard account codes?';
        NoGLAccountMappingErr: Label 'No G/L account mapping was created for range ID %1', Comment = '%1 = any integer number';
        MappingExistsErr: Label 'Mapping for category %1 with mapping code %2 already exists for range ID %3.', Comment = '%1 = category no., %2 = mapping code, %3 = any integer number';
        MappingNotDoneErr: Label 'One or more G/L accounts do not have a mapping setup. Open the SAF-T Mapping Setup page for the selected mapping range and map each G/L account either to the  standard account or the grouping code.';
        MappingDoneErr: Label 'One or more G/L accounts already have a mapping setup. Create a new mapping range with another mapping type.';
        DimensionWithoutAnalysisCodeErr: Label 'One or more dimensions do not have a SAF-T analysis code. Open the Dimensions page and specify a SAF-T analysis code for each dimension.';
        VATPostingSetupWithoutTaxCodeErr: Label 'One or more VAT posting setup do not have a %1. Open the VAT Posting Setup page and specify %1 for each VAT posting setup combination.';
        SourceCodeWithoutSAFTCodeErr: Label 'One or more source codes do not have a SAF-T source code. Open the Source Codes page and specify a SAF-T source code for each source code.';
        ChartOfAccountsAlreadyExistsErr: Label 'A chart of accounts must be empty to be created based on SAF-T standard accounts.';
        AssortedJournalsSourceCodeDescriptionLbl: Label 'Assorted Journals';
        GeneralLedgerJournalsSourceCodeDescriptionLbl: Label 'General Ledger Journals';
        AccountReceivablesSourceCodeDescriptionLbl: Label 'Account Receivables';
        AccountPayablesSourceCodeDescriptionLbl: Label 'Account Payables';
#if not CLEAN24
        SAFTSetupGuideTxt: Label 'Set up SAF-T';
#endif
        DefaultLbl: Label 'DEFAULT';

    trigger OnRun()
    begin
        SetupGLAccountsForMapping(Rec);
    end;

    procedure GetDefaultSAFTMappingRange(var SAFTMappingRange: Record "SAF-T Mapping Range")
    begin
        with SAFTMappingRange do
            if not FindLast() then begin
                Init();
                Code := DefaultLbl;
                Insert(true);
            end;
    end;

    procedure ValidateMappingRange(var SAFTMappingRange: Record "SAF-T Mapping Range")
    begin
        if SAFTMappingRange."Starting Date" = 0D then
            error(StartingDateNotFilledErr);
        if SAFTMappingRange."Ending Date" = 0D then
            error(EndingDateNotFilledErr);
        SAFTMappingRange.Modify();
    end;

    procedure MatchChartOfAccounts(SAFTMappingRange: Record "SAF-T Mapping Range")
    begin
        MatchChartOfAccountsLocal(SAFTMappingRange, false);
    end;

    procedure CreateChartOfAccounts(SAFTMappingRange: Record "SAF-T Mapping Range")
    var
        GLAccount: Record "G/L Account";
        SAFTMapping: Record "SAF-T Mapping";
    begin
        if GuiAllowed() then
            if not Confirm(CreateChartOfAccountsQst, false) then
                exit;
        if not GLAccount.IsEmpty() then
            error(ChartOfAccountsAlreadyExistsErr);
        SAFTMappingRange.CheckMappingIsStandardAccount();

        SAFTMapping.SetRange("Mapping Type", SAFTMappingRange."Mapping Type");
        SAFTMapping.FindSet();
        repeat
            GLAccount.Init();
            GLAccount.Validate("No.", SAFTMapping."No.");
            GLAccount.Validate(Name, copystr(SAFTMapping.Description, 1, MaxStrLen(GLAccount.Name)));
            GLAccount.Validate("Account Type", GLAccount."Account Type"::Posting);
            GLAccount.Insert(true);
        until SAFTMapping.Next() = 0;
        MatchChartOfAccountsLocal(SAFTMappingRange, true);
    end;

    local procedure MatchChartOfAccountsLocal(SAFTMappingRange: Record "SAF-T Mapping Range"; FromCreateChartOfAccounts: Boolean)
    var
        SAFTMapping: Record "SAF-T Mapping";
        SAFTGLAccountMapping: Record "SAF-T G/L Account Mapping";
        GLAccount: Record "G/L Account";
        MatchedCount: Integer;
    begin
        if GuiAllowed() and (not FromCreateChartOfAccounts) then
            if not Confirm(MatchChartOfAccountsQst, false) then
                exit;
        SAFTMappingRange.CheckMappingIsStandardAccount();
        SAFTMapping.SetRange("Mapping Type", SAFTMappingRange."Mapping Type");
        SAFTMapping.FindSet();
        repeat
            if GLAccount.GET(SAFTMapping."No.") and (GLAccount."Account Type" = GLAccount."Account Type"::Posting) then begin
                SAFTGLAccountMapping.Init();
                SAFTGLAccountMapping."Mapping Type" := SAFTMapping."Mapping Type";
                SAFTGLAccountMapping."Category No." := SAFTMapping."Category No.";
                SAFTGLAccountMapping."G/L Account No." := GLAccount."No.";
                SAFTGLAccountMapping."Mapping Range Code" := SAFTMappingRange.Code;
                SAFTGLAccountMapping."No." := SAFTMapping."No.";
                if not SAFTGLAccountMapping.insert() then
                    SAFTGLAccountMapping.Modify();
                MatchedCount += 1;
            end;
        until SAFTMapping.Next() = 0;
        if GuiAllowed() then begin
            GLAccount.SetRange("Account Type", GLAccount."Account Type"::Posting);
            Message(StandardAccountsMatchedMsg, MatchedCount, GLAccount.Count());
        end;
    end;

    procedure CopyMapping(FromMappingRangeCode: Code[20]; ToMappingRangeCode: Code[20]; Replace: Boolean)
    var
        FromMappingRange: Record "SAF-T Mapping Range";
        ToMappingRange: Record "SAF-T Mapping Range";
        FromSAFTGLAccountMapping: Record "SAF-T G/L Account Mapping";
        ToSAFTGLAccountMapping: Record "SAF-T G/L Account Mapping";
    begin
        FromMappingRange.Get(FromMappingRangeCode);
        ToMappingRange.Get(ToMappingRangeCode);
        if FromMappingRange."Mapping Type" <> ToMappingRange."Mapping Type" then
            error(DifferentMappingTypeErr);

        FromSAFTGLAccountMapping.SetRange("Mapping Range Code", FromMappingRangeCode);
        if not FromSAFTGLAccountMapping.FindSet() then
            error(NoGLAccountMappingErr, FromMappingRangeCode);
        repeat
            ToSAFTGLAccountMapping := FromSAFTGLAccountMapping;
            ToSAFTGLAccountMapping."Mapping Range Code" := ToMappingRangeCode;
            if not ToSAFTGLAccountMapping.Insert() then
                if Replace then
                    ToSAFTGLAccountMapping.Modify()
                else
                    error(MappingExistsErr, ToSAFTGLAccountMapping."Category No.", ToSAFTGLAccountMapping."No.", ToSAFTGLAccountMapping."Mapping Range Code");
        until FromSAFTGLAccountMapping.Next() = 0;

    end;

    local procedure SetupGLAccountsForMapping(SAFTMappingRange: Record "SAF-T Mapping Range")
    var
        GLAccount: Record "G/L Account";
        SAFTGLAccountMapping: Record "SAF-T G/L Account Mapping";
        Window: Dialog;
    begin
        SAFTMappingRange.TestField("Mapping Type");
        SAFTMappingRange.TestField("Starting Date");
        SAFTMappingRange.TestField("Ending Date");
        if GuiAllowed() then
            Window.Open(PreparingSourceForMappingLbl);
        GetGLAccountForMapping(GLAccount);
        repeat
            SAFTGLAccountMapping.Init();
            SAFTGLAccountMapping."Mapping Range Code" := SAFTMappingRange.Code;
            SAFTGLAccountMapping."Mapping Type" := SAFTMappingRange."Mapping Type";
            SAFTGLAccountMapping."G/L Account No." := GLAccount."No.";
            SAFTGLAccountMapping."G/L Entries Exists" :=
                GLAccNetChangeIsNotZero(GLAccount, SAFTMappingRange."Starting Date", SAFTMappingRange."Ending Date",
                SAFTMappingRange."Include Incoming Balance");
            if not SAFTGLAccountMapping.find() then
                SAFTGLAccountMapping.insert();
        until GLAccount.next() = 0;
        if GuiAllowed() then
            Window.Close();
    end;

    local procedure GetGLAccountForMapping(var GLAccount: Record "G/L Account")
    begin
        GLAccount.SetRange("Account Type", GLAccount."Account Type"::Posting);
        if not GLAccount.FindSet() then
            error(ChartOfAccountsDoesNotExistErr);
    end;

    procedure UpdateGLEntriesExistStateForGLAccMapping(MappingRangeCode: Code[20])
    var
        SAFTMappingRange: Record "SAF-T Mapping Range";
        SAFTGLAccountMapping: Record "SAF-T G/L Account Mapping";
    begin
        if MappingRangeCode = '' then
            exit;
        if not SAFTMappingRange.get(MappingRangeCode) then
            exit;
        SAFTGLAccountMapping.SetRange("Mapping Range Code", SAFTMappingRange.Code);
        if SAFTGLAccountMapping.FindSet() then
            repeat
                SAFTGLAccountMapping.Validate("G/L Entries Exists",
                    GLAccHasEntries(
                        SAFTGLAccountMapping."G/L Account No.", SAFTMappingRange."Starting Date",
                        SAFTMappingRange."Ending Date", SAFTMappingRange."Include Incoming Balance"));
                SAFTGLAccountMapping.Modify(true);
            until SAFTGLAccountMapping.Next() = 0;
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

    procedure UpdateMasterDataWithNoSeries()
    var
        SAFTSetup: Record "SAF-T Setup";
        Dimension: Record Dimension;
        VATPostingSetup: Record "VAT Posting Setup";
    begin
        SAFTSetup.Get();
        Dimension.SetRange("SAF-T Analysis Type", '');
        if Dimension.FindSet() then
            repeat
                Dimension.UpdateSAFTAnalysisTypeFromNoSeries();
                Dimension.Validate("Export to SAF-T", true);
                Dimension.Modify(true);
            until Dimension.Next() = 0;

        VATPostingSetup.SetRange("Purchase SAF-T Tax Code", 0);
        if VATPostingSetup.FindSet() then
            repeat
                VATPostingSetup.AssignSAFTTaxCodes();
                VATPostingSetup.Modify(true);
            until VATPostingSetup.Next() = 0;
    end;

    procedure UpdateSAFTSourceCodesBySetup()
    var
        TempNameValueBuffer: Record "Name/Value Buffer" temporary;
        SourceCodeSetup: Record "Source Code Setup";
    begin
        InsertTempNameValueBuffer(TempNameValueBuffer, SourceCodeSetup.FieldNo("General Journal"), GetGLSAFTSourceCode());
        InsertTempNameValueBuffer(TempNameValueBuffer, SourceCodeSetup.FieldNo("IC General Journal"), GetGLSAFTSourceCode());
        InsertTempNameValueBuffer(TempNameValueBuffer, SourceCodeSetup.FieldNo("Close Income Statement"), GetGLSAFTSourceCode());
        InsertTempNameValueBuffer(TempNameValueBuffer, SourceCodeSetup.FieldNo("VAT Settlement"), GetGLSAFTSourceCode());
        InsertTempNameValueBuffer(TempNameValueBuffer, SourceCodeSetup.FieldNo("Exchange Rate Adjmt."), GetGLSAFTSourceCode());
        InsertTempNameValueBuffer(TempNameValueBuffer, SourceCodeSetup.FieldNo("Deleted Document"), GetGLSAFTSourceCode());
        InsertTempNameValueBuffer(TempNameValueBuffer, SourceCodeSetup.FieldNo("Adjust Add. Reporting Currency"), GetGLSAFTSourceCode());
        InsertTempNameValueBuffer(TempNameValueBuffer, SourceCodeSetup.FieldNo("Compress G/L"), GetGLSAFTSourceCode());
        InsertTempNameValueBuffer(TempNameValueBuffer, SourceCodeSetup.FieldNo("Compress VAT Entries"), GetGLSAFTSourceCode());
        InsertTempNameValueBuffer(TempNameValueBuffer, SourceCodeSetup.FieldNo("Compress Bank Acc. Ledger"), GetGLSAFTSourceCode());
        InsertTempNameValueBuffer(TempNameValueBuffer, SourceCodeSetup.FieldNo("Compress Check Ledger"), GetGLSAFTSourceCode());
        InsertTempNameValueBuffer(TempNameValueBuffer, SourceCodeSetup.FieldNo("Financially Voided Check"), GetGLSAFTSourceCode());
        InsertTempNameValueBuffer(TempNameValueBuffer, SourceCodeSetup.FieldNo("Trans. Bank Rec. to Gen. Jnl."), GetGLSAFTSourceCode());
        InsertTempNameValueBuffer(TempNameValueBuffer, SourceCodeSetup.FieldNo("Reversal"), GetGLSAFTSourceCode());
        InsertTempNameValueBuffer(TempNameValueBuffer, SourceCodeSetup.FieldNo("Cash Flow Worksheet"), GetGLSAFTSourceCode());
        InsertTempNameValueBuffer(TempNameValueBuffer, SourceCodeSetup.FieldNo("Payment Reconciliation Journal"), GetGLSAFTSourceCode());

        InsertTempNameValueBuffer(TempNameValueBuffer, SourceCodeSetup.FieldNo("Sales"), GetARSAFTSourceCode());
        InsertTempNameValueBuffer(TempNameValueBuffer, SourceCodeSetup.FieldNo("Sales Journal"), GetARSAFTSourceCode());
        InsertTempNameValueBuffer(TempNameValueBuffer, SourceCodeSetup.FieldNo("Cash Receipt Journal"), GetARSAFTSourceCode());
        InsertTempNameValueBuffer(TempNameValueBuffer, SourceCodeSetup.FieldNo("Sales Entry Application"), GetARSAFTSourceCode());
        InsertTempNameValueBuffer(TempNameValueBuffer, SourceCodeSetup.FieldNo("Unapplied Sales Entry Appln."), GetARSAFTSourceCode());
        InsertTempNameValueBuffer(TempNameValueBuffer, SourceCodeSetup.FieldNo("Reminder"), GetARSAFTSourceCode());
        InsertTempNameValueBuffer(TempNameValueBuffer, SourceCodeSetup.FieldNo("Finance Charge Memo"), GetARSAFTSourceCode());
        InsertTempNameValueBuffer(TempNameValueBuffer, SourceCodeSetup.FieldNo("Compress Cust. Ledger"), GetARSAFTSourceCode());
        InsertTempNameValueBuffer(TempNameValueBuffer, SourceCodeSetup.FieldNo("Service Management"), GetARSAFTSourceCode());

        InsertTempNameValueBuffer(TempNameValueBuffer, SourceCodeSetup.FieldNo("Purchases"), GetAPSAFTSourceCode());
        InsertTempNameValueBuffer(TempNameValueBuffer, SourceCodeSetup.FieldNo("Purchase Journal"), GetAPSAFTSourceCode());
        InsertTempNameValueBuffer(TempNameValueBuffer, SourceCodeSetup.FieldNo("Payment Journal"), GetAPSAFTSourceCode());
        InsertTempNameValueBuffer(TempNameValueBuffer, SourceCodeSetup.FieldNo("Purchase Entry Application"), GetAPSAFTSourceCode());
        InsertTempNameValueBuffer(TempNameValueBuffer, SourceCodeSetup.FieldNo("Unapplied Purch. Entry Appln."), GetAPSAFTSourceCode());
        InsertTempNameValueBuffer(TempNameValueBuffer, SourceCodeSetup.FieldNo("Compress Vend. Ledger"), GetAPSAFTSourceCode());
        SetRestFieldsOfSourceCodeSetupToAssortedJournals(TempNameValueBuffer);
        OnCollectSourceCodeFieldsForSAFTMapping(TempNameValueBuffer);
        MapSourceCodeToSAFTSourceCodeFromBuffer(TempNameValueBuffer);
        MapRestSourceCodesToAssortedJournals();
    end;

    local procedure SetRestFieldsOfSourceCodeSetupToAssortedJournals(var TempNameValueBuffer: Record "Name/Value Buffer" temporary)
    var
        RecRef: RecordRef;
        PrimaryKeyFieldRef: FieldRef;
        FieldRef: FieldRef;
        KeyRef: KeyRef;
        i: Integer;
    begin
        RecRef.Open(Database::"Source Code Setup");
        KeyRef := RecRef.KeyIndex(1);
        PrimaryKeyFieldRef := KeyRef.FieldIndex(1);
        for i := 1 to RecRef.FieldCount() do begin
            FieldRef := RecRef.FieldIndex(i);
            if FieldRef.Number() <> PrimaryKeyFieldRef.Number() then
                if not TempNameValueBuffer.Get(FieldRef.Number()) then
                    InsertTempNameValueBuffer(TempNameValueBuffer, FieldRef.Number(), GetASAFTSourceCode());
        end;
    end;

    local procedure MapSourceCodeToSAFTSourceCodeFromBuffer(var TempNameValueBuffer: Record "Name/Value Buffer" temporary)
    var
        SourceCode: Record "Source Code";
        SourceCodeSetup: Record "Source Code Setup";
        RecRef: RecordRef;
        FieldRef: FieldRef;
    begin
        if not TempNameValueBuffer.FindSet() then
            exit;

        if not SourceCodeSetup.Get() then
            exit;

        RecRef.GetTable(SourceCodeSetup);
        repeat
            FieldRef := RecRef.Field(TempNameValueBuffer.ID);
            if Format(FieldRef.Value()) <> '' then
                if SourceCode.Get(FieldRef.Value()) then begin
                    SourceCode.Validate("SAF-T Source Code", TempNameValueBuffer.Name);
                    SourceCode.Modify(true);
                end;
        until TempNameValueBuffer.Next() = 0;
    end;

    procedure MapRestSourceCodesToAssortedJournals()
    var
        SourceCode: Record "Source Code";
    begin
        SourceCode.SetRange("SAF-T Source Code", '');
        if SourceCode.FindSet() then
            repeat
                SourceCode.Validate("SAF-T Source Code", GetASAFTSourceCode());
                SourceCode.Modify(true);
            until SourceCode.Next() = 0;
    end;

    procedure GetGLSAFTSourceCode(): Code[9]
    begin
        exit('GL');
    end;

    procedure GetARSAFTSourceCode(): Code[9]
    begin
        exit('AR');
    end;

    procedure GetAPSAFTSourceCode(): Code[9]
    begin
        exit('AP');
    end;

    procedure GetASAFTSourceCode(): Code[9]
    begin
        exit('A');
    end;

    procedure GetASAFTSourceCodeDescription(): Text[100]
    begin
        exit(AssortedJournalsSourceCodeDescriptionLbl);
    end;

    local procedure InsertTempNameValueBuffer(var TempNameValueBuffer: Record "Name/Value Buffer" temporary; ID: Integer; Name: Text[250])
    begin
        TempNameValueBuffer.ID := ID;
        TempNameValueBuffer.Name := Name;
        if not TempNameValueBuffer.Insert() then
            TempNameValueBuffer.Modify(); // make it possible to overwrite by subscriber
    end;

    procedure VerifyMappingIsDone(MappingRangeCode: Code[20])
    var
        SAFTGLAccountMapping: Record "SAF-T G/L Account Mapping";
        SAFTMappingRange: Record "SAF-T Mapping Range";
        SAFTMappingHelper: Codeunit "SAF-T Mapping Helper";
    begin
        SAFTMappingHelper.UpdateGLEntriesExistStateForGLAccMapping(MappingRangeCode);
        SAFTGLAccountMapping.SetRange("Mapping Range Code", MappingRangeCode);
        SAFTGLAccountMapping.SetRange("No.", '');
        if not SAFTGLAccountMapping.IsEmpty() then begin
            SAFTMappingRange.Get(MappingRangeCode);
            LogError(SAFTMappingRange, MappingNotDoneErr);
        end;
    end;

    procedure VerifyNoMappingDone(SAFTMappingRange: Record "SAF-T Mapping Range")
    var
        SAFTGLAccountMapping: Record "SAF-T G/L Account Mapping";
    begin
        SAFTGLAccountMapping.SetRange("Mapping Range Code", SAFTMappingRange.Code);
        SAFTGLAccountMapping.SetFilter("No.", '<>%1', '');
        if not SAFTGLAccountMapping.IsEmpty() then
            error(MappingDoneErr);
    end;

    procedure VerifyDimensionsHaveAnalysisCode()
    var
        Dimension: Record Dimension;
    begin
        if Dimension.IsEmpty() then
            exit;
        Dimension.SetRange("SAF-T Analysis Type", '');
        if not Dimension.IsEmpty() then
            LogError(Dimension, DimensionWithoutAnalysisCodeErr);
    end;

    procedure VerifyVATPostingSetupHasTaxCodes()
    var
        VATPostingSetup: Record "VAT Posting Setup";
    begin
        if not VATPostingSetup.FindSet() then
            exit;
        VATPostingSetup.SetRange("Sales SAF-T Tax Code", 0);
        if not VATPostingSetup.IsEmpty() then
            LogFieldError(
                VATPostingSetup, VATPostingSetup.FieldNo("Sales SAF-T Tax Code"),
                strsubstno(VATPostingSetupWithoutTaxCodeErr, VATPostingSetup.FieldCaption("Sales SAF-T Tax Code")));
        VATPostingSetup.SetRange("Sales SAF-T Tax Code");

        VATPostingSetup.SetRange("Purchase SAF-T Tax Code", 0);
        if not VATPostingSetup.IsEmpty() then
            LogFieldError(
                VATPostingSetup, VATPostingSetup.FieldNo("Purchase SAF-T Tax Code"),
                strsubstno(VATPostingSetupWithoutTaxCodeErr, VATPostingSetup.FieldCaption("Purchase SAF-T Tax Code")));
        VATPostingSetup.SetRange("Purchase SAF-T Tax Code");
    end;

    procedure VerifySourceCodesHasSAFTCodes()
    var
        SourceCode: Record "Source Code";
    begin
        SourceCode.SetRange("SAF-T Source Code", '');
        if not SourceCode.IsEmpty() then
            LogError(SourceCode, SourceCodeWithoutSAFTCodeErr);
    end;

    procedure GetGLAccountsMappedInfo(MappingRangeCode: Code[20]): Text[20]
    var
        SAFTGLAccountMapping: Record "SAF-T G/L Account Mapping";
        TotalCount: Integer;
    begin
        SAFTGLAccountMapping.SetRange("Mapping Range Code", MappingRangeCode);
        TotalCount := SAFTGLAccountMapping.Count();
        SAFTGLAccountMapping.SetFilter("No.", '<>%1', '');
        exit(StrSubstNo('%1/%2', SAFTGLAccountMapping.Count(), TotalCount));
    end;

    procedure GetVATPostingSetupMappedInfo(): Text[20]
    var
        VATPostingSetup: Record "VAT Posting Setup";
        TotalCount: Integer;
        Count: Integer;
    begin
        TotalCount := VATPostingSetup.Count();
        if VATPostingSetup.FindSet() then
            repeat
                if (VATPostingSetup."Sale VAT Reporting Code" <> '') or (VATPostingSetup."Purch. VAT Reporting Code" <> '') then
                    Count += 1;
            until VATPostingSetup.Next() = 0;
        exit(StrSubstNo('%1/%2', Count, TotalCount));
    end;

    local procedure LogError(SourceVariant: Variant; ErrorMessage: Text)
    var
        ErrorMessageManagement: Codeunit "Error Message Management";
    begin
        if not GuiAllowed() then
            Error(ErrorMessage);
        ErrorMessageManagement.LogError(SourceVariant, ErrorMessage, '');
    end;

    local procedure LogFieldError(SourceVariant: Variant; SourceFieldNo: Integer; ErrorMessage: Text)
    var
        ErrorMessageManagement: Codeunit "Error Message Management";
    begin
        if not GuiAllowed() then
            Error(ErrorMessage);
        ErrorMessageManagement.LogContextFieldError(0, ErrorMessage, SourceVariant, SourceFieldNo, '');
    end;

#if not CLEAN24
    [Obsolete('The procedure is not used will be removed', '24.0')]
    procedure AddSAFTAssistedSetup()
    var
        GuidedExperience: Codeunit "Guided Experience";
    begin
        GuidedExperience.InsertAssistedSetup(
            CopyStr(SAFTSetupGuideTxt, 1, 2048),
            CopyStr(SAFTSetupGuideTxt, 1, 50),
            '',
            1,
            ObjectType::Page,
            PAGE::"SAF-T Setup Wizard",
            "Assisted Setup Group"::GettingStarted,
            '',
            "Video Category"::Uncategorized,
            ''
        );
    end;
#endif

    procedure InsertDefaultNoSeriesInSAFTSetup()
    var
        SAFTSetup: Record "SAF-T Setup";
    begin
        if not SAFTSetup.Get() then begin
            SAFTSetup.Init();
            SAFTSetup.Insert();
        end;
        SAFTSetup.Modify();
    end;

    procedure InsertSAFTSourceCodes()
    var
        SAFTMappingHelper: Codeunit "SAF-T Mapping Helper";
    begin
        InsertSAFTSourceCode(SAFTMappingHelper.GetGLSAFTSourceCode(), GeneralLedgerJournalsSourceCodeDescriptionLbl);
        InsertSAFTSourceCode(SAFTMappingHelper.GetARSAFTSourceCode(), AccountReceivablesSourceCodeDescriptionLbl);
        InsertSAFTSourceCode(SAFTMappingHelper.GetAPSAFTSourceCode(), AccountPayablesSourceCodeDescriptionLbl);
        InsertSAFTSourceCode(SAFTMappingHelper.GetASAFTSourceCode(), SAFTMappingHelper.GetASAFTSourceCodeDescription());
    end;

    local procedure InsertSAFTSourceCode(Code: Code[9]; Description: Text[100])
    var
        SAFTSourceCode: Record "SAF-T Source Code";
    begin
        SAFTSourceCode.Validate(Code, Code);
        if SAFTSourceCode.Find() then
            exit;
        SAFTSourceCode.Validate(Description, Description);
        SAFTSourceCode.Insert(true);
    end;

    [EventSubscriber(ObjectType::Table, Database::"Dimension", 'OnBeforeInsertEvent', '', false, false)]
    local procedure UpdateSAFAnalysisTypeOnBeforeDimensionInsert(var Rec: Record "Dimension"; RunTrigger: Boolean)
    begin
        if Rec.IsTemporary() then
            exit;
        Rec.UpdateSAFTAnalysisTypeFromNoSeries();
    end;

    [EventSubscriber(ObjectType::Table, Database::"VAT Posting Setup", 'OnBeforeInsertEvent', '', false, false)]
    local procedure AssignSAFTaxCodesOnBeforeDimensionInsert(var Rec: Record "VAT Posting Setup"; RunTrigger: Boolean)
    begin
        if Rec.IsTemporary() then
            exit;
        Rec.AssignSAFTTaxCodes();
    end;

    [IntegrationEvent(false, false)]
    local procedure OnCollectSourceCodeFieldsForSAFTMapping(var TempNameValueBuffer: Record "Name/Value Buffer" temporary)
    begin
    end;
}
