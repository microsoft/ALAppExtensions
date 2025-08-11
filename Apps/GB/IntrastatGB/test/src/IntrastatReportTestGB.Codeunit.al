codeunit 10505 "Intrastat Report Test GB"
{
    Subtype = Test;
    TestType = Uncategorized;
    TestPermissions = Disabled;

    trigger OnRun()
    begin
        // [FEATURE] [Intrastat GB]
        IsInitialized := false;
    end;

    var
        Assert: Codeunit Assert;
        LibraryTestInitialize: Codeunit "Library - Test Initialize";
        LibraryIntrastat: Codeunit "Library - Intrastat";
        LibraryUtility: Codeunit "Library - Utility";
        LibraryRandom: Codeunit "Library - Random";
        LibraryERM: Codeunit "Library - ERM";
        IsInitialized: Boolean;
        DataExchFileContentMissingErr: Label 'Data Exch File Content must not be empty';
        IntrastatFileOutputErr: Label 'Intrastat has exported incorrectly to file output.';

    [Test]
    [HandlerFunctions('IntrastatReportGetLinesPageHandler,StrMenuHandlerShpt')]
    procedure E2EIntrastatReportGBFileCreationShpt()
    var
        SalesLine: Record "Sales Line";
        ShipmentMethod: Record "Shipment Method";
        TransactionType: Record "Transaction Type";
        IntrastatReportPage: TestPage "Intrastat Report";
        InvoiceDate: Date;
        IntrastatReportNo: Code[20];
    begin
        // [FEATURE] [Intrastat Report GB] [File Validation]
        // [SCENARIO] End to end file creation
        // [GIVEN] Posted Sales Order for intrastat
        // [GIVEN] Report Template and Batch        
        Initialize();
        InvoiceDate := CalcDate('<5Y>');
        LibraryIntrastat.CreateAndPostSalesOrder(SalesLine, InvoiceDate);
        CreateIntrastatReportAndSuggestLines(InvoiceDate, IntrastatReportNo);
        Commit();

        // [GIVEN] A Intrastat Report
        IntrastatReportPage.OpenEdit();
        IntrastatReportPage.Filter.SetFilter("No.", IntrastatReportNo);
        TransactionType.Code := CopyStr(LibraryUtility.GenerateGUID(), 3, 2);
        TransactionType.Insert();
        IntrastatReportPage.IntrastatLines."Transaction Type".Value(TransactionType.Code);
        IntrastatReportPage.IntrastatLines.Quantity.Value(Format(LibraryRandom.RandInt(20)));
        IntrastatReportPage.IntrastatLines."Total Weight".Value(Format(LibraryRandom.RandInt(20)));
        IntrastatReportPage.IntrastatLines."Statistical Value".Value(Format(LibraryRandom.RandInt(100)));

        ShipmentMethod.FindFirst();
        IntrastatReportPage.IntrastatLines."Shpt. Method Code".Value(ShipmentMethod.Code);
        IntrastatReportPage.IntrastatLines."Partner VAT ID".Value('111111111');
        IntrastatReportPage.ChecklistReport.Invoke();

        // [THEN] No errors surfaced from checklist
        IntrastatReportPage.ErrorMessagesPart."Field Name".AssertEquals('');

        // [WHEN] Running Create File
        IntrastatReportPage.CreateFile.Invoke(); 

        // [THEN] Check file content for shipment
        CheckFileContentForShpt(IntrastatReportPage, 'D', 'X');
        IntrastatReportPage.Close();
    end;

    [Test]
    [HandlerFunctions('IntrastatReportGetLinesPageHandler,StrMenuHandlerRcpt')]
    procedure E2EIntrastatReportGBFileCreationRcpt()
    var
        PurchaseLine: Record "Purchase Line";
        ShipmentMethod: Record "Shipment Method";
        TransactionType: Record "Transaction Type";
        IntrastatReportPage: TestPage "Intrastat Report";
        InvoiceDate: Date;
        IntrastatReportNo: Code[20];
    begin
        // [FEATURE] [Intrastat Report GB] [File Validation]
        // [SCENARIO] End to end file creation
        // [GIVEN] Posted Purchase Order for intrastat
        // [GIVEN] Report Template and Batch        
        Initialize();
        InvoiceDate := CalcDate('<5Y>');
        LibraryIntrastat.CreateAndPostPurchaseOrder(PurchaseLine, InvoiceDate);
        CreateIntrastatReportAndSuggestLines(InvoiceDate, IntrastatReportNo);
        Commit();

        // [GIVEN] A Intrastat Report
        IntrastatReportPage.OpenEdit();
        IntrastatReportPage.Filter.SetFilter("No.", IntrastatReportNo);
        TransactionType.Code := CopyStr(LibraryUtility.GenerateGUID(), 3, 2);
        TransactionType.Insert();
        IntrastatReportPage.IntrastatLines."Transaction Type".Value(TransactionType.Code);
        IntrastatReportPage.IntrastatLines.Quantity.Value(Format(LibraryRandom.RandInt(20)));
        IntrastatReportPage.IntrastatLines."Total Weight".Value(Format(LibraryRandom.RandInt(20)));
        IntrastatReportPage.IntrastatLines."Statistical Value".Value(Format(LibraryRandom.RandInt(100)));

        ShipmentMethod.FindFirst();
        IntrastatReportPage.IntrastatLines."Shpt. Method Code".Value(ShipmentMethod.Code);
        IntrastatReportPage.IntrastatLines."Partner VAT ID".Value('111111111');
        IntrastatReportPage.ChecklistReport.Invoke();

        // [THEN] No errors surfaced from checklist
        IntrastatReportPage.ErrorMessagesPart."Field Name".AssertEquals('');

        // [WHEN] Running Create File
        IntrastatReportPage.CreateFile.Invoke(); 

        // [THEN] Check file content for receipt
        CheckFileContentForRcpt(IntrastatReportPage, 'A', 'X');
        IntrastatReportPage.Close();
    end;

    local procedure Initialize()
    var
        LibraryERMCountryData: Codeunit "Library - ERM Country Data";
        GLSetupVATCalculation: Enum "G/L Setup VAT Calculation";
    begin
        LibraryTestInitialize.OnTestInitialize(CODEUNIT::"Intrastat Report Test");

        if IsInitialized then
            exit;
        LibraryTestInitialize.OnBeforeTestSuiteInitialize(CODEUNIT::"Intrastat Report Test");
        UpdateIntrastatCodeInCountryRegion();
        LibraryERMCountryData.CreateVATData();
        LibraryERMCountryData.CreateGeneralPostingSetupData();
        LibraryERMCountryData.UpdateSalesReceivablesSetup();
        LibraryERMCountryData.UpdatePurchasesPayablesSetup();
        LibraryERMCountryData.UpdateGeneralPostingSetup();
        LibraryERM.SetBillToSellToVATCalc(GLSetupVATCalculation::"Bill-to/Pay-to No.");
        LibraryIntrastat.CreateIntrastatReportSetup();
        LibraryIntrastat.CreateIntrastatDataExchangeDefinition();
        CreateIntrastatReportChecklist();

        IsInitialized := true;
        Commit();
        LibraryTestInitialize.OnAfterTestSuiteInitialize(CODEUNIT::"Intrastat Report Test");
    end;

    local procedure CreateIntrastatReportChecklist()
    var
        IntrastatReportChecklist: Record "Intrastat Report Checklist";
        IntrastatReportLine: Record "Intrastat Report Line";
    begin
        IntrastatReportChecklist.DeleteAll();

        CreateIntrastatReportChecklistRecord(IntrastatReportLine.FieldNo("Tariff No."), '');
        CreateIntrastatReportChecklistRecord(IntrastatReportLine.FieldNo("Country/Region Code"), '');
        CreateIntrastatReportChecklistRecord(IntrastatReportLine.FieldNo("Transaction Type"), '');
        CreateIntrastatReportChecklistRecord(IntrastatReportLine.FieldNo(Quantity), 'Supplementary Units: True');
        CreateIntrastatReportChecklistRecord(IntrastatReportLine.FieldNo("Total Weight"), 'Supplementary Units: False');
        CreateIntrastatReportChecklistRecord(IntrastatReportLine.FieldNo("Country/Region of Origin Code"), 'Type: Shipment');
        CreateIntrastatReportChecklistRecord(IntrastatReportLine.FieldNo("Partner VAT ID"), 'Type: Shipment');
    end;

    local procedure CreateIntrastatReportChecklistRecord(FieldNo: Integer; FilterExpression: Text[1024])
    var
        IntrastatReportChecklist: Record "Intrastat Report Checklist";
    begin
        IntrastatReportChecklist.Init();
        IntrastatReportChecklist.Validate("Field No.", FieldNo);
        if FilterExpression <> '' then
            IntrastatReportChecklist.Validate("Filter Expression", FilterExpression);
        if IntrastatReportChecklist.Insert() then;
    end;

    local procedure UpdateIntrastatCodeInCountryRegion()
    var
        CompanyInformation: Record "Company Information";
        CountryRegion: Record "Country/Region";
    begin
        CompanyInformation.Get();
        CompanyInformation."Bank Account No." := '';
        CompanyInformation.Modify();
        CountryRegion.Get(CompanyInformation."Country/Region Code");
        if CountryRegion."Intrastat Code" = '' then begin
            CountryRegion.Validate("Intrastat Code", CountryRegion.Code);
            CountryRegion.Modify(true);
        end;
    end;
   
    local procedure CheckFileContentForShpt(var IntrastatReportPage: TestPage "Intrastat Report"; FileType: Char; HasData: Char)
    var
        DataExch: Record "Data Exch.";
        CompanyInfo: Record "Company Information";
        FileMgt: Codeunit "File Management";
        LibraryTextFileValidation: Codeunit "Library - Text File Validation";
        TempBlob: Codeunit "Temp Blob";
        FileName: Text;
        Header, Line1: Text;
        TabChar: Char;
        DecVar: Decimal;
    begin
        DataExch.FindLast();
        Assert.IsTrue(DataExch."File Content".HasValue(), DataExchFileContentMissingErr);
        
        DataExch.CalcFields("File Content");
        TempBlob.FromRecord(DataExch, DataExch.FieldNo("File Content"));

        FileName := FileMgt.ServerTempFileName('txt');
        FileMgt.BLOBExportToServerFile(TempBlob, FileName);

        TabChar := ',';
        Header := LibraryTextFileValidation.ReadLine(FileName, 1);
        CompanyInfo.Get();  

        // Verify header line
        Assert.AreEqual('T', LibraryTextFileValidation.ReadField(Header, 1, TabChar), IntrastatFileOutputErr);
        Assert.AreEqual(CompanyInfo."VAT Registration No.", LibraryTextFileValidation.ReadField(Header, 2, TabChar), IntrastatFileOutputErr);
        Assert.AreEqual('', LibraryTextFileValidation.ReadField(Header, 3, TabChar), IntrastatFileOutputErr);
        Assert.AreEqual(CopyStr(CompanyInfo.Name,1,9), LibraryTextFileValidation.ReadField(Header, 4, TabChar), IntrastatFileOutputErr); 
        Assert.AreEqual(CopyStr(CompanyInfo.Name,11,30), LibraryTextFileValidation.ReadField(Header, 5, TabChar), IntrastatFileOutputErr);
        Assert.AreEqual(HasData, LibraryTextFileValidation.ReadField(Header, 6, TabChar), IntrastatFileOutputErr);
        Assert.AreEqual(FileType, LibraryTextFileValidation.ReadField(Header, 7, TabChar), IntrastatFileOutputErr);
        Assert.AreEqual(Format(WorkDate(), 0, '<Day,2><Month,2><Year,2>'), LibraryTextFileValidation.ReadField(Header, 8, TabChar), IntrastatFileOutputErr);
        Assert.AreEqual(CopyStr(IntrastatReportPage."Statistics Period".Value(), 3, 2) + CopyStr(IntrastatReportPage."Statistics Period".Value(), 1, 2), LibraryTextFileValidation.ReadField(Header, 9, TabChar), IntrastatFileOutputErr);
        Assert.AreEqual('CSV02', LibraryTextFileValidation.ReadField(Header, 10, TabChar), IntrastatFileOutputErr);

        // Verify Line
        Line1 := LibraryTextFileValidation.ReadLine(FileName, 2);
        IntrastatReportPage.IntrastatLines."Tariff No.".AssertEquals(LibraryTextFileValidation.ReadField(Line1, 1, TabChar));
        Evaluate(DecVar, LibraryTextFileValidation.ReadField(Line1, 2, TabChar));
        IntrastatReportPage.IntrastatLines."Statistical Value".AssertEquals(DecVar);
        IntrastatReportPage.IntrastatLines."Shpt. Method Code".AssertEquals(LibraryTextFileValidation.ReadField(Line1, 3, TabChar));
        IntrastatReportPage.IntrastatLines."Transaction Type".AssertEquals(LibraryTextFileValidation.ReadField(Line1, 4, TabChar));
        Evaluate(DecVar, LibraryTextFileValidation.ReadField(Line1, 5, TabChar));
        IntrastatReportPage.IntrastatLines."Total Weight".AssertEquals(DecVar);
        IntrastatReportPage.IntrastatLines."Supplementary Quantity".AssertEquals(LibraryTextFileValidation.ReadField(Line1, 6, TabChar));
        IntrastatReportPage.IntrastatLines."Country/Region Code".AssertEquals(LibraryTextFileValidation.ReadField(Line1, 7, TabChar));
        IntrastatReportPage.IntrastatLines."Partner VAT ID".AssertEquals(LibraryTextFileValidation.ReadField(Line1, 8, TabChar));
        IntrastatReportPage.IntrastatLines."Country/Region of Origin Code".AssertEquals(LibraryTextFileValidation.ReadField(Line1, 9, TabChar));
        IntrastatReportPage.IntrastatLines."Document No.".AssertEquals(LibraryTextFileValidation.ReadField(Line1, 10, TabChar));
    end;

    local procedure CheckFileContentForRcpt(var IntrastatReportPage: TestPage "Intrastat Report"; FileType: Char; HasData: Char)
    var
        DataExch: Record "Data Exch.";
        CompanyInfo: Record "Company Information";
        FileMgt: Codeunit "File Management";
        LibraryTextFileValidation: Codeunit "Library - Text File Validation";
        TempBlob: Codeunit "Temp Blob";
        FileName: Text;
        Header, Line1: Text;
        TabChar: Char;
        DecVar: Decimal;
    begin
        DataExch.FindLast();
        Assert.IsTrue(DataExch."File Content".HasValue(), DataExchFileContentMissingErr);
        
        DataExch.CalcFields("File Content");
        TempBlob.FromRecord(DataExch, DataExch.FieldNo("File Content"));

        FileName := FileMgt.ServerTempFileName('txt');
        FileMgt.BLOBExportToServerFile(TempBlob, FileName);

        TabChar := ',';
        Header := LibraryTextFileValidation.ReadLine(FileName, 1);
        CompanyInfo.Get();  

        // Verify header line
        Assert.AreEqual('T', LibraryTextFileValidation.ReadField(Header, 1, TabChar), IntrastatFileOutputErr);
        Assert.AreEqual(CompanyInfo."VAT Registration No.", LibraryTextFileValidation.ReadField(Header, 2, TabChar), IntrastatFileOutputErr);
        Assert.AreEqual('', LibraryTextFileValidation.ReadField(Header, 3, TabChar), IntrastatFileOutputErr);
        Assert.AreEqual(CopyStr(CompanyInfo.Name,1,9), LibraryTextFileValidation.ReadField(Header, 4, TabChar), IntrastatFileOutputErr); 
        Assert.AreEqual(CopyStr(CompanyInfo.Name,11,30), LibraryTextFileValidation.ReadField(Header, 5, TabChar), IntrastatFileOutputErr);
        Assert.AreEqual(HasData, LibraryTextFileValidation.ReadField(Header, 6, TabChar), IntrastatFileOutputErr);
        Assert.AreEqual(FileType, LibraryTextFileValidation.ReadField(Header, 7, TabChar), IntrastatFileOutputErr);
        Assert.AreEqual(Format(WorkDate(), 0, '<Day,2><Month,2><Year,2>'), LibraryTextFileValidation.ReadField(Header, 8, TabChar), IntrastatFileOutputErr);
        Assert.AreEqual(CopyStr(IntrastatReportPage."Statistics Period".Value(), 3, 2) + CopyStr(IntrastatReportPage."Statistics Period".Value(), 1, 2), LibraryTextFileValidation.ReadField(Header, 9, TabChar), IntrastatFileOutputErr);
        Assert.AreEqual('CSV02', LibraryTextFileValidation.ReadField(Header, 10, TabChar), IntrastatFileOutputErr);        

        // Verify Line
        Line1 := LibraryTextFileValidation.ReadLine(FileName, 2);
        IntrastatReportPage.IntrastatLines."Tariff No.".AssertEquals(LibraryTextFileValidation.ReadField(Line1, 1, TabChar));
        Evaluate(DecVar, LibraryTextFileValidation.ReadField(Line1, 2, TabChar));
        IntrastatReportPage.IntrastatLines."Statistical Value".AssertEquals(DecVar);
        IntrastatReportPage.IntrastatLines."Shpt. Method Code".AssertEquals(LibraryTextFileValidation.ReadField(Line1, 3, TabChar));
        IntrastatReportPage.IntrastatLines."Transaction Type".AssertEquals(LibraryTextFileValidation.ReadField(Line1, 4, TabChar));
        Evaluate(DecVar, LibraryTextFileValidation.ReadField(Line1, 5, TabChar));
        IntrastatReportPage.IntrastatLines."Total Weight".AssertEquals(DecVar);
        IntrastatReportPage.IntrastatLines."Supplementary Quantity".AssertEquals(LibraryTextFileValidation.ReadField(Line1, 6, TabChar));
        IntrastatReportPage.IntrastatLines."Country/Region Code".AssertEquals(LibraryTextFileValidation.ReadField(Line1, 7, TabChar));
        IntrastatReportPage.IntrastatLines."Document No.".AssertEquals(LibraryTextFileValidation.ReadField(Line1, 8, TabChar));
    end;

    procedure CreateIntrastatReportAndSuggestLines(ReportDate: Date; var IntrastatReportNo: Code[20])
    begin
        LibraryIntrastat.CreateIntrastatReport(ReportDate, IntrastatReportNo);
        InvokeSuggestLinesOnIntrastatReport(IntrastatReportNo);
    end;

    procedure InvokeSuggestLinesOnIntrastatReport(IntrastatReportNo: Code[20])
    var
        IntrastatReport: TestPage "Intrastat Report";
    begin
        IntrastatReport.OpenEdit();
        IntrastatReport.Filter.SetFilter("No.", IntrastatReportNo);
        IntrastatReport.GetEntries.Invoke();
    end;

    [RequestPageHandler]
    procedure IntrastatReportGetLinesPageHandler(var RequestPage: TestRequestPage "Intrastat Report Get Lines")
    begin
        RequestPage.OK().Invoke();
    end;

    [StrMenuHandler]
    procedure StrMenuHandlerRcpt(Options: Text; var Choice: Integer; Instruction: Text)
    begin
        Choice := 1;        
    end;

    [StrMenuHandler]
    procedure StrMenuHandlerShpt(Options: Text; var Choice: Integer; Instruction: Text)
    begin
        Choice := 2;        
    end;


}
