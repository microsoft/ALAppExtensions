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

    layout
    {
        area(content)
        {
            repeater(Group)
            {
                field(id; Id)
                {
                    Caption = 'Id';
                    Editable = false;
                }
                field(lineNumber; "Line No.")
                {
                    Caption = 'Line No.';
                }
                field(display; Description)
                {
                    Caption = 'Description';
                }
                field(balance; Balance)
                {
                    AutoFormatType = 0;
                    BlankZero = true;
                    Caption = 'Balance';
                }
                field(lineType; "Line Type")
                {
                    Caption = 'Line Type';
                }
                field(indentation; Indentation)
                {
                    Caption = 'Indentation';
                }
                field(dateFilter; "Date Filter")
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


