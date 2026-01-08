// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------

namespace Microsoft.DemoData.FixedAsset;

using Microsoft.DemoData.Finance;
using Microsoft.DemoTool.Helpers;
using Microsoft.Finance.GeneralLedger.Journal;
using Microsoft.FixedAssets.Depreciation;
using Microsoft.FixedAssets.Journal;

codeunit 5609 "Create FA Jnl. Lines"
{
    InherentEntitlements = X;
    InherentPermissions = X;
    EventSubscriberInstance = Manual;

    trigger OnRun()
    var
        ContosoFixedAsset: Codeunit "Contoso Fixed Asset";
        ContosoUtilities: Codeunit "Contoso Utilities";
        CreateFAJnlTemplate: Codeunit "Create FA Jnl. Template";
        CreateFANoSeries: Codeunit "Create FA No Series";
        CreateFixedAsset: Codeunit "Create Fixed Asset";
        CreateGLAccount: Codeunit "Create G/L Account";
        FAJournalBatchName: Code[10];
        FAJournalTemplateName: Code[10];
    begin
        FAJournalTemplateName := CreateFAJnlTemplate.Assets();
        FAJournalBatchName := CreateFAJnlTemplate.Default();

        InsertFAGenJournalLine(FAJournalTemplateName, FAJournalBatchName, 10000, CreateFixedAsset.FA000010(), ContosoUtilities.AdjustDate(19010101D), Enum::"Gen. Journal Line FA Posting Type"::"Acquisition Cost", AssetAcquisitionLbl, AcquisitionLbl, Enum::"Gen. Journal Account Type"::"G/L Account", CreateGLAccount.Cash(), 65000);
        InsertFAGenJournalLine(FAJournalTemplateName, FAJournalBatchName, 20000, CreateFixedAsset.FA000020(), ContosoUtilities.AdjustDate(19010101D), Enum::"Gen. Journal Line FA Posting Type"::"Acquisition Cost", AssetAcquisitionLbl, AcquisitionLbl, Enum::"Gen. Journal Account Type"::"G/L Account", CreateGLAccount.Cash(), 70000);
        InsertFAGenJournalLine(FAJournalTemplateName, FAJournalBatchName, 30000, CreateFixedAsset.FA000030(), ContosoUtilities.AdjustDate(19010101D), Enum::"Gen. Journal Line FA Posting Type"::"Acquisition Cost", AssetAcquisitionLbl, AcquisitionLbl, Enum::"Gen. Journal Account Type"::"G/L Account", CreateGLAccount.Cash(), 95000);
        InsertFAGenJournalLine(FAJournalTemplateName, FAJournalBatchName, 40000, CreateFixedAsset.FA000050(), ContosoUtilities.AdjustDate(19010101D), Enum::"Gen. Journal Line FA Posting Type"::"Acquisition Cost", AssetAcquisitionLbl, AcquisitionLbl, Enum::"Gen. Journal Account Type"::"G/L Account", CreateGLAccount.Cash(), 15000);
        InsertFAGenJournalLine(FAJournalTemplateName, FAJournalBatchName, 50000, CreateFixedAsset.FA000060(), ContosoUtilities.AdjustDate(19010101D), Enum::"Gen. Journal Line FA Posting Type"::"Acquisition Cost", AssetAcquisitionLbl, AcquisitionLbl, Enum::"Gen. Journal Account Type"::"G/L Account", CreateGLAccount.Cash(), 60000);
        InsertFAGenJournalLine(FAJournalTemplateName, FAJournalBatchName, 60000, CreateFixedAsset.FA000070(), ContosoUtilities.AdjustDate(19010101D), Enum::"Gen. Journal Line FA Posting Type"::"Acquisition Cost", AssetAcquisitionLbl, AcquisitionLbl, Enum::"Gen. Journal Account Type"::"G/L Account", CreateGLAccount.Cash(), 1500);
        InsertFAGenJournalLine(FAJournalTemplateName, FAJournalBatchName, 70000, CreateFixedAsset.FA000080(), ContosoUtilities.AdjustDate(19010101D), Enum::"Gen. Journal Line FA Posting Type"::"Acquisition Cost", AssetAcquisitionLbl, AcquisitionLbl, Enum::"Gen. Journal Account Type"::"G/L Account", CreateGLAccount.Cash(), 11000);
        InsertFAGenJournalLine(FAJournalTemplateName, FAJournalBatchName, 80000, CreateFixedAsset.FA000090(), ContosoUtilities.AdjustDate(19010101D), Enum::"Gen. Journal Line FA Posting Type"::"Acquisition Cost", AssetAcquisitionLbl, AcquisitionLbl, Enum::"Gen. Journal Account Type"::"G/L Account", CreateGLAccount.Cash(), 4000);
        Codeunit.Run(Codeunit::"Post FA Jnl. Lines");

        CalculateDepreciationLines(ContosoUtilities.AdjustDate(19011231D), 1);
        CalculateDepreciationLines(ContosoUtilities.AdjustDate(19021231D), 2);
        Codeunit.Run(Codeunit::"Post FA Jnl. Lines");
    end;

    procedure InsertFAGenJournalLine(JournalTemplateName: Code[10]; JournalBatchName: Code[10]; LineNo: Integer; AccountNo: Code[20]; PostingDate: Date; FAPostingType: Enum "Gen. Journal Line FA Posting Type"; DocumentNo: Code[20]; Description: Text[100]; BalAccountType: Enum "Gen. Journal Account Type"; BalAccountNo: Code[20]; Amount: Decimal)
    var
        GenJournalLine: Record "Gen. Journal Line";
    begin
        GenJournalLine.Validate("Journal Template Name", JournalTemplateName);
        GenJournalLine.Validate("Journal Batch Name", JournalBatchName);
        GenJournalLine.Validate("Line No.", LineNo);
        GenJournalLine.Validate("Account Type", Enum::"Gen. Journal Account Type"::"Fixed Asset");
        GenJournalLine.Validate("Account No.", AccountNo);
        GenJournalLine.Validate("Posting Date", PostingDate);
        GenJournalLine.Validate("FA Posting Type", FAPostingType);
        GenJournalLine.Validate("Document No.", DocumentNo);
        GenJournalLine.Validate(Description, Description);
        GenJournalLine.Validate("Bal. Account Type", BalAccountType);
        GenJournalLine.Validate("Bal. Account No.", BalAccountNo);
        GenJournalLine.Validate(Amount, Amount);
        GenJournalLine.Insert(true);
    end;

    local procedure CalculateDepreciationLines(PostingDate: Date; BatchCount: Integer)
    var
        CalculateDepreciation: Report "Calculate Depreciation";
        CreateFADepreciationBook: Codeunit "Create FA Depreciation Book";
    begin
        CalculateDepreciation.InitializeRequest(CreateFADepreciationBook.Company(), PostingDate, false, 0, PostingDate, StrSubstNo('%1%2', AssetDepreciationLbl, BatchCount), DepreciationLbl, true);
        CalculateDepreciation.UseRequestPage(false);
        BindSubscription(this);
        CalculateDepreciation.Run();
        UnbindSubscription(this);
    end;

    [EventSubscriber(ObjectType::Report, Report::"Calculate Depreciation", OnPostReportOnBeforeConfirmShowGenJournalLines, '', true, true)]
    local procedure ConfirmShowGenJournalLines(DeprBook: Record "Depreciation Book"; GenJnlLine: Record "Gen. Journal Line"; GenJnlLineCreatedCount: Integer; var IsHandled: Boolean)
    begin
        IsHandled := true;
    end;

    var
        AcquisitionLbl: Label 'Acquisition', MaxLength = 100;
        AssetAcquisitionLbl: Label 'ASSET-ACQ', MaxLength = 20;
        AssetDepreciationLbl: Label 'ASSET-DEPR', MaxLength = 20;
        DepreciationLbl: Label 'Depreciation', MaxLength = 100;
}