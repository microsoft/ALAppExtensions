namespace Microsoft.SubscriptionBilling;

using Microsoft.Sales.History;
using System.Utilities;
using System.Text;
using Microsoft.Projects.Project.Ledger;
using Microsoft.Sales.Customer;

reportextension 8008 "Contract Standard Sales Inv." extends "Standard Sales - Invoice"
{
    RDLCLayout = './Billing/Report Extensions/StandardSalesInvoice.rdl';
    WordLayout = './Billing/Report Extensions/StandardSalesInvoice.docx';

    dataset
    {
        add(Header)
        {
            column(RecurringBilling; "Recurring Billing")
            {
            }
        }
        modify(Header)
        {
            trigger OnAfterAfterGetRecord()
            begin
                ContractBillingPrintout.FillContractBillingDetailsBufferFromSalesInvoice(Header, TempContractBillingDetailsBuffer, ColumnHeaders);
                FillTempContractBillingDetailsGroupingBuffer();
            end;
        }
        add(Line)
        {
            column(ContractLineNo; "Contract Line No.")
            {
            }
            column(ContractNo; "Contract No.")
            {
            }
            column(RecurringBillingfrom; "Recurring Billing from")
            {
            }
            column(RecurringBillingto; "Recurring Billing to")
            {
            }
        }
        addafter(ReportTotalsLine)
        {
            dataitem(ContractBillingDetailsMapping; Integer)
            {
                MaxIteration = 1;
                DataItemTableView = sorting(Number);

                column(ContractBillingDetailsContractNoLbl; ContractNoLbl) { }
                column(ContractBillingDetailsPositionDescriptionLbl; SalesInvoiceLine.FieldCaption(Description)) { }
                column(ContractBillingDetailsCustomerLbl; CustomerLbl) { }

                dataitem(ContractBillingDetailsGrouping; Integer)
                {
                    DataItemTableView = sorting(Number);
                    column(ContractBillingDetailsContractNo; TempContractBillingDetailsBuffer."External Document No.") { }
                    column(ContractBillingDetailsPositionDescription; SalesInvoiceLine.Description) { }
                    column(ContractBillingDetailsPositionNoLbl; PositionLbl) { }
                    column(ContractBillingDetailsPositionNo; SalesInvoiceLine."Line No.") { }
                    column(ContractBillingDetailsCustomerName; Customer2.Name) { }
                    column(ContractBillingDetailsStartDateLbl; StartDateLbl) { }
                    column(ContractBillingDetailsEndDateLbl; EndDateLbl) { }
                    column(ContractBillingDetailsDaysLbl; DaysLbl) { }
                    column(ContractBillingDetailsQtyLbl; SalesInvoiceLine.FieldCaption(Quantity)) { }
                    column(ContractBillingDetailsSalesPriceLbl; SalesPriceLblTxt) { }
                    column(ContractBillingDetailsDiscountPercentLbl; DiscountPercentLblText) { }
                    column(ContractBillingDetailsDiscountAmountLbl; DiscountAmountLblText) { }
                    column(ContractBillingDetailsAmountLbl; AmountLblText) { }
                    column(ContractBillingDetailsCurrencyCodeLbl; CurrencyLblText) { }
                    column(ContractBillingDetailsDescriptionLbl; ServiceDescriptionLbl) { }

                    dataitem(ContractBillingDetails; Integer)
                    {
                        DataItemTableView = sorting(Number);

                        column(ContractBillingDetailsStartDate; Format(TempContractBillingDetailsBuffer."Document Date")) { }
                        column(ContractBillingDetailsEndDate; Format(TempContractBillingDetailsBuffer."Posting Date")) { }
                        column(Days; Days) { }
                        column(ContractBillingDetailsQuantity; Format(TempContractBillingDetailsBuffer.Quantity)) { }
                        column(ContractBillingDetailsSalesPrice; FormattedUnitPrice)
                        {
                            AutoFormatExpression = Line.GetCurrencyCode();
                            AutoFormatType = 2;
                        }
                        column(ContractBillingDetailsDiscountPercent; LineDiscountPctText) { }
                        column(ContractBillingDetailsBillingAmount; FormattedLineAmount)
                        {
                            AutoFormatExpression = Line.GetCurrencyCode();
                            AutoFormatType = 1;
                        }
                        column(ContractBillingDetailsBillingDiscountAmount; FormattedLineDiscountAmount)
                        {
                            AutoFormatExpression = Line.GetCurrencyCode();
                            AutoFormatType = 1;
                        }
                        column(ContractBillingDetailsCurrencyCode; TempContractBillingDetailsBuffer."Currency Code") { }
                        column(ContractBillingDetailsDescription; TempContractBillingDetailsBuffer.Description) { }

                        trigger OnPreDataItem()
                        begin
                            TempContractBillingDetailsBuffer.SetRange("Document No.", TempContractBillingDetailsGroupingBuffer."Document No.");
                            TempContractBillingDetailsBuffer.SetRange("Ledger Entry No.", TempContractBillingDetailsGroupingBuffer."Ledger Entry No.");

                            if TempContractBillingDetailsBuffer.IsEmpty() then
                                CurrReport.Break();

                            SetRange(Number, 1, TempContractBillingDetailsBuffer.Count());
                            if Header."Currency Code" <> '' then
                                CurrencyLblText := CurrencyLbl;
                        end;

                        trigger OnAfterGetRecord()
                        var
                            AutoFormatType: Enum "Auto Format";
                        begin
                            if Number = 1 then
                                TempContractBillingDetailsBuffer.FindSet()
                            else
                                TempContractBillingDetailsBuffer.Next();

                            ContractBillingPrintout.FormatContractBillingDetails(TempContractBillingDetailsBuffer, SalesInvoiceLine);

                            if not Customer2.Get(TempContractBillingDetailsBuffer."Resource Group No.") then
                                Customer2.Init();

                            ReportFormatting.FormatTextVariableFromDecimalValue(FormattedUnitPrice, TempContractBillingDetailsBuffer."Unit Price", AutoFormatType::UnitAmountFormat, TempContractBillingDetailsBuffer."Currency Code");
                            ReportFormatting.FormatTextVariableFromDecimalValue(FormattedLineAmount, TempContractBillingDetailsBuffer."Line Amount", AutoFormatType::AmountFormat, TempContractBillingDetailsBuffer."Currency Code");
                            ReportFormatting.FormatTextVariableFromDecimalValue(FormattedLineDiscountAmount, TempContractBillingDetailsBuffer."Line Discount Amount", AutoFormatType::AmountFormat, TempContractBillingDetailsBuffer."Currency Code");

                            LineDiscountPctText := '';
                            if TempContractBillingDetailsBuffer."Line Discount %" <> 0 then
                                LineDiscountPctText := Format(-Round(TempContractBillingDetailsBuffer."Line Discount %", 0.1));

                            SalesPriceLblTxt := ColumnHeaders[1];
                            DiscountPercentLblText := ColumnHeaders[2];
                            DiscountAmountLblText := ColumnHeaders[3];
                            AmountLblText := ColumnHeaders[4];

                            Days := 0;
                            if (TempContractBillingDetailsBuffer."Document Date" <> 0D) and (TempContractBillingDetailsBuffer."Posting Date" <> 0D) then
                                Days := TempContractBillingDetailsBuffer."Posting Date" - TempContractBillingDetailsBuffer."Document Date" + 1;
                        end;
                    }
                    trigger OnPreDataItem()
                    begin
                        if TempContractBillingDetailsGroupingBuffer.IsEmpty() then
                            CurrReport.Break();

                        SetRange(Number, 1, TempContractBillingDetailsGroupingBuffer.Count());
                    end;

                    trigger OnAfterGetRecord()
                    begin
                        if Number = 1 then
                            TempContractBillingDetailsGroupingBuffer.FindSet()
                        else
                            TempContractBillingDetailsGroupingBuffer.Next();

                        ContractBillingPrintout.FormatContractBillingDetails(TempContractBillingDetailsGroupingBuffer, SalesInvoiceLine);
                    end;
                }
                trigger OnPreDataItem()
                begin
                    if TempContractBillingDetailsBuffer.Count > 0 then
                        SetRange(Number, 1)
                    else
                        CurrReport.Break();
                end;

                trigger OnAfterGetRecord()
                begin
                    if TempContractBillingDetailsBuffer.Count = 0 then
                        CurrReport.Break();
                end;
            }
        }
    }
    var
        TempContractBillingDetailsBuffer: Record "Job Ledger Entry" temporary;
        TempContractBillingDetailsGroupingBuffer: Record "Job Ledger Entry" temporary;
        SalesInvoiceLine: Record "Sales Invoice Line";
        Customer2: Record Customer;
        ContractBillingPrintout: Codeunit "Contract Billing Printout";
        ReportFormatting: Codeunit "Report Formatting";
        CustomerLbl: Label 'Customer';
        ContractNoLbl: Label 'Contract No.';
        PositionLbl: Label 'Pos.';
        StartDateLbl: Label 'Start Date';
        EndDateLbl: Label 'End Date';
        DaysLbl: Label 'Days';
        Days: Integer;
        ServiceDescriptionLbl: Label 'Service Object';
        CurrencyLbl: Label 'Currency';
        SalesPriceLblTxt: Text;
        CurrencyLblText: Text;
        DiscountPercentLblText: Text;
        DiscountAmountLblText: Text;
        AmountLblText: Text;
        ColumnHeaders: array[5] of Text;
        FormattedLineDiscountAmount: Text;

    local procedure FillTempContractBillingDetailsGroupingBuffer()
    begin
        TempContractBillingDetailsBuffer.Reset();
        if TempContractBillingDetailsBuffer.FindSet() then
            repeat
                TempContractBillingDetailsGroupingBuffer.SetRange("Document No.", TempContractBillingDetailsBuffer."Document No.");
                TempContractBillingDetailsGroupingBuffer.SetRange("Ledger Entry No.", TempContractBillingDetailsBuffer."Ledger Entry No.");
                if not TempContractBillingDetailsGroupingBuffer.FindFirst() then begin
                    TempContractBillingDetailsGroupingBuffer := TempContractBillingDetailsBuffer;
                    TempContractBillingDetailsGroupingBuffer.Insert(false);
                end;
            until TempContractBillingDetailsBuffer.Next() = 0;
        TempContractBillingDetailsGroupingBuffer.Reset();
    end;
}
