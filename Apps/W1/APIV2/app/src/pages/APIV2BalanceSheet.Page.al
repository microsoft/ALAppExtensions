namespace Microsoft.API.V2;

using Microsoft.Integration.Graph;
using Microsoft.Integration.Entity;

page 30033 "APIV2 - Balance Sheet"
{
    APIVersion = 'v2.0';
    EntityCaption = 'Balance Sheet';
    EntitySetCaption = 'Balance Sheets';
    DelayedInsert = true;
    DeleteAllowed = false;
    Editable = false;
    EntityName = 'balanceSheet';
    EntitySetName = 'balanceSheets';
    InsertAllowed = false;
    ModifyAllowed = false;
    PageType = API;
    SourceTable = "Balance Sheet Buffer";
    SourceTableTemporary = true;
    Extensible = false;
    ODataKeyFields = Id;
    AboutText = 'Provides read-only access to balance sheet reports, detailing assets, liabilities, and equity with account-level breakdowns and date filters. Supports GET operations for retrieving financial position data at specific points in time, enabling automated financial reporting, compliance, and integration with external accounting or consolidation systems.';

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
                field(balance; Rec.Balance)
                {
                    AutoFormatType = 0;
                    BlankZero = true;
                    Caption = 'Balance';
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
    begin
        RecVariant := Rec;
        GraphMgtReports.SetUpBalanceSheetAPIData(RecVariant);
    end;

}


