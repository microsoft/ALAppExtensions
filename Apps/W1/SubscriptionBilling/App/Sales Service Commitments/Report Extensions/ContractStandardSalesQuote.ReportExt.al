namespace Microsoft.SubscriptionBilling;

using System.Text;
using System.Utilities;
using Microsoft.Utilities;
using Microsoft.Sales.Document;

reportextension 8011 "Contract Standard Sales Quote" extends "Standard Sales - Quote"
{
    dataset
    {
        modify(Header)
        {
            trigger OnAfterAfterGetRecord()
            begin
                FillServiceCommitmentsForLine();
                FillServiceCommitmentsGroupPerPeriod();
            end;
        }
        modify(Line)
        {
            trigger OnAfterAfterGetRecord()
            begin
                SalesReportPrintoutMgmt.ExcludeItemFromTotals(Line, TotalSubTotal, TotalInvDiscAmount, TotalAmount, TotalAmountVAT, TotalAmountInclVAT);
            end;
        }
        addfirst(Line)
        {
            dataitem(ServiceCommitmentHeaderForSalesLine; "Integer")
            {
                DataItemTableView = sorting(Number) where(Number = const(1));
                PrintOnlyIfDetail = true;
                column(ServiceCommitmentForLineDescription_Lbl; ReportFormatting.GetValueFromBuffer(TempServiceCommitmentForLineCaption, ServiceCommitmentForLine.FieldName(Description)))
                {
                }
                column(ServiceCommitmentForLinePrice_Lbl; ReportFormatting.GetValueFromBuffer(TempServiceCommitmentForLineCaption, ServiceCommitmentForLine.FieldName("Unit Price")))
                {
                }
                column(ServiceCommitmentForLineDiscount_Lbl; ReportFormatting.GetValueFromBuffer(TempServiceCommitmentForLineCaption, ServiceCommitmentForLine.FieldName("Line Discount %")))
                {
                }
                dataitem(ServiceCommitmentForLine; "Sales Line")
                {
                    DataItemTableView = sorting("Line No.");
                    UseTemporary = true;
                    column(ServiceCommitmentForLineLineNo; "Line No.")
                    {
                    }
                    column(ServiceCommitmentForLineDescription; Description)
                    {
                    }
                    column(ServiceCommitmentForLineDiscount; ReportFormatting.BlankZeroFormatting("Line Discount %"))
                    {
                    }
                    column(ServiceCommitmentForLinePrice; ReportFormatting.BlankZeroWithCurrencyCode("Unit Price", "Currency Code", AutoFormatType::UnitAmountFormat))
                    {
                    }
                    trigger OnPreDataItem()
                    begin
                        SetRange("Document Type", Line."Document Type");
                        SetRange("Document No.", Format(Line."Line No."));
                        if IsEmpty() then
                            CurrReport.Break();
                    end;
                }
            }
        }
        addafter(ReportTotalsLine)
        {
            dataitem(ServiceCommitmentForLineCaption; "Integer")
            {
                DataItemTableView = sorting(Number) where(Number = const(1));
                column(ServiceCommitmentForLineTotalText_Lbl; ReportFormatting.GetValueFromBuffer(TempServiceCommitmentForLineCaption, 'TotalText'))
                {
                }
                trigger OnPreDataItem()
                begin
                    if ServiceCommitmentsGroup.IsEmpty() then
                        CurrReport.Break();
                end;
            }
            dataitem(ServiceCommitmentsGroup; "Name/Value Buffer")
            {
                DataItemTableView = sorting(ID);
                UseTemporary = true;
                dataitem(ServiceCommitmentsGroupPerPeriod; "Name/Value Buffer")
                {
                    DataItemTableView = sorting(ID);
                    UseTemporary = true;
                    column(ServiceCommitmentsGroupPerPeriodType; "Value Long")
                    {
                    }
                    column(ServiceCommitmentsGroupPerPeriodName; Name)
                    {
                    }
                    column(ServiceCommitmentsGroupPerPeriodValue; Value)
                    {
                    }
                    trigger OnPreDataItem()
                    begin
                        SetRange("Value Long", ServiceCommitmentsGroup."Value Long");
                    end;
                }
            }
        }
    }
    rendering
    {
        layout("SalesQuoteForSubscriptionBilling.rdlc")
        {
            Type = RDLC;
            LayoutFile = './Sales Service Commitments/Report Extensions/Layouts/SalesQuoteForSubscriptionBilling.rdlc';
            Caption = 'Sales Quote for Subscription Billing (RDLC)';
            Summary = 'The Sales Quote for Subscription Billing (RDLC) is the most detailed layout and provides most flexible layout options.';
        }
        layout("SalesQuoteForSubscriptionBilling.docx")
        {
            Type = Word;
            LayoutFile = './Sales Service Commitments/Report Extensions/Layouts/SalesQuoteForSubscriptionBilling.docx';
            Caption = 'Sales Quote for Subscription Billing (Word)';
            Summary = 'The Sales Quote for Subscription Billing (Word) provides a simple layout that is also relatively easy for an end-user to modify.';
        }
    }

    var
        TempServiceCommitmentForLineCaption: Record "Name/Value Buffer" temporary;
        SalesReportPrintoutMgmt: Codeunit "Sales Report Printout Mgmt.";
        ReportFormatting: Codeunit "Report Formatting";
        AutoFormatType: Enum "Auto Format";

    local procedure FillServiceCommitmentsForLine()
    begin
        ServiceCommitmentForLine.DeleteAll(false);
        TempServiceCommitmentForLineCaption.Reset();
        TempServiceCommitmentForLineCaption.DeleteAll(false);
        OnBeforeFillSubscriptionLinesForLine(Header, ServiceCommitmentForLine, TempServiceCommitmentForLineCaption);
        SalesReportPrintoutMgmt.FillServiceCommitmentsForLine(Header, ServiceCommitmentForLine, TempServiceCommitmentForLineCaption);
    end;

    local procedure FillServiceCommitmentsGroupPerPeriod()
    begin
        ServiceCommitmentsGroup.Reset();
        ServiceCommitmentsGroup.DeleteAll(false);
        ServiceCommitmentsGroupPerPeriod.Reset();
        ServiceCommitmentsGroupPerPeriod.DeleteAll(false);
        OnBeforeFillSubscriptionLinesGroupPerPeriod(Header, ServiceCommitmentsGroupPerPeriod);
        SalesReportPrintoutMgmt.FillServiceCommitmentsGroups(Header, ServiceCommitmentsGroupPerPeriod, ServiceCommitmentsGroup);
    end;

    [IntegrationEvent(false, false)]
    local procedure OnBeforeFillSubscriptionLinesForLine(Header: Record "Sales Header"; var SubscriptionLineForLine: Record "Sales Line"; var SubscriptionLineForLineCaption: Record "Name/Value Buffer")
    begin
    end;

    [IntegrationEvent(false, false)]
    local procedure OnBeforeFillSubscriptionLinesGroupPerPeriod(Header: Record "Sales Header"; var SubscriptionLinesGroupPerPeriod: Record "Name/Value Buffer")
    begin
    end;
}
