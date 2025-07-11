namespace Microsoft.API.V1;

using Microsoft.Integration.Graph;
using Microsoft.Integration.Entity;

page 20033 "APIV1 - Balance Sheet"
{
    APIVersion = 'v1.0';
    Caption = 'balanceSheet', Locked = true;
    DelayedInsert = true;
    DeleteAllowed = false;
    Editable = false;
    EntityName = 'balanceSheet';
    EntitySetName = 'balanceSheet';
    InsertAllowed = false;
    ModifyAllowed = false;
    PageType = API;
    SourceTable = "Balance Sheet Buffer";
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
                field(balance; Rec.Balance)
                {
                    AutoFormatType = 0;
                    BlankZero = true;
                    Caption = 'balance', Locked = true;
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
    begin
        RecVariant := Rec;
        GraphMgtReports.SetUpBalanceSheetAPIData(RecVariant);
    end;

}



