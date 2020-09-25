page 20031 "APIV1 - Aged AR"
{
    APIVersion = 'v1.0';
    Caption = 'agedAccountsReceivable', Locked = true;
    DelayedInsert = true;
    DeleteAllowed = false;
    Editable = false;
    EntityName = 'agedAccountsReceivable';
    EntitySetName = 'agedAccountsReceivable';
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
                field(customerId; AccountId)
                {
                    Caption = 'customerId', Locked = true;
                }
                field(customerNumber; "No.")
                {
                    Caption = 'customerNumber', Locked = true;
                }
                field(name; Name)
                {
                    Caption = 'name', Locked = true;
                }
                field(currencyCode; "Currency Code")
                {
                    Caption = 'currencyCode', Locked = true;
                }
                field(balanceDue; Balance)
                {
                    Caption = 'balance', Locked = true;
                }
                field(currentAmount; Before)
                {
                    Caption = 'before', Locked = true;
                }
                field(period1Amount; "Period 1")
                {
                    Caption = 'period1', Locked = true;
                }
                field(period2Amount; "Period 2")
                {
                    Caption = 'period2', Locked = true;
                }
                field(period3Amount; "Period 3")
                {
                    Caption = 'period3', Locked = true;
                }
                field(agedAsOfDate; "Period Start Date")
                {
                    Caption = 'periodStartDate', Locked = true;
                }
                field(periodLengthFilter; "Period Length")
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
        GraphMgtReports.SetUpAgedReportAPIData(RecVariant, ReportAPIType::"Aged Accounts Receivable");
    end;
}


