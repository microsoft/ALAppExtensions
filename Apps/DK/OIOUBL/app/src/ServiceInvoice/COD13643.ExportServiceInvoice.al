// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------

codeunit 13643 "OIOUBL-Export Service Invoice"
{
    TableNo = "Record Export Buffer";
    Permissions = tabledata "Service Invoice Header" = rm;

    var
        CompanyInfo: Record "Company Information";
        GLSetup: Record "General Ledger Setup";
        Currency: Record "Currency";
        ServiceMgtSetup: Record "Service Mgt. Setup";
        OIOUBLXMLGenerator: Codeunit "OIOUBL-Common Logic";
        OIOUBLDocumentEncode: Codeunit "OIOUBL-Document Encode";
        CompanyInfoRead: Boolean;
        GLSetupRead: Boolean;
        DocNameSpace: Text[250];
        DocNameSpace2: Text[250];

    trigger OnRun();
    var
        ServiceInvoiceHeader: Record "Service Invoice Header";
        RecordRef: RecordRef;
    begin
        RecordRef.Get(RecordID);
        RecordRef.SetTable(ServiceInvoiceHeader);

        ServerFilePath := CreateXML(ServiceInvoiceHeader);
        Modify();

        ServiceInvoiceHeader."OIOUBL-Electronic Invoice Created" := true;
        ServiceInvoiceHeader.Modify();

        Codeunit.Run(Codeunit::"Service Inv.-Printed", ServiceInvoiceHeader);
    end;

    procedure ExportXML(ServiceInvoiceHeader: Record "Service Invoice Header")
    var
        ServInvHeader2: Record "Service Invoice Header";
        RecordExportBuffer: Record "Record Export Buffer";
        ElectronicDocumentFormat: Record "Electronic Document Format";
        RBMgt: Codeunit "File Management";
        OIOUBLManagement: Codeunit "OIOUBL-Management";
        EnvironmentInfo: Codeunit "Environment Information";
        FromFile: Text[1024];
        DocumentType: Option "Quote","Order","Invoice","Credit Memo";
    begin
        FromFile := CreateXML(ServiceInvoiceHeader);

        ServiceMgtSetup.Get();

        if RBMgt.IsLocalFileSystemAccessible() and not EnvironmentInfo.IsSaaS() then
            ServiceMgtSetup.OIOUBLVerifyAndSetPath(DocumentType::Invoice);

        OIOUBLManagement.UpdateRecordExportBuffer(
            ServiceInvoiceHeader.RecordId(),
            CopyStr(FromFile, 1, MaxStrLen(RecordExportBuffer.ServerFilePath)),
            ElectronicDocumentFormat.GetAttachmentFileName(ServiceInvoiceHeader."No.", 'Invoice', 'xml'));

        OIOUBLManagement.ExportXMLFile(ServiceInvoiceHeader."No.", FromFile, ServiceMgtSetup."OIOUBL-Service Invoice Path");

        ServInvHeader2.Get(ServiceInvoiceHeader."No.");
        ServInvHeader2."OIOUBL-Electronic Invoice Created" := true;
        ServInvHeader2.Modify();

        Codeunit.Run(Codeunit::"Service Inv.-Printed", ServInvHeader2);
    end;

    local procedure InsertOrderReference(var RootElement: XmlElement; ID: Code[35]; CustomerReference: Code[20]);
    var
        ChildElement: XmlElement;
    begin
        ChildElement := XmlElement.Create('OrderReference', DocNameSpace2);

        ChildElement.Add(XmlElement.Create('ID', DocNameSpace, ID));
        if CustomerReference <> '' then
            ChildElement.Add(XmlElement.Create('CustomerReference', DocNameSpace, CustomerReference));

        RootElement.Add(ChildElement);
    end;

    local procedure InsertInvoiceTaxTotal(var InvoiceElement: XmlElement; var ServiceInvoiceLine: Record "Service Invoice Line"; TotalTaxAmount: Decimal; CurrencyCode: Code[10]);
    var
        TaxTotalElement: XmlElement;
        TaxableAmount: Decimal;
        TaxAmount: Decimal;
        VATPercentage: Decimal;
    begin
        TaxTotalElement := XmlElement.Create('TaxTotal', DocNameSpace2);

        TaxTotalElement.Add(
          XmlElement.Create('TaxAmount', DocNameSpace,
            XmlAttribute.Create('currencyID', CurrencyCode),
            OIOUBLDocumentEncode.DecimalToText(TotalTaxAmount)));

        // Invoice->TaxTotal (for ("Normal VAT" AND "VAT %" <> 0) OR "Full VAT")
        ServiceInvoiceLine.SETFILTER(
          "VAT Calculation Type", '%1|%2',
          ServiceInvoiceLine."VAT Calculation Type"::"Normal VAT",
          ServiceInvoiceLine."VAT Calculation Type"::"Full VAT");
        if ServiceInvoiceLine.FINDFIRST() then begin
            TaxableAmount := 0;
            TaxAmount := 0;
            ServiceInvoiceLine.SETFILTER("VAT %", '<>0');
            if ServiceInvoiceLine.FINDSET() then begin
                VATPercentage := ServiceInvoiceLine."VAT %";
                repeat
                    UpdateTaxAmtAndTaxableAmt(ServiceInvoiceLine.Amount, ServiceInvoiceLine."Amount Including VAT", TaxableAmount, TaxAmount);
                until ServiceInvoiceLine.NEXT() = 0;
                OIOUBLXMLGenerator.InsertTaxSubtotal(TaxTotalElement, ServiceInvoiceLine."VAT Calculation Type", TaxableAmount, TaxAmount, VATPercentage, CurrencyCode);
            end;

            TaxableAmount := 0;
            TaxAmount := 0;
            ServiceInvoiceLine.SETRANGE("VAT %", 0);
            if ServiceInvoiceLine.FINDSET() then begin
                VATPercentage := ServiceInvoiceLine."VAT %";
                repeat
                    UpdateTaxAmtAndTaxableAmt(ServiceInvoiceLine.Amount, ServiceInvoiceLine."Amount Including VAT", TaxableAmount, TaxAmount);
                until ServiceInvoiceLine.NEXT() = 0;
                // Invoice->TaxTotal->TaxSubtotal
                OIOUBLXMLGenerator.InsertTaxSubtotal(TaxTotalElement, ServiceInvoiceLine."VAT Calculation Type", TaxableAmount, TaxAmount, VATPercentage, CurrencyCode);
            end;
        end;

        // Invoice->TaxTotal (for "Reverse Charge VAT")
        ServiceInvoiceLine.SETRANGE("VAT %");
        ServiceInvoiceLine.SETRANGE("VAT Calculation Type", ServiceInvoiceLine."VAT Calculation Type"::"Reverse Charge VAT");
        if ServiceInvoiceLine.FINDSET() then begin
            TaxableAmount := 0;
            TaxAmount := 0;
            VATPercentage := ServiceInvoiceLine."VAT %";
            repeat
                UpdateTaxAmtAndTaxableAmt(ServiceInvoiceLine.Amount, ServiceInvoiceLine."Amount Including VAT", TaxableAmount, TaxAmount);
            until ServiceInvoiceLine.NEXT() = 0;
            OIOUBLXMLGenerator.InsertTaxSubtotal(TaxTotalElement, ServiceInvoiceLine."VAT Calculation Type", TaxableAmount, TaxAmount, VATPercentage, CurrencyCode);
        end;

        InvoiceElement.Add(TaxTotalElement);
    end;

    local procedure InsertOrderLineReference(var InvoiceLineElement: XmlElement; ServiceInvoiceHeader: Record "Service Invoice Header"; ServiceInvoiceLine: Record "Service Invoice Line");
    var
        OrderLineReferenceElement: XmlElement;
    begin
        OrderLineReferenceElement := XmlElement.Create('OrderLineReference', DocNameSpace2);
        OrderLineReferenceElement.Add(XmlElement.Create('LineID', DocNameSpace,
          FORMAT(ServiceInvoiceLine."Line No.")));
        InsertOrderReference(OrderLineReferenceElement,
          ServiceInvoiceHeader."Your Reference", '');
        InvoiceLineElement.Add(OrderLineReferenceElement);
    end;

    local procedure InsertInvoiceLine(var InvoiceElement: XmlElement; ServiceInvoiceHeader: Record "Service Invoice Header"; ServiceInvoiceLine: Record "Service Invoice Line"; CurrencyCode: Code[10]; UnitOfMeasureCode: Code[10])
    var
        InvoiceLineElement: XmlElement;
    begin
        InvoiceLineElement := XmlElement.Create('InvoiceLine', DocNameSpace2);

        InvoiceLineElement.Add(XmlElement.Create('ID', DocNameSpace, FORMAT(ServiceInvoiceLine."Line No.")));
        InvoiceLineElement.Add(
          XmlElement.Create('InvoicedQuantity', DocNameSpace,
            XmlAttribute.Create('unitCode', OIOUBLDocumentEncode.GetUoMCode(UnitOfMeasureCode)),
            OIOUBLDocumentEncode.DecimalToText(ServiceInvoiceLine.Quantity)));
        InvoiceLineElement.Add(
          XmlElement.Create('LineExtensionAmount', DocNameSpace,
            XmlAttribute.Create('currencyID', CurrencyCode),
            OIOUBLDocumentEncode.DecimalToText(ServiceInvoiceLine.Amount + ServiceInvoiceLine."Inv. Discount Amount")));
        InvoiceLineElement.Add(XmlElement.Create('AccountingCost', DocNameSpace, ServiceInvoiceLine."OIOUBL-Account Code"));
        InsertOrderLineReference(InvoiceLineElement, ServiceInvoiceHeader, ServiceInvoiceLine);

        OIOUBLXMLGenerator.InsertLineTaxTotal(
          InvoiceLineElement,
          ServiceInvoiceLine."Amount Including VAT",
          ServiceInvoiceLine.Amount,
          ServiceInvoiceLine."VAT Calculation Type",
          ServiceInvoiceLine."VAT %",
          CurrencyCode);
        OIOUBLXMLGenerator.InsertItem(InvoiceLineElement, ServiceInvoiceLine.Description, ServiceInvoiceLine."No.");
        OIOUBLXMLGenerator.InsertPrice(
            InvoiceLineElement,
            Round((ServiceInvoiceLine.Amount + ServiceInvoiceLine."Inv. Discount Amount") / ServiceInvoiceLine.Quantity),
            UnitOfMeasureCode, CurrencyCode);

        InvoiceElement.Add(InvoiceLineElement);
    end;

    local procedure CreateXML(ServiceInvoiceHeader: Record "Service Invoice Header") FromFile: Text[250]
    var
        ServInvLine: Record "Service Invoice Line";
        ServInvLine2: Record "Service Invoice Line";
        OIOUBLProfile: Record "OIOUBL-Profile";
        DeliveryAddress: Record "Standard Address";
        BillToAddress: Record "Standard Address";
        CustomerContact: Record Contact;
        RBMgt: Codeunit "File Management";
        PEPPOLManagement: Codeunit "PEPPOL Management";
        XMLCurrNode: XmlElement;
        XMLdocOut: XmlDocument;
        CurrencyCode: Code[10];
        UnitOfMeasureCode: Code[10];
        LineAmount: Decimal;
        TaxAmount: Decimal;
        TotalAmount: Decimal;
        TotalInvDiscountAmount: Decimal;
        TotalTaxAmount: Decimal;
        OutputFile: File;
        FileOutstream: Outstream;
    begin
        CODEUNIT.RUN(CODEUNIT::"OIOUBL-Check Service Invoice", ServiceInvoiceHeader);
        ReadGLSetup();
        ReadCompanyInfo();

        if ServiceInvoiceHeader."Currency Code" = '' then
            CurrencyCode := GLSetup."LCY Code"
        else
            CurrencyCode := ServiceInvoiceHeader."Currency Code";

        ServInvLine.SETRANGE("Document No.", ServiceInvoiceHeader."No.");
        ServInvLine.SETFILTER(Type, '>%1', 0);
        ServInvLine.SETFILTER("No.", '<>%1', ' ');
        if NOT ServInvLine.FINDSET() then
            EXIT;

        FromFile := CopyStr(RBMgt.ServerTempFileName(''), 1, MaxStrLen(FromFile));

        // Invoice
        XmlDocument.ReadFrom(OIOUBLXMLGenerator.GetInvoiceHeader(), XMLdocOut);
        XMLdocOut.GetRoot(XMLCurrNode);

        OIOUBLXMLGenerator.init(DocNameSpace, DocNameSpace2);

        XMLCurrNode.Add(XmlElement.Create('UBLVersionID', DocNameSpace, '2.0'));
        XMLCurrNode.Add(XmlElement.Create('CustomizationID', DocNameSpace, 'OIOUBL-2.02'));

        XMLCurrNode.Add(
          XmlElement.Create('ProfileID', DocNameSpace,
            XmlAttribute.Create('schemeID', 'urn:oioubl:id:profileid-1.2'),
            XmlAttribute.Create('schemeAgencyID', '320'),
            OIOUBLProfile.GetOIOUBLProfileID(ServiceInvoiceHeader."OIOUBL-Profile Code", ServiceInvoiceHeader."Customer No.")));

        XMLCurrNode.Add(XmlElement.Create('ID', DocNameSpace, ServiceInvoiceHeader."No."));
        XMLCurrNode.Add(XmlElement.Create('CopyIndicator', DocNameSpace,
          OIOUBLDocumentEncode.BooleanToText(ServiceInvoiceHeader."OIOUBL-Electronic Invoice Created")));
        XMLCurrNode.Add(XmlElement.Create('IssueDate', DocNameSpace,
          OIOUBLDocumentEncode.DateToText(ServiceInvoiceHeader."Posting Date")));

        XMLCurrNode.Add(XmlElement.Create('InvoiceTypeCode', DocNameSpace,
          XmlAttribute.Create('listID', 'urn:oioubl:codelist:invoicetypecode-1.1'),
          XmlAttribute.Create('listAgencyID', '320'),
          '380'));

        XMLCurrNode.Add(XmlElement.Create('DocumentCurrencyCode', DocNameSpace, CurrencyCode));
        XMLCurrNode.Add(XmlElement.Create('AccountingCostCode', DocNameSpace, ServiceInvoiceHeader."OIOUBL-Account Code"));

        with ServiceInvoiceHeader do begin
            // Invoice->OrderReference
            if "Order No." <> '' then
                InsertOrderReference(XMLCurrNode,
                  "Your Reference",
                  "Order No.")
            else
                InsertOrderReference(XMLCurrNode,
                  "Your Reference",
                  "Pre-Assigned No.");

            // Invoice->AccountingSupplierParty
            OIOUBLXMLGenerator.InsertAccountingSupplierParty(XMLCurrNode, "Salesperson Code");

            // Invoice->AccountingCustomerParty
            BillToAddress.Address := "Bill-to Address";
            BillToAddress."Address 2" := "Bill-to Address 2";
            BillToAddress.City := "Bill-to City";
            BillToAddress."Post Code" := "Bill-to Post Code";
            BillToAddress."Country/Region Code" := "Bill-to Country/Region Code";
            CustomerContact.Name := "Contact Name";
            CustomerContact."Phone No." := "Phone No.";
            CustomerContact."Fax No." := "Fax No.";
            CustomerContact."E-Mail" := "E-Mail";
            OIOUBLXMLGenerator.InsertAccountingCustomerParty(XMLCurrNode,
              "OIOUBL-GLN",
              "VAT Registration No.",
              "Bill-to Name",
              BillToAddress,
              CustomerContact);

            // Invoice->Delivery
            DeliveryAddress.Address := "Ship-to Address";
            DeliveryAddress."Address 2" := "Ship-to Address 2";
            DeliveryAddress.City := "Ship-to City";
            DeliveryAddress."Post Code" := "Ship-to Post Code";
            DeliveryAddress."Country/Region Code" := "Ship-to Country/Region Code";
            OIOUBLXMLGenerator.InsertDelivery(XMLCurrNode, DeliveryAddress, CalcDate('<0D>'));

            // Invoice->PaymentMeans
            OIOUBLXMLGenerator.InsertPaymentMeans(XMLCurrNode, "Due Date");

            // Invoice->PaymentTerms
            ServInvLine2.RESET();
            ServInvLine2.COPY(ServInvLine);
            ServInvLine2.SETRANGE(Type);
            ServInvLine2.SETRANGE("No.");
            ServInvLine2.SETRANGE(Quantity);
            ServInvLine2.CALCSUMS(Amount, "Amount Including VAT", "Inv. Discount Amount");
            OIOUBLXMLGenerator.InsertPaymentTerms(XMLCurrNode,
              "Payment Terms Code",
              "Payment Discount %",
              CurrencyCode,
              "Pmt. Discount Date",
              "Due Date",
              ServInvLine2."Amount Including VAT");

            TotalInvDiscountAmount := 0;
            if ServInvLine2.FINDSET() then
                repeat
                    ExcludeVAT(ServInvLine2, "Prices Including VAT");
                    TotalInvDiscountAmount += ServInvLine2."Inv. Discount Amount";
                until ServInvLine2.NEXT() = 0;
        end;

        // Invoice->AllowanceCharge
        if TotalInvDiscountAmount > 0 then
            OIOUBLXMLGenerator.InsertAllowanceCharge(XMLCurrNode, 1, 'Rabat',
              OIOUBLXMLGenerator.GetTaxCategoryID(ServInvLine2."VAT Calculation Type", ServInvLine2."VAT %"),
              TotalInvDiscountAmount, CurrencyCode, 0);

        // Invoice->TaxTotal
        ServInvLine2.RESET();
        ServInvLine2.COPY(ServInvLine);
        ServInvLine2.SETFILTER(
          "VAT Calculation Type", '%1|%2|%3',
          ServInvLine2."VAT Calculation Type"::"Normal VAT",
          ServInvLine2."VAT Calculation Type"::"Full VAT",
          ServInvLine2."VAT Calculation Type"::"Reverse Charge VAT");
        if ServInvLine2.FINDFIRST() then begin
            TotalTaxAmount := 0;
            ServInvLine2.CALCSUMS(Amount, "Amount Including VAT");
            TotalTaxAmount := ServInvLine2."Amount Including VAT" - ServInvLine2.Amount;

            InsertInvoiceTaxTotal(XMLCurrNode, ServInvLine2, TotalTaxAmount, CurrencyCode);
        end;

        // Invoice->LegalMonetaryTotal
        LineAmount := 0;
        TaxAmount := 0;

        ServInvLine2.RESET();
        ServInvLine2.COPY(ServInvLine);
        if ServInvLine2.FINDSET() then
            repeat
                ExcludeVAT(ServInvLine2, ServiceInvoiceHeader."Prices Including VAT");
                LineAmount += ServInvLine2.Amount + ServInvLine2."Inv. Discount Amount";
                TotalAmount += ServInvLine2."Amount Including VAT";
                TaxAmount += ServInvLine2."Amount Including VAT" - ServInvLine2.Amount;
            until ServInvLine2.NEXT() = 0;

        OIOUBLXMLGenerator.InsertLegalMonetaryTotal(XMLCurrNode, LineAmount, TaxAmount, TotalAmount, TotalInvDiscountAmount, CurrencyCode);

        // Invoice->InvoiceLine
        repeat
            ServInvLine.TESTFIELD(Description);

            if (ServInvLine.Type = ServInvLine.Type::"G/L Account") and (ServInvLine."Unit of Measure Code" = '') then
                UnitOfMeasureCode := PEPPOLManagement.GetUoMforPieceINUNECERec20ListID()
            else
                UnitOfMeasureCode := ServInvLine."Unit of Measure Code";

            ExcludeVAT(ServInvLine, ServiceInvoiceHeader."Prices Including VAT");
            InsertInvoiceLine(XMLCurrNode, ServiceInvoiceHeader, ServInvLine, CurrencyCode, UnitOfMeasureCode);
        until ServInvLine.NEXT() = 0;

        OutputFile.Create(FromFile);
        OutputFile.CreateOutStream(FileOutstream);
        OnCreateXMLOnBeforeXmlDocumentWriteToFileStream(XMLdocOut, ServiceInvoiceHeader, DocNameSpace, DocNameSpace2);
        XMLdocOut.WriteTo(FileOutstream);
        OutputFile.Close();
    end;

    procedure ReadCompanyInfo();
    begin
        if NOT CompanyInfoRead then begin
            CompanyInfo.GET();
            CompanyInfoRead := TRUE;
        end;
    end;

    procedure ReadGLSetup();
    begin
        if NOT GLSetupRead then begin
            GLSetup.GET();
            GLSetupRead := TRUE;
        end;
    end;

    procedure GetPaymentChannelCode(): Text;
    begin
        exit(CompanyInfo.GetOIOUBLPaymentChannelCode());
    end;

    procedure UpdateTaxAmtAndTaxableAmt(Amount: Decimal; AmountIncludingVAT: Decimal; var TaxableAmountParam: Decimal; var TaxAmountParam: Decimal);
    begin
        TaxableAmountParam := TaxableAmountParam + Amount;
        TaxAmountParam := TaxAmountParam + AmountIncludingVAT - Amount;
    end;

    procedure ExcludeVAT(var ServInvLine: Record "Service Invoice Line"; PricesInclVAT: Boolean);
    var
        ExclVATFactor: Decimal;
    begin
        if NOT PricesInclVAT then
            EXIT;
        WITH ServInvLine do begin
            ExclVATFactor := 1 + "VAT %" / 100;
            "Line Discount Amount" := ROUND("Line Discount Amount" / ExclVATFactor, Currency."Amount Rounding Precision");
            "Inv. Discount Amount" := ROUND("Inv. Discount Amount" / ExclVATFactor, Currency."Amount Rounding Precision");
            "Unit Price" := ROUND("Unit Price" / ExclVATFactor, Currency."Amount Rounding Precision");
        end;
    end;

    [IntegrationEvent(false, false)]
    local procedure OnCreateXMLOnBeforeXmlDocumentWriteToFileStream(var XMLdocOut: XmlDocument; ServiceInvoiceHeader: Record "Service Invoice Header"; DocNameSpace: Text[250]; DocNameSpace2: Text[250])
    begin
    end;
}