namespace Microsoft.DataMigration.GP.HistoricalData;

page 41012 "Hist. Inventory Trx. Headers"
{
    ApplicationArea = All;
    Caption = 'Historical Inventory Trx. List';
    PageType = List;
    CardPageId = "Hist. Inventory Trx.";
    Editable = false;
    DeleteAllowed = false;
    InsertAllowed = false;
    LinksAllowed = false;
    ModifyAllowed = false;
    SourceTable = "Hist. Inventory Trx. Header";
    UsageCategory = History;

    layout
    {
        area(Content)
        {
            repeater(ListData)
            {
                field("Document No."; Rec."Document No.")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Document No. field.';
                }
                field("Document Type"; Rec."Document Type")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Document Type field.';
                }
                field("Document Date"; Rec."Document Date")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Document Date field.';
                }
                field("Post Date"; Rec."Post Date")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Post Date field.';
                }
                field("Batch No."; Rec."Batch No.")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Batch No. field.';
                }
                field("Batch Source"; Rec."Batch Source")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Batch Source field.';
                }
                field("Source Reference No."; Rec."Source Reference No.")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Source Reference No. field.';
                }
                field("Source Indicator"; Rec."Source Indicator")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Source Indicator field.';
                }
                field("Audit Code"; Rec."Audit Code")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Audit Code field.';
                }
            }
        }
    }
}