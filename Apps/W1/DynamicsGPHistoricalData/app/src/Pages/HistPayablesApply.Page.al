namespace Microsoft.DataMigration.GP.HistoricalData;

page 41023 "Hist. Payables Apply"
{
    ApplicationArea = All;
    UsageCategory = None;
    Caption = 'Historical Payables Apply';
    PageType = Card;
    SourceTable = "Hist. Payables Apply";
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

                field("Vendor No."; Rec."Vendor No.")
                {
                    ToolTip = 'Specifies the value of the Vendor No. field.';
                }
                field("Vendor Name"; Rec."Vendor Name")
                {
                    ToolTip = 'Specifies the value of the Vendor Name field.';
                }
                field("Document Type"; Rec."Document Type")
                {
                    ToolTip = 'Specifies the value of the Document Type field.';
                }
                field("Apply To Voucher No."; Rec."Apply To Voucher No.")
                {
                    ToolTip = 'Specifies the value of the Apply To Voucher No. field.';
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
                field("Voucher No."; Rec."Voucher No.")
                {
                    ToolTip = 'Specifies the value of the Voucher No. field.';
                }
                field("Document Amount"; Rec."Document Amount")
                {
                    ToolTip = 'Specifies the value of the Document Amount field.';
                }
                field("Currency Code"; Rec."Currency Code")
                {
                    ToolTip = 'Specifies the value of the Currency Code field.';
                }
                field("Disc. Taken Amount"; Rec."Disc. Taken Amount")
                {
                    ToolTip = 'Specifies the value of the Disc. Taken Amount field.';
                }
                field("Write Off Amount"; Rec."Write Off Amount")
                {
                    ToolTip = 'Specifies the value of the Write Off Amount field.';
                }
                field("Orig. Applied Amount"; Rec."Orig. Applied Amount")
                {
                    ToolTip = 'Specifies the value of the Orig. Applied Amount field.';
                }
                field("Orig. Discount Taken Amount"; Rec."Orig. Discount Taken Amount")
                {
                    ToolTip = 'Specifies the value of the Orig. Discount Taken Amount field.';
                }
                field("Orig. Discount Available Taken"; Rec."Orig. Discount Available Taken")
                {
                    ToolTip = 'Specifies the value of the Orig. Discount Available Taken field.';
                }
                field("Orig. Write Off Amount"; Rec."Orig. Write Off Amount")
                {
                    ToolTip = 'Specifies the value of the Orig. Write Off Amount field.';
                }
                field("Apply To Post Date"; Rec."Apply To Post Date")
                {
                    ToolTip = 'Specifies the value of the Apply To Post Date field.';
                }
                field("Apply From Document No."; Rec."Apply From Document No.")
                {
                    ToolTip = 'Specifies the value of the Apply From Document No. field.';
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
                    ToolTip = 'Specifies the value of the Apply From Discount Taken Amount field.';
                }
                field("Apply From Disc. Avail. Taken"; Rec."Apply From Disc. Avail. Taken")
                {
                    ToolTip = 'Specifies the value of the Apply From Discount Available Taken field.';
                }
                field("Apply From Write Off Amount"; Rec."Apply From Write Off Amount")
                {
                    ToolTip = 'Specifies the value of the Apply From Write Off Amount field.';
                }
                field("Actual Apply To Amount"; Rec."Actual Apply To Amount")
                {
                    ToolTip = 'Specifies the value of the Actual Apply To Amount field.';
                }
                field("Actual Discount Taken Amount"; Rec."Actual Discount Taken Amount")
                {
                    ToolTip = 'Specifies the value of the Actual Discount Taken Amount field.';
                }
                field("Actual Disc. Available Taken"; Rec."Actual Disc. Available Taken")
                {
                    ToolTip = 'Specifies the value of the Actual Disc. Available Taken field.';
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
                    ToolTip = 'Specifies the value of the Apply From Denom. Exchange Rate field.';
                }
                field("PPS Amount Deducted"; Rec."PPS Amount Deducted")
                {
                    ToolTip = 'Specifies the value of the PPS Amount Deducted field.';
                }
                field("GST Discount Amount"; Rec."GST Discount Amount")
                {
                    ToolTip = 'Specifies the value of the GST Discount Amount field.';
                }
                field("1099 Amount"; Rec."1099 Amount")
                {
                    ToolTip = 'Specifies the value of the 1099 Amount field.';
                }
                field("Credit 1099 Amount"; Rec."Credit 1099 Amount")
                {
                    ToolTip = 'Specifies the value of the Credit 1099 Amount field.';
                }
            }
            group(Documents)
            {
                Caption = 'Payables Documents';

                part(HistPayablesDocumentList; "Hist. Payables Document List")
                {
                    Caption = 'Historical Payables Document Lines';
                    ShowFilter = false;
                    ApplicationArea = All;
                    SubPageLink = "Vendor No." = field("Vendor No."), "Document Type" = field("Apply To Document Type"), "Document No." = field("Apply To Document No.");
                }
            }
        }
    }

    trigger OnAfterGetCurrRecord()
    begin
        DataCaptionExpressionTxt := Format(Rec."Document Type") + ' - ' + Rec."Voucher No.";
    end;

    var
        DataCaptionExpressionTxt: Text;
}