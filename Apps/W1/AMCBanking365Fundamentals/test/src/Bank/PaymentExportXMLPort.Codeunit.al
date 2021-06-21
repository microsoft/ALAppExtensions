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
        Assert: Codeunit Assert;
        LibraryXPathXMLReader: Codeunit "Library - XPath XML Reader";
        LibraryUtility: Codeunit "Library - Utility";
        LibraryRandom: Codeunit "Library - Random";
        AMCBankingMgt: Codeunit "AMC Banking Mgt.";

    [Test]
    [Scope('OnPrem')]
    procedure ExportAMCXMLSunshine()
    var
        CompanyInformation: Record "Company Information";
        PaymentExportData: Record "Payment Export Data";
        DataExch: Record "Data Exch.";
        DataExchDef: Record "Data Exch. Def";
        TempXmlBuffer: Record "XML Buffer" temporary;
        TempBlob: Codeunit "Temp Blob";
        OutStream: OutStream;
    begin
        // Setup
        CompanyInformation.Get();
        CompanyInformation.County := LibraryUtility.GenerateGUID();
        CompanyInformation.Modify();

        SetupExport(TempBlob, DataExch, DataExchDef, TempXMLBuffer, XMLPORT::"AMC Bank Export CT", DataExchDef."File Type"::Xml);

        // Execute
        TempBlob.CreateOutStream(OutStream);
        PaymentExportData.SetRange("Data Exch Entry No.", DataExch."Entry No.");
        XMLPORT.Export(DataExchDef."Reading/Writing XMLport", OutStream, PaymentExportData);

        // Verify Stream Content.
        VerifyAMCOutput(TempXMLBuffer, TempBlob, DataExch."Entry No.");
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

    local procedure SetupExport(var TempBlobANSI: Codeunit "Temp Blob"; var DataExch: Record "Data Exch."; var DataExchDef: Record "Data Exch. Def"; var TempXmlBuffer: Record "Xml Buffer"; ProcessingXMLport: Integer; FileType: Option)
    var
    begin
        CreateDataExchDef(DataExchDef, ProcessingXMLport, DataExchDef."Column Separator"::Comma, FileType);
        CreateDataExch(DataExch, DataExchDef.Code, TempBlobANSI);
        CreateExportData(TempXmlBuffer, DataExch);
    end;

    local procedure CreateExportData(var TempXmlBuffer: Record "Xml Buffer"; DataExch: Record "Data Exch.")
    var
        CompanyInformation: Record "Company Information";
        PaymentExportData: Record "Payment Export Data";
        PaymentExportDataRecordRef: RecordRef;
        CompanyInfoRecordRef: RecordRef;
        FieldRef: FieldRef;
        FixedText: Text[250];
        FixedDec: Decimal;
        FixedInt: Integer;
        FixedDate: Date;
        FieldId: Integer;
        EntryCounter: Integer;
    begin

        Clear(PaymentExportData);
        PaymentExportData.Init();
        PaymentExportData."Line No." += 1;
        PaymentExportData."Data Exch Entry No." := DataExch."Entry No.";
        PaymentExportData."Data Exch. Line Def Code" := DataExch."Data Exch. Line Def Code";
        PaymentExportData.Insert();

        PaymentExportDataRecordRef.GetTable(PaymentExportData);

        FixedText := LibraryUtility.GenerateGUID();
        FixedDec := LibraryRandom.RandDec(1000, 2);
        FixedDate := LibraryUtility.GenerateRandomDate(Today(), Today());
        FixedInt := LibraryRandom.RandInt(10000);

        //Run through PaymentExportdata Table and create random data
        for FieldId := 1 to PaymentExportDataRecordRef.FieldCount() do
            if (PaymentExportDataRecordRef.FieldExist(FieldId) and (FieldId > 4)) then begin

                FieldRef := PaymentExportDataRecordRef.Field(FieldId);

                case FieldRef.Type of
                    FieldType::Text,
                    FieldType::Code:
                        AMCBankingMgt.SetFieldValue(PaymentExportDataRecordRef, FieldId, FixedText, false, false);
                    FieldType::Date:
                        AMCBankingMgt.SetFieldValue(PaymentExportDataRecordRef, FieldId, FixedDate, false, false);
                    FieldType::Decimal:
                        AMCBankingMgt.SetFieldValue(PaymentExportDataRecordRef, FieldId, FixedDec, false, false);
                    FieldType::Integer:
                        AMCBankingMgt.SetFieldValue(PaymentExportDataRecordRef, FieldId, FixedInt, false, false);
                end;
                CreateXmlBufferForPaymentExportData(PaymentExportDataRecordRef, FieldId, TempXmlBuffer, DataExch."Entry No.", EntryCounter);
            end;
        PaymentExportDataRecordRef.Modify();

        //Run through CompanyInformation Table and add to exportdata
        CompanyInformation.Get();
        CompanyInfoRecordRef.GetTable(CompanyInformation);

        FieldId := 0;
        for FieldId := 1 to CompanyInfoRecordRef.FieldCount() do
            if (CompanyInfoRecordRef.FieldExist(FieldId) and (FieldId > 1)) then
                CreateXmlBufferForPaymentExportData(CompanyInfoRecordRef, FieldId, TempXmlBuffer, DataExch."Entry No.", EntryCounter);
    end;


    local procedure CreateXmlBufferForPaymentExportData(RecordRef: RecordRef; FieldId: Integer; var TempXmlBuffer: Record "XML Buffer"; DataExchNo: Integer; var EntryCounter: Integer)
    var
        FieldRef: FieldRef;
        PaymentExportdataValue: Text;
        paymentExportBankXPathTxt: Label '/paymentExportBank/', Locked = true;
        banktransjournalXPathTxt: Label '/paymentExportBank/amcpaymentreq/banktransjournal/', Locked = true;
        banktransusXPathTxt: Label '/paymentExportBank/amcpaymentreq/banktransjournal/banktransus/', Locked = true;
        ownbankaccountXPathTxt: Label '/paymentExportBank/amcpaymentreq/banktransjournal/banktransus/ownbankaccount/', Locked = true;
        bankaccountaddressXPathTxt: Label '/paymentExportBank/amcpaymentreq/banktransjournal/banktransus/ownbankaccount/bankaccountaddress/', Locked = true;
        banktransthemXPathTxt: Label '/paymentExportBank/amcpaymentreq/banktransjournal/banktransus/banktransthem/', Locked = true;
        //emailadviceXPathTxt: Label '/paymentExportBank/amcpaymentreq/banktransjournal/banktransus/banktransthem/emailadvice/', Locked = true;
        receiversbankaccountXPathTxt: Label '/paymentExportBank/amcpaymentreq/banktransjournal/banktransus/banktransthem/receiversbankaccount/', Locked = true;
        recbankaccaddressXPathTxt: Label '/paymentExportBank/amcpaymentreq/banktransjournal/banktransus/banktransthem/receiversbankaccount/bankaccountaddress/', Locked = true;
        amountdetailsTHXPathTxt: Label '/paymentExportBank/amcpaymentreq/banktransjournal/banktransus/banktransthem/amountdetails/', Locked = true;
        receiversaddressTHXPathTxt: Label '/paymentExportBank/amcpaymentreq/banktransjournal/banktransus/banktransthem/receiversaddress/', Locked = true;
        ownaddressXPathTxt: Label '/paymentExportBank/amcpaymentreq/banktransjournal/banktransus/ownaddress/', Locked = true;
    begin
        PaymentExportdataValue := CopyStr(AMCBankingMgt.GetFieldValue(RecordRef, FieldId), 1, 250);

        if (PaymentExportdataValue <> '') then begin
            EntryCounter += 1;
            FieldRef := RecordRef.Field(FieldId);

            Clear(TempXmlBuffer);
            TempXmlBuffer.Init();
            TempXmlBuffer."Entry No." := EntryCounter;
            TempXmlBuffer.Depth := DataExchNo;
            TempXmlBuffer."Parent Entry No." := RecordRef.Number();
            TempXmlBuffer.Type := TempXmlBuffer.Type::Element;
            TempXmlBuffer."Node Number" := FieldId;
            TempXmlBuffer.Name := CopyStr(FieldRef.Name(), 1, 250);
            TempXmlBuffer.Value := CopyStr(AMCBankingMgt.GetFieldValue(RecordRef, FieldId), 1, 250);

            if (RecordRef.Number() = Database::"Company Information") then
                case FieldRef.Name() of
                    'Registration No.':
                        TempXmlBuffer.Path := ownaddressXPathTxt + 'legalregistrationnumber';
                    'Address':
                        TempXmlBuffer.Path := ownaddressXPathTxt + 'address1';
                    'Address 2':
                        TempXmlBuffer.Path := ownaddressXPathTxt + 'address2';
                    'City':
                        TempXmlBuffer.Path := ownaddressXPathTxt + 'city';
                    'Name':
                        TempXmlBuffer.Path := ownaddressXPathTxt + 'name';
                    'Country/Region Code':
                        TempXmlBuffer.Path := ownaddressXPathTxt + 'countryiso';
                    'Post Code':
                        TempXmlBuffer.Path := ownaddressXPathTxt + 'zipcode';
                    'County':
                        TempXmlBuffer.Path := ownaddressXPathTxt + 'state';
                    'E-Mail':
                        TempXmlBuffer.Path := ownaddressXPathTxt + 'contactemail';
                    'Contact Person':
                        TempXmlBuffer.Path := ownaddressXPathTxt + 'contactname';
                end;


            if (RecordRef.Number() = Database::"Payment Export Data") then
                case FieldRef.Name() of
                    'General Journal Template':
                        TempXmlBuffer.Path := banktransjournalXPathTxt + 'journalname';
                    'Importing Description':
                        TempXmlBuffer.Path := banktransjournalXPathTxt + 'journalnumber';
                    'Message ID':
                        TempXmlBuffer.Path := banktransjournalXPathTxt + 'uniqueid';
                    'Recipient Name':
                        TempXmlBuffer.Path := banktransusXPathTxt + 'ownreference';
                    'End-to-End ID':
                        TempXmlBuffer.Path := banktransusXPathTxt + 'uniqueid';
                    'Sender Bank Account No.':
                        TempXmlBuffer.Path := ownbankaccountXPathTxt + 'bankaccount';
                    'Sender Bank Account Currency':
                        TempXmlBuffer.Path := ownbankaccountXPathTxt + 'currency';
                    'Sender Bank Clearing Code':
                        TempXmlBuffer.Path := ownbankaccountXPathTxt + 'intregno';
                    'Sender Bank Clearing Std.':
                        TempXmlBuffer.Path := ownbankaccountXPathTxt + 'intregnotype';
                    'Sender Bank BIC':
                        TempXmlBuffer.Path := ownbankaccountXPathTxt + 'swiftcode';
                    'Sender Bank Address':
                        TempXmlBuffer.Path := bankaccountaddressXPathTxt + 'address1';
                    'Sender Bank City':
                        TempXmlBuffer.Path := bankaccountaddressXPathTxt + 'city';
                    'Sender Bank Country/Region':
                        TempXmlBuffer.Path := bankaccountaddressXPathTxt + 'countryiso';
                    'Sender Bank Name':
                        TempXmlBuffer.Path := bankaccountaddressXPathTxt + 'name';
                    'Sender Bank County':
                        TempXmlBuffer.Path := bankaccountaddressXPathTxt + 'state';
                    'Sender Bank Post Code':
                        TempXmlBuffer.Path := bankaccountaddressXPathTxt + 'zipcode';
                    'Recipient ID':
                        TempXmlBuffer.Path := banktransthemXPathTxt + 'customerid';
                    'Payment Type':
                        TempXmlBuffer.Path := banktransthemXPathTxt + 'paymenttype';
                    'Payment Reference':
                        TempXmlBuffer.Path := banktransthemXPathTxt + 'reference';
                    'Applies-to Ext. Doc. No.':
                        TempXmlBuffer.Path := banktransthemXPathTxt + 'shortadvice';
                    'Payment Information ID':
                        TempXmlBuffer.Path := banktransthemXPathTxt + 'uniqueid';
                    'Recipient Bank Acc. No.':
                        TempXmlBuffer.Path := receiversbankaccountXPathTxt + 'bankaccount';
                    'AMC Recip. Bank Acc. Currency':
                        TempXmlBuffer.Path := receiversbankaccountXPathTxt + 'currency';
                    'Recipient Bank Clearing Code':
                        TempXmlBuffer.Path := receiversbankaccountXPathTxt + 'intregno';
                    'Recipient Bank Clearing Std.':
                        TempXmlBuffer.Path := receiversbankaccountXPathTxt + 'intregnotype';
                    'Recipient Bank BIC':
                        TempXmlBuffer.Path := receiversbankaccountXPathTxt + 'swiftcode';
                    'Recipient Bank Address':
                        TempXmlBuffer.Path := recbankaccaddressXPathTxt + 'address1';
                    'Recipient Bank City':
                        TempXmlBuffer.Path := recbankaccaddressXPathTxt + 'city';
                    'Recipient Bank Country/Region':
                        TempXmlBuffer.Path := recbankaccaddressXPathTxt + 'countryiso';
                    'Recipient Bank Name':
                        TempXmlBuffer.Path := recbankaccaddressXPathTxt + 'name';
                    'Recipient Bank County':
                        TempXmlBuffer.Path := recbankaccaddressXPathTxt + 'state';
                    'Recipient Bank Post Code':
                        TempXmlBuffer.Path := recbankaccaddressXPathTxt + 'zipcode';
                    'Message Structure':
                        TempXmlBuffer.Path := banktransthemXPathTxt + 'messagestructure';
                    'Costs Distribution':
                        TempXmlBuffer.Path := banktransthemXPathTxt + 'costs';
                    'Amount':
                        TempXmlBuffer.Path := amountdetailsTHXPathTxt + 'payamount';
                    'Currency Code':
                        TempXmlBuffer.Path := amountdetailsTHXPathTxt + 'paycurrency';
                    'Transfer Date':
                        TempXmlBuffer.Path := amountdetailsTHXPathTxt + 'paydate';
                    'Recipient Address':
                        TempXmlBuffer.Path := receiversaddressTHXPathTxt + 'address1';
                    'Recipient City':
                        TempXmlBuffer.Path := receiversaddressTHXPathTxt + 'city';
                    'Recipient Country/Region Code':
                        TempXmlBuffer.Path := receiversaddressTHXPathTxt + 'countryiso';
                    'Recipient County':
                        TempXmlBuffer.Path := receiversaddressTHXPathTxt + 'state';
                    'Recipient Post Code':
                        TempXmlBuffer.Path := receiversaddressTHXPathTxt + 'zipcode';
                    'Own Address Info.':
                        TempXmlBuffer.Path := banktransusXPathTxt + 'ownaddressinfo';
                    'Sender Bank Name - Data Conv.':
                        TempXmlBuffer.Path := paymentExportBankXPathTxt + 'bank';
                end;

            if (TempXmlBuffer.Path <> '') then
                TempXmlBuffer.Insert();
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

    local procedure VerifyAMCOutput(var TempXMLBuffer: Record "XML Buffer"; TempBlobANSI: Codeunit "Temp Blob"; DataExchNo: Integer)
    var
    begin
        LibraryXPathXMLReader.InitializeWithBlob(TempBlobANSI, AMCBankingMgt.GetNamespace());
        LibraryXPathXMLReader.SetDefaultNamespaceUsage(false);

        TempXMLBuffer.Reset();
        TempXMLBuffer.SetRange(TempXMLBuffer.Depth, DataExchNo);
        if (TempXMLBuffer.FindSet()) then
            repeat
                LibraryXPathXMLReader.VerifyNodeValueByXPath(PrefixXPath(TempXMLBuffer.Path, '/', '/ns:'), TempXMLBuffer.GetValue());
            until TempXMLBuffer.Next() = 0
        else
            Assert.AssertRecordNotFound();

    end;
}