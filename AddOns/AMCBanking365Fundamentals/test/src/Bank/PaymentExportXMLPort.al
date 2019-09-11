codeunit 134423 "Payment Export XMLPort"
{
    Permissions = TableData "Data Exch." = i;
    Subtype = Test;
    TestPermissions = Disabled;

    trigger OnRun()
    begin
        // [FEATURE] [Export] [Data Exchange]
    end;

    var
        LibraryXPathXMLReader: Codeunit "Library - XPath XML Reader";
        LibraryUtility: Codeunit "Library - Utility";
        LibraryRandom: Codeunit "Library - Random";

    [Test]
    [Scope('OnPrem')]
    procedure ExportAMCXMLSunshine()
    var
        CompanyInfo: Record "Company Information";
        DataExchColumnDef: Record "Data Exch. Column Def";
        DataExch: Record "Data Exch.";
        DataExchDef: Record "Data Exch. Def";
        DataExchField: Record "Data Exch. Field";
        TempBlob: Codeunit "Temp Blob";
        OutStream: OutStream;
        ExportTextArray: array[10, 100] of Text[250];
        i: Integer;
    begin
        // Setup
        CompanyInfo.Get();
        CompanyInfo.County := LibraryUtility.GenerateGUID();
        CompanyInfo.Modify();

        SetupExport(TempBlob, DataExch, DataExchDef, ExportTextArray, XMLPORT::"AMC Bank Export CreditTransfer",
          DataExchDef."File Type"::Xml);
        SetupAMCColumnDef(DataExchDef.Code);
        DataExchColumnDef.SetRange("Data Exch. Def Code", DataExchDef.Code);
        DataExchColumnDef.SetRange("Data Exch. Line Def Code", DataExchDef.Code);

        for i := 1 to ArrayLen(ExportTextArray, 1) do
            CreateDataExchFieldForLine(ExportTextArray, i, DataExch."Entry No.", 1, 1,
              DataExchColumnDef.Count(), DataExchDef.Code);

        // Execute
        TempBlob.CreateOutStream(OutStream);
        DataExchField.Init();
        DataExchField.SetRange("Data Exch. No.", DataExch."Entry No.");
        XMLPORT.Export(DataExchDef."Reading/Writing XMLport", OutStream, DataExchField);

        // Verify Stream Content.
        VerifyAMCOutput(ExportTextArray, TempBlob, DataExchDef.Code);
    end;

    [Test]
    [Scope('OnPrem')]
    procedure ExportAMCXMLMissingPath()
    var
        DataExchColumnDef: Record "Data Exch. Column Def";
        DataExch: Record "Data Exch.";
        DataExchDef: Record "Data Exch. Def";
        DataExchField: Record "Data Exch. Field";
        TempBlob: Codeunit "Temp Blob";
        OutStream: OutStream;
        ExportTextArray: array[10, 100] of Text[250];
        xPath: Text;
        i: Integer;
    begin
        // Setup
        SetupExport(TempBlob, DataExch, DataExchDef, ExportTextArray, XMLPORT::"AMC Bank Export CreditTransfer",
          DataExchDef."File Type"::Xml);
        SetupAMCColumnDef(DataExchDef.Code);
        DataExchColumnDef.SetRange("Data Exch. Def Code", DataExchDef.Code);
        DataExchColumnDef.SetRange("Data Exch. Line Def Code", DataExchDef.Code);

        for i := 1 to ArrayLen(ExportTextArray, 1) do
            CreateDataExchFieldForLine(ExportTextArray, i, DataExch."Entry No.", 1, 1,
              DataExchColumnDef.Count(), DataExchDef.Code);

        DataExchColumnDef.Next(LibraryRandom.RandInt(DataExchColumnDef.Count()));
        xPath := DataExchColumnDef.Path;
        DataExchColumnDef.Path := '';
        DataExchColumnDef.Modify();

        // Execute
        TempBlob.CreateOutStream(OutStream);
        DataExchField.Init();
        DataExchField.SetRange("Data Exch. No.", DataExch."Entry No.");
        XMLPORT.Export(DataExchDef."Reading/Writing XMLport", OutStream, DataExchField);

        // Verify Stream Content.
        LibraryXPathXMLReader.InitializeWithBlob(TempBlob, 'http://soap.xml.link.amc.dk/');
        LibraryXPathXMLReader.VerifyNodeCountWithValueByXPath(xPath, '', 0);
    end;

    local procedure SetupAMCColumnDef(DataExchDefCode: Code[20])
    begin
        CreateDataExchColumnDef(DataExchDefCode, DataExchDefCode, 1,
          '/paymentExportBank/amcpaymentreq/banktransjournal/bankagreementlevel1');
        CreateDataExchColumnDef(DataExchDefCode, DataExchDefCode, 2,
          '/paymentExportBank/amcpaymentreq/banktransjournal/uniqueid');
        CreateDataExchColumnDef(DataExchDefCode, DataExchDefCode, 3,
          '/paymentExportBank/amcpaymentreq/banktransjournal/transmissionref1');
        CreateDataExchColumnDef(DataExchDefCode, DataExchDefCode, 4,
          '/paymentExportBank/amcpaymentreq/banktransjournal/messageref');
        CreateDataExchColumnDef(DataExchDefCode, DataExchDefCode, 5, '/paymentExportBank/bank');

        CreateDataExchColumnDef(DataExchDefCode, DataExchDefCode, 6,
          '/paymentExportBank/amcpaymentreq/banktransjournal/banktransus/bankaccountident/bankaccount');
        CreateDataExchColumnDef(DataExchDefCode, DataExchDefCode, 7,
          '/paymentExportBank/amcpaymentreq/banktransjournal/banktransus/bankaccountident/intregno');
        CreateDataExchColumnDef(DataExchDefCode, DataExchDefCode, 8,
          '/paymentExportBank/amcpaymentreq/banktransjournal/banktransus/bankaccountident/intregnotype');
        CreateDataExchColumnDef(DataExchDefCode, DataExchDefCode, 9,
          '/paymentExportBank/amcpaymentreq/banktransjournal/banktransus/bankaccountident/swiftcode');
        CreateDataExchColumnDef(DataExchDefCode, DataExchDefCode, 10,
          '/paymentExportBank/amcpaymentreq/banktransjournal/banktransus/bankaccountcurrency');
        CreateDataExchColumnDef(DataExchDefCode, DataExchDefCode, 11,
          '/paymentExportBank/amcpaymentreq/banktransjournal/banktransus/messagetoownbank');
        CreateDataExchColumnDef(DataExchDefCode, DataExchDefCode, 12,
          '/paymentExportBank/amcpaymentreq/banktransjournal/banktransus/ownreference');
        CreateDataExchColumnDef(DataExchDefCode, DataExchDefCode, 13,
          '/paymentExportBank/amcpaymentreq/banktransjournal/banktransus/uniqueid');
        CreateDataExchColumnDef(DataExchDefCode, DataExchDefCode, 14,
          '/paymentExportBank/amcpaymentreq/banktransjournal/banktransus/banktransthem/shortadvice');
        CreateDataExchColumnDef(DataExchDefCode, DataExchDefCode, 15,
          '/paymentExportBank/amcpaymentreq/banktransjournal/banktransus/banktransthem/customerid');
        CreateDataExchColumnDef(DataExchDefCode, DataExchDefCode, 16,
          '/paymentExportBank/amcpaymentreq/banktransjournal/banktransus/banktransthem/costs');
        CreateDataExchColumnDef(DataExchDefCode, DataExchDefCode, 17,
          '/paymentExportBank/amcpaymentreq/banktransjournal/banktransus/banktransthem/paymenttype');
        CreateDataExchColumnDef(DataExchDefCode, DataExchDefCode, 18,
          '/paymentExportBank/amcpaymentreq/banktransjournal/banktransus/banktransthem/reference');
        CreateDataExchColumnDef(DataExchDefCode, DataExchDefCode, 19,
          '/paymentExportBank/amcpaymentreq/banktransjournal/banktransus/banktransthem/uniqueid');
        CreateDataExchColumnDef(DataExchDefCode, DataExchDefCode, 20,
          '/paymentExportBank/amcpaymentreq/banktransjournal/banktransus/banktransthem/receiversaddress/address1');
        CreateDataExchColumnDef(DataExchDefCode, DataExchDefCode, 21,
          '/paymentExportBank/amcpaymentreq/banktransjournal/banktransus/banktransthem/receiversaddress/address2');
        CreateDataExchColumnDef(DataExchDefCode, DataExchDefCode, 22,
          '/paymentExportBank/amcpaymentreq/banktransjournal/banktransus/banktransthem/receiversaddress/city');
        CreateDataExchColumnDef(DataExchDefCode, DataExchDefCode, 23,
          '/paymentExportBank/amcpaymentreq/banktransjournal/banktransus/banktransthem/receiversaddress/name');
        CreateDataExchColumnDef(DataExchDefCode, DataExchDefCode, 24,
          '/paymentExportBank/amcpaymentreq/banktransjournal/banktransus/banktransthem/receiversaddress/countryiso');
        CreateDataExchColumnDef(DataExchDefCode, DataExchDefCode, 25,
          '/paymentExportBank/amcpaymentreq/banktransjournal/banktransus/banktransthem/receiversaddress/zipcode');
        CreateDataExchColumnDef(DataExchDefCode, DataExchDefCode, 26,
          '/paymentExportBank/amcpaymentreq/banktransjournal/banktransus/banktransthem/receiversbankaccount/bankaccount');
        CreateDataExchColumnDef(DataExchDefCode, DataExchDefCode, 27,
          '/paymentExportBank/amcpaymentreq/banktransjournal/banktransus/banktransthem/receiversbankaccount/intregno');
        CreateDataExchColumnDef(DataExchDefCode, DataExchDefCode, 28,
          '/paymentExportBank/amcpaymentreq/banktransjournal/banktransus/banktransthem/receiversbankaccount/intregnotype');
        CreateDataExchColumnDef(DataExchDefCode, DataExchDefCode, 29,
          '/paymentExportBank/amcpaymentreq/banktransjournal/banktransus/banktransthem/receiversbankaccount/swiftcode');
        CreateDataExchColumnDef(DataExchDefCode, DataExchDefCode, 30,
          '/paymentExportBank/amcpaymentreq/banktransjournal/banktransus/banktransthem/emailadvice/recipient');
        CreateDataExchColumnDef(DataExchDefCode, DataExchDefCode, 31,
          '/paymentExportBank/amcpaymentreq/banktransjournal/banktransus/banktransthem/emailadvice/subject');
        CreateDataExchColumnDef(DataExchDefCode, DataExchDefCode, 32,
          '/paymentExportBank/amcpaymentreq/banktransjournal/banktransus/banktransthem/emailadvice/paymentmessage/linenum');
        CreateDataExchColumnDef(DataExchDefCode, DataExchDefCode, 33,
          '/paymentExportBank/amcpaymentreq/banktransjournal/banktransus/banktransthem/emailadvice/paymentmessage/text');
        CreateDataExchColumnDef(DataExchDefCode, DataExchDefCode, 34,
          '/paymentExportBank/amcpaymentreq/banktransjournal/banktransus/banktransthem/paymentmessage/linenum');
        CreateDataExchColumnDef(DataExchDefCode, DataExchDefCode, 35,
          '/paymentExportBank/amcpaymentreq/banktransjournal/banktransus/banktransthem/paymentmessage/text');
        CreateDataExchColumnDef(DataExchDefCode, DataExchDefCode, 36,
          '/paymentExportBank/amcpaymentreq/banktransjournal/banktransus/banktransthem/amountdetails/payamount');
        CreateDataExchColumnDef(DataExchDefCode, DataExchDefCode, 37,
          '/paymentExportBank/amcpaymentreq/banktransjournal/banktransus/banktransthem/amountdetails/paycurrency');
        CreateDataExchColumnDef(DataExchDefCode, DataExchDefCode, 38,
          '/paymentExportBank/amcpaymentreq/banktransjournal/banktransus/banktransthem/amountdetails/paydate');
        CreateDataExchColumnDef(DataExchDefCode, DataExchDefCode, 39,
          '/paymentExportBank/amcpaymentreq/banktransjournal/banktransus/banktransthem/banktransspec/origamount');
        CreateDataExchColumnDef(DataExchDefCode, DataExchDefCode, 40,
          '/paymentExportBank/amcpaymentreq/banktransjournal/banktransus/banktransthem/banktransspec/origdate');
        CreateDataExchColumnDef(DataExchDefCode, DataExchDefCode, 41,
          '/paymentExportBank/amcpaymentreq/banktransjournal/banktransus/banktransthem/banktransspec/invoiceref');

        CreateDataExchColumnDef(DataExchDefCode, DataExchDefCode, 42,
          '/paymentExportBank/amcpaymentreq/banktransjournal/banktransus/banktransthem/receiversbankaccount/bankaccountaddress/address1');
        CreateDataExchColumnDef(DataExchDefCode, DataExchDefCode, 43,
          '/paymentExportBank/amcpaymentreq/banktransjournal/banktransus/banktransthem/receiversbankaccount/bankaccountaddress/address2');
        CreateDataExchColumnDef(DataExchDefCode, DataExchDefCode, 44,
          '/paymentExportBank/amcpaymentreq/banktransjournal/banktransus/banktransthem/receiversbankaccount/bankaccountaddress/city');
        CreateDataExchColumnDef(DataExchDefCode, DataExchDefCode, 45,
          '/paymentExportBank/amcpaymentreq/banktransjournal/banktransus/banktransthem/receiversbankaccount/bankaccountaddress/name');
        CreateDataExchColumnDef(DataExchDefCode, DataExchDefCode, 46,
          '/paymentExportBank/amcpaymentreq/banktransjournal/banktransus/banktransthem/receiversbankaccount/bankaccountaddress/countryiso');
        CreateDataExchColumnDef(DataExchDefCode, DataExchDefCode, 47,
          '/paymentExportBank/amcpaymentreq/banktransjournal/banktransus/banktransthem/receiversbankaccount/bankaccountaddress/zipcode');

        CreateDataExchColumnDef(DataExchDefCode, DataExchDefCode, 48,
          '/paymentExportBank/amcpaymentreq/banktransjournal/banktransus/bankaccountident/bankaccountaddress/address1');
        CreateDataExchColumnDef(DataExchDefCode, DataExchDefCode, 49,
          '/paymentExportBank/amcpaymentreq/banktransjournal/banktransus/bankaccountident/bankaccountaddress/address2');
        CreateDataExchColumnDef(DataExchDefCode, DataExchDefCode, 50,
          '/paymentExportBank/amcpaymentreq/banktransjournal/banktransus/bankaccountident/bankaccountaddress/city');
        CreateDataExchColumnDef(DataExchDefCode, DataExchDefCode, 51,
          '/paymentExportBank/amcpaymentreq/banktransjournal/banktransus/bankaccountident/bankaccountaddress/name');
        CreateDataExchColumnDef(DataExchDefCode, DataExchDefCode, 52,
          '/paymentExportBank/amcpaymentreq/banktransjournal/banktransus/bankaccountident/bankaccountaddress/countryiso');
        CreateDataExchColumnDef(DataExchDefCode, DataExchDefCode, 53,
          '/paymentExportBank/amcpaymentreq/banktransjournal/banktransus/bankaccountident/bankaccountaddress/zipcode');

        CreateDataExchColumnDef(DataExchDefCode, DataExchDefCode, 54,
          '/paymentExportBank/amcpaymentreq/banktransjournal/banktransus/banktransthem/banktransspec/amountdetails/payamount');
        CreateDataExchColumnDef(DataExchDefCode, DataExchDefCode, 55,
          '/paymentExportBank/amcpaymentreq/banktransjournal/banktransus/banktransthem/banktransspec/amountdetails/paycurrency');
        CreateDataExchColumnDef(DataExchDefCode, DataExchDefCode, 56,
          '/paymentExportBank/amcpaymentreq/banktransjournal/banktransus/banktransthem/banktransspec/amountdetails/paydate');
        CreateDataExchColumnDef(DataExchDefCode, DataExchDefCode, 57,
          '/paymentExportBank/amcpaymentreq/banktransjournal/banktransus/banktransthem/messagestructure');

        CreateDataExchColumnDef(DataExchDefCode, DataExchDefCode, 58,
          '/paymentExportBank/amcpaymentreq/banktransjournal/banktransus/banktransthem/regulatoryreporting/code');
        CreateDataExchColumnDef(DataExchDefCode, DataExchDefCode, 59,
          '/paymentExportBank/amcpaymentreq/banktransjournal/banktransus/banktransthem/regulatoryreporting/date');
        CreateDataExchColumnDef(DataExchDefCode, DataExchDefCode, 60,
          '/paymentExportBank/amcpaymentreq/banktransjournal/banktransus/banktransthem/regulatoryreporting/text');
        CreateDataExchColumnDef(DataExchDefCode, DataExchDefCode, 61,
          '/paymentExportBank/amcpaymentreq/banktransjournal/banktransus/ownaddressinfo');
        CreateDataExchColumnDef(DataExchDefCode, DataExchDefCode, 62,
          '/paymentExportBank/amcpaymentreq/banktransjournal/banktransus/countryoforigin');

        CreateDataExchColumnDef(DataExchDefCode, DataExchDefCode, 63,
          '/paymentExportBank/amcpaymentreq/banktransjournal/banktransus/banktransthem/receiversaddress/state');
        CreateDataExchColumnDef(DataExchDefCode, DataExchDefCode, 64,
          '/paymentExportBank/amcpaymentreq/banktransjournal/banktransus/banktransthem/receiversbankaccount/bankaccountaddress/state');
        CreateDataExchColumnDef(DataExchDefCode, DataExchDefCode, 65,
          '/paymentExportBank/amcpaymentreq/banktransjournal/banktransus/bankaccountident/bankaccountaddress/state');
    end;

    local procedure CreateDataExch(var DataExch: Record "Data Exch."; DataExchDefCode: Code[20]; TempBlob: Codeunit "Temp Blob")
    var
        InStream: InStream;
    begin
        TempBlob.CreateInStream(InStream);
        DataExch.InsertRec('', InStream, DataExchDefCode);
    end;

    local procedure CreateDataExchDef(var DataExchDef: Record "Data Exch. Def"; ProcessingXMLport: Integer; ColumnSeparator: Option; FileType: Option)
    begin
        DataExchDef.InsertRecForExport(LibraryUtility.GenerateRandomCode(DataExchDef.FieldNo(Code), DATABASE::"Data Exch. Def"),
          LibraryUtility.GenerateGUID(), DataExchDef.Type::"Payment Export", ProcessingXMLport, FileType);
        DataExchDef."Column Separator" := ColumnSeparator;
        DataExchDef."File Encoding" := DataExchDef."File Encoding"::WINDOWS;
        DataExchDef.Modify();
    end;

    local procedure CreateDataExchColumnDef(DataExchDefCode: Code[20]; DataExchLineDefCode: Code[20]; ColumnNo: Integer; Path: Text[250])
    var
        DataExchColumnDef: Record "Data Exch. Column Def";
    begin
        DataExchColumnDef.InsertRecForExport(DataExchDefCode, DataExchLineDefCode, ColumnNo, '',
          DataExchColumnDef."Data Type"::Text, '', 0, '');
        DataExchColumnDef.Path := Path;
        DataExchColumnDef.Modify();
    end;

    local procedure SetupExport(var TempBlobANSI: Codeunit "Temp Blob"; var DataExch: Record "Data Exch."; var DataExchDef: Record "Data Exch. Def"; var ExportTextArray: array[10, 100] of Text[250]; ProcessingXMLport: Integer; FileType: Option)
    var
        DataExchLineDef: Record "Data Exch. Line Def";
    begin
        CreateDataExchDef(DataExchDef, ProcessingXMLport, DataExchDef."Column Separator"::Comma, FileType);
        CreateDataExch(DataExch, DataExchDef.Code, TempBlobANSI);
        CreateExportData(ExportTextArray);
        DataExchLineDef.InsertRec(DataExchDef.Code, DataExchDef.Code, DataExchDef.Code, ArrayLen(ExportTextArray, 2));
    end;

    local procedure CreateExportData(var ExportText: array[10, 100] of Text[250])
    var
        FixedId: Text[250];
        i: Integer;
        j: Integer;
        NoOfColumns: Integer;
    begin
        FixedId := LibraryUtility.GenerateGUID();
        for i := 1 to ArrayLen(ExportText, 1) do begin
            NoOfColumns := LibraryRandom.RandIntInRange(65, ArrayLen(ExportText, 2));
            for j := 1 to 5 do
                ExportText[i] [j] := FixedId; // repeating info for each line.
            for j := 6 to NoOfColumns do
                ExportText[i] [j] := LibraryUtility.GenerateGUID() + 'æøåÆØÅ';
        end;
    end;

    local procedure CreateDataExchFieldForLine(ExportText: array[10, 10] of Text[250]; LineNo: Integer; DataExchEntryNo: Integer; FirstColumnIndex: Integer; SkipColumns: Integer; MaxNoOfColumns: Integer; DataExchLineDefNo: Code[20])
    var
        DataExchField: Record "Data Exch. Field";
        j: Integer;
    begin
        j := FirstColumnIndex;
        while j <= MaxNoOfColumns do begin
            if ExportText[LineNo] [j] <> '' then
                DataExchField.InsertRec(DataExchEntryNo, LineNo, j, ExportText[LineNo] [j], DataExchLineDefNo);
            j += SkipColumns;
        end;
    end;

    local procedure VerifyAMCOutput(ExportData: array[10, 10] of Text[250]; TempBlobANSI: Codeunit "Temp Blob"; DataExchDefCode: Code[20])
    var
        CompanyInformation: Record "Company Information";
        DataExchColumnDef: Record "Data Exch. Column Def";
        AMCBankingMgt: Codeunit "AMC Banking Mgt.";
        i: Integer;
        j: Integer;
    begin
        LibraryXPathXMLReader.InitializeWithBlob(TempBlobANSI, AMCBankingMgt.GetNamespace());

        for i := 1 to ArrayLen(ExportData, 1) do
            for j := 1 to ArrayLen(ExportData, 2) do
                if (ExportData[i] [j] <> '') and DataExchColumnDef.Get(DataExchDefCode, DataExchDefCode, j) then
                    LibraryXPathXMLReader.VerifyNodeCountWithValueByXPath(DataExchColumnDef.Path, ExportData[i] [j], 1);

        CompanyInformation.Get();
        LibraryXPathXMLReader.VerifyNodeCountWithValueByXPath(
          '/paymentExportBank/amcpaymentreq/banktransjournal/legalregistrationnumber',
          CompanyInformation."VAT Registration No.", 1);
        LibraryXPathXMLReader.VerifyNodeCountWithValueByXPath(
          '/paymentExportBank/amcpaymentreq/banktransjournal/banktransus/ownaddress/address1',
          CompanyInformation.Address, ArrayLen(ExportData, 1));
        LibraryXPathXMLReader.VerifyNodeCountWithValueByXPath(
          '/paymentExportBank/amcpaymentreq/banktransjournal/banktransus/ownaddress/address2',
          CompanyInformation."Address 2", ArrayLen(ExportData, 1));
        LibraryXPathXMLReader.VerifyNodeCountWithValueByXPath(
          '/paymentExportBank/amcpaymentreq/banktransjournal/banktransus/ownaddress/city',
          CompanyInformation.City, ArrayLen(ExportData, 1));
        LibraryXPathXMLReader.VerifyNodeCountWithValueByXPath(
          '/paymentExportBank/amcpaymentreq/banktransjournal/banktransus/ownaddress/name',
          CompanyInformation.Name, ArrayLen(ExportData, 1));
        LibraryXPathXMLReader.VerifyNodeCountWithValueByXPath(
          '/paymentExportBank/amcpaymentreq/banktransjournal/banktransus/ownaddress/countryiso',
          CompanyInformation."Country/Region Code", ArrayLen(ExportData, 1));
        LibraryXPathXMLReader.VerifyNodeCountWithValueByXPath(
          '/paymentExportBank/amcpaymentreq/banktransjournal/banktransus/ownaddress/zipcode',
          CompanyInformation."Post Code", ArrayLen(ExportData, 1));
        LibraryXPathXMLReader.VerifyNodeCountWithValueByXPath(
          '/paymentExportBank/amcpaymentreq/banktransjournal/banktransus/ownaddress/state',
          CompanyInformation.County, ArrayLen(ExportData, 1));
        LibraryXPathXMLReader.VerifyNodeCountWithValueByXPath('/paymentExportBank/language', 'ENU', 1);
    end;
}

