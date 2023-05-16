pageextension 4859 "AutoAcc Purchase Order Subform" extends "Purchase Order Subform"
{
    layout
    {
        addafter("Appl.-to Item Entry")
        {
            field("Automatic Account Group"; Rec."Automatic Account Group")
            {
                ApplicationArea = Basic, Suite;
                ToolTip = 'Specifies an automatic account group code.';
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
