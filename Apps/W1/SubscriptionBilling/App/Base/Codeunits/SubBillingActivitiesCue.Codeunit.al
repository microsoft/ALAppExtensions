namespace Microsoft.SubscriptionBilling;

using Microsoft.Sales.History;
using Microsoft.Purchases.History;
using Microsoft.Projects.Project.Job;

codeunit 8071 "Sub. Billing Activities Cue"
{
    Access = Internal;
    Permissions = tabledata "Subscription Billing Cue" = r;

    var
        Results: Dictionary of [Text, Text];

    trigger OnRun()
    var
        Parameters: Dictionary of [Text, Text];
    begin
        Parameters := Page.GetBackgroundParameters();

        CalculateFieldValues(Parameters, Results);

        Page.SetBackgroundTaskResult(Results);
    end;

    procedure CalculateFieldValues(Parameters: Dictionary of [Text, Text]; var ReturnResults: Dictionary of [Text, Text])
    var
        SubscriptionBillingCue: Record "Subscription Billing Cue";
    begin
        if SubscriptionBillingCue.Get() then;
        CalculateCueFieldValues(SubscriptionBillingCue);

        ReturnResults.Add(SubscriptionBillingCue.FieldName("Revenue current Month"), Format(SubscriptionBillingCue."Revenue current Month", 0, '<Precision,0:0><Standard Format,9>'));
        ReturnResults.Add(SubscriptionBillingCue.FieldName("Cost current Month"), Format(SubscriptionBillingCue."Cost current Month", 0, '<Precision,0:0><Standard Format,9>'));
        ReturnResults.Add(SubscriptionBillingCue.FieldName("Revenue previous Month"), Format(SubscriptionBillingCue."Revenue previous Month", 0, '<Precision,0:0><Standard Format,9>'));
        ReturnResults.Add(SubscriptionBillingCue.FieldName("Cost previous Month"), Format(SubscriptionBillingCue."Cost previous Month", 0, '<Precision,0:0><Standard Format,9>'));
        ReturnResults.Add(SubscriptionBillingCue.FieldName(Overdue), Format(SubscriptionBillingCue.Overdue));
        ReturnResults.Add(SubscriptionBillingCue.FieldName("Last Updated On"), Format(SubscriptionBillingCue."Last Updated On", 0, 9));
    end;

    local procedure CalculateCueFieldValues(var SubscriptionBillingCue: Record "Subscription Billing Cue")
    var
        TemporaryOverdueServiceCommitments: Record "Overdue Service Commitments" temporary;
    begin
        SubscriptionBillingCue."Revenue current Month" := RevenueCurrentMonth();
        SubscriptionBillingCue."Cost current Month" := CostCurrentMonth();
        SubscriptionBillingCue."Revenue previous Month" := RevenuePreviousMonth();
        SubscriptionBillingCue."Cost previous Month" := CostPreviousMonth();
        SubscriptionBillingCue.Overdue := TemporaryOverdueServiceCommitments.CountOverdueServiceCommitments();
        SubscriptionBillingCue."Last Updated On" := CurrentDateTime();
    end;

    procedure EvaluateResults(var Results: Dictionary of [Text, Text]; var SubscriptionBillingCue: Record "Subscription Billing Cue")
    var
        ResultValue: Text;
    begin
        if Results.Count() = 0 then
            exit;

        if TryGetDictionaryValue(Results, SubscriptionBillingCue.FieldName("Revenue current Month"), ResultValue) then
            Evaluate(SubscriptionBillingCue."Revenue current Month", ResultValue);
        if TryGetDictionaryValue(Results, SubscriptionBillingCue.FieldName("Cost current Month"), ResultValue) then
            Evaluate(SubscriptionBillingCue."Cost current Month", ResultValue, 9);
        if TryGetDictionaryValue(Results, SubscriptionBillingCue.FieldName("Revenue previous Month"), ResultValue) then
            Evaluate(SubscriptionBillingCue."Revenue previous Month", ResultValue);
        if TryGetDictionaryValue(Results, SubscriptionBillingCue.FieldName("Cost previous Month"), ResultValue) then
            Evaluate(SubscriptionBillingCue."Cost previous Month", ResultValue);
        if TryGetDictionaryValue(Results, SubscriptionBillingCue.FieldName(Overdue), ResultValue) then
            Evaluate(SubscriptionBillingCue.Overdue, ResultValue);
        if TryGetDictionaryValue(Results, SubscriptionBillingCue.FieldName("Last Updated On"), ResultValue) then
            Evaluate(SubscriptionBillingCue."Last Updated On", ResultValue, 9);
    end;

    [TryFunction]
    local procedure TryGetDictionaryValue(var Results: Dictionary of [Text, Text]; DictionaryKey: Text; var ReturnValue: Text)
    begin
        ReturnValue := Results.Get(DictionaryKey);
    end;

    internal procedure DrillDownOverdueServiceCommitments()
    var
        TemporaryOverdueServiceCommitments: Record "Overdue Service Commitments" temporary;
    begin
        TemporaryOverdueServiceCommitments.FillOverdueServiceCommitments();
        Page.Run(Page::"Overdue Service Commitments", TemporaryOverdueServiceCommitments);
    end;

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
