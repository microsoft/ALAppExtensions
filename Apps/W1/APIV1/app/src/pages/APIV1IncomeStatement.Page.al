namespace Microsoft.API.V1;

using Microsoft.Integration.Entity;
using Microsoft.Integration.Graph;

page 20035 "APIV1 - Income Statement"
{
    APIVersion = 'v1.0';
    Caption = 'incomeStatement', Locked = true;
    DelayedInsert = true;
    DeleteAllowed = false;
    Editable = false;
    EntityName = 'incomeStatement';
    EntitySetName = 'incomeStatement';
    InsertAllowed = false;
    ModifyAllowed = false;
    PageType = API;
    SourceTable = "Acc. Schedule Line Entity";
    SourceTableTemporary = true;
    Extensible = false;

    layout
    {
        area(content)
        {
            repeater(Group)
            {
                field(lineNumber; Rec."Line No.")
                {
                    Caption = 'lineNumber', Locked = true;
                }
                field(display; Rec.Description)
                {
                    Caption = 'description', Locked = true;
                }
                field(netChange; Rec."Net Change")
                {
                    AutoFormatType = 0;
                    BlankZero = true;
                    Caption = 'netChange', Locked = true;
                }
                field(lineType; Rec."Line Type")
                {
                    Caption = 'lineType', Locked = true;
                }
                field(indentation; Rec.Indentation)
                {
                    Caption = 'indentation', Locked = true;
                }
                field(dateFilter; Rec."Date Filter")
                {
                    Caption = 'dateFilter', Locked = true;
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



