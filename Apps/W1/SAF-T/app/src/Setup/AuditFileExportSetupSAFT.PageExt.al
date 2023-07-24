pageextension 5285 "Audit File Export Setup SAF-T" extends "Audit File Export Setup"
{
    layout
    {
        addafter(DefaultPostCode)
        {
            field("Default Payment Method Code"; Rec."Default Payment Method Code")
            {
                ApplicationArea = Basic, Suite;
                ToolTip = 'Specifies the payment method to use when no value is specified for a payment or a refund.';
                Enabled = SAFTFormat;
                Visible = SAFTFormat;
            }
        }
    }

    trigger OnOpenPage()
    begin
        SAFTFormat := IsSAFTFormat();
    end;

    trigger OnAfterGetCurrRecord()
    begin
        SAFTFormat := IsSAFTFormat();
    end;

    var
        SAFTFormat: Boolean;

    local procedure IsSAFTFormat(): Boolean
    begin
        exit(Rec."Audit File Export Format" = Enum::"Audit File Export Format"::SAFT);
    end;
}