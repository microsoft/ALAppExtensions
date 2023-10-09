// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------
namespace Microsoft.Bank.Payment;

using Microsoft.Finance.VAT.Calculation;
using Microsoft.Foundation.Company;
using Microsoft.Sales.History;
using Microsoft.Sales.Receivables;
using Microsoft.Service.History;

table 11511 "Swiss QR-Bill Billing Info"
{
    DataClassification = CustomerContent;
    DrillDownPageId = "Swiss QR-Bill Billing Info";

    fields
    {
        field(1; "Code"; Code[20])
        {
            Caption = 'Code';
            NotBlank = true;
        }
        field(2; "Document No."; Boolean)
        {
            Caption = 'Document No.';
        }
        field(3; "Document Date"; Boolean)
        {
            Caption = 'Document Date';
        }
        field(5; "VAT Number"; Boolean)
        {
            Caption = 'VAT Number';
        }
        field(6; "VAT Date"; Boolean)
        {
            Caption = 'VAT Date';
        }
        field(7; "VAT Details"; Boolean)
        {
            Caption = 'VAT Details';
        }
        field(9; "Payment Terms"; Boolean)
        {
            Caption = 'Payment Terms';
        }
    }

    keys
    {
        key(PK; Code)
        {
            Clustered = true;
        }
    }

    var
        SwissQRBillMgt: Codeunit "Swiss QR-Bill Mgt.";
        SwissQRBillBillingInfo: Codeunit "Swiss QR-Bill Billing Info";
        DefaultCodeLbl: Label 'DEFAULT';

    internal procedure InitDefault()
    begin
        Init();
        Code := CopyStr(DefaultCodeLbl, 1, MaxStrLen(Code));
        "Document No." := true;
        "Document Date" := true;
        "VAT Date" := true;
        "VAT Number" := true;
        "VAT Details" := true;
        "Payment Terms" := true;
    end;

    internal procedure GetBillingInformation(CustomerLedgerEntryNo: Integer): Text[140]
    var
        CompanyInformation: Record "Company Information";
        CustLedgerEntry: Record "Cust. Ledger Entry";
        SalesInvoiceLine: Record "Sales Invoice Line";
        ServiceInvoiceLine: Record "Service Invoice Line";
        SalesInvoiceHeader: Record "Sales Invoice Header";
        ServiceInvoiceHeader: Record "Service Invoice Header";
        TempVATAmountLine: Record "VAT Amount Line" temporary;
        PaymentTermsCode: Code[10];
    begin
        CompanyInformation.Get();
        CustLedgerEntry.Get(CustomerLedgerEntryNo);
        if CustLedgerEntry."Document Type" = CustLedgerEntry."Document Type"::Invoice then
            case true of
                SalesInvoiceHeader.Get(CustLedgerEntry."Document No."):
                    begin
                        PaymentTermsCode := SalesInvoiceHeader."Payment Terms Code";
                        SalesInvoiceLine.CalcVATAmountLines(SalesInvoiceHeader, TempVATAmountLine);
                    end;
                SwissQRBillMgt.FindServiceInvoiceFromLedgerEntry(ServiceInvoiceHeader, CustLedgerEntry):
                    begin
                        PaymentTermsCode := ServiceInvoiceHeader."Payment Terms Code";
                        ServiceInvoiceLine.CalcVATAmountLines(ServiceInvoiceHeader, TempVATAmountLine);
                    end;
            end;

        exit(
            GetDocumentBillingInfo(
                CustLedgerEntry."Document No.",
                CustLedgerEntry."Document Date",
                CompanyInformation."VAT Registration No.",
                CustLedgerEntry."Posting Date",
                TempVATAmountLine,
                PaymentTermsCode));
    end;

    local procedure GetDocumentBillingInfo(DoumentNo: Code[20]; DocumentDate: Date; VATRegNo: Text; VATDate: Date; var TempVATAmountLine: Record "VAT Amount Line"; PaymentTermsCode: Code[10]): Text[140]
    var
        TempSwissQRBillBillingDetail: Record "Swiss QR-Bill Billing Detail" temporary;
    begin
        if "Document No." then
            AddDetailsIfNotBlanked(TempSwissQRBillBillingDetail, TempSwissQRBillBillingDetail."Tag Type"::"Document No.", DoumentNo);
        if "Document Date" then
            AddDetailsIfNotBlanked(
                TempSwissQRBillBillingDetail,
                TempSwissQRBillBillingDetail."Tag Type"::"Document Date", SwissQRBillBillingInfo.FormatDate(DocumentDate));
        if "VAT Number" then
            AddDetailsIfNotBlanked(
                TempSwissQRBillBillingDetail,
                TempSwissQRBillBillingDetail."Tag Type"::"VAT Registration No.", SwissQRBillBillingInfo.FormatVATRegNo(VATRegNo));
        if "VAT Date" then
            AddDetailsIfNotBlanked(
                TempSwissQRBillBillingDetail,
                TempSwissQRBillBillingDetail."Tag Type"::"VAT Date", SwissQRBillBillingInfo.FormatDate(VATDate));
        if "VAT Details" then
            AddDetailsIfNotBlanked(
                TempSwissQRBillBillingDetail,
                TempSwissQRBillBillingDetail."Tag Type"::"VAT Details", SwissQRBillBillingInfo.GetDocumentVATDetails(TempVATAmountLine));
        if "Payment Terms" then
            AddDetailsIfNotBlanked(
                TempSwissQRBillBillingDetail,
                TempSwissQRBillBillingDetail."Tag Type"::"Payment Terms", SwissQRBillBillingInfo.GetDocumentPaymentTerms(PaymentTermsCode));

        exit(SwissQRBillBillingInfo.CreateBillingInfoString(TempSwissQRBillBillingDetail, 'S1'));
    end;

    local procedure AddDetailsIfNotBlanked(var SwissQRBillBillingDetail: Record "Swiss QR-Bill Billing Detail"; TagType: Enum "Swiss QR-Bill Billing Detail"; DetailsValue: Text)
    begin
        if DetailsValue <> '' then
            SwissQRBillBillingDetail.AddBufferRecord('S1', TagType, DetailsValue, '');
    end;
}
