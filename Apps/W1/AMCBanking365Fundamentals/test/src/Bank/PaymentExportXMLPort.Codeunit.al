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
        LibraryAmcWebService: Codeunit "Library - Amc Web Service";

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
    var
        DataExchColumnDef: Record "Data Exch. Column Def";
        DataExchFieldMapping: Record "Data Exch. Field Mapping";
        AMCBankingMgt: Codeunit "AMC Banking Mgt.";
        ColumnCounter: Integer;
    begin

        LibraryAmcWebService.SetupAMCBankingDataExch(AMCBankingMgt.GetDataExchDef_CT());

        DataExchColumnDef.SetCurrentKey("Data Exch. Def Code", Path);
        DataExchColumnDef.Ascending(false);
        DataExchColumnDef.SetRange("Data Exch. Def Code", AMCBankingMgt.GetDataExchDef_CT());
        if (DataExchColumnDef.FindSet()) then
            repeat
                DataExchFieldMapping.SetRange("Data Exch. Def Code", DataExchColumnDef."Data Exch. Def Code");
                DataExchFieldMapping.SetRange("Column No.", DataExchColumnDef."Column No.");
                if (DataExchFieldMapping.FindFirst()) then
                    if ((StrPos(DataExchFieldMapping.GetPath(), 'chequeinfo') = 0) and
                        (StrPos(DataExchFieldMapping.GetPath(), 'journalnumber') = 0) and
                        (StrPos(DataExchFieldMapping.GetPath(), 'paymentmessage') = 0) and
                        (StrPos(DataExchFieldMapping.GetPath(), 'messagestructure') = 0) and
                        (StrPos(DataExchFieldMapping.GetPath(), 'banktransspec') = 0)) then begin //Skip journalnumber, chequeinfo,messagestructure, paymentmessage and banktransspec, as this is handled differently
                        ColumnCounter += 1;
                        CreateDataExchColumnDef(DataExchDefCode, DataExchDefCode, ColumnCounter, CopyStr(DataExchFieldMapping.GetPath(), 1, 250));
                    end;
            until DataExchColumnDef.Next() = 0;
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

    local procedure PrefixXPath(SourceText: Text; FindText: Text; ReplaceText: Text): Text
    var
        pos: Integer;
    begin
        if ((StrPos(SourceText, FindText) > 0) and (StrPos(SourceText, ReplaceText) = 0)) then begin
            pos := StrPos(SourceText, FindText);
            SourceText := DelStr(SourceText, pos, STRLEN(FindText));
            SourceText := InsStr(SourceText, ReplaceText, pos);
        END;

        exit(SourceText);
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
        LibraryXPathXMLReader.SetDefaultNamespaceUsage(false);

        for i := 1 to ArrayLen(ExportData, 1) do
            for j := 1 to ArrayLen(ExportData, 2) do
                if (ExportData[i] [j] <> '') and DataExchColumnDef.Get(DataExchDefCode, DataExchDefCode, j) then
                    LibraryXPathXMLReader.VerifyNodeCountWithValueByXPath(PrefixXPath(DataExchColumnDef.Path, '/', '/ns:'), ExportData[i] [j], 1);

        CompanyInformation.Get();
        LibraryXPathXMLReader.VerifyNodeCountWithValueByXPath(
          PrefixXPath('/paymentExportBank/amcpaymentreq/banktransjournal/legalregistrationnumber', '/', '/ns:'),
          CompanyInformation."VAT Registration No.", 1);
        LibraryXPathXMLReader.VerifyNodeCountWithValueByXPath(
          PrefixXPath('/paymentExportBank/amcpaymentreq/banktransjournal/banktransus/ownaddress/address1', '/', '/ns:'),
          CompanyInformation.Address, ArrayLen(ExportData, 1));
        LibraryXPathXMLReader.VerifyNodeCountWithValueByXPath(
          PrefixXPath('/paymentExportBank/amcpaymentreq/banktransjournal/banktransus/ownaddress/address2', '/', '/ns:'),
          CompanyInformation."Address 2", ArrayLen(ExportData, 1));
        LibraryXPathXMLReader.VerifyNodeCountWithValueByXPath(
          PrefixXPath('/paymentExportBank/amcpaymentreq/banktransjournal/banktransus/ownaddress/city', '/', '/ns:'),
          CompanyInformation.City, ArrayLen(ExportData, 1));
        LibraryXPathXMLReader.VerifyNodeCountWithValueByXPath(
          PrefixXPath('/paymentExportBank/amcpaymentreq/banktransjournal/banktransus/ownaddress/name', '/', '/ns:'),
          CompanyInformation.Name, ArrayLen(ExportData, 1));
        LibraryXPathXMLReader.VerifyNodeCountWithValueByXPath(
          PrefixXPath('/paymentExportBank/amcpaymentreq/banktransjournal/banktransus/ownaddress/countryiso', '/', '/ns:'),
          CompanyInformation."Country/Region Code", ArrayLen(ExportData, 1));
        LibraryXPathXMLReader.VerifyNodeCountWithValueByXPath(
          PrefixXPath('/paymentExportBank/amcpaymentreq/banktransjournal/banktransus/ownaddress/zipcode', '/', '/ns:'),
          CompanyInformation."Post Code", ArrayLen(ExportData, 1));
        LibraryXPathXMLReader.VerifyNodeCountWithValueByXPath(
          PrefixXPath('/paymentExportBank/amcpaymentreq/banktransjournal/banktransus/ownaddress/state', '/', '/ns:'),
          CompanyInformation.County, ArrayLen(ExportData, 1));
        LibraryXPathXMLReader.VerifyNodeCountWithValueByXPath(PrefixXPath('/paymentExportBank/language', '/', '/ns:'), 'ENU', 1);
    end;
}