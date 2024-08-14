namespace Microsoft.DataMigration.GP.HistoricalData;

page 41006 "Hist. Receivables Document"
{
    PageType = Card;
    Caption = 'Historical Receivables Document';
    SourceTable = "Hist. Receivables Document";
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
                field("Trx. Description"; Rec."Trx. Description")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Trx. Description field.';
                }
                field("Document Date"; Rec."Document Date")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Document Date field.';
                }
                field("Due Date"; Rec."Due Date")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Due Date field.';
                }
                field("Invoice Paid Off Date"; Rec."Invoice Paid Off Date")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Invoice Paid Off Date field.';
                }
                field("Currency Code"; Rec."Currency Code")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Currency field.';
                }
                field("Current Trx. Amount"; Rec."Current Trx. Amount")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Current Trx. Amount field.';
                }
                field("Orig. Trx. Amount"; Rec."Orig. Trx. Amount")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Orig. Trx. Amount field.';
                }
                field("Sales Amount"; Rec."Sales Amount")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Sales Amount field.';
                }
                field("Misc. Amount"; Rec."Misc. Amount")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Misc. Amount field.';
                }
                field("Freight Amount"; Rec."Freight Amount")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Freight Amount field.';
                }
                field("Tax Amount"; Rec."Tax Amount")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Tax Amount field.';
                }
                field("Cost Amount"; Rec."Cost Amount")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Cost Amount field.';
                }
                field("Cash Amount"; Rec."Cash Amount")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Cash Amount field.';
                }
                field("Disc. Taken Amount"; Rec."Disc. Taken Amount")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Disc. Taken Amount field.';
                }
                field("Sales Territory"; Rec."Sales Territory")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Sales Territory field.';
                }
                field("Salesperson No."; Rec."Salesperson No.")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Salesperson No. field.';
                }
                field("Commission Dollar Amount"; Rec."Commission Dollar Amount")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Commission Dollar Amount field.';
                }
                field("Ship Method"; Rec."Ship Method")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Ship Method field.';
                }
                field("Customer No."; Rec."Customer No.")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Customer No. field.';
                }
                field("Customer Name"; Rec."Customer Name")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Customer Name field.';
                }
                field("Payment Terms ID"; Rec."Payment Terms ID")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Payment Terms ID field.';
                }
                field("Write Off Amount"; Rec."Write Off Amount")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Write Off Amount field.';
                }
                field("Customer Purchase No."; Rec."Customer Purchase No.")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Customer Purchase No. field.';
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
                field("Audit Code"; Rec."Audit Code")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Audit Code field.';
                }
                field("Post Date"; Rec."Post Date")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Post Date field.';
                }
                field(User; Rec.User)
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the User field.';
                }
            }
            group(Apply)
            {
                Caption = 'Receivables Apply';

                part(HistReceivablesApplyList; "Hist. Receivables Apply List")
                {
                    Caption = 'Historical Receivables Apply Lines';
                    ShowFilter = false;
                    ApplicationArea = All;
                    SubPageLink = "Customer No." = field("Customer No.");
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
        CurrPage.HistReceivablesApplyList.Page.FilterByDocumentNo(Rec."Document Type", Rec."Document No.");
        DataCaptionExpressionTxt := Format(Rec."Document Type") + ' - ' + Rec."Document No.";
    end;

    var
        DataCaptionExpressionTxt: Text;
}