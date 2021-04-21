pageextension 31158 "Bank Account List CZP" extends "Bank Account List"
{
    trigger OnOpenPage()
    var
        CashDeskSingleInstanceCZP: Codeunit "Cash Desk Single Instance CZP";
    begin
        if CashDeskSingleInstanceCZP.GetShowAllBankAccountType() then begin
            Caption := 'Bank Account and Cash Desk List';
            exit;
        end;

        Rec.FilterGroup(2);
        Rec.SetRange("Account Type CZP", Rec."Account Type CZP"::"Bank Account");
        Rec.FilterGroup(0);
    end;
}
