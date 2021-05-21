codeunit 31108 "Cash Desk Single Instance CZP"
{
    SingleInstance = true;

    var
        ShowAllBankAccountType: Boolean;

    procedure SetShowAllBankAccountType(NewShowAllBankAccountType: Boolean)
    begin
        ShowAllBankAccountType := NewShowAllBankAccountType;
    end;

    procedure GetShowAllBankAccountType(): Boolean
    begin
        exit(ShowAllBankAccountType);
    end;
}
