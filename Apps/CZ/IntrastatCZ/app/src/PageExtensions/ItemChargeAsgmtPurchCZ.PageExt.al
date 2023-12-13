#if not CLEAN24
pageextension 31410 "Item Charge Asgmt. (Purch) CZ" extends "Item Charge Assignment (Purch)"
{
    ObsoleteState = Pending;
    ObsoleteTag = '24.0';
    ObsoleteReason = 'Intrastat related functionalities are moving to Intrastat extension.';
#if not CLEAN22

    layout
    {
#pragma warning disable AL0432
        modify("Incl. in Intrastat Amount CZL")
        {
            Enabled = not IntrastatEnabled;
            Visible = not IntrastatEnabled;
        }
        modify("Incl. in Intrastat S.Value CZL")
        {
            Enabled = not IntrastatEnabled;
            Visible = not IntrastatEnabled;
        }
#pragma warning restore AL0432
    }

    trigger OnOpenPage()
    begin
        IntrastatEnabled := IntrastatReportManagement.IsFeatureEnabled();
    end;

    var
        IntrastatReportManagement: Codeunit IntrastatReportManagement;
        IntrastatEnabled: Boolean;
#endif
}
#endif