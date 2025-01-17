namespace Microsoft.DataMigration.GP.HistoricalData;

page 41010 "Hist. Inventory Trx."
{
    PageType = Card;
    Caption = 'Historical Inventory Transaction';
    SourceTable = "Hist. Inventory Trx. Header";
    ApplicationArea = All;
    UsageCategory = None;
    Editable = false;
    DeleteAllowed = false;
    InsertAllowed = false;
    ModifyAllowed = false;
    DataCaptionExpression = DataCaptionExpressionTxt;

    layout
    {
        area(Content)
        {
            group(Main)
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

            group(Lines)
            {
                Caption = 'Inventory Transaction Lines';

                part(InventoryTrxLines; "Hist. Inventory Trx. Lines")
                {
                    Caption = 'Historical Inventory Transaction Lines';
                    ShowFilter = false;
                    ApplicationArea = All;
                    SubPageLink = "Document Type" = field("Document Type"), "Document No." = field("Document No.");
                }
            }
        }
    }

    actions
    {
        area(Promoted)
        {
            actionref(ViewDistributions_Promoted; ViewDistributions)
            {
            }
        }
        area(Processing)
        {
            action(ViewDistributions)
            {
                ApplicationArea = All;
                Caption = 'View Distributions';
                ToolTip = 'View the G/L account distributions related to this transaction.';
                Image = RelatedInformation;

                trigger OnAction()
                var
                    HistGenJournalLines: Page "Hist. Gen. Journal Lines";
                begin
                    HistGenJournalLines.SetFilterOriginatingTrxSourceNo(Rec."Audit Code");
                    HistGenJournalLines.Run();
                end;
            }
        }
    }

    trigger OnAfterGetCurrRecord()
    begin
        DataCaptionExpressionTxt := Format(Rec."Document Type") + ' - ' + Rec."Document No.";
    end;

    var
        DataCaptionExpressionTxt: Text;
}