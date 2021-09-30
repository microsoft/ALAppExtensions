pageextension 31012 "Vendor Posting Groups CZL" extends "Vendor Posting Groups"
{
    actions
    {
#pragma warning disable AL0432
        addlast(navigation)
#pragma warning restore AL0432
        {
            group("Posting Group CZL")
            {
                Caption = '&Posting Group';

                action("Substitutions CZL")
                {
                    ApplicationArea = Basic, Suite;
                    Caption = 'Substitutions';
                    Image = Relationship;
                    Promoted = true;
                    PromotedCategory = Process;
                    PromotedIsBig = true;
                    RunObject = Page "Subst. Vend. Post. Groups CZL";
                    RunPageLink = "Parent Vendor Posting Group" = Field(Code);
                    ToolTip = 'View or edit the related vendor posting group substitutions.';
                }
            }
        }
    }
}