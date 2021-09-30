pageextension 31011 "Customer Posting Groups CZL" extends "Customer Posting Groups"
{
    actions
    {
#pragma warning disable AL0432
        addlast(Navigation)
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
                    RunObject = Page "Subst. Cust. Post. Groups CZL";
                    RunPageLink = "Parent Customer Posting Group" = Field(Code);
                    ToolTip = 'View or edit the related customer posting group substitutions.';
                }
            }
        }
    }
}