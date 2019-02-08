pageextension 13621 PaymentApplication extends "Payment Application"
{
    layout
    {
        modify(Control2)
        {
            Visible = ShowMatchConfidence;
        }
    }
    procedure SetMatchConfidence(Value: Boolean);
    begin
        ShowMatchConfidence := Value;
    end;

    var
        ShowMatchConfidence: Boolean;
}