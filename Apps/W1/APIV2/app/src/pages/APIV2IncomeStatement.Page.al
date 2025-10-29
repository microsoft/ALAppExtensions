namespace Microsoft.API.V2;

using Microsoft.Integration.Entity;
using Microsoft.Integration.Graph;

page 30035 "APIV2 - Income Statement"
{
    APIVersion = 'v2.0';
    EntityCaption = 'Income Statement';
    EntitySetCaption = 'Income Statements';
    DelayedInsert = true;
    DeleteAllowed = false;
    Editable = false;
    EntityName = 'incomeStatement';
    EntitySetName = 'incomeStatements';
    InsertAllowed = false;
    ModifyAllowed = false;
    PageType = API;
    SourceTable = "Acc. Schedule Line Entity";
    SourceTableTemporary = true;
    Extensible = false;
    ODataKeyFields = Id;
    AboutText = 'Provides read-only access to income statement data, including revenues, expenses, net change, and account breakdowns over specified periods. Supports GET operations for financial analysis, automated reporting, and integration with external business intelligence or management dashboards to deliver timely profitability insights.';

    layout
    {
        area(content)
        {
            repeater(Group)
            {
                field(id; Rec.Id)
                {
                    Caption = 'Id';
                    Editable = false;
                }
                field(lineNumber; Rec."Line No.")
                {
                    Caption = 'Line No.';
                }
                field(display; Rec.Description)
                {
                    Caption = 'Description';
                }
                field(netChange; Rec."Net Change")
                {
                    AutoFormatType = 0;
                    BlankZero = true;
                    Caption = 'Net Change';
                }
                field(lineType; Rec."Line Type")
                {
                    Caption = 'Line Type';
                }
                field(indentation; Rec.Indentation)
                {
                    Caption = 'Indentation';
                }
                field(dateFilter; Rec."Date Filter")
                {
                    Caption = 'Date Filter';
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
        GraphMgtReports.SetUpAccountScheduleBaseAPIDataWrapper(RecVariant, ReportAPIType::"Income Statement");
    end;
}


