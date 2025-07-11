namespace Microsoft.Bank.StatementImport.Yodlee;

using Microsoft.Bank.BankAccount;
using Microsoft.Finance.GeneralLedger.Setup;

table 1451 "MS - Yodlee Bank Acc. Link"
{
    ReplicateData = false;
    DataClassification = CustomerContent;

    fields
    {
        field(1; "No."; Code[20])
        {
            TableRelation = "Bank Account"."No.";
        }
        field(2; "Online Bank Account ID"; Text[250])
        {
        }
        field(3; "Online Bank ID"; Text[250])
        {
        }
        field(4; "Automatic Logon Possible"; Boolean)
        {
        }
        field(5; Name; Text[50])
        {
        }
        field(6; "Currency Code"; Code[10])
        {
        }
        field(7; Contact; Text[50])
        {
        }
        field(8; "Bank Account No."; Text[30])
        {
        }
        field(100; "Temp Linked Bank Account No."; Code[20])
        {
        }
    }

    keys
    {
        key(Key1; "No.")
        {
            Clustered = true;
        }
        key(Key2; "Online Bank Account ID")
        {
        }
    }

    fieldgroups
    {
    }

    procedure CreateBankAccount(var BankAccount: Record 270);
    var
        GeneralLedgerSetup: Record "General Ledger Setup";
        CurrencyCode: Code[10];
    begin
        GeneralLedgerSetup.GET();
        if "Currency Code" <> '' then
            CurrencyCode := GeneralLedgerSetup.GetCurrencyCode("Currency Code");
        BankAccount.INIT();
        BankAccount.VALIDATE("Bank Account No.", "Bank Account No.");
        BankAccount.VALIDATE(Name, Name);
        BankAccount.VALIDATE("Currency Code", CurrencyCode);
        BankAccount.VALIDATE(Contact, Contact);
        BankAccount.INSERT(true);
    end;
}

