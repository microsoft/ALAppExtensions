pageextension 31159 "Bank Account Card CZP" extends "Bank Account Card"
{
    trigger OnOpenPage()
    begin
        Rec.FilterGroup(2);
        Rec.SetRange("Account Type CZP", Rec."Account Type CZP"::"Bank Account");
        Rec.FilterGroup(0);
    end;
}
