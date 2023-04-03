pageextension 31014 "Detailed Vend.Ledg.Entries CZL" extends "Detailed Vendor Ledg. Entries"
{
    layout
    {
        addlast(Control1)
        {
#if not CLEAN22
#pragma warning disable AL0432
            field("Vendor Posting Group CZL"; Rec."Vendor Posting Group CZL")
#pragma warning restore AL0432
            {
                ApplicationArea = Basic, Suite;
                ToolTip = 'Specifies the vendor''s market type to link business transactions made for the vendor with the appropriate account in the general ledger.';
#if not CLEAN20
                Visible = not AllowMultiplePostingGroupsEnabled;
#else
                Visible = false;
#endif
                ObsoleteState = Pending;
                ObsoleteTag = '22.0';
                ObsoleteReason = 'Replaced by "Posting Group" field.';
            }
#endif
            field("Posting Group CZL"; Rec."Posting Group")
            {
                ApplicationArea = Basic, Suite;
                ToolTip = 'Specifies the customer''s market type to link business transactions to.';
#if not CLEAN20
                Visible = AllowMultiplePostingGroupsEnabled;
#endif
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