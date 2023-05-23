#if not CLEAN22
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
                Caption = '&Posting Group (Obsolete)';
                ObsoleteState = Pending;
                ObsoleteTag = '22.0';
                ObsoleteReason = 'Replaced by Posting Group group.';

                action("Substitutions CZL")
                {
                    ApplicationArea = Basic, Suite;
                    Caption = 'Substitutions (Obsolete)';
                    Image = Relationship;
                    Promoted = true;
                    PromotedCategory = Process;
                    PromotedIsBig = true;
                    RunObject = Page "Subst. Vend. Post. Groups CZL";
                    RunPageLink = "Parent Vendor Posting Group" = Field(Code);
                    ToolTip = 'View or edit the related vendor posting group substitutions.';
#if not CLEAN20
                    Visible = not AllowMultiplePostingGroupsEnabled;
#else
                    Visible = false;
#endif
                    ObsoleteState = Pending;
                    ObsoleteTag = '22.0';
                    ObsoleteReason = 'Replaced by Alternative action.';
                }
            }
        }
    }
#if not CLEAN20

    trigger OnOpenPage()
    begin
        AllowMultiplePostingGroupsEnabled := PostingGroupManagement.IsAllowMultipleCustVendPostingGroupsEnabled();
    end;

    var
#pragma warning disable AL0432
        PostingGroupManagement: Codeunit "Posting Group Management CZL";
#pragma warning restore AL0432
        AllowMultiplePostingGroupsEnabled: Boolean;
#endif
}
#endif