pageextension 4702 "VAT Report List Extension" extends "VAT Report List"
{
    layout
    {
        // Add changes to page layout here
        addafter("VAT Report Type")
        {
            field("VAT Group Return"; Rec."VAT Group Return")
            {
                ApplicationArea = Basic, Suite;
                ToolTip = 'Specifies whether or not this is a VAT group return.';
                Visible = IsGroupRepresentative;
            }
        }
        addbefore(Status)
        {
            field("VAT Group Status"; Rec."VAT Group Status")
            {
                ApplicationArea = Basic, Suite;
                ToolTip = 'Specifies the status of the VAT return on the group representative side. If this VAT return was used in any VAT Group return on the representative side, that status is mirrored here.';
                Visible = (not Rec."VAT Group Return") and IsGroupMember;
            }
        }
    }
    var
        VATReportSetup: Record "VAT Report Setup";
        IsGroupMember: Boolean;
        IsGroupRepresentative: Boolean;

    trigger OnAfterGetRecord()
    begin
        if not VATReportSetup.Get() then
            exit;
        IsGroupMember := VATReportSetup.IsGroupMember();
        IsGroupRepresentative := VATReportSetup.IsGroupRepresentative();
    end;
}