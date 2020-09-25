// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------

codeunit 13639 "OIOUBL-Export Issued Reminder"
{
    TableNo = "Issued Reminder Header";
    Permissions = tabledata "Issued Reminder Header" = rm;

    var
        GLSetup: Record "General Ledger Setup";
        CompanyInfo: Record "Company Information";
        IssuedReminder: Record "Issued Reminder Header";
        IssuedReminderLine: Record "Issued Reminder Line";
        SalesSetup: Record "Sales & Receivables Setup";
        OIOUBLDocumentEncode: Codeunit "OIOUBL-Document Encode";
        OIOUBLCommonLogic: Codeunit "OIOUBL-Common Logic";
        DocNameSpace: Text[250];
        DocNameSpace2: Text[250];

    local procedure InsertReminderTaxTotal(var ReminderElement: XmlElement; var IssuedReminderLine: Record "Issued Reminder Line"; TotalTaxAmount: Decimal; CurrencyCode: Code[10]);
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
        IssuedReminderLine.SETFILTER(
          "VAT Calculation Type", '%1|%2',
          IssuedReminderLine."VAT Calculation Type"::"Normal VAT",
          IssuedReminderLine."VAT Calculation Type"::"Full VAT");
        if IssuedReminderLine.FINDFIRST() then begin
            TaxableAmount := 0;
            TaxAmount := 0;
            IssuedReminderLine.SETFILTER("VAT %", '<>0');
            if IssuedReminderLine.FINDSET() then begin
                VATPercentage := IssuedReminderLine."VAT %";
                repeat
                    UpdateTaxAmtAndTaxableAmt(IssuedReminderLine.Amount, IssuedReminderLine."VAT Amount", TaxableAmount, TaxAmount);
                until IssuedReminderLine.NEXT() = 0;
                OIOUBLCommonLogic.InsertTaxSubtotal(
                  TaxTotalElement,
                  IssuedReminderLine."VAT Calculation Type",
                  TaxableAmount,
                  TaxAmount,
                  VATPercentage,
                  CurrencyCode);
            end;

            TaxableAmount := 0;
            TaxAmount := 0;
            IssuedReminderLine.SETRANGE("VAT %", 0);
            IssuedReminderLine.SETRANGE("VAT Calculation Type", IssuedReminderLine."VAT Calculation Type"::"Normal VAT");
            if IssuedReminderLine.FINDSET() then begin
                VATPercentage := IssuedReminderLine."VAT %";
                repeat
                    UpdateTaxAmtAndTaxableAmt(IssuedReminderLine.Amount, IssuedReminderLine."VAT Amount", TaxableAmount, TaxAmount);
                until IssuedReminderLine.NEXT() = 0;
                // Invoice->TaxTotal->TaxSubtotal
                OIOUBLCommonLogic.InsertTaxSubtotal(
                  TaxTotalElement,
                  IssuedReminderLine."VAT Calculation Type",
                  TaxableAmount,
                  TaxAmount,
                  VATPercentage,
                  CurrencyCode);
            end;
        end;

        // Invoice->TaxTotal (for "Reverse Charge VAT")
        IssuedReminderLine.SETRANGE("VAT %");
        IssuedReminderLine.SETRANGE("VAT Calculation Type", IssuedReminderLine."VAT Calculation Type"::"Reverse Charge VAT");
        if IssuedReminderLine.FINDSET() then begin
            TaxableAmount := 0;
            TaxAmount := 0;
            VATPercentage := IssuedReminderLine."VAT %";
            repeat
                UpdateTaxAmtAndTaxableAmt(IssuedReminderLine.Amount, IssuedReminderLine."VAT Amount", TaxableAmount, TaxAmount);
            until IssuedReminderLine.NEXT() = 0;
            OIOUBLCommonLogic.InsertTaxSubtotal(
              TaxTotalElement,
              IssuedReminderLine."VAT Calculation Type",
              TaxableAmount,
              TaxAmount,
              VATPercentage,
              CurrencyCode);
        end;

        ReminderElement.Add(TaxTotalElement);
    end;

    trigger OnRun();
    var
        IssuedReminderLine2: Record "Issued Reminder Line";
        ContactStandardAddress: Record "Standard Address";
        ContactInfo: Record Contact;
        RBMgt: Codeunit "File Management";
        OIOUBLManagement: Codeunit "OIOUBL-Management";
        EnvironmentInfo: Codeunit "Environment Information";
        XMLdocOut: XmlDocument;
        XMLCurrNode: XmlElement;
        CurrencyCode: Code[10];
        FromFile: Text[1024];
        TaxableAmount: Decimal;
        TaxAmount: Decimal;
        TotalTaxAmount: Decimal;
        TotalAmount: Decimal;
        DocumentType: Option "Quote","Order","Invoice","Credit Memo","Blanket Order","Return Order","Finance Charge","Reminder";
        OutputFile: File;
        FileOutstream: Outstream;
    begin
        CODEUNIT.RUN(CODEUNIT::"OIOUBL-Check Issued Reminder", Rec);
        GLSetup.GET();
        CompanyInfo.GET();

        if "Currency Code" = '' then
            CurrencyCode := GLSetup."LCY Code"
        else
            CurrencyCode := "Currency Code";

        IssuedReminderLine.SETRANGE("Reminder No.", "No.");
        IssuedReminderLine.SETFILTER(Type, '>%1', 0);
        IssuedReminderLine.SETFILTER("No.", '<>%1', ' ');
        if NOT IssuedReminderLine.FINDSET() then
            EXIT;

        FromFile := CopyStr(RBMgt.ServerTempFileName(''), 1, MaxStrLen(FromFile));

        // Reminder
        XmlDocument.ReadFrom(OIOUBLCommonLogic.GetReminderHeader(), XMLdocOut);
        XMLdocOut.GetRoot(XMLCurrNode);

        OIOUBLCommonLogic.init(DocNameSpace, DocNameSpace2);

        XMLCurrNode.Add(XmlElement.Create('UBLVersionID', DocNameSpace, '2.0'));
        XMLCurrNode.Add(XmlElement.Create('CustomizationID', DocNameSpace, 'OIOUBL-2.02'));

        XMLCurrNode.Add(
          XmlElement.Create('ProfileID', DocNameSpace,
            XmlAttribute.Create('schemeID', 'urn:oioubl:id:profileid-1.2'),
            XmlAttribute.Create('schemeAgencyID', '320'),
            'Procurement-BilSim-1.0'));

        XMLCurrNode.Add(XmlElement.Create('ID', DocNameSpace, "No."));
        XMLCurrNode.Add(XmlElement.Create('CopyIndicator', DocNameSpace,
          OIOUBLDocumentEncode.BooleanToText("OIOUBL-Electronic Reminder Created")));
        XMLCurrNode.Add(XmlElement.Create('IssueDate', DocNameSpace,
          OIOUBLDocumentEncode.DateToText("Posting Date")));

        XMLCurrNode.Add(
          XmlElement.Create('ReminderTypeCode', DocNameSpace,
            XmlAttribute.Create('listID', 'urn:oioubl.codelist:remindertypecode-1.1'),
            XmlAttribute.Create('listAgencyID', '320'),
            'Advis'));

        XMLCurrNode.Add(XmlElement.Create('ReminderSequenceNumeric', DocNameSpace, '1'));
        XMLCurrNode.Add(XmlElement.Create('DocumentCurrencyCode', DocNameSpace, CurrencyCode));
        XMLCurrNode.Add(XmlElement.Create('AccountingCostCode', DocNameSpace, "OIOUBL-Account Code"));

        // Reminder->AccountingSupplierParty
        OIOUBLCommonLogic.InsertAccountingSupplierParty(XMLCurrNode, '');

        // Reminder->AccountingCustomerParty
        ContactStandardAddress.Address := "Address";
        ContactStandardAddress."Address 2" := "Address 2";
        ContactStandardAddress.City := "City";
        ContactStandardAddress."Post Code" := "Post Code";
        ContactStandardAddress."Country/Region Code" := "Country/Region Code";
        ContactInfo.Name := "Contact";
        ContactInfo."Phone No." := "OIOUBL-Contact Phone No.";
        ContactInfo."Fax No." := "OIOUBL-Contact Fax No.";
        ContactInfo."E-Mail" := "OIOUBL-Contact E-Mail";
        OIOUBLCommonLogic.InsertAccountingCustomerParty(XMLCurrNode,
          "OIOUBL-GLN",
          "VAT Registration No.",
          "Name",
          ContactStandardAddress,
          ContactInfo);

        // Reminder->PaymentMeans
        OIOUBLCommonLogic.InsertPaymentMeans(XMLCurrNode, "Due Date");

        // Reminder->PaymentTerms
        TotalAmount := 0;
        IssuedReminderLine2.RESET();
        IssuedReminderLine2.COPY(IssuedReminderLine);
        if IssuedReminderLine2.FINDSET() then
            repeat
                TotalAmount := TotalAmount + IssuedReminderLine2.Amount + IssuedReminderLine2."VAT Amount";
            until IssuedReminderLine2.NEXT() = 0;
        OIOUBLCommonLogic.InsertPaymentTerms(XMLCurrNode,
          '',
          0,
          CurrencyCode,
          CalcDate('<0D>'),
          "Due Date",
          TotalAmount);

        // Reminder->TaxTotal (for ("Normal VAT" AND "VAT %" <> 0) OR "Full VAT")
        IssuedReminderLine2.RESET();
        IssuedReminderLine2.COPY(IssuedReminderLine);
        IssuedReminderLine2.SETFILTER(
          "VAT Calculation Type", '%1|%2|%3',
          IssuedReminderLine2."VAT Calculation Type"::"Normal VAT",
          IssuedReminderLine2."VAT Calculation Type"::"Full VAT",
          IssuedReminderLine2."VAT Calculation Type"::"Reverse Charge VAT");
        if IssuedReminderLine2.FINDFIRST() then begin
            TotalTaxAmount := 0;
            IssuedReminderLine2.CALCSUMS(Amount, Amount);
            TotalTaxAmount := IssuedReminderLine2.Amount - IssuedReminderLine2.Amount;

            InsertReminderTaxTotal(XMLCurrNode, IssuedReminderLine2, TotalTaxAmount, CurrencyCode);
        end;

        // Reminder->LegalMonetaryTotal
        TaxableAmount := 0;
        TaxAmount := 0;

        IssuedReminderLine2.RESET();
        IssuedReminderLine2.COPY(IssuedReminderLine);
        if IssuedReminderLine2.FINDSET() then
            repeat
                TaxableAmount := TaxableAmount + IssuedReminderLine2.Amount;
                TaxAmount := TaxAmount + IssuedReminderLine2."VAT Amount";
            until IssuedReminderLine2.NEXT() = 0;

        OIOUBLCommonLogic.InsertLegalMonetaryTotal(XMLCurrNode, TaxableAmount, TaxAmount, TotalAmount, 0, CurrencyCode);

        // Reminder->ReminderLine
        repeat
            if IssuedReminderLine.Amount <> 0 then begin
                IssuedReminderLine.TESTFIELD(Description);
                OIOUBLCommonLogic.InsertReminderLine(XMLCurrNode,
                  IssuedReminderLine."Line No.",
                  IssuedReminderLine.Description,
                  IssuedReminderLine.Amount,
                  CurrencyCode,
                  IssuedReminderLine."OIOUBL-Account Code");
            end;
        until IssuedReminderLine.NEXT() = 0;

        SalesSetup.GET();

        OutputFile.create(FromFile);
        OutputFile.CreateOutStream(FileOutstream);
        OnRunOnBeforeXmlDocumentWriteToFileStream(XMLdocOut, Rec, DocNameSpace, DocNameSpace2);
        XMLdocOut.WriteTo(FileOutstream);
        OutputFile.Close();

        if RBMgt.IsLocalFileSystemAccessible() AND NOT EnvironmentInfo.IsSaaS() then
            SalesSetup.VerifyAndSetOIOUBLSetupPath(DocumentType::Reminder);

        OIOUBLManagement.ExportXMLFile("No.", FromFile, SalesSetup."OIOUBL-Reminder Path");

        IssuedReminder.GET("No.");
        IssuedReminder."OIOUBL-Electronic Reminder Created" := TRUE;
        IssuedReminder.MODIFY();
    end;

    procedure UpdateTaxAmtAndTaxableAmt(Amount: Decimal; VATAmount: Decimal; var TaxableAmountParam: Decimal; var TaxAmountParam: Decimal);
    begin
        TaxableAmountParam := TaxableAmountParam + Amount;
        TaxAmountParam := TaxAmountParam + VATAmount
    end;

    [IntegrationEvent(false, false)]
    local procedure OnRunOnBeforeXmlDocumentWriteToFileStream(var XMLdocOut: XmlDocument; IssuedReminderHeader: Record "Issued Reminder Header"; DocNameSpace: Text[250]; DocNameSpace2: Text[250])
    begin
    end;
}