codeunit 137551 "Tax Document GL Posting Tests"
{
    Subtype = Test;
    TestPermissions = NonRestrictive;
    EventSubscriberInstance = Manual;
    trigger OnRun()
    begin
        // [FEATURE] [TaxEngine] [Tax Document GL Posting] [UT]
    end;

    var
        Assert: Codeunit Assert;

    [Test]
    procedure TestTransferTransactionValue()
    var
        SalesLine: Record "Sales Line";
        SalesHeader: Record "Sales Header";
        TaxTransactionValue: Record "Tax Transaction Value";
        TempTransactionValue: Record "Tax Transaction Value" temporary;
        LibraryTaxTypeTests: Codeunit "Library - Tax Type Tests";
        LibraryUseCaseTests: Codeunit "Library - Use Case Tests";
        TaxDocumentGLPosting: Codeunit "Tax Document GL Posting";
        FromRecID: RecordId;
        Type: Option Option,Text,Integer,Decimal,Boolean,Date;
        CaseID, TaxID, EmptyGuid : Guid;
        AttributeID, ComponentID : Integer;
    begin
        // [SCENARIO] To check system is transfering transaction value from one RecordID to another RecordID

        // [GIVEN] There should be record in transaction value table 
        SalesLine.SetRange("Document Type", SalesLine."Document Type"::Order);
        SalesLine.SetFilter("Qty. to Invoice", '<>%1', 0);
        SalesLine.FindFirst();
        FromRecID := SalesLine.RecordId();

        SalesHeader.get(SalesLine."Document Type", SalesLine."Document No.");

        CaseID := CreateGuid();
        TaxID := CreateGuid();
        LibraryTaxTypeTests.CreateTaxType('VAT', 'VAT');
        AttributeID := LibraryTaxTypeTests.CreateTaxAttribute('VAT', 'VATBusPostingGrp', Type::Text, Database::"Sales Header", SalesLine.FieldNo("VAT Bus. Posting Group"), 0, false);
        ComponentID := LibraryTaxTypeTests.CreateComponent('VAT', 'VAT', "Rounding Direction"::Nearest, 0.1, false);

        LibraryUseCaseTests.CreateUseCase('VAT', CaseID, Database::"Sales Line", 'Test Use Case', EmptyGuid);
        LibraryUseCaseTests.CreateTransactionValue(CaseID, AttributeID, "Transaction Value Type"::ATTRIBUTE, SalesLine."VAT Bus. Posting Group", 0, 0, SalesLine.RecordId, 'VAT');
        LibraryUseCaseTests.CreateTransactionValue(CaseID, ComponentID, "Transaction Value Type"::COMPONENT, '', 10000, 10, SalesLine.RecordId, 'VAT');

        // [WHEN] PrepareTransactionValueToPost function is called
        TaxDocumentGLPosting.PrepareTransactionValueToPost(
            SalesLine.RecordId,
            SalesLine.Quantity,
            SalesLine.Quantity,
            SalesHeader."Currency Code",
            SalesHeader."Currency Factor",
            TempTransactionValue);

        SalesLine.Next();

        TaxDocumentGLPosting.TransferTransactionValue(
            FromRecID,
            SalesLine.RecordId(),
            TempTransactionValue);

        // [THEN] it should create records in transaction value for new Sales Line record
        TaxTransactionValue.SetRange("Tax Record ID", SalesLine.RecordId());
        Assert.RecordIsNotEmpty(TaxTransactionValue);
    end;

    [Test]
    procedure TestGetAttributeColumNameForAttribute()
    var
        SalesLine: Record "Sales Line";
        TaxTransactionValue: Record "Tax Transaction Value";
        LibraryUseCaseTests: Codeunit "Library - Use Case Tests";
        LibraryTaxTypeTests: Codeunit "Library - Tax Type Tests";
        Type: Option Option,Text,Integer,Decimal,Boolean,Date;
        CaseID, EmptyGuid : Guid;
        AttributeID: Integer;
        ActualName: Text;
    begin
        // [SCENARIO] To check if GetAttributeColumnName return correct attribute name

        // [GIVEN] There should be record in transaction value table with value type attribute
        SalesLine.SetRange("Document Type", SalesLine."Document Type"::Order);
        SalesLine.SetFilter("Qty. to Invoice", '<>%1', 0);
        SalesLine.FindFirst();

        CaseID := CreateGuid();
        LibraryTaxTypeTests.CreateTaxType('VAT', 'VAT');
        AttributeID := LibraryTaxTypeTests.CreateTaxAttribute(
            'VAT',
            'VATBusPostingGrp',
            Type::Text,
            Database::"Sales Header",
            SalesLine.FieldNo("VAT Bus. Posting Group"),
            0,
            false);

        LibraryUseCaseTests.CreateUseCase('VAT', CaseID, Database::"Sales Line", 'Test Use Case', EmptyGuid);
        LibraryUseCaseTests.CreateTransactionValue(CaseID, AttributeID, "Transaction Value Type"::ATTRIBUTE, SalesLine."VAT Bus. Posting Group", 0, 0, SalesLine.RecordId, 'VAT');
        // [WHEN] GetAttributeColumnName function is called
        TaxTransactionValue.SetRange("Tax Record ID", SalesLine.RecordId());
        TaxTransactionValue.SetRange("Value Type", "Transaction Value Type"::ATTRIBUTE);
        TaxTransactionValue.SetRange("Value ID", AttributeID);
        TaxTransactionValue.FindFirst();
        ActualName := TaxTransactionValue.GetAttributeColumName();

        // [THEN] it should return the same name as Attribute created
        Assert.AreEqual('VATBusPostingGrp', ActualName, 'Attribute name should be VATBusPostingGrp');
    end;

    [Test]
    procedure TestGetAttributeColumNameForComponent()
    var
        SalesLine: Record "Sales Line";
        TaxTransactionValue: Record "Tax Transaction Value";
        LibraryUseCaseTests: Codeunit "Library - Use Case Tests";
        LibraryTaxTypeTests: Codeunit "Library - Tax Type Tests";
        CaseID, EmptyGuid : Guid;
        ComponentID: Integer;
        ActualName: Text;
    begin
        // [SCENARIO] To check if GetAttributeColumnName return correct Component name

        // [GIVEN] There should be record in transaction value table with value type attribute
        SalesLine.SetRange("Document Type", SalesLine."Document Type"::Order);
        SalesLine.SetFilter("Qty. to Invoice", '<>%1', 0);
        SalesLine.FindFirst();

        CaseID := CreateGuid();
        LibraryTaxTypeTests.CreateTaxType('VAT', 'VAT');
        ComponentID := LibraryTaxTypeTests.CreateComponent('VAT', 'VAT', "Rounding Direction"::Nearest, 0.1, false);

        LibraryUseCaseTests.CreateUseCase('VAT', CaseID, Database::"Sales Line", 'Test Use Case', EmptyGuid);
        LibraryUseCaseTests.CreateTransactionValue(CaseID, ComponentID, "Transaction Value Type"::COMPONENT, '', 10000, 10, SalesLine.RecordId, 'VAT');

        // [WHEN] GetAttributeColumnName function is called
        TaxTransactionValue.SetRange("Tax Record ID", SalesLine.RecordId());
        TaxTransactionValue.SetRange("Value Type", "Transaction Value Type"::COMPONENT);
        TaxTransactionValue.SetRange("Value ID", ComponentID);
        TaxTransactionValue.FindFirst();
        ActualName := TaxTransactionValue.GetAttributeColumName();

        // [THEN] it should return the same name as Component created
        Assert.AreEqual('VAT', ActualName, 'Component name should be VAT');
    end;

    [Test]
    procedure TestGetAttributeColumNameForColumn()
    var
        SalesLine: Record "Sales Line";
        TaxTransactionValue: Record "Tax Transaction Value";
        LibraryUseCaseTests: Codeunit "Library - Use Case Tests";
        LibraryTaxTypeTests: Codeunit "Library - Tax Type Tests";
        Type: Option Option,Text,Integer,Decimal,Boolean,Date;
        CaseID, EmptyGuid : Guid;
        ColumnID: Integer;
        ActualName: Text;
    begin
        // [SCENARIO] To check if GetAttributeColumnName return correct Component name

        // [GIVEN] There should be record in transaction value table with value type attribute
        SalesLine.SetRange("Document Type", SalesLine."Document Type"::Order);
        SalesLine.SetFilter("Qty. to Invoice", '<>%1', 0);
        SalesLine.FindFirst();

        CaseID := CreateGuid();
        LibraryTaxTypeTests.CreateTaxType('VAT', 'VAT');
        ColumnID := LibraryTaxTypeTests.CreateTaxRateColumnSetup('VAT', "Column Type"::"Range From", 0, 1, Type::Date, 0, 'Effective');

        LibraryUseCaseTests.CreateUseCase('VAT', CaseID, Database::"Sales Line", 'Test Use Case', EmptyGuid);
        LibraryUseCaseTests.CreateTransactionValue(CaseID, ColumnID, "Transaction Value Type"::COLUMN, '', 10000, 10, SalesLine.RecordId, 'VAT');

        // [WHEN] GetAttributeColumnName function is called
        TaxTransactionValue.SetRange("Tax Record ID", SalesLine.RecordId());
        TaxTransactionValue.SetRange("Value Type", "Transaction Value Type"::COLUMN);
        TaxTransactionValue.SetRange("Value ID", ColumnID);
        TaxTransactionValue.FindFirst();
        ActualName := TaxTransactionValue.GetAttributeColumName();

        // [THEN] it should return the same name as Component created
        Assert.AreEqual('Effective', ActualName, 'Component name should be VAT');
    end;

    [Test]
    procedure TestGetTransactionDatatypeforColumn()
    var
        SalesLine: Record "Sales Line";
        TaxTransactionValue: Record "Tax Transaction Value";
        LibraryUseCaseTests: Codeunit "Library - Use Case Tests";
        LibraryTaxTypeTests: Codeunit "Library - Tax Type Tests";
        Type: Option Option,Text,Integer,Decimal,Boolean,Date;
        CaseID, EmptyGuid : Guid;
        ColumnID: Integer;
        ActualDatatype, ExptectedDatatype : Enum "Symbol Data Type";
    begin
        // [SCENARIO] To check if GetTransactionDatatype returns correct datatype of the value type

        // [GIVEN] There should be record in transaction value table with value type attribute
        SalesLine.SetRange("Document Type", SalesLine."Document Type"::Order);
        SalesLine.SetFilter("Qty. to Invoice", '<>%1', 0);
        SalesLine.FindFirst();

        CaseID := CreateGuid();
        LibraryTaxTypeTests.CreateTaxType('VAT', 'VAT');
        ColumnID := LibraryTaxTypeTests.CreateTaxRateColumnSetup('VAT', "Column Type"::"Range From", 0, 1, Type::Date, 0, 'Effective');

        LibraryUseCaseTests.CreateUseCase('VAT', CaseID, Database::"Sales Line", 'Test Use Case', EmptyGuid);
        LibraryUseCaseTests.CreateTransactionValue(CaseID, ColumnID, "Transaction Value Type"::COLUMN, '', 10000, 10, SalesLine.RecordId, 'VAT');

        // [WHEN] GetTransactionDataType function is called
        TaxTransactionValue.SetRange("Tax Record ID", SalesLine.RecordId());
        TaxTransactionValue.SetRange("Value Type", "Transaction Value Type"::COLUMN);
        TaxTransactionValue.SetRange("Value ID", ColumnID);
        TaxTransactionValue.FindFirst();
        ActualDatatype := TaxTransactionValue.GetTransactionDataType();

        // [THEN] it should return the same datatype
        ExptectedDatatype := ExptectedDatatype::Date;
        Assert.AreEqual(ExptectedDatatype, ActualDatatype, 'datatype should be date');
    end;

    [Test]
    procedure TestGetTransactionDatatypeforAttribute()
    var
        SalesLine: Record "Sales Line";
        TaxTransactionValue: Record "Tax Transaction Value";
        LibraryUseCaseTests: Codeunit "Library - Use Case Tests";
        LibraryTaxTypeTests: Codeunit "Library - Tax Type Tests";
        Type: Option Option,Text,Integer,Decimal,Boolean,Date;
        CaseID, EmptyGuid : Guid;
        AttributeID: Integer;
        ActualDatatype, ExptectedDatatype : Enum "Symbol Data Type";
    begin
        // [SCENARIO] To check if GetTransactionDatatype returns correct datatype of the value type

        // [GIVEN] There should be record in transaction value table with value type attribute
        SalesLine.SetRange("Document Type", SalesLine."Document Type"::Order);
        SalesLine.SetFilter("Qty. to Invoice", '<>%1', 0);
        SalesLine.FindFirst();

        CaseID := CreateGuid();
        LibraryTaxTypeTests.CreateTaxType('VAT', 'VAT');
        AttributeID := LibraryTaxTypeTests.CreateTaxAttribute(
            'VAT',
            'VATBusPostingGrp',
            Type::Text,
            Database::"Sales Header",
            SalesLine.FieldNo("VAT Bus. Posting Group"),
            0,
            false);

        LibraryUseCaseTests.CreateUseCase('VAT', CaseID, Database::"Sales Line", 'Test Use Case', EmptyGuid);
        LibraryUseCaseTests.CreateTransactionValue(CaseID, AttributeID, "Transaction Value Type"::ATTRIBUTE, SalesLine."VAT Bus. Posting Group", 0, 0, SalesLine.RecordId, 'VAT');

        // [WHEN] GetTransactionDataType function is called
        TaxTransactionValue.SetRange("Tax Record ID", SalesLine.RecordId());
        TaxTransactionValue.SetRange("Value Type", "Transaction Value Type"::ATTRIBUTE);
        TaxTransactionValue.SetRange("Value ID", AttributeID);
        TaxTransactionValue.FindFirst();
        ActualDatatype := TaxTransactionValue.GetTransactionDataType();

        // [THEN] it should return the same datatype
        ExptectedDatatype := ExptectedDatatype::String;
        Assert.AreEqual(ExptectedDatatype, ActualDatatype, 'datatype should be string');
    end;

    [Test]
    procedure TestGetTransactionRecordID()
    var
        SalesLine: Record "Sales Line";
        SalesInvoiceLine: Record "Sales Invoice Line";
        SalesCrMemoLine: Record "Sales Cr.Memo Line";
        PurchLine: Record "Purchase Line";
        PurchInvLine: Record "Purch. Inv. Line";
        PurchCrMemoLine: Record "Purch. Cr. Memo Line";
        TransferLine: Record "Transfer Line";
        TransferShptLine: Record "Transfer Shipment Line";
        TransferRcptLine: Record "Transfer Receipt Line";
        GenJnlLine: Record "Gen. Journal Line";
        GenJournalBatch: Record "Gen. Journal Batch";
        TaxTransactionValue: Record "Tax Transaction Value";
        LibraryJournals: Codeunit "Library - Journals";
        LibraryUseCaseTests: Codeunit "Library - Use Case Tests";
        LibraryTaxTypeTests: Codeunit "Library - Tax Type Tests";
        SalesRecId, PurchRecId, TransferRecId, JournalRecId : RecordId;
        SalesInvRecId, SalesCrRecId, PurchInvRecId, PurchCrRecId, TransferShptRecId, TransferRcptRecId : RecordId;
        Type: Option Option,Text,Integer,Decimal,Boolean,Date;
        SalesCaseID, PurchCaseID, TransferCaseID, JournalCaseID, EmptyGuid : Guid;
        AttributeID: Integer;
    begin
        // [SCENARIO] To check if GetTaxRecordID returns correct recordID

        // [GIVEN] There should be record in transaction value table with records of Sales, Purchase , transfer and Journal
        SalesLine.SetRange("Document Type", SalesLine."Document Type"::Order);
        SalesLine.SetFilter("Qty. to Invoice", '<>%1', 0);
        SalesLine.FindFirst();

        SalesInvoiceLine.SetFilter("No.", '<>%1', '');
        SalesInvoiceLine.FindFirst();

        SalesCrMemoLine.SetFilter("No.", '<>%1', '');
        SalesCrMemoLine.FindFirst();

        PurchLine.SetRange("Document Type", PurchLine."Document Type"::Order);
        PurchLine.SetFilter("Qty. to Invoice", '<>%1', 0);
        PurchLine.FindFirst();

        PurchInvLine.SetFilter("No.", '<>%1', '');
        PurchInvLine.FindFirst();

        PurchCrMemoLine.SetFilter("No.", '<>%1', '');
        PurchCrMemoLine.FindFirst();

        TransferLine.SetFilter("Qty. to Receive", '<>%1', 0);
        TransferLine.FindFirst();

        TransferShptLine.SetFilter("Item No.", '<>%1', '');
        TransferShptLine.FindFirst();

        TransferRcptLine.SetFilter("Item No.", '<>%1', '');
        TransferRcptLine.FindFirst();

        LibraryJournals.CreateGenJournalBatch(GenJournalBatch);
        LibraryJournals.CreateGenJournalLineWithBatch(GenJnlLine, "Gen. Journal Document Type"::Payment, "Gen. Journal Account Type"::Customer, '', 0);

        SalesCaseID := CreateGuid();
        LibraryTaxTypeTests.CreateTaxType('VAT', 'VAT');
        AttributeID := LibraryTaxTypeTests.CreateTaxAttribute(
            'VAT',
            'VATBusPostingGrp',
            Type::Text,
            Database::"Sales Header",
            SalesLine.FieldNo("VAT Bus. Posting Group"),
            0,
            false);

        LibraryUseCaseTests.CreateUseCase('VAT', SalesCaseID, Database::"Sales Line", 'Test Use Case', EmptyGuid);
        LibraryUseCaseTests.CreateUseCase('VAT', PurchCaseID, Database::"Purchase Line", 'Test Use Case', EmptyGuid);
        LibraryUseCaseTests.CreateUseCase('VAT', TransferCaseID, Database::"Transfer Line", 'Test Use Case', EmptyGuid);
        LibraryUseCaseTests.CreateUseCase('VAT', TransferCaseID, Database::"Gen. Journal Line", 'Test Use Case', EmptyGuid);
        LibraryUseCaseTests.CreateTransactionValue(SalesCaseID, AttributeID, "Transaction Value Type"::ATTRIBUTE, SalesLine."VAT Bus. Posting Group", 0, 0, SalesLine.RecordId, 'VAT');
        LibraryUseCaseTests.CreateTransactionValue(SalesCaseID, AttributeID, "Transaction Value Type"::ATTRIBUTE, SalesLine."VAT Bus. Posting Group", 0, 0, SalesInvoiceLine.RecordId, 'VAT');
        LibraryUseCaseTests.CreateTransactionValue(SalesCaseID, AttributeID, "Transaction Value Type"::ATTRIBUTE, SalesLine."VAT Bus. Posting Group", 0, 0, SalesCrMemoLine.RecordId, 'VAT');
        LibraryUseCaseTests.CreateTransactionValue(PurchCaseID, AttributeID, "Transaction Value Type"::ATTRIBUTE, PurchLine."VAT Bus. Posting Group", 0, 0, PurchLine.RecordId, 'VAT');
        LibraryUseCaseTests.CreateTransactionValue(PurchCaseID, AttributeID, "Transaction Value Type"::ATTRIBUTE, PurchLine."VAT Bus. Posting Group", 0, 0, PurchInvLine.RecordId, 'VAT');
        LibraryUseCaseTests.CreateTransactionValue(PurchCaseID, AttributeID, "Transaction Value Type"::ATTRIBUTE, PurchLine."VAT Bus. Posting Group", 0, 0, PurchCrMemoLine.RecordId, 'VAT');
        LibraryUseCaseTests.CreateTransactionValue(TransferCaseID, AttributeID, "Transaction Value Type"::ATTRIBUTE, '', 0, 0, TransferLine.RecordId, 'VAT');
        LibraryUseCaseTests.CreateTransactionValue(TransferCaseID, AttributeID, "Transaction Value Type"::ATTRIBUTE, '', 0, 0, TransferShptLine.RecordId, 'VAT');
        LibraryUseCaseTests.CreateTransactionValue(TransferCaseID, AttributeID, "Transaction Value Type"::ATTRIBUTE, '', 0, 0, TransferRcptLine.RecordId, 'VAT');
        LibraryUseCaseTests.CreateTransactionValue(JournalCaseID, AttributeID, "Transaction Value Type"::ATTRIBUTE, '', 0, 0, GenJnlLine.RecordId(), 'VAT');


        // [WHEN] GetRecordID function is called
        TaxTransactionValue.FilterGroup(4);
        TaxTransactionValue.SetFilter("Table ID Filter", '%1', Database::"Sales Line");
        TaxTransactionValue.SetFilter("Document Type Filter", '%1', SalesLine."Document Type".AsInteger());
        TaxTransactionValue.SetFilter("Document No. Filter", '%1', SalesLine."Document No.");
        TaxTransactionValue.SetFilter("Line No. Filter", '%1', SalesLine."Line No.");
        TaxTransactionValue.GetRecordID(SalesRecId);

        TaxTransactionValue.Reset();
        TaxTransactionValue.FilterGroup(4);
        TaxTransactionValue.SetFilter("Table ID Filter", '%1', Database::"Sales Invoice Line");
        TaxTransactionValue.SetFilter("Document No. Filter", '%1', SalesInvoiceLine."Document No.");
        TaxTransactionValue.SetFilter("Line No. Filter", '%1', SalesInvoiceLine."Line No.");
        TaxTransactionValue.GetRecordID(SalesInvRecId);

        TaxTransactionValue.Reset();
        TaxTransactionValue.FilterGroup(4);
        TaxTransactionValue.SetFilter("Table ID Filter", '%1', Database::"Sales Cr.Memo Line");
        TaxTransactionValue.SetFilter("Document No. Filter", '%1', SalesCrMemoLine."Document No.");
        TaxTransactionValue.SetFilter("Line No. Filter", '%1', SalesCrMemoLine."Line No.");
        TaxTransactionValue.GetRecordID(SalesCrRecId);

        TaxTransactionValue.Reset();
        TaxTransactionValue.FilterGroup(4);
        TaxTransactionValue.SetFilter("Table ID Filter", '%1', Database::"Purchase Line");
        TaxTransactionValue.SetFilter("Document Type Filter", '%1', PurchLine."Document Type".AsInteger());
        TaxTransactionValue.SetFilter("Document No. Filter", '%1', PurchLine."Document No.");
        TaxTransactionValue.SetFilter("Line No. Filter", '%1', PurchLine."Line No.");
        TaxTransactionValue.GetRecordID(PurchRecId);

        TaxTransactionValue.Reset();
        TaxTransactionValue.FilterGroup(4);
        TaxTransactionValue.SetFilter("Table ID Filter", '%1', Database::"Purch. Inv. Line");
        TaxTransactionValue.SetFilter("Document No. Filter", '%1', PurchInvLine."Document No.");
        TaxTransactionValue.SetFilter("Line No. Filter", '%1', PurchInvLine."Line No.");
        TaxTransactionValue.GetRecordID(PurchInvRecId);

        TaxTransactionValue.Reset();
        TaxTransactionValue.FilterGroup(4);
        TaxTransactionValue.SetFilter("Table ID Filter", '%1', Database::"Purch. Cr. Memo Line");
        TaxTransactionValue.SetFilter("Document No. Filter", '%1', PurchCrMemoLine."Document No.");
        TaxTransactionValue.SetFilter("Line No. Filter", '%1', PurchCrMemoLine."Line No.");
        TaxTransactionValue.GetRecordID(PurchCrRecId);

        TaxTransactionValue.Reset();
        TaxTransactionValue.FilterGroup(4);
        TaxTransactionValue.SetFilter("Table ID Filter", '%1', Database::"Transfer Line");
        TaxTransactionValue.SetFilter("Document No. Filter", '%1', TransferLine."Document No.");
        TaxTransactionValue.SetFilter("Line No. Filter", '%1', TransferLine."Line No.");
        TaxTransactionValue.GetRecordID(TransferRecId);

        TaxTransactionValue.Reset();
        TaxTransactionValue.FilterGroup(4);
        TaxTransactionValue.SetFilter("Table ID Filter", '%1', Database::"Transfer Shipment Line");
        TaxTransactionValue.SetFilter("Document No. Filter", '%1', TransferShptLine."Document No.");
        TaxTransactionValue.SetFilter("Line No. Filter", '%1', TransferShptLine."Line No.");
        TaxTransactionValue.GetRecordID(TransferShptRecId);

        TaxTransactionValue.Reset();
        TaxTransactionValue.FilterGroup(4);
        TaxTransactionValue.SetFilter("Table ID Filter", '%1', Database::"Transfer Receipt Line");
        TaxTransactionValue.SetFilter("Document No. Filter", '%1', TransferRcptLine."Document No.");
        TaxTransactionValue.SetFilter("Line No. Filter", '%1', TransferRcptLine."Line No.");
        TaxTransactionValue.GetRecordID(TransferRcptRecId);

        TaxTransactionValue.Reset();
        TaxTransactionValue.FilterGroup(4);
        TaxTransactionValue.SetFilter("Table ID Filter", '%1', Database::"Gen. Journal Line");
        TaxTransactionValue.SetFilter("Template Name Filter", '%1', GenJnlLine."Journal Template Name");
        TaxTransactionValue.SetFilter("Batch Name Filter", '%1', GenJnlLine."Journal Batch Name");
        TaxTransactionValue.SetFilter("Document No. Filter", '%1', GenJnlLine."Document No.");
        TaxTransactionValue.SetFilter("Line No. Filter", '%1', GenJnlLine."Line No.");
        TaxTransactionValue.GetRecordID(JournalRecId);

        // [THEN] it should return the same recordid's for Sales, Purchase, Transfer and Journal
        Assert.AreEqual(SalesLine.RecordId(), SalesRecId, 'Sales recordid should be same');
        Assert.AreEqual(SalesInvoiceLine.RecordId(), SalesInvRecId, 'Sales Invoice recordid should be same');
        Assert.AreEqual(SalesCrMemoLine.RecordId(), SalesCrRecId, 'Sales Cr. Memo recordid should be same');
        Assert.AreEqual(PurchLine.RecordId(), PurchRecId, 'Purchase recordid should be same');
        Assert.AreEqual(PurchInvLine.RecordId(), PurchInvRecId, 'Purch. Invoice recordid should be same');
        Assert.AreEqual(PurchCrMemoLine.RecordId(), PurchCrRecId, 'Purch. Cr. Memo recordid should be same');
        Assert.AreEqual(TransferLine.RecordId(), TransferRecId, 'Transfer recordid should be same');
        Assert.AreEqual(TransferShptLine.RecordId(), TransferShptRecId, 'Transfer Shipment recordid should be same');
        Assert.AreEqual(TransferRcptLine.RecordId(), TransferRcptRecId, 'Transfer Receipt recordid should be same');
        Assert.AreEqual(GenJnlLine.RecordId(), JournalRecId, 'Journal Line recordid should be same');
    end;

    [Test]
    procedure TestGetTransactionDocument()
    var
        GenJnlLine: Record "Gen. Journal Line";
        GenJnlLine2: Record "Gen. Journal Line";
        GenJournalBatch: Record "Gen. Journal Batch";
        LibraryJournals: Codeunit "Library - Journals";
        LibraryUseCaseTests: Codeunit "Library - Use Case Tests";
        LibraryTaxTypeTests: Codeunit "Library - Tax Type Tests";
        TaxPostingBufferMgmt: Codeunit "Tax Posting Buffer Mgmt.";
        GenJnlPostLine: Codeunit "Gen. Jnl.-Post Line";
        TaxDocumentGLPostingTests: Codeunit "Tax Document GL Posting Tests";
        Record: Variant;
        JournalCaseID, EmptyGuid : Guid;
        Type: Option Option,Text,Integer,Decimal,Boolean,Date;
        AttributeID: Integer;
    begin
        // [SCENARIO] To check if GetTaxRecordID returns correct recordID

        // [GIVEN] There should be record in transaction value table with records of Sales, Purchase , transfer and Journal
        LibraryJournals.CreateGenJournalBatch(GenJournalBatch);
        LibraryJournals.CreateGenJournalLineWithBatch(GenJnlLine, "Gen. Journal Document Type"::Payment, "Gen. Journal Account Type"::Customer, '', 0);

        LibraryTaxTypeTests.CreateTaxType('VAT', 'VAT');
        AttributeID := LibraryTaxTypeTests.CreateTaxAttribute(
            'VAT',
            'VATBusPostingGrp',
            Type::Text,
            Database::"Gen. Journal Line",
            GenJnlLine.FieldNo("VAT Bus. Posting Group"),
            0,
            false);

        LibraryUseCaseTests.CreateUseCase('VAT', JournalCaseID, Database::"Gen. Journal Line", 'Test Use Case', EmptyGuid);
        LibraryUseCaseTests.CreateTransactionValue(JournalCaseID, AttributeID, "Transaction Value Type"::ATTRIBUTE, '', 0, 0, GenJnlLine.RecordId(), 'VAT');

        // [WHEN] GetRecordID function is called
        BindSubscription(TaxDocumentGLPostingTests);
        GenJnlPostLine.RunWithCheck(GenJnlLine);
        UnBindSubscription(TaxDocumentGLPostingTests);
        // [THEN] it should return the same recordid's for Sales, Purchase, Transfer and Journal
        TaxPostingBufferMgmt.GetDocument(Record);
        GenJnlLine2 := Record;
        Assert.AreEqual(GenJnlLine.RecordId(), GenJnlLine2.RecordId(), 'Record should be of Gen. Journal Line');
    end;

    [EventSubscriber(ObjectType::Codeunit, Codeunit::"Gen. Jnl.-Post Line", 'OnBeforeCode', '', false, false)]
    local procedure OnBeforeCode(var IsPosted: Boolean)
    begin
        IsPosted := true;
    end;
}