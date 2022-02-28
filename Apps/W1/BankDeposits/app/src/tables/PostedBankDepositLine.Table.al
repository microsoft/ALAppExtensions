table 1692 "Posted Bank Deposit Line"
{
    Caption = 'Posted Bank Deposit Line';
    LookupPageID = "Posted Bank Deposit Lines";

    fields
    {
        field(1; "Bank Deposit No."; Code[20])
        {
            Caption = 'Bank Deposit No.';
            TableRelation = "Posted Bank Deposit Header";
        }
        field(2; "Line No."; Integer)
        {
            Caption = 'Line No.';
        }
        field(3; "Account Type"; Enum "Gen. Journal Account Type")
        {
            Caption = 'Account Type';
            InitValue = Customer;
        }
        field(4; "Account No."; Code[20])
        {
            Caption = 'Account No.';
            TableRelation = IF ("Account Type" = CONST("G/L Account")) "G/L Account"
            ELSE
            IF ("Account Type" = CONST(Customer)) Customer
            ELSE
            IF ("Account Type" = CONST(Vendor)) Vendor
            ELSE
            IF ("Account Type" = CONST("Bank Account")) "Bank Account"
            ELSE
            IF ("Account Type" = CONST("IC Partner")) "IC Partner";
        }
        field(5; "Document Date"; Date)
        {
            Caption = 'Document Date';
        }
        field(6; "Document Type"; Enum "Gen. Journal Document Type")
        {
            Caption = 'Document Type';
        }
        field(7; "Document No."; Code[20])
        {
            Caption = 'Document No.';
        }
        field(8; Description; Text[100])
        {
            Caption = 'Description';
        }
        field(9; "Currency Code"; Code[10])
        {
            Caption = 'Currency Code';
            Editable = false;
            TableRelation = Currency;
        }
        field(10; Amount; Decimal)
        {
            AutoFormatExpression = "Currency Code";
            AutoFormatType = 1;
            Caption = 'Amount';
            MinValue = 0;
        }
        field(11; "Posting Group"; Code[20])
        {
            Caption = 'Posting Group';
            Editable = false;
            TableRelation = IF ("Account Type" = CONST(Customer)) "Customer Posting Group"
            ELSE
            IF ("Account Type" = CONST(Vendor)) "Vendor Posting Group";
        }
        field(12; "Shortcut Dimension 1 Code"; Code[20])
        {
            CaptionClass = '1,2,1';
            Caption = 'Shortcut Dimension 1 Code';
            TableRelation = "Dimension Value".Code WHERE("Global Dimension No." = CONST(1));
        }
        field(13; "Shortcut Dimension 2 Code"; Code[20])
        {
            CaptionClass = '1,2,2';
            Caption = 'Shortcut Dimension 2 Code';
            TableRelation = "Dimension Value".Code WHERE("Global Dimension No." = CONST(2));
        }
        field(14; "Posting Date"; Date)
        {
            Caption = 'Posting Date';
        }
        field(15; "Bank Account Ledger Entry No."; Integer)
        {
            Caption = 'Bank Account Ledger Entry No.';
            TableRelation = "Bank Account Ledger Entry";
        }
        field(16; "Entry No."; Integer)
        {
            Caption = 'Entry No.';
            TableRelation = IF ("Account Type" = CONST("G/L Account")) "G/L Entry"
            ELSE
            IF ("Account Type" = CONST(Customer)) "Cust. Ledger Entry"
            ELSE
            IF ("Account Type" = CONST(Vendor)) "Vendor Ledger Entry"
            ELSE
            IF ("Account Type" = CONST("Bank Account")) "Bank Account Ledger Entry";
        }
        field(480; "Dimension Set ID"; Integer)
        {
            Caption = 'Dimension Set ID';
            Editable = false;
            TableRelation = "Dimension Set Entry";

            trigger OnLookup()
            begin
                ShowDimensions();
            end;
        }
    }

    keys
    {
        key(Key1; "Bank Deposit No.", "Line No.")
        {
            Clustered = true;
            SumIndexFields = Amount;
        }
        key(Key2; "Account Type", "Account No.")
        {
        }
        key(Key3; "Document No.", "Posting Date")
        {
        }
        key(Key4; "Bank Account Ledger Entry No.")
        {
        }
    }

    fieldgroups
    {
    }

    var
        DimensionManagement: Codeunit DimensionManagement;

    [Scope('OnPrem')]
    procedure ShowDimensions()
    begin
        DimensionManagement.ShowDimensionSet("Dimension Set ID", TableCaption() + ' ' + "Document No." + ' ' + Format("Line No."));
    end;

    [Scope('OnPrem')]
    procedure ShowAccountCard()
    var
        GLAccount: Record "G/L Account";
        Customer: Record Customer;
        Vendor: Record Vendor;
        BankAccount: Record "Bank Account";
    begin
        case "Account Type" of
            "Account Type"::"G/L Account":
                begin
                    GLAccount."No." := "Account No.";
                    PAGE.Run(PAGE::"G/L Account Card", GLAccount);
                end;
            "Account Type"::Customer:
                begin
                    Customer."No." := "Account No.";
                    PAGE.Run(PAGE::"Customer Card", Customer);
                end;
            "Account Type"::Vendor:
                begin
                    Vendor."No." := "Account No.";
                    PAGE.Run(PAGE::"Vendor Card", Vendor);
                end;
            "Account Type"::"Bank Account":
                begin
                    BankAccount."No." := "Account No.";
                    PAGE.Run(PAGE::"Bank Account Card", BankAccount);
                end;
        end;
    end;

    [Scope('OnPrem')]
    procedure ShowAccountLedgerEntries()
    var
        GLEntry: Record "G/L Entry";
        CustLedgerEntry: Record "Cust. Ledger Entry";
        VendorLedgerEntry: Record "Vendor Ledger Entry";
        BankAccountLedgerEntry: Record "Bank Account Ledger Entry";
    begin
        case "Account Type" of
            "Account Type"::"G/L Account":
                begin
                    GLEntry.SetCurrentKey("G/L Account No.", "Posting Date");
                    GLEntry.SetRange("G/L Account No.", "Account No.");
                    if not GLEntry.Get("Entry No.") then
                        if GLEntry.FindLast() then;
                    PAGE.Run(PAGE::"General Ledger Entries", GLEntry);
                end;
            "Account Type"::Customer:
                begin
                    CustLedgerEntry.SetCurrentKey("Customer No.", "Posting Date");
                    CustLedgerEntry.SetRange("Customer No.", "Account No.");
                    if not CustLedgerEntry.Get("Entry No.") then
                        if CustLedgerEntry.FindLast() then;
                    PAGE.Run(PAGE::"Customer Ledger Entries", CustLedgerEntry);
                end;
            "Account Type"::Vendor:
                begin
                    VendorLedgerEntry.SetCurrentKey("Vendor No.", "Posting Date");
                    VendorLedgerEntry.SetRange("Vendor No.", "Account No.");
                    if not VendorLedgerEntry.Get("Entry No.") then
                        if VendorLedgerEntry.FindLast() then;
                    PAGE.Run(PAGE::"Vendor Ledger Entries", VendorLedgerEntry);
                end;
            "Account Type"::"Bank Account":
                begin
                    BankAccountLedgerEntry.SetCurrentKey("Bank Account No.", "Posting Date");
                    BankAccountLedgerEntry.SetRange("Bank Account No.", "Account No.");
                    if not BankAccountLedgerEntry.Get("Entry No.") then
                        if BankAccountLedgerEntry.FindLast() then;
                    PAGE.Run(PAGE::"Bank Account Ledger Entries", BankAccountLedgerEntry);
                end;
        end;
    end;
}

