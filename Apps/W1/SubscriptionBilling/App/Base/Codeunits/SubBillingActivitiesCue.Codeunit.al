namespace Microsoft.SubscriptionBilling;

using Microsoft.Sales.History;
using Microsoft.Purchases.History;
using Microsoft.Projects.Project.Job;

codeunit 8071 "Sub. Billing Activities Cue"
{
    Access = Internal;
    procedure GetMyJobsFilter() FilterText: Text
    var
        MyJobs: Record "My Job";
    begin
        MyJobs.SetRange("User ID", UserId);
        if MyJobs.FindSet() then
            repeat
                if FilterText <> '' then
                    FilterText += '|';
                FilterText += MyJobs."Job No.";
            until MyJobs.Next() = 0;
    end;

    procedure RevenueCurrentMonth() Result: Decimal
    begin
        exit(GetRevenue(true));
    end;

    procedure CostCurrentMonth() Result: Decimal
    begin
        exit(GetCost(true));
    end;

    procedure RevenuePreviousMonth() Result: Decimal
    begin
        exit(GetRevenue(false));
    end;

    procedure CostPreviousMonth() Result: Decimal
    begin
        exit(GetCost(false));
    end;

    local procedure GetRevenue(CurrentMonth: Boolean): Decimal
    var
        SalesInvLine: Record "Sales Invoice Line";
        SalesCrMemoLine: Record "Sales Cr.Memo Line";
        DateFilterFrom: Text;
        DateFilterTo: Text;
    begin
        GetDateFilters(CurrentMonth, DateFilterFrom, DateFilterTo);
        SalesInvLine.SetFilter("Contract No.", '<>%1', '');
        SalesInvLine.SetRange("Posting Date", CalcDate(DateFilterFrom, WorkDate()), CalcDate(DateFilterTo, WorkDate()));
        SalesInvLine.CalcSums(Amount);

        SalesCrMemoLine.SetFilter("Contract No.", '<>%1', '');
        SalesCrMemoLine.SetRange("Posting Date", CalcDate(DateFilterFrom, WorkDate()), CalcDate(DateFilterTo, WorkDate()));
        SalesCrMemoLine.CalcSums(Amount);

        exit(SalesInvLine.Amount - SalesCrMemoLine.Amount);
    end;

    local procedure GetCost(CurrentMonth: Boolean): Decimal
    var
        PurchInvLine: Record "Purch. Inv. Line";
        PurchCrMemoLine: Record "Purch. Cr. Memo Line";
        DateFilterFrom: Text;
        DateFilterTo: Text;
    begin
        GetDateFilters(CurrentMonth, DateFilterFrom, DateFilterTo);
        PurchInvLine.SetFilter("Contract No.", '<>%1', '');
        PurchInvLine.SetRange("Posting Date", CalcDate(DateFilterFrom, WorkDate()), CalcDate(DateFilterTo, WorkDate()));
        PurchInvLine.CalcSums(Amount);

        PurchCrMemoLine.SetFilter("Contract No.", '<>%1', '');
        PurchCrMemoLine.SetRange("Posting Date", CalcDate(DateFilterFrom, WorkDate()), CalcDate(DateFilterTo, WorkDate()));
        PurchCrMemoLine.CalcSums(Amount);

        exit(PurchInvLine.Amount - PurchCrMemoLine.Amount);
    end;

    local procedure GetDateFilters(CurrentMonth: Boolean; var DateFilterFrom: Text; var DateFilterTo: Text)
    begin
        if CurrentMonth then begin
            DateFilterFrom := '<-CM>';
            DateFilterTo := '<CM>';
        end else begin
            DateFilterFrom := '<-CM-1M>';
            DateFilterTo := '<CM-1M>';
        end;
    end;

}
