pageextension 31222 "Posted Service Inv. Update CZL" extends "Posted Service Inv. - Update"
{
    layout
    {
        addlast(Payment)
        {
            field("Variable Symbol CZL"; Rec."Variable Symbol CZL")
            {
                ApplicationArea = Basic, Suite;
                ToolTip = 'Specifies the detail information for payment.';
                Importance = Promoted;
                Editable = true;
            }
            field("Constant Symbol CZL"; Rec."Constant Symbol CZL")
            {
                ApplicationArea = Basic, Suite;
                ToolTip = 'Specifies the additional symbol of bank payments.';
                Importance = Additional;
                Editable = true;
            }
            field("Specific Symbol CZL"; Rec."Specific Symbol CZL")
            {
                ApplicationArea = Basic, Suite;
                ToolTip = 'Specifies the additional symbol of bank payments.';
                Importance = Additional;
                Editable = true;
            }
        }
    }
}
