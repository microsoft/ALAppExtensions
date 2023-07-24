pageextension 31115 "Posted Return Receipt CZL" extends "Posted Return Receipt"
{
    layout
    {
#if not CLEAN20
#pragma warning disable AL0432
        movelast(General; "Posting Description")
#pragma warning restore AL0432
#else
        addlast(General)
        {
            field("Posting Description CZL"; Rec."Posting Description")
            {
                ApplicationArea = SalesReturnOrder;
                Editable = false;
                ToolTip = 'Specifies a description of the document. The posting description also appers on customer and G/L entries.';
                Visible = false;
            }
        }
#endif
        addbefore("Location Code")
        {
            field("Reason Code CZL"; Rec."Reason Code")
            {
                ApplicationArea = Basic, Suite;
                Editable = false;
                ToolTip = 'Specifies the reason code on the entry.';
                Visible = true;
            }
        }
        addafter("Document Date")
        {
            field("Correction CZL"; Rec.Correction)
            {
                ApplicationArea = Basic, Suite;
                Editable = false;
                ToolTip = 'Specifies if you need to post a corrective entry to an account.';
            }
        }
        addlast(Invoicing)
        {
            field("VAT Bus. Posting Group CZL"; Rec."VAT Bus. Posting Group")
            {
                ApplicationArea = Basic, Suite;
                Editable = false;
                ToolTip = 'Specifies a VAT business posting group code.';
            }
            field("Customer Posting Group CZL"; Rec."Customer Posting Group")
            {
                ApplicationArea = Basic, Suite;
                Editable = false;
                ToolTip = 'Specifies the customerÍs market type to link business transactions to.';
            }
        }
#if not CLEAN22
        addlast(Shipping)
        {
            field("Intrastat Exclude CZL"; Rec."Intrastat Exclude CZL")
            {
                ApplicationArea = Basic, Suite;
                Caption = 'Intrastat Exclude (Obsolete)';
                ToolTip = 'Specifies that entry will be excluded from intrastat.';
                Editable = false;
                ObsoleteState = Pending;
                ObsoleteTag = '22.0';
                ObsoleteReason = 'Intrastat related functionalities are moved to Intrastat extensions. This field is not used any more.';
            }
            field("Physical Transfer CZL"; Rec."Physical Transfer CZL")
            {
                ApplicationArea = Basic, Suite;
                Caption = 'Physical Transfer (Obsolete)';
                ToolTip = 'Specifies if there is physical transfer of the item.';
                Editable = false;
                ObsoleteState = Pending;
                ObsoleteTag = '22.0';
                ObsoleteReason = 'Intrastat related functionalities are moved to Intrastat extensions.';
            }
        }
#endif
    }
}
