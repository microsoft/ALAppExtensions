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
#pragma warning disable AL0432
        modify("Intrastat Exclude CZL")
#pragma warning restore AL0432
        {
            Enabled = not IntrastatEnabled;
            Visible = not IntrastatEnabled;
        }
#endif
        addlast("Foreign Trade")
        {
            field("Intrastat Exclude CZ"; Rec."Intrastat Exclude CZ")
            {
                ApplicationArea = Basic, Suite;
                Caption = 'Intrastat Exclude';
                ToolTip = 'Specifies that entry will be excluded from intrastat.';
#if not CLEAN22
                Enabled = IntrastatEnabled;
                Visible = IntrastatEnabled;
#endif
            }
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