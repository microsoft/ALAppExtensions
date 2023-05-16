pageextension 4866 "AA Sales Return Order Subform" extends "Sales Return Order Subform"
{
    layout
    {
        addafter("Appl.-to Item Entry")
        {
            field("Automatic Account Group"; Rec."Automatic Account Group")
            {
                ApplicationArea = Basic, Suite;
                ToolTip = 'Specifies a code relating to an automatic account group.';
#if not CLEAN22
                Visible = AutomaticAccountCodesAppEnabled;
                Enabled = AutomaticAccountCodesAppEnabled;
#endif
            }
        }
    }
#if not CLEAN22
    trigger OnOpenPage()
    begin
        AutomaticAccountCodesAppEnabled := AutoAccCodesFeatureMgt.IsEnabled();
    end;

    var
        AutoAccCodesFeatureMgt: Codeunit "Auto. Acc. Codes Feature Mgt.";
        AutomaticAccountCodesAppEnabled: Boolean;
#endif
}
