#pragma warning disable AL0432
codeunit 148060 "VAT Statements CZL"
{
    Subtype = Test;
    TestPermissions = Disabled;

    trigger OnRun()
    begin
        // [FEATURE] [Core] [VAT Statement]
        isInitialized := false;
    end;

    var
        LibraryERM: Codeunit "Library - ERM";
        LibraryRandom: Codeunit "Library - Random";
        LibraryReportDataset: Codeunit "Library - Report Dataset";
        LibraryVariableStorage: Codeunit "Library - Variable Storage";
        Assert: Codeunit Assert;
        LibraryTaxCZL: Codeunit "Library - Tax CZL";
        XMLFormat: Enum "VAT Statement XML Format CZL";
        isInitialized: Boolean;

    local procedure Initialize()
    var
        LibraryTestInitialize: Codeunit "Library - Test Initialize";
    begin
        LibraryTestInitialize.OnTestInitialize(Codeunit::"VAT Statements CZL");
        LibraryRandom.Init();
        LibraryTaxCZL.SetUseVATDate(true);
        if isInitialized then
            exit;
        LibraryTestInitialize.OnBeforeTestSuiteInitialize(Codeunit::"VAT Statements CZL");

        isInitialized := true;
        // Commit();  because TransactionModel::AutoRollback
        LibraryTestInitialize.OnAfterTestSuiteInitialize(Codeunit::"VAT Statements CZL");
    end;

    [Test]
    [HandlerFunctions('VATStatementTemplateListModalPageHandler')]
    [TransactionModel(TransactionModel::AutoRollback)]
    procedure VATStatementPreviewVATDate()
    var
        VATStatementName: Record "VAT Statement Name";
        VATStatementLine: Record "VAT Statement Line";
        VATPeriodCZL: Record "VAT Period CZL";
        VATStatementPreviewCZL: TestPage "VAT Statement Preview CZL";
        VATStatement: TestPage "VAT Statement";
        VATEntries: TestPage "VAT Entries";
        StartingDate: Date;
        EndingDate: Date;
    begin
        // [SCENARIO] Page 'VAT Entries' opened from VAT Statement Preview respect the Date Filter in VAT Statement
        Initialize();

        // [GIVEN] "VAT Statement Name" and "VAT Statement Line" with Type = "VAT Entry Totaling" has been created
        LibraryERM.CreateVATStatementNameWithTemplate(VATStatementName);
        LibraryERM.CreateVATStatementLine(VATStatementLine, VATStatementName."Statement Template Name", VATStatementName.Name);
        VATStatementLine.Validate(Type, VATStatementLine.Type::"VAT Entry Totaling");
        VATStatementLine.Validate("Amount Type", VATStatementLine."Amount Type"::Amount);
        VATStatementLine.Modify(true);
        LibraryVariableStorage.Enqueue(VATStatementName."Statement Template Name");

        // [GIVEN] Page VAT Statement Preview for created line has been opened
        VATStatement.OpenEdit();
        VATStatement.Filter.SetFilter("Statement Template Name", VATStatementLine."Statement Template Name");
        VATStatement.Filter.SetFilter("Statement Name", VATStatementLine."Statement Name");
        VATStatement.First();
        VATStatementPreviewCZL.Trap();
        VATStatement."P&review CZL".Invoke();

        // [GIVEN] Dates has been set
        LibraryTaxCZL.FindFirstOpenVATPeriod(VATPeriodCZL);
        StartingDate := VATPeriodCZL."Starting Date";
        EndingDate := CalcDate('<+1M-1D>', StartingDate);
        VATStatementPreviewCZL.VATPeriodStartDate.SetValue(StartingDate);
        VATStatementPreviewCZL.VATPeriodEndDate.SetValue(EndingDate);
        VATStatementPreviewCZL.PeriodSelection.SetValue("VAT Statement Report Period Selection"::"Within Period");
        VATEntries.Trap();

        // [WHEN] DrillDown to ColumnValue
        VATStatementPreviewCZL.VATStatementLineSubForm.ColumnValue.Drilldown();

        // [THEN] Page "VAT Entries" will be opened with filter to VAT Date
#if not CLEAN22
#pragma warning disable AL0432
        Assert.AreEqual(VATEntries.Filter.GetFilter("VAT Date CZL"), StrSubstNo('%1..%2', StartingDate, EndingDate), '');
#pragma warning restore AL0432
#else
        Assert.AreEqual(VATEntries.Filter.GetFilter("VAT Reporting Date"), StrSubstNo('%1..%2', StartingDate, EndingDate), '');
#endif
        VATEntries.Close();
        VATStatement.Close();
        VATStatementPreviewCZL.Close();
    end;

    [ModalPageHandler]
    procedure VATStatementTemplateListModalPageHandler(var VATStatementTemplateList: TestPage "VAT Statement Template List")
    begin
        VATStatementTemplateList.Filter.SetFilter(Name, LibraryVariableStorage.DequeueText());
        VATStatementTemplateList.OK().Invoke();
    end;

    [Test]
    [HandlerFunctions('CalcAndPostVATSettlCZLRequestPageHandler,VATStatementCZLRequestPageHandler,ConfirmYesHandler')]
    [TransactionModel(TransactionModel::AutoRollback)]
    procedure VATStatementDPHDP3Print()
    var
        VATStatementTemplate: Record "VAT Statement Template";
        VATStatementLine: Record "VAT Statement Line";
        VATStatementName: Record "VAT Statement Name";
        StartingDate: Date;
        EndingDate: Date;
        DocumentNo: Code[20];
        GLAccountNo: Code[20];
        RowNo: Code[10];
        TotalAmount: Decimal;
    begin
        // [SCENARIO] Using existing demo data, post the VAT settlement and print the VAT Statement filtered for VAT Settlement Document No.
        Initialize();

        // [GIVEN] VAT Statement has been select
        FindVATStatementTemplate(VATStatementTemplate, XMLFormat::DPHDP3);
        LibraryTaxCZL.SelectVATStatementName(VATStatementName, VATStatementTemplate.Name);

        // [GIVEN] Starting Date and Ending Date have been calculated as first open VAT Period
        StartingDate := LibraryTaxCZL.GetVATPeriodStartingDate();
        EndingDate := CalcDate('<+1M-1D>', StartingDate);

        // [GIVEN] Account No. and Settlement No. have been created
        DocumentNo := GetSettlementNo(StartingDate);
        GLAccountNo := LibraryERM.CreateGLAccountNo();

        // [GIVEN] VAT Settlement has been posted in given VAT Period
        RunCalcAndPostVATSettlCZL(StartingDate, EndingDate, DocumentNo, GLAccountNo);

        // [GIVEN] VAT statement line row number and expected amount needed have been collected 
        FindFirstPrintableVATStatementTotalLine(VATStatementLine, VATStatementTemplate.Name, VATStatementName.Name);
        RowNo := VATStatementLine."Row No.";
        SelectVATStatementRowTotalingLines(VATStatementLine, VATStatementTemplate.Name, VATStatementName.Name, VATStatementLine."Row Totaling");
        CalcExpectedSettlementTotalAmount(VATStatementLine, DocumentNo, TotalAmount);

        // [WHEN] Print VAT Statement
        PrintVATStatement(VATStatementName, StartingDate, Endingdate, DocumentNo);

        // [THEN] Report dataset will have VAT Statement Line matching RowNo with expected TotalAmount
        LibraryReportDataset.LoadDataSetFile();
        LibraryReportDataset.MoveToRow(LibraryReportDataset.FindRow('VatStmtLineRowNo', RowNo) + 1);
        LibraryReportDataset.AssertCurrentRowValueEquals('TotalAmount', TotalAmount);
    end;

    [Test]
    [HandlerFunctions('CalcAndPostVATSettlCZLRequestPageHandler,ExportVATStmtDialogRequestPageHandler,ConfirmYesHandler')]
    [TransactionModel(TransactionModel::AutoRollback)]
    procedure VATStatementDPHDP3Export()
    var
        VATStatementTemplate: Record "VAT Statement Template";
        VATStatementName: Record "VAT Statement Name";
        TempBlob: Codeunit "Temp Blob";
        StartingDate: Date;
        EndingDate: Date;
        DocumentNo: Code[20];
        GLAccountNo: Code[20];
        InStream: InStream;
        XMLDoc: XmlDocument;
    begin
        // [SCENARIO] Using existing demo data, post the VAT settlement and export the VAT Statement filtered for VAT Settlement Document No.
        Initialize();

        // [GIVEN] VAT Statement has been select
        FindVATStatementTemplate(VATStatementTemplate, XMLFormat::DPHDP3);
        LibraryTaxCZL.SelectVATStatementName(VATStatementName, VATStatementTemplate.Name);

        // [GIVEN] Starting Date and Ending Date have been calculated as first open VAT Period
        StartingDate := LibraryTaxCZL.GetVATPeriodStartingDate();
        EndingDate := CalcDate('<+1M-1D>', StartingDate);

        // [GIVEN] Account No. and Settlement No. have been created
        DocumentNo := GetSettlementNo(StartingDate);
        GLAccountNo := LibraryERM.CreateGLAccountNo();

        // [GIVEN] VAT Settlement has been posted in given VAT Period
        RunCalcAndPostVATSettlCZL(StartingDate, EndingDate, DocumentNo, GLAccountNo);

        // [WHEN] Export VAT Statement
        RunExportVATStatement(VATStatementTemplate.Name, VATStatementName.Name, StartingDate, EndingDate, DocumentNo, TempBlob);

        // [THEN] Exported XML document will have correct structure
        TempBlob.CreateInStream(InStream);
        XMLDocument.ReadFrom(InStream, XMLDoc);
        AssertXmlDocNodeExist(XMLDoc, '/Pisemnost/DPHDP3/VetaD');
        AssertXmlDocNodeExist(XMLDoc, '/Pisemnost/DPHDP3/VetaP');
        AssertXmlDocNodeExist(XMLDoc, '/Pisemnost/DPHDP3/Veta1');
        AssertXmlDocNodeExist(XMLDoc, '/Pisemnost/DPHDP3/Veta2');
        AssertXmlDocNodeExist(XMLDoc, '/Pisemnost/DPHDP3/Veta3');
        AssertXmlDocNodeExist(XMLDoc, '/Pisemnost/DPHDP3/Veta4');
        AssertXmlDocNodeExist(XMLDoc, '/Pisemnost/DPHDP3/Veta5');
        AssertXmlDocNodeExist(XMLDoc, '/Pisemnost/DPHDP3/Veta6');
    end;

    local procedure AssertXmlDocNodeExist(var XMLDoc: XmlDocument; XPath: Text)
    var
        FoundNode: XmlNode;
    begin
        Assert.IsTrue(XMLDoc.SelectSingleNode(XPath, FoundNode), StrSubstNo('XML Node %1 not found.', XPath));
    end;

    [Test]
    [HandlerFunctions('CalcAndPostVATSettlCZLRequestPageHandler,VATStatementCZLRequestPageHandler,ConfirmYesHandler')]
    procedure VATStatementDPHDP3PrintAdditional()
    var
        VATStatementTemplate: Record "VAT Statement Template";
    begin
        AdditionalVATStatement(VATStatementTemplate."XML Format CZL"::DPHDP3, '2DAN');
    end;

    procedure AdditionalVATStatement(XMLFormat: Enum "VAT Statement XML Format CZL"; SalesTaxRowNo: Code[10])
    var
        GenJournalBatch: Record "Gen. Journal Batch";
        GenJournalLine: Record "Gen. Journal Line";
        VATStatementTemplate: Record "VAT Statement Template";
        VATStatementName: Record "VAT Statement Name";
        StartingDate: Date;
        EndingDate: Date;
        DocumentNo: Code[20];
        GLAccountNo: Code[20];
        AdditionalVATAmount: Decimal;
    begin
        // [SCENARIO] Using existing demo data, post the VAT settlement, reopen and post additional line with VAT
        Initialize();

        // [GIVEN] VAT Statement has been select
        FindVATStatementTemplate(VATStatementTemplate, XMLFormat::DPHDP3);
        LibraryTaxCZL.SelectVATStatementName(VATStatementName, VATStatementTemplate.Name);

        // [GIVEN] Starting Date and Ending Date have been calculated as first open VAT Period
        StartingDate := LibraryTaxCZL.GetVATPeriodStartingDate();
        EndingDate := CalcDate('<+1M-1D>', StartingDate);

        // [GIVEN] Account No. and Settlement No. have been created
        DocumentNo := GetSettlementNo(StartingDate);
        GLAccountNo := LibraryERM.CreateGLAccountNo();

        // [GIVEN] VAT Settlement has been posted in given VAT Period
        Commit();
        RunCalcAndPostVATSettlCZL(StartingDate, EndingDate, DocumentNo, GLAccountNo);

        // [GIVEN] VAT Period has been reopened and additional Gen. Journal Line with random amount has been posted
        LibraryTaxCZL.ReopenVATPeriod(StartingDate);
        SelectGenJournalBatch(GenJournalBatch);
        LibraryERM.CreateGeneralJnlLine(
          GenJournalLine, GenJournalBatch."Journal Template Name", GenJournalBatch.Name, "Gen. Journal Document Type"::" ",
          GenJournalLine."Account Type"::"G/L Account", LibraryERM.CreateGLAccountWithSalesSetup(), -1000);
        GenJournalLine.Validate("Posting Date", CalcDate('<+10D>', StartingDate));
        GenJournalLine.Modify(true);
        AdditionalVATAmount := -GenJournalLine."VAT Amount";
        LibraryERM.PostGeneralJnlLine(GenJournalLine);

        // [GIVEN] New Settlement No. has been created
        DocumentNo := CopyStr(StrSubstNo('%1A', DocumentNo), 1, MaxStrLen(DocumentNo));

        // [GIVEN] VAT Settlement has been posted in given VAT Period        
        Commit();
        RunCalcAndPostVATSettlCZL(StartingDate, EndingDate, DocumentNo, GLAccountNo);

        // [WHEN] Print VAT Statement
        Commit();
        PrintVATStatement(VATStatementName, StartingDate, EndingDate, DocumentNo);

        // [THEN] Report dataset will have VAT Statement Line matching RowNo with expected TotalAmount
        LibraryReportDataset.LoadDataSetFile();
        LibraryReportDataset.MoveToRow(LibraryReportDataset.FindRow('VatStmtLineRowNo', SalesTaxRowNo) + 1);
        LibraryReportDataset.AssertCurrentRowValueEquals('TotalAmount', AdditionalVATAmount);
    end;

    [RequestPageHandler]
    procedure VATStatementCZLRequestPageHandler(var VATStatement: TestRequestPage "VAT Statement")
    var
        StartingDate: Date;
        EndingDate: Date;
        Selection: Option;
        PeriodSelection: Option;
        DocumentNo: Code[20];
    begin
        StartingDate := LibraryVariableStorage.DequeueDate();
        EndingDate := LibraryVariableStorage.DequeueDate();
        Selection := LibraryVariableStorage.DequeueInteger();
        PeriodSelection := LibraryVariableStorage.DequeueInteger();
        DocumentNo := CopyStr(LibraryVariableStorage.DequeueText(), 1, 20);

        VATStatement.StartingDate.SetValue(StartingDate);
        VATStatement.EndingDate.SetValue(EndingDate);
        VATStatement.Selection.SetValue(Selection);
        VATStatement.PeriodSelection.SetValue(PeriodSelection);
        VATStatement.SettlementNoFilterCZL.SetValue(DocumentNo);

        VATStatement.SaveAsXml(
          LibraryReportDataset.GetParametersFileName(), LibraryReportDataset.GetFileName());
    end;

    local procedure RunExportVATStatement(StmtTempName: Code[10]; StmtName: Code[10]; StartingDate: Date; EndingDate: Date; DocumentNo: Code[20]; var TempBlob: Codeunit "Temp Blob")
    begin
        LibraryVariableStorage.Enqueue(StartingDate);
        LibraryVariableStorage.Enqueue(EndingDate);
        LibraryVariableStorage.Enqueue("VAT Statement Report Selection"::Closed);
        LibraryVariableStorage.Enqueue("VAT Statement Report Period Selection"::"Within Period");
        LibraryVariableStorage.Enqueue(LibraryTaxCZL.GetCompanyOfficialsNo()); // FilledByEmployeeNoField
        LibraryVariableStorage.Enqueue(DocumentNo); //SettlementNoFilter

        LibraryTaxCZL.RunExportVATStatement(StmtTempName, StmtName, TempBlob);
    end;

    [RequestPageHandler]
    procedure ExportVATStmtDialogRequestPageHandler(var ExportVATStmtDialogCZL: TestRequestPage "Export VAT Stmt. Dialog CZL")
    var
        FieldValueVariant: Variant;
    begin
        LibraryVariableStorage.Dequeue(FieldValueVariant);
        ExportVATStmtDialogCZL.StartDateField.SetValue(FieldValueVariant);
        LibraryVariableStorage.Dequeue(FieldValueVariant);
        ExportVATStmtDialogCZL.EndDateField.SetValue(FieldValueVariant);
        LibraryVariableStorage.Dequeue(FieldValueVariant);
        ExportVATStmtDialogCZL.SelectionField.SetValue(FieldValueVariant);
        LibraryVariableStorage.Dequeue(FieldValueVariant);
        ExportVATStmtDialogCZL.PeriodSelectionField.SetValue(FieldValueVariant);
        LibraryVariableStorage.Dequeue(FieldValueVariant);
        ExportVATStmtDialogCZL.FilledByEmployeeNoField.SetValue(FieldValueVariant);
        LibraryVariableStorage.Dequeue(FieldValueVariant);
        ExportVATStmtDialogCZL.SettlementNoFilterField.SetValue(FieldValueVariant);

        ExportVATStmtDialogCZL.OK().Invoke();
    end;

    local procedure RunCalcAndPostVATSettlCZL(StartingDate: Date; EndingDate: Date; DocumentNo: Code[20]; GLAccountNo: Code[20])
    var
        VATPostingSetup: Record "VAT Posting Setup";
        TempBlob: Codeunit "Temp Blob";
        RequestPageXML: Text;
    begin
        LibraryVariableStorage.Enqueue(StartingDate);
        LibraryVariableStorage.Enqueue(EndingDate);
        LibraryVariableStorage.Enqueue(EndingDate); // as PostingDate
        LibraryVariableStorage.Enqueue(DocumentNo);
        LibraryVariableStorage.Enqueue(GLAccountNo);
        LibraryVariableStorage.Enqueue(true);

        VATPostingSetup.Reset();
        RequestPageXML := Report.RunRequestPage(Report::"Calc. and Post VAT Settl. CZL");
        RunAndSaveReport(Report::"Calc. and Post VAT Settl. CZL", VATPostingSetup, RequestPageXML, TempBlob, ReportFormat::Xml);
    end;

    [RequestPageHandler]
    procedure CalcAndPostVATSettlCZLRequestPageHandler(var CalcandPostVATSettlCZL: TestRequestPage "Calc. and Post VAT Settl. CZL")
    var
        FieldValueVariant: Variant;
    begin
        LibraryVariableStorage.Dequeue(FieldValueVariant);
        CalcandPostVATSettlCZL.StartingDate.SetValue(FieldValueVariant);
        LibraryVariableStorage.Dequeue(FieldValueVariant);
        CalcandPostVATSettlCZL.EndingDate.SetValue(FieldValueVariant);
        LibraryVariableStorage.Dequeue(FieldValueVariant);
        CalcandPostVATSettlCZL.PostingDt.SetValue(FieldValueVariant);
        LibraryVariableStorage.Dequeue(FieldValueVariant);
        CalcandPostVATSettlCZL.DocumentNo.SetValue(FieldValueVariant);
        LibraryVariableStorage.Dequeue(FieldValueVariant);
        CalcandPostVATSettlCZL.SettlementAcc.SetValue(FieldValueVariant);
        LibraryVariableStorage.Dequeue(FieldValueVariant);
        CalcandPostVATSettlCZL.Post.SetValue(FieldValueVariant);

        CalcandPostVATSettlCZL.OK().Invoke();
    end;

    [ConfirmHandler]
    procedure ConfirmYesHandler(Question: Text; var Reply: Boolean)
    begin
        Reply := true;
    end;

    local procedure FindFirstPrintableVATStatementTotalLine(var VATStatementLine: Record "VAT Statement Line"; VATStmTemplCode: Code[10]; VATStmName: Code[10])
    begin
        VATStatementLine.Reset();
        VATStatementLine.SetRange("Statement Template Name", VATStmTemplCode);
        VATStatementLine.SetRange("Statement Name", VATStmName);
        VATStatementLine.SetRange(Type, VATStatementLine.Type::"Formula CZL");
        VATStatementLine.SetRange(Print, true);
        VATStatementLine.FindFirst();
    end;


    local procedure SelectVATStatementRowTotalingLines(var VATStatementLine: Record "VAT Statement Line"; VATStmTemplCode: Code[10]; VATStmName: Code[10]; RowTotaling: Text[50])
    begin
        VATStatementLine.Reset();
        VATStatementLine.SetRange("Statement Template Name", VATStmTemplCode);
        VATStatementLine.SetRange("Statement Name", VATStmName);
        VATStatementLine.SetFilter("Row No.", RowTotaling);
    end;

    local procedure CalcExpectedSettlementTotalAmount(var VATStatementLine: Record "VAT Statement Line"; DocumentNo: Code[20]; var TotalAmount: Decimal)
    var
        VATEntry: Record "VAT Entry";
        Sign: Integer;
    begin
        if VATStatementLine.FindSet() then
            repeat
                VATEntry.Reset();
                VATEntry.SetRange("Document No.", DocumentNo);
                VATEntry.SetRange("VAT Bus. Posting Group", VATStatementLine."VAT Bus. Posting Group");
                VATEntry.SetRange("VAT Prod. Posting Group", VATStatementLine."VAT Prod. Posting Group");
                case VATStatementLine."Gen. Posting Type" of
                    VATStatementLine."Gen. Posting Type"::Purchase:
                        VATEntry.SetFilter(Amount, '<=0');
                    VATStatementLine."Gen. Posting Type"::Sale:
                        VATEntry.SetFilter(Amount, '>=0');
                end;

                Sign := 1;
                if VATStatementLine."Print with" = VATStatementLine."Print with"::"Opposite Sign" then
                    Sign := -1;

                if VATEntry.FindFirst() then
                    case VATStatementLine."Amount Type" of
                        VATStatementLine."Amount Type"::Amount:
                            TotalAmount += Sign * VATEntry.Amount;
                        VATStatementLine."Amount Type"::Base:
                            TotalAmount += Sign * VATEntry.Base;
                    end;
            until VATStatementLine.Next() = 0;
    end;

    local procedure PrintVATStatement(VATStatementName: Record "VAT Statement Name"; StartingDate: Date; EndingDate: Date; DocumentNo: Code[20])
    var
        VATStatementLine: Record "VAT Statement Line";
    begin
        LibraryVariableStorage.Enqueue(StartingDate);
        LibraryVariableStorage.Enqueue(EndingDate);
        LibraryVariableStorage.Enqueue("VAT Statement Report Selection"::Closed);
        LibraryVariableStorage.Enqueue("VAT Statement Report Period Selection"::"Within Period");
        LibraryVariableStorage.Enqueue(DocumentNo);

        VATStatementLine.SetRange("Statement Template Name", VATStatementName."Statement Template Name");
        VATStatementLine.SetRange("Statement Name", VATStatementName.Name);

        LibraryTaxCZL.PrintVATStatement(VATStatementLine, true);
    end;

    local procedure RunAndSaveReport(ReportID: Integer; RecordVariant: Variant; RequestPageParametersXML: Text; var TempBlob: Codeunit "Temp Blob"; ReportFormat: ReportFormat)
    var
        DataTypeManagement: Codeunit "Data Type Management";
        ReportRecordRef: RecordRef;
        ReportOutStream: OutStream;
    begin
        TempBlob.CreateOutStream(ReportOutStream);

        if DataTypeManagement.GetRecordRef(RecordVariant, ReportRecordRef) then
            Report.SaveAs(ReportID, RequestPageParametersXML, ReportFormat, ReportOutStream, ReportRecordRef)
        else
            Report.SaveAs(ReportID, RequestPageParametersXML, ReportFormat, ReportOutStream);
    end;

    local procedure FindVATStatementTemplate(var VATStatementTemplate: Record "VAT Statement Template"; XMLFormat: Enum "VAT Statement XML Format CZL")
    begin
        LibraryTaxCZL.FindVATStatementTemplate(VATStatementTemplate);
        SetXMLFormat(VATStatementTemplate, XMLFormat);
    end;

    local procedure GetSettlementNo(StartingDate: Date): Code[20]
    begin
        exit(StrSubstNo('VYRDPH%1%2', Date2DMY(StartingDate, 2), Date2DMY(StartingDate, 3)));
    end;

    local procedure SetXMLFormat(var VATStatementTemplate: Record "VAT Statement Template"; XMLFormat: Enum "VAT Statement XML Format CZL")
    begin
        LibraryTaxCZL.SetXMLFormat(VATStatementTemplate, XMLFormat);
    end;

    local procedure SelectGenJournalBatch(var GenJournalBatch: Record "Gen. Journal Batch")
    begin
        LibraryERM.SelectGenJnlBatch(GenJournalBatch);
        LibraryERM.ClearGenJournalLines(GenJournalBatch)
    end;
}