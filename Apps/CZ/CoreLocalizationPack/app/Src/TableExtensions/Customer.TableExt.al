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
            begin
                if not RegistrationNoMgtCZL.CheckRegistrationNo("Registration No. CZL", "No.", Database::Customer) then
                    exit;
                if "Registration No. CZL" <> xRec."Registration No. CZL" then begin
                    RegistrationLogMgtCZL.LogCustomer(Rec);
                    if RegNoServiceConfigCZL.RegNoSrvIsEnabled() then begin
                        RegistrationLogMgtCZL.ValidateRegNoWithARES(ResultRecordRef, Rec, "No.", RegistrationLogCZL."Account Type"::Customer);
                        ResultRecordRef.SetTable(Rec);
                    end;
                end;
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
    }
    var
        RegistrationLogMgtCZL: Codeunit "Registration Log Mgt. CZL";
        RegistrationNoMgtCZL: Codeunit "Registration No. Mgt. CZL";

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
        ContBusRel: Record "Contact Business Relation";
    begin
        ContBusRel.SetCurrentKey("Link to Table", "No.");
        ContBusRel.SetRange("Link to Table", ContBusRel."Link to Table"::Customer);
        ContBusRel.SetRange("No.", "No.");
        if ContBusRel.FindFirst() then begin
            ContBusRel.SetRange("Contact No.", ContBusRel."Contact No.");
            ContBusRel.SetRange("Link to Table", ContBusRel."Link to Table"::Vendor);
            ContBusRel.SetRange("No.");
            if ContBusRel.FindFirst() then
                exit(ContBusRel."No.");
        end;
    end;
}
