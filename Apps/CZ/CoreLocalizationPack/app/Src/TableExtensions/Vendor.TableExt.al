#pragma warning disable AA0232
tableextension 11702 "Vendor CZL" extends Vendor
{
    fields
    {
        modify("Registration Number")
        {
            trigger OnAfterValidate()
            var
                RegistrationLogCZL: Record "Registration Log CZL";
                RegNoServiceConfigCZL: Record "Reg. No. Service Config CZL";
                ResultRecordRef: RecordRef;
                LogNotVerified: Boolean;
            begin
                if not RegistrationNoMgtCZL.CheckRegistrationNo(GetRegistrationNoTrimmedCZL(), "No.", Database::Vendor) then
                    exit;

                LogNotVerified := true;
                if "Registration Number" <> xRec."Registration Number" then
                    if RegNoServiceConfigCZL.RegNoSrvIsEnabled() then begin
                        LogNotVerified := false;
                        RegistrationLogMgtCZL.ValidateRegNoWithARES(ResultRecordRef, Rec, "No.", RegistrationLogCZL."Account Type"::Vendor);
                        ResultRecordRef.SetTable(Rec);
                    end;

                if LogNotVerified then
                    RegistrationLogMgtCZL.LogVendor(Rec);
            end;
        }
        field(11770; "Registration No. CZL"; Text[20])
        {
            Caption = 'Registration No.';
            DataClassification = CustomerContent;
#if not CLEAN23
            ObsoleteState = Pending;
            ObsoleteTag = '23.0';
#else
            ObsoleteState = Removed;
            ObsoleteTag = '26.0';
#endif
            ObsoleteReason = 'Replaced by standard "Registration Number" field.';
#if not CLEAN23

            trigger OnValidate()
            var
                RegistrationLogCZL: Record "Registration Log CZL";
                RegNoServiceConfigCZL: Record "Reg. No. Service Config CZL";
                ResultRecordRef: RecordRef;
                LogNotVerified: Boolean;
            begin
                if not RegistrationNoMgtCZL.CheckRegistrationNo("Registration No. CZL", "No.", Database::Vendor) then
                    exit;

                LogNotVerified := true;
                if "Registration No. CZL" <> xRec."Registration No. CZL" then
                    if RegNoServiceConfigCZL.RegNoSrvIsEnabled() then begin
                        LogNotVerified := false;
                        RegistrationLogMgtCZL.ValidateRegNoWithARES(ResultRecordRef, Rec, "No.", RegistrationLogCZL."Account Type"::Vendor);
                        ResultRecordRef.SetTable(Rec);
                    end;

                if LogNotVerified then
                    RegistrationLogMgtCZL.LogVendor(Rec);
            end;
#endif
        }
        field(11771; "Tax Registration No. CZL"; Text[20])
        {
            Caption = 'Tax Registration No.';
            DataClassification = CustomerContent;

            trigger OnValidate()
            begin
                RegistrationNoMgtCZL.CheckTaxRegistrationNo("Tax Registration No. CZL", "No.", Database::Vendor);
            end;
        }
        field(11772; "Validate Registration No. CZL"; Boolean)
        {
            Caption = 'Validate Registration No.';
            DataClassification = CustomerContent;
        }
        field(11767; "Last Unreliab. Check Date CZL"; Date)
        {
            CalcFormula = max("Unreliable Payer Entry CZL"."Check Date" where("VAT Registration No." = field("VAT Registration No."),
                                                                            "Entry Type" = CONST(Payer)));
            Caption = 'Last Unreliability Check Date';
            Editable = false;
            FieldClass = FlowField;
        }
        field(11768; "VAT Unreliable Payer CZL"; Option)
        {
            CalcFormula = lookup("Unreliable Payer Entry CZL"."Unreliable Payer" where("VAT Registration No." = field("VAT Registration No."),
                                                                                      "Entry Type" = const(Payer),
                                                                                      "Check Date" = field("Last Unreliab. Check Date CZL")));
            Caption = 'VAT Unreliable Payer';
            Editable = false;
            FieldClass = FlowField;
            OptionCaption = ' ,NO,YES,NOTFOUND';
            OptionMembers = " ",NO,YES,NOTFOUND;
        }
        field(11769; "Disable Unreliab. Check CZL"; Boolean)
        {
            Caption = 'Disable Unreliability Check';
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
#if not CLEAN23
    keys
    {
        key(Key11700; "Registration No. CZL")
        {
            ObsoleteState = Pending;
            ObsoleteTag = '23.0';
            ObsoleteReason = 'Replaced by standard "Registration Number" field.';
        }
    }
#endif

    var
        UnrelPayerServiceSetupCZL: Record "Unrel. Payer Service Setup CZL";
        UnreliablePayerMgtCZL: Codeunit "Unreliable Payer Mgt. CZL";
        RegistrationLogMgtCZL: Codeunit "Registration Log Mgt. CZL";
        RegistrationNoMgtCZL: Codeunit "Registration No. Mgt. CZL";
        RegistrationNo: Text[20];

    procedure ImportUnrPayerStatusCZL()
    begin
        UnreliablePayerMgtCZL.ImportUnrPayerStatusForVendor(Rec);
    end;

    procedure IsUnreliablePayerCheckPossibleCZL(): Boolean
    begin
        if "Disable Unreliab. Check CZL" then
            exit(false);
        if not UnrelPayerServiceSetupCZL.Get() then
            exit(false);
        if not UnrelPayerServiceSetupCZL.Enabled then
            exit(false);
        exit(UnreliablePayerMgtCZL.IsVATRegNoExportPossible("VAT Registration No.", "Country/Region Code"));
    end;

    procedure GetUnreliablePayerStatusCZL(): Integer
    var
        UnreliablePayerEntryCZL: Record "Unreliable Payer Entry CZL";
    begin
        UnreliablePayerEntryCZL.SetCurrentKey("VAT Registration No.");
        UnreliablePayerEntryCZL.SetRange("VAT Registration No.", "VAT Registration No.");
        UnreliablePayerEntryCZL.SetRange("Entry Type", UnreliablePayerEntryCZL."Entry Type"::Payer);
        if not UnreliablePayerEntryCZL.FindLast() then
            exit(UnreliablePayerEntryCZL."Unreliable Payer"::NOTFOUND);
        exit(UnreliablePayerEntryCZL."Unreliable Payer");
    end;

    procedure ShowUnreliableEntriesCZL()
    var
        UnreliablePayerEntryCZL: Record "Unreliable Payer Entry CZL";
        UnreliablePayerEntriesCZL: Page "Unreliable Payer Entries CZL";
        UnreliablePayerEntriesCZLCaptionTok: Label '%1 - %2', Comment = '%1 = Vendor No., %2 = Page caption', Locked = true;
    begin
        UnreliablePayerEntryCZL.SetCurrentKey("VAT Registration No.", "Vendor No.", "Check Date");
        UnreliablePayerEntryCZL.FilterGroup(2);
        UnreliablePayerEntryCZL.SetRange("VAT Registration No.", Rec."VAT Registration No.");
        UnreliablePayerEntryCZL.FilterGroup(0);
        UnreliablePayerEntriesCZL.SetTableView(UnreliablePayerEntryCZL);
        UnreliablePayerEntriesCZL.SetUnreliablePayerNoCZL(Rec."No.");
        UnreliablePayerEntriesCZL.Caption := StrSubstNo(UnreliablePayerEntriesCZLCaptionTok, Rec."No.", UnreliablePayerEntriesCZL.Caption);
        UnreliablePayerEntriesCZL.RunModal();
    end;

    procedure CheckVendorLedgerOpenEntriesCZL()
    var
        VendorLedgerEntry: Record "Vendor Ledger Entry";
        ChangeErr: Label ' cannot be changed';
    begin
        VendorLedgerEntry.SetCurrentKey("Vendor No.", Open);
        VendorLedgerEntry.SetRange("Vendor No.", "No.");
        VendorLedgerEntry.SetRange(Open, true);
        if not VendorLedgerEntry.IsEmpty() then
            FieldError("Vendor Posting Group", ChangeErr);
    end;

    procedure GetLinkedCustomerCZL(): Code[20]
    var
        ContactBusinessRelation: Record "Contact Business Relation";
    begin
        ContactBusinessRelation.SetCurrentKey("Link to Table", "No.");
        ContactBusinessRelation.SetRange("Link to Table", ContactBusinessRelation."Link to Table"::Vendor);
        ContactBusinessRelation.SetRange("No.", "No.");
        if ContactBusinessRelation.FindFirst() then begin
            ContactBusinessRelation.SetRange("Contact No.", ContactBusinessRelation."Contact No.");
            ContactBusinessRelation.SetRange("Link to Table", ContactBusinessRelation."Link to Table"::Customer);
            ContactBusinessRelation.SetRange("No.");
            if ContactBusinessRelation.FindFirst() then
                exit(ContactBusinessRelation."No.");
        end;
    end;

    internal procedure SaveRegistrationNoCZL()
    begin
        RegistrationNo := GetRegistrationNoTrimmedCZL();
    end;

    internal procedure GetSavedRegistrationNoCZL(): Text[20]
    begin
        exit(RegistrationNo);
    end;

    procedure GetRegistrationNoTrimmedCZL(): Text[20]
    begin
        exit(CopyStr("Registration Number", 1, 20));
    end;
}
