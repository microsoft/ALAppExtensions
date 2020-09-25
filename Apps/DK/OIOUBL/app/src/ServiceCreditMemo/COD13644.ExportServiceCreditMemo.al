// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------

codeunit 13644 "OIOUBL-Export Service Cr.Memo"
{
    TableNo = "Record Export Buffer";
    Permissions = tabledata "Service Cr.Memo Header" = rm;

    var
        CompanyInfo: Record "Company Information";
        GLSetup: Record "General Ledger Setup";
        ServiceSetup: Record "Service Mgt. Setup";
        Currency: Record Currency;
        OIOUBLDocumentEncode: Codeunit "OIOUBL-Document Encode";
        OIOUBLXMLGenerator: Codeunit "OIOUBL-Common Logic";
        DocNameSpace: Text[250];
        DocNameSpace2: Text[250];
        CompanyInfoRead: Boolean;
        GLSetupRead: Boolean;

    trigger OnRun()
    var
        ServiceCrMemoHeader: Record "Service Cr.Memo Header";
        RecordRef: RecordRef;
    begin
        RecordRef.Get(RecordID);
        RecordRef.SetTable(ServiceCrMemoHeader);

        ServerFilePath := CreateXML(ServiceCrMemoHeader);
        Modify();

        ServiceCrMemoHeader."OIOUBL-Electronic Credit Memo Created" := true;
        ServiceCrMemoHeader.Modify();

        Codeunit.Run(Codeunit::"Service Cr. Memo-Printed", ServiceCrMemoHeader);
    end;

    procedure ExportXML(ServiceCrMemoHeader: Record "Service Cr.Memo Header")
    var
        ServiceCrMemoHeader2: Record "Service Cr.Memo Header";
        RecordExportBuffer: Record "Record Export Buffer";
        ElectronicDocumentFormat: Record "Electronic Document Format";
        RBMgt: Codeunit "File Management";
        OIOUBLManagement: Codeunit "OIOUBL-Management";
        EnvironmentInfo: Codeunit "Environment Information";
        FromFile: Text[1024];
        DocumentType: Option "Quote","Order","Invoice","Credit Memo","Blanket Order","Return Order","Finance Charge","Reminder";
    begin
        FromFile := CreateXML(ServiceCrMemoHeader);

        ServiceSetup.Get();

        if RBMgt.IsLocalFileSystemAccessible() and not EnvironmentInfo.IsSaaS() then
            ServiceSetup.OIOUBLVerifyAndSetPath(DocumentType::"Credit Memo");

        OIOUBLManagement.UpdateRecordExportBuffer(
            ServiceCrMemoHeader.RecordId(),
            CopyStr(FromFile, 1, MaxStrLen(RecordExportBuffer.ServerFilePath)),
            ElectronicDocumentFormat.GetAttachmentFileName(ServiceCrMemoHeader."No.", 'Credit Memo', 'xml'));

        OIOUBLManagement.ExportXMLFile(ServiceCrMemoHeader."No.", FromFile, ServiceSetup."OIOUBL-Service Cr. Memo Path");

        ServiceCrMemoHeader2.Get(ServiceCrMemoHeader."No.");
        ServiceCrMemoHeader2."OIOUBL-Electronic Credit Memo Created" := true;
        ServiceCrMemoHeader2.Modify();

        Codeunit.Run(Codeunit::"Service Cr. Memo-Printed", ServiceCrMemoHeader2);
    end;

    local procedure InsertDiscrepancyResponse(var CrMemoElement: XmlElement);
    var
        DiscrepancyResponseElement: XmlElement;
    begin
        DiscrepancyResponseElement := XmlElement.Create('DiscrepancyResponse', DocNameSpace2);

        DiscrepancyResponseElement.Add(XmlElement.Create('ReferenceID', DocNameSpace, '1'));
        DiscrepancyResponseElement.Add(XmlElement.Create('Description', DocNameSpace, 'Kreditnota if?lge aftale'));

        CrMemoElement.Add(DiscrepancyResponseElement);
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

    local procedure InsertCrMemoTaxTotal(var CrMemoElement: XmlElement; var ServiceCrMemoLine: Record "Service Cr.Memo Line"; TotalTaxAmount: Decimal; CurrencyCode: Code[10]);
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

        // CrMemo->TaxTotal (for ("Normal VAT" AND "VAT %" <> 0) OR "Full VAT")
        ServiceCrMemoLine.SETFILTER(
          "VAT Calculation Type", '%1|%2',
          ServiceCrMemoLine."VAT Calculation Type"::"Normal VAT",
          ServiceCrMemoLine."VAT Calculation Type"::"Full VAT");
        if ServiceCrMemoLine.FINDFIRST() then begin
            TaxableAmount := 0;
            TaxAmount := 0;
            ServiceCrMemoLine.SETFILTER("VAT %", '<>0');
            if ServiceCrMemoLine.FINDSET() then begin
                VATPercentage := ServiceCrMemoLine."VAT %";
                repeat
                    UpdateTaxAmtAndTaxableAmt(ServiceCrMemoLine.Amount, ServiceCrMemoLine."Amount Including VAT", TaxableAmount, TaxAmount);
                until ServiceCrMemoLine.NEXT() = 0;
                OIOUBLXMLGenerator.InsertTaxSubtotal(TaxTotalElement, ServiceCrMemoLine."VAT Calculation Type", TaxableAmount, TaxAmount, VATPercentage, CurrencyCode);
            end;

            TaxableAmount := 0;
            TaxAmount := 0;
            ServiceCrMemoLine.SETRANGE("VAT %", 0);
            if ServiceCrMemoLine.FINDSET() then begin
                VATPercentage := ServiceCrMemoLine."VAT %";
                repeat
                    UpdateTaxAmtAndTaxableAmt(ServiceCrMemoLine.Amount, ServiceCrMemoLine."Amount Including VAT", TaxableAmount, TaxAmount);
                until ServiceCrMemoLine.NEXT() = 0;
                // CrMemo->TaxTotal->TaxSubtotal
                OIOUBLXMLGenerator.InsertTaxSubtotal(TaxTotalElement, ServiceCrMemoLine."VAT Calculation Type", TaxableAmount, TaxAmount, VATPercentage, CurrencyCode);
            end;
        end;

        // CrMemo->TaxTotal (for "Reverse Charge VAT")
        ServiceCrMemoLine.SETRANGE("VAT %");
        ServiceCrMemoLine.SETRANGE("VAT Calculation Type", ServiceCrMemoLine."VAT Calculation Type"::"Reverse Charge VAT");
        if ServiceCrMemoLine.FINDSET() then begin
            TaxableAmount := 0;
            TaxAmount := 0;
            VATPercentage := ServiceCrMemoLine."VAT %";
            repeat
                UpdateTaxAmtAndTaxableAmt(ServiceCrMemoLine.Amount, ServiceCrMemoLine."Amount Including VAT", TaxableAmount, TaxAmount);
            until ServiceCrMemoLine.NEXT() = 0;
            OIOUBLXMLGenerator.InsertTaxSubtotal(TaxTotalElement, ServiceCrMemoLine."VAT Calculation Type", TaxableAmount, TaxAmount, VATPercentage, CurrencyCode);
        end;

        CrMemoElement.Add(TaxTotalElement);
    end;

    local procedure InsertCrMemoLine(var CrMemoElement: XmlElement; ServiceCrMemoLine: Record "Service Cr.Memo Line"; CurrencyCode: Code[10]; UnitOfMeasureCode: Code[10])
    var
        CrMemoLineElement: XmlElement;
    begin
        CrMemoLineElement := XmlElement.Create('CreditNoteLine', DocNameSpace2);

        CrMemoLineElement.Add(XmlElement.Create('ID', DocNameSpace, FORMAT(ServiceCrMemoLine."Line No.")));
        CrMemoLineElement.Add(
          XmlElement.Create('CreditedQuantity', DocNameSpace,
            XmlAttribute.Create('unitCode', OIOUBLDocumentEncode.GetUoMCode(UnitOfMeasureCode)),
            OIOUBLDocumentEncode.DecimalToText(ServiceCrMemoLine.Quantity)));
        CrMemoLineElement.Add(
          XmlElement.Create('LineExtensionAmount', DocNameSpace,
            XmlAttribute.Create('currencyID', CurrencyCode),
            OIOUBLDocumentEncode.DecimalToText(ServiceCrMemoLine.Amount + ServiceCrMemoLine."Inv. Discount Amount")));

        OIOUBLXMLGenerator.InsertLineTaxTotal(CrMemoLineElement,
          ServiceCrMemoLine."Amount Including VAT",
          ServiceCrMemoLine.Amount,
          ServiceCrMemoLine."VAT Calculation Type",
          ServiceCrMemoLine."VAT %",
          CurrencyCode);
        OIOUBLXMLGenerator.InsertItem(CrMemoLineElement, ServiceCrMemoLine.Description, ServiceCrMemoLine."No.");
        OIOUBLXMLGenerator.InsertPrice(
            CrMemoLineElement,
            Round((ServiceCrMemoLine.Amount + ServiceCrMemoLine."Inv. Discount Amount") / ServiceCrMemoLine.Quantity),
            UnitOfMeasureCode, CurrencyCode);

        CrMemoElement.Add(CrMemoLineElement);
    end;

    local procedure CreateXML(ServiceCrMemoHeader: Record "Service Cr.Memo Header") FromFile: Text[250]
    var
        ServiceCrMemoLine: Record "Service Cr.Memo Line";
        ServiceCrMemoLine2: Record "Service Cr.Memo Line";
        OIOUBLProfile: Record "OIOUBL-Profile";
        BillToAddress: Record "Standard Address";
        PartyContact: Record Contact;
        RBMgt: Codeunit "File Management";
        PEPPOLManagement: Codeunit "PEPPOL Management";
        XMLdocOut: XmlDocument;
        XMLCurrNode: XmlElement;
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
        CODEUNIT.RUN(CODEUNIT::"OIOUBL-Check Service Cr. Memo", ServiceCrMemoHeader);
        ReadGLSetup();
        ReadCompanyInfo();

        if ServiceCrMemoHeader."Currency Code" = '' then
            CurrencyCode := GLSetup."LCY Code"
        else
            CurrencyCode := ServiceCrMemoHeader."Currency Code";

        if CurrencyCode = GLSetup."LCY Code" then
            Currency.InitRoundingPrecision()
        else begin
            Currency.GET(CurrencyCode);
            Currency.TESTFIELD("Amount Rounding Precision");
        end;

        ServiceCrMemoLine.SETRANGE("Document No.", ServiceCrMemoHeader."No.");
        ServiceCrMemoLine.SETFILTER(Type, '>%1', 0);
        ServiceCrMemoLine.SETFILTER("No.", '<>%1', ' ');
        if NOT ServiceCrMemoLine.FINDSET() then
            EXIT;

        FromFile := CopyStr(RBMgt.ServerTempFileName(''), 1, MaxStrLen(FromFile));

        // Credit Memo
        XmlDocument.ReadFrom(OIOUBLXMLGenerator.GetCrMemoHeader(), XMLdocOut);
        XMLdocOut.GetRoot(XMLCurrNode);

        OIOUBLXMLGenerator.init(DocNameSpace, DocNameSpace2);

        XMLCurrNode.Add(XmlElement.Create('UBLVersionID', DocNameSpace, '2.0'));
        XMLCurrNode.Add(XmlElement.Create('CustomizationID', DocNameSpace, 'OIOUBL-2.02'));

        XMLCurrNode.Add(
          XmlElement.Create('ProfileID', DocNameSpace,
            XmlAttribute.Create('schemeID', 'urn:oioubl:id:profileid-1.2'),
            XmlAttribute.Create('schemeAgencyID', '320'),
            OIOUBLProfile.GetOIOUBLProfileID(ServiceCrMemoHeader."OIOUBL-Profile Code", ServiceCrMemoHeader."Customer No.")));

        XMLCurrNode.Add(XmlElement.Create('ID', DocNameSpace, ServiceCrMemoHeader."No."));
        XMLCurrNode.Add(XmlElement.Create('CopyIndicator', DocNameSpace,
          OIOUBLDocumentEncode.BooleanToText(ServiceCrMemoHeader."OIOUBL-Electronic Credit Memo Created")));
        XMLCurrNode.Add(XmlElement.Create('IssueDate', DocNameSpace,
          OIOUBLDocumentEncode.DateToText(ServiceCrMemoHeader."Posting Date")));

        XMLCurrNode.Add(XmlElement.Create('DocumentCurrencyCode', DocNameSpace, CurrencyCode));
        XMLCurrNode.Add(XmlElement.Create('AccountingCostCode', DocNameSpace, ServiceCrMemoHeader."OIOUBL-Account Code"));

        InsertDiscrepancyResponse(XMLCurrNode);
        InsertOrderReference(XMLCurrNode,
          ServiceCrMemoHeader."Your Reference",
          ServiceCrMemoHeader."Applies-to Doc. No.");

        // Credit Memo->AccountingSupplierParty
        OIOUBLXMLGenerator.InsertAccountingSupplierParty(XMLCurrNode, ServiceCrMemoHeader."Salesperson Code");

        with ServiceCrMemoHeader do begin
            // Credit Memo->AccountingCustomerParty
            BillToAddress.Address := "Bill-to Address";
            BillToAddress."Address 2" := "Bill-to Address 2";
            BillToAddress.City := "Bill-to City";
            BillToAddress."Post Code" := "Bill-to Post Code";
            BillToAddress."Country/Region Code" := "Bill-to Country/Region Code";
            PartyContact.Name := "Contact Name";
            PartyContact."Phone No." := "Phone No.";
            PartyContact."Fax No." := "Fax No.";
            PartyContact."E-Mail" := "E-Mail";
            OIOUBLXMLGenerator.InsertAccountingCustomerParty(XMLCurrNode,
              "OIOUBL-GLN",
              "VAT Registration No.",
              "Bill-to Name",
              BillToAddress,
              PartyContact);

            // CreditMemo->Allowance Charge
            ServiceCrMemoLine2.RESET();
            ServiceCrMemoLine2.COPY(ServiceCrMemoLine);
            ServiceCrMemoLine2.SETRANGE(Type);
            ServiceCrMemoLine2.SETRANGE("No.");
            ServiceCrMemoLine2.CALCSUMS(Amount, "Amount Including VAT", "Inv. Discount Amount");

            TotalInvDiscountAmount := 0;
            if ServiceCrMemoLine2.FINDSET() then
                repeat
                    ExcludeVAT(ServiceCrMemoLine2, ServiceCrMemoHeader."Prices Including VAT");
                    TotalInvDiscountAmount += ServiceCrMemoLine2."Inv. Discount Amount";
                until ServiceCrMemoLine2.NEXT() = 0;

            if TotalInvDiscountAmount > 0 then
                OIOUBLXMLGenerator.InsertAllowanceCharge(XMLCurrNode, 1, 'Rabat',
                  OIOUBLXMLGenerator.GetTaxCategoryID(ServiceCrMemoLine2."VAT Calculation Type", ServiceCrMemoLine2."VAT %"),
                  TotalInvDiscountAmount, CurrencyCode, ServiceCrMemoLine2."VAT %");
        end;

        ServiceCrMemoLine2.RESET();
        ServiceCrMemoLine2.COPY(ServiceCrMemoLine);
        ServiceCrMemoLine2.SETFILTER(
          "VAT Calculation Type", '%1|%2|%3',
          ServiceCrMemoLine2."VAT Calculation Type"::"Normal VAT",
          ServiceCrMemoLine2."VAT Calculation Type"::"Full VAT",
          ServiceCrMemoLine2."VAT Calculation Type"::"Reverse Charge VAT");
        if ServiceCrMemoLine2.FINDFIRST() then begin
            TotalTaxAmount := 0;
            ServiceCrMemoLine2.CALCSUMS(Amount, "Amount Including VAT");
            TotalTaxAmount := ServiceCrMemoLine2."Amount Including VAT" - ServiceCrMemoLine2.Amount;

            InsertCrMemoTaxTotal(XMLCurrNode, ServiceCrMemoLine2, TotalTaxAmount, CurrencyCode);
        end;

        // CreditMemo->LegalMonetaryTotal
        LineAmount := 0;
        TaxAmount := 0;

        ServiceCrMemoLine2.RESET();
        ServiceCrMemoLine2.COPY(ServiceCrMemoLine);
        if ServiceCrMemoLine2.FINDSET() then
            repeat
                ExcludeVAT(ServiceCrMemoLine2, ServiceCrMemoHeader."Prices Including VAT");
                LineAmount += ServiceCrMemoLine2.Amount + ServiceCrMemoLine2."Inv. Discount Amount";
                TotalAmount += ServiceCrMemoLine2."Amount Including VAT";
                TaxAmount += ServiceCrMemoLine2."Amount Including VAT" - ServiceCrMemoLine2.Amount;
            until ServiceCrMemoLine2.NEXT() = 0;
        OIOUBLXMLGenerator.InsertLegalMonetaryTotal(XMLCurrNode, LineAmount, TaxAmount, TotalAmount, TotalInvDiscountAmount, CurrencyCode);

        // CreditMemo->CreditMemoLine
        repeat
            ServiceCrMemoLine.TESTFIELD(Description);

            if (ServiceCrMemoLine.Type = ServiceCrMemoLine.Type::"G/L Account") and (ServiceCrMemoLine."Unit of Measure Code" = '') then
                UnitOfMeasureCode := PEPPOLManagement.GetUoMforPieceINUNECERec20ListID()
            else
                UnitOfMeasureCode := ServiceCrMemoLine."Unit of Measure Code";

            ExcludeVAT(ServiceCrMemoLine, ServiceCrMemoHeader."Prices Including VAT");
            InsertCrMemoLine(XMLCurrNode, ServiceCrMemoLine, CurrencyCode, UnitOfMeasureCode);
        until ServiceCrMemoLine.NEXT() = 0;

        OutputFile.Create(FromFile);
        OutputFile.CreateOutStream(FileOutstream);
        OnCreateXMLOnBeforeXmlDocumentWriteToFileStream(XMLdocOut, ServiceCrMemoHeader, DocNameSpace, DocNameSpace2);
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

    procedure UpdateTaxAmtAndTaxableAmt(Amount: Decimal; AmountIncludingVAT: Decimal; var TaxableAmountParam: Decimal; var TaxAmountParam: Decimal);
    begin
        TaxableAmountParam := TaxableAmountParam + Amount;
        TaxAmountParam := TaxAmountParam + AmountIncludingVAT - Amount;
    end;

    local procedure ExcludeVAT(var ServiceCrMemoLine: Record "Service Cr.Memo Line"; PricesInclVAT: Boolean);
    var
        ExclVATFactor: Decimal;
    begin
        if not PricesInclVAT then
            exit;
        with ServiceCrMemoLine do begin
            ExclVATFactor := 1 + "VAT %" / 100;
            "Line Discount Amount" := Round("Line Discount Amount" / ExclVATFactor, Currency."Amount Rounding Precision");
            "Inv. Discount Amount" := Round("Inv. Discount Amount" / ExclVATFactor, Currency."Amount Rounding Precision");
            "Unit Price" := Round("Unit Price" / ExclVATFactor, Currency."Amount Rounding Precision");
        end;
    end;

    [IntegrationEvent(false, false)]
    local procedure OnCreateXMLOnBeforeXmlDocumentWriteToFileStream(var XMLdocOut: XmlDocument; ServiceCrMemoHeader: Record "Service Cr.Memo Header"; DocNameSpace: Text[250]; DocNameSpace2: Text[250])
    begin
    end;
}