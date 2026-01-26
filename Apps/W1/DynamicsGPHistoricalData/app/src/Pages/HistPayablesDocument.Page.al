namespace Microsoft.DataMigration.GP.HistoricalData;

page 41008 "Hist. Payables Document"
{
    PageType = Card;
    Caption = 'Historical Payables Document';
    SourceTable = "Hist. Payables Document";
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
                field("Document Amount"; Rec."Document Amount")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Document Amount field.';
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
                field("Disc. Taken Amount"; Rec."Disc. Taken Amount")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Disc. Taken Amount field.';
                }
                field("Trade Discount Amount"; Rec."Trade Discount Amount")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Trade Discount Amount field.';
                }
                field("Total Payments"; Rec."Total Payments")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Total Payments field.';
                }
                field("Vendor No."; Rec."Vendor No.")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Vendor No. field.';
                }
                field("Vendor Name"; Rec."Vendor Name")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Vendor Name field.';
                }
                field("Payment Terms ID"; Rec."Payment Terms ID")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Payment Terms ID field.';
                }
                field("Ship Method"; Rec."Ship Method")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Ship Method field.';
                }
                field("Write Off Amount"; Rec."Write Off Amount")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Write Off Amount field.';
                }
                field("1099 Type"; Rec."1099 Type")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the 1099 Type field.';
                }
                field("1099 Amount"; Rec."1099 Amount")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the 1099 Amount field.';
                }
                field("1099 Box Number"; Rec."1099 Box Number")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the 1099 Box Number field.';
                }
                field("PO Number"; Rec."PO Number")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the PO Number field.';
                }
                field("Voucher No."; Rec."Voucher No.")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Voucher No. field.';
                }
                field("Audit Code"; Rec."Audit Code")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Audit Code field.';
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
                field("Post Date"; Rec."Post Date")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Post Date field.';
                }
                field(Voided; Rec.Voided)
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Voided field.';
                }
                field("Purchase No."; Rec."Purchase No.")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Purchase No. field.';
                }
                field(User; Rec.User)
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the User field.';
                }
            }
            group(Apply)
            {
                Caption = 'Payables Apply';

                part(HistPayablesApplyList; "Hist. Payables Apply List")
                {
                    Caption = 'Historical Payables Apply Lines';
                    ShowFilter = false;
                    ApplicationArea = All;
                    SubPageLink = "Vendor No." = field("Vendor No.");
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
        CurrPage.HistPayablesApplyList.Page.FilterByVoucherNo(Rec."Document Type", Rec."Voucher No.");
        DataCaptionExpressionTxt := Format(Rec."Document Type") + ' - ' + Rec."Document No.";
    end;

    var
        DataCaptionExpressionTxt: Text;
}