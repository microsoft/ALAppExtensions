pageextension 31158 "Bank Account List" extends "Bank Account List"
{
    trigger OnOpenPage()
    begin
        Rec.FilterGroup(2);
        Rec.SetRange("Account Type CZP", Rec."Account Type CZP"::"Bank Account");
        Rec.FilterGroup(0);
    end;
}
