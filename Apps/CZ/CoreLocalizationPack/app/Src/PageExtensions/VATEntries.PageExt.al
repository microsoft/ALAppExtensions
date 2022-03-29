pageextension 11755 "VAT Entries CZL" extends "VAT Entries"
{
    layout
    {
        addafter("Posting Date")
        {
            field("VAT Date CZL"; Rec."VAT Date CZL")
            {
                ApplicationArea = Basic, Suite;
                ToolTip = 'Specifies date by which the accounting transaction will enter VAT statement.';
            }
            field("VAT Settlement No. CZL"; Rec."VAT Settlement No. CZL")
            {
                ApplicationArea = Basic, Suite;
                ToolTip = 'Specifies the document number which the VAT entries were closed.';
                Visible = false;
            }
        }
        addafter("Document No.")
        {
            field("External Document No. CZL"; Rec."External Document No.")
            {
                ApplicationArea = Basic, Suite;
                ToolTip = 'Specifies the number that the vendor uses on the invoice they sent to you or number of receipt.';
            }
        }
        addafter("VAT Registration No.")
        {
            field("Registration No. CZL"; Rec."Registration No. CZL")
            {
                ApplicationArea = Basic, Suite;
                ToolTip = 'Specifies the registration number of customer or vendor.';
                Visible = false;
            }
            field("Tax Registration No. CZL"; Rec."Tax Registration No. CZL")
            {
                ApplicationArea = Basic, Suite;
                ToolTip = 'Specifies the secondary VAT registration number for the customer or vedor.';
                Visible = false;
            }
        }
        addafter("EU 3-Party Trade")
        {
            field("EU 3-Party Intermed. Role CZL"; Rec."EU 3-Party Intermed. Role CZL")
            {
                ApplicationArea = VAT;
                ToolTip = 'Specifies when the VAT entry will use European Union third-party intermediate trade rules. This option complies with VAT accounting standards for EU third-party trade.';
            }
        }
        addlast(Control1)
        {
            field("VAT Ctrl. Report No. CZL"; Rec."VAT Ctrl. Report No. CZL")
            {
                ApplicationArea = VAT;
                ToolTip = 'Specifies vat control report no.';
            }
            field("VAT Ctrl. Report Line No. CZL"; Rec."VAT Ctrl. Report Line No. CZL")
            {
                ApplicationArea = VAT;
                ToolTip = 'Specifies the number of line in the VAT control report.';
            }
            field("VAT Identifier CZL"; Rec."VAT Identifier CZL")
            {
                ApplicationArea = Basic, Suite;
                ToolTip = 'Specifies a code to group various VAT posting setups with similar attributes, for example VAT percentage.';
                Visible = false;
            }
        }
    }
}
