pageextension 11754 "Posted Serv. Credit Memos CZL" extends "Posted Service Credit Memos"
{
    layout
    {
        addafter("Posting Date")
        {
#if not CLEAN22
            field("VAT Date CZL"; Rec."VAT Date CZL")
            {
                ApplicationArea = Basic, Suite;
                Caption = 'VAT Date (Obsolete)';
                ToolTip = 'Specifies date by which the accounting transaction will enter VAT statement.';
                Visible = false;
                ObsoleteState = Pending;
                ObsoleteTag = '22.0';
                ObsoleteReason = 'Replaced by VAT Reporting Date.';
            }
#endif
            field("VAT Reporting Date CZL"; Rec."VAT Reporting Date")
            {
                ApplicationArea = Basic, Suite;
                ToolTip = 'Specifies the date used to include entries on VAT reports in a VAT period. This is either the date that the document was created or posted, depending on your setting on the General Ledger Setup page.';
                Visible = false;
            }
        }
        addlast(Control1)
        {
            field("Credit Memo Type CZL"; Rec."Credit Memo Type CZL")
            {
                ApplicationArea = Basic, Suite;
                ToolTip = 'Specifies the type of credit memo (corrective tax document, internal correction, insolvency tax document).';
                Visible = false;
            }
            field("Variable Symbol CZL"; Rec."Variable Symbol CZL")
            {
                ApplicationArea = Basic, Suite;
                ToolTip = 'Specifies the detail information for payment.';
            }
            field("Constant Symbol CZL"; Rec."Constant Symbol CZL")
            {
                ApplicationArea = Basic, Suite;
                ToolTip = 'Specifies the additional symbol of bank payments.';
                Visible = false;
            }
            field("Specific Symbol CZL"; Rec."Specific Symbol CZL")
            {
                ApplicationArea = Basic, Suite;
                ToolTip = 'Specifies the additional symbol of bank payments.';
                Visible = false;
            }
            field("Bank Account Code CZL"; Rec."Bank Account Code CZL")
            {
                ApplicationArea = Basic, Suite;
                ToolTip = 'Specifies a code to idenfity bank account of company.';
                Visible = false;
            }
            field("Bank Account No. CZL"; Rec."Bank Account No. CZL")
            {
                ApplicationArea = Basic, Suite;
                ToolTip = 'Specifies the number used by the bank for the bank account.';
            }
            field("IBAN CZL"; Rec."IBAN CZL")
            {
                ApplicationArea = Basic, Suite;
                ToolTip = 'Specifies the bank account''s international bank account number.';
            }
            field("Intrastat Exclude CZL"; Rec."Intrastat Exclude CZL")
            {
                ApplicationArea = Basic, Suite;
                ToolTip = 'Specifies that entry will be excluded from intrastat.';
                Visible = false;
            }
            field("Physical Transfer CZL"; Rec."Physical Transfer CZL")
            {
                ApplicationArea = SalesReturnOrder;
                ToolTip = 'Specifies if there is physical transfer of the item.';
                Visible = false;
            }
        }
    }
}
