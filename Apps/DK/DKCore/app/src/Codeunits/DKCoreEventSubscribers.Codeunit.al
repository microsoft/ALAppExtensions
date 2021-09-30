codeunit 13601 "DK Core Event Subscribers"
{

    [EventSubscriber(ObjectType::Table, Database::"Bank Account", 'OnValidateBankAccount', '', false, false)]
    local procedure ValidateBankAccount(var BankAccount: Record "Bank Account"; FieldToValidate: Text);
    begin
        ValidateBankAcc(BankAccount."Bank Account No.", BankAccount."Bank Branch No.", FieldToValidate);
    end;

    [EventSubscriber(ObjectType::Table, Database::"Bank Account", 'OnGetBankAccount', '', false, false)]
    local procedure GetBankAccountNo(var Handled: Boolean; BankAccount: Record "Bank Account"; var ResultBankAccountNo: Text);
    begin
        Handled := true;

        GetBankAccNo(BankAccount."Bank Account No.", BankAccount."Bank Branch No.", BankAccount.IBAN, ResultBankAccountNo);
    end;

    [EventSubscriber(ObjectType::Table, Database::"Customer Bank Account", 'OnValidateBankAccount', '', false, false)]
    local procedure ValidateCustomerBankAccount(var CustomerBankAccount: Record "Customer Bank Account"; FieldToValidate: Text);
    begin
        ValidateBankAcc(CustomerBankAccount."Bank Account No.", CustomerBankAccount."Bank Branch No.", FieldToValidate);
    end;

    [EventSubscriber(ObjectType::Table, Database::"Customer Bank Account", 'OnGetBankAccount', '', false, false)]
    local procedure GetCustomerBankAccountNo(var Handled: Boolean; CustomerBankAccount: Record "Customer Bank Account"; var ResultBankAccountNo: Text);
    begin
        Handled := true;

        GetBankAccNo(CustomerBankAccount."Bank Account No.", CustomerBankAccount."Bank Branch No.", CustomerBankAccount.IBAN, ResultBankAccountNo);
    end;

    [EventSubscriber(ObjectType::Table, Database::"Vendor Bank Account", 'OnValidateBankAccount', '', false, false)]
    local procedure ValidateVendorBankAccount(var VendorBankAccount: Record "Vendor Bank Account"; FieldToValidate: Text);
    begin
        ValidateBankAcc(VendorBankAccount."Bank Account No.", VendorBankAccount."Bank Branch No.", FieldToValidate);
    end;

    [EventSubscriber(ObjectType::Table, Database::"Vendor Bank Account", 'OnGetBankAccount', '', false, false)]
    local procedure GetVendorBankAccountNo(var Handled: Boolean; VendorBankAccount: Record "Vendor Bank Account"; var ResultBankAccountNo: Text);
    begin
        Handled := true;

        GetBankAccNo(VendorBankAccount."Bank Account No.", VendorBankAccount."Bank Branch No.", VendorBankAccount.IBAN, ResultBankAccountNo);
    end;

    [EventSubscriber(ObjectType::Codeunit, Codeunit::"Application Area Mgmt.", 'OnGetBasicExperienceAppAreas', '', false, false)]
    local procedure OnGetBasicExperienceAppAreas(var TempApplicationAreaSetup: Record "Application Area Setup" temporary);
    begin
        TempApplicationAreaSetup."Basic DK" := true;
    end;

    [EventSubscriber(ObjectType::Codeunit, Codeunit::"Pre & Post Process XML Import", 'OnCheckBankAccNo', '', false, false)]
    local procedure OnCheckBankAccNo(var Handled: Boolean; var CheckedResult: Boolean; DataExchFieldDetails: Query "Data Exch. Field Details"; BankAccount: Record "Bank Account");
    begin
        Handled := true;

        if (DelChr(DataExchFieldDetails.FieldValue, '=', '- ') <> DelChr(BankAccount."Bank Account No." + BankAccount."Bank Branch No.", '=', '- ')) then
            CheckedResult := true
    end;

    local procedure ValidateBankAcc(var BankAccountNo: Text[30]; var BankBranchNo: Text[20]; FieldToValidate: Text)
    begin
        case FieldToValidate of
            'Bank Account No.':
                if (BankAccountNo <> '') and (StrLen(BankAccountNo) < 10) then
                    BankAccountNo := PadStr('', 10 - StrLen(BankAccountNo), '0') + BankAccountNo;
            'Bank Branch No.':
                if (BankBranchNo <> '') and (StrLen(BankBranchNo) < 4) then
                    BankBranchNo := PadStr('', 4 - StrLen(BankBranchNo), '0') + BankBranchNo;
        end;
    end;

    local procedure GetBankAccNo(BankAccountNo: Text[30]; BankBranchNo: Text[20]; IBAN: Code[50]; var ResultAccountNo: Text)
    begin
        if (BankBranchNo = '') or (BankAccountNo = '') then
            ResultAccountNo := DelChr(IBAN, '=<>')
        else
            ResultAccountNo := BankBranchNo + BankAccountNo;
    end;
}