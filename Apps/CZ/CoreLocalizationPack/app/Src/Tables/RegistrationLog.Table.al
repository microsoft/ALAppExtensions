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
        field(3; "Account Type"; Enum "Reg. Log Account Type CZL")
        {
            Caption = 'Account Type';
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
        field(30; "Detail Status"; Enum "Reg. Log Detail Status CZL")
        {
            Caption = 'Detail Status';
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

    var
        CustomerUpdatedMsg: Label 'The customer has been updated.';
        VendorUpdatedMsg: Label 'The vendor has been updated.';
        ContactUpdatedMsg: Label 'The contact has been updated.';

    procedure InitRegLog(var RegistrationLogCZL: Record "Registration Log CZL"; AcountType: Enum "Reg. Log Account Type CZL"; AccountNo: Code[20]; RegNo: Text[20])
    begin
        RegistrationLogCZL.Init();
        RegistrationLogCZL."Account Type" := AcountType;
        RegistrationLogCZL."Account No." := AccountNo;
        RegistrationLogCZL."Registration No." := RegNo;
    end;

#if not CLEAN19
#pragma warning disable AL0432
    [Obsolete('The ARES Update report is discontinued, use the Registration Log Details page instead.', '19.0')]
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
#pragma warning restore AL0432
#endif
    procedure OpenModifyDetails()
    var
        Customer: Record Customer;
        Vendor: Record Vendor;
        Contact: Record Contact;
        CustContUpdate: Codeunit "CustCont-Update";
        VendContUpdate: Codeunit "VendCont-Update";
        CustVendBankUpdate: Codeunit "CustVendBank-Update";
        RecordRef: RecordRef;
    begin
        GetAccountRecordRef(RecordRef);
        if OpenDetailForRecRef(RecordRef) then begin
            RecordRef.Modify();
            case RecordRef.Number of
                Database::Customer:
                    begin
                        RecordRef.SetTable(Customer);
                        CustContUpdate.OnModify(Customer);
                    end;
                Database::Vendor:
                    begin
                        RecordRef.SetTable(Vendor);
                        VendContUpdate.OnModify(Vendor);
                    end;
                Database::Contact:
                    begin
                        RecordRef.SetTable(Contact);
                        CustVendBankUpdate.Run(Contact);
                    end;
            end;
        end;
    end;

    procedure OpenDetailForRecRef(var RecordRef: RecordRef): Boolean
    var
        RegistrationLogDetail: Record "Registration Log Detail CZL";
    begin
        if GuiAllowed() and ("Detail Status" <> "Detail Status"::"Not Verified") then begin
            RegistrationLogDetail.SetRange("Log Entry No.", "Entry No.");
            Page.RunModal(Page::"Registration Log Details CZL", RegistrationLogDetail);
            exit(ApplyDetailChanges(RecordRef));
        end;
    end;

    local procedure ApplyDetailChanges(var RecordRef: RecordRef) Result: Boolean
    var
        RegistrationLogDetail: Record "Registration Log Detail CZL";
        DummyCustomer: Record Customer;
        VATRegLogSuppression: Codeunit "VAT Reg. Log Suppression CZL";
    begin
        RegistrationLogDetail.SetRange("Log Entry No.", "Entry No.");
        RegistrationLogDetail.SetRange(Status, RegistrationLogDetail.Status::Accepted);
        Result := RegistrationLogDetail.FindSet();
        if Result then begin
            repeat
                case RegistrationLogDetail."Field Name" of
                    RegistrationLogDetail."Field Name"::Name:
                        ValidateField(RecordRef, DummyCustomer.FieldName(Name), RegistrationLogDetail.Response);
                    RegistrationLogDetail."Field Name"::Address:
                        ValidateField(RecordRef, DummyCustomer.FieldName(Address), RegistrationLogDetail.Response);
                    RegistrationLogDetail."Field Name"::City:
                        ValidateField(RecordRef, DummyCustomer.FieldName(City), RegistrationLogDetail.Response);
                    RegistrationLogDetail."Field Name"::"Post Code":
                        ValidateField(RecordRef, DummyCustomer.FieldName("Post Code"), RegistrationLogDetail.Response);
                    RegistrationLogDetail."Field Name"::"VAT Registration No.":
                        begin
                            BindSubscription(VATRegLogSuppression);
                            ValidateField(RecordRef, DummyCustomer.FieldName("VAT Registration No."), RegistrationLogDetail.Response);
                            UnbindSubscription(VATRegLogSuppression)
                        end;
                end;
            until RegistrationLogDetail.Next() = 0;
            RegistrationLogDetail.ModifyAll(Status, RegistrationLogDetail.Status::Applied);
            ShowDetailUpdatedMessage(RecordRef.Number());
        end;
    end;

    local procedure ValidateField(var RecordRef: RecordRef; FieldName: Text; Value: Text)
    var
        ConfigValidateManagement: Codeunit "Config. Validate Management";
        DataTypeManagement: Codeunit "Data Type Management";
        FieldRef: FieldRef;
    begin
        if DataTypeManagement.FindFieldByName(RecordRef, FieldRef, FieldName) then
            ConfigValidateManagement.EvaluateValueWithValidate(FieldRef, CopyStr(Value, 1, FieldRef.Length()), false);
    end;

    local procedure ShowDetailUpdatedMessage(TableID: Integer);
    begin
        if GuiAllowed() then
            case TableID of
                Database::Customer:
                    Message(CustomerUpdatedMsg);
                Database::Vendor:
                    Message(VendorUpdatedMsg);
                Database::Contact:
                    Message(ContactUpdatedMsg);
            end;
    end;

    procedure GetAccountRecordRef(var RecordRef: RecordRef): Boolean
    var
        Customer: Record Customer;
        Vendor: Record Vendor;
        Contact: Record Contact;
    begin
        Clear(RecordRef);
        case "Account Type" of
            "Account Type"::Customer:
                if Customer.Get("Account No.") then
                    RecordRef.GetTable(Customer);
            "Account Type"::Vendor:
                if Vendor.Get("Account No.") then
                    RecordRef.GetTable(Vendor);
            "Account Type"::Contact:
                if Contact.Get("Account No.") then
                    RecordRef.GetTable(Contact);
        end;

        exit(RecordRef.Number <> 0);
    end;

    local procedure GetFieldValue(var RecordRef: RecordRef; FieldName: Text) Result: Text;
    var
        DataTypeManagement: Codeunit "Data Type Management";
        FieldRef: FieldRef;
    begin
        if DataTypeManagement.FindFieldByName(RecordRef, FieldRef, FieldName) then
            Result := FieldRef.Value();
    end;

    procedure LogDetails(): Boolean
    var
        DummyCustomer: Record Customer;
        RecordRef: RecordRef;
        TotalCount: Integer;
        ValidCount: Integer;
    begin
        GetAccountRecordRef(RecordRef);

        LogDetail(
          TotalCount, ValidCount, Enum::"Reg. Log Detail Field CZL"::Name, GetFieldValue(RecordRef, DummyCustomer.FieldName(Name)), "Verified Name");
        LogDetail(
          TotalCount, ValidCount, Enum::"Reg. Log Detail Field CZL"::Address, GetFieldValue(RecordRef, DummyCustomer.FieldName(Address)), "Verified Address");
        LogDetail(
          TotalCount, ValidCount, Enum::"Reg. Log Detail Field CZL"::City, GetFieldValue(RecordRef, DummyCustomer.FieldName(City)), "Verified City");
        LogDetail(
          TotalCount, ValidCount, Enum::"Reg. Log Detail Field CZL"::"Post Code", GetFieldValue(RecordRef, DummyCustomer.FieldName("Post Code")), "Verified Post Code");
        LogDetail(
          TotalCount, ValidCount, Enum::"Reg. Log Detail Field CZL"::"VAT Registration No.", GetFieldValue(RecordRef, DummyCustomer.FieldName("VAT Registration No.")), "Verified VAT Registration No.");

        if TotalCount > 0 then
            if TotalCount = ValidCount then
                "Detail Status" := "Detail Status"::Valid
            else
                if ValidCount > 0 then
                    "Detail Status" := "Detail Status"::"Partially Valid"
                else
                    "Detail Status" := "Detail Status"::"Not Valid";

        exit(TotalCount > 0);
    end;

    local procedure LogDetail(var TotalCount: Integer; var ValidCount: Integer; FieldName: Enum "Reg. Log Detail Field CZL"; CurrentValue: Text; ResponseValue: Text)
    var
        RegistrationLogDetail: Record "Registration Log Detail CZL";
    begin
        if ResponseValue = '' then
            exit;

        InitRegistrationLogDetailFromRec(RegistrationLogDetail, FieldName, CurrentValue);
        RegistrationLogDetail.Response := CopyStr(ResponseValue, 1, MaxStrLen(RegistrationLogDetail.Response));

        if (RegistrationLogDetail."Current Value" = RegistrationLogDetail.Response) and
           (RegistrationLogDetail.Response <> '')
        then
            RegistrationLogDetail.Status := RegistrationLogDetail.Status::Valid;
        RegistrationLogDetail.Insert();

        TotalCount += 1;
        if RegistrationLogDetail.Status = RegistrationLogDetail.Status::Valid then
            ValidCount += 1;
    end;

    local procedure InitRegistrationLogDetailFromRec(var RegistrationLogDetail: Record "Registration Log Detail CZL"; FieldName: Enum "Reg. Log Detail Field CZL"; CurrentValue: Text)
    begin
        RegistrationLogDetail.Init();
        RegistrationLogDetail."Log Entry No." := "Entry No.";
        RegistrationLogDetail."Account Type" := "Account Type";
        RegistrationLogDetail."Account No." := "Account No.";
        RegistrationLogDetail.Status := RegistrationLogDetail.Status::"Not Valid";
        RegistrationLogDetail."Field Name" := FieldName;
        RegistrationLogDetail."Current Value" := CopyStr(CurrentValue, 1, MaxStrLen(RegistrationLogDetail."Current Value"));
    end;
}
