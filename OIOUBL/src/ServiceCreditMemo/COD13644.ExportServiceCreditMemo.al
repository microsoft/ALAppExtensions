// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------

codeunit 13644 "OIOUBL-Export Service Cr.Memo"
{
    TableNo = "Service Cr.Memo Header";
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

    local procedure InsertCrMemoTaxTotal(var CrMemoElement: XmlElement; ServiceCrMemoHeader: Record "Service Cr.Memo Header"; var ServiceCrMemoLine: Record "Service Cr.Memo Line"; TotalTaxAmount: Decimal);
    var
        TaxTotalElement: XmlElement;
        TaxableAmount: Decimal;
        TaxAmount: Decimal;
        VATPercentage: Decimal;
    begin
        TaxTotalElement := XmlElement.Create('TaxTotal', DocNameSpace2);

        TaxTotalElement.Add(
          XmlElement.Create('TaxAmount', DocNameSpace,
            XmlAttribute.Create('currencyID', ServiceCrMemoHeader."Currency Code"),
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
                OIOUBLXMLGenerator.InsertTaxSubtotal(TaxTotalElement, ServiceCrMemoLine."VAT Calculation Type", TaxableAmount, TaxAmount, VATPercentage, ServiceCrMemoHeader."Currency Code");
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
                OIOUBLXMLGenerator.InsertTaxSubtotal(TaxTotalElement, ServiceCrMemoLine."VAT Calculation Type", TaxableAmount, TaxAmount, VATPercentage, ServiceCrMemoHeader."Currency Code");
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
            OIOUBLXMLGenerator.InsertTaxSubtotal(TaxTotalElement, ServiceCrMemoLine."VAT Calculation Type", TaxableAmount, TaxAmount, VATPercentage, ServiceCrMemoHeader."Currency Code");
        end;

        CrMemoElement.Add(TaxTotalElement);
    end;

    local procedure InsertCrMemoLine(var CrMemoElement: XmlElement; ServiceCrMemoHeader: Record "Service Cr.Memo Header"; ServiceCrMemoLine: Record "Service Cr.Memo Line"; CurrencyCode: Code[10])
    var
        CrMemoLineElement: XmlElement;
    begin
        CrMemoLineElement := XmlElement.Create('CreditNoteLine', DocNameSpace2);

        CrMemoLineElement.Add(XmlElement.Create('ID', DocNameSpace, FORMAT(ServiceCrMemoLine."Line No.")));
        CrMemoLineElement.Add(
          XmlElement.Create('CreditedQuantity', DocNameSpace,
            XmlAttribute.Create('unitCode', OIOUBLDocumentEncode.GetUoMCode(ServiceCrMemoLine."Unit of Measure Code")),
            OIOUBLDocumentEncode.DecimalToText(ServiceCrMemoLine.Quantity)));
        CrMemoLineElement.Add(
          XmlElement.Create('LineExtensionAmount', DocNameSpace,
            XmlAttribute.Create('currencyID', ServiceCrMemoHeader."Currency Code"),
            OIOUBLDocumentEncode.DecimalToText(ServiceCrMemoLine.Amount + ServiceCrMemoLine."Inv. Discount Amount" +
              ServiceCrMemoLine."Line Discount Amount")));

        OIOUBLXMLGenerator.InsertLineTaxTotal(CrMemoLineElement,
          ServiceCrMemoLine."Amount Including VAT",
          ServiceCrMemoLine.Amount,
          ServiceCrMemoLine."VAT Calculation Type",
          ServiceCrMemoLine."VAT %",
          CurrencyCode);
        OIOUBLXMLGenerator.InsertItem(CrMemoLineElement, ServiceCrMemoLine.Description, ServiceCrMemoLine."No.");
        OIOUBLXMLGenerator.InsertPrice(CrMemoLineElement, ServiceCrMemoLine."Unit Price", ServiceCrMemoLine."Unit of Measure Code", CurrencyCode);

        CrMemoElement.Add(CrMemoLineElement);
    end;

    trigger OnRun();
    var
        ServiceCrMemoLine: Record "Service Cr.Memo Line";
        ServiceCrMemoLine2: Record "Service Cr.Memo Line";
        OIOUBLProfile: Record "OIOUBL-Profile";
        BillToAddress: Record "Standard Address";
        PartyContact: Record Contact;
        ServiceCrMemoHeader2: Record "Service Cr.Memo Header";
        RBMgt: Codeunit "File Management";
        OIOUBLManagement: Codeunit "OIOUBL-Management";
        PermissionManager: Codeunit "Permission Manager";
        XMLdocOut: XmlDocument;
        XMLCurrNode: XmlElement;
        FromFile: Text[1024];
        DocumentType: Option "Quote","Order","Invoice","Credit Memo","Blanket Order","Return Order","Finance Charge","Reminder";
        CurrencyCode: Code[10];
        TaxableAmount: Decimal;
        TaxAmount: Decimal;
        TotalAmount: Decimal;
        TotalInvDiscountAmount: Decimal;
        TotalTaxAmount: Decimal;
        OutputFile: File;
        FileOutstream: Outstream;
    begin
        CODEUNIT.RUN(CODEUNIT::"OIOUBL-Check Service Cr. Memo", Rec);
        ReadGLSetup();
        ReadCompanyInfo();

        if "Currency Code" = '' then
            CurrencyCode := GLSetup."LCY Code"
        else
            CurrencyCode := "Currency Code";

        if CurrencyCode = GLSetup."LCY Code" then
            Currency.InitRoundingPrecision()
        else begin
            Currency.GET(CurrencyCode);
            Currency.TESTFIELD("Amount Rounding Precision");
        end;

        ServiceCrMemoLine.SETRANGE("Document No.", "No.");
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
            OIOUBLProfile.GetOIOUBLProfileID("OIOUBL-Profile Code", "Customer No.")));

        XMLCurrNode.Add(XmlElement.Create('ID', DocNameSpace, "No."));
        XMLCurrNode.Add(XmlElement.Create('CopyIndicator', DocNameSpace,
          OIOUBLDocumentEncode.BooleanToText("OIOUBL-Electronic Credit Memo Created")));
        XMLCurrNode.Add(XmlElement.Create('IssueDate', DocNameSpace,
          OIOUBLDocumentEncode.DateToText("Posting Date")));

        XMLCurrNode.Add(XmlElement.Create('DocumentCurrencyCode', DocNameSpace, CurrencyCode));
        XMLCurrNode.Add(XmlElement.Create('AccountingCostCode', DocNameSpace, "OIOUBL-Account Code"));

        InsertDiscrepancyResponse(XMLCurrNode);
        InsertOrderReference(XMLCurrNode,
          "Your Reference",
          "Applies-to Doc. No.");

        // Credit Memo->AccountingSupplierParty
        OIOUBLXMLGenerator.InsertAccountingSupplierParty(XMLCurrNode, "Salesperson Code");

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
                TotalInvDiscountAmount := TotalInvDiscountAmount + ServiceCrMemoLine2."Inv. Discount Amount" +
                  ServiceCrMemoLine2."Line Discount Amount";
            until ServiceCrMemoLine2.NEXT() = 0;

        if TotalInvDiscountAmount > 0 then
            OIOUBLXMLGenerator.InsertAllowanceCharge(XMLCurrNode, 1, 'Rabat',
              OIOUBLXMLGenerator.GetTaxCategoryID(ServiceCrMemoLine2."VAT Calculation Type", ServiceCrMemoLine2."VAT %"),
              TotalInvDiscountAmount, CurrencyCode, ServiceCrMemoLine2."VAT %");

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

            InsertCrMemoTaxTotal(XMLCurrNode, Rec, ServiceCrMemoLine2, TotalTaxAmount);
        end;

        // CreditMemo->LegalMonetaryTotal
        TaxableAmount := 0;
        TaxAmount := 0;

        ServiceCrMemoLine2.RESET();
        ServiceCrMemoLine2.COPY(ServiceCrMemoLine);
        if ServiceCrMemoLine2.FINDSET() then
            repeat
                TaxableAmount := TaxableAmount + ServiceCrMemoLine2.Amount + ServiceCrMemoLine2."Inv. Discount Amount" +
                ServiceCrMemoLine2."Line Discount Amount";
                TotalAmount := TotalAmount + ServiceCrMemoLine2."Amount Including VAT";
                TaxAmount := TaxAmount + ServiceCrMemoLine2."Amount Including VAT" - ServiceCrMemoLine2.Amount;
            until ServiceCrMemoLine2.NEXT() = 0;
        OIOUBLXMLGenerator.InsertLegalMonetaryTotal(XMLCurrNode, TaxableAmount, TaxAmount, TotalAmount, TotalInvDiscountAmount, CurrencyCode);

        // CreditMemo->CreditMemoLine
        repeat
            ServiceCrMemoLine.TESTFIELD(Description);

            InsertCrMemoLine(XMLCurrNode, Rec, ServiceCrMemoLine, CurrencyCode);
        until ServiceCrMemoLine.NEXT() = 0;

        OutputFile.create(FromFile);
        OutputFile.CreateOutStream(FileOutstream);
        XMLdocOut.WriteTo(FileOutstream);
        OutputFile.Close();

        ServiceSetup.GET();

        if RBMgt.CanRunDotNetOnClient() and not PermissionManager.SoftwareAsAService() then
            ServiceSetup.OIOUBLVerifyAndSetPath(DocumentType::"Credit Memo");

        OIOUBLManagement.ExportXMLFile("No.", FromFile, ServiceSetup."OIOUBL-Service Cr. Memo Path");

        ServiceCrMemoHeader2.GET("No.");
        ServiceCrMemoHeader2."OIOUBL-Electronic Credit Memo Created" := TRUE;
        ServiceCrMemoHeader2.MODIFY();
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

}