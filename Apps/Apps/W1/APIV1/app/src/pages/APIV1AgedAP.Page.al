namespace Microsoft.API.V1;

using Microsoft.Integration.Entity;
using Microsoft.Integration.Graph;

page 20032 "APIV1 - Aged AP"
{
    APIVersion = 'v1.0';
    Caption = 'agedAccountsPayable', Locked = true;
    DelayedInsert = true;
    DeleteAllowed = false;
    Editable = false;
    EntityName = 'agedAccountsPayable';
    EntitySetName = 'agedAccountsPayable';
    InsertAllowed = false;
    ModifyAllowed = false;
    PageType = API;
    SourceTable = "Aged Report Entity";
    SourceTableTemporary = true;
    Extensible = false;

    layout
    {
        area(content)
        {
            repeater(Group)
            {
                field(vendorId; Rec.AccountId)
                {
                    Caption = 'id', Locked = true;
                }
                field(vendorNumber; Rec."No.")
                {
                    Caption = 'vendorNumber', Locked = true;
                }
                field(name; Rec.Name)
                {
                    Caption = 'name', Locked = true;
                }
                field(currencyCode; Rec."Currency Code")
                {
                    Caption = 'currencyCode', Locked = true;
                }
                field(balanceDue; Rec.Balance)
                {
                    Caption = 'balance', Locked = true;
                }
                field(currentAmount; Rec.Before)
                {
                    Caption = 'before', Locked = true;
                }
                field(period1Amount; Rec."Period 1")
                {
                    Caption = 'period1', Locked = true;
                }
                field(period2Amount; Rec."Period 2")
                {
                    Caption = 'period2', Locked = true;
                }
                field(period3Amount; Rec."Period 3")
                {
                    Caption = 'period3', Locked = true;
                }
                field(agedAsOfDate; Rec."Period Start Date")
                {
                    Caption = 'periodStartDate', Locked = true;
                }
                field(periodLengthFilter; Rec."Period Length")
                {
                    Caption = 'periodLength', Locked = true;
                }
            }
        }
    }

    actions
    {
    }

    trigger OnOpenPage()
    var
        GraphMgtReports: Codeunit "Graph Mgt - Reports";
        RecVariant: Variant;
        ReportAPIType: Option "Balance Sheet","Income Statement","Trial Balance","CashFlow Statement","Aged Accounts Payable","Aged Accounts Receivable","Retained Earnings";
    begin
        RecVariant := Rec;
        GraphMgtReports.SetUpAgedReportAPIData(RecVariant, ReportAPIType::"Aged Accounts Payable");
    end;
}



