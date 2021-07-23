#pragma warning disable AL0432
codeunit 148060 "Tax VAT Statements CZL"
{
    Subtype = Test;
    TestPermissions = NonRestrictive;

    var
        LibraryERM: Codeunit "Library - ERM";
        LibraryRandom: Codeunit "Library - Random";
        LibraryReportDataset: Codeunit "Library - Report Dataset";
        LibraryVariableStorage: Codeunit "Library - Variable Storage";
        Assert: Codeunit Assert;
        LibraryTaxCZL: Codeunit "Library - Tax CZL";

    local procedure Initialize()
    var
        StatutoryReportingSetupCZL: Record "Statutory Reporting Setup CZL";
    begin
        LibraryRandom.SetSeed(1);  // Use Random Number Generator to generate the seed for RANDOM function.
        LibraryVariableStorage.Clear();
        Clear(LibraryReportDataset);
        LibraryTaxCZL.SetUseVATDate(true);
        LibraryTaxCZL.CreateStatReportingSetup();
        LibraryTaxCZL.SetVATStatementInformation();
        LibraryTaxCZL.SetCompanyType(StatutoryReportingSetupCZL."Company Type"::Corporate);
    end;

    [Test]
    [HandlerFunctions('VATStatementTemplateListModalPageHandler,ConfirmYesHandler')]
    [TransactionModel(TransactionModel::AutoRollback)]
    procedure DateFilterCopyToVATEntriesFromVATStatementPreview()
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
        // [FEATURE] [UI] [VAT Statement Preview]
        // [SCENARIO] 'VAT Entries' opened from VAT Statement Preview respect the Date Filter in VAT Statement
        Initialize();

        // [GIVEN] "VAT Statement Name" and "VAT Statement Line" with Type = "VAT Entry Totaling"
        LibraryERM.CreateVATStatementNameWithTemplate(VATStatementName);
        LibraryERM.CreateVATStatementLine(VATStatementLine, VATStatementName."Statement Template Name", VATStatementName.Name);
        VATStatementLine.Validate(Type, VATStatementLine.Type::"VAT Entry Totaling");
        VATStatementLine.Validate("Amount Type", VATStatementLine."Amount Type"::Amount);
        VATStatementLine.Modify(true);
        LibraryVariableStorage.Enqueue(VATStatementName."Statement Template Name");

        // [GIVEN] Open page "VAT Statement Preview CZL" for created line
        VATStatement.OpenEdit();
        VATStatement.Filter.SetFilter("Statement Template Name", VATStatementLine."Statement Template Name");
        VATStatement.Filter.SetFilter("Statement Name", VATStatementLine."Statement Name");
        VATStatement.First();
        VATStatementPreviewCZL.Trap();
        VATStatement."P&review CZL".Invoke();

        // [GIVEN] Starting Date is first open VAT Period
        LibraryTaxCZL.FindFirstOpenVATPeriod(VATPeriodCZL);
        StartingDate := VATPeriodCZL."Starting Date";
        EndingDate := CalcDate('<+1M-1D>', StartingDate);

        // [GIVEN] Set date filter to first open VAT Period and Period Selection = "Within Period"
        VATStatementPreviewCZL.VATPeriodStartDate.SetValue(StartingDate);
        VATStatementPreviewCZL.VATPeriodEndDate.SetValue(EndingDate);
        VATStatementPreviewCZL.PeriodSelection.SetValue("VAT Statement Report Period Selection"::"Within Period");
        VATEntries.Trap();

        // [WHEN] DrillDown to ColumnValue
        VATStatementPreviewCZL.VATStatementLineSubForm.ColumnValue.Drilldown();

        // [THEN] Page "VAT Entries" was opened with filter to "VAT Date" = Date
        Assert.AreEqual(VATEntries.Filter.GetFilter("VAT Date CZL"), StrSubstNo('%1..%2', StartingDate, EndingDate), '');
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
    procedure PrintingVATStatementDPHDP3()
    var
        VATStatementTemplate: Record "VAT Statement Template";
    begin
        PrintingVATStatement(VATStatementTemplate."XML Format CZL"::DPHDP3);
    end;

    procedure PrintingVATStatement(XMLFormat: Enum "VAT Statement XML Format CZL")
    var
        VATStatementLine: Record "VAT Statement Line";
        VATStatementName: Record "VAT Statement Name";
        VATStatementTemplate: Record "VAT Statement Template";
        StartingDate: Date;
        EndingDate: Date;
        DocumentNo: Code[20];
        GLAccountNo: Code[20];
        RowNo: Code[10];
        TotalAmount: Decimal;
    begin
        // [FEATURE] [Print VAT Statement CZL] 
        // [SCENARIO] Using existing demo data, post the VAT settlement and print the VAT Statement filtered for VAT Settlement Document No.
        Initialize();

        // [GIVEN] VAT Statement Template selected according parameter XMLFormat
        FindVATStatementTemplate(VATStatementTemplate, XMLFormat);

        // [GIVEN] Select first VAT Statement Name for specified VAT Statement Template
        LibraryTaxCZL.SelectVATStatementName(VATStatementName, VATStatementTemplate.Name);

        // [GIVEN] Starting Date is first open VAT Period or first open VAT Entry
        StartingDate := LibraryTaxCZL.GetVATPeriodStartingDate();
        EndingDate := CalcDate('<+1M-1D>', StartingDate);

        // [GIVEN] VAT Settlement Document No. = "VYRDPH<month><year>"
        DocumentNo := GetSettlementNo(StartingDate);

        // [GIVEN] Settlement G/L Account = random account
        GLAccountNo := LibraryERM.CreateGLAccountNo();

        // [GIVEN] Post VAT Settlement, so the VAT Entries in given VAT Period are closed and new VAT Settlement entries created
        RunCalcAndPostVATSettlCZL(StartingDate, EndingDate, DocumentNo, GLAccountNo);

        // [GIVEN] Collect VAT statement line row number and expected amount needed for the subsequent test evaluation. 
        FindFirstPrintableVATStatementTotalLine(VATStatementLine, VATStatementTemplate.Name, VATStatementName.Name);
        RowNo := VATStatementLine."Row No.";
        SelectVATStatementRowTotalingLines(VATStatementLine, VATStatementTemplate.Name, VATStatementName.Name, VATStatementLine."Row Totaling");
        CalcExpectedSettlementTotalAmount(VATStatementLine, DocumentNo, TotalAmount);

        // [WHEN] Run report "VAT Statement CZL" including "Closed" VAT entries "Within Period" for VAT Settlement Document No.
        PrintVATStatement(VATStatementName, StartingDate, Endingdate, DocumentNo);

        // [THEN] There is a VAT statement line matching RowNo with expected TotalAmount. E.g. RowNo = 1ZAK, TotalAmount = 28038911.98
        LibraryReportDataset.LoadDataSetFile();
        LibraryReportDataset.MoveToRow(LibraryReportDataset.FindRow('VatStmtLineRowNo', RowNo) + 1);
        LibraryReportDataset.AssertCurrentRowValueEquals('TotalAmount', TotalAmount);
    end;

    [Test]
    [HandlerFunctions('CalcAndPostVATSettlCZLRequestPageHandler,ExportVATStmtDialogRequestPageHandler,ConfirmYesHandler')]
    [TransactionModel(TransactionModel::AutoRollback)]
    procedure ExportingVATStatementDPHDP3()
    var
        VATStatementTemplate: Record "VAT Statement Template";
    begin
        ExportingVATStatement(VATStatementTemplate."XML Format CZL"::DPHDP3);
    end;

    procedure ExportingVATStatement(XMLFormat: Enum "VAT Statement XML Format CZL")
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
        // [FEATURE] [Export VAT Statement CZL] 
        // [SCENARIO] Using existing demo data, post the VAT settlement and export the VAT Statement filtered for VAT Settlement Document No.
        Initialize();

        // [GIVEN] VAT Statement Template selected according parameter XMLFormat
        FindVATStatementTemplate(VATStatementTemplate, XMLFormat);

        // [GIVEN] Select first VAT Statement Name for specified VAT Statement Template
        LibraryTaxCZL.SelectVATStatementName(VATStatementName, VATStatementTemplate.Name);
        //FindVATStatementLine(VATStatementLine, VATStatementTemplate.Name, '');

        // [GIVEN] Starting Date is first open VAT Period or first open VAT Entry
        StartingDate := LibraryTaxCZL.GetVATPeriodStartingDate();
        EndingDate := CalcDate('<+1M-1D>', StartingDate);

        // [GIVEN] VAT Settlement Document No. = "VYRDPH<month><year>"
        DocumentNo := GetSettlementNo(StartingDate);

        // [GIVEN] Settlement G/L Account = random account
        GLAccountNo := LibraryERM.CreateGLAccountNo();

        // [GIVEN] Post VAT Settlement, so the VAT Entries in given VAT Period are closed and new VAT Settlement entries created
        RunCalcAndPostVATSettlCZL(StartingDate, EndingDate, DocumentNo, GLAccountNo);

        // [WHEN] Run VAT Statement export to Blob including "Closed" VAT entries "Within Period" for VAT Settlement Document No.
        RunExportVATStatement(VATStatementTemplate.Name, VATStatementName.Name, StartingDate, EndingDate, DocumentNo, TempBlob);

        // [THEN] Verify exported XML document structure
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
    procedure AdditionalVATStatementDPHDP3()
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
        // [FEATURE] [Print Additional VAT Statement CZL] 
        // [SCENARIO] Using existing demo data, post the VAT settlement.Reopen and post additional line with VAT.
        // [SCENARIO] Post additional VAT settlement and print VAT Statement.
        Initialize();

        // [GIVEN] VAT Statement Template selected according parameter XMLFormat
        FindVATStatementTemplate(VATStatementTemplate, XMLFormat);

        // [GIVEN] Select first VAT Statement Name for specified VAT Statement Template
        LibraryTaxCZL.SelectVATStatementName(VATStatementName, VATStatementTemplate.Name);

        // [GIVEN] Starting Date is first open VAT Period or first open VAT Entry
        StartingDate := LibraryTaxCZL.GetVATPeriodStartingDate();
        EndingDate := CalcDate('<+1M-1D>', StartingDate);

        // [GIVEN] VAT Settlement Document No. = "VYRDPH<month><year>"
        DocumentNo := GetSettlementNo(StartingDate);

        // [GIVEN] Settlement G/L Account = random account
        GLAccountNo := LibraryERM.CreateGLAccountNo();



        // [GIVEN] Post VAT Settlement, so the VAT Entries in given VAT Period are closed and new VAT Settlement entries created
        Commit();
        RunCalcAndPostVATSettlCZL(StartingDate, EndingDate, DocumentNo, GLAccountNo);

        // [GIVEN] Reopen VAT Period and post additional GenJnl line with random amount. Additional VAT Entry for AdditionalVATAmount is created
        LibraryTaxCZL.ReopenVATPeriod(StartingDate);
        SelectGenJournalBatch(GenJournalBatch);
        LibraryERM.CreateGeneralJnlLine(
          GenJournalLine, GenJournalBatch."Journal Template Name", GenJournalBatch.Name, "Gen. Journal Document Type"::" ",
          GenJournalLine."Account Type"::"G/L Account", LibraryERM.CreateGLAccountWithSalesSetup(),
          -LibraryRandom.RandDecInRange(1000, 2000, 2));
        GenJournalLine.Validate("Posting Date", CalcDate('<+10D>', StartingDate));
        GenJournalLine.Modify(true);
        AdditionalVATAmount := -GenJournalLine."VAT Amount";
        LibraryERM.PostGeneralJnlLine(GenJournalLine);
        Commit();

        // [GIVEN] Additional VAT Settlement Document No. = "VYRDPH<month><year>1A"
        DocumentNo := CopyStr(StrSubstNo('%1A', DocumentNo), 1, MaxStrLen(DocumentNo));

        // [GIVEN] Post VAT Settlement, so the additional VAT Entries are closed and new VAT Settlement entries created        
        RunCalcAndPostVATSettlCZL(StartingDate, EndingDate, DocumentNo, GLAccountNo);
        Commit();


        // [WHEN] Run report "VAT Statement CZL" including "Closed" VAT entries "Within Period" for Additional VAT Settlement Document No.
        PrintVATStatement(VATStatementName, StartingDate, EndingDate, DocumentNo);

        // [THEN] There is a VAT statement line matching RowNo with expected AdditionalVATAmount. E.g. RowNo = 2DAN, TotalAmount = 1234
        LibraryReportDataset.LoadDataSetFile();
        LibraryReportDataset.MoveToRow(LibraryReportDataset.FindRow('VatStmtLineRowNo', SalesTaxRowNo) + 1);
        LibraryReportDataset.AssertCurrentRowValueEquals('TotalAmount', AdditionalVATAmount);
    end;

    [RequestPageHandler]
    procedure VATStatementCZLRequestPageHandler(var VATStatementCZL: TestRequestPage "VAT Statement CZL")
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

        VATStatementCZL.StartingDate.SetValue(StartingDate);
        VATStatementCZL.EndingDate.SetValue(EndingDate);
        VATStatementCZL.Selection.SetValue(Selection);
        VATStatementCZL.PeriodSelection.SetValue(PeriodSelection);
        VATStatementCZL.SettlementNoFilterField.SetValue(DocumentNo);

        VATStatementCZL.SaveAsXml(
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
        ConvertVATStatementLineDeprEnumValues(VATStatementLine);
        VATStatementLine.SetRange(Type, VATStatementLine.Type::"Formula CZL");
        VATStatementLine.SetRange(Print, true);
        VATStatementLine.FindFirst();
    end;

    [Obsolete('Will be removed once verified that VAT Statement Line do not contain obsoleted Type::"Formula".', '18.0')]
    local procedure ConvertVATStatementLineDeprEnumValues(var VATStatementLine: Record "VAT Statement Line");
    begin
#if CLEAN17
        VATStatementLine.SetRange(Type, 4); // VATStatementLine.Type::"Formula"
#else
        VATStatementLine.SetRange(Type, VATStatementLine.Type::"Formula");
#endif
        if not VATStatementLine.IsEmpty() then
            VATStatementLine.ModifyAll(Type, VATStatementLine.Type::"Formula CZL", true);
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