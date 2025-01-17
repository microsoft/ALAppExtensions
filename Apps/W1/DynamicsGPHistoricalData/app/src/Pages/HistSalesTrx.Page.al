namespace Microsoft.DataMigration.GP.HistoricalData;

page 41007 "Hist. Sales Trx."
{
    PageType = Card;
    Caption = 'Historical Sales Transaction';
    SourceTable = "Hist. Sales Trx. Header";
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
                field("No."; Rec."No.")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the No. field.';
                }
                field("Sales Trx. Status"; Rec."Sales Trx. Status")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Sales Trx. Status field.';
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
                field("Actual Ship Date"; Rec."Actual Ship Date")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Actual Ship Date field.';
                }
                field("Currency Code"; Rec."Currency Code")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Currency Code field.';
                }
                field("Sub Total"; Rec."Sub Total")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Sub Total field.';
                }
                field("Tax Amount"; Rec."Tax Amount")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Ext. Price field.';
                }
                field("Trade Disc. Amount"; Rec."Trade Disc. Amount")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Trade Discount Amount field.';
                }
                field("Freight Amount"; Rec."Freight Amount")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Freight Amount field.';
                }
                field("Misc. Amount"; Rec."Misc. Amount")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Miscellaneous Amount field.';
                }
                field("Payment Recv. Amount"; Rec."Payment Recv. Amount")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Payment Received Amount field.';
                }
                field("Disc. Taken Amount"; Rec."Disc. Taken Amount")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Discount Taken Amount field.';
                }
                field(Total; Rec.Total)
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Total field.';
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
                field("Contact Person Name"; Rec."Contact Person Name")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Contact Person Name field.';
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
                field("Ship Method"; Rec."Ship Method")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Ship Method field.';
                }
                field("Ship-to Code"; Rec."Ship-to Code")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Ship-to Code field.';
                }
                field("Ship-to Name"; Rec."Ship-to Name")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Ship-to Name field.';
                }
                field("Ship-to Address"; Rec."Ship-to Address")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Ship-to Address field.';
                }
                field("Ship-to Address 2"; Rec."Ship-to Address 2")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Ship-to Address 2 field.';
                }
                field("Ship-to City"; Rec."Ship-to City")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Ship-to City field.';
                }
                field("Ship-to State"; Rec."Ship-to State")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Ship-to State field.';
                }
                field("Ship-to Zipcode"; Rec."Ship-to Zipcode")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Ship-to Zipcode field.';
                }
                field("Ship-to Country"; Rec."Ship-to Country")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Ship-to Country field.';
                }
                field("Original No."; Rec."Original No.")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Original No. field.';
                }
                field("Customer Purchase No."; Rec."Customer Purchase No.")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Customer Purchase No. field.';
                }
                field("Audit Code"; Rec."Audit Code")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Audit Code field.';
                }
                field("Sales Trx. Type"; Rec."Sales Trx. Type")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Sales Type field.';
                }
            }
            group(Lines)
            {
                Caption = 'Sales Transaction Lines';

                part(SalesTrxLines; "Hist. Sales Trx. Lines")
                {
                    Caption = 'Historical Sales Transaction Lines';
                    ShowFilter = false;
                    ApplicationArea = All;
                    SubPageLink = "Sales Header No." = field("No.");
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
        DataCaptionExpressionTxt := Rec."No.";
    end;

    var
        DataCaptionExpressionTxt: Text;
}