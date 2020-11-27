tableextension 11747 "Company Information CZL" extends "Company Information"
{
    fields
    {
        field(11770; "Default Bank Account Code CZL"; Code[20])
        {
            Caption = 'Default Bank Account Code';
            TableRelation = "Bank Account" where("Currency Code" = const(''));
            DataClassification = CustomerContent;

            trigger OnValidate()
            var
                BankAccount: Record "Bank Account";
            begin
                if "Default Bank Account Code CZL" <> '' then begin
                    BankAccount.Get("Default Bank Account Code CZL");
                    Validate("Bank Name", BankAccount.Name);
                    Validate("Bank Account No.", BankAccount."Bank Account No.");
                    Validate(IBAN, BankAccount.IBAN);
                    Validate("SWIFT Code", BankAccount."SWIFT Code");
                    Validate("Payment Routing No.", BankAccount."Transit No.");
                    Validate("Bank Branch No.", BankAccount."Bank Branch No.");
                end;
            end;
        }
        field(11771; "Bank Branch Name CZL"; Text[100])
        {
            Caption = 'Bank Branch Name';
            DataClassification = CustomerContent;
        }
        field(11772; "Bank Account Format Check CZL"; Boolean)
        {
            Caption = 'Bank Account Format Check';
            DataClassification = CustomerContent;
        }
        field(11782; "Tax Registration No. CZL"; Text[20])
        {
            Caption = 'Tax Registration No.';
            DataClassification = CustomerContent;
        }
    }
}
