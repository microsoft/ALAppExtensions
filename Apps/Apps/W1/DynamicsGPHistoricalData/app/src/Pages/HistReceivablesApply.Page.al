namespace Microsoft.DataMigration.GP.HistoricalData;

page 41024 "Hist. Receivables Apply"
{
    ApplicationArea = All;
    UsageCategory = None;
    Caption = 'Historical Receivables Apply';
    PageType = Card;
    SourceTable = "Hist. Receivables Apply";
    DeleteAllowed = false;
    InsertAllowed = false;
    ModifyAllowed = false;
    DataCaptionExpression = DataCaptionExpressionTxt;

    layout
    {
        area(content)
        {
            group(General)
            {
                Caption = 'General';

                field("Customer No."; Rec."Customer No.")
                {
                    ToolTip = 'Specifies the value of the Customer No. field.';
                }
                field("Customer Name"; Rec."Customer Name")
                {
                    ToolTip = 'Specifies the value of the Customer Name field.';
                }
                field("Corporate Customer No."; Rec."Corporate Customer No.")
                {
                    ToolTip = 'Specifies the value of the Corporate Customer No. field.';
                }
                field("Date"; Rec."Date")
                {
                    Caption = 'Trx. Date';
                    ToolTip = 'Specifies the value of the Date field.';
                }
                field("GL Posting Date"; Rec."GL Posting Date")
                {
                    ToolTip = 'Specifies the value of the GL Posting Date field.';
                }
                field("Apply To Document No."; Rec."Apply To Document No.")
                {
                    ToolTip = 'Specifies the value of the Apply To Document No. field.';
                }
                field("Apply To Document Type"; Rec."Apply To Document Type")
                {
                    ToolTip = 'Specifies the value of the Apply To Document Type field.';
                }
                field("Apply To Document Date"; Rec."Apply To Document Date")
                {
                    ToolTip = 'Specifies the value of the Apply To Document Date field.';
                }
                field("Apply To GL Posting Date"; Rec."Apply To GL Posting Date")
                {
                    ToolTip = 'Specifies the value of the Apply To GL Posting Date field.';
                }
                field("Currency Code"; Rec."Currency Code")
                {
                    ToolTip = 'Specifies the value of the Currency Code field.';
                }
                field("Apply To Amount"; Rec."Apply To Amount")
                {
                    ToolTip = 'Specifies the value of the Apply To Amount field.';
                }
                field("Discount Taken Amount"; Rec."Discount Taken Amount")
                {
                    ToolTip = 'Specifies the value of the Discount Taken Amount field.';
                }
                field("Discount Available Taken"; Rec."Discount Available Taken")
                {
                    ToolTip = 'Specifies the value of the Discount Available Taken field.';
                }
                field("Write Off Amount"; Rec."Write Off Amount")
                {
                    ToolTip = 'Specifies the value of the Write Off Amount field.';
                }
                field("Orig. Apply To Amount"; Rec."Orig. Apply To Amount")
                {
                    ToolTip = 'Specifies the value of the Orig. Apply To Amount field.';
                }
                field("Orig. Disc. Taken Amount"; Rec."Orig. Disc. Taken Amount")
                {
                    ToolTip = 'Specifies the value of the Orig. Disc. Taken Amount field.';
                }
                field("Orig. Disc. Available Taken"; Rec."Orig. Disc. Available Taken")
                {
                    ToolTip = 'Specifies the value of the Orig. Disc. Available Taken field.';
                }
                field("Orig. Write Off Amount"; Rec."Orig. Write Off Amount")
                {
                    ToolTip = 'Specifies the value of the Orig. Write Off Amount field.';
                }
                field("Apply To Exchange Rate"; Rec."Apply To Exchange Rate")
                {
                    ToolTip = 'Specifies the value of the Apply To Exchange Rate field.';
                }
                field("Apply To Denom. Exch. Rate"; Rec."Apply To Denom. Exch. Rate")
                {
                    ToolTip = 'Specifies the value of the Apply To Denom. Exch. Rate field.';
                }
                field("Apply From Document No."; Rec."Apply From Document No.")
                {
                    ToolTip = 'Specifies the value of the Apply From Document No. field.';
                }
                field("Apply From Document Type"; Rec."Apply From Document Type")
                {
                    ToolTip = 'Specifies the value of the Apply From Document Type field.';
                }
                field("Apply From Document Date"; Rec."Apply From Document Date")
                {
                    ToolTip = 'Specifies the value of the Apply From Document Date field.';
                }
                field("Apply From GL Posting Date"; Rec."Apply From GL Posting Date")
                {
                    ToolTip = 'Specifies the value of the Apply From GL Posting Date field.';
                }
                field("Apply From Currency Code"; Rec."Apply From Currency Code")
                {
                    ToolTip = 'Specifies the value of the Apply From Currency Code field.';
                }
                field("Apply From Apply Amount"; Rec."Apply From Apply Amount")
                {
                    ToolTip = 'Specifies the value of the Apply From Apply Amount field.';
                }
                field("Apply From Disc. Taken Amount"; Rec."Apply From Disc. Taken Amount")
                {
                    ToolTip = 'Specifies the value of the Apply From Disc. Taken Amount field.';
                }
                field("Apply From Disc. Avail. Taken"; Rec."Apply From Disc. Avail. Taken")
                {
                    ToolTip = 'Specifies the value of the Apply From Disc. Avail. Taken field.';
                }
                field("Apply From Write Off Amount"; Rec."Apply From Write Off Amount")
                {
                    ToolTip = 'Specifies the value of the Apply From Write Off Amount field.';
                }
                field("Actual Apply To Amount"; Rec."Actual Apply To Amount")
                {
                    ToolTip = 'Specifies the value of the Actual Apply To Amount field.';
                }
                field("Actual Disc. Taken Amount"; Rec."Actual Disc. Taken Amount")
                {
                    ToolTip = 'Specifies the value of the Actual Disc. Taken Amount field.';
                }
                field("Actual Disc. Avail. Taken"; Rec."Actual Disc. Avail. Taken")
                {
                    ToolTip = 'Specifies the value of the Actual Disc. Avail. Taken field.';
                }
                field("Actual Write Off Amount"; Rec."Actual Write Off Amount")
                {
                    ToolTip = 'Specifies the value of the Actual Write Off Amount field.';
                }
                field("Apply From Exchange Rate"; Rec."Apply From Exchange Rate")
                {
                    ToolTip = 'Specifies the value of the Apply From Exchange Rate field.';
                }
                field("Apply From Denom. Exch. Rate"; Rec."Apply From Denom. Exch. Rate")
                {
                    ToolTip = 'Specifies the value of the Apply From Denom. Exch. Rate field.';
                }
                field("Apply From Round Amount"; Rec."Apply From Round Amount")
                {
                    ToolTip = 'Specifies the value of the Apply From Round Amount field.';
                }
                field("Apply To Round Amount"; Rec."Apply To Round Amount")
                {
                    ToolTip = 'Specifies the value of the Apply To Round Amount field.';
                }
                field("Apply To Round Discount"; Rec."Apply To Round Discount")
                {
                    ToolTip = 'Specifies the value of the Apply To Round Discount field.';
                }
                field("Orig. Apply From Round Amount"; Rec."Orig. Apply From Round Amount")
                {
                    ToolTip = 'Specifies the value of the Orig. Apply From Round Amount field.';
                }
                field("Orig. Apply To Round Amount"; Rec."Orig. Apply To Round Amount")
                {
                    ToolTip = 'Specifies the value of the Orig. Apply To Round Amount field.';
                }
                field("Orig. Apply To Round Discount"; Rec."Orig. Apply To Round Discount")
                {
                    ToolTip = 'Specifies the value of the Orig. Apply To Round Discount field.';
                }
                field("GST Discount Amount"; Rec."GST Discount Amount")
                {
                    ToolTip = 'Specifies the value of the GST Discount Amount field.';
                }
                field("PPS Amount Deducted"; Rec."PPS Amount Deducted")
                {
                    ToolTip = 'Specifies the value of the PPS Amount Deducted field.';
                }
                field("Realized Gain-Loss Amount"; Rec."Realized Gain-Loss Amount")
                {
                    ToolTip = 'Specifies the value of the Realized Gain-Loss Amount field.';
                }
                field("Settled Gain CreditCurrTrx"; Rec."Settled Gain CreditCurrTrx")
                {
                    ToolTip = 'Specifies the value of the Settled Gain CreditCurrTrx field.';
                }
                field("Settled Loss CreditCurrTrx"; Rec."Settled Loss CreditCurrTrx")
                {
                    ToolTip = 'Specifies the value of the Settled Loss CreditCurrTrx field.';
                }
                field("Settled Gain DebitCurrTrx"; Rec."Settled Gain DebitCurrTrx")
                {
                    ToolTip = 'Specifies the value of the Settled Gain DebitCurrTrx field.';
                }
                field("Settled Loss DebitCurrTrx"; Rec."Settled Loss DebitCurrTrx")
                {
                    ToolTip = 'Specifies the value of the Settled Loss DebitCurrTrx field.';
                }
                field("Settled Gain DebitDiscAvail"; Rec."Settled Gain DebitDiscAvail")
                {
                    ToolTip = 'Specifies the value of the Settled Gain DebitDiscAvail field.';
                }
                field("Settled Loss DebitDiscAvail"; Rec."Settled Loss DebitDiscAvail")
                {
                    ToolTip = 'Specifies the value of the Settled Loss DebitDiscAvail field.';
                }
                field("Audit Code"; Rec."Audit Code")
                {
                    ToolTip = 'Specifies the value of the Audit Code field.';
                }
            }
            group(Documents)
            {
                Caption = 'Receivables Documents';

                part(HistReceivablesDocumentList; "Hist. Recv. Document List")
                {
                    Caption = 'Historical Receivables Document List';
                    ShowFilter = false;
                    ApplicationArea = All;
                    SubPageLink = "Customer No." = field("Customer No."), "Document Type" = field("Apply To Document Type"), "Document No." = field("Apply To Document No.");
                }
            }
        }
    }

    trigger OnAfterGetCurrRecord()
    begin
        DataCaptionExpressionTxt := Format(Rec."Apply From Document Type") + ' - ' + Rec."Apply From Document No.";
    end;

    var
        DataCaptionExpressionTxt: Text;
}