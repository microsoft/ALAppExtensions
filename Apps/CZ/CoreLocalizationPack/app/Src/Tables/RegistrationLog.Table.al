table 11756 "Registration Log CZL"
{
    Caption = 'Registration Log';

    fields
    {
        field(1; "Entry No."; Integer)
        {
            AutoIncrement = true;
            Caption = 'Entry No.';
            DataClassification = CustomerContent;
        }
        field(2; "Registration No."; Text[20])
        {
            Caption = 'Registration No.';
            NotBlank = true;
            DataClassification = CustomerContent;
        }
        field(3; "Account Type"; Option)
        {
            Caption = 'Account Type';
            OptionCaption = 'Customer,Vendor,Contact';
            OptionMembers = Customer,Vendor,Contact;
            DataClassification = CustomerContent;
        }
        field(4; "Account No."; Code[20])
        {
            Caption = 'Account No.';
            TableRelation = if ("Account Type" = const(Customer)) Customer else
            if ("Account Type" = const(Vendor)) Vendor else
            if ("Account Type" = const(Contact)) Contact;
            DataClassification = CustomerContent;
        }
        field(6; "User ID"; Code[50])
        {
            Caption = 'User ID';
            DataClassification = EndUserIdentifiableInformation;
            TableRelation = User."User Name";
        }
        field(10; Status; Option)
        {
            Caption = 'Status';
            OptionCaption = 'Not Verified,Valid,Invalid';
            OptionMembers = "Not Verified",Valid,Invalid;
            DataClassification = CustomerContent;
        }
        field(11; "Verified Name"; Text[150])
        {
            Caption = 'Verified Name';
            DataClassification = CustomerContent;
        }
        field(12; "Verified Address"; Text[150])
        {
            Caption = 'Verified Address';
            DataClassification = CustomerContent;
        }
        field(13; "Verified City"; Text[150])
        {
            Caption = 'Verified City';
            TableRelation = "Post Code".City;
            ValidateTableRelation = false;
            DataClassification = CustomerContent;
        }
        field(14; "Verified Post Code"; Code[20])
        {
            Caption = 'Verified Post Code';
            TableRelation = "Post Code";
            ValidateTableRelation = false;
            DataClassification = CustomerContent;
        }
        field(15; "Verified VAT Registration No."; Text[20])
        {
            Caption = 'Verified VAT Registration No.';
            DataClassification = CustomerContent;
        }
        field(20; "Verified Date"; DateTime)
        {
            Caption = 'Verified Date';
            DataClassification = CustomerContent;
        }
        field(25; "Verified Result"; Text[150])
        {
            Caption = 'Verified Result';
            DataClassification = CustomerContent;
        }
    }
    keys
    {
        key(Key1; "Entry No.")
        {
            Clustered = true;
        }
    }
    procedure InitRegLog(var RegistrationLogCZL: Record "Registration Log CZL"; AcountType: Option; AccountNo: Code[20]; RegNo: Text[20])
    begin
        RegistrationLogCZL.Init();
        RegistrationLogCZL."Account Type" := AcountType;
        RegistrationLogCZL."Account No." := AccountNo;
        RegistrationLogCZL."Registration No." := RegNo;
    end;

    procedure UpdateCard()
    var
        Customer: Record Customer;
        Vendor: Record Vendor;
        Contact: Record Contact;
        RegistrationLogMgtCZL: Codeunit "Registration Log Mgt. CZL";
        RecordRef: RecordRef;
    begin
        TestField(Status, Status::Valid);

        case "Account Type" of
            "Account Type"::Customer:
                begin
                    Customer.Get("Account No.");
                    RegistrationLogMgtCZL.RunARESUpdate(RecordRef, Customer, Rec);
                end;
            "Account Type"::Vendor:
                begin
                    Vendor.Get("Account No.");
                    RegistrationLogMgtCZL.RunARESUpdate(RecordRef, Vendor, Rec);
                end;
            "Account Type"::Contact:
                begin
                    Contact.Get("Account No.");
                    RegistrationLogMgtCZL.RunARESUpdate(RecordRef, Contact, Rec);
                end;
        end;

        RecordRef.Modify(true);
    end;
}
