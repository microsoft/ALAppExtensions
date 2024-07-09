codeunit 139554 "Library - Intrastat"
{
    Subtype = Test;
    TestPermissions = Disabled;
    EventSubscriberInstance = Manual;

    // [FEATURE] [Intrastat] [Library]
    var
        LibraryERM: Codeunit "Library - ERM";
        LibraryJob: Codeunit "Library - Job";
        LibraryMarketing: Codeunit "Library - Marketing";
        LibraryPurchase: Codeunit "Library - Purchase";
        LibraryUtility: Codeunit "Library - Utility";
        LibraryInventory: Codeunit "Library - Inventory";
        LibraryFixedAsset: Codeunit "Library - Fixed Asset";
        LibrarySales: Codeunit "Library - Sales";
        LibraryRandom: Codeunit "Library - Random";
        LibraryWarehouse: Codeunit "Library - Warehouse";
        LibraryItemTracking: Codeunit "Library - Item Tracking";

    procedure CreateIntrastatReportSetup()
    var
        IntrastatReportSetup: Record "Intrastat Report Setup";
        NoSeriesCode: Code[20];
    begin
        if IntrastatReportSetup.Get() then
            exit;
        NoSeriesCode := LibraryERM.CreateNoSeriesCode();
        IntrastatReportSetup.Init();
        IntrastatReportSetup.Validate("Intrastat Nos.", NoSeriesCode);
        IntrastatReportSetup.Insert();

        IntrastatReportSetup.Validate("Report Receipts", true);
        IntrastatReportSetup.Validate("Report Shipments", true);
        IntrastatReportSetup.Modify(true);
    end;

    procedure CreateIntrastatReport(ReportDate: Date; var IntrastatReportNo: Code[20])
    var
        IntrastatReportHeader: Record "Intrastat Report Header";
    begin
        IntrastatReportHeader.Init();
        IntrastatReportHeader.Validate("No.", GetIntrastatNo());
        IntrastatReportHeader.Insert();

        IntrastatReportHeader.Validate("Statistics Period", GetStatisticalPeriod(ReportDate));
        IntrastatReportHeader.Modify();

        IntrastatReportNo := IntrastatReportHeader."No.";
    end;

    procedure CreateIntrastatReportLine(var IntrastatReportLine: Record "Intrastat Report Line")
    var
        IntrastatReportHeader: Record "Intrastat Report Header";
        IntrastatReportNo: Code[20];
    begin
        CreateIntrastatReport(WorkDate(), IntrastatReportNo);
        IntrastatReportHeader.Get(IntrastatReportNo);

        IntrastatReportLine.Init();
        IntrastatReportLine.Validate("Intrastat No.", IntrastatReportNo);
        IntrastatReportLine.Validate("Line No.", 1000);
        IntrastatReportLine.Insert();
    end;

    procedure CreateIntrastatReportLineinIntrastatReport(var IntrastatReportLine: Record "Intrastat Report Line"; IntrastatReportNo: Code[20])
    var
        IntrastatReportLineRecordRef: RecordRef;
    begin
        IntrastatReportLine.Init();
        IntrastatReportLine.Validate("Intrastat No.", IntrastatReportNo);
        IntrastatReportLineRecordRef.GetTable(IntrastatReportLine);
        IntrastatReportLine.Validate("Line No.", LibraryUtility.GetNewLineNo(IntrastatReportLineRecordRef, IntrastatReportLine.FieldNo("Line No.")));
        IntrastatReportLine.Insert(true);
    end;

    procedure ClearIntrastatReportLines(IntrastatReportNo: Code[20])
    var
        IntrastatReportLine: Record "Intrastat Report Line";
    begin
        IntrastatReportLine.SetRange("Intrastat No.", IntrastatReportNo);
        IntrastatReportLine.DeleteAll(true);
    end;

    procedure CreateIntrastatReportChecklistRecord(FieldNo: Integer; FilterExpression: Text[1024])
    var
        IntrastatReportChecklist: Record "Intrastat Report Checklist";
    begin
        IntrastatReportChecklist.Init();
        IntrastatReportChecklist.Validate("Field No.", FieldNo);
        if FilterExpression <> '' then
            IntrastatReportChecklist.Validate("Filter Expression", FilterExpression);
        if IntrastatReportChecklist.Insert() then;
    end;

    procedure CreateIntrastatContact(ContactType: Enum "Intrastat Report Contact Type"): Code[20]
    var
        IntrastatReportSetup: Record "Intrastat Report Setup";
    begin
        case ContactType of
            IntrastatReportSetup."Intrastat Contact Type"::Contact:
                exit(LibraryMarketing.CreateIntrastatContact(LibraryERM.CreateCountryRegionWithIntrastatCode()));
            IntrastatReportSetup."Intrastat Contact Type"::Vendor:
                exit(LibraryPurchase.CreateIntrastatContact(LibraryERM.CreateCountryRegionWithIntrastatCode()));
        end;
    end;

    procedure CreateCountryRegionWithIntrastatCode(): Code[10]
    var
        CountryRegion: Record "Country/Region";
    begin
        CreateCountryRegion(CountryRegion);
        CountryRegion.Validate(Name, LibraryUtility.GenerateGUID());
        CountryRegion.Validate("Intrastat Code", LibraryUtility.GenerateGUID());
        CountryRegion.Modify(true);
        exit(CountryRegion.Code);
    end;

    procedure CreateCountryRegion(var CountryRegion: Record "Country/Region")
    begin
        CountryRegion.Init();
        CountryRegion.Validate(
          Code,
          CopyStr(LibraryUtility.GenerateRandomCode(CountryRegion.FieldNo(Code), DATABASE::"Country/Region"),
            1, LibraryUtility.GetFieldLength(DATABASE::"Country/Region", CountryRegion.FieldNo(Code))));
        CountryRegion.Insert(true);
    end;

    procedure CreateIntrastatReportChecklist()
    var
        IntrastatReportChecklist: Record "Intrastat Report Checklist";
        IntrastatReportLine: Record "Intrastat Report Line";
    begin
        IntrastatReportChecklist.DeleteAll();

        IntrastatReportChecklist.Init();
        IntrastatReportChecklist.Validate("Field No.", IntrastatReportLine.FieldNo("Document No."));
        IntrastatReportChecklist.Insert();
    end;


    procedure CreateAndPostFixedAssetPurchaseOrder(var PurchaseLine: Record "Purchase Line"; PostingDate: Date): Code[20]
    var
        PurchaseHeader: Record "Purchase Header";
    begin
        exit(
          CreateAndPostPurchaseDocumentMultiLine(
            PurchaseLine, PurchaseHeader."Document Type"::Order, PostingDate, PurchaseLine.Type::"Fixed Asset", CreateFixedAsset(), 1));
    end;

    procedure CreateIntrastatDataExchangeDefinition()
    var
        DataExchDef: Record "Data Exch. Def";
        IntrastatReportSetup: Record "Intrastat Report Setup";
        TempBlob: Codeunit "Temp Blob";
        XMLOutStream: OutStream;
        XMLInStream: InStream;
        DataExchangeXMLTxt: Label '<?xml version="1.0" encoding="UTF-8" standalone="no"?><root><DataExchDef Code="INTRA-2022" Name="Intrastat Report 2022" Type="5" ReadingWritingXMLport="1231" ExternalDataHandlingCodeunit="4813" ColumnSeparator="1" FileType="1" ReadingWritingCodeunit="1276"><DataExchLineDef LineType="1" Code="DEFAULT" Name="DEFAULT" ColumnCount="9"><DataExchColumnDef ColumnNo="1" Name="Tariff No." Show="false" DataType="0" Length="8" TextPaddingRequired="true" PadCharacter="0" Justification="0" UseNodeNameAsValue="false" /><DataExchColumnDef ColumnNo="2" Name="Country/Region Code" Show="false" DataType="0" Length="3" TextPaddingRequired="true" PadCharacter="&amp;#032;" Justification="1" UseNodeNameAsValue="false" /><DataExchColumnDef ColumnNo="3" Name="Transaction Type" Show="false" DataType="0" Length="2" TextPaddingRequired="true" Justification="1" UseNodeNameAsValue="false" /><DataExchColumnDef ColumnNo="4" Name="Quantity" Show="false" DataType="0" Length="11" TextPaddingRequired="true" PadCharacter="0" Justification="0" UseNodeNameAsValue="false" /><DataExchColumnDef ColumnNo="5" Name="Total Weight" Show="false" DataType="0" Length="10" TextPaddingRequired="true" PadCharacter="0" Justification="0" UseNodeNameAsValue="false" /><DataExchColumnDef ColumnNo="6" Name="Statistical Value" Show="false" DataType="0" Length="11" TextPaddingRequired="true" PadCharacter="0" Justification="0" UseNodeNameAsValue="false" /><DataExchColumnDef ColumnNo="7" Name="Internal Ref. No." Show="false" DataType="0" Length="30" TextPaddingRequired="true" PadCharacter="&amp;#032;" Justification="1" UseNodeNameAsValue="false" /><DataExchColumnDef ColumnNo="8" Name="Partner Tax ID" Show="false" DataType="0" Length="20" TextPaddingRequired="true" PadCharacter="&amp;#032;" Justification="1" UseNodeNameAsValue="false" /><DataExchColumnDef ColumnNo="9" Name="Country/Region of Origin Code" Show="false" DataType="0" Length="3" TextPaddingRequired="true" PadCharacter="&amp;#032;" Justification="1" UseNodeNameAsValue="false" /><DataExchMapping TableId="4812" Name="" KeyIndex="5" MappingCodeunit="1269"><DataExchFieldMapping ColumnNo="1" FieldID="5" Optional="true" TransformationRule="TRIMALL"><TransformationRules><Code>TRIMALL</Code><Description>Removes all spaces</Description><TransformationType>5</TransformationType><FindValue>&amp;#032;</FindValue><ReplaceValue /><StartPosition>0</StartPosition><Length>0</Length><DataFormat /><DataFormattingCulture /><NextTransformationRule /><TableID>0</TableID><SourceFieldID>0</SourceFieldID><TargetFieldID>0</TargetFieldID><FieldLookupRule>0</FieldLookupRule><Precision>0.00</Precision><Direction /></TransformationRules></DataExchFieldMapping><DataExchFieldMapping ColumnNo="2" FieldID="7" Optional="true" /><DataExchFieldMapping ColumnNo="3" FieldID="8" Optional="true" /><DataExchFieldMapping ColumnNo="4" FieldID="14" Optional="true" TransformationRule="ROUNDTOINT"><TransformationRules><Code>ALPHANUMERIC_ONLY</Code><Description>Alphanumeric Text Only</Description><TransformationType>7</TransformationType><FindValue /><ReplaceValue /><StartPosition>0</StartPosition><Length>0</Length><DataFormat /><DataFormattingCulture /><NextTransformationRule /><TableID>0</TableID><SourceFieldID>0</SourceFieldID><TargetFieldID>0</TargetFieldID><FieldLookupRule>0</FieldLookupRule><Precision>0.00</Precision><Direction /></TransformationRules><TransformationRules><Code>ROUNDTOINT</Code><Description>Round to integer</Description><TransformationType>14</TransformationType><FindValue>&amp;#032;</FindValue><ReplaceValue /><StartPosition>0</StartPosition><Length>0</Length><DataFormat /><DataFormattingCulture /><NextTransformationRule>ALPHANUMERIC_ONLY</NextTransformationRule><TableID>0</TableID><SourceFieldID>0</SourceFieldID><TargetFieldID>0</TargetFieldID><FieldLookupRule>0</FieldLookupRule><Precision>1.00</Precision><Direction>=</Direction></TransformationRules></DataExchFieldMapping><DataExchFieldMapping ColumnNo="5" FieldID="21" Optional="true" TransformationRule="ROUNDUPTOINT"><TransformationRules><Code>ALPHANUMERIC_ONLY</Code><Description>Alphanumeric Text Only</Description><TransformationType>7</TransformationType><FindValue /><ReplaceValue /><StartPosition>0</StartPosition><Length>0</Length><DataFormat /><DataFormattingCulture /><NextTransformationRule /><TableID>0</TableID><SourceFieldID>0</SourceFieldID><TargetFieldID>0</TargetFieldID><FieldLookupRule>0</FieldLookupRule><Precision>0.00</Precision><Direction /></TransformationRules><TransformationRules><Code>ROUNDUPTOINT</Code><Description>Round up to integer</Description><TransformationType>14</TransformationType><FindValue>&amp;#032;</FindValue><ReplaceValue /><StartPosition>0</StartPosition><Length>0</Length><DataFormat /><DataFormattingCulture /><NextTransformationRule>ALPHANUMERIC_ONLY</NextTransformationRule><TableID>0</TableID><SourceFieldID>0</SourceFieldID><TargetFieldID>0</TargetFieldID><FieldLookupRule>0</FieldLookupRule><Precision>1.00</Precision><Direction>&gt;</Direction></TransformationRules></DataExchFieldMapping><DataExchFieldMapping ColumnNo="6" FieldID="17" Optional="true" TransformationRule="ROUNDTOINT"><TransformationRules><Code>ALPHANUMERIC_ONLY</Code><Description>Alphanumeric Text Only</Description><TransformationType>7</TransformationType><FindValue /><ReplaceValue /><StartPosition>0</StartPosition><Length>0</Length><DataFormat /><DataFormattingCulture /><NextTransformationRule /><TableID>0</TableID><SourceFieldID>0</SourceFieldID><TargetFieldID>0</TargetFieldID><FieldLookupRule>0</FieldLookupRule><Precision>0.00</Precision><Direction /></TransformationRules><TransformationRules><Code>ROUNDTOINT</Code><Description>Round to integer</Description><TransformationType>14</TransformationType><FindValue>&amp;#032;</FindValue><ReplaceValue /><StartPosition>0</StartPosition><Length>0</Length><DataFormat /><DataFormattingCulture /><NextTransformationRule>ALPHANUMERIC_ONLY</NextTransformationRule><TableID>0</TableID><SourceFieldID>0</SourceFieldID><TargetFieldID>0</TargetFieldID><FieldLookupRule>0</FieldLookupRule><Precision>1.00</Precision><Direction>=</Direction></TransformationRules></DataExchFieldMapping><DataExchFieldMapping ColumnNo="7" FieldID="23" Optional="true" /><DataExchFieldMapping ColumnNo="8" FieldID="29" Optional="true" /><DataExchFieldMapping ColumnNo="9" FieldID="24" Optional="true" TransformationRule="EUCOUNTRYCODELOOKUP"><TransformationRules><Code>EUCOUNTRYCODELOOKUP</Code><Description>EU Country Lookup</Description><TransformationType>13</TransformationType><FindValue>&amp;#032;</FindValue><ReplaceValue /><StartPosition>0</StartPosition><Length>0</Length><DataFormat /><DataFormattingCulture /><NextTransformationRule /><TableID>9</TableID><SourceFieldID>1</SourceFieldID><TargetFieldID>7</TargetFieldID><FieldLookupRule>1</FieldLookupRule><Precision>0.00</Precision><Direction /></TransformationRules></DataExchFieldMapping><DataExchFieldGrouping FieldID="3" /><DataExchFieldGrouping FieldID="5" /><DataExchFieldGrouping FieldID="7" /><DataExchFieldGrouping FieldID="8" /><DataExchFieldGrouping FieldID="9" /><DataExchFieldGrouping FieldID="24" /><DataExchFieldGrouping FieldID="29" /></DataExchMapping></DataExchLineDef></DataExchDef></root>',
                            Locked = true; // will be replaced with file import when available
    begin
        if not DataExchDef.Get('INTRA-2022') then begin
            TempBlob.CreateOutStream(XMLOutStream);
            XMLOutStream.WriteText(DataExchangeXMLTxt);
            TempBlob.CreateInStream(XMLInStream);
            Xmlport.Import(Xmlport::"Imp / Exp Data Exch Def & Map", XMLInStream);
        end;
        IntrastatReportSetup.Get();
        IntrastatReportSetup."Data Exch. Def. Code" := 'INTRA-2022';
        IntrastatReportSetup.Modify();
    end;

    procedure CreateAndPostJobJournalLine(ShipmentMethodCode: Code[10]; LocationCode: Code[10]): Code[20]
    var
        CompanyInformation: Record "Company Information";
        CountryRegion: Record "Country/Region";
        Job: Record Job;
        JobJournalLine: Record "Job Journal Line";
        JobTask: Record "Job Task";
        SourceCodeSetup: Record "Source Code Setup";
    begin
        LibraryJob.CreateJob(Job);
        LibraryJob.CreateJobTask(Job, JobTask);
        LibraryJob.CreateJobJournalLineForType(LibraryJob.UsageLineTypeBlank(), LibraryJob.ItemType(), JobTask, JobJournalLine);
        CompanyInformation.Get();
        CountryRegion.SetFilter(Code, '<>%1', CompanyInformation."Country/Region Code");
        CountryRegion.SetFilter("Intrastat Code", '<>%1', '');
        CountryRegion.FindFirst();
        Job.Validate("Bill-to Country/Region Code", CountryRegion.Code);
        Job.Validate("Sell-to Country/Region Code", CountryRegion.Code);
        Job.Validate("Ship-to Country/Region Code", CountryRegion.Code);
        Job.Modify(true);
        JobJournalLine.Validate("Country/Region Code", CountryRegion.Code);
        JobJournalLine.Validate("Shpt. Method Code", ShipmentMethodCode);
        JobJournalLine.Validate("Location Code", LocationCode);
        SourceCodeSetup.Get();
        JobJournalLine.Validate("Source Code", SourceCodeSetup."Job Journal");
        JobJournalLine.Modify(true);

        LibraryJob.PostJobJournal(JobJournalLine);

        exit(JobJournalLine."No.");
    end;

    procedure CreateSalesDocument(var SalesHeader: Record "Sales Header"; var SalesLine: Record "Sales Line"; CustomerNo: Code[20]; PostingDate: Date; DocumentType: Enum "Sales Document Type"; Type: Enum "Sales Line Type"; No: Code[20];
                                                                                                                                                                              NoOfLines: Integer)
    var
        FADepreciationBook: Record "FA Depreciation Book";
        i: Integer;
    begin
        // Create Sales Order with Random Quantity and Unit Price.
        CreateSalesHeader(SalesHeader, CustomerNo, PostingDate, DocumentType);
        for i := 1 to NoOfLines do begin
            LibrarySales.CreateSalesLine(SalesLine, SalesHeader, Type, No, LibraryRandom.RandDec(10, 2));
            SalesLine.Validate("Unit Price", LibraryRandom.RandDec(100, 2));
            if SalesLine.Type = SalesLine.Type::"Fixed Asset" then begin
                FADepreciationBook.SetRange("FA No.", No);
                FADepreciationBook.FindFirst();
                SalesLine.Validate("Depreciation Book Code", FADepreciationBook."Depreciation Book Code");
                SalesLine.Validate(Quantity, 1);
            end;
            SalesLine.Modify(true);
        end;
    end;

    procedure CreateSalesShipmentHeader(var SalesShipmentHeader: Record "Sales Shipment Header"; ShippingInternetAddress: Text[250])
    begin
        SalesShipmentHeader.Init();
        SalesShipmentHeader."Package Tracking No." := LibraryUtility.GenerateGUID();
        SalesShipmentHeader."Shipping Agent Code" := CreateShippingAgent(ShippingInternetAddress);
    end;

    procedure CreateSalesHeader(var SalesHeader: Record "Sales Header"; CustomerNo: Code[20]; PostingDate: Date; DocumentType: Enum "Sales Document Type")
    begin
        LibrarySales.CreateSalesHeader(SalesHeader, DocumentType, CustomerNo);
        SalesHeader.Validate("Posting Date", PostingDate);
        SalesHeader.Modify(true);
    end;

    procedure CreateAndPostSalesInvoiceWithItemAndItemCharge(PostingDate: Date): Code[20]
    var
        SalesHeader: Record "Sales Header";
        SalesLine: Record "Sales Line";
        SalesLine2: Record "Sales Line";
        LibraryCosting: Codeunit "Library - Costing";
    begin
        CreateSalesHeader(SalesHeader, CreateCustomer(), PostingDate, SalesHeader."Document Type"::Invoice);
        LibrarySales.CreateSalesLine(SalesLine2, SalesHeader, SalesLine.Type::Item, '', LibraryRandom.RandDec(10, 2));
        SalesLine2.Validate("Unit Price", LibraryRandom.RandDec(100, 2));
        SalesLine2.Modify(true);
        LibrarySales.CreateSalesLine(SalesLine, SalesHeader, SalesLine.Type::"Charge (Item)", '', LibraryRandom.RandDec(10, 2));
        SalesLine.Validate("Unit Price", LibraryRandom.RandDec(100, 2));
        SalesLine.Modify(true);
        LibraryCosting.AssignItemChargeSales(SalesLine, SalesLine2);
        exit(LibrarySales.PostSalesDocument(SalesHeader, false, true));
    end;

    procedure CreateAndPostSalesCrMemoForItemCharge(PostedSalesInvoiceCode: Code[20]; PostingDate: Date): Code[20]
    var
        SalesHeader: Record "Sales Header";
        SalesLine: Record "Sales Line";
        SalesInvoiceHeader: Record "Sales Invoice Header";
        CorrectPostedSalesInvoice: Codeunit "Correct Posted Sales Invoice";
    begin
        SalesInvoiceHeader.Get(PostedSalesInvoiceCode);
        CorrectPostedSalesInvoice.CreateCreditMemoCopyDocument(SalesInvoiceHeader, SalesHeader);
        SalesLine.SetRange("Document Type", SalesLine."Document Type"::"Credit Memo");
        SalesLine.SetRange("Document No.", SalesHeader."No.");
        SalesLine.SetRange(Type, SalesLine.Type::Item);
        SalesLine.FindFirst();
        SalesLine.Delete(true);
        SalesHeader.Validate("Posting Date", PostingDate);
        SalesHeader.Modify(true);
        exit(LibrarySales.PostSalesDocument(SalesHeader, false, true));
    end;

    procedure CreateItemLedgerEntry(var ItemLedgerEntry: Record "Item Ledger Entry"; PostingDate: Date; ItemNo: Code[20]; Quantity: Decimal; ILEEntryType: Enum "Item Ledger Entry Type")
    var
        ItemLedgerEntryNo: Integer;
    begin
        ItemLedgerEntryNo := LibraryUtility.GetNewRecNo(ItemLedgerEntry, ItemLedgerEntry.FieldNo("Entry No."));
        Clear(ItemLedgerEntry);
        ItemLedgerEntry."Entry No." := ItemLedgerEntryNo;
        ItemLedgerEntry."Item No." := ItemNo;
        ItemLedgerEntry."Posting Date" := PostingDate;
        ItemLedgerEntry."Entry Type" := ILEEntryType;
        ItemLedgerEntry.Quantity := Quantity;
        ItemLedgerEntry."Country/Region Code" := GetCountryRegionCode();
        ItemLedgerEntry.Insert();
    end;

    procedure CreateValueEntry(var ValueEntry: Record "Value Entry"; var ItemLedgerEntry: Record "Item Ledger Entry"; DocumentType: Enum "Item Ledger Document Type"; PostingDate: Date)
    var
        ValueEntryNo: Integer;
    begin
        ValueEntryNo := LibraryUtility.GetNewRecNo(ValueEntry, ValueEntry.FieldNo("Entry No."));
        Clear(ValueEntry);
        ValueEntry."Entry No." := ValueEntryNo;
        ValueEntry."Item No." := ItemLedgerEntry."Item No.";
        ValueEntry."Posting Date" := PostingDate;
        ValueEntry."Entry Type" := ValueEntry."Entry Type"::"Direct Cost";
        ValueEntry."Item Ledger Entry Type" := ItemLedgerEntry."Entry Type";
        ValueEntry."Item Ledger Entry No." := ItemLedgerEntry."Entry No.";
        ValueEntry."Item Charge No." := LibraryInventory.CreateItemChargeNo();
        ValueEntry."Document Type" := DocumentType;
        ValueEntry.Insert();
    end;

    procedure CreateCustomerWithVATRegNo(IsEUCountry: Boolean): Code[20]
    var
        Customer: Record Customer;
    begin
        LibrarySales.CreateCustomer(Customer);
        Customer.Validate("Country/Region Code", CreateCountryRegionWithIntrastatCode(IsEUCountry));
        Customer.Validate("VAT Registration No.", LibraryERM.GenerateVATRegistrationNo(Customer."Country/Region Code"));
        Customer.Modify(true);
        exit(Customer."No.");
    end;

    procedure CreateVendorWithVATRegNo(IsEUCountry: Boolean): Code[20]
    var
        Vendor: Record Vendor;
    begin
        LibraryPurchase.CreateVendor(Vendor);
        Vendor.Validate("Country/Region Code", CreateCountryRegionWithIntrastatCode(IsEUCountry));
        Vendor.Validate("VAT Registration No.", LibraryERM.GenerateVATRegistrationNo(Vendor."Country/Region Code"));
        Vendor.Modify(true);
        exit(Vendor."No.");
    end;

    procedure CreateCountryRegion(var CountryRegion: Record "Country/Region"; IsEUCountry: Boolean)
    begin
        CountryRegion.Code := LibraryUtility.GenerateRandomCodeWithLength(CountryRegion.FieldNo(Code), Database::"Country/Region", 3);
        CountryRegion.Validate("Intrastat Code", CopyStr(LibraryUtility.GenerateRandomAlphabeticText(3, 0), 1, 3));
        if IsEUCountry then
            CountryRegion.Validate("EU Country/Region Code", CopyStr(LibraryUtility.GenerateRandomAlphabeticText(3, 0), 1, 3));
        CountryRegion.Insert(true);
    end;

    procedure CreateCountryRegionWithIntrastatCode(IsEUIntrastat: Boolean): Code[10]
    var
        CountryRegion: Record "Country/Region";
    begin
        CreateCountryRegion(CountryRegion, IsEUIntrastat);
        exit(CountryRegion.Code);
    end;

    procedure CreateCustomer(): Code[20]
    var
        Customer: Record Customer;
    begin
        LibrarySales.CreateCustomer(Customer);
        Customer.Validate("Country/Region Code", GetCountryRegionCode());
        Customer.Modify(true);
        exit(Customer."No.");
    end;

    procedure CreateAndPostPurchaseOrder(var PurchaseLine: Record "Purchase Line"; PostingDate: Date): Code[20]
    var
        PurchaseHeader: Record "Purchase Header";
    begin
        exit(
          CreateAndPostPurchaseDocumentMultiLine(
            PurchaseLine, PurchaseHeader."Document Type"::Order, PostingDate, PurchaseLine.Type::Item, CreateItem(), 1));
    end;

    procedure CreateAndPostPurchaseDocumentMultiLine(var PurchaseLine: Record "Purchase Line"; DocumentType: Enum "Purchase Document Type"; PostingDate: Date;
                                                                                                                       LineType: Enum "Purchase Line Type";
                                                                                                                       ItemNo: Code[20];
                                                                                                                       NoOfLines: Integer): Code[20]
    var
        PurchaseHeader: Record "Purchase Header";
        i: Integer;
    begin
        CreatePurchaseHeader(PurchaseHeader, DocumentType, PostingDate, CreateVendor(GetCountryRegionCode()));
        for i := 1 to NoOfLines do
            CreatePurchaseLine(PurchaseHeader, PurchaseLine, LineType, ItemNo);
        if LineType = LineType::"Fixed Asset" then
            exit(LibraryPurchase.PostPurchaseDocument(PurchaseHeader, true, true))
        else
            exit(LibraryPurchase.PostPurchaseDocument(PurchaseHeader, true, false));
    end;

    procedure CreateAndPostPurchaseOrderWithInvoice(var PurchaseLine: Record "Purchase Line"; PostingDate: Date): Code[20]
    var
        PurchaseHeader: Record "Purchase Header";
    begin
        exit(
          CreateAndPostPurchaseDocumentMultiLineWithInvoice(
            PurchaseLine, PurchaseHeader."Document Type"::Order, PostingDate, PurchaseLine.Type::Item, CreateItem(), 1));
    end;

    procedure CreateAndPostPurchaseDocumentMultiLineWithInvoice(var PurchaseLine: Record "Purchase Line"; DocumentType: Enum "Purchase Document Type"; PostingDate: Date;
                                                                                                                       LineType: Enum "Purchase Line Type";
                                                                                                                       ItemNo: Code[20];
                                                                                                                       NoOfLines: Integer): Code[20]
    var
        PurchaseHeader: Record "Purchase Header";
        i: Integer;
    begin
        CreatePurchaseHeader(PurchaseHeader, DocumentType, PostingDate, CreateVendor(GetCountryRegionCode()));
        for i := 1 to NoOfLines do
            CreatePurchaseLine(PurchaseHeader, PurchaseLine, LineType, ItemNo);
        exit(LibraryPurchase.PostPurchaseDocument(PurchaseHeader, true, true));
    end;

    procedure CreateItem(): Code[20]
    var
        Item: Record Item;
    begin
        LibraryInventory.CreateItemWithTariffNo(Item, CopyStr(LibraryUtility.CreateCodeRecord(DATABASE::"Tariff Number"), 3, 10));
        exit(Item."No.");
    end;

    procedure CreateTrackedItem(Tracking: Integer; CreateInfo: Boolean; CreateInfoOnPosting: Boolean;
        var SerialNoInformation: Record "Serial No. Information";
        var LotNoInformation: Record "Lot No. Information";
        var PackageNoInformation: Record "Package No. Information"): Code[20]
    var
        CountryRegion: Record "Country/Region";
        Item: Record Item;
        ItemTrackingCode: Record "Item Tracking Code";
    begin
        CreateCountryRegion(CountryRegion, false);
        LibraryInventory.CreateItem(Item);
        case Tracking of
            1:
                begin
                    LibraryItemTracking.CreateItemTrackingCode(ItemTrackingCode, true, false, false); // Serial No.
                    if CreateInfo then begin
                        LibraryItemTracking.CreateSerialNoInformation(SerialNoInformation, Item."No.", '', LibraryUtility.GenerateGUID());
                        SerialNoInformation.Validate("Country/Region Code", CountryRegion.Code);
                        SerialNoInformation.Modify(true);
                    end;
                    if CreateInfoOnPosting then begin
                        ItemTrackingCode.Validate("Create SN Info on Posting", true);
                        ItemTrackingCode.Modify(true);
                    end;
                end;
            2:
                begin
                    LibraryItemTracking.CreateItemTrackingCode(ItemTrackingCode, false, true, false); // Lot No.
                    if CreateInfo then begin
                        LibraryItemTracking.CreateLotNoInformation(LotNoInformation, Item."No.", '', LibraryUtility.GenerateGUID());
                        LotNoInformation.Validate("Country/Region Code", CountryRegion.Code);
                        LotNoInformation.Modify(true);
                    end;
                    if CreateInfoOnPosting then begin
                        ItemTrackingCode.Validate("Create Lot No. Info on posting", true);
                        ItemTrackingCode.Modify(true);
                    end;
                end;
            3:
                begin
                    LibraryItemTracking.CreateItemTrackingCode(ItemTrackingCode, false, false, true); // Package No.
                    if CreateInfo then begin
                        LibraryItemTracking.CreatePackageNoInformation(PackageNoInformation, Item."No.", LibraryUtility.GenerateGUID());
                        PackageNoInformation.Validate("Country/Region Code", CountryRegion.Code);
                        PackageNoInformation.Modify(true);
                    end;
                end;
        end;

        Item.Validate("Item Tracking Code", ItemTrackingCode.Code);
        CreateCountryRegion(CountryRegion, true);
        Item.Validate("Country/Region of Origin Code", CountryRegion.Code);
        Item.Modify(true);

        exit(Item."No.");
    end;

    procedure CreateFixedAsset(): Code[20]
    var
        FixedAsset: Record "Fixed Asset";
    begin
        LibraryFixedAsset.CreateFixedAsset(FixedAsset);
        exit(FixedAsset."No.");
    end;

    procedure CreateItemChargeAssignmentForPurchaseCreditMemo(PurchaseLine: Record "Purchase Line"; DocumentNo: Code[20])
    var
        ItemChargeAssignmentPurch: Record "Item Charge Assignment (Purch)";
        PurchRcptLine: Record "Purch. Rcpt. Line";
        ItemChargeAssgntPurch: Codeunit "Item Charge Assgnt. (Purch.)";
    begin
        ItemChargeAssignmentPurch.Init();
        ItemChargeAssignmentPurch.Validate("Document Type", PurchaseLine."Document Type");
        ItemChargeAssignmentPurch.Validate("Document No.", PurchaseLine."Document No.");
        ItemChargeAssignmentPurch.Validate("Document Line No.", PurchaseLine."Line No.");
        ItemChargeAssignmentPurch.Validate("Item Charge No.", PurchaseLine."No.");
        ItemChargeAssignmentPurch.Validate("Unit Cost", PurchaseLine."Direct Unit Cost");
        PurchRcptLine.SetRange("Document No.", DocumentNo);
        PurchRcptLine.FindFirst();
        ItemChargeAssgntPurch.CreateRcptChargeAssgnt(PurchRcptLine, ItemChargeAssignmentPurch);
        UpdatePurchaseItemChargeQtyToAssign(PurchaseLine);
    end;

    procedure CreateItemChargeAssignmentForSalesCreditMemo(SalesLine: Record "Sales Line"; DocumentNo: Code[20])
    var
        SalesShipmentLine: Record "Sales Shipment Line";
        ItemChargeAssignmentSales: Record "Item Charge Assignment (Sales)";
        ItemChargeAssgntSales: Codeunit "Item Charge Assgnt. (Sales)";
    begin
        ItemChargeAssignmentSales.Init();
        ItemChargeAssignmentSales.Validate("Document Type", SalesLine."Document Type");
        ItemChargeAssignmentSales.Validate("Document No.", SalesLine."Document No.");
        ItemChargeAssignmentSales.Validate("Document Line No.", SalesLine."Line No.");
        ItemChargeAssignmentSales.Validate("Item Charge No.", SalesLine."No.");
        ItemChargeAssignmentSales.Validate("Unit Cost", SalesLine."Unit Price");
        SalesShipmentLine.SetRange("Document No.", DocumentNo);
        SalesShipmentLine.FindFirst();
        ItemChargeAssgntSales.CreateShptChargeAssgnt(SalesShipmentLine, ItemChargeAssignmentSales);
        UpdateSalesItemChargeQtyToAssign(SalesLine);
    end;

    procedure CreatePurchaseHeader(var PurchaseHeader: Record "Purchase Header"; DocumentType: Enum "Purchase Document Type"; PostingDate: Date;
                                                                                                         VendorNo: Code[20])
    var
        Location: Record Location;
    begin
        // Create Purchase Order With Random Quantity and Direct Unit Cost.
        LibraryPurchase.CreatePurchHeader(PurchaseHeader, DocumentType, VendorNo);
        with PurchaseHeader do begin
            Validate("Posting Date", PostingDate);
            LibraryWarehouse.CreateLocationWithInventoryPostingSetup(Location);
            Validate("Location Code", Location.Code);
            Modify(true);
        end;
    end;

    procedure CreatePurchaseLine(var PurchaseHeader: Record "Purchase Header"; var PurchaseLine: Record "Purchase Line"; Type: Enum "Purchase Line Type"; No: Code[20])
    var
        DepreciationBook: Record "Depreciation Book";
        FADepreciationBook: Record "FA Depreciation Book";
        FAPostingGroup: Record "FA Posting Group";
    begin
        // Take Random Values for Purchase Line.
        LibraryPurchase.CreatePurchaseLine(PurchaseLine, PurchaseHeader, Type, No, LibraryRandom.RandDec(10, 2));
        PurchaseLine.Validate("Direct Unit Cost", LibraryRandom.RandDec(100, 2));

        if PurchaseLine.Type = PurchaseLine.Type::"Fixed Asset" then begin
            LibraryFixedAsset.CreateDepreciationBook(DepreciationBook);
            DepreciationBook.Validate("G/L Integration - Acq. Cost", true);
            DepreciationBook.Validate("G/L Integration - Disposal", true);
            DepreciationBook.Modify(true);

            LibraryFixedAsset.CreateFADepreciationBook(FADepreciationBook, No, DepreciationBook.Code);
            LibraryFixedAsset.CreateFAPostingGroup(FAPostingGroup);
            FADepreciationBook.Validate("FA Posting Group", FAPostingGroup.Code);
            FADepreciationBook.Modify(true);

            PurchaseLine.Validate("Depreciation Book Code", DepreciationBook.Code);
            PurchaseLine.Validate(Quantity, 1);
        end;

        PurchaseLine.Modify(true);
    end;

    procedure CreateAndPostPurchaseItemJournalLine(LocationCode: Code[10]; ItemNo: Code[20])
    var
        ItemJournalTemplate: Record "Item Journal Template";
        ItemJournalBatch: Record "Item Journal Batch";
        ItemJournalLine: Record "Item Journal Line";
    begin
        LibraryInventory.CreateItemJournalTemplate(ItemJournalTemplate);
        LibraryInventory.CreateItemJournalBatch(ItemJournalBatch, ItemJournalTemplate.Name);
        LibraryInventory.CreateItemJournalLine(
          ItemJournalLine,
          ItemJournalTemplate.Name,
          ItemJournalBatch.Name,
          ItemJournalLine."Entry Type"::Purchase,
          ItemNo,
          LibraryRandom.RandIntInRange(10, 1000));
        ItemJournalLine.Validate("Location Code", LocationCode);
        ItemJournalLine.Modify(true);
        LibraryInventory.PostItemJournalLine(ItemJournalTemplate.Name, ItemJournalBatch.Name);
    end;

    procedure CreateAndPostSalesOrder(var SalesLine: Record "Sales Line"; PostingDate: Date): Code[20]
    var
        SalesHeader: Record "Sales Header";
    begin
        exit(
          CreateAndPostSalesDocumentMultiLine(
            SalesLine, SalesHeader."Document Type"::Order, PostingDate, SalesLine.Type::Item, CreateItem(), 1));
    end;

    procedure CreateFromToLocations(var LocationFrom: Record Location; var LocationTo: Record Location; CountryRegionCode: Code[10])
    begin
        LibraryWarehouse.CreateLocationWithInventoryPostingSetup(LocationFrom);
        LibraryWarehouse.CreateLocationWithInventoryPostingSetup(LocationTo);
        LocationTo.Validate("Country/Region Code", CountryRegionCode);
        LocationTo.Modify(true);
    end;

    procedure CreateAndPostSalesOrderWithCountryAndLocation(CountryRegionCode: Code[10]; LocationCode: Code[10]; ItemNo: Code[20])
    var
        Customer: Record Customer;
        SalesHeader: Record "Sales Header";
        SalesLine: Record "Sales Line";
    begin
        LibrarySales.CreateCustomerWithLocationCode(Customer, LocationCode);
        Customer.Validate("Country/Region Code", CountryRegionCode);
        Customer.Modify(true);
        LibrarySales.CreateSalesHeader(SalesHeader, SalesHeader."Document Type"::Order, Customer."No.");
        SalesHeader.Validate("Location Code", LocationCode);
        SalesHeader.Validate("VAT Country/Region Code", CountryRegionCode);
        SalesHeader.Modify(true);
        LibrarySales.CreateSalesLine(SalesLine, SalesHeader, SalesLine.Type::Item, ItemNo, 1);
        LibrarySales.PostSalesDocument(SalesHeader, true, true);
    end;

    procedure CreateAndPostSalesOrderWithDiferrentCountries(SellToCountryRegionCode: Code[10]; ShipToCountryRegionCode: Code[10]; BillToCountryRegionCode: Code[10]; InvoiceDate: Date)
    var
        Customer: Record Customer;
        SalesHeader: Record "Sales Header";
        SalesLine: Record "Sales Line";
    begin
        LibrarySales.CreateCustomer(Customer);
        Customer.Validate("Country/Region Code", SellToCountryRegionCode);
        Customer.Modify(true);
        LibrarySales.CreateSalesHeader(SalesHeader, SalesHeader."Document Type"::Order, Customer."No.");
        SalesHeader.Validate("Posting Date", InvoiceDate);
        SalesHeader.Validate("Sell-to Country/Region Code", SellToCountryRegionCode);
        SalesHeader.Validate("Ship-to Country/Region Code", ShipToCountryRegionCode);
        SalesHeader.Validate("Bill-to Country/Region Code", BillToCountryRegionCode);
        SalesHeader.Modify(true);
        LibrarySales.CreateSalesLine(SalesLine, SalesHeader, SalesLine.Type::Item, CreateItem(), 1);
        LibrarySales.PostSalesDocument(SalesHeader, true, false);
    end;

    procedure CreateAndPostSalesDocumentMultiLine(var SalesLine: Record "Sales Line"; DocumentType: Enum "Sales Document Type"; PostingDate: Date;
                                                                                                             LineType: Enum "Sales Line Type";
                                                                                                             ItemNo: Code[20];
                                                                                                             NoOfSalesLines: Integer): Code[20]
    var
        SalesHeader: Record "Sales Header";
    begin
        CreateSalesDocument(SalesHeader, SalesLine, CreateCustomer(), PostingDate, DocumentType, LineType, ItemNo, NoOfSalesLines);
        if LineType = LineType::"Fixed Asset" then
            exit(LibrarySales.PostSalesDocument(SalesHeader, true, true))
        else
            exit(LibrarySales.PostSalesDocument(SalesHeader, true, false));
    end;

    procedure CreateAndPostSalesOrderWithInvoice(var SalesLine: Record "Sales Line"; PostingDate: Date): Code[20]
    var
        SalesHeader: Record "Sales Header";
    begin
        exit(
          CreateAndPostSalesDocumentMultiLineWithInvoice(
            SalesLine, SalesHeader."Document Type"::Order, PostingDate, SalesLine.Type::Item, CreateItem(), 1));
    end;

    procedure CreateAndPostSalesDocumentMultiLineWithInvoice(var SalesLine: Record "Sales Line"; DocumentType: Enum "Sales Document Type"; PostingDate: Date;
                                                                                                         LineType: Enum "Sales Line Type";
                                                                                                         ItemNo: Code[20];
                                                                                                         NoOfSalesLines: Integer): Code[20]
    var
        SalesHeader: Record "Sales Header";
    begin
        CreateSalesDocument(SalesHeader, SalesLine, CreateCustomer(), PostingDate, DocumentType, LineType, ItemNo, NoOfSalesLines);
        exit(LibrarySales.PostSalesDocument(SalesHeader, true, true));
    end;

    procedure CreateAndPostTransferOrder(var TransferLine: Record "Transfer Line"; FromLocation: Code[10]; ToLocation: Code[10]; ItemNo: Code[20])
    var
        TransferHeader: Record "Transfer Header";
    begin
        LibraryWarehouse.CreateTransferHeader(TransferHeader, FromLocation, ToLocation, '');
        TransferHeader.Validate("Direct Transfer", true);
        TransferHeader.Modify(true);
        LibraryWarehouse.CreateTransferLine(TransferHeader, TransferLine, ItemNo, 1);
        LibraryWarehouse.PostTransferOrder(TransferHeader, true, true);
    end;

    procedure CreateShippingAgent(ShippingInternetAddress: Text[250]): Code[10]
    var
        ShippingAgent: Record "Shipping Agent";
    begin
        LibraryInventory.CreateShippingAgent(ShippingAgent);
        ShippingAgent."Internet Address" := ShippingInternetAddress;
        ShippingAgent.Modify();
        exit(ShippingAgent.Code);
    end;

    procedure CreateVendor(CountryRegionCode: Code[10]): Code[20]
    var
        Vendor: Record Vendor;
    begin
        LibraryPurchase.CreateVendor(Vendor);
        Vendor.Validate("Country/Region Code", CountryRegionCode);
        Vendor.Modify(true);
        exit(Vendor."No.");
    end;

    procedure DeleteIntrastatReport(IntrastatReportNo: Code[20])
    var
        IntrastatReportHeader: Record "Intrastat Report Header";
        IntrastatReportLine: Record "Intrastat Report Line";
    begin
        IntrastatReportLine.SetRange("Intrastat No.", IntrastatReportNo);
        IntrastatReportLine.DeleteAll(true);
        IntrastatReportHeader.SetRange("No.", IntrastatReportNo);
        IntrastatReportHeader.DeleteAll(true);
    end;

    procedure GetCountryRegionCode(): Code[10]
    var
        CountryRegion: Record "Country/Region";
        CompanyInformation: Record "Company Information";
    begin
        CompanyInformation.Get();
        CountryRegion.SetFilter(Code, '<>%1', CompanyInformation."Country/Region Code");
        CountryRegion.SetFilter("Intrastat Code", '<>''''');
        CountryRegion.FindFirst();
        exit(CountryRegion.Code);
    end;

    procedure GetCompanyInfoCountryRegionCode(): Code[10]
    var
        CompanyInformation: Record "Company Information";
    begin
        CompanyInformation.Get();
        exit(CompanyInformation."Country/Region Code");
    end;

    procedure GetIntrastatNo() NoSeriesCode: Code[20]
    var
        IntrastatReportSetup: Record "Intrastat Report Setup";
        NoSeries: Record "No. Series";
        NoSeriesCodeunit: Codeunit "No. Series";
    begin
        NoSeries.SetFilter(NoSeries.Code, IntrastatReportSetup."Intrastat Nos.");
        NoSeries.FindFirst();
        NoSeriesCode := NoSeriesCodeunit.GetNextNo(NoSeries.Code);
    end;

    procedure GetStatisticalPeriod(ReportDate: Date): code[20]
    var
        Month: Code[2];
        Year: Code[4];
    begin
        Month := format(Date2DMY(ReportDate, 2));
        If StrLen(Month) < 2 then
            Month := '0' + Month;
        Year := CopyStr(format(Date2DMY(ReportDate, 3)), 3, 2);
        exit(Year + Month);
    end;

    procedure GetIntrastatReportLine(DocumentNo: Code[20]; IntrastatReportNo: Code[20]; var IntrastatReportLine: Record "Intrastat Report Line")
    begin
        IntrastatReportLine.SetRange("Intrastat No.", IntrastatReportNo);
        IntrastatReportLine.SetRange("Document No.", DocumentNo);
        IntrastatReportLine.FindFirst();
    end;

    procedure IntrastatSetupEnableReportReceipts()
    var
        IntrastatReportSetup: Record "Intrastat Report Setup";
    begin
        if not IntrastatReportSetup.Get() then
            CreateIntrastatReportSetup();
        IntrastatReportSetup.get();
        IntrastatReportSetup."Report Receipts" := true;
        IntrastatReportSetup.Modify();
    end;

    procedure SetIntrastatContact(ContactType: Enum "Intrastat Report Contact Type"; ContactNo: Code[20])
    var
        IntrastatReportSetup: Record "Intrastat Report Setup";
    begin
        IntrastatReportSetup.Get();
        IntrastatReportSetup.Validate("Intrastat Contact Type", ContactType);
        IntrastatReportSetup.Validate("Intrastat Contact No.", ContactNo);
        IntrastatReportSetup.Modify();
    end;

    procedure UpdatePurchaseItemChargeQtyToAssign(PurchaseLine: Record "Purchase Line")
    var
        ItemChargeAssignmentPurch: Record "Item Charge Assignment (Purch)";
    begin
        ItemChargeAssignmentPurch.Get(
          PurchaseLine."Document Type", PurchaseLine."Document No.", PurchaseLine."Line No.", PurchaseLine."Line No.");
        ItemChargeAssignmentPurch.Validate("Qty. to Assign", PurchaseLine.Quantity);
        ItemChargeAssignmentPurch.Modify(true);
    end;

    procedure UpdateSalesItemChargeQtyToAssign(SalesLine: Record "Sales Line")
    var
        ItemChargeAssignmentSales: Record "Item Charge Assignment (Sales)";
    begin
        ItemChargeAssignmentSales.Get(SalesLine."Document Type", SalesLine."Document No.", SalesLine."Line No.", SalesLine."Line No.");
        ItemChargeAssignmentSales.Validate("Qty. to Assign", SalesLine.Quantity);
        ItemChargeAssignmentSales.Modify(true);
    end;

    procedure UndoPurchaseReceiptLine(DocumentNo: Code[20]; No: Code[20])
    var
        PurchRcptLine: Record "Purch. Rcpt. Line";
    begin
        PurchRcptLine.SetRange("Document No.", DocumentNo);
        PurchRcptLine.SetRange("No.", No);
        PurchRcptLine.FindFirst();
        LibraryPurchase.UndoPurchaseReceiptLine(PurchRcptLine);
    end;

    procedure UndoPurchaseReceiptLineByLineNo(DocumentNo: Code[20]; LineNo: Integer)
    var
        PurchRcptLine: Record "Purch. Rcpt. Line";
    begin
        PurchRcptLine.SetRange("Document No.", DocumentNo);
        PurchRcptLine.FindSet();
        PurchRcptLine.Next(LineNo - 1);
        PurchRcptLine.SetRecFilter();
        LibraryPurchase.UndoPurchaseReceiptLine(PurchRcptLine);
    end;

    procedure UndoReturnShipmentLineByLineNo(DocumentNo: Code[20]; LineNo: Integer)
    var
        ReturnShipmentLine: Record "Return Shipment Line";
    begin
        ReturnShipmentLine.SetRange("Document No.", DocumentNo);
        ReturnShipmentLine.FindSet();
        ReturnShipmentLine.Next(LineNo - 1);
        ReturnShipmentLine.SetRecFilter();

        LibraryPurchase.UndoReturnShipmentLine(ReturnShipmentLine);
    end;

    procedure UndoSalesShipmentLine(DocumentNo: Code[20]; No: Code[20])
    var
        SalesShipmentLine: Record "Sales Shipment Line";
    begin
        SalesShipmentLine.SetRange("Document No.", DocumentNo);
        SalesShipmentLine.SetRange("No.", No);
        SalesShipmentLine.FindFirst();
        LibrarySales.UndoSalesShipmentLine(SalesShipmentLine);
    end;

    procedure UndoSalesShipmentLineByLineNo(DocumentNo: Code[20]; LineNo: Integer)
    var
        SalesShipmentLine: Record "Sales Shipment Line";
    begin
        SalesShipmentLine.SetRange("Document No.", DocumentNo);
        SalesShipmentLine.FindSet();
        SalesShipmentLine.Next(LineNo - 1);
        SalesShipmentLine.SetRecFilter();

        LibrarySales.UndoSalesShipmentLine(SalesShipmentLine);
    end;

    procedure UndoReturnReceiptLineByLineNo(DocumentNo: Code[20]; LineNo: Integer)
    var
        ReturnReceiptLine: Record "Return Receipt Line";
    begin
        ReturnReceiptLine.SetRange("Document No.", DocumentNo);
        ReturnReceiptLine.FindSet();
        ReturnReceiptLine.Next(LineNo - 1);
        ReturnReceiptLine.SetRecFilter();
        LibrarySales.UndoReturnReceiptLine(ReturnReceiptLine);
    end;

    procedure UpdateShipmentOnInvoiceSalesSetup(ShipmentOnInvoice: Boolean)
    var
        SalesReceivablesSetup: Record "Sales & Receivables Setup";
    begin
        SalesReceivablesSetup.Get();
        SalesReceivablesSetup.Validate("Shipment on Invoice", ShipmentOnInvoice);
        SalesReceivablesSetup.Modify(true);
    end;

    procedure UpdateRetShpmtOnCrMemoPurchSetup(RetShpmtOnCrMemo: Boolean)
    var
        PurchasesPayablesSetup: Record "Purchases & Payables Setup";
    begin
        PurchasesPayablesSetup.Get();
        PurchasesPayablesSetup.Validate("Return Shipment on Credit Memo", RetShpmtOnCrMemo);
        PurchasesPayablesSetup.Modify(true);
    end;

    procedure UpdateReturnReceiptOnCreditMemoSalesSetup(ReturnReceiptOnCreditMemo: Boolean)
    var
        SalesReceivablesSetup: Record "Sales & Receivables Setup";
    begin
        SalesReceivablesSetup.Get();
        SalesReceivablesSetup.Validate("Return Receipt on Credit Memo", ReturnReceiptOnCreditMemo);
        SalesReceivablesSetup.Modify(true);
    end;

    procedure UpdateIntrastatCodeInCountryRegion()
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

    procedure UpdateIntrastatReportSetupDataExchDef(DataExchDefCode: Code[20])
    var
        IntrastatReportSetup: Record "Intrastat Report Setup";
    begin
        IntrastatReportSetup.Get();
        IntrastatReportSetup.Validate("Data Exch. Def. Code", DataExchDefCode);
        IntrastatReportSetup.Modify();
    end;

    procedure UseItemNonZeroNetWeight(var IntrastatReportLine: Record "Intrastat Report Line"): Decimal
    var
        Item: Record Item;
    begin
        Item.Get(CreateItem());
        IntrastatReportLine.Validate("Item No.", Item."No.");
        IntrastatReportLine.Validate(Quantity, LibraryRandom.RandDecInRange(10, 20, 2));
        IntrastatReportLine.Modify(true);
        exit(Item."Net Weight");
    end;

    procedure CreateAndPostSalesOrderWithCountryAndLocation(CountryRegionCode: Code[10]; LocationCode: Code[10]; ItemNo: Code[20]; NewShipReceive: Boolean; NewInvoice: Boolean): Code[20]
    var
        Customer: Record Customer;
        SalesHeader: Record "Sales Header";
        SalesLine: Record "Sales Line";
    begin
        LibrarySales.CreateCustomerWithLocationCode(Customer, LocationCode);
        Customer.Validate("Country/Region Code", CountryRegionCode);
        Customer.Modify(true);
        LibrarySales.CreateSalesHeader(SalesHeader, SalesHeader."Document Type"::Order, Customer."No.");
        SalesHeader.Validate("Location Code", LocationCode);
        SalesHeader.Validate("VAT Country/Region Code", CountryRegionCode);
        SalesHeader.Modify(true);
        LibrarySales.CreateSalesLine(SalesLine, SalesHeader, SalesLine.Type::Item, ItemNo, 1);
        exit(LibrarySales.PostSalesDocument(SalesHeader, NewShipReceive, NewInvoice));
    end;

    procedure CreateSalesOrdersWithDropShipment(var SalesHeader: Record "Sales Header"; EUCustomer: Boolean): Code[20]
    var
        Customer: Record Customer;
        SalesLine: Record "Sales Line";
    begin
        if EUCustomer then
            LibrarySales.CreateSalesHeader(SalesHeader, SalesHeader."Document Type"::Order, CreateCustomer())
        else begin
            LibrarySales.CreateCustomer(Customer);
            LibrarySales.CreateSalesHeader(SalesHeader, SalesHeader."Document Type"::Order, Customer."No.")
        end;
        CreateDropShipmentLine(SalesLine, SalesHeader);
        SalesLine.Validate("Unit Price", LibraryRandom.RandDec(1000, 2));
        SalesLine.Modify(true);
        LibrarySales.ReleaseSalesDocument(SalesHeader);
        exit(SalesLine."No.");
    end;

    procedure CreatePurchOrdersWithDropShipment(var PurchHeader: Record "Purchase Header"; SellToCustomerNo: Code[20]; EUVendor: Boolean)
    begin
        if EUVendor then
            LibraryPurchase.CreatePurchHeader(PurchHeader, PurchHeader."Document Type"::Order, CreateVendor(GetCountryRegionCode()))
        else
            LibraryPurchase.CreatePurchHeader(PurchHeader, PurchHeader."Document Type"::Order, CreateVendor(''));
        PurchHeader.Validate("Sell-to Customer No.", SellToCustomerNo);
        PurchHeader.Modify(true);

        LibraryPurchase.GetDropShipment(PurchHeader);
    end;

    procedure CreateDropShipmentLine(var SalesLine: Record "Sales Line"; var SalesHeader: Record "Sales Header")
    var
        Purchasing: Record Purchasing;
        Item: Record Item;
    begin
        Item.Get(CreateItem());
        LibrarySales.CreateSalesLine(SalesLine, SalesHeader, SalesLine.Type::Item, Item."No.", LibraryRandom.RandDec(10, 2));
        LibraryPurchase.CreatePurchasingCode(Purchasing);
        Purchasing.Validate("Drop Shipment", true);
        Purchasing.Modify(true);
        SalesLine.Validate("Purchasing Code", Purchasing.Code);
        SalesLine.Modify(true);
    end;

    [EventSubscriber(ObjectType::Codeunit, Codeunit::IntrastatReportManagement, 'OnAfterCheckFeatureEnabled', '', true, true)]
    local procedure OnAfterCheckFeatureEnabled(var IsEnabled: Boolean)
    begin
        IsEnabled := true;
    end;
}