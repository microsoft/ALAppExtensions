tableextension 11701 "Customer CZL" extends Customer
{
    fields
    {
        field(11770; "Registration No. CZL"; Text[20])
        {
            Caption = 'Registration No.';
            DataClassification = CustomerContent;

            trigger OnValidate()
            var
                RegistrationLogCZL: Record "Registration Log CZL";
                RegNoServiceConfigCZL: Record "Reg. No. Service Config CZL";
                ResultRecordRef: RecordRef;
                LogNotVerified: Boolean;
            begin
                if not RegistrationNoMgtCZL.CheckRegistrationNo("Registration No. CZL", "No.", Database::Customer) then
                    exit;

                LogNotVerified := true;
                if "Registration No. CZL" <> xRec."Registration No. CZL" then
                    if RegNoServiceConfigCZL.RegNoSrvIsEnabled() then begin
                        LogNotVerified := false;
                        RegistrationLogMgtCZL.ValidateRegNoWithARES(ResultRecordRef, Rec, "No.", RegistrationLogCZL."Account Type"::Customer);
                        ResultRecordRef.SetTable(Rec);
                    end;

                if LogNotVerified then
                    RegistrationLogMgtCZL.LogCustomer(Rec);
            end;
        }
        field(11771; "Tax Registration No. CZL"; Text[20])
        {
            Caption = 'Tax Registration No.';
            DataClassification = CustomerContent;

            trigger OnValidate()
            begin
                RegistrationNoMgtCZL.CheckTaxRegistrationNo("Tax Registration No. CZL", "No.", Database::Customer);
            end;
        }
        field(11772; "Validate Registration No. CZL"; Boolean)
        {
            Caption = 'Validate Registration No.';
            DataClassification = CustomerContent;
        }
        field(31070; "Transaction Type CZL"; Code[10])
        {
            Caption = 'Transaction Type';
            TableRelation = "Transaction Type";
            DataClassification = CustomerContent;
        }
        field(31071; "Transaction Specification CZL"; Code[10])
        {
            Caption = 'Transaction Specification';
            TableRelation = "Transaction Specification";
            DataClassification = CustomerContent;
        }
        field(31072; "Transport Method CZL"; Code[10])
        {
            Caption = 'Transport Method';
            TableRelation = "Transport Method";
            DataClassification = CustomerContent;
        }
    }
    keys
    {
        key(Key11700; "Registration No. CZL")
        {
        }
    }

    var
        RegistrationLogMgtCZL: Codeunit "Registration Log Mgt. CZL";
        RegistrationNoMgtCZL: Codeunit "Registration No. Mgt. CZL";
        RegistrationNo: Text[20];

    procedure CheckOpenCustomerLedgerEntriesCZL()
    var
        CustLedgerEntry: Record "Cust. Ledger Entry";
        ChangeErr: Label ' cannot be changed';
    begin
        CustLedgerEntry.SetCurrentKey("Customer No.", Open);
        CustLedgerEntry.SetRange("Customer No.", "No.");
        CustLedgerEntry.SetRange(Open, true);
        if not CustLedgerEntry.IsEmpty() then
            FieldError("Customer Posting Group", ChangeErr);
    end;

    procedure GetLinkedVendorCZL(): Code[20]
    var
        ContactBusinessRelation: Record "Contact Business Relation";
    begin
        ContactBusinessRelation.SetCurrentKey("Link to Table", "No.");
        ContactBusinessRelation.SetRange("Link to Table", ContactBusinessRelation."Link to Table"::Customer);
        ContactBusinessRelation.SetRange("No.", "No.");
        if ContactBusinessRelation.FindFirst() then begin
            ContactBusinessRelation.SetRange("Contact No.", ContactBusinessRelation."Contact No.");
            ContactBusinessRelation.SetRange("Link to Table", ContactBusinessRelation."Link to Table"::Vendor);
            ContactBusinessRelation.SetRange("No.");
            if ContactBusinessRelation.FindFirst() then
                exit(ContactBusinessRelation."No.");
        end;
    end;

    internal procedure SaveRegistrationNoCZL()
    begin
        RegistrationNo := "Registration No. CZL"
    end;

    internal procedure GetSavedRegistrationNoCZL(): Text[20]
    begin
        exit(RegistrationNo);
    end;
}
