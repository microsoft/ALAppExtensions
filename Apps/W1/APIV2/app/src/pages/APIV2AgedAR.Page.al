namespace Microsoft.API.V2;

using Microsoft.Integration.Entity;
using Microsoft.Integration.Graph;

page 30031 "APIV2 - Aged AR"
{
    APIVersion = 'v2.0';
    EntityCaption = 'Aged Accounts Receivable';
    EntitySetCaption = 'Aged Accounts Receivables';
    DelayedInsert = true;
    DeleteAllowed = false;
    Editable = false;
    EntityName = 'agedAccountsReceivable';
    EntitySetName = 'agedAccountsReceivables';
    InsertAllowed = false;
    ModifyAllowed = false;
    PageType = API;
    SourceTable = "Aged Report Entity";
    SourceTableTemporary = true;
    Extensible = false;
    ODataKeyFields = AccountId;
    AboutText = 'Provides real-time aged accounts receivable data, including customer details, outstanding balances, and amounts due by aging period. Supports GET operations for retrieving aging reports to enable credit management, collections automation, and financial analysis in external systems. Ideal for integrations requiring up-to-date visibility into customer payment performance and overdue receivables.';

    layout
    {
        area(content)
        {
            repeater(Group)
            {
                field(customerId; Rec.AccountId)
                {
                    Caption = 'Customer Id';
                }
                field(customerNumber; Rec."No.")
                {
                    Caption = 'Customer No.';
                }
                field(name; Rec.Name)
                {
                    Caption = 'Name';
                }
                field(currencyCode; Rec."Currency Code")
                {
                    Caption = 'Currency Code';
                }
                field(balanceDue; Rec.Balance)
                {
                    Caption = 'Balance';
                }
                field(currentAmount; Rec.Before)
                {
                    Caption = 'Before';
                }
                field(period1Label; Rec."Period 1 Label")
                {
                    Caption = 'Period 1 Label';
                }
                field(period1Amount; Rec."Period 1")
                {
                    Caption = 'Period 1';
                }
                field(period2Label; Rec."Period 2 Label")
                {
                    Caption = 'Period 2 Label';
                }
                field(period2Amount; Rec."Period 2")
                {
                    Caption = 'Period 2';
                }
                field(period3Label; Rec."Period 3 Label")
                {
                    Caption = 'Period 3 Label';
                }
                field(period3Amount; Rec."Period 3")
                {
                    Caption = 'Period 3';
                }
                field(agedAsOfDate; Rec."Period Start Date")
                {
                    Caption = 'Period Start Date';
                }
                field(periodLengthFilter; Rec."Period Length")
                {
                    Caption = 'Period Length';
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
        GraphMgtReports.SetUpAgedReportAPIData(RecVariant, ReportAPIType::"Aged Accounts Receivable");
    end;
}


