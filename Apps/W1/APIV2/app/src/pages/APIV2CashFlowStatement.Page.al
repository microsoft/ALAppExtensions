namespace Microsoft.API.V2;

using Microsoft.Integration.Entity;
using Microsoft.Integration.Graph;

page 30026 "APIV2 - Cash Flow Statement"
{
    APIVersion = 'v2.0';
    EntityCaption = 'Cash Flow Statement';
    EntitySetCaption = 'Cash Flow Statements';
    DelayedInsert = true;
    DeleteAllowed = false;
    Editable = false;
    EntityName = 'cashFlowStatement';
    EntitySetName = 'cashFlowStatements';
    InsertAllowed = false;
    ModifyAllowed = false;
    PageType = API;
    SourceTable = "Acc. Schedule Line Entity";
    SourceTableTemporary = true;
    Extensible = false;
    ODataKeyFields = Id;

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
        GraphMgtReports.SetUpAccountScheduleBaseAPIDataWrapper(RecVariant, ReportAPIType::"CashFlow Statement");
    end;
}

