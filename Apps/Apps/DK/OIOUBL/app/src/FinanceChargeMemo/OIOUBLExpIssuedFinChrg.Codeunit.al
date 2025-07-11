// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------
namespace Microsoft.EServices.EDocument;

using Microsoft.CRM.Contact;
using Microsoft.Finance.GeneralLedger.Setup;
using Microsoft.Foundation.Address;
using Microsoft.Foundation.Company;
using Microsoft.Sales.FinanceCharge;
using Microsoft.Sales.Setup;
using System.Utilities;

codeunit 13638 "OIOUBL-Exp. Issued Fin. Chrg"
{
    TableNo = "Issued Fin. Charge Memo Header";
    Permissions = tabledata "Issued Fin. Charge Memo Header" = rm;

    var
        GLSetup: Record "General Ledger Setup";
        CompanyInfo: Record "Company Information";
        IssuedFinChargeMemo: Record "Issued Fin. Charge Memo Header";
        IssuedFinChargeMemoLine: Record "Issued Fin. Charge Memo Line";
        SalesSetup: Record "Sales & Receivables Setup";
        OIOUBLDocumentEncode: Codeunit "OIOUBL-Document Encode";
        OIOUBLXMLGenerator: Codeunit "OIOUBL-Common Logic";
        DocNameSpace: Text[250];
        DocNameSpace2: Text[250];

    local procedure InsertReminderTaxTotal(var ReminderElement: XmlElement; var IssuedFinChargeMemoLineLocal: Record "Issued Fin. Charge Memo Line"; TotalTaxAmount: Decimal; CurrencyCode: Code[10]);
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
        IssuedFinChargeMemoLineLocal.SETFILTER(
          "VAT Calculation Type", '%1|%2',
          IssuedFinChargeMemoLineLocal."VAT Calculation Type"::"Normal VAT",
          IssuedFinChargeMemoLineLocal."VAT Calculation Type"::"Full VAT");
        if IssuedFinChargeMemoLineLocal.FINDFIRST() then begin
            TaxableAmount := 0;
            TaxAmount := 0;
            IssuedFinChargeMemoLineLocal.SETFILTER("VAT %", '<>0');
            if IssuedFinChargeMemoLineLocal.FINDSET() then begin
                VATPercentage := IssuedFinChargeMemoLineLocal."VAT %";
                repeat
                    UpdateTaxAmtAndTaxableAmt(IssuedFinChargeMemoLineLocal.Amount, IssuedFinChargeMemoLineLocal."VAT Amount", TaxableAmount, TaxAmount);
                until IssuedFinChargeMemoLineLocal.NEXT() = 0;
                OIOUBLXMLGenerator.InsertTaxSubtotal(
                    TaxTotalElement, IssuedFinChargeMemoLineLocal."VAT Calculation Type".AsInteger(), TaxableAmount, TaxAmount, VATPercentage, CurrencyCode);
            end;
        end;

        IssuedFinChargeMemoLineLocal.SETRANGE("VAT %", 0);
        IssuedFinChargeMemoLineLocal.SETRANGE("VAT Calculation Type", IssuedFinChargeMemoLineLocal."VAT Calculation Type"::"Normal VAT");
        if IssuedFinChargeMemoLineLocal.FINDSET() then begin
            TaxableAmount := 0;
            TaxAmount := 0;
            VATPercentage := IssuedFinChargeMemoLineLocal."VAT %";
            repeat
                UpdateTaxAmtAndTaxableAmt(IssuedFinChargeMemoLineLocal.Amount, IssuedFinChargeMemoLineLocal."VAT Amount", TaxableAmount, TaxAmount);
            until IssuedFinChargeMemoLineLocal.NEXT() = 0;
            // Invoice->TaxTotal->TaxSubtotal
            OIOUBLXMLGenerator.InsertTaxSubtotal(
                TaxTotalElement, IssuedFinChargeMemoLineLocal."VAT Calculation Type".AsInteger(), TaxableAmount, TaxAmount, VATPercentage, CurrencyCode);
        end;

        // Invoice->TaxTotal (for "Reverse Charge VAT")
        IssuedFinChargeMemoLineLocal.SETRANGE("VAT %");
        IssuedFinChargeMemoLineLocal.SETRANGE("VAT Calculation Type", IssuedFinChargeMemoLineLocal."VAT Calculation Type"::"Reverse Charge VAT");
        if IssuedFinChargeMemoLineLocal.FINDSET() then begin
            TaxableAmount := 0;
            TaxAmount := 0;
            VATPercentage := IssuedFinChargeMemoLineLocal."VAT %";
            repeat
                UpdateTaxAmtAndTaxableAmt(IssuedFinChargeMemoLineLocal.Amount, IssuedFinChargeMemoLineLocal."VAT Amount", TaxableAmount, TaxAmount);
            until IssuedFinChargeMemoLineLocal.NEXT() = 0;
            OIOUBLXMLGenerator.InsertTaxSubtotal(
                TaxTotalElement, IssuedFinChargeMemoLineLocal."VAT Calculation Type".AsInteger(), TaxableAmount, TaxAmount, VATPercentage, CurrencyCode);
        end;

        ReminderElement.Add(TaxTotalElement);
    end;

    trigger OnRun();
    var

        TempBlob: Codeunit "Temp Blob";
        OIOUBLManagement: Codeunit "OIOUBL-Management";
    begin
        GenerateTempBlob(Rec, TempBlob);

        OIOUBLManagement.ExportXMLFile("No.", TempBlob, SalesSetup."OIOUBL-Fin. Chrg. Memo Path", '');

        IssuedFinChargeMemo.GET("No.");
        IssuedFinChargeMemo."OIOUBL-Elec. Fin. Charge Memo Created" := TRUE;
        IssuedFinChargeMemo.MODIFY();
    end;

    procedure GenerateTempBlob(IssuedFinChargeMemoHeader: Record "Issued Fin. Charge Memo Header"; var TempBlob: Codeunit "Temp Blob");
    var
        IssuedFinChargeMemoLine2: Record "Issued Fin. Charge Memo Line";
        PartyContact: Record Contact;
        PostalAddress: Record "Standard Address";
        XMLdocOut: XmlDocument;
        XMLCurrNode: XmlElement;
        CurrencyCode: Code[10];
        TaxableAmount: Decimal;
        TaxAmount: Decimal;
        TotalTaxAmount: Decimal;
        TotalAmount: Decimal;
        FileOutstream: Outstream;
    begin
        CODEUNIT.RUN(CODEUNIT::"OIOUBL-Check Issued Fin. Chrg", IssuedFinChargeMemoHeader);
        GLSetup.GET();
        CompanyInfo.GET();

        if IssuedFinChargeMemoHeader."Currency Code" = '' then
            CurrencyCode := GLSetup."LCY Code"
        else
            CurrencyCode := IssuedFinChargeMemoHeader."Currency Code";

        if NOT ContainsValidLine(IssuedFinChargeMemoLine, IssuedFinChargeMemoHeader."No.") then
            EXIT;

        // FinCharge
        XmlDocument.ReadFrom(OIOUBLXMLGenerator.GetReminderHeader(), XMLdocOut);
        XMLdocOut.GetRoot(XMLCurrNode);

        OIOUBLXMLGenerator.init(DocNameSpace, DocNameSpace2);

        XMLCurrNode.Add(XmlElement.Create('UBLVersionID', DocNameSpace, '2.0'));
        XMLCurrNode.Add(XmlElement.Create('CustomizationID', DocNameSpace, 'OIOUBL-2.02'));

        XMLCurrNode.Add(
          XmlElement.Create('ProfileID', DocNameSpace,
            XmlAttribute.Create('schemeID', 'urn:oioubl:id:profileid-1.2'),
            XmlAttribute.Create('schemeAgencyID', '320'),
            'Procurement-BilSim-1.0'));

        XMLCurrNode.Add(XmlElement.Create('ID', DocNameSpace, IssuedFinChargeMemoHeader."No."));
        XMLCurrNode.Add(XmlElement.Create('CopyIndicator', DocNameSpace,
          OIOUBLDocumentEncode.BooleanToText(IssuedFinChargeMemoHeader."OIOUBL-Elec. Fin. Charge Memo Created")));
        XMLCurrNode.Add(XmlElement.Create('IssueDate', DocNameSpace,
          OIOUBLDocumentEncode.DateToText(IssuedFinChargeMemoHeader."Posting Date")));

        XMLCurrNode.Add(
          XmlElement.Create('ReminderTypeCode', DocNameSpace,
            XmlAttribute.Create('listID', 'urn:oioubl.codelist:remindertypecode-1.1'),
            XmlAttribute.Create('listAgencyID', '320'),
            'Reminder'));

        XMLCurrNode.Add(XmlElement.Create('ReminderSequenceNumeric', DocNameSpace, '1'));
        XMLCurrNode.Add(XmlElement.Create('DocumentCurrencyCode', DocNameSpace, CurrencyCode));
        XMLCurrNode.Add(XmlElement.Create('AccountingCostCode', DocNameSpace, IssuedFinChargeMemoHeader."OIOUBL-Account Code"));

        // FinCharge->AccountingSupplierParty
        OIOUBLXMLGenerator.InsertAccountingSupplierParty(XMLCurrNode, '');

        // FinCharge->AccountingCustomerParty
        PostalAddress.Address := IssuedFinChargeMemoHeader.Address;
        PostalAddress."Address 2" := IssuedFinChargeMemoHeader."Address 2";
        PostalAddress.City := IssuedFinChargeMemoHeader.City;
        PostalAddress."Post Code" := IssuedFinChargeMemoHeader."Post Code";
        PostalAddress."Country/Region Code" := IssuedFinChargeMemoHeader."Country/Region Code";
        PartyContact.Name := IssuedFinChargeMemoHeader.Contact;
        PartyContact."Phone No." := IssuedFinChargeMemoHeader."OIOUBL-Contact Phone No.";
        PartyContact."Fax No." := IssuedFinChargeMemoHeader."OIOUBL-Contact Fax No.";
        PartyContact."E-Mail" := IssuedFinChargeMemoHeader."OIOUBL-Contact E-Mail";
        OIOUBLXMLGenerator.InsertAccountingCustomerParty(XMLCurrNode,
          IssuedFinChargeMemoHeader."OIOUBL-GLN",
          IssuedFinChargeMemoHeader."VAT Registration No.",
          IssuedFinChargeMemoHeader.Name,
          PostalAddress,
          PartyContact);

        // FinCharge->PaymentMeans
        OIOUBLXMLGenerator.InsertPaymentMeans(XMLCurrNode, IssuedFinChargeMemoHeader."Due Date");

        // FinCharge->PaymentTerms
        TotalAmount := 0;
        IssuedFinChargeMemoLine2.RESET();
        IssuedFinChargeMemoLine2.COPY(IssuedFinChargeMemoLine);
        if IssuedFinChargeMemoLine2.FINDSET() then
            repeat
                TotalAmount := TotalAmount + IssuedFinChargeMemoLine2.Amount + IssuedFinChargeMemoLine2."VAT Amount";
            until IssuedFinChargeMemoLine2.NEXT() = 0;
        OIOUBLXMLGenerator.InsertPaymentTerms(
          XMLCurrNode, '', 0, CurrencyCode, CalcDate('<0D>'), IssuedFinChargeMemoHeader."Due Date", TotalAmount);

        // FinCharge->TaxTotal (for ("Normal VAT" AND "VAT %" <> 0) OR "Full VAT")
        IssuedFinChargeMemoLine2.RESET();
        IssuedFinChargeMemoLine2.COPY(IssuedFinChargeMemoLine);
        IssuedFinChargeMemoLine2.SETFILTER(
          "VAT Calculation Type", '%1|%2|%3',
          IssuedFinChargeMemoLine2."VAT Calculation Type"::"Normal VAT",
          IssuedFinChargeMemoLine2."VAT Calculation Type"::"Full VAT",
          IssuedFinChargeMemoLine2."VAT Calculation Type"::"Reverse Charge VAT");
        if IssuedFinChargeMemoLine2.FINDFIRST() then begin
            TotalTaxAmount := 0;
            IssuedFinChargeMemoLine2.CALCSUMS(Amount, Amount);
            TotalTaxAmount := IssuedFinChargeMemoLine2.Amount - IssuedFinChargeMemoLine2.Amount;

            InsertReminderTaxTotal(XMLCurrNode, IssuedFinChargeMemoLine2, TotalTaxAmount, CurrencyCode);
        end;

        // FinCharge->LegalMonetaryTotal
        TaxableAmount := 0;
        TaxAmount := 0;

        IssuedFinChargeMemoLine2.RESET();
        IssuedFinChargeMemoLine2.COPY(IssuedFinChargeMemoLine);
        if IssuedFinChargeMemoLine2.FINDSET() then
            repeat
                TaxableAmount := TaxableAmount + IssuedFinChargeMemoLine2.Amount;
                TaxAmount := TaxAmount + IssuedFinChargeMemoLine2."VAT Amount";
            until IssuedFinChargeMemoLine2.NEXT() = 0;

        OIOUBLXMLGenerator.InsertLegalMonetaryTotal(XMLCurrNode, TaxableAmount, TaxAmount, TotalAmount, 0, CurrencyCode);

        // FinCharge->ReminderLine
        repeat
            if IssuedFinChargeMemoLine.Amount <> 0 then begin
                IssuedFinChargeMemoLine.TESTFIELD(Description);
                OIOUBLXMLGenerator.InsertReminderLine(XMLCurrNode,
                  IssuedFinChargeMemoLine."Line No.",
                  IssuedFinChargeMemoLine.Description,
                  IssuedFinChargeMemoLine.Amount,
                  CurrencyCode,
                  IssuedFinChargeMemoLine."OIOUBL-Account Code");
            end;
        until IssuedFinChargeMemoLine.NEXT() = 0;

        SalesSetup.GET();

        TempBlob.CreateOutStream(FileOutstream);
        OnRunOnBeforeXmlDocumentWriteToFileStream(XMLdocOut, IssuedFinChargeMemoHeader, DocNameSpace, DocNameSpace2);
        XMLdocOut.WriteTo(FileOutstream);
    end;

    procedure UpdateTaxAmtAndTaxableAmt(Amount: Decimal; VATAmount: Decimal; var TaxableAmountParam: Decimal; var TaxAmountParam: Decimal);
    begin
        TaxableAmountParam := TaxableAmountParam + Amount;
        TaxAmountParam := TaxAmountParam + VATAmount
    end;

    procedure ContainsValidLine(var IssuedFinChargeMemoLine: Record "Issued Fin. Charge Memo Line"; IssuedFinChargeMemoHeaderNo: Code[20]) ReturnValue: Boolean;
    begin
        ReturnValue := FALSE;
        WITH IssuedFinChargeMemoLine do begin
            SETRANGE("Finance Charge Memo No.", IssuedFinChargeMemoHeaderNo);
            SETFILTER(Type, '>%1', 0);
            if FINDSET() then
                repeat
                    ReturnValue := ((Type = Type::"Customer Ledger Entry") AND ("Document No." <> '')) OR
                      ((Type = Type::"G/L Account") AND ("No." <> ''));
                until (NEXT() = 0) OR ReturnValue;
        end;
        exit(ReturnValue)
    end;

    [IntegrationEvent(false, false)]
    local procedure OnRunOnBeforeXmlDocumentWriteToFileStream(var XMLdocOut: XmlDocument; IssuedFinChargeMemoHeader: Record "Issued Fin. Charge Memo Header"; DocNameSpace: Text[250]; DocNameSpace2: Text[250])
    begin
    end;
}
