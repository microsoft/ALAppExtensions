codeunit 13852 "OIOUBL Structured Validations"
{
    var
        Assert: Codeunit Assert;
        UnitOfMeasureCodeTok: Label 'PCS', Locked = true;
        SalesInvoiceNoTok: Label '103033', Locked = true;
        PurchaseorderNoTok: Label '2', Locked = true;
        MockDate: Date;
        MockCurrencyCode: Code[10];
        MockDataMismatchErr: Label 'The %1 in %2 does not align with the mock data. Expected: %3, Actual: %4', Locked = true, Comment = '%1 = Field caption, %2 = Table caption, %3 = Expected value, %4 = Actual value';


    internal procedure AssertFullEDocumentContentExtracted(EDocumentEntryNo: Integer)
    var
        EDocumentPurchaseHeader: Record "E-Document Purchase Header";
        EDocumentPurchaseLine: Record "E-Document Purchase Line";
    begin
        EDocumentPurchaseHeader.Get(EDocumentEntryNo);
        Assert.AreEqual(SalesInvoiceNoTok, EDocumentPurchaseHeader."Sales Invoice No.", StrSubstNo(MockDataMismatchErr, EDocumentPurchaseHeader.FieldCaption("Sales Invoice No."), EDocumentPurchaseHeader.TableCaption(), SalesInvoiceNoTok, EDocumentPurchaseHeader."Sales Invoice No."));
        Assert.AreEqual(MockDate, EDocumentPurchaseHeader."Document Date", StrSubstNo(MockDataMismatchErr, EDocumentPurchaseHeader.FieldCaption("Document Date"), EDocumentPurchaseHeader.TableCaption(), MockDate, EDocumentPurchaseHeader."Document Date"));
        Assert.AreEqual(CalcDate('<+1M>', MockDate), EDocumentPurchaseHeader."Due Date", StrSubstNo(MockDataMismatchErr, EDocumentPurchaseHeader.FieldCaption("Due Date"), EDocumentPurchaseHeader.TableCaption(), CalcDate('<+1M>', MockDate), EDocumentPurchaseHeader."Due Date"));
        Assert.AreEqual(MockCurrencyCode, EDocumentPurchaseHeader."Currency Code", StrSubstNo(MockDataMismatchErr, EDocumentPurchaseHeader.FieldCaption("Currency Code"), EDocumentPurchaseHeader.TableCaption(), MockCurrencyCode, EDocumentPurchaseHeader."Currency Code"));
        Assert.AreEqual(PurchaseorderNoTok, EDocumentPurchaseHeader."Purchase Order No.", StrSubstNo(MockDataMismatchErr, EDocumentPurchaseHeader.FieldCaption("Purchase Order No."), EDocumentPurchaseHeader.TableCaption(), PurchaseorderNoTok, EDocumentPurchaseHeader."Purchase Order No."));
        Assert.AreEqual('CRONUS International', EDocumentPurchaseHeader."Vendor Company Name", StrSubstNo(MockDataMismatchErr, EDocumentPurchaseHeader.FieldCaption("Vendor Company Name"), EDocumentPurchaseHeader.TableCaption(), 'CRONUS International', EDocumentPurchaseHeader."Vendor Company Name"));
        Assert.AreEqual('Main Street, 14', EDocumentPurchaseHeader."Vendor Address", StrSubstNo(MockDataMismatchErr, EDocumentPurchaseHeader.FieldCaption("Vendor Address"), EDocumentPurchaseHeader.TableCaption(), 'Main Street, 14', EDocumentPurchaseHeader."Vendor Address"));
        Assert.AreEqual('GB123456789', EDocumentPurchaseHeader."Vendor VAT Id", StrSubstNo(MockDataMismatchErr, EDocumentPurchaseHeader.FieldCaption("Vendor VAT Id"), EDocumentPurchaseHeader.TableCaption(), 'GB123456789', EDocumentPurchaseHeader."Vendor VAT Id"));
        Assert.AreEqual('Jim Olive', EDocumentPurchaseHeader."Vendor Contact Name", StrSubstNo(MockDataMismatchErr, EDocumentPurchaseHeader.FieldCaption("Vendor Contact Name"), EDocumentPurchaseHeader.TableCaption(), 'Jim Olive', EDocumentPurchaseHeader."Vendor Contact Name"));
        Assert.AreEqual('The Cannon Group PLC', EDocumentPurchaseHeader."Customer Company Name", StrSubstNo(MockDataMismatchErr, EDocumentPurchaseHeader.FieldCaption("Customer Company Name"), EDocumentPurchaseHeader.TableCaption(), 'The Cannon Group PLC', EDocumentPurchaseHeader."Customer Company Name"));
        Assert.AreEqual('GB789456278', EDocumentPurchaseHeader."Customer VAT Id", StrSubstNo(MockDataMismatchErr, EDocumentPurchaseHeader.FieldCaption("Customer VAT Id"), EDocumentPurchaseHeader.TableCaption(), 'GB789456278', EDocumentPurchaseHeader."Customer VAT Id"));
        Assert.AreEqual('192 Market Square', EDocumentPurchaseHeader."Customer Address", StrSubstNo(MockDataMismatchErr, EDocumentPurchaseHeader.FieldCaption("Customer Address"), EDocumentPurchaseHeader.TableCaption(), '192 Market Square', EDocumentPurchaseHeader."Customer Address"));

        EDocumentPurchaseLine.SetRange("E-Document Entry No.", EDocumentEntryNo);
        EDocumentPurchaseLine.FindSet();
        Assert.AreEqual(1, EDocumentPurchaseLine."Quantity", StrSubstNo(MockDataMismatchErr, EDocumentPurchaseLine.FieldCaption("Quantity"), EDocumentPurchaseLine.TableCaption(), 1, EDocumentPurchaseLine."Quantity"));
        Assert.AreEqual(UnitOfMeasureCodeTok, EDocumentPurchaseLine."Unit of Measure", StrSubstNo(MockDataMismatchErr, EDocumentPurchaseLine.FieldCaption("Unit of Measure"), EDocumentPurchaseLine.TableCaption(), UnitOfMeasureCodeTok, EDocumentPurchaseLine."Unit of Measure"));
        Assert.AreEqual(4000, EDocumentPurchaseLine."Sub Total", StrSubstNo(MockDataMismatchErr, EDocumentPurchaseLine.FieldCaption("Sub Total"), EDocumentPurchaseLine.TableCaption(), 4000, EDocumentPurchaseLine."Sub Total"));
        Assert.AreEqual(MockCurrencyCode, EDocumentPurchaseLine."Currency Code", StrSubstNo(MockDataMismatchErr, EDocumentPurchaseLine.FieldCaption("Currency Code"), EDocumentPurchaseLine.TableCaption(), MockCurrencyCode, EDocumentPurchaseLine."Currency Code"));
        Assert.AreEqual(0, EDocumentPurchaseLine."Total Discount", StrSubstNo(MockDataMismatchErr, EDocumentPurchaseLine.FieldCaption("Total Discount"), EDocumentPurchaseLine.TableCaption(), 0, EDocumentPurchaseLine."Total Discount"));
        Assert.AreEqual('Bicycle', EDocumentPurchaseLine.Description, StrSubstNo(MockDataMismatchErr, EDocumentPurchaseLine.FieldCaption(Description), EDocumentPurchaseLine.TableCaption(), 'Bicycle', EDocumentPurchaseLine.Description));
        Assert.AreEqual('1000', EDocumentPurchaseLine."Product Code", StrSubstNo(MockDataMismatchErr, EDocumentPurchaseLine.FieldCaption("Product Code"), EDocumentPurchaseLine.TableCaption(), '1000', EDocumentPurchaseLine."Product Code"));
        Assert.AreEqual(25, EDocumentPurchaseLine."VAT Rate", StrSubstNo(MockDataMismatchErr, EDocumentPurchaseLine.FieldCaption("VAT Rate"), EDocumentPurchaseLine.TableCaption(), 25, EDocumentPurchaseLine."VAT Rate"));
        Assert.AreEqual(4000, EDocumentPurchaseLine."Unit Price", StrSubstNo(MockDataMismatchErr, EDocumentPurchaseLine.FieldCaption("Unit Price"), EDocumentPurchaseLine.TableCaption(), 4000, EDocumentPurchaseLine."Unit Price"));

        EDocumentPurchaseLine.Next();
        Assert.AreEqual(2, EDocumentPurchaseLine."Quantity", StrSubstNo(MockDataMismatchErr, EDocumentPurchaseLine.FieldCaption("Quantity"), EDocumentPurchaseLine.TableCaption(), 2, EDocumentPurchaseLine."Quantity"));
        Assert.AreEqual(UnitOfMeasureCodeTok, EDocumentPurchaseLine."Unit of Measure", StrSubstNo(MockDataMismatchErr, EDocumentPurchaseLine.FieldCaption("Unit of Measure"), EDocumentPurchaseLine.TableCaption(), UnitOfMeasureCodeTok, EDocumentPurchaseLine."Unit of Measure"));
        Assert.AreEqual(10000, EDocumentPurchaseLine."Sub Total", StrSubstNo(MockDataMismatchErr, EDocumentPurchaseLine.FieldCaption("Sub Total"), EDocumentPurchaseLine.TableCaption(), 10000, EDocumentPurchaseLine."Sub Total"));
        Assert.AreEqual(MockCurrencyCode, EDocumentPurchaseLine."Currency Code", StrSubstNo(MockDataMismatchErr, EDocumentPurchaseLine.FieldCaption("Currency Code"), EDocumentPurchaseLine.TableCaption(), MockCurrencyCode, EDocumentPurchaseLine."Currency Code"));
        Assert.AreEqual(0, EDocumentPurchaseLine."Total Discount", StrSubstNo(MockDataMismatchErr, EDocumentPurchaseLine.FieldCaption("Total Discount"), EDocumentPurchaseLine.TableCaption(), 0, EDocumentPurchaseLine."Total Discount"));
        Assert.AreEqual('Bicycle v2', EDocumentPurchaseLine.Description, StrSubstNo(MockDataMismatchErr, EDocumentPurchaseLine.FieldCaption(Description), EDocumentPurchaseLine.TableCaption(), 'Bicycle v2', EDocumentPurchaseLine.Description));
        Assert.AreEqual('2000', EDocumentPurchaseLine."Product Code", StrSubstNo(MockDataMismatchErr, EDocumentPurchaseLine.FieldCaption("Product Code"), EDocumentPurchaseLine.TableCaption(), '2000', EDocumentPurchaseLine."Product Code"));
        Assert.AreEqual(25, EDocumentPurchaseLine."VAT Rate", StrSubstNo(MockDataMismatchErr, EDocumentPurchaseLine.FieldCaption("VAT Rate"), EDocumentPurchaseLine.TableCaption(), 25, EDocumentPurchaseLine."VAT Rate"));
        Assert.AreEqual(5000, EDocumentPurchaseLine."Unit Price", StrSubstNo(MockDataMismatchErr, EDocumentPurchaseLine.FieldCaption("Unit Price"), EDocumentPurchaseLine.TableCaption(), 5000, EDocumentPurchaseLine."Unit Price"));
    end;

    internal procedure AssertPurchaseDocument(VendorNo: Code[20]; PurchaseHeader: Record "Purchase Header"; Item: Record Item)
    var
        PurchaseLine: Record "Purchase Line";
        Item1NoTok: Label 'GL00000001', Locked = true;
        Item2NoTok: Label 'GL00000003', Locked = true;
    begin
        Assert.AreEqual(SalesInvoiceNoTok, PurchaseHeader."Vendor Invoice No.", StrSubstNo(MockDataMismatchErr, PurchaseHeader.FieldCaption("Vendor Invoice No."), PurchaseHeader.TableCaption(), SalesInvoiceNoTok, PurchaseHeader."Vendor Invoice No."));
        Assert.AreEqual(MockDate, PurchaseHeader."Document Date", StrSubstNo(MockDataMismatchErr, PurchaseHeader.FieldCaption("Document Date"), PurchaseHeader.TableCaption(), MockDate, PurchaseHeader."Document Date"));
        Assert.AreEqual(CalcDate('<+1M>', MockDate), PurchaseHeader."Due Date", StrSubstNo(MockDataMismatchErr, PurchaseHeader.FieldCaption("Due Date"), PurchaseHeader.TableCaption(), CalcDate('<+1M>', MockDate), PurchaseHeader."Due Date"));
        Assert.AreEqual(MockCurrencyCode, PurchaseHeader."Currency Code", StrSubstNo(MockDataMismatchErr, PurchaseHeader.FieldCaption("Currency Code"), PurchaseHeader.TableCaption(), MockCurrencyCode, PurchaseHeader."Currency Code"));
        Assert.AreEqual(PurchaseorderNoTok, PurchaseHeader."Vendor Order No.", StrSubstNo(MockDataMismatchErr, PurchaseHeader.FieldCaption("Vendor Order No."), PurchaseHeader.TableCaption(), PurchaseorderNoTok, PurchaseHeader."Vendor Order No."));
        Assert.AreEqual(VendorNo, PurchaseHeader."Buy-from Vendor No.", StrSubstNo(MockDataMismatchErr, PurchaseHeader.FieldCaption("Buy-from Vendor No."), PurchaseHeader.TableCaption(), VendorNo, PurchaseHeader."Buy-from Vendor No."));

        PurchaseLine.SetRange("Document Type", PurchaseHeader."Document Type");
        PurchaseLine.SetRange("Document No.", PurchaseHeader."No.");
        PurchaseLine.FindSet();
        Assert.AreEqual(1, PurchaseLine.Quantity, StrSubstNo(MockDataMismatchErr, PurchaseLine.FieldCaption(Quantity), PurchaseLine.TableCaption(), 1, PurchaseLine.Quantity));
        Assert.AreEqual(4000, PurchaseLine."Direct Unit Cost", StrSubstNo(MockDataMismatchErr, PurchaseLine.FieldCaption("Direct Unit Cost"), PurchaseLine.TableCaption(), 4000, PurchaseLine."Direct Unit Cost"));
        Assert.AreEqual(MockCurrencyCode, PurchaseLine."Currency Code", StrSubstNo(MockDataMismatchErr, PurchaseLine.FieldCaption("Currency Code"), PurchaseLine.TableCaption(), MockCurrencyCode, PurchaseLine."Currency Code"));
        Assert.AreEqual(0, PurchaseLine."Line Discount Amount", StrSubstNo(MockDataMismatchErr, PurchaseLine.FieldCaption("Line Discount Amount"), PurchaseLine.TableCaption(), 0, PurchaseLine."Line Discount Amount"));
        // In the import file we have a name 'Bicycle' but because of Item Cross Reference validation Item description is being used
        if Item."No." <> '' then begin
            Assert.AreEqual('Bicycle', PurchaseLine.Description, StrSubstNo(MockDataMismatchErr, PurchaseLine.FieldCaption(Description), PurchaseLine.TableCaption(), Item."No.", PurchaseLine.Description));
            Assert.AreEqual(Item."No.", PurchaseLine."No.", StrSubstNo(MockDataMismatchErr, PurchaseLine.FieldCaption("No."), PurchaseLine.TableCaption(), Item."No.", PurchaseLine."No."));
            Assert.AreEqual(Item."Purch. Unit of Measure", PurchaseLine."Unit of Measure Code", StrSubstNo(MockDataMismatchErr, PurchaseLine.FieldCaption("Unit of Measure Code"), PurchaseLine.TableCaption(), UnitOfMeasureCodeTok, PurchaseLine."Unit of Measure Code"));
        end else begin
            Assert.AreEqual(Item1NoTok, PurchaseLine.Description, StrSubstNo(MockDataMismatchErr, PurchaseLine.FieldCaption(Description), PurchaseLine.TableCaption(), Item1NoTok, PurchaseLine.Description));
            Assert.AreEqual(Item1NoTok, PurchaseLine."No.", StrSubstNo(MockDataMismatchErr, PurchaseLine.FieldCaption("No."), PurchaseLine.TableCaption(), Item1NoTok, PurchaseLine."No."));
            Assert.AreEqual(UnitOfMeasureCodeTok, PurchaseLine."Unit of Measure Code", StrSubstNo(MockDataMismatchErr, PurchaseLine.FieldCaption("Unit of Measure Code"), PurchaseLine.TableCaption(), UnitOfMeasureCodeTok, PurchaseLine."Unit of Measure Code"));
        end;

        PurchaseLine.Next();
        Assert.AreEqual(2, PurchaseLine.Quantity, StrSubstNo(MockDataMismatchErr, PurchaseLine.FieldCaption(Quantity), PurchaseLine.TableCaption(), 2, PurchaseLine.Quantity));
        Assert.AreEqual(UnitOfMeasureCodeTok, PurchaseLine."Unit of Measure Code", StrSubstNo(MockDataMismatchErr, PurchaseLine.FieldCaption("Unit of Measure Code"), PurchaseLine.TableCaption(), UnitOfMeasureCodeTok, PurchaseLine."Unit of Measure Code"));
        Assert.AreEqual(5000, PurchaseLine."Direct Unit Cost", StrSubstNo(MockDataMismatchErr, PurchaseLine.FieldCaption("Direct Unit Cost"), PurchaseLine.TableCaption(), 5000, PurchaseLine."Direct Unit Cost"));
        Assert.AreEqual(MockCurrencyCode, PurchaseLine."Currency Code", StrSubstNo(MockDataMismatchErr, PurchaseLine.FieldCaption("Currency Code"), PurchaseLine.TableCaption(), MockCurrencyCode, PurchaseLine."Currency Code"));
        Assert.AreEqual(0, PurchaseLine."Line Discount Amount", StrSubstNo(MockDataMismatchErr, PurchaseLine.FieldCaption("Line Discount Amount"), PurchaseLine.TableCaption(), 0, PurchaseLine."Line Discount Amount"));
        // In the import file we have a name 'Bicycle v2' but because of Item Cross Reference validation Item description is being used
        Assert.AreEqual(Item2NoTok, PurchaseLine.Description, StrSubstNo(MockDataMismatchErr, PurchaseLine.FieldCaption(Description), PurchaseLine.TableCaption(), Item2NoTok, PurchaseLine.Description));
        Assert.AreEqual(Item2NoTok, PurchaseLine."No.", StrSubstNo(MockDataMismatchErr, PurchaseLine.FieldCaption("No."), PurchaseLine.TableCaption(), Item2NoTok, PurchaseLine."No."));
    end;

    procedure SetMockDate(MockDate: Date)
    begin
        this.MockDate := MockDate;
    end;

    procedure SetMockCurrencyCode(MockCurrencyCode: Code[10])
    begin
        this.MockCurrencyCode := MockCurrencyCode;
    end;
}