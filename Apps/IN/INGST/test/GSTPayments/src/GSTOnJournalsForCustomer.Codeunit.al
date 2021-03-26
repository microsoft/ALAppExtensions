codeunit 18271 "GST On Journals For Customer"
{
    Subtype = Test;

    var
        VATPostingSetup: Record "VAT Posting Setup";
        LibraryRandom: Codeunit "Library - Random";
        LibraryGST: Codeunit "Library GST";
        LibraryERM: Codeunit "Library - ERM";
        LibraryJournals: Codeunit "Library - Journals";
        LibraryGSTJournals: Codeunit "Library GST Journals";
        ComponentPerArray: array[20] of Decimal;
        Storage: Dictionary of [Text[20], Text[20]];
        StorageBoolean: Dictionary of [Text[20], Boolean];
        GSTOnAdvanceReceiptErr: Label 'GST on Advance Payment must be equal to ''No'' in Gen. Journal Line: Journal Template Name= %1, Journal Batch Name= %2, Line No.= %3. Current value is ''Yes''', Comment = '%1 = Journal Template Name,%2 = Journal Batch Name,%3= Line No.';
        LocationCodeLbl: Label 'LocationCode', Locked = true;
        LocationStateCodeLbl: Label 'LocationStateCode', Locked = true;
        GSTGroupCodeLbl: Label 'GSTGroupCode', Locked = true;
        HSNSACCodeLbl: Label 'HSNSACCode', Locked = true;
        ExemptedLbl: Label 'Exempted', Locked = true;
        FromStateCodeLbl: Label 'FromStateCode', Locked = true;
        CustomerNoLbl: Label 'CustomerNo', Locked = true;
        ToStateCodeLbl: Label 'ToStateCode', Locked = true;
        GSTCustomerTypeLbl: Label 'GSTCustomerType', Locked = true;
        ReverseDocumentNoLbl: Label 'ReverseDocumentNo', Locked = true;
        PostedDocumentNoLbl: Label 'PostedDocumentNo', Locked = true;
        TemplateNameLbl: Label 'TemplateName', Locked = true;
        CustGSTTypeErr: Label ' You can select POS Out Of India field on header only if GST Customer/Vednor Type is Registered, Unregistered or Deemed Export.';
        InvoiceTypeErr: Label 'You can not select the Sales Invoice Type %1 for GST Customer Type %2.', Comment = '%1 = Sales Invoice Type , %2 = GST Customer Type';
        SalesInvoiceTypeBillofsupplyErr: Label 'Sales Invoice Type must be equal to ''Bill of Supply''  in Gen. Journal Line: Journal Template Name=%1, Journal Batch Name=%2, Line No.=%3. Current value is ''%4''.', Comment = '%1 = Journal Template Name,%2 = Journal Batch Name,%3= Line No.,%4=Current Value';
        ReferencenotxtErr: Label 'Reference Invoice No is required where Invoice Type is Debit note and Supplementary.';
        GSTPlaceOfSuppErr: Label 'You can not select POS Out Of India field on header if GST Place of Supply is Location Address.';
        GSTRelevantInfoErr: Label ' You cannot change any GST Relevant Information of Refund Doument after Payment Application.';
        GSTPlaceofSupplyFAErr: Label 'GST Place of Supply must be equal to ''%5''  in Gen. Journal Line: Journal Template Name=%1, Journal Batch Name=%2, Line No.=%3. Current value is ''%4''.', Comment = '%1 = Journal Template Name,%2 = Journal Batch Name,%3= Line No.,%4=Current Value,%5=Previous Value';
        ShiptoGSTARNErr: Label 'Either GST Registration No. or ARN No. should have a value in Ship To Code.';

    [Test]
    [HandlerFunctions('TaxRatePageHandler')]
    procedure CheckPosOutofIndiaExportCutomer()
    var
        GenJournalLine: Record "Gen. Journal Line";
        GSTJournalLineValidations: codeunit "GST Journal Line Validations";
        Assert: Codeunit Assert;
        TemplateType: Enum "Gen. Journal Template Type";
        GSTGroupType: Enum "GST Group Type";
        GSTCustomerType: Enum "GST Customer Type";
    begin
        // [SCENARIO] Check if system is only allowing POS out of India for registered customer.
        // [GIVEN] Gen journal line for account type customer and POS out of India.
        InitializeShareStep(false);
        CreateGSTSetup(GSTCustomerType::Export, GSTGroupType::Service, true, false);
        LibraryGSTJournals.CreateGenJnlLineFromCustomerToGLForInvoice(GenJournalLine, TemplateType::General);
        LibraryGSTJournals.ProvidePOSOutofIndiaValue(GenJournalLine);

        // [WHEN] The function Pos out of India is called for GST customer Type Export
        asserterror GSTJournalLineValidations.POSOutOfIndia(GenJournalLine);

        //[THEN] Verified error message for customer type.
        Assert.ExpectedError(CustGSTTypeErr);
    end;

    [Test]
    [HandlerFunctions('TaxRatePageHandler')]
    procedure CheckRegisteredCustomerNotExemptedSalesInvoiceType()
    var
        GenJournalLine: Record "Gen. Journal Line";
        GSTJournalLineValidations: codeunit "GST Journal Line Validations";
        Assert: Codeunit Assert;
        TemplateType: Enum "Gen. Journal Template Type";
        GSTGroupType: Enum "GST Group Type";
        GSTCustomerType: Enum "GST Customer Type";
        SalesInvociceType: Enum "Sales Invoice Type";
    begin
        // [SCENARIO] Check if system not allowing exempted invoice for registered customer and invoice type export.
        // [GIVEN] Gen Journal line for account type customer with invoice type as export and exempted as false.
        InitializeShareStep(false);
        CreateGSTSetup(GSTCustomerType::Registered, GSTGroupType::Service, true, false);
        LibraryGSTJournals.CreateGenJnlLineFromCustomerToGLForInvoice(GenJournalLine, TemplateType::General);
        AssignSalesInvoiceTypeValue(GenJournalLine, false, SalesInvociceType::Export, false);

        // [WHEN] The function salesinvoicetype is called.
        asserterror GSTJournalLineValidations.SalesInvoiceType(GenJournalLine);

        //[THEN] Verify the error message for sales invoice type.
        Assert.AreEqual(StrSubstNo(InvoiceTypeErr,
            GenJournalLine."Sales Invoice Type",
            GenJournalLine."GST Customer Type"),
            GetLastErrorText,
            '');
    end;

    [Test]
    [HandlerFunctions('TaxRatePageHandler')]
    procedure CheckRegisteredCustomerExemptedSalesInvoiceType()
    var
        GenJournalLine: Record "Gen. Journal Line";
        GSTJournalLineValidations: codeunit "GST Journal Line Validations";
        Assert: Codeunit Assert;
        TemplateType: Enum "Gen. Journal Template Type";
        GSTGroupType: Enum "GST Group Type";
        GSTCustomerType: Enum "GST Customer Type";
        SalesInvociceType: Enum "Sales Invoice Type";
    begin
        // [SCENARIO] Check if system allowing exempted invoice for registered customer and only for invoice type as bill of supply.
        // [GIVEN] Gen journal line for account type customer with invoice type as export and exempted as true.
        InitializeShareStep(false);
        CreateGSTSetup(GSTCustomerType::Registered, GSTGroupType::Service, true, false);
        LibraryGSTJournals.CreateGenJnlLineFromCustomerToGLForInvoice(GenJournalLine, TemplateType::General);
        AssignSalesInvoiceTypeValue(GenJournalLine, true, SalesInvociceType::Export, false);

        // [WHEN] The function salesinvoicetype is called.
        asserterror GSTJournalLineValidations.SalesInvoiceType(GenJournalLine);

        //[THEN] Verify the error message for sales invoice type.
        Assert.AreEqual(StrSubstNo(SalesInvoiceTypeBillofsupplyErr,
            GenJournalLine."Journal Template Name",
            GenJournalLine."Journal Batch Name",
            GenJournalLine."Line No.",
            GenJournalLine."Sales Invoice Type"),
            GetLastErrorText,
            '');
    end;

    [Test]
    [HandlerFunctions('TaxRatePageHandler')]
    procedure CheckExportCustomerNotExemptedSalesInvoiceType()
    var
        GenJournalLine: Record "Gen. Journal Line";
        GSTJournalLineValidations: codeunit "GST Journal Line Validations";
        Assert: Codeunit Assert;
        TemplateType: Enum "Gen. Journal Template Type";
        GSTGroupType: Enum "GST Group Type";
        GSTCustomerType: Enum "GST Customer Type";
        SalesInvociceType: Enum "Sales Invoice Type";
    begin
        // [SCENARIO] Check if system not allowing exempted invoice for export customer and invoice type bill of supply & taxable.
        // [GIVEN] Gen journal line for account type customer with invoice type as taxable and exempted as false.
        InitializeShareStep(false);
        CreateGSTSetup(GSTCustomerType::Export, GSTGroupType::Service, true, false);
        LibraryGSTJournals.CreateGenJnlLineFromCustomerToGLForInvoice(GenJournalLine, TemplateType::General);
        AssignSalesInvoiceTypeValue(GenJournalLine, false, SalesInvociceType::Taxable, false);

        // [WHEN] The function salesinvoicetype is called.
        asserterror GSTJournalLineValidations.SalesInvoiceType(GenJournalLine);

        //[THEN] Verify the error message for sales invoice type.
        Assert.AreEqual(StrSubstNo(InvoiceTypeErr,
            GenJournalLine."Sales Invoice Type",
            GenJournalLine."GST Customer Type"),
            GetLastErrorText,
            '');
    end;

    [Test]
    [HandlerFunctions('TaxRatePageHandler')]
    procedure CheckExportCustomerExemptedSalesInvoiceType()
    var
        GenJournalLine: Record "Gen. Journal Line";
        GSTJournalLineValidations: codeunit "GST Journal Line Validations";
        Assert: Codeunit Assert;
        TemplateType: Enum "Gen. Journal Template Type";
        GSTGroupType: Enum "GST Group Type";
        GSTCustomerType: Enum "GST Customer Type";
        SalesInvociceType: Enum "Sales Invoice Type";
    begin
        // [SCENARIO] Check if system allowing exempted invoice for export customer and only for invoice type as bill of supply.
        // [GIVEN] Gen journal line for account type customet with invoice type as export and exempted as true.
        InitializeShareStep(false);
        CreateGSTSetup(GSTCustomerType::Export, GSTGroupType::Service, true, false);
        LibraryGSTJournals.CreateGenJnlLineFromCustomerToGLForInvoice(GenJournalLine, TemplateType::General);
        AssignSalesInvoiceTypeValue(GenJournalLine, true, SalesInvociceType::Export, false);

        // [WHEN] The function salesinvoicetype is called.
        asserterror GSTJournalLineValidations.SalesInvoiceType(GenJournalLine);

        //[THEN] Verify the error message for sales invoice type.
        Assert.AreEqual(StrSubstNo(SalesInvoiceTypeBillofsupplyErr,
            GenJournalLine."Journal Template Name",
            GenJournalLine."Journal Batch Name",
            GenJournalLine."Line No.",
            GenJournalLine."Sales Invoice Type"),
            GetLastErrorText,
            '');
    end;

    [Test]
    [HandlerFunctions('TaxRatePageHandler')]
    procedure CheckExemptedCustomerTaxableSalesInvoiceType()
    var
        GenJournalLine: Record "Gen. Journal Line";
        GSTJournalLineValidations: codeunit "GST Journal Line Validations";
        Assert: Codeunit Assert;
        TemplateType: Enum "Gen. Journal Template Type";
        GSTGroupType: Enum "GST Group Type";
        GSTCustomerType: Enum "GST Customer Type";
        SalesInvociceType: Enum "Sales Invoice Type";
    begin
        // [SCENARIO] Check if system not allowing exempted invoice for exempted customer and invoice type as taxable .
        // [GIVEN] Gen journal line for account type customer with invoice type as taxable, exempted as false and ref. inv. no.
        InitializeShareStep(false);
        CreateGSTSetup(GSTCustomerType::Exempted, GSTGroupType::Service, true, false);
        LibraryGSTJournals.CreateGenJnlLineFromCustomerToGLForInvoice(GenJournalLine, TemplateType::General);
        AssignSalesInvoiceTypeValue(GenJournalLine, false, SalesInvociceType::Taxable, false);

        // [WHEN] The function salesinvoicetype is called.
        asserterror GSTJournalLineValidations.SalesInvoiceType(GenJournalLine);

        //[THEN] Verify the error message for invoice type.
        Assert.AreEqual(StrSubstNo(InvoiceTypeErr,
            GenJournalLine."Sales Invoice Type",
            GenJournalLine."GST Customer Type"),
            GetLastErrorText,
            '');
    end;

    [Test]
    [HandlerFunctions('TaxRatePageHandler')]
    procedure CheckRegisteredCustomerTaxableSalesInvoiceTypeRefInvNo()
    var
        GenJournalLine: Record "Gen. Journal Line";
        GSTJournalLineValidations: codeunit "GST Journal Line Validations";
        Assert: Codeunit Assert;
        TemplateType: Enum "Gen. Journal Template Type";
        GSTGroupType: Enum "GST Group Type";
        GSTCustomerType: Enum "GST Customer Type";
        SalesInvociceType: Enum "Sales Invoice Type";
    begin
        // [SCENARIO] Check if system not allowing registered customer invoice with ref. invoice no. and invoice type as taxable.
        // [GIVEN] Gen journal line for account type customer with invoice type as taxable and exempted as false.
        InitializeShareStep(false);
        CreateGSTSetup(GSTCustomerType::Registered, GSTGroupType::Service, true, false);
        LibraryGSTJournals.CreateGenJnlLineFromCustomerToGLForInvoice(GenJournalLine, TemplateType::General);
        AssignSalesInvoiceTypeValue(GenJournalLine, false, SalesInvociceType::Taxable, true);

        // [WHEN] The function salesinvoicetype is called.
        asserterror GSTJournalLineValidations.SalesInvoiceType(GenJournalLine);

        //[THEN] Verify the error message for ref inv. no.
        Assert.ExpectedError(ReferencenotxtErr);
    end;

    [Test]
    [HandlerFunctions('TaxRatePageHandler')]
    procedure CheckAccountNoPartyTypeCustomer()
    var
        GenJournalLine: Record "Gen. Journal Line";
        GSTJournalLineValidations: codeunit "GST Journal Line Validations";
        Assert: Codeunit Assert;
        TemplateType: Enum "Gen. Journal Template Type";
        GSTGroupType: Enum "GST Group Type";
        GSTCustomerType: Enum "GST Customer Type";
    begin
        // [SCENARIO] Check if system assigning same value in account no. as party code for party type customer .
        // [GIVEN] Gen journal line for party type customer.
        InitializeShareStep(false);
        CreateGSTSetup(GSTCustomerType::Registered, GSTGroupType::Service, true, false);
        LibraryGSTJournals.CreateGenJnlLineFromPartyTypeCustomerToGLForInvoice(GenJournalLine, TemplateType::General);

        // [WHEN] The function PartyCode is called.
        GSTJournalLineValidations.PartyCode(GenJournalLine);

        //[THEN] Verify the account no. is same as party code.
        Assert.Compare(GenJournalLine."Party Code", GenJournalLine."Account No.");
    end;

    [Test]
    [HandlerFunctions('TaxRatePageHandler')]
    procedure CheckBalCustNo()
    var
        GenJournalLine: Record "Gen. Journal Line";
        Customer: Record Customer;
        GSTJournalLineValidations: codeunit "GST Journal Line Validations";
        Assert: Codeunit Assert;
        TemplateType: Enum "Gen. Journal Template Type";
        GSTGroupType: Enum "GST Group Type";
        GSTCustomerType: Enum "GST Customer Type";
        PartyCode: Code[20];
    begin
        // [SCENARIO] Check if system assigning GST customer type same as bal customer, when party type customer.
        // [GIVEN] Gen journal line for party type customer.
        InitializeShareStep(false);
        CreateGSTSetup(GSTCustomerType::Registered, GSTGroupType::Service, true, false);
        PartyCode := LibraryGST.CreateCustomerParties(GSTCustomerType::Registered);
        LibraryGSTJournals.CreateGenJnlLineFromPartyTypeCustomerInvoice(GenJournalLine, TemplateType::General, PartyCode);
        Customer.Get(GenJournalLine."Account No.");

        // [WHEN] The function balcusno is called.
        GSTJournalLineValidations.BalCustNo(GenJournalLine, Customer);

        //[THEN] Verify the gst customer type same in gen. journal line.
        Assert.Compare(GenJournalLine."GST Customer Type", Customer."GST Customer Type");
    end;

    [Test]
    [HandlerFunctions('TaxRatePageHandler')]
    procedure CheckCustomerInvoiceWithAppliestoDocNo()
    var
        xGenJournalLine: Record "Gen. Journal Line";
        GenJournalLine: Record "Gen. Journal Line";
        GSTJournalLineValidations: codeunit "GST Journal Line Validations";
        Assert: Codeunit Assert;
        TemplateType: Enum "Gen. Journal Template Type";
        GSTGroupType: Enum "GST Group Type";
        GSTCustomerType: Enum "GST Customer Type";
        AccountType: Enum "Gen. Journal Account Type";
    begin
        // [SCENARIO] Check if system not allowing to change any revelant GST information after application.
        // [GIVEN] Gen journal line for invoice and applies to doc no.
        InitializeShareStep(false);
        CreateGSTSetup(GSTCustomerType::Registered, GSTGroupType::Service, true, false);
        CreateGenJnlLineToGL(GenJournalLine, TemplateType::General, AccountType::Customer, false, false);
        xGenJournalLine := GenJournalLine;
        LibraryGSTJournals.AssignAppliesToDocNo(GenJournalLine);

        // [WHEN] The function GSTPlaceofSupply is called.
        asserterror GSTJournalLineValidations.GSTPlaceofsuppply(GenJournalLine, xGenJournalLine);

        //[THEN] Verify the error message after application.
        Assert.ExpectedError(GSTRelevantInfoErr);
    end;

    [Test]
    [HandlerFunctions('TaxRatePageHandler')]
    procedure CheckFAInvoiceGSTPlaceofSupply()
    var
        xGenJournalLine: Record "Gen. Journal Line";
        GenJournalLine: Record "Gen. Journal Line";
        GSTJournalLineValidations: codeunit "GST Journal Line Validations";
        Assert: Codeunit Assert;
        TemplateType: Enum "Gen. Journal Template Type";
        GSTGroupType: Enum "GST Group Type";
        GSTCustomerType: Enum "GST Customer Type";
        AccountType: Enum "Gen. Journal Account Type";
    begin
        // [SCENARIO] Check if system not allowing to change GST place of supply for FA reclassification entry.
        // [GIVEN] Gen journal line for FA and GST place of supply.
        InitializeShareStep(false);
        CreateGSTSetup(GSTCustomerType::Registered, GSTGroupType::Service, true, false);
        CreateGenJnlLineToGL(GenJournalLine, TemplateType::General, AccountType::"Fixed Asset", true, false);
        xGenJournalLine := GenJournalLine;
        LibraryGSTJournals.AssignFAInfotoGenJournalLine(GenJournalLine, xGenJournalLine);

        // [WHEN] The function GSTPlaceofSupply is called.
        asserterror GSTJournalLineValidations.GSTPlaceofsuppply(GenJournalLine, xGenJournalLine);

        //[THEN] Verify the error message for FA entry.
        Assert.AreEqual(StrSubstNo(GSTPlaceofSupplyFAErr,
            GenJournalLine."Journal Template Name",
            GenJournalLine."Journal Batch Name",
            GenJournalLine."Line No.",
            GenJournalLine."GST Place of Supply",
            xGenJournalLine."GST Place of Supply"),
            GetLastErrorText,
            '');
    end;

    [Test]
    [HandlerFunctions('TaxRatePageHandler')]
    procedure CheckShiptoCodeRegArnNo()
    var
        xGenJournalLine: Record "Gen. Journal Line";
        GenJournalLine: Record "Gen. Journal Line";
        Assert: Codeunit Assert;
        TemplateType: Enum "Gen. Journal Template Type";
        GSTGroupType: Enum "GST Group Type";
        GSTCustomerType: Enum "GST Customer Type";
        AccountType: Enum "Gen. Journal Account Type";
    begin
        // [SCENARIO] Check for gst registration no. or arn no. in ship to code.
        // [GIVEN] Gen journal line for registered customer.
        InitializeShareStep(false);
        CreateGSTSetup(GSTCustomerType::Registered, GSTGroupType::Service, true, false);
        CreateGenJnlLineToGL(GenJournalLine, TemplateType::General, AccountType::Customer, false, true);
        xGenJournalLine := GenJournalLine;

        // [WHEN] The function GSTPlaceofSupply is called.
        asserterror GenJournalLine.Validate("GST Place of Supply", GenJournalLine."GST Place of Supply"::"Ship-to Address");

        //[THEN] Verify the error message for blank GST reg no. or arn no.
        Assert.ExpectedError(ShiptoGSTARNErr);
    end;

    [Test]
    [HandlerFunctions('TaxRatePageHandler')]
    procedure CheckPosOutofIndiaIMultiLineCustomerLocationAddress()
    var
        GenJournalLine: Record "Gen. Journal Line";
        GSTJournalLineValidations: codeunit "GST Journal Line Validations";
        Assert: Codeunit Assert;
        TemplateType: Enum "Gen. Journal Template Type";
        GSTGroupType: Enum "GST Group Type";
        GSTCustomerType: Enum "GST Customer Type";
        GSTPlaceOfSupply: Enum "GST Dependency Type";
    begin
        // [SCENARIO] Check if system does not allow multiline invoice for POS out of India and GST place of supply location address for export customer.
        // [GIVEN] Gen Journal Line for Account Type Customer and POS out of India.
        InitializeShareStep(false);
        CreateGSTSetup(GSTCustomerType::Export, GSTGroupType::Service, true, false);
        LibraryGSTJournals.CreateGenJnlLineFromCustomerToGLForInvoice(GenJournalLine, TemplateType::General);
        LibraryGSTJournals.ProvidePOSOutofIndiaMultiLineValue(GenJournalLine, GSTPlaceOfSupply::"Location Address", GSTCustomerType::" ");
        //Second line
        LibraryGSTJournals.CreateSecondGenJnlLineFromCustomerToGLForInvoice(GenJournalLine);
        LibraryGSTJournals.ProvidePOSOutofIndiaMultiLineValue(GenJournalLine, GSTPlaceOfSupply::" ", GSTCustomerType::Export);

        // [WHEN] The function Pos out of India is called.
        asserterror GSTJournalLineValidations.POSOutOfIndia(GenJournalLine);

        //[THEN] Verify error message for GST place os supply.
        Assert.ExpectedError(GSTPlaceOfSuppErr);
    end;

    [Test]
    [HandlerFunctions('TaxRatePageHandler')]
    procedure CheckPosOutofIndiaCustomerBlankGSTPlaceofSupply()
    var
        GenJournalLine: Record "Gen. Journal Line";
        GSTJournalLineValidations: codeunit "GST Journal Line Validations";
        Assert: Codeunit Assert;
        TemplateType: Enum "Gen. Journal Template Type";
        GSTGroupType: Enum "GST Group Type";
        GSTCustomerType: Enum "GST Customer Type";
        GSTPlaceOfSupply: Enum "GST Dependency Type";
    begin
        // [SCENARIO] Check if system does not allow invoice for POS out of India and GST place of supply as blank for export customer.
        // [GIVEN] Gen Journal Line for Account Type Customer and POS out of India,with blank GST place of supply.
        InitializeShareStep(false);
        CreateGSTSetup(GSTCustomerType::Export, GSTGroupType::Service, true, false);
        LibraryGSTJournals.CreateGenJnlLineFromCustomerToGLForInvoice(GenJournalLine, TemplateType::General);
        LibraryGSTJournals.ProvidePOSOutofIndiaMultiLineValue(GenJournalLine, GSTPlaceOfSupply::" ", GSTCustomerType::Export);

        // [WHEN] The function Pos out of India is called.
        asserterror GSTJournalLineValidations.POSOutOfIndia(GenJournalLine);

        //[THEN] Verify error message for GST customer type.
        Assert.ExpectedError(CustGSTTypeErr);
    end;

    [Test]
    [HandlerFunctions('TaxRatePageHandler')]
    procedure PostFromBankReceiptVoucherWithGSTOnAdvanceReceiptForSEZDevelopment()
    var
        GenJournalLine: Record "Gen. Journal Line";
        Assert: Codeunit Assert;
        GSTGroupType: Enum "GST Group Type";
        GSTCustomerType: Enum "GST Customer Type";
        TemplateType: Enum "Gen. Journal Template Type";
    begin
        // [SCENARIO] [355678] -Check if system is not calculating GST on Advance Receipt for : - Customer - SEZ Development.
        // [GIVEN] Created GST Setup
        InitializeShareStep(false);
        CreateGSTSetup(GSTCustomerType::"SEZ Development", GSTGroupType::Service, false, false);
        LibraryGSTJournals.CreateLocationWithVoucherSetup(TemplateType::"Bank Receipt Voucher");

        // [WHEN] Create and Post Bank Rceipt Voucher
        LibraryGSTJournals.CreateGenJnlLineForVoucherWithoutAdvancePayment(GenJournalLine, TemplateType::"Bank Receipt Voucher");

        // [THEN] Assert error Verified
        asserterror GenJournalLine.Validate("GST on Advance Payment", true);
        Assert.IsFalse(GenJournalLine."GST on Advance Payment", StrSubstNo(GSTOnAdvanceReceiptErr, GenJournalLine."Journal Template Name", GenJournalLine."Journal Batch Name", GenJournalLine."Line No."));
    end;

    [Test]
    [HandlerFunctions('TaxRatePageHandler')]
    procedure PostFromBankReceiptVoucherWithGSTOnAdvanceReceiptForExport()
    var
        GenJournalLine: Record "Gen. Journal Line";
        Assert: Codeunit Assert;
        GSTGroupType: Enum "GST Group Type";
        GSTCustomerType: Enum "GST Customer Type";
        TemplateType: Enum "Gen. Journal Template Type";
    begin
        // [SCENARIO] [355662] -Check if system is not calculating GST on Advance Receipt for : - Customer - Export.
        // [GIVEN] Created GST Setup
        InitializeShareStep(false);
        CreateGSTSetup(GSTCustomerType::Export, GSTGroupType::Service, false, false);
        LibraryGSTJournals.CreateLocationWithVoucherSetup(TemplateType::"Bank Receipt Voucher");

        // [WHEN] Create and Post Bank Receipt Voucher
        LibraryGSTJournals.CreateGenJnlLineForVoucherWithoutAdvancePayment(GenJournalLine, TemplateType::"Bank Receipt Voucher");

        // [THEN] Assert error Verified
        asserterror GenJournalLine.Validate("GST on Advance Payment", true);
        Assert.IsFalse(GenJournalLine."GST on Advance Payment", StrSubstNo(GSTOnAdvanceReceiptErr, GenJournalLine."Journal Template Name", GenJournalLine."Journal Batch Name", GenJournalLine."Line No."));
    end;

    [Test]
    [HandlerFunctions('TaxRatePageHandler')]
    procedure PostFromBankReceiptVoucherWithGSTOnAdvanceReceiptForDeemedExports()
    var
        GenJournalLine: Record "Gen. Journal Line";
        Assert: Codeunit Assert;
        GSTGroupType: Enum "GST Group Type";
        GSTCustomerType: Enum "GST Customer Type";
        TemplateType: Enum "Gen. Journal Template Type";
    begin
        // [SCENARIO] [355668] - Check if system is not calculating GST on Advance Receipt for : - Customer - Deemed Exports.
        // [GIVEN] Created GST Setup
        InitializeShareStep(false);
        CreateGSTSetup(GSTCustomerType::"Deemed Export", GSTGroupType::Service, false, false);
        LibraryGSTJournals.CreateLocationWithVoucherSetup(TemplateType::"Bank Receipt Voucher");

        // [WHEN] Create and Post Bank Receipt Voucher
        LibraryGSTJournals.CreateGenJnlLineForVoucherWithoutAdvancePayment(GenJournalLine, TemplateType::"Bank Receipt Voucher");

        // [THEN] Assert error Verified
        asserterror GenJournalLine.Validate("GST on Advance Payment", true);
        Assert.IsFalse(GenJournalLine."GST on Advance Payment", StrSubstNo(GSTOnAdvanceReceiptErr, GenJournalLine."Journal Template Name", GenJournalLine."Journal Batch Name", GenJournalLine."Line No."));
    end;

    [Test]
    [HandlerFunctions('TaxRatePageHandler')]
    procedure PostFromBankReceiptVoucherWithGSTOnAdvanceReceiptForSEZUnit()
    var
        GenJournalLine: Record "Gen. Journal Line";
        Assert: Codeunit Assert;
        GSTGroupType: Enum "GST Group Type";
        GSTCustomerType: Enum "GST Customer Type";
        TemplateType: Enum "Gen. Journal Template Type";
    begin
        // [SCENARIO] [355674]- Check if system is not calculating GST on Advance Receipt for : - Customer - SEZ Unit.
        // [GIVEN] Created GST Setup
        InitializeShareStep(false);
        CreateGSTSetup(GSTCustomerType::"SEZ Unit", GSTGroupType::Service, false, false);
        LibraryGSTJournals.CreateLocationWithVoucherSetup(TemplateType::"Bank Receipt Voucher");

        // [WHEN] Create and Post Bank Receipt Voucher
        LibraryGSTJournals.CreateGenJnlLineForVoucherWithoutAdvancePayment(GenJournalLine, TemplateType::"Bank Receipt Voucher");

        // [THEN] Assert error Verified
        asserterror GenJournalLine.Validate("GST on Advance Payment", true);
        Assert.IsFalse(GenJournalLine."GST on Advance Payment", StrSubstNo(GSTOnAdvanceReceiptErr, GenJournalLine."Journal Template Name", GenJournalLine."Journal Batch Name", GenJournalLine."Line No."));
    end;

    [Test]
    [HandlerFunctions('TaxRatePageHandler')]
    procedure PostFromBankReceiptVoucherWithGSTOnAdvanceReceiptForExemptedCustomer()
    var
        GenJournalLine: Record "Gen. Journal Line";
        Assert: Codeunit Assert;
        GSTGroupType: Enum "GST Group Type";
        GSTCustomerType: Enum "GST Customer Type";
        TemplateType: Enum "Gen. Journal Template Type";
    begin
        // [SCENARIO] [355677]- Check if system is not calculating GST on Advance Receipt for : - Customer - Exempted.
        // [GIVEN] Created GST Setup
        InitializeShareStep(true);
        CreateGSTSetup(GSTCustomerType::Exempted, GSTGroupType::Service, false, false);
        LibraryGSTJournals.CreateLocationWithVoucherSetup(TemplateType::"Bank Receipt Voucher");

        // [WHEN] Create and Post Bank Receipt Voucher
        LibraryGSTJournals.CreateGenJnlLineForVoucherWithoutAdvancePayment(GenJournalLine, TemplateType::"Bank Receipt Voucher");

        // [THEN] Assert error Verified
        asserterror GenJournalLine.Validate("GST on Advance Payment", true);
        Assert.IsFalse(GenJournalLine."GST on Advance Payment", StrSubstNo(GSTOnAdvanceReceiptErr, GenJournalLine."Journal Template Name", GenJournalLine."Journal Batch Name", GenJournalLine."Line No."));
    end;

    [Test]
    [HandlerFunctions('TaxRatePageHandler')]
    procedure PostFromSalesJournalForGoodsRegisteredInterState()
    var
        GenJournalLine: Record "Gen. Journal Line";
        GSTGroupType: Enum "GST Group Type";
        GSTCustomerType: Enum "GST Customer Type";
        TemplateType: Enum "Gen. Journal Template Type";
        DocumentNo: Code[20];
    begin
        // [SCENARIO] [358548] Inter-State Sales of Goods to Registered or Unregistered Customer through Sale Journal
        // [GIVEN] Created GST Setup
        InitializeShareStep(false);
        CreateGSTSetup(GSTCustomerType::Registered, GSTGroupType::Goods, false, false);
        SetStorageGSTJournalText(GSTCustomerTypeLbl, Format(GSTCustomerType::Registered));

        // [WHEN] Create and Post Sales Journal
        LibraryGSTJournals.CreateGenJnlLineFromCustomerToGLForInvoice(GenJournalLine, TemplateType::Sales);
        LibraryERM.PostGeneralJnlLine(GenJournalLine);

        // [THEN] GST ledger entries are created and Verified
        DocumentNo := LibraryGST.VerifyGLEntry(GenJournalLine."Journal Batch Name");
        LibraryGST.GSTLedgerEntryCount(DocumentNo, 1);
    end;

    [Test]
    [HandlerFunctions('TaxRatePageHandler')]
    procedure PostFromSalesJournalForServiceUnregisteredInterState()
    var
        GenJournalLine: Record "Gen. Journal Line";
        GSTGroupType: Enum "GST Group Type";
        GSTCustomerType: Enum "GST Customer Type";
        TemplateType: Enum "Gen. Journal Template Type";
        DocumentNo: Code[20];
    begin
        // [SCENARIO] [358595] Inter-State Sales of Services to Registered or Unregistered Customer through Sale Journal
        // [GIVEN] Created GST Setup
        InitializeShareStep(false);
        CreateGSTSetup(GSTCustomerType::Unregistered, GSTGroupType::Service, false, false);
        SetStorageGSTJournalText(GSTCustomerTypeLbl, Format(GSTCustomerType::Registered));

        // [WHEN] Create and Post Sales Journal
        LibraryGSTJournals.CreateGenJnlLineFromCustomerToGLForInvoice(GenJournalLine, TemplateType::Sales);
        LibraryERM.PostGeneralJnlLine(GenJournalLine);

        // [THEN] GST ledger entries are created and Verified
        DocumentNo := LibraryGST.VerifyGLEntry(GenJournalLine."Journal Batch Name");
        LibraryGST.GSTLedgerEntryCount(DocumentNo, 1);
    end;

    [Test]
    [HandlerFunctions('TaxRatePageHandler')]
    procedure PostFromGeneralJournalForServiceUnregisteredInterState()
    var
        GenJournalLine: Record "Gen. Journal Line";
        GSTGroupType: Enum "GST Group Type";
        GSTCustomerType: Enum "GST Customer Type";
        TemplateType: Enum "Gen. Journal Template Type";
        DocumentNo: Code[20];
    begin
        // [SCENARIO] [358595] Inter-State Sales of Services to Registered or Unregistered Customer through Sale Journal
        // [GIVEN] Created GST Setup
        InitializeShareStep(false);
        CreateGSTSetup(GSTCustomerType::Unregistered, GSTGroupType::Service, false, false);
        SetStorageGSTJournalText(GSTCustomerTypeLbl, Format(GSTCustomerType::Registered));

        // [WHEN] Create and Post Sales Journal
        LibraryGSTJournals.CreateGenJnlLineFromCustomerToGLForInvoice(GenJournalLine, TemplateType::Sales);
        LibraryERM.PostGeneralJnlLine(GenJournalLine);

        // [THEN] GST ledger entries are created and Verified
        DocumentNo := LibraryGST.VerifyGLEntry(GenJournalLine."Journal Batch Name");
        LibraryGST.GSTLedgerEntryCount(DocumentNo, 1);
    end;

    [Test]
    [HandlerFunctions('TaxRatePageHandler')]
    procedure PostFromGeneralJournalForServiceRegisteredIntraState()
    var
        GenJournalLine: Record "Gen. Journal Line";
        GSTGroupType: Enum "GST Group Type";
        GSTCustomerType: Enum "GST Customer Type";
        TemplateType: Enum "Gen. Journal Template Type";
        DocumentNo: Code[20];
    begin
        // [SCENARIO] [358595] Inter-State Sales of Services to Registered or Unregistered Customer through Sale Journal
        // [GIVEN] Created GST Setup
        InitializeShareStep(false);
        CreateGSTSetup(GSTCustomerType::Registered, GSTGroupType::Service, true, false);
        SetStorageGSTJournalText(GSTCustomerTypeLbl, Format(GSTCustomerType::Registered));

        // [WHEN] Create and Post Sales Journal
        LibraryGSTJournals.CreateGenJnlLineFromCustomerToGLForInvoice(GenJournalLine, TemplateType::Sales);
        LibraryERM.PostGeneralJnlLine(GenJournalLine);

        // [THEN] GST ledger entries are created and Verified
        DocumentNo := LibraryGST.VerifyGLEntry(GenJournalLine."Journal Batch Name");
        LibraryGST.GSTLedgerEntryCount(DocumentNo, 2);
    end;

    [Test]
    [HandlerFunctions('TaxRatePageHandler')]
    procedure PostFromSalesJournalForRegisteredIntraState()
    var
        GenJournalLine: Record "Gen. Journal Line";
        GSTGroupType: Enum "GST Group Type";
        GSTCustomerType: Enum "GST Customer Type";
        TemplateType: Enum "Gen. Journal Template Type";
        DocumentNo: Code[20];
    begin
        // [SCENARIO] [355739] Check if system is calculating GST on Invoice created from Sales journals for Registered Customer.
        // [GIVEN] Created GST Setup
        InitializeShareStep(false);
        CreateGSTSetup(GSTCustomerType::Registered, GSTGroupType::Service, true, false);

        // [WHEN] Create and Post Sales Journal
        LibraryGSTJournals.CreateGenJnlLineFromCustomerToGLForInvoice(GenJournalLine, TemplateType::Sales);
        LibraryERM.PostGeneralJnlLine(GenJournalLine);

        // [THEN] GST ledger entries are created and Verified
        DocumentNo := LibraryGST.VerifyGLEntry(GenJournalLine."Journal Batch Name");
        LibraryGST.GSTLedgerEntryCount(DocumentNo, 2);
    end;

    [Test]
    [HandlerFunctions('TaxRatePageHandler')]
    procedure PostFromSalesJournalForUnregisteredIntraState()
    var
        GenJournalLine: Record "Gen. Journal Line";
        GSTGroupType: Enum "GST Group Type";
        GSTCustomerType: Enum "GST Customer Type";
        TemplateType: Enum "Gen. Journal Template Type";
        DocumentNo: Code[20];
    begin
        // [SCENARIO] [355740] Check if system is calculating GST on Invoice created from Sales journals for Unregistered Customer.
        // [GIVEN] Created GST Setup
        InitializeShareStep(false);
        CreateGSTSetup(GSTCustomerType::Unregistered, GSTGroupType::Service, true, false);

        // [WHEN] Create and Post Sales Journal
        LibraryGSTJournals.CreateGenJnlLineFromCustomerToGLForInvoice(GenJournalLine, TemplateType::Sales);
        LibraryERM.PostGeneralJnlLine(GenJournalLine);

        // [THEN] GST ledger entries are created and Verified
        DocumentNo := LibraryGST.VerifyGLEntry(GenJournalLine."Journal Batch Name");
        LibraryGST.GSTLedgerEntryCount(DocumentNo, 2);
    end;

    [Test]
    [HandlerFunctions('TaxRatePageHandler')]
    procedure PostFromGeneralJournalForRegisteredIntraState()
    var
        GenJournalLine: Record "Gen. Journal Line";
        GSTGroupType: Enum "GST Group Type";
        GSTCustomerType: Enum "GST Customer Type";
        TemplateType: Enum "Gen. Journal Template Type";
        DocumentNo: Code[20];
    begin
        // [SCENARIO] [355745] Check if system is calculating GST on Invoice created from General journals for Registered Customer
        // [GIVEN] Created GST Setup
        InitializeShareStep(false);
        CreateGSTSetup(GSTCustomerType::Registered, GSTGroupType::Service, true, false);

        // [WHEN] Create and Post Sales Journal
        LibraryGSTJournals.CreateGenJnlLineFromCustomerToGLForInvoice(GenJournalLine, TemplateType::General);
        LibraryERM.PostGeneralJnlLine(GenJournalLine);

        // [THEN] GST ledger entries are created and Verified
        DocumentNo := LibraryGST.VerifyGLEntry(GenJournalLine."Journal Batch Name");
        LibraryGST.GSTLedgerEntryCount(DocumentNo, 2);
    end;

    [Test]
    [HandlerFunctions('TaxRatePageHandler')]
    procedure PostFromGeneralJournalForUnregisteredIntraState()
    var
        GenJournalLine: Record "Gen. Journal Line";
        GSTGroupType: Enum "GST Group Type";
        GSTCustomerType: Enum "GST Customer Type";
        TemplateType: Enum "Gen. Journal Template Type";
        DocumentNo: Code[20];
    begin
        // [SCENARIO] [355746] Check if system is calculating GST on Invoice created from General journals for Unregistered Customer
        // [GIVEN] Created GST Setup
        InitializeShareStep(false);
        CreateGSTSetup(GSTCustomerType::Unregistered, GSTGroupType::Service, true, false);

        // [WHEN] Create and Post Sales Journal
        LibraryGSTJournals.CreateGenJnlLineFromCustomerToGLForInvoice(GenJournalLine, TemplateType::General);
        LibraryERM.PostGeneralJnlLine(GenJournalLine);

        // [THEN] GST ledger entries are created and Verified
        DocumentNo := LibraryGST.VerifyGLEntry(GenJournalLine."Journal Batch Name");
        LibraryGST.GSTLedgerEntryCount(DocumentNo, 2);
    end;

    [Test]
    [HandlerFunctions('TaxRatePageHandler')]
    procedure PostFromGeneralJournalForExportIntraState()
    var
        GenJournalLine: Record "Gen. Journal Line";
        GSTGroupType: Enum "GST Group Type";
        GSTCustomerType: Enum "GST Customer Type";
        TemplateType: Enum "Gen. Journal Template Type";
        DocumentNo: Code[20];
    begin
        // [SCENARIO] [355747] Check if system is calculating GST on Invoice created from General journals for Export Customer
        // [GIVEN] Created GST Setup
        InitializeShareStep(false);
        CreateGSTSetup(GSTCustomerType::Export, GSTGroupType::Service, false, false);

        // [WHEN] Create and Post Sales Journal
        LibraryGSTJournals.CreateGenJnlLineFromCustomerToGLForInvoice(GenJournalLine, TemplateType::General);
        LibraryERM.PostGeneralJnlLine(GenJournalLine);

        // [THEN] GST ledger entries are created and Verified
        DocumentNo := LibraryGST.VerifyGLEntry(GenJournalLine."Journal Batch Name");
        LibraryGST.GSTLedgerEntryCount(DocumentNo, 1);
    end;

    [Test]
    [HandlerFunctions('TaxRatePageHandler')]
    procedure PostFromGeneralJournalForSezUnitIntraState()
    var
        GenJournalLine: Record "Gen. Journal Line";
        GSTGroupType: Enum "GST Group Type";
        GSTCustomerType: Enum "GST Customer Type";
        TemplateType: Enum "Gen. Journal Template Type";
        DocumentNo: Code[20];
    begin
        // [SCENARIO] [355748] Check if system is calculating GST on Invoice created from General journals for SEZ Unit Customer
        // [GIVEN] Created GST Setup
        InitializeShareStep(false);
        CreateGSTSetup(GSTCustomerType::"SEZ Unit", GSTGroupType::Service, false, false);

        // [WHEN] Create and Post Sales Journal
        LibraryGSTJournals.CreateGenJnlLineFromCustomerToGLForInvoice(GenJournalLine, TemplateType::General);
        LibraryERM.PostGeneralJnlLine(GenJournalLine);

        // [THEN] GST ledger entries are created and Verified
        DocumentNo := LibraryGST.VerifyGLEntry(GenJournalLine."Journal Batch Name");
        LibraryGST.GSTLedgerEntryCount(DocumentNo, 1);
    end;

    [Test]
    [HandlerFunctions('TaxRatePageHandler')]
    procedure PostFromGeneralJournalForSEZDevelopmentIntraState()
    var
        GenJournalLine: Record "Gen. Journal Line";
        GSTGroupType: Enum "GST Group Type";
        GSTCustomerType: Enum "GST Customer Type";
        TemplateType: Enum "Gen. Journal Template Type";
        DocumentNo: Code[20];
    begin
        // [SCENARIO] [355750] Check if system is calculating GST on Invoice created from General journals for SEZ Development Customer
        // [GIVEN] Created GST Setup
        InitializeShareStep(false);
        CreateGSTSetup(GSTCustomerType::"SEZ Development", GSTGroupType::Service, false, false);

        // [WHEN] Create and Post General Journal
        LibraryGSTJournals.CreateGenJnlLineFromCustomerToGLForInvoice(GenJournalLine, TemplateType::General);
        LibraryERM.PostGeneralJnlLine(GenJournalLine);

        // [THEN] GST ledger entries are created and Verified
        DocumentNo := LibraryGST.VerifyGLEntry(GenJournalLine."Journal Batch Name");
        LibraryGST.GSTLedgerEntryCount(DocumentNo, 1);
    end;

    [Test]
    [HandlerFunctions('TaxRatePageHandler')]
    procedure PostFromSalesJournalForExportWithFCY()
    var
        GenJournalLine: Record "Gen. Journal Line";
        GSTGroupType: Enum "GST Group Type";
        GSTCustomerType: Enum "GST Customer Type";
        TemplateType: Enum "Gen. Journal Template Type";
        DocumentNo: Code[20];
    begin
        // [SCENARIO] [358604] GST calculation  in Foreign currency transaction through Sale journal
        // [GIVEN] Created GST Setup
        InitializeShareStep(false);
        CreateGSTSetup(GSTCustomerType::Export, GSTGroupType::Service, false, false);

        // [WHEN] Create and Post Sales Journal
        LibraryGSTJournals.CreateGenJnlLineFromCustomerToGLForInvoice(GenJournalLine, TemplateType::Sales);
        LibraryERM.PostGeneralJnlLine(GenJournalLine);

        // [THEN] GST ledger entries are created and Verified
        DocumentNo := LibraryGST.VerifyGLEntry(GenJournalLine."Journal Batch Name");
        LibraryGST.GSTLedgerEntryCount(DocumentNo, 1);
    end;

    [Test]
    [HandlerFunctions('TaxRatePageHandler,JournalTemplateHandler,ReferencePageHandler,CustomerLedgerEntries')]
    procedure PostFromSalesJournalCreditMemoForRegisteredCustomerWithRefInvNo()
    var
        GenJournalLine: Record "Gen. Journal Line";
        GSTGroupType: Enum "GST Group Type";
        GSTCustomerType: Enum "GST Customer Type";
        TemplateType: Enum "Gen. Journal Template Type";
        DocumentNo: Code[20];
    begin
        // [SCENARIO] GST calculation in credit memo from sales journal for registered customer

        // [GIVEN] Created GST Setup and tax rates with gst group service and jurisdiction type intrastate
        InitializeShareStep(false);
        CreateGSTSetup(GSTCustomerType::Registered, GSTGroupType::Service, true, false);

        // [WHEN] Create and Post Sales Journal for Invoice
        LibraryGSTJournals.CreateGenJnlLineFromCustomerToGLForInvoice(GenJournalLine, TemplateType::Sales);
        SetStorageGSTJournalText(PostedDocumentNoLbl, GenJournalLine."Document No.");
        LibraryERM.PostGeneralJnlLine(GenJournalLine);

        // [THEN] create and post sales journal with credit memo and reference invoice number
        LibraryGSTJournals.CreateGenJnlLineFromCustomerToGLForCreditMemo(GenJournalLine, TemplateType::Sales);
        SetStorageGSTJournalText(ReverseDocumentNoLbl, GenJournalLine."Document No.");
        LibraryERM.PostGeneralJnlLine(GenJournalLine);

        // [THEN] Verify GST Ledger Entry
        DocumentNo := LibraryGST.VerifyGLEntry(GenJournalLine."Journal Batch Name");
        LibraryGST.GSTLedgerEntryCount(DocumentNo, 2);
    end;

    local procedure CreateTaxRate()
    var
        GSTSetup: Record "GST Setup";
        TaxTypes: TestPage "Tax Types";
    begin
        if not GSTSetup.Get() then
            exit;
        TaxTypes.OpenEdit();
        TaxTypes.Filter.SetFilter(Code, GSTSetup."GST Tax Type");
        TaxTypes.TaxRates.Invoke();
    end;

    local procedure CreateGSTSetup(
        GSTCustomerType: Enum "GST Customer Type";
        GSTGroupType: Enum "GST Group Type";
        IntraState: Boolean;
        ReverseCharge: Boolean)
    var
        GSTGroup: Record "GST Group";
        HSNSAC: Record "HSN/SAC";
        TaxComponent: Record "Tax Component";
        CompanyInformation: Record "Company information";
        LocationStateCode: Code[10];
        CustomerNo: Code[20];
        LocationCode: Code[10];
        CustomerStateCode: Code[10];
        LocPANNo: Code[20];
        LocationGSTRegNo: Code[15];
        GSTGroupCode: Code[20];
        HSNSACCode: Code[10];
        HsnSacType: Enum "GST Goods And Services Type";
        GSTComponentCode: Text[30];
    begin
        CompanyInformation.Get();
        if CompanyInformation."P.A.N. No." = '' then begin
            CompanyInformation."P.A.N. No." := LibraryGST.CreatePANNos();
            CompanyInformation.Modify();
        end else
            LocPANNo := CompanyInformation."P.A.N. No.";

        LocPANNo := CompanyInformation."P.A.N. No.";
        LocationStateCode := LibraryGST.CreateInitialSetup();
        SetStorageGSTJournalText(LocationStateCodeLbl, LocationStateCode);

        LocationGSTRegNo := LibraryGST.CreateGSTRegistrationNos(LocationStateCode, LocPANNo);

        if CompanyInformation."GST Registration No." = '' then begin
            CompanyInformation."GST Registration No." := LocationGSTRegNo;
            CompanyInformation.Modify(true);
        end;

        LocationCode := LibraryGST.CreateLocationSetup(LocationStateCode, LocationGSTRegNo, false);
        SetStorageGSTJournalText(LocationCodeLbl, LocationCode);

        GSTGroupCode := LibraryGST.CreateGSTGroup(GSTGroup, GSTGroupType, GSTGroup."GST Place Of Supply"::"Bill-to Address", ReverseCharge);
        SetStorageGSTJournalText(GSTGroupCodeLbl, GSTGroupCode);

        HSNSACCode := LibraryGST.CreateHSNSACCode(HSNSAC, GSTGroupCode, HsnSacType::HSN);
        SetStorageGSTJournalText(HSNSACCodeLbl, HSNSACCode);

        if IntraState then begin
            CustomerNo := LibraryGST.CreateCustomerSetup();
            LibraryGSTJournals.UpdateCustomerSetupWithGST(CustomerNo, GSTCustomerType, LocationStateCode, LocPANNo);
            InitializeTaxRateParameters(IntraState, LocationStateCode, LocationStateCode);
        end else begin
            CustomerStateCode := LibraryGST.CreateGSTStateCode();
            CustomerNo := LibraryGST.CreateCustomerSetup();
            LibraryGSTJournals.UpdateCustomerSetupWithGST(CustomerNo, GSTCustomerType, CustomerStateCode, LocPANNo);
            if GSTCustomerType in [GSTCustomerType::Export, GSTCustomerType::"SEZ Unit", GSTCustomerType::"SEZ Development"] then
                InitializeTaxRateParameters(IntraState, '', LocationStateCode)
            else
                InitializeTaxRateParameters(IntraState, CustomerStateCode, LocationStateCode);
        end;
        SetStorageGSTJournalText(CustomerNoLbl, CustomerNo);
        CreateTaxRate();
        LibraryGST.CreateGSTComponentAndPostingSetup(IntraState, LocationStateCode, TaxComponent, GSTComponentCode);
    end;

    local procedure InitializeTaxRateParameters(IntraState: Boolean; FromState: Code[10]; ToState: Code[10]) GSTTaxPercent: Decimal;
    begin
        SetStorageGSTJournalText(FromStateCodeLbl, FromState);
        SetStorageGSTJournalText(ToStateCodeLbl, ToState);
        GSTTaxPercent := LibraryRandom.RandDecInRange(10, 18, 0);
        if IntraState then begin
            ComponentPerArray[1] := (GSTTaxPercent / 2);
            ComponentPerArray[2] := (GSTTaxPercent / 2);
        end else
            ComponentPerArray[4] := GSTTaxPercent;
    end;

    local procedure AssignSalesInvoiceTypeValue(
        var GenJournalLine: Record "Gen. Journal Line";
        ExemptedValue: Boolean; SalesInvociceType:
        Enum "Sales Invoice Type";
        AssignRefInvNo: Boolean)
    var
        LibraryUtility: Codeunit "Library - Utility";
    begin
        GenJournalLine."Sales Invoice Type" := SalesInvociceType;
        GenJournalLine."Old Document No." := GenJournalLine."Document No.";
        GenJournalLine.Exempted := ExemptedValue;
        if AssignRefInvNo then
            GenJournalLine."Reference Invoice No." := LibraryUtility.GenerateRandomCode(GenJournalLine.FieldNo("Reference Invoice No."), Database::"Gen. Journal Line");

        GenJournalLine.Modify(true);
    end;

    local procedure CreateGenJnlLineToGL(
        var GenJournalLine: Record "Gen. Journal Line";
        TemplateType: Enum "Gen. Journal Template Type";
        AccountType: Enum "Gen. Journal Account Type";
        FAEntry: Boolean;
        AssignShiptoAddress: boolean)
    var
        GenJournalTemplate: Record "Gen. Journal Template";
        GenJournalBatch: Record "Gen. Journal Batch";
        ShiptoAddress: Record "Ship-to Address";
        LibraryFixedAsset: codeunit "Library - Fixed Asset";
        LibrarySales: Codeunit "Library - Sales";
        LocationCode: Code[10];
        AccountNo: Code[20];
    begin
        AccountNo := CopyStr(Storage.Get(CustomerNoLbl), 1, 20);
        Evaluate(LocationCode, Storage.Get(LocationCodeLbl));

        if FAEntry then
            AccountNo := LibraryFixedAsset.CreateFixedAssetNo();

        LibraryGSTJournals.CreateGenJournalTemplateBatch(GenJournalTemplate, GenJournalBatch, TemplateType);
        LibraryJournals.CreateGenJournalLine(GenJournalLine,
                                            GenJournalTemplate.Name,
                                            GenJournalBatch.Name,
                                            GenJournalLine."Document Type"::Refund,
                                            AccountType,
                                            AccountNo,
                                            GenJournalLine."Bal. Account Type"::"G/L Account",
                                            LibraryGST.CreateGLAccWithGSTDetails(
                                                VATPostingSetup,
                                                CopyStr(Storage.Get(GSTGroupCodeLbl), 1, 20),
                                                CopyStr(Storage.Get(HSNSACCodeLbl), 1, 10),
                                                true,
                                                StorageBoolean.Get(ExemptedLbl)
                                            ),
                                            LibraryRandom.RandIntInRange(1, 100000));
        GenJournalLine.Validate("Location Code", LocationCode);
        GenJournalLine.Validate("Bal. Gen. Posting Type", GenJournalLine."Bal. Gen. Posting Type"::Sale);

        if AssignShiptoAddress then begin
            LibrarySales.CreateShipToAddress(ShiptoAddress, AccountNo);
            GenJournalLine.Validate("Ship-to Code", ShiptoAddress.Code);
        end;

        GenJournalLine.Modify(true);
    end;

    local procedure SetStorageGSTJournalText(KeyValue: Text[20]; Value: Text[20])
    begin
        Storage.Set(KeyValue, Value);
        LibraryGSTJournals.SetStorageGSTJournalText(Storage);
    end;

    local procedure InitializeShareStep(Exempted: Boolean)
    begin
        StorageBoolean.Set(ExemptedLbl, Exempted);
        LibraryGSTJournals.SetStorageGSTJournalBoolean(StorageBoolean);
    end;

    [ModalPageHandler]
    procedure JournalTemplateHandler(var GeneralJournalTemplateList: TestPage "General Journal Template List")
    begin
        GeneralJournalTemplateList.Filter.SetFilter(Name, Storage.Get(TemplateNameLbl));
        GeneralJournalTemplateList.OK().Invoke();
    end;

    [PageHandler]
    procedure ReferencePageHandler(var UpdateReferenceInvJournals: TestPage "Update Reference Inv. Journals")
    begin
        UpdateReferenceInvJournals."Reference Invoice Nos.".Lookup();
        UpdateReferenceInvJournals."Reference Invoice Nos.".SetValue(Storage.Get(PostedDocumentNoLbl));
        UpdateReferenceInvJournals.Verify.Invoke();
    end;

    [ModalPageHandler]
    procedure CustomerLedgerEntries(var CustomerLedgerEntries: TestPage "Customer Ledger Entries")
    begin
        CustomerLedgerEntries.Filter.SetFilter("Document No.", Storage.Get(PostedDocumentNoLbl));
        CustomerLedgerEntries.OK().Invoke();
    end;

    [PageHandler]
    procedure TaxRatePageHandler(var TaxRates: TestPage "Tax Rates")
    begin
        TaxRates.New();
        TaxRates.AttributeValue1.SetValue(Storage.Get(GSTGroupCodeLbl));
        TaxRates.AttributeValue2.SetValue(Storage.Get(HSNSACCodeLbl));
        TaxRates.AttributeValue3.SetValue(Storage.Get(FromStateCodeLbl));
        TaxRates.AttributeValue4.SetValue(Storage.Get(ToStateCodeLbl));
        TaxRates.AttributeValue5.SetValue(WorkDate());
        TaxRates.AttributeValue6.SetValue(CalcDate('<10Y>', WorkDate()));
        TaxRates.AttributeValue7.SetValue(ComponentPerArray[1]); // SGST
        TaxRates.AttributeValue8.SetValue(ComponentPerArray[2]); // CGST
        TaxRates.AttributeValue9.SetValue(ComponentPerArray[4]); // IGST
        TaxRates.AttributeValue10.SetValue(ComponentPerArray[5]); // KFloodCess
        TaxRates.OK().Invoke();
    end;
}