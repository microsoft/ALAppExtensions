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
                field(netChange; "Net Change")
                {
                    AutoFormatType = 0;
                    BlankZero = true;
                    Caption = 'Net Change';
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
        ReportAPIType: Option "Balance Sheet","Income Statement","Trial Balance","CashFlow Statement","Aged Accounts Payable","Aged Accounts Receivable","Retained Earnings";
    begin
        RecVariant := Rec;
        GraphMgtReports.SetUpAccountScheduleBaseAPIDataWrapper(RecVariant, ReportAPIType::"Income Statement");
    end;
}


