namespace Microsoft.API.V2;

using Microsoft.Integration.Entity;
using Microsoft.Integration.Graph;

page 30029 "APIV2 - Retained Earnings"
{
    APIVersion = 'v2.0';
    EntityCaption = 'Retained Earnings Statement';
    EntitySetCaption = 'Retained Earnings Statements';
    DelayedInsert = true;
    DeleteAllowed = false;
    Editable = false;
    EntityName = 'retainedEarningsStatement';
    EntitySetName = 'retainedEarningsStatements';
    InsertAllowed = false;
    ModifyAllowed = false;
    PageType = API;
    SourceTable = "Acc. Schedule Line Entity";
    SourceTableTemporary = true;
    Extensible = false;
    ODataKeyFields = Id;
    AboutText = 'Provides read-only access to retained earnings statement data, including net changes, descriptions, fiscal period breakdowns, and company-level summaries. Supports GET operations for automating financial reporting, enabling integration with external accounting, consolidation, compliance, and audit systems requiring up-to-date retained earnings insights.';

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
        GraphMgtReports.SetUpAccountScheduleBaseAPIDataWrapper(RecVariant, ReportAPIType::"Retained Earnings");
    end;
}

