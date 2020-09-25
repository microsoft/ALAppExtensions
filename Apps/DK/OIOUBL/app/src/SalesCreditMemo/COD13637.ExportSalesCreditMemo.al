// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------

codeunit 13637 "OIOUBL-Export Sales Cr. Memo"
{
    TableNo = "Record Export Buffer";
    Permissions = tabledata "Sales Cr.Memo Header" = rm;

    trigger OnRun();
    var
        SalesCrMemoHeader: Record "Sales Cr.Memo Header";
        RecordRef: RecordRef;
    begin
        RecordRef.Get(RecordID);
        RecordRef.SetTable(SalesCrMemoHeader);

        ServerFilePath := CreateXML(SalesCrMemoHeader);
        Modify();

        SalesCrMemoHeader."OIOUBL-Electronic Credit Memo Created" := true;
        SalesCrMemoHeader.Modify();

        Codeunit.Run(Codeunit::"Sales Cr. Memo-Printed", SalesCrMemoHeader);
    end;

    var
        CompanyInfo: Record "Company Information";
        GLSetup: Record "General Ledger Setup";
        SalesSetup: Record 311;
        Currency: Record Currency;
        OIOUBLDocumentEncode: Codeunit "OIOUBL-Document Encode";
        OIOUBLXMLGenerator: Codeunit "OIOUBL-Common Logic";
        DocNameSpace: Text[250];
        DocNameSpace2: Text[250];
        CompanyInfoRead: Boolean;
        GLSetupRead: Boolean;

    procedure ExportXML(SalesCrMemoHeader: Record "Sales Cr.Memo Header");
    var
        SalesCrMemoHeader2: Record "Sales Cr.Memo Header";
        RecordExportBuffer: Record "Record Export Buffer";
        ElectronicDocumentFormat: Record "Electronic Document Format";
        RBMgt: Codeunit "File Management";
        OIOUBLManagement: Codeunit "OIOUBL-Management";
        EnvironmentInfo: Codeunit "Environment Information";
        FromFile: Text[1024];
        DocumentType: Option "Quote","Order","Invoice","Credit Memo","Blanket Order","Return Order","Finance Charge","Reminder";
    begin
        FromFile := CreateXML(SalesCrMemoHeader);

        SalesSetup.Get();

        if RBMgt.IsLocalFileSystemAccessible() and not EnvironmentInfo.IsSaaS() then
            SalesSetup.VerifyAndSetOIOUBLSetupPath(DocumentType::"Credit Memo");

        OIOUBLManagement.UpdateRecordExportBuffer(
            SalesCrMemoHeader.RecordId(),
            CopyStr(FromFile, 1, MaxStrLen(RecordExportBuffer.ServerFilePath)),
            ElectronicDocumentFormat.GetAttachmentFileName(SalesCrMemoHeader."No.", 'Credit Memo', 'xml'));

        OIOUBLManagement.ExportXMLFile(SalesCrMemoHeader."No.", FromFile, SalesSetup."OIOUBL-Cr. Memo Path");

        SalesCrMemoHeader2.Get(SalesCrMemoHeader."No.");
        SalesCrMemoHeader2."OIOUBL-Electronic Credit Memo Created" := true;
        SalesCrMemoHeader2.Modify();

        Codeunit.Run(Codeunit::"Sales Cr. Memo-Printed", SalesCrMemoHeader2);
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

    local procedure InsertCrMemoTaxTotal(var CrMemoElement: XmlElement; var SalesCrMemoLine: Record "Sales Cr.Memo Line"; TotalTaxAmount: Decimal; CurrencyCode: Code[10]);
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
        SalesCrMemoLine.SETFILTER(
          "VAT Calculation Type", '%1|%2',
          SalesCrMemoLine."VAT Calculation Type"::"Normal VAT",
          SalesCrMemoLine."VAT Calculation Type"::"Full VAT");
        if SalesCrMemoLine.FINDFIRST() then begin
            TaxableAmount := 0;
            TaxAmount := 0;
            SalesCrMemoLine.SETFILTER("VAT %", '<>0');
            if SalesCrMemoLine.FINDSET() then begin
                VATPercentage := SalesCrMemoLine."VAT %";
                repeat
                    UpdateTaxAmtAndTaxableAmt(SalesCrMemoLine.Amount, SalesCrMemoLine."Amount Including VAT", TaxableAmount, TaxAmount);
                until SalesCrMemoLine.NEXT() = 0;
                OIOUBLXMLGenerator.InsertTaxSubtotal(TaxTotalElement, SalesCrMemoLine."VAT Calculation Type", TaxableAmount, TaxAmount, VATPercentage, CurrencyCode);
            end;

            TaxableAmount := 0;
            TaxAmount := 0;
            SalesCrMemoLine.SETRANGE("VAT %", 0);
            if SalesCrMemoLine.FINDSET() then begin
                VATPercentage := SalesCrMemoLine."VAT %";
                repeat
                    UpdateTaxAmtAndTaxableAmt(SalesCrMemoLine.Amount, SalesCrMemoLine."Amount Including VAT", TaxableAmount, TaxAmount);
                until SalesCrMemoLine.NEXT() = 0;
                // CrMemo->TaxTotal->TaxSubtotal
                OIOUBLXMLGenerator.InsertTaxSubtotal(TaxTotalElement, SalesCrMemoLine."VAT Calculation Type", TaxableAmount, TaxAmount, VATPercentage, CurrencyCode);
            end;
        end;

        // CrMemo->TaxTotal (for "Reverse Charge VAT")
        SalesCrMemoLine.SETRANGE("VAT %");
        SalesCrMemoLine.SETRANGE("VAT Calculation Type", SalesCrMemoLine."VAT Calculation Type"::"Reverse Charge VAT");
        if SalesCrMemoLine.FINDSET() then begin
            TaxableAmount := 0;
            TaxAmount := 0;
            VATPercentage := SalesCrMemoLine."VAT %";
            repeat
                UpdateTaxAmtAndTaxableAmt(SalesCrMemoLine.Amount, SalesCrMemoLine."Amount Including VAT", TaxableAmount, TaxAmount);
            until SalesCrMemoLine.NEXT() = 0;
            OIOUBLXMLGenerator.InsertTaxSubtotal(TaxTotalElement, SalesCrMemoLine."VAT Calculation Type", TaxableAmount, TaxAmount, VATPercentage, CurrencyCode);
        end;

        CrMemoElement.Add(TaxTotalElement);
    end;

    local procedure InsertCrMemoLine(var CrMemoElement: XmlElement; SalesCrMemoLine: Record "Sales Cr.Memo Line"; CurrencyCode: Code[10])
    var
        CrMemoLineElement: XmlElement;
    begin
        CrMemoLineElement := XmlElement.Create('CreditNoteLine', DocNameSpace2);

        CrMemoLineElement.Add(XmlElement.Create('ID', DocNameSpace, FORMAT(SalesCrMemoLine."Line No.")));
        CrMemoLineElement.Add(
          XmlElement.Create('CreditedQuantity', DocNameSpace,
            XmlAttribute.Create('unitCode', OIOUBLDocumentEncode.GetUoMCode(SalesCrMemoLine."Unit of Measure Code")),
            OIOUBLDocumentEncode.DecimalToText(SalesCrMemoLine.Quantity)));
        CrMemoLineElement.Add(
          XmlElement.Create('LineExtensionAmount', DocNameSpace,
            XmlAttribute.Create('currencyID', CurrencyCode),
            OIOUBLDocumentEncode.DecimalToText(SalesCrMemoLine.Amount + SalesCrMemoLine."Inv. Discount Amount")));

        OIOUBLXMLGenerator.InsertLineTaxTotal(CrMemoLineElement,
          SalesCrMemoLine."Amount Including VAT",
          SalesCrMemoLine.Amount,
          SalesCrMemoLine."VAT Calculation Type",
          SalesCrMemoLine."VAT %",
          CurrencyCode);
        OIOUBLXMLGenerator.InsertItem(CrMemoLineElement, SalesCrMemoLine.Description, SalesCrMemoLine."No.");
        OIOUBLXMLGenerator.InsertPrice(
            CrMemoLineElement,
            Round((SalesCrMemoLine.Amount + SalesCrMemoLine."Inv. Discount Amount") / SalesCrMemoLine.Quantity),
            SalesCrMemoLine."Unit of Measure Code", CurrencyCode);

        CrMemoElement.Add(CrMemoLineElement);
    end;

    local procedure CreateXML(SalesCrMemoHeader: Record 114) FromFile: Text[250];
    var
        SalesCrMemoLine: Record 115;
        SalesCrMemoLine2: Record 115;
        OIOUBLProfile: Record "OIOUBL-Profile";
        BillToAddress: Record "Standard Address";
        SellToContact: Record Contact;
        RBMgt: Codeunit 419;
        XMLdocOut: XmlDocument;
        XMLCurrNode: XmlElement;
        CurrencyCode: Code[10];
        LineAmount: Decimal;
        TaxAmount: Decimal;
        TotalAmount: Decimal;
        TotalInvDiscountAmount: Decimal;
        TotalTaxAmount: Decimal;
        OutputFile: File;
        FileOutstream: Outstream;
    begin
        CODEUNIT.RUN(CODEUNIT::"OIOUBL-Check Sales Cr. Memo", SalesCrMemoHeader);
        ReadGLSetup();
        ReadCompanyInfo();

        if SalesCrMemoHeader."Currency Code" = '' then
            CurrencyCode := GLSetup."LCY Code"
        else
            CurrencyCode := SalesCrMemoHeader."Currency Code";

        if CurrencyCode = GLSetup."LCY Code" then
            Currency.InitRoundingPrecision()
        else begin
            Currency.GET(CurrencyCode);
            Currency.TESTFIELD("Amount Rounding Precision");
        end;

        SalesCrMemoLine.SETRANGE("Document No.", SalesCrMemoHeader."No.");
        SalesCrMemoLine.SETFILTER(Type, '>%1', 0);
        SalesCrMemoLine.SETFILTER("No.", '<>%1', ' ');
        if NOT SalesCrMemoLine.FINDSET() then
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
            OIOUBLProfile.GetOIOUBLProfileID(SalesCrMemoHeader."OIOUBL-Profile Code", SalesCrMemoHeader."Sell-to Customer No.")));

        XMLCurrNode.Add(XmlElement.Create('ID', DocNameSpace, SalesCrMemoHeader."No."));
        XMLCurrNode.Add(XmlElement.Create('CopyIndicator', DocNameSpace,
          OIOUBLDocumentEncode.BooleanToText(SalesCrMemoHeader."OIOUBL-Electronic Credit Memo Created")));
        XMLCurrNode.Add(XmlElement.Create('IssueDate', DocNameSpace,
          OIOUBLDocumentEncode.DateToText(SalesCrMemoHeader."Posting Date")));

        XMLCurrNode.Add(XmlElement.Create('DocumentCurrencyCode', DocNameSpace, CurrencyCode));
        XMLCurrNode.Add(XmlElement.Create('AccountingCostCode', DocNameSpace, SalesCrMemoHeader."OIOUBL-Account Code"));

        InsertDiscrepancyResponse(XMLCurrNode);
        OIOUBLXMLGenerator.InsertOrderReference(XMLCurrNode,
          SalesCrMemoHeader."External Document No.",
          SalesCrMemoHeader."Applies-to Doc. No.",
          SalesCrMemoHeader."Posting Date");

        // Credit Memo->AccountingSupplierParty
        OIOUBLXMLGenerator.InsertAccountingSupplierParty(XMLCurrNode, SalesCrMemoHeader."Salesperson Code");

        // Credit Memo->AccountingCustomerParty
        BillToAddress.Address := SalesCrMemoHeader."Bill-to Address";
        BillToAddress."Address 2" := SalesCrMemoHeader."Bill-to Address 2";
        BillToAddress.City := SalesCrMemoHeader."Bill-to City";
        BillToAddress."Post Code" := SalesCrMemoHeader."Bill-to Post Code";
        BillToAddress."Country/Region Code" := SalesCrMemoHeader."Bill-to Country/Region Code";
        SellToContact.Name := SalesCrMemoHeader."Sell-to Contact";
        SellToContact."Phone No." := SalesCrMemoHeader."OIOUBL-Sell-to Contact Phone No.";
        SellToContact."Fax No." := SalesCrMemoHeader."OIOUBL-Sell-to Contact Fax No.";
        SellToContact."E-Mail" := SalesCrMemoHeader."OIOUBL-Sell-to Contact E-Mail";
        OIOUBLXMLGenerator.InsertAccountingCustomerParty(XMLCurrNode,
          SalesCrMemoHeader."OIOUBL-GLN",
          SalesCrMemoHeader."VAT Registration No.",
          SalesCrMemoHeader."Bill-to Name",
          BillToAddress,
          SellToContact);

        // CreditMemo->Allowance Charge
        SalesCrMemoLine2.RESET();
        SalesCrMemoLine2.COPY(SalesCrMemoLine);
        SalesCrMemoLine2.SETRANGE(Type);
        SalesCrMemoLine2.SETRANGE("No.");
        SalesCrMemoLine2.CALCSUMS(Amount, "Amount Including VAT", "Inv. Discount Amount");

        TotalInvDiscountAmount := 0;
        if SalesCrMemoLine2.FINDSET() then
            repeat
                ExcludeVAT(SalesCrMemoLine2, SalesCrMemoHeader."Prices Including VAT");
                TotalInvDiscountAmount += SalesCrMemoLine2."Inv. Discount Amount";
            until SalesCrMemoLine2.NEXT() = 0;

        if TotalInvDiscountAmount > 0 then
            OIOUBLXMLGenerator.InsertAllowanceCharge(XMLCurrNode, 1, 'Rabat',
              OIOUBLXMLGenerator.GetTaxCategoryID(SalesCrMemoLine2."VAT Calculation Type", SalesCrMemoLine2."VAT %"),
              TotalInvDiscountAmount, CurrencyCode, SalesCrMemoLine2."VAT %");

        SalesCrMemoLine2.RESET();
        SalesCrMemoLine2.COPY(SalesCrMemoLine);
        SalesCrMemoLine2.SETFILTER(
          "VAT Calculation Type", '%1|%2|%3',
          SalesCrMemoLine2."VAT Calculation Type"::"Normal VAT",
          SalesCrMemoLine2."VAT Calculation Type"::"Full VAT",
          SalesCrMemoLine2."VAT Calculation Type"::"Reverse Charge VAT");
        if SalesCrMemoLine2.FINDFIRST() then begin
            TotalTaxAmount := 0;
            SalesCrMemoLine2.CALCSUMS(Amount, "Amount Including VAT");
            TotalTaxAmount := SalesCrMemoLine2."Amount Including VAT" - SalesCrMemoLine2.Amount;

            InsertCrMemoTaxTotal(XMLCurrNode, SalesCrMemoLine2, TotalTaxAmount, CurrencyCode);
        end;

        // CreditMemo->LegalMonetaryTotal
        LineAmount := 0;
        TaxAmount := 0;

        SalesCrMemoLine2.RESET();
        SalesCrMemoLine2.COPY(SalesCrMemoLine);
        if SalesCrMemoLine2.FINDSET() then
            repeat
                ExcludeVAT(SalesCrMemoLine2, SalesCrMemoHeader."Prices Including VAT");
                LineAmount += SalesCrMemoLine2.Amount + SalesCrMemoLine2."Inv. Discount Amount";
                TotalAmount += SalesCrMemoLine2."Amount Including VAT";
                TaxAmount += SalesCrMemoLine2."Amount Including VAT" - SalesCrMemoLine2.Amount;
            until SalesCrMemoLine2.NEXT() = 0;
        OIOUBLXMLGenerator.InsertLegalMonetaryTotal(XMLCurrNode, LineAmount, TaxAmount, TotalAmount, TotalInvDiscountAmount, CurrencyCode);

        // CreditMemo->CreditMemoLine
        repeat
            SalesCrMemoLine.TESTFIELD(Description);

            ExcludeVAT(SalesCrMemoLine, SalesCrMemoHeader."Prices Including VAT");
            InsertCrMemoLine(XMLCurrNode, SalesCrMemoLine, CurrencyCode);
        until SalesCrMemoLine.NEXT() = 0;

        OutputFile.create(FromFile);
        OutputFile.CreateOutStream(FileOutstream);
        OnCreateXMLOnBeforeXmlDocumentWriteToFileStream(XMLdocOut, SalesCrMemoHeader, DocNameSpace, DocNameSpace2);
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

    local procedure ExcludeVAT(var SalesCrMemoLine: Record "Sales Cr.Memo Line"; PricesInclVAT: Boolean);
    var
        ExclVATFactor: Decimal;
    begin
        if NOT PricesInclVAT then
            EXIT;
        WITH SalesCrMemoLine do begin
            ExclVATFactor := 1 + "VAT %" / 100;
            "Line Discount Amount" := ROUND("Line Discount Amount" / ExclVATFactor, Currency."Amount Rounding Precision");
            "Inv. Discount Amount" := ROUND("Inv. Discount Amount" / ExclVATFactor, Currency."Amount Rounding Precision");
            "Unit Price" := ROUND("Unit Price" / ExclVATFactor, Currency."Amount Rounding Precision");
        end;
    end;

    [IntegrationEvent(false, false)]
    local procedure OnCreateXMLOnBeforeXmlDocumentWriteToFileStream(var XMLdocOut: XmlDocument; SalesCrMemoHeader: Record "Sales Cr.Memo Header"; DocNameSpace: Text[250]; DocNameSpace2: Text[250])
    begin
    end;
}