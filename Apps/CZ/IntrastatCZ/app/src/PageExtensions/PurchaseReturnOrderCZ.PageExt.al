pageextension 31351 "Purchase Return Order CZ" extends "Purchase Return Order"
{
    layout
    {
#if not CLEAN22
#pragma warning disable AL0432
        modify("Physical Transfer CZL")
#pragma warning restore AL0432
        {
            Visible = not IntrastatEnabled;
            Enabled = not IntrastatEnabled;
        }
#endif
        addlast("Shipping and Payment")
        {
            field("Physical Transfer CZ"; Rec."Physical Transfer CZ")
            {
                ApplicationArea = Basic, Suite;
                Caption = 'Physical Transfer';
                ToolTip = 'Specifies if there is physical transfer of the item.';
#if not CLEAN22
                Visible = IntrastatEnabled;
                Enabled = IntrastatEnabled;
#endif
            }
        }
    }
#if not CLEAN22

    trigger OnOpenPage()
    begin
        IntrastatEnabled := IntrastatReportManagement.IsFeatureEnabled();
    end;

    var
        IntrastatReportManagement: Codeunit IntrastatReportManagement;
        IntrastatEnabled: Boolean;
#endif
}