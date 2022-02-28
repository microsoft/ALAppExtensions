codeunit 148068 "VAT Ctrl. Report UT CZL"
{
    Subtype = Test;
    TestPermissions = Disabled;
    EventSubscriberInstance = Manual;

    trigger OnRun()
    begin
        // [FEATURE] [Core] [VAT Ctrl. Report]
        isInitialized := false;
    end;

    var
        Assert: Codeunit Assert;
        LibraryERM: Codeunit "Library - ERM";
        LibraryRandom: Codeunit "Library - Random";
        LibraryReportDataset: Codeunit "Library - Report Dataset";
        LibraryReportValidation: Codeunit "Library - Report Validation";
        LibrarySales: Codeunit "Library - Sales";
        LibraryTaxCZL: Codeunit "Library - Tax CZL";
        LibraryUtility: Codeunit "Library - Utility";
        LibraryVariableStorage: Codeunit "Library - Variable Storage";
        isInitialized: Boolean;
        SectionA1Tok: Label 'A1', Locked = true;
        SectionA2Tok: Label 'A2', Locked = true;
        SectionA3Tok: Label 'A3', Locked = true;
        SectionA4Tok: Label 'A4', Locked = true;
        SectionA5Tok: Label 'A5', Locked = true;
        SectionB1Tok: Label 'B1', Locked = true;
        SectionB2Tok: Label 'B2', Locked = true;
        SectionB3Tok: Label 'B3', Locked = true;
        SectionCodeHasNotBeenChangedTxt: Label 'The section code has not been changed.';
        ExternalDocNoHasNotBeenChangedTxt: Label 'The external document no. has not been changed.';
        IncorrectValueInCellOnWorksheetErr: Label 'Incorrect value on worksheet %1 in cell R%2 C%3', Comment = '%1 = workshwwt, %2 = row, %3 = column';
        XmlNodeFoundErr: Label 'XML Node %1 found.', Comment = '%1 = XPath';
        XmlNodeNotFoundErr: Label 'XML Node %1 not found.', Comment = '%1 = XPath';
        UnexpectedAttributeValueErr: Label 'Unexpected xml attribute value.';

    local procedure Initialize()
    var
        LibraryTestInitialize: Codeunit "Library - Test Initialize";
    begin
        LibraryTestInitialize.OnTestInitialize(Codeunit::"VAT Ctrl. Report CZL");

        LibraryVariableStorage.Clear();
        LibraryRandom.Init();

        if isInitialized then
            exit;
        LibraryTestInitialize.OnBeforeTestSuiteInitialize(Codeunit::"VAT Ctrl. Report CZL");

        LibraryTaxCZL.CreateDefaultVATControlReportSections(true);

        isInitialized := true;
        LibraryTestInitialize.OnAfterTestSuiteInitialize(Codeunit::"VAT Ctrl. Report CZL");
    end;

    [Test]
    [HandlerFunctions('VATCtrlReportSectionsHandler')]
    procedure ChangeSectionOnVATControlReportLine()
    var
        VATCtrlReportLineCZL: Record "VAT Ctrl. Report Line CZL";
    begin
        // [FEATURE] [UT]
        // [SCENARIO] The section is possible to change on the vat control report line
        Initialize();

        // [GIVEN] The vat control report line with section A4 has been created
        VATCtrlReportLineCZL := CreateVATCtrlReportLine(SectionA4Tok);

        // [WHEN] Run function for changing section code and change section A4 to A5
        ChangeVATControlReportSection(VATCtrlReportLineCZL, SectionA5Tok);

        // [THEN] The section code on the vat control report line will be changed
        VATCtrlReportLineCZL.Get(VATCtrlReportLineCZL."VAT Ctrl. Report No.", VATCtrlReportLineCZL."Line No.");
        Assert.AreEqual(SectionA5Tok, VATCtrlReportLineCZL."VAT Ctrl. Report Section Code", SectionCodeHasNotBeenChangedTxt);
    end;

    [Test]
    [HandlerFunctions('VATCtrlReportSectionsHandler')]
    procedure BulkChangeSectionOnVATControlReportLines()
    var
        VATCtrlReportLineCZL: Record "VAT Ctrl. Report Line CZL";
    begin
        // [FEATURE] [UT]
        // [SCENARIO] The sections are possible to change on more vat control report lines
        Initialize();

        // [GIVEN] Two vat control report lines with different sections have been created
        VATCtrlReportLineCZL := CreateVATCtrlReportLine(SectionA4Tok);
        CreateVATCtrlReportLine(VATCtrlReportLineCZL."VAT Ctrl. Report No.", SectionB2Tok);

        // [WHEN] Run function for changing section code for two created lines
        VATCtrlReportLineCZL.SetRange("VAT Ctrl. Report No.", VATCtrlReportLineCZL."VAT Ctrl. Report No.");
        ChangeVATControlReportSection(VATCtrlReportLineCZL, SectionB3Tok);

        // [THEN] The section code on the first vat control report line will be changed
        VATCtrlReportLineCZL.FindSet();
        Assert.AreEqual(SectionB3Tok, VATCtrlReportLineCZL."VAT Ctrl. Report Section Code", SectionCodeHasNotBeenChangedTxt);

        // [THEN] The section code on the second vat control report line will be changed
        VATCtrlReportLineCZL.Next();
        Assert.AreEqual(SectionB3Tok, VATCtrlReportLineCZL."VAT Ctrl. Report Section Code", SectionCodeHasNotBeenChangedTxt);
    end;

    [Test]
    procedure ChangeExternalDocumentNoOnVATControlReportLine()
    var
        VATCtrlReportHeaderCZL: Record "VAT Ctrl. Report Header CZL";
        VATCtrlReportLineCZL: Record "VAT Ctrl. Report Line CZL";
        VATCtrlReportCardCZL: TestPage "VAT Ctrl. Report Card CZL";
        NewExternalDocumentNo: Code[20];
    begin
        // [FEATURE] [UT]
        // [SCENARIO] The external document no. is possible to change on the vat control report line
        Initialize();

        // [GIVEN] The vat control report header has been created
        VATCtrlReportHeaderCZL := CreateVATCtrlReportHeader();

        // [GIVEN] The vat control report line has been created
        VATCtrlReportLineCZL := CreateVATCtrlReportLine(VATCtrlReportHeaderCZL."No.", SectionA4Tok);

        // [WHEN] Change external document no. on line
        NewExternalDocumentNo := LibraryUtility.GenerateGUID();
        VATCtrlReportCardCZL.OpenEdit();
        VATCtrlReportCardCZL.GoToRecord(VATCtrlReportHeaderCZL);
        VATCtrlReportCardCZL.Lines.First();
        VATCtrlReportCardCZL.Lines."External Document No.".SetValue(NewExternalDocumentNo);
        VATCtrlReportCardCZL.Close();

        // [THEN] The external document no. will be changed
        VATCtrlReportLineCZL.SetRange("VAT Ctrl. Report No.", VATCtrlReportLineCZL."VAT Ctrl. Report No.");
        VATCtrlReportLineCZL.FindFirst();
        Assert.AreEqual(NewExternalDocumentNo, VATCtrlReportLineCZL."External Document No.", ExternalDocNoHasNotBeenChangedTxt);
    end;

    [Test]
    procedure ChangeEditableFieldsOnVATControlReportLine()
    var
        VATCtrlReportHeaderCZL: Record "VAT Ctrl. Report Header CZL";
        VATCtrlReportLineCZL: Record "VAT Ctrl. Report Line CZL";
        VATCtrlReportCardCZL: TestPage "VAT Ctrl. Report Card CZL";
        NewCustomerNo: Code[20];
        NewRegistrationNo: Text[20];
        NewOriginalDocumentVATDate: Date;
    begin
        // [FEATURE] [UI]
        // [SCENARIO] The missing fields are possible to change on the vat control report line
        Initialize();

        // [GIVEN] The vat control report header has been created
        VATCtrlReportHeaderCZL := CreateVATCtrlReportHeader();

        // [GIVEN] The vat control report line has been created
        VATCtrlReportLineCZL := CreateVATCtrlReportLine(VATCtrlReportHeaderCZL."No.", SectionA4Tok);

        // [WHEN] Change missing fields on line
        NewCustomerNo := LibrarySales.CreateCustomerNo();
        NewRegistrationNo := LibraryUtility.GenerateGUID();
        NewOriginalDocumentVATDate := CalcDate('<-1M>', WorkDate());
        VATCtrlReportCardCZL.OpenEdit();
        VATCtrlReportCardCZL.GoToRecord(VATCtrlReportHeaderCZL);
        VATCtrlReportCardCZL.Lines.First();
        VATCtrlReportCardCZL.Lines."Bill-to/Pay-to No.".SetValue(NewCustomerNo);
        VATCtrlReportCardCZL.Lines."Registration No.".SetValue(NewRegistrationNo);
        VATCtrlReportCardCZL.Lines."Original Document VAT Date".SetValue(NewOriginalDocumentVATDate);
        VATCtrlReportCardCZL.Close();

        // [THEN] The fields will be changed
        VATCtrlReportLineCZL.SetRange("VAT Ctrl. Report No.", VATCtrlReportLineCZL."VAT Ctrl. Report No.");
        VATCtrlReportLineCZL.FindFirst();
        Assert.AreEqual(NewCustomerNo, VATCtrlReportLineCZL."Bill-to/Pay-to No.", ExternalDocNoHasNotBeenChangedTxt);
        Assert.AreEqual(NewRegistrationNo, VATCtrlReportLineCZL."Registration No.", ExternalDocNoHasNotBeenChangedTxt);
        Assert.AreEqual(NewOriginalDocumentVATDate, VATCtrlReportLineCZL."Original Document VAT Date", ExternalDocNoHasNotBeenChangedTxt);
    end;

    [Test]
    procedure ExportInternalDocCheckToExcel()
    var
        VATCtrlReportHeaderCZL: Record "VAT Ctrl. Report Header CZL";
        VATCtrlReportLineCZL1: Record "VAT Ctrl. Report Line CZL";
        VATCtrlReportLineCZL2: Record "VAT Ctrl. Report Line CZL";
        ExportedFileName: Text;
    begin
        // [SCENARIO] Export internal document check from vat control report.
        Initialize();

        // [GIVEN] The vat control report header has been created
        VATCtrlReportHeaderCZL := CreateVATCtrlReportHeader();

        // [GIVEN] Two vat control report lines for storno have been created
        VATCtrlReportLineCZL1 := CreateVATCtrlReportLine(VATCtrlReportHeaderCZL."No.", SectionA4Tok);
        VATCtrlReportLineCZL2 := VATCtrlReportLineCZL1;
        VATCtrlReportLineCZL2."Line No." += 10000;
        VATCtrlReportLineCZL2."Document No." := LibraryUtility.GenerateGUID();
        VATCtrlReportLineCZL2.Base := -VATCtrlReportLineCZL2.Base;
        VATCtrlReportLineCZL2.Amount := -VATCtrlReportLineCZL2.Amount;
        VATCtrlReportLineCZL2.Insert();

        // [WHEN] Run ExportInternalDocCheckToExcel function
        ExportedFileName := ExportInternalDocCheckToExcel(VATCtrlReportHeaderCZL);

        // [THEN] The excel worksheet will be contain document no. from both lines
        LibraryReportValidation.SetFullFileName(ExportedFileName);
        LibraryReportValidation.OpenFile();
        VerifyCellValueOnWorksheet(1, 2, 3, VATCtrlReportLineCZL1."Document No.");
        VerifyCellValueOnWorksheet(1, 2, 4, VATCtrlReportLineCZL2."Document No.");
    end;

    [Test]
    [HandlerFunctions('VATCtrlReportTestRequestPageHandler')]
    procedure PrintVATControlReportTest()
    var
        VATCtrlReportHeaderCZL: Record "VAT Ctrl. Report Header CZL";
        VATCtrlReportLineCZL1: Record "VAT Ctrl. Report Line CZL";
        VATCtrlReportLineCZL2: Record "VAT Ctrl. Report Line CZL";
    begin
        // [SCENARIO] The test report for vat control report.
        Initialize();

        // [GIVEN] The vat control report header has been created
        VATCtrlReportHeaderCZL := CreateVATCtrlReportHeader();

        // [GIVEN] Two vat control report lines with different sections have been created
        VATCtrlReportLineCZL1 := CreateVATCtrlReportLine(VATCtrlReportHeaderCZL."No.", SectionA4Tok);
        VATCtrlReportLineCZL2 := CreateVATCtrlReportLine(VATCtrlReportHeaderCZL."No.", SectionB2Tok);
        Commit();

        // [WHEN] Run vat control report test report
        RunVATCtrlReportTest(VATCtrlReportHeaderCZL);

        // [THEN] Two created lines are printed
        LibraryReportDataset.AssertElementWithValueExists('VATControlReportBuffer_VATControlRepSectionCode', VATCtrlReportLineCZL1."VAT Ctrl. Report Section Code");
        LibraryReportDataset.AssertElementWithValueExists('VATControlReportBuffer_VATControlRepSectionCode', VATCtrlReportLineCZL2."VAT Ctrl. Report Section Code");
        LibraryReportDataset.AssertElementWithValueNotExist('VATControlReportBuffer_VATControlRepSectionCode', SectionA1Tok);
        LibraryReportDataset.AssertElementWithValueNotExist('VATControlReportBuffer_VATControlRepSectionCode', SectionA2Tok);
        LibraryReportDataset.AssertElementWithValueNotExist('VATControlReportBuffer_VATControlRepSectionCode', SectionA3Tok);
        LibraryReportDataset.AssertElementWithValueNotExist('VATControlReportBuffer_VATControlRepSectionCode', SectionA5Tok);
        LibraryReportDataset.AssertElementWithValueNotExist('VATControlReportBuffer_VATControlRepSectionCode', SectionB1Tok);
        LibraryReportDataset.AssertElementWithValueNotExist('VATControlReportBuffer_VATControlRepSectionCode', SectionB3Tok);
    end;

    [Test]
    [HandlerFunctions('VATCtrlReportStatModalPageHandler')]
    procedure ShowVATControlReportStatistic()
    var
        VATCtrlReportHeaderCZL: Record "VAT Ctrl. Report Header CZL";
    begin
        // [SCENARIO] Show statistic of vat control report.
        Initialize();

        // [GIVEN] The vat control report header has been created
        VATCtrlReportHeaderCZL := CreateVATCtrlReportHeader();

        // [GIVEN] Two vat control report lines with different sections have been created
        CreateVATCtrlReportLine(VATCtrlReportHeaderCZL."No.", SectionA4Tok);
        CreateVATCtrlReportLine(VATCtrlReportHeaderCZL."No.", SectionB2Tok);
        Commit();

        // [WHEN] Run vat control report statistic
        RunVATCtrlReportStatistic(VATCtrlReportHeaderCZL);

        // [THEN] The non-empty statistic will be shown
        // Check is in the VATCtrlReportStatModalPageHandler
    end;

    [Test]
    [HandlerFunctions('YesConfirmHandler,GetDocumentNoAndDateModalPageHandler')]
    procedure CloseVATControlReport()
    var
        VATCtrlReportHeaderCZL: Record "VAT Ctrl. Report Header CZL";
        VATCtrlReportLineCZL: Record "VAT Ctrl. Report Line CZL";
        ClosedDocumentNo: Code[20];
        ClosedDate: Date;
    begin
        // [SCENARIO] Close the lines of vat control report.
        Initialize();

        // [GIVEN] The vat control report header has been created
        VATCtrlReportHeaderCZL := CreateVATCtrlReportHeader();

        // [GIVEN] Two vat control report lines with different sections have been created
        CreateVATCtrlReportLine(VATCtrlReportHeaderCZL."No.", SectionA4Tok);
        CreateVATCtrlReportLine(VATCtrlReportHeaderCZL."No.", SectionB2Tok);
        Commit();

        // [GIVEN] The vat control report has been released
        LibraryTaxCZL.ReleaseVATControlReport(VATCtrlReportHeaderCZL);

        // [WHEN] Close vat control report
        ClosedDocumentNo := LibraryUtility.GenerateGUID();
        ClosedDate := WorkDate();
        CloseVATControlReportLines(VATCtrlReportHeaderCZL, ClosedDocumentNo, ClosedDate);

        // [THEN] All the vat control report lines will be closed
        VATCtrlReportLineCZL.SetRange("VAT Ctrl. Report No.", VATCtrlReportHeaderCZL."No.");
        VATCtrlReportLineCZL.FindSet();
        Assert.AreEqual(ClosedDocumentNo, VATCtrlReportLineCZL."Closed by Document No.", '');
        Assert.AreEqual(ClosedDate, VATCtrlReportLineCZL."Closed Date", '');
        VATCtrlReportLineCZL.Next();
        Assert.AreEqual(ClosedDocumentNo, VATCtrlReportLineCZL."Closed by Document No.", '');
        Assert.AreEqual(ClosedDate, VATCtrlReportLineCZL."Closed Date", '');
    end;

    [Test]
    [HandlerFunctions('ExportVATCtrDialogRequestPageHandler')]
    procedure ExportRecapitulativeVATControlReport()
    var
        VATCtrlReportHeaderCZL: Record "VAT Ctrl. Report Header CZL";
        VATCtrlReportLineCZL1: Record "VAT Ctrl. Report Line CZL";
        VATCtrlReportLineCZL2: Record "VAT Ctrl. Report Line CZL";
        VATCtrlReportXmlDocument: XmlDocument;
    begin
        // [SCENARIO] Vat control report is possible to export to xml.
        Initialize();

        // [GIVEN] The vat control report header has been created
        VATCtrlReportHeaderCZL := CreateVATCtrlReportHeader();

        // [GIVEN] Two vat control report lines with different sections have been created
        VATCtrlReportLineCZL1 := CreateVATCtrlReportLine(VATCtrlReportHeaderCZL."No.", SectionA4Tok);
        VATCtrlReportLineCZL2 := CreateVATCtrlReportLine(VATCtrlReportHeaderCZL."No.", SectionB2Tok);

        // [GIVEN] The vat control report has been released
        LibraryTaxCZL.ReleaseVATControlReport(VATCtrlReportHeaderCZL);
        Commit();

        // [WHEN] Export recapitulative vat control report
        VATCtrlReportXmlDocument := ExportVATCtrlReport(VATCtrlReportHeaderCZL, Enum::"VAT Statement Report Selection"::Open, Enum::"VAT Ctrl. Report Decl Type CZL"::Recapitulative);

        // [THEN] The information regarding recapitulative statement will be in the xml
        AssertXmlAttributeValue(VATCtrlReportXmlDocument, '/Pisemnost/DPHKH1/VetaD', 'khdph_forma', 'B');

        // [THEN] The statement A4 and B2 will be in the xml
        AssertXmlAttributeValue(VATCtrlReportXmlDocument, '/Pisemnost/DPHKH1/VetaA4', 'c_evid_dd', VATCtrlReportLineCZL1."Document No.");
        AssertXmlAttributeValue(VATCtrlReportXmlDocument, '/Pisemnost/DPHKH1/VetaB2', 'c_evid_dd', VATCtrlReportLineCZL2."External Document No.");
    end;

    [Test]
    [HandlerFunctions('ExportVATCtrDialogRequestPageHandler')]
    procedure ExcludeLineFromExportVATControlReport()
    var
        VATCtrlReportHeaderCZL: Record "VAT Ctrl. Report Header CZL";
        VATCtrlReportLineCZL1: Record "VAT Ctrl. Report Line CZL";
        VATCtrlReportLineCZL2: Record "VAT Ctrl. Report Line CZL";
        VATCtrlReportXmlDocument: XmlDocument;
    begin
        // [SCENARIO] Vat control report line is possible to exclude from export to xml.
        Initialize();

        // [GIVEN] The vat control report header has been created
        VATCtrlReportHeaderCZL := CreateVATCtrlReportHeader();

        // [GIVEN] Two vat control report lines with different sections have been created
        VATCtrlReportLineCZL1 := CreateVATCtrlReportLine(VATCtrlReportHeaderCZL."No.", SectionA4Tok);
        VATCtrlReportLineCZL2 := CreateVATCtrlReportLine(VATCtrlReportHeaderCZL."No.", SectionB2Tok);

        // [GIVEN] The first line has been excluded from export
        VATCtrlReportLineCZL1.Validate("Exclude from Export", true);
        VATCtrlReportLineCZL1.Modify();

        // [GIVEN] The vat control report has been released
        LibraryTaxCZL.ReleaseVATControlReport(VATCtrlReportHeaderCZL);
        Commit();

        // [WHEN] Export vat control report
        VATCtrlReportXmlDocument := ExportVATCtrlReport(VATCtrlReportHeaderCZL, Enum::"VAT Statement Report Selection"::Open, Enum::"VAT Ctrl. Report Decl Type CZL"::Recapitulative);

        // [THEN] The A4 statement won't be in the xml
        AssertXmlDocNodeNotExist(VATCtrlReportXmlDocument, '/Pisemnost/DPHKH1/VetaA4');
    end;

    [Test]
    [HandlerFunctions('ExportVATCtrDialogRequestPageHandler')]
    procedure ExportSupplementaryVATControlReport()
    var
        VATCtrlReportHeaderCZL: Record "VAT Ctrl. Report Header CZL";
        VATCtrlReportLineCZL1: Record "VAT Ctrl. Report Line CZL";
        VATCtrlReportLineCZL2: Record "VAT Ctrl. Report Line CZL";
        VATCtrlReportXmlDocument: XmlDocument;
    begin
        // [SCENARIO] Export supplementary vat control report to xml.
        Initialize();

        // [GIVEN] The vat control report header has been created
        VATCtrlReportHeaderCZL := CreateVATCtrlReportHeader();

        // [GIVEN] Two vat control report lines with different sections have been created
        VATCtrlReportLineCZL1 := CreateVATCtrlReportLine(VATCtrlReportHeaderCZL."No.", SectionA4Tok);
        VATCtrlReportLineCZL2 := CreateVATCtrlReportLine(VATCtrlReportHeaderCZL."No.", SectionB2Tok);

        // [GIVEN] The vat control report has been released
        LibraryTaxCZL.ReleaseVATControlReport(VATCtrlReportHeaderCZL);
        Commit();

        // [WHEN] Export supplementary vat control report
        VATCtrlReportXmlDocument := ExportVATCtrlReport(VATCtrlReportHeaderCZL, Enum::"VAT Statement Report Selection"::Open, Enum::"VAT Ctrl. Report Decl Type CZL"::Supplementary);

        // [THEN] The information regarding supplementary statement will be in the xml
        AssertXmlAttributeValue(VATCtrlReportXmlDocument, '/Pisemnost/DPHKH1/VetaD', 'khdph_forma', 'N');

        // [THEN] The statement A4 and B2 will be in the xml
        AssertXmlAttributeValue(VATCtrlReportXmlDocument, '/Pisemnost/DPHKH1/VetaA4', 'c_evid_dd', VATCtrlReportLineCZL1."Document No.");
        AssertXmlAttributeValue(VATCtrlReportXmlDocument, '/Pisemnost/DPHKH1/VetaB2', 'c_evid_dd', VATCtrlReportLineCZL2."External Document No.");
    end;

    local procedure AssertXmlDocNodeNotExist(var XMLDoc: XmlDocument; XPath: Text)
    var
        FoundNode: XmlNode;
    begin
        Assert.IsFalse(XMLDoc.SelectSingleNode(XPath, FoundNode), StrSubstNo(XmlNodeFoundErr, XPath));
    end;

    local procedure AssertXmlAttributeValue(var XMLDoc: XmlDocument; XPath: Text; AttributeName: Text; AttributeValue: Text)
    var
        XmlDOMManagement: Codeunit "XML DOM Management";
        FoundNode: XmlNode;
    begin
        Assert.IsTrue(XMLDoc.SelectSingleNode(XPath, FoundNode), StrSubstNo(XmlNodeNotFoundErr, XPath));
        Assert.AreEqual(XmlDOMManagement.GetAttributeValue(FoundNode, AttributeName), AttributeValue, UnexpectedAttributeValueErr);
    end;

    local procedure CreateVATCtrlReportHeader() VATCtrlReportHeaderCZL: Record "VAT Ctrl. Report Header CZL"
    var
        DateFromLastOpenVATPeriod: Date;
    begin
        DateFromLastOpenVATPeriod := LibraryTaxCZL.GetDateFromLastOpenVATPeriod();
        LibraryTaxCZL.CreateVATControlReportWithPeriod(VATCtrlReportHeaderCZL, Date2DMY(DateFromLastOpenVATPeriod, 2), Date2DMY(DateFromLastOpenVATPeriod, 3));
    end;

    local procedure CreateVATCtrlReportLine(SectionCode: Code[20]) VATCtrlReportLineCZL: Record "VAT Ctrl. Report Line CZL"
    begin
        VATCtrlReportLineCZL := CreateVATCtrlReportLine('', SectionCode);
    end;

    local procedure CreateVATCtrlReportLine(VATCtrlReportNo: Code[20]; SectionCode: Code[20]) VATCtrlReportLineCZL: Record "VAT Ctrl. Report Line CZL"
    var
        VATPostingSetup: Record "VAT Posting Setup";
        RecordRef: RecordRef;
    begin
        if VATCtrlReportNo = '' then
            VATCtrlReportNo := LibraryUtility.GenerateRandomCode(VATCtrlReportLineCZL.FieldNo("VAT Ctrl. Report No."), Database::"VAT Ctrl. Report Line CZL");

        LibraryERM.FindVATPostingSetup(VATPostingSetup, Enum::"Tax Calculation Type"::"Normal VAT");
        VATCtrlReportLineCZL.Init();
        VATCtrlReportLineCZL."VAT Ctrl. Report No." := VATCtrlReportNo;
        RecordRef.GetTable(VATCtrlReportLineCZL);
        VATCtrlReportLineCZL."Line No." := LibraryUtility.GetNewLineNo(RecordRef, VATCtrlReportLineCZL.FieldNo("Line No."));
        VATCtrlReportLineCZL."VAT Ctrl. Report Section Code" := SectionCode;
        VATCtrlReportLineCZL."Posting Date" := LibraryTaxCZL.GetDateFromLastOpenVATPeriod();
        VATCtrlReportLineCZL."VAT Date" := VATCtrlReportLineCZL."Posting Date";
        VATCtrlReportLineCZL."Original Document VAT Date" := VATCtrlReportLineCZL."VAT Date";
        VATCtrlReportLineCZL."Bill-to/Pay-to No." := LibrarySales.CreateCustomerNo();
        VATCtrlReportLineCZL."Document No." := LibraryUtility.GenerateGUID();
        VATCtrlReportLineCZL."External Document No." := LibraryUtility.GenerateGUID();
        VATCtrlReportLineCZL."VAT Registration No." := LibraryUtility.GenerateGUID();
        VATCtrlReportLineCZL.Type := VATCtrlReportLineCZL.Type::Sale;
        VATCtrlReportLineCZL."VAT Bus. Posting Group" := VATPostingSetup."VAT Bus. Posting Group";
        VATCtrlReportLineCZL."VAT Prod. Posting Group" := VATPostingSetup."VAT Prod. Posting Group";
        VATCtrlReportLineCZL."VAT Rate" := VATPostingSetup."VAT Rate CZL".AsInteger();
        VATCtrlReportLineCZL.Base := -LibraryRandom.RandDec(10000, 2);
        VATCtrlReportLineCZL.Amount := -LibraryRandom.RandDec(10000, 2);
        VATCtrlReportLineCZL.Insert();
    end;

    local procedure ChangeVATControlReportSection(var VATCtrlReportLineCZL: Record "VAT Ctrl. Report Line CZL"; SectionCode: Code[20])
    begin
        LibraryVariableStorage.Enqueue(SectionCode);
        VATCtrlReportLineCZL.ChangeVATControlRepSection();
    end;

    local procedure CloseVATControlReportLines(VATCtrlReportHeaderCZL: Record "VAT Ctrl. Report Header CZL"; ClosedDocumentNo: Code[20]; ClosedDate: Date)
    begin
        LibraryVariableStorage.Enqueue(ClosedDocumentNo);
        LibraryVariableStorage.Enqueue(ClosedDate);
        LibraryTaxCZL.CloseVATControlReportLines(VATCtrlReportHeaderCZL);
    end;

    local procedure ExportInternalDocCheckToExcel(VATCtrlReportHeaderCZL: Record "VAT Ctrl. Report Header CZL") ExportedFileName: Text
    var
        VATCtrlReportMgtCZL: Codeunit "VAT Ctrl. Report Mgt. CZL";
        VATCtrlReportUTCZL: Codeunit "VAT Ctrl. Report UT CZL";
    begin
        BindSubscription(VATCtrlReportUTCZL);
        VATCtrlReportMgtCZL.ExportInternalDocCheckToExcel(VATCtrlReportHeaderCZL, false);
        ExportedFileName := VATCtrlReportUTCZL.GetExportedFileName();
        UnbindSubscription(VATCtrlReportUTCZL);
    end;

    local procedure ExportVATCtrlReport(VATCtrlReportHeaderCZL: Record "VAT Ctrl. Report Header CZL"; EntriesSelection: Enum "VAT Statement Report Selection"; DeclarationType: Enum "VAT Ctrl. Report Decl Type CZL") XmlDoc: XmlDocument
    var
        TempBlob: Codeunit "Temp Blob";
        XmlDocumentInStream: InStream;
    begin
        LibraryVariableStorage.Enqueue(EntriesSelection);
        LibraryVariableStorage.Enqueue(DeclarationType);

        LibraryTaxCZL.RunExportVATCtrlReport(VATCtrlReportHeaderCZL, TempBlob);

        TempBlob.CreateInStream(XmlDocumentInStream);
        XMLDocument.ReadFrom(XmlDocumentInStream, XmlDoc);
    end;

    local procedure RunVATCtrlReportStatistic(var VATCtrlReportHeaderCZL: Record "VAT Ctrl. Report Header CZL")
    var
        VATCtrlReportLineCZL: Record "VAT Ctrl. Report Line CZL";
        VATCtrlReportCardCZL: TestPage "VAT Ctrl. Report Card CZL";
    begin
        VATCtrlReportLineCZL.SetRange("VAT Ctrl. Report No.", VATCtrlReportHeaderCZL."No.");
        if VATCtrlReportLineCZL.FindSet() then
            repeat
                LibraryVariableStorage.Enqueue(VATCtrlReportLineCZL."VAT Ctrl. Report Section Code");
                LibraryVariableStorage.Enqueue(VATCtrlReportLineCZL.Base);
                LibraryVariableStorage.Enqueue(VATCtrlReportLineCZL.Amount);
            until VATCtrlReportLineCZL.Next() = 0;

        VATCtrlReportCardCZL.OpenView();
        VATCtrlReportCardCZL.GoToRecord(VATCtrlReportHeaderCZL);
        VATCtrlReportCardCZL.Statistics.Invoke();
    end;

    local procedure RunVATCtrlReportTest(var VATCtrlReportHeaderCZL: Record "VAT Ctrl. Report Header CZL")
    var
        XmlParameters: Text;
    begin
        VATCtrlReportHeaderCZL.SetRecFilter();
        XmlParameters := Report.RunRequestPage(Report::"VAT Ctrl. Report - Test CZL");
        LibraryReportDataset.RunReportAndLoad(Report::"VAT Ctrl. Report - Test CZL", VATCtrlReportHeaderCZL, XmlParameters);
    end;

    internal procedure GetExportedFileName(): Text
    begin
        exit(LibraryVariableStorage.DequeueText());
    end;

    local procedure VerifyCellValueOnWorksheet(WorksheetNo: Integer; RowId: Integer; ColumnId: Integer; ExpectedValue: Text)
    begin
        Assert.AreEqual(
          ExpectedValue,
          LibraryReportValidation.GetValueFromSpecifiedCellOnWorksheet(WorksheetNo, RowId, ColumnId),
          StrSubstNo(IncorrectValueInCellOnWorksheetErr, WorksheetNo, RowId, ColumnId));
    end;

    [MessageHandler]
    procedure MessageHandler(Message: Text[1024])
    begin
        // Message Handler
    end;

    [ConfirmHandler]
    procedure YesConfirmHandler(Question: Text[1024]; var Reply: Boolean)
    begin
        Reply := true;
    end;

    [ModalPageHandler]
    procedure VATCtrlReportSectionsHandler(var VATCtrlReportSectionsCZL: TestPage "VAT Ctrl. Report Sections CZL")
    begin
        VATCtrlReportSectionsCZL.GoToKey(LibraryVariableStorage.DequeueText());
        VATCtrlReportSectionsCZL.OK().Invoke();
    end;

    [RequestPageHandler]
    procedure VATCtrlReportGetEntHandler(var VATCtrlReportGetEntCZL: TestRequestPage "VAT Ctrl. Report Get Ent. CZL")
    var
        VariantValue: Variant;
    begin
        LibraryVariableStorage.Dequeue(VariantValue);
        VATCtrlReportGetEntCZL.StartingDate.AssertEquals(VariantValue);
        LibraryVariableStorage.Dequeue(VariantValue);
        VATCtrlReportGetEntCZL.EndingDate.AssertEquals(VariantValue);
        LibraryVariableStorage.Dequeue(VariantValue);
        VATCtrlReportGetEntCZL.VATStatementTemplateCZL.AssertEquals(VariantValue);
        LibraryVariableStorage.Dequeue(VariantValue);
        VATCtrlReportGetEntCZL.VATStatementNameCZL.AssertEquals(VariantValue);
        LibraryVariableStorage.Dequeue(VariantValue);
        VATCtrlReportGetEntCZL.ProcessEntryTypeCZL.SetValue(VariantValue);
        VATCtrlReportGetEntCZL.OK().Invoke();
    end;

    [RequestPageHandler]
    procedure VATCtrlReportTestRequestPageHandler(var VATCtrlReportTestCZL: TestRequestPage "VAT Ctrl. Report - Test CZL")
    begin
        // Empty handler used to close the request page. We use default settings.
    end;

    [ModalPageHandler]
    procedure VATCtrlReportStatModalPageHandler(var VATCtrlReportStatCZL: TestPage "VAT Ctrl. Report Stat. CZL")
    begin
        while LibraryVariableStorage.Length() <> 0 do begin
            VATCtrlReportStatCZL.SubForm.Filter.SetFilter("VAT Ctrl. Report Section Code", LibraryVariableStorage.DequeueText());
            VATCtrlReportStatCZL.SubForm."Total Base".AssertEquals(LibraryVariableStorage.DequeueDecimal());
            VATCtrlReportStatCZL.SubForm."Total Amount".AssertEquals(LibraryVariableStorage.DequeueDecimal());
        end;
    end;

    [EventSubscriber(ObjectType::Codeunit, Codeunit::"File Management", 'OnBeforeDownloadHandler', '', false, false)]
    local procedure GetExcelFileNameOnBeforeDownloadHandler(FromFileName: Text; var IsHandled: Boolean)
    begin
        LibraryVariableStorage.Enqueue(FromFileName);
        IsHandled := true;
    end;

    [ModalPageHandler]
    procedure GetDocumentNoAndDateModalPageHandler(var GetDocumentNoAndDateCZL: TestPage "Get Document No. and Date CZL");
    begin
        GetDocumentNoAndDateCZL.ClosedDocNo.SetValue(LibraryVariableStorage.DequeueText());
        GetDocumentNoAndDateCZL.ClosedDate.SetValue(LibraryVariableStorage.DequeueDate());
        GetDocumentNoAndDateCZL.OK().Invoke();
    end;

    [RequestPageHandler]
    procedure ExportVATCtrDialogRequestPageHandler(var ExportVATCtrlDialogCZL: TestRequestPage "Export VAT Ctrl. Dialog CZL")
    begin
        ExportVATCtrlDialogCZL.SelectionField.SetValue(LibraryVariableStorage.DequeueInteger());
        ExportVATCtrlDialogCZL.DeclarationTypeField.SetValue(LibraryVariableStorage.DequeueInteger());
        ExportVATCtrlDialogCZL.OK().Invoke();
    end;
}