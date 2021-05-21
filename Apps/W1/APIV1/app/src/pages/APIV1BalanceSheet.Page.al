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
                field(lineNumber; "Line No.")
                {
                    Caption = 'lineNumber', Locked = true;
                }
                field(display; Description)
                {
                    Caption = 'description', Locked = true;
                }
                field(balance; Balance)
                {
                    AutoFormatType = 0;
                    BlankZero = true;
                    Caption = 'balance', Locked = true;
                }
                field(lineType; "Line Type")
                {
                    Caption = 'lineType', Locked = true;
                }
                field(indentation; Indentation)
                {
                    Caption = 'indentation', Locked = true;
                }
                field(dateFilter; "Date Filter")
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


