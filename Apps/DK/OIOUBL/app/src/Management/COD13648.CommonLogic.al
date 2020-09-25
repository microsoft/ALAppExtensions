// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------

codeunit 13648 "OIOUBL-Common Logic"
{
    var
        CompanyInfo: Record "Company Information";
        PaymentTerms: Record "Payment Terms";
        OIOUBLDocumentEncode: Codeunit "OIOUBL-Document Encode";
        XmlNSAttributeCBC: XmlAttribute;
        XmlNSAttributeCAC: XmlAttribute;
        DocNameSpaceCBC: Text[250];
        DocNameSpaceCAC: Text[250];

    procedure InsertOrderReference(var RootElement: XmlElement; ID: Code[35]; SalesOrderID: Code[20]; IssueDate: Date);
    var
        ChildElement: XmlElement;
    begin
        ChildElement := XmlElement.Create('OrderReference', DocNameSpaceCAC);

        ChildElement.Add(XmlElement.Create('ID', DocNameSpaceCBC, ID));
        if SalesOrderID <> '' then
            ChildElement.Add(XmlElement.Create('SalesOrderID', DocNameSpaceCBC, SalesOrderID));
        if IssueDate <> CalcDate('<0D>') then
            ChildElement.Add(XmlElement.Create('IssueDate', DocNameSpaceCBC, OIOUBLDocumentEncode.DateToText(IssueDate)));

        RootElement.Add(ChildElement);
    end;

    local procedure InsertContact(var RootElement: XmlElement; ID: Text; Contact: Record Contact);
    var
        ContactElement: XmlElement;
    begin
        ContactElement := XmlElement.Create('Contact', DocNameSpaceCAC);

        ContactElement.Add(XmlElement.Create('ID', DocNameSpaceCBC, ID));
        ContactElement.Add(XmlElement.Create('Name', DocNameSpaceCBC, Contact.Name));
        ContactElement.Add(XmlElement.Create('Telephone', DocNameSpaceCBC, Contact."Phone No."));
        ContactElement.Add(XmlElement.Create('Telefax', DocNameSpaceCBC, Contact."Fax No."));
        ContactElement.Add(XmlElement.Create('ElectronicMail', DocNameSpaceCBC, Contact."E-Mail"));

        RootElement.Add(ContactElement);
    end;

    local procedure InsertPartyLegalEntity(var PartyElement: XmlElement);
    var
        PartyLegalEntityElement: XmlElement;
    begin
        PartyLegalEntityElement := XmlElement.Create('PartyLegalEntity', DocNameSpaceCAC);

        PartyLegalEntityElement.Add(XmlElement.Create('RegistrationName', DocNameSpaceCBC, CompanyInfo.Name));
        PartyLegalEntityElement.Add(
          XmlElement.Create('CompanyID', DocNameSpaceCBC,
            XmlAttribute.Create('schemeID', 'DK:CVR'),
            OIOUBLDocumentEncode.GetCompanyVATRegNo(CompanyInfo."VAT Registration No.")));

        PartyElement.Add(PartyLegalEntityElement);
    end;

    procedure InsertTaxScheme(var RootElement: XmlElement; SchemeAgencyID: Text)
    var
        TaxSchemeElement: XmlElement;
    begin
        TaxSchemeElement := XmlElement.Create('TaxScheme', DocNameSpaceCAC);

        TaxSchemeElement.Add(
          XmlElement.Create('ID', DocNameSpaceCBC,
            XmlAttribute.Create('schemeID', 'urn:oioubl:id:taxschemeid-1.1'),
            '63'));
        TaxSchemeElement.Add(XmlElement.Create('Name', DocNameSpaceCBC, 'Moms'));

        RootElement.Add(TaxSchemeElement);
    end;

    procedure InsertPartyTaxScheme(var PartyElement: XmlElement);
    var
        PartyTaxSchemeElement: XmlElement;
    begin
        PartyTaxSchemeElement := XmlElement.Create('PartyTaxScheme', DocNameSpaceCAC);

        PartyTaxSchemeElement.Add(
          XmlElement.Create('CompanyID', DocNameSpaceCBC,
            XmlAttribute.Create('schemeID', 'DK:SE'),
            OIOUBLDocumentEncode.GetCompanyVATRegNo(CompanyInfo."VAT Registration No.")));
        InsertTaxScheme(PartyTaxSchemeElement, '320');

        PartyElement.Add(PartyTaxSchemeElement);
    end;

    local procedure InsertCountry(var AddressElement: XmlElement; IdentificationCode: Text);
    var
        CountryElement: XmlElement;
    begin
        CountryElement := XmlElement.Create('Country', DocNameSpaceCAC);
        CountryElement.Add(XmlElement.Create('IdentificationCode', DocNameSpaceCBC, IdentificationCode));
        AddressElement.Add(CountryElement);
    end;

    procedure InsertAddress(var RootElement: XmlElement; ElementName: Text; Address: Record "Standard Address"; InhouseMail: Text);
    var
        AddressElement: XmlElement;
    begin
        AddressElement := XmlElement.Create(ElementName, DocNameSpaceCAC);

        AddressElement.Add(
          XmlElement.Create('AddressFormatCode', DocNameSpaceCBC,
            XmlAttribute.Create('listID', 'urn:oioubl:codelist:addressformatcode-1.1'),
            XmlAttribute.Create('listAgencyID', '320'),
            'StructuredLax'));
        AddressElement.Add(XmlElement.Create('StreetName', DocNameSpaceCBC, Address.Address));
        AddressElement.Add(XmlElement.Create('AdditionalStreetName', DocNameSpaceCBC, Address."Address 2"));
        if InhouseMail <> '' then
            AddressElement.Add(XmlElement.Create('InhouseMail', DocNameSpaceCBC, InhouseMail));
        AddressElement.Add(XmlElement.Create('CityName', DocNameSpaceCBC, Address.City));
        AddressElement.Add(XmlElement.Create('PostalZone', DocNameSpaceCBC, Address."Post Code"));
        InsertCountry(AddressElement,
          OIOUBLDocumentEncode.GetOIOUBLCountryRegionCode(Address."Country/Region Code"));

        RootElement.Add(AddressElement);
    end;

    local procedure InsertPartyName(var PartyElement: XmlElement; Name: Text);
    var
        PartyNameElement: XmlElement;
    begin
        PartyNameElement := XmlElement.Create('PartyName', DocNameSpaceCAC);
        PartyNameElement.Add(XmlElement.Create('Name', DocNameSpaceCBC, Name));
        PartyElement.Add(PartyNameElement);
    end;

    Local procedure InsertPartyIdentification(var PartyElement: XmlElement; ID: Text);
    var
        PartyIdentificationElement: XmlElement;
    begin
        PartyIdentificationElement := XmlElement.Create('PartyIdentification', DocNameSpaceCAC);

        PartyIdentificationElement.Add(XmlElement.Create('ID', DocNameSpaceCBC,
          XmlAttribute.Create('schemeID', 'DK:CVR'),
          ID));

        PartyElement.Add(PartyIdentificationElement);
    end;

    Local procedure InsertSupplierParty(var AccountingSupplierPartyElement: XmlElement; SalespersonCode: Code[20]);
    var
        SalespersonPurchaser: Record "Salesperson/Purchaser";
        CompanyAddress: Record "Standard Address" temporary;
        SalespersonContact: Record Contact;
        PartyElement: XmlElement;
    begin
        PartyElement := XmlElement.Create('Party', DocNameSpaceCAC);

        PartyElement.Add(XmlElement.Create('WebsiteURI', DocNameSpaceCBC, CompanyInfo."Home Page"));
        PartyElement.Add(XmlElement.Create('EndpointID', DocNameSpaceCBC,
          XmlAttribute.Create('schemeID', 'DK:CVR'),
          OIOUBLDocumentEncode.GetCompanyVATRegNo(CompanyInfo."VAT Registration No.")));
        InsertPartyIdentification(PartyElement, OIOUBLDocumentEncode.GetCompanyVATRegNo(CompanyInfo."VAT Registration No."));
        InsertPartyName(PartyElement, CompanyInfo.Name);
        CompanyAddress.CopyFromCompanyInformation(CompanyInfo);
        InsertAddress(PartyElement,
          'PostalAddress',
          CompanyAddress,
          CompanyInfo."E-Mail");
        InsertPartyTaxScheme(PartyElement);
        InsertPartyLegalEntity(PartyElement);
        if SalespersonPurchaser.GET(SalespersonCode) then begin
            SalespersonContact.Name := SalespersonPurchaser.Name;
            SalespersonContact."Phone No." := SalespersonPurchaser."Phone No.";
            SalespersonContact."E-Mail" := SalespersonPurchaser."E-Mail";

            InsertContact(PartyElement,
              SalespersonCode,
              SalespersonContact);
        end;


        AccountingSupplierPartyElement.Add(PartyElement);
    end;

    procedure InsertAccountingSupplierParty(var InvoiceElement: XmlElement; SalespersonCode: Code[20]);
    var
        AccountingSupplierPartyElement: XmlElement;
    begin
        AccountingSupplierPartyElement := XmlElement.Create('AccountingSupplierParty', DocNameSpaceCAC);
        InsertSupplierParty(AccountingSupplierPartyElement, SalespersonCode);
        InvoiceElement.Add(AccountingSupplierPartyElement);
    end;

    Local procedure InsertCustomerParty(var AccountingCustomerParty: XmlElement; GLN: Code[13]; VATRegNo: Text[20]; PartyName: Text[100]; PostalAddress: Record "Standard Address"; PartyContact: Record Contact);
    var
        PartyElement: XmlElement;
    begin
        PartyElement := XmlElement.Create('Party', DocNameSpaceCAC);

        PartyElement.Add(XmlElement.Create('EndpointID', DocNameSpaceCBC,
          XmlAttribute.Create('schemeAgencyID', '9'),
          XmlAttribute.Create('schemeID', 'GLN'),
          GLN));
        InsertPartyIdentification(PartyElement, OIOUBLDocumentEncode.GetCustomerVATRegNoIncCustomerCountryCode(VATRegNo, PostalAddress."Country/Region Code"));
        InsertPartyName(PartyElement, PartyName);
        InsertAddress(PartyElement,
          'PostalAddress',
          PostalAddress,
          '');
        InsertContact(PartyElement,
          PartyContact.Name,
          PartyContact);

        AccountingCustomerParty.Add(PartyElement);
    end;

    procedure InsertAccountingCustomerParty(var InvoiceElement: XmlElement; GLN: Code[13]; VATRegNo: Text[20]; PartyName: Text[100]; PostalAddress: Record "Standard Address"; PartyContact: Record Contact);
    var
        AccountingCustomerParty: XmlElement;
    begin
        AccountingCustomerParty := XmlElement.Create('AccountingCustomerParty', DocNameSpaceCAC);
        InsertCustomerParty(AccountingCustomerParty,
          GLN,
          VATRegNo,
          PartyName,
          PostalAddress,
          PartyContact);
        InvoiceElement.Add(AccountingCustomerParty);
    end;

    local procedure InsertDeliveryLocation(var DeliveryElement: XmlElement; DeliveryAddress: Record "Standard Address");
    var
        DeliveryLocationElement: XmlElement;
    begin
        DeliveryLocationElement := XmlElement.Create('DeliveryLocation', DocNameSpaceCAC);

        InsertAddress(DeliveryLocationElement,
          'Address',
          DeliveryAddress,
          '');

        DeliveryElement.Add(DeliveryLocationElement);
    end;

    procedure InsertDelivery(var InvoiceElement: XmlElement; DeliveryAddress: Record "Standard Address"; ShipmentDate: Date);
    var
        DeliveryElement: XmlElement;
    begin
        DeliveryElement := XmlElement.Create('Delivery', DocNameSpaceCAC);

        if ShipmentDate <> CalcDate('<0D>') then
            DeliveryElement.Add(XmlElement.Create('ActualDeliveryDate', DocNameSpaceCBC,
              OIOUBLDocumentEncode.DateToText(ShipmentDate)));

        InsertDeliveryLocation(DeliveryElement, DeliveryAddress);

        InvoiceElement.Add(DeliveryElement);
    end;

    local procedure InsertFinancialInstution(var RootElement: XmlElement);
    var
        FinancialInstitutionElement: XmlElement;
    begin
        FinancialInstitutionElement := XmlElement.Create('FinancialInstitution', DocNameSpaceCAC);

        if CompanyInfo."SWIFT Code" <> '' then
            FinancialInstitutionElement.Add(XmlElement.Create('ID', DocNameSpaceCBC, CompanyInfo."SWIFT Code"))
        else
            FinancialInstitutionElement.Add(XmlElement.Create('ID', DocNameSpaceCBC, 'null'));
        FinancialInstitutionElement.Add(XmlElement.Create('Name', DocNameSpaceCBC, CompanyInfo."Bank Name"));

        RootElement.Add(FinancialInstitutionElement);
    end;

    local procedure InsertFinancialInstitutionBranch(var RootElement: XmlElement);
    var
        FinancialInstitutionBranchElement: XmlElement;
    begin
        FinancialInstitutionBranchElement := XmlElement.Create(
          'FinancialInstitutionBranch', DocNameSpaceCAC);

        FinancialInstitutionBranchElement.Add(
          XmlElement.Create('ID', DocNameSpaceCBC, CompanyInfo."Bank Branch No."));
        InsertFinancialInstution(FinancialInstitutionBranchElement);

        RootElement.Add(FinancialInstitutionBranchElement);
    end;

    local procedure InsertPayeeFinancialAccount(var PaymentMeansElement: XmlElement);
    var
        PayeeFinancialAccountElement: XmlElement;
    begin
        PayeeFinancialAccountElement := XmlElement.Create('PayeeFinancialAccount', DocNameSpaceCAC);

        PayeeFinancialAccountElement.Add(XmlElement.Create('ID', DocNameSpaceCBC,
          CompanyInfo."Bank Account No."));
        InsertFinancialInstitutionBranch(PayeeFinancialAccountElement);

        PaymentMeansElement.Add(PayeeFinancialAccountElement);
    end;

    procedure InsertPaymentMeans(var InvoiceElement: XmlElement; DueDate: Date);
    var
        PaymentMeansElement: XmlElement;
    begin
        PaymentMeansElement := XmlElement.Create('PaymentMeans', DocNameSpaceCAC);

        PaymentMeansElement.Add(XmlElement.Create('ID', DocNameSpaceCBC, '1'));
        PaymentMeansElement.Add(XmlElement.Create('PaymentMeansCode', DocNameSpaceCBC, '42'));
        PaymentMeansElement.Add(XmlElement.Create('PaymentDueDate', DocNameSpaceCBC,
          OIOUBLDocumentEncode.DateToText(DueDate)));
        PaymentMeansElement.Add(
          XmlElement.Create('PaymentChannelCode', DocNameSpaceCBC,
            XmlAttribute.Create('listAgencyID', '320'),
            XmlAttribute.Create('listID', 'urn:oioubl:codelist:paymentchannelcode-1.1'),
            GetPaymentChannelCode()));
        InsertPayeeFinancialAccount(PaymentMeansElement);

        InvoiceElement.Add(PaymentMeansElement);
    end;

    local procedure InsertPeriod(var RootElement: XmlElement; PeriodName: Text; StartDate: Text; EndDate: Text);
    var
        PeriodElement: XmlElement;
    begin
        PeriodElement := XmlElement.Create(PeriodName, DocNameSpaceCAC);

        if StartDate <> '' then
            PeriodElement.Add(XmlElement.Create('StartDate', DocNameSpaceCBC, StartDate));
        if EndDate <> '' then
            PeriodElement.Add(XmlElement.Create('EndDate', DocNameSpaceCBC, EndDate));

        RootElement.Add(PeriodElement);
    end;

    procedure InsertPaymentTerms(var InvoiceElement: XmlElement; PaymentTermsCode: Code[20]; PmtDiscountPercent: Decimal; CurrencyCode: Code[10]; PmtDiscountDate: Date; DueDate: Date; Amount: Decimal);
    var
        PaymentTermsElement: XmlElement;
    begin
        PaymentTermsElement := XmlElement.Create('PaymentTerms', DocNameSpaceCAC);

        PaymentTermsElement.Add(XmlElement.Create('ID', DocNameSpaceCBC, '1'));
        PaymentTermsElement.Add(XmlElement.Create('PaymentMeansID', DocNameSpaceCBC, '1'));

        if PaymentTerms.GET(PaymentTermsCode) then begin
            PaymentTermsElement.Add(XmlElement.Create('Note', DocNameSpaceCBC, PaymentTerms.Description));
            PaymentTermsElement.Add(XmlElement.Create('SettlementDiscountPercent', DocNameSpaceCBC,
              OIOUBLDocumentEncode.DecimalToText(PmtDiscountPercent)));
        end;
        PaymentTermsElement.Add(
          XmlElement.Create('Amount', DocNameSpaceCBC,
            XmlAttribute.Create('currencyID', CurrencyCode),
            OIOUBLDocumentEncode.DecimalToText(Amount)));
        if PmtDiscountDate <> CalcDate('<0D>') then
            // Invoice->PaymentTerms->SettlementPeriod
            InsertPeriod(PaymentTermsElement, 'SettlementPeriod', '',
              OIOUBLDocumentEncode.DateToText(PmtDiscountDate));
        // Invoice->PaymentTerms->PenaltyPeriod
        InsertPeriod(PaymentTermsElement, 'PenaltyPeriod',
          OIOUBLDocumentEncode.DateToText(DueDate), '');

        InvoiceElement.Add(PaymentTermsElement);
    end;

    local procedure InsertTaxCategory(var RootElement: XmlElement; TaxCategoryID: Text; Percent: Decimal);
    var
        TaxCategoryElement: XmlElement;
    begin
        TaxCategoryElement := XmlElement.Create('TaxCategory', DocNameSpaceCAC);

        TaxCategoryElement.Add(
          XmlElement.Create('ID', DocNameSpaceCBC,
            XmlAttribute.Create('schemeID', 'urn:oioubl:id:taxcategoryid-1.1'),
            XmlAttribute.Create('schemeAgencyID', '320'),
            TaxCategoryID));
        TaxCategoryElement.Add(XmlElement.Create('Percent', DocNameSpaceCBC, OIOUBLDocumentEncode.DecimalToText(Percent)));
        InsertTaxScheme(TaxCategoryElement, '');

        RootElement.Add(TaxCategoryElement);
    end;

    procedure InsertAllowanceCharge(var RootElement: XmlElement; Id: Integer; AllowanceChargeReason: Text; TaxCategoryID: Text[15]; Amount: Decimal; CurrencyCode: Code[10]; Percent: Decimal);
    var
        AllowanceChargeElement: XmlElement;
    begin
        AllowanceChargeElement := XmlElement.Create('AllowanceCharge', DocNameSpaceCAC);

        AllowanceChargeElement.Add(XmlElement.Create('ID', DocNameSpaceCBC, Format(Id)));
        AllowanceChargeElement.Add(XmlElement.Create('ChargeIndicator', DocNameSpaceCBC, 'false'));
        AllowanceChargeElement.Add(XmlElement.Create('AllowanceChargeReason', DocNameSpaceCBC, AllowanceChargeReason));
        AllowanceChargeElement.Add(XmlElement.Create('MultiplierFactorNumeric', DocNameSpaceCBC, '1.000'));
        AllowanceChargeElement.Add(XmlElement.Create('SequenceNumeric', DocNameSpaceCBC, '1'));
        AllowanceChargeElement.Add(
          XmlElement.Create('Amount', DocNameSpaceCBC,
            XmlAttribute.Create('currencyID', CurrencyCode),
            OIOUBLDocumentEncode.DecimalToText(Amount)));
        AllowanceChargeElement.Add(
          XmlElement.Create('BaseAmount', DocNameSpaceCBC,
            XmlAttribute.Create('currencyID', CurrencyCode),
            OIOUBLDocumentEncode.DecimalToText(Amount)));
        // Invoice->AllowanceCharge->TaxCategory
        InsertTaxCategory(AllowanceChargeElement, TaxCategoryID, Percent);

        RootElement.Add(AllowanceChargeElement);
    end;

    procedure InsertTaxSubtotal(var RootElement: XmlElement; VATCalculationType: Option; TaxableAmount: Decimal; TaxAmount: Decimal; VATPercentage: Decimal; CurrencyCode: Code[10]);
    var
        TaxSubtotalElement: XmlElement;
    begin
        TaxSubtotalElement := XmlElement.Create('TaxSubtotal', DocNameSpaceCAC);

        TaxSubtotalElement.Add(
          XmlElement.Create('TaxableAmount', DocNameSpaceCBC,
            XmlAttribute.Create('currencyID', CurrencyCode),
            OIOUBLDocumentEncode.DecimalToText(TaxableAmount)));
        TaxSubtotalElement.Add(
          XmlElement.Create('TaxAmount', DocNameSpaceCBC,
            XmlAttribute.Create('currencyID', CurrencyCode),
            OIOUBLDocumentEncode.DecimalToText(TaxAmount)));
        InsertTaxCategory(TaxSubtotalElement,
          GetTaxCategoryID(VATCalculationType, VATPercentage), VATPercentage);

        RootElement.Add(TaxSubtotalElement);
    end;

    procedure InsertLineTaxTotal(var RootElement: XmlElement; AmountIncludingVAT: Decimal; Amount: Decimal; VATCalculationType: Option; VATPercent: Decimal; CurrencyCode: Code[10]);
    var
        TaxTotalElement: XmlElement;
    begin
        TaxTotalElement := XmlElement.Create('TaxTotal', DocNameSpaceCAC);

        TaxTotalElement.Add(
          XmlElement.Create('TaxAmount', DocNameSpaceCBC,
            XmlAttribute.Create('currencyID', CurrencyCode),
            OIOUBLDocumentEncode.DecimalToText(AmountIncludingVAT - Amount)));
        InsertTaxSubtotal(TaxTotalElement, VATCalculationType,
          Amount, AmountIncludingVAT - Amount, VATPercent, CurrencyCode);

        RootElement.Add(TaxTotalElement);
    end;

    procedure InsertLegalMonetaryTotal(var InvoiceElement: XmlElement; LineAmount: Decimal; TaxAmount: Decimal; TotalAmount: Decimal; TotalInvDiscountAmount: Decimal; CurrencyCode: Code[10])
    var
        LegalMonetaryTotalElement: XmlElement;
    begin
        LegalMonetaryTotalElement := XmlElement.Create('LegalMonetaryTotal', DocNameSpaceCAC);

        LegalMonetaryTotalElement.Add(
          XmlElement.Create('LineExtensionAmount', DocNameSpaceCBC,
            XmlAttribute.Create('currencyID', CurrencyCode),
            OIOUBLDocumentEncode.DecimalToText(LineAmount)));
        LegalMonetaryTotalElement.Add(
          XmlElement.Create('TaxExclusiveAmount', DocNameSpaceCBC,
            XmlAttribute.Create('currencyID', CurrencyCode),
            OIOUBLDocumentEncode.DecimalToText(TaxAmount)));
        LegalMonetaryTotalElement.Add(
          XmlElement.Create('TaxInclusiveAmount', DocNameSpaceCBC,
            XmlAttribute.Create('currencyID', CurrencyCode),
            OIOUBLDocumentEncode.DecimalToText(TotalAmount)));
        if TotalInvDiscountAmount > 0 then
            LegalMonetaryTotalElement.Add(
              XmlElement.Create('AllowanceTotalAmount', DocNameSpaceCBC,
                XmlAttribute.Create('currencyID', CurrencyCode),
                OIOUBLDocumentEncode.DecimalToText(TotalInvDiscountAmount)));
        LegalMonetaryTotalElement.Add(
          XmlElement.Create('PayableAmount', DocNameSpaceCBC,
            XmlAttribute.Create('currencyID', CurrencyCode),
            OIOUBLDocumentEncode.DecimalToText(TotalAmount)));

        InvoiceElement.Add(LegalMonetaryTotalElement);
    end;

    procedure InsertReminderLine(var ReminderElement: XmlElement; ID: integer; Note: Text[100]; Amount: Decimal; CurrencyCode: Code[10]; AccountCode: Code[30]);
    var
        ReminderLineElement: XmlElement;
    begin
        ReminderLineElement := XmlElement.Create('ReminderLine', DocNameSpaceCAC);

        ReminderLineElement.Add(XmlElement.Create('ID', DocNameSpaceCBC, FORMAT(ID)));
        ReminderLineElement.Add(XmlElement.Create('Note', DocNameSpaceCBC, Note));
        if Amount > 0 then
            ReminderLineElement.Add(
              XmlElement.Create('DebitLineAmount', DocNameSpaceCBC,
                XmlAttribute.Create('currencyID', CurrencyCode),
                OIOUBLDocumentEncode.DecimalToText(Amount)));
        if Amount < 0 then
            ReminderLineElement.Add(
              XmlElement.Create('DebitLineAmount', DocNameSpaceCBC,
                XmlAttribute.Create('currencyID', CurrencyCode),
                OIOUBLDocumentEncode.DecimalToText(Amount)));
        ReminderLineElement.Add(XmlElement.Create('AccountingCost', DocNameSpaceCBC, AccountCode));
        ReminderElement.Add(ReminderLineElement);
    end;

    local procedure InsertSellersItemIdentification(var ItemElement: XmlElement; ID: Code[20]);
    var
        SellersItemIdElement: XmlElement;
    begin
        SellersItemIdElement := XmlElement.Create('SellersItemIdentification', DocNameSpaceCAC);

        SellersItemIdElement.Add(
          XmlElement.Create('ID', DocNameSpaceCBC,
            XmlAttribute.Create('schemeID', 'n/a'),
            ID));

        ItemElement.Add(SellersItemIdElement);
    end;

    procedure InsertItem(var RootElement: XmlElement; Description: Text[100]; LineNo: Code[20]);
    var
        ItemElement: XmlElement;
    begin
        ItemElement := XmlElement.Create('Item', DocNameSpaceCAC);

        ItemElement.Add(XmlElement.Create('Description', DocNameSpaceCBC, Description));
        ItemElement.Add(XmlElement.Create('Name', DocNameSpaceCBC,
          COPYSTR(Description, 1, 40)));
        InsertSellersItemIdentification(ItemElement, LineNo);

        RootElement.Add(ItemElement);
    end;

    procedure InsertPrice(var RootElement: XmlElement; UnitPrice: Decimal; UnitOfMeasureCode: Code[10]; CurrencyCode: Code[10]);
    var
        PriceElement: XmlElement;
    begin
        PriceElement := XmlElement.Create('Price', DocNameSpaceCAC);

        PriceElement.Add(
          XmlElement.Create('PriceAmount', DocNameSpaceCBC,
            XmlAttribute.Create('currencyID', CurrencyCode),
            OIOUBLDocumentEncode.DecimalToText(UnitPrice)));
        PriceElement.Add(
          XmlElement.Create('BaseQuantity', DocNameSpaceCBC,
            XmlAttribute.Create('unitCode', OIOUBLDocumentEncode.GetUoMCode(UnitOfMeasureCode)),
            '1'));
        RootElement.Add(PriceElement);
    end;

    procedure GetPaymentChannelCode(): Text;
    begin
        exit(CompanyInfo.GetOIOUBLPaymentChannelCode());
    end;

    procedure GetInvoiceHeader(): Text;
    begin
        exit('<?xml version="1.0" encoding="UTF-8" ?>' +
        '<Invoice xsi:schemaLocation="urn:oasis:names:specification:ubl:schema:xsd:Invoice-2 UBL-Invoice-2.0.xsd" ' +
        'xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance" xmlns="urn:oasis:names:specification:ubl:schema:xsd:Invoice-2" ' +
        'xmlns:cac="urn:oasis:names:specification:ubl:schema:xsd:CommonAggregateComponents-2" ' +
        'xmlns:cbc="urn:oasis:names:specification:ubl:schema:xsd:CommonBasicComponents-2" ' +
        'xmlns:ccts="urn:oasis:names:specification:ubl:schema:xsd:CoreComponentParameters-2" ' +
        'xmlns:sdt="urn:oasis:names:specification:ubl:schema:xsd:SpecializedDatatypes-2" ' +
        'xmlns:udt="urn:un:unece:uncefact:data:specification:UnqualifiedDataTypesSchemaModule:2"/>');
    end;

    procedure GetReminderHeader(): Text;
    begin
        exit('<?xml version="1.0" encoding="UTF-8" ?>' +
          '<Reminder xmlns="urn:oasis:names:specification:ubl:schema:xsd:Reminder-2" ' +
          'xmlns:cac="urn:oasis:names:specification:ubl:schema:xsd:CommonAggregateComponents-2" ' +
          'xmlns:cbc="urn:oasis:names:specification:ubl:schema:xsd:CommonBasicComponents-2" ' +
          'xmlns:ccts="urn:oasis:names:specification:ubl:schema:xsd:CoreComponentParameters-2" ' +
          'xmlns:sdt="urn:oasis:names:specification:ubl:schema:xsd:SpecializedDatatypes-2" ' +
          'xmlns:udt="urn:un:unece:uncefact:data:specification:UnqualifiedDataTypesSchemaModule:2" ' +
          'xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance" ' +
          'xsi:schemaLocation="urn:oasis:names:specification:ubl:schema:xsd:Reminder-2 UBL-Reminder-2.0.xsd"/> ');
    end;

    procedure GetCrMemoHeader(): Text;
    begin
        exit('<?xml version="1.0" encoding="UTF-8" ?>' +
          '<CreditNote xsi:schemaLocation="urn:oasis:names:specification:ubl:schema:xsd:CreditNote-2 UBL-CreditNote-2.0.xsd" ' +
          'xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance"  ' +
          'xmlns="urn:oasis:names:specification:ubl:schema:xsd:CreditNote-2" ' +
          'xmlns:cac="urn:oasis:names:specification:ubl:schema:xsd:CommonAggregateComponents-2" ' +
          'xmlns:cbc="urn:oasis:names:specification:ubl:schema:xsd:CommonBasicComponents-2" ' +
          'xmlns:ccts="urn:oasis:names:specification:ubl:schema:xsd:CoreComponentParameters-2" ' +
          'xmlns:sdt="urn:oasis:names:specification:ubl:schema:xsd:SpecializedDatatypes-2" ' +
          'xmlns:udt="urn:un:unece:uncefact:data:specification:UnqualifiedDataTypesSchemaModule:2"/> ');
    end;

    procedure GetTaxCategoryID(Type: Option "Normal VAT","Reverse Charge VAT","Full VAT","Sales Tax"; VATPercent: Decimal): Text[15];
    begin
        case Type of
            Type::"Normal VAT":
                begin
                    if VATPercent <> 0 then
                        exit('StandardRated');
                    exit('ZeroRated');
                end;
            Type::"Full VAT":
                exit('StandardRated');
            Type::"Reverse Charge VAT":
                exit('ReverseCharge');
            else
                exit('ZeroRated');
        end;
    end;

    procedure init(var XmlNameSpaceCBC: Text[250]; var XmlNameSpaceCAC: Text[250]);
    begin
        CompanyInfo.get();

        DocNameSpaceCBC := 'urn:oasis:names:specification:ubl:schema:xsd:CommonBasicComponents-2';
        DocNameSpaceCAC := 'urn:oasis:names:specification:ubl:schema:xsd:CommonAggregateComponents-2';

        XmlNSAttributeCBC := XmlAttribute.CreateNamespaceDeclaration('cbc', DocNameSpaceCBC);
        XmlNSAttributeCAC := XmlAttribute.CreateNamespaceDeclaration('cac', DocNameSpaceCAC);

        XmlNameSpaceCBC := DocNameSpaceCBC;
        XmlNameSpaceCAC := DocNameSpaceCAC;
    end;

}