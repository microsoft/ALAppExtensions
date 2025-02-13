namespace Microsoft.SubscriptionBilling;

using System.Utilities;
using System.Text;
using Microsoft.Utilities;
using Microsoft.Sales.Document;

reportextension 8010 "Contract Sales Order Conf." extends "Standard Sales - Order Conf."
{
    RDLCLayout = './Sales Service Commitments/Report Extensions/StandardSalesOrderConf.rdl';
    WordLayout = './Sales Service Commitments/Report Extensions/StandardSalesOrderConf.docx';

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
        addbefore(AssemblyLine)
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
        OnBeforeFillServiceCommitmentsForLine(Header, ServiceCommitmentForLine, TempServiceCommitmentForLineCaption);
        SalesReportPrintoutMgmt.FillServiceCommitmentsForLine(Header, ServiceCommitmentForLine, TempServiceCommitmentForLineCaption);
    end;

    local procedure FillServiceCommitmentsGroupPerPeriod()
    begin
        ServiceCommitmentsGroup.Reset();
        ServiceCommitmentsGroup.DeleteAll(false);
        ServiceCommitmentsGroupPerPeriod.Reset();
        ServiceCommitmentsGroupPerPeriod.DeleteAll(false);
        OnBeforeFillServiceCommitmentsGroupPerPeriod(Header, ServiceCommitmentsGroupPerPeriod);
        SalesReportPrintoutMgmt.FillServiceCommitmentsGroups(Header, ServiceCommitmentsGroupPerPeriod, ServiceCommitmentsGroup);
    end;

    [InternalEvent(false, false)]
    local procedure OnBeforeFillServiceCommitmentsForLine(Header: Record "Sales Header"; var ServiceCommitmentForLine: Record "Sales Line"; var ServiceCommitmentForLineCaption: Record "Name/Value Buffer")
    begin
    end;

    [InternalEvent(false, false)]
    local procedure OnBeforeFillServiceCommitmentsGroupPerPeriod(Header: Record "Sales Header"; var ServiceCommitmentsGroupPerPeriod: Record "Name/Value Buffer")
    begin
    end;
}
