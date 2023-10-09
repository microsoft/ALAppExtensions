#if not CLEAN22
pageextension 31346 "Customer Card CZ" extends "Customer Card"
{
    ObsoleteState = Pending;
    ObsoleteTag = '22.0';
    ObsoleteReason = 'Intrastat related functionalities are moving to Intrastat extension.';

    layout
    {
#pragma warning disable AL0432
        modify("Transaction Type CZL")
#pragma warning restore AL0432
        {
            Enabled = not IntrastatEnabled;
            Visible = not IntrastatEnabled;
        }
#pragma warning disable AL0432
        modify("Transport Method CZL")
#pragma warning restore AL0432
        {
            Enabled = not IntrastatEnabled;
            Visible = not IntrastatEnabled;
        }
    }

    trigger OnOpenPage()
    begin
        IntrastatEnabled := IntrastatReportManagement.IsFeatureEnabled();
    end;

    var
        IntrastatReportManagement: Codeunit IntrastatReportManagement;
        IntrastatEnabled: Boolean;
}
#endif