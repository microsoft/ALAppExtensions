codeunit 31041 "Company Info Handler CZL"
{
    var
        BankOperationsFunctionsCZL: Codeunit "Bank Operations Functions CZL";

    [EventSubscriber(ObjectType::Table, Database::"Company Information", 'OnBeforeValidateEvent', 'Bank Account No.', false, false)]
    local procedure CheckCzBankAccountNoOnBeforeBankAccountNoValidate(var Rec: Record "Company Information")
    begin
        BankOperationsFunctionsCZL.CheckCzBankAccountNo(Rec."Bank Account No.", Rec."Country/Region Code");
    end;

    [EventSubscriber(ObjectType::Table, Database::"Company Information", 'OnBeforeValidateEvent', 'Country/Region Code', false, false)]
    local procedure CheckCzBankAccountNoOnBeforeCountryRegionCodeValidate(var Rec: Record "Company Information")
    begin
        BankOperationsFunctionsCZL.CheckCzBankAccountNo(Rec."Bank Account No.", Rec."Country/Region Code");
    end;
}
