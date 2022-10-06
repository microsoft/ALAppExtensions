pageextension 1708 "Navigate Ext." extends Navigate
{
    layout
    {
        modify(ContactType)
        {
            trigger OnBeforeValidate()
            begin
                NavigationFromPostedBankDeposit := (ContactType = ContactType::"Bank Account");
            end;
        }
    }

    var
        NavigationFromPostedBankDeposit: Boolean;

    internal procedure GetNoOfRecords(TableID: Integer): Integer
    begin
        exit(NoOfRecords(TableID));
    end;

    internal procedure SetNavigationFromPostedBankDeposit(Value: Boolean)
    begin
        NavigationFromPostedBankDeposit := Value;
    end;

    internal procedure GetNavigationFromPostedBankDeposit(): Boolean
    begin
        exit(NavigationFromPostedBankDeposit);
    end;
}