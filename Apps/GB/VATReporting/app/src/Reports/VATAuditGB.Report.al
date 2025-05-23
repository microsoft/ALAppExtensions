// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------
namespace Microsoft.Finance.VAT.Reporting;

using Microsoft.Finance.VAT.Ledger;
using Microsoft.Purchases.Vendor;
using Microsoft.Sales.Customer;
using Microsoft.Sales.Receivables;
using System.IO;
using System.Telemetry;
using System.Utilities;

report 10544 "VAT Audit GB"
{
    Caption = 'VAT Audit';
    ProcessingOnly = true;

    dataset
    {
        dataitem(Customer; Customer)
        {
            DataItemTableView = sorting("No.");

            trigger OnAfterGetRecord()
            begin
                CustomerOutStr.WriteText(
                  StrSubstNo(
                    SevenDelimitedValuesTxt,
                    "No.",
                    Name,
                    Address,
                    "Address 2",
                    City,
                    County,
                    "Post Code") + CRLF);

                Window.Update(1, "No.");
            end;

            trigger OnPostDataItem()
            var
                InStream: InStream;
            begin
                if CustomerExport then begin
                    CustomerTempBlob.CreateInStream(InStream);
                    RBMgt.DownloadFromStreamHandler(InStream, '', 'C:', '', ToFile);
                end;
            end;

            trigger OnPreDataItem()
            begin
                if not CustomerExport then
                    CurrReport.Break();
                ToFile := CustomerFileName;

                CustomerTempBlob.CreateOutStream(CustomerOutStr);
                CustomerOutStr.WriteText(
                  StrSubstNo(
                    SevenDelimitedValuesTxt,
                    FieldCaption("No."),
                    FieldCaption(Name),
                    FieldCaption(Address),
                    FieldCaption("Address 2"),
                    FieldCaption(City),
                    FieldCaption(County),
                    FieldCaption("Post Code")) + CRLF);

                Window.Open(Text1041000Txt);
            end;
        }
        dataitem(OpenPayments; "Cust. Ledger Entry")
        {
            CalcFields = "Original Amt. (LCY)";
            DataItemTableView = sorting("Customer No.", Open, Positive) where(Open = const(true), Positive = const(false));

            trigger OnAfterGetRecord()
            begin
                OpenPaymentOutStr.WriteText(
                  StrSubstNo(
                    SevenDelimitedValuesTxt,
                    "Entry No.",
                    "Customer No.",
                    Description,
                    Format("Document Type"),
                    "Document No.",
                    "Posting Date",
                    "Original Amt. (LCY)") + CRLF);

                Window.Update(1, "Entry No.");
            end;

            trigger OnPostDataItem()
            var
                InStream: InStream;
            begin
                if OpenPaymentExport then begin
                    OpenPaymentTempBlob.CreateInStream(InStream);
                    RBMgt.DownloadFromStreamHandler(InStream, '', 'C:', '', ToFile);
                end;
            end;

            trigger OnPreDataItem()
            begin
                if not OpenPaymentExport then
                    CurrReport.Break();
                ToFile := OpenPaymentFileName;

                OpenPaymentTempBlob.CreateOutStream(OpenPaymentOutStr);
                OpenPaymentOutStr.WriteText(
                  StrSubstNo(
                    SevenDelimitedValuesTxt,
                    FieldCaption("Entry No."),
                    FieldCaption("Customer No."),
                    FieldCaption(Description),
                    FieldCaption("Document Type"),
                    FieldCaption("Document No."),
                    FieldCaption("Posting Date"),
                    FieldCaption("Original Amt. (LCY)")) + CRLF);

                Window.Open(Text1041001Txt);
            end;
        }
        dataitem(LateInvoicing; "Cust. Ledger Entry")
        {
            CalcFields = "Original Amt. (LCY)";
            DataItemTableView = sorting("Customer No.", Open, Positive) where(Open = const(false), Positive = const(false));

            trigger OnAfterGetRecord()
            var
                CustLedgEntry: Record "Cust. Ledger Entry";
                InvPostingDates: Text;
                LateInvoice: Boolean;
            begin
                LateInvoice := false;
                InvPostingDates := '';
                CustLedgEntry.Reset();
                CustLedgEntry.SetCurrentKey("Entry No.");
                CustLedgEntry.SetRange("Entry No.", "Closed by Entry No.");
                if CustLedgEntry.Find('-') then
                    repeat
                        if (CustLedgEntry."Posting Date" - "Posting Date") > LateInvoiceDelay then begin
                            LateInvoice := true;
                            if StrLen(InvPostingDates) > 1 then
                                InvPostingDates := InvPostingDates.Substring(1, 250) + ';';
                            if StrLen(InvPostingDates) < 240 then
                                InvPostingDates := InvPostingDates + Format(CustLedgEntry."Posting Date");
                        end;
                    until CustLedgEntry.Next() = 0;
                CustLedgEntry.Reset();
                CustLedgEntry.SetCurrentKey("Closed by Entry No.");
                CustLedgEntry.SetRange("Closed by Entry No.", "Entry No.");
                if CustLedgEntry.Find('-') then
                    repeat
                        if (CustLedgEntry."Posting Date" - "Posting Date") > LateInvoiceDelay then begin
                            LateInvoice := true;
                            if StrLen(InvPostingDates) > 1 then
                                InvPostingDates := InvPostingDates + ';';
                            if StrLen(InvPostingDates) < 240 then
                                InvPostingDates := InvPostingDates + Format(CustLedgEntry."Posting Date");
                        end;
                    until CustLedgEntry.Next() = 0;

                if not LateInvoice then
                    CurrReport.Skip();

                LateInvoicingOutStr.WriteText(
                  StrSubstNo(
                    EightDelimitedValuesTxt,
                    "Entry No.",
                    "Customer No.",
                    Description,
                    Format("Document Type"),
                    "Document No.",
                    "Posting Date",
                    InvPostingDates,
                    "Original Amt. (LCY)") + CRLF);

                Window.Update(1, "Entry No.");
            end;

            trigger OnPostDataItem()
            var
                InStream: InStream;
            begin
                if LateInvoicingExport then begin
                    LateInvoicingTempBlob.CreateInStream(InStream);
                    RBMgt.DownloadFromStreamHandler(InStream, '', 'C:', '', ToFile);
                end;
            end;

            trigger OnPreDataItem()
            begin
                if not LateInvoicingExport then
                    CurrReport.Break();
                ToFile := LateInvoicingFileName;

                LateInvoicingTempBlob.CreateOutStream(LateInvoicingOutStr);
                LateInvoicingOutStr.WriteText(
                  StrSubstNo(
                    EightDelimitedValuesTxt,
                    FieldCaption("Entry No."),
                    FieldCaption("Customer No."),
                    FieldCaption(Description),
                    FieldCaption("Document Type"),
                    FieldCaption("Document No."),
                    Text1041002Txt + FieldCaption("Posting Date"),
                    Text1041003Txt + FieldCaption("Posting Date"),
                    FieldCaption("Original Amt. (LCY)")) + CRLF);

                Window.Open(Text1041004Txt);
            end;
        }
        dataitem(Vendor; Vendor)
        {
            DataItemTableView = sorting("No.");

            trigger OnAfterGetRecord()
            begin
                VendorOutStr.WriteText(
                  StrSubstNo(
                    EightDelimitedValuesTxt,
                    "No.",
                    Name,
                    Address,
                    "Address 2",
                    City,
                    County,
                    "Post Code",
                    true) + CRLF);

                Window.Update(1, "No.");
            end;

            trigger OnPostDataItem()
            var
                InStream: InStream;
            begin
                if VendorExport then begin
                    VendorTempBlob.CreateInStream(InStream);
                    RBMgt.DownloadFromStreamHandler(InStream, '', 'C:', '', ToFile);
                end;
            end;

            trigger OnPreDataItem()
            begin
                if not VendorExport then
                    CurrReport.Break();
                ToFile := VendorFileName;

                VendorTempBlob.CreateOutStream(VendorOutStr);
                VendorOutStr.WriteText(
                  StrSubstNo(
                    SevenDelimitedValuesTxt,
                    FieldCaption("No."),
                    FieldCaption(Name),
                    FieldCaption(Address),
                    FieldCaption("Address 2"),
                    FieldCaption(City),
                    FieldCaption(County),
                    FieldCaption("Post Code")) + CRLF);

                Window.Open(Text1041005Txt);
            end;
        }
        dataitem("VAT Entry"; "VAT Entry")
        {
            DataItemTableView = sorting("Document No.", "VAT Reporting Date");
            RequestFilterFields = "VAT Reporting Date", "Posting Date";

            trigger OnAfterGetRecord()
            begin
                VATEntryOutStr.WriteText(
                  StrSubstNo(
                    ElevenDelimitedValuesTxt,
                    "Posting Date",
                    "VAT Reporting Date",
                    "Document No.",
                    Format("Document Type"),
                    Base,
                    Amount,
                    Format("VAT Calculation Type"),
                    Format(Type),
                    "Bill-to/Pay-to No.",
                    "External Document No.",
                    "Entry No.") + CRLF);

                Window.Update(1, "Entry No.");
            end;

            trigger OnPostDataItem()
            var
                InStream: InStream;
            begin
                if VATEntryExport then begin
                    VATEntryTempBlob.CreateInStream(InStream);
                    RBMgt.DownloadFromStreamHandler(InStream, '', 'C:', '', ToFile);
                end;
            end;

            trigger OnPreDataItem()
            begin
                if not VATEntryExport then
                    CurrReport.Break();

                ToFile := VATEntryFileName;

                VATEntryTempBlob.CreateOutStream(VATEntryOutStr);
                VATEntryOutStr.WriteText(
                  StrSubstNo(
                    ElevenDelimitedValuesTxt,
                    FieldCaption("Posting Date"),
                    FieldCaption("VAT Reporting Date"),
                    FieldCaption("Document No."),
                    FieldCaption("Document Type"),
                    FieldCaption(Base),
                    FieldCaption(Amount),
                    FieldCaption("VAT Calculation Type"),
                    FieldCaption(Type),
                    FieldCaption("Bill-to/Pay-to No."),
                    FieldCaption("External Document No."),
                    FieldCaption("Entry No.")) + CRLF);

                Window.Open(Text1041006Txt);
            end;
        }
    }

    requestpage
    {
        SaveValues = true;

        layout
        {
            area(content)
            {
                group(Options)
                {
                    Caption = 'Options';
                    field("Customer Export"; CustomerExport)
                    {
                        ApplicationArea = Basic, Suite;
                        Caption = 'Export Customers';
                        ToolTip = 'Specifies that you want to export the Customer table.';
                    }
                    field("Customer File Name"; CustomerFileName)
                    {
                        ApplicationArea = All;
                        Caption = 'Customer File';
                        ToolTip = 'Specifies the relevant customer data for VAT auditors.';
                        Visible = CustomerFileNameCtrlVisible;
                    }
                    field("Open Payment Export"; OpenPaymentExport)
                    {
                        ApplicationArea = Basic, Suite;
                        Caption = 'Export Open Payments';
                        ToolTip = 'Specifies that you want to export all customers'' opened credit entries.';
                    }
                    field(OpenPaymentFileNameCtrl; OpenPaymentFileName)
                    {
                        ApplicationArea = All;
                        Caption = 'Open Payments File';
                        ToolTip = 'Specifies that you want to export the open credit entries.';
                        Visible = OpenPaymentFileNameCtrlVisible;
                    }
                    field("Late Invoicing Export"; LateInvoicingExport)
                    {
                        ApplicationArea = Basic, Suite;
                        Caption = 'Export Late Invoicing';
                        ToolTip = 'Specifies that you want to export all customer entries that were invoiced later than Late Invoice Delay (Days) limit.';
                    }
                    field("Late Invoice Delay"; LateInvoiceDelay)
                    {
                        ApplicationArea = Basic, Suite;
                        Caption = 'Late Invoice Delay (Days)';
                        DecimalPlaces = 0 : 0;
                        MinValue = 0;
                        ToolTip = 'Specifies the number of days between the invoice issue date and the payment received date. ';
                    }
                    field("Late Invoicing File Name"; LateInvoicingFileName)
                    {
                        ApplicationArea = All;
                        Caption = 'Late Invoicing File';
                        ToolTip = 'Specifies customer entries that took longer to invoice than the number of days specified in the Late Invoice Delay (Days) field.';
                        Visible = LateInvoicingFileNameCtrlVisib;
                    }
                    field("Vendor Export"; VendorExport)
                    {
                        ApplicationArea = Basic, Suite;
                        Caption = 'Export Vendors';
                        ToolTip = 'Specifies that you want to export the Vendor table.';
                    }
                    field("Vendor File Name"; VendorFileName)
                    {
                        ApplicationArea = All;
                        Caption = 'Vendor File';
                        ToolTip = 'Specifies the relevant vendor data for VAT auditors.';
                        Visible = VendorFileNameCtrlVisible;
                    }
                    field("VAT Entry Export"; VATEntryExport)
                    {
                        ApplicationArea = Basic, Suite;
                        Caption = 'Export VAT Entries';
                        ToolTip = 'Specifies that you want to export the VAT Entry table.';
                    }
                    field("VAT Entry File Name"; VATEntryFileName)
                    {
                        ApplicationArea = All;
                        Caption = 'VAT Entry File';
                        ToolTip = 'Specifies the relevant VAT entry data for VAT auditors.';
                        Visible = VATEntryFileNameCtrlVisible;
                    }
                }
            }
        }

        actions
        {
        }

        trigger OnInit()
        begin
            VATEntryFileNameCtrlVisible := true;
            VendorFileNameCtrlVisible := true;
            LateInvoicingFileNameCtrlVisib := true;
            OpenPaymentFileNameCtrlVisible := true;
            CustomerFileNameCtrlVisible := true;
        end;

        trigger OnOpenPage()
        begin
            FeatureTelemetry.LogUptake('0001Q1D', VatTok, Enum::"Feature Uptake Status"::Discovered);
            if CustomerFileName = '' then
                CustomerFileName := Text1041013Txt;
            if OpenPaymentFileName = '' then
                OpenPaymentFileName := Text1041014Txt;
            if LateInvoicingFileName = '' then
                LateInvoicingFileName := Text1041015Txt;
            if VendorFileName = '' then
                VendorFileName := Text1041016Txt;
            if VATEntryFileName = '' then
                VATEntryFileName := Text1041017Txt;
            if LateInvoiceDelay = 0 then
                LateInvoiceDelay := 14;
            CustomerFileNameCtrlVisible := false;
            OpenPaymentFileNameCtrlVisible := false;
            LateInvoicingFileNameCtrlVisib := false;
            VendorFileNameCtrlVisible := false;
            VATEntryFileNameCtrlVisible := false
        end;
    }

    labels
    {
    }

    trigger OnPreReport()
    begin
        FeatureTelemetry.LogUptake('0001Q1C', VatTok, Enum::"Feature Uptake Status"::"Set up");
        if CustomerExport and (CustomerFileName = '') then
            Error(Text1041007Txt);

        if OpenPaymentExport and (OpenPaymentFileName = '') then
            Error(Text1041008Txt);

        if LateInvoicingExport then begin
            if LateInvoicingFileName = '' then
                Error(Text1041009Txt);
            if LateInvoiceDelay = 0 then
                Error(Text1041010Txt);
        end;

        if VendorExport and (VendorFileName = '') then
            Error(Text1041011Txt);

        if VATEntryExport and (VATEntryFileName = '') then
            Error(Text1041012Txt);

        CRLF[1] := 13;
        CRLF[2] := 10;
    end;

    trigger OnPostReport()
    begin
        FeatureTelemetry.LogUptake('0001Q1A', VatTok, Enum::"Feature Uptake Status"::"Used");
        FeatureTelemetry.LogUsage('0001Q1B', VatTok, 'UK VAT Audit Report Printed');
    end;

    var
        FeatureTelemetry: Codeunit "Feature Telemetry";
        RBMgt: Codeunit "File Management";
        CustomerTempBlob: Codeunit "Temp Blob";
        OpenPaymentTempBlob: Codeunit "Temp Blob";
        LateInvoicingTempBlob: Codeunit "Temp Blob";
        VendorTempBlob: Codeunit "Temp Blob";
        VATEntryTempBlob: Codeunit "Temp Blob";
        VatTok: Label 'UK Print VAT Audit Reports', Locked = true;
        Text1041000Txt: Label 'Exporting Customers...#1##################', Comment = '%1=';
        Text1041001Txt: Label 'Exporting Open Payments...#1##################', Comment = '%1=';
        Text1041002Txt: Label 'Payment ';
        Text1041003Txt: Label 'Invoice ';
        Text1041004Txt: Label 'Exporting Late Invoicing Entries...#1##################', Comment = '%1=';
        Text1041005Txt: Label 'Exporting Vendors...#1##################', Comment = '%1=';
        Text1041006Txt: Label 'Exporting VAT Entries...#1##################', Comment = '%1=';
        Text1041007Txt: Label 'Please enter the Customer File name.';
        Text1041008Txt: Label 'Please enter the Open Payments File name.';
        Text1041009Txt: Label 'Please enter the Late Invoicing File name.';
        Text1041010Txt: Label 'Please enter the Late Invoicing No. of Days.';
        Text1041011Txt: Label 'Please enter the Vendor File name.';
        Text1041012Txt: Label 'Please enter the VAT Entry File name.';
        Text1041013Txt: Label 'C:\Customer.CSV';
        Text1041014Txt: Label 'C:\OpenPay.CSV';
        Text1041015Txt: Label 'C:\LateInv.CSV';
        Text1041016Txt: Label 'C:\Vendor.CSV';
        Text1041017Txt: Label 'C:\VATentry.CSV';
        Window: Dialog;
        CRLF: Text[2];
        CustomerOutStr: OutStream;
        OpenPaymentOutStr: OutStream;
        LateInvoicingOutStr: OutStream;
        VendorOutStr: OutStream;
        VATEntryOutStr: OutStream;
        CustomerFileName: Text;
        OpenPaymentFileName: Text;
        LateInvoicingFileName: Text;
        VendorFileName: Text;
        VATEntryFileName: Text;
        CustomerExport: Boolean;
        OpenPaymentExport: Boolean;
        LateInvoicingExport: Boolean;
        VendorExport: Boolean;
        VATEntryExport: Boolean;
        LateInvoiceDelay: Decimal;
        ToFile: Text;
        CustomerFileNameCtrlVisible: Boolean;
        OpenPaymentFileNameCtrlVisible: Boolean;
        LateInvoicingFileNameCtrlVisib: Boolean;
        VendorFileNameCtrlVisible: Boolean;
        VATEntryFileNameCtrlVisible: Boolean;
        SevenDelimitedValuesTxt: Label '"%1","%2","%3","%4","%5","%6","%7"', Locked = true;
        EightDelimitedValuesTxt: Label '"%1","%2","%3","%4","%5","%6","%7","%8"', Locked = true;
        ElevenDelimitedValuesTxt: Label '"%1","%2","%3","%4","%5","%6","%7","%8","%9","%10","%11"', Locked = true;
}