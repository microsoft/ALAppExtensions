#if not CLEAN19
report 11799 "ARES Update CZL"
{
    Caption = 'ARES Update';
    ProcessingOnly = true;
    UsageCategory = None;
    ObsoleteState = Pending;
    ObsoleteReason = 'The page Registration Log Details should be used instead';
    ObsoleteTag = '19.0';

    requestpage
    {

        layout
        {
            area(content)
            {
                group(General)
                {
                    Caption = 'General';
                    field(Type; AccountType)
                    {
                        ApplicationArea = Basic, Suite;
                        Caption = 'Type';
                        Editable = false;
                        ToolTip = 'Specifies type of update';
                    }
                    field(No; AccountNo)
                    {
                        ApplicationArea = Basic, Suite;
                        Caption = 'No.';
                        Editable = false;
                        ToolTip = 'Specifies the number of the vendor/customer';
                    }
                    field(RegNo; RegistrationNo)
                    {
                        ApplicationArea = Basic, Suite;
                        Caption = 'Registration No.';
                        Editable = false;
                        ToolTip = 'Specifies the company''s registration number';
                    }
                }
                group(Options)
                {
                    Caption = 'Options';
                    field("FieldUpdateMask[FieldType::All]"; FieldUpdateMask[FieldType::All])
                    {
                        ApplicationArea = Basic, Suite;
                        Caption = 'Update All';
                        ToolTip = 'Specifies if all fields will be updated from ares';

                        trigger OnValidate()
                        begin
                            ValidateUpdateField(FieldType::All);
                        end;
                    }
                    field("FieldUpdateMask[FieldType::Name]"; FieldUpdateMask[FieldType::Name])
                    {
                        ApplicationArea = Basic, Suite;
                        Caption = 'Update Name';
                        ToolTip = 'Specifies if the name will be updated from ares';

                        trigger OnValidate()
                        begin
                            ValidateUpdateField(FieldType::Name);
                        end;
                    }
                    field("FieldUpdateMask[FieldType::Address]"; FieldUpdateMask[FieldType::Address])
                    {
                        ApplicationArea = Basic, Suite;
                        Caption = 'Update Address';
                        ToolTip = 'Specifies if the address will be updated from ares';

                        trigger OnValidate()
                        begin
                            ValidateUpdateField(FieldType::Address);
                        end;
                    }
                    field("FieldUpdateMask[FieldType::City]"; FieldUpdateMask[FieldType::City])
                    {
                        ApplicationArea = Basic, Suite;
                        Caption = 'Update City';
                        ToolTip = 'Specifies if the city will be updated from ares';

                        trigger OnValidate()
                        begin
                            ValidateUpdateField(FieldType::City);
                        end;
                    }
                    field("FieldUpdateMask[FieldType::PostCode]"; FieldUpdateMask[FieldType::PostCode])
                    {
                        ApplicationArea = Basic, Suite;
                        Caption = 'Update Post Code';
                        ToolTip = 'Specifies if the post code will be updated from ares';

                        trigger OnValidate()
                        begin
                            ValidateUpdateField(FieldType::PostCode);
                        end;
                    }
                    field("FieldUpdateMask[FieldType::VATRegNo]"; FieldUpdateMask[FieldType::VATRegNo])
                    {
                        ApplicationArea = Basic, Suite;
                        Caption = 'Update VAT Registration No.';
                        ToolTip = 'Specifies if the vat registration No. will be updated from ares';

                        trigger OnValidate()
                        begin
                            ValidateUpdateField(FieldType::VATRegNo);
                        end;
                    }
                }
            }
        }
    }

    trigger OnPreReport()
    begin
        PopulateFieldsFromRegLog(GlobalRecordRef, GlobalRecordVariant, GlobalRegistrationLogCZL);
    end;

    var
        GlobalRegistrationLogCZL: Record "Registration Log CZL";
        DataTypeManagement: Codeunit "Data Type Management";
        GlobalRecordRef: RecordRef;
        GlobalRecordVariant: Variant;
        FieldUpdateMask: array[10] of Boolean;
        FieldType: Option ,Name,Address,City,PostCode,VATRegNo,All;
        AccountType: Enum "Reg. Log Account Type CZL";
        AccountNo: Code[20];
        RegistrationNo: Text[20];

    procedure InitializeReport(RecordVariant: Variant; RegistrationLogCZL: Record "Registration Log CZL")
    begin
        GlobalRecordVariant := RecordVariant;
        GlobalRegistrationLogCZL := RegistrationLogCZL;

        DataTypeManagement.GetRecordRef(GlobalRecordVariant, GlobalRecordRef);

        AccountType := RegistrationLogCZL."Account Type";
        AccountNo := RegistrationLogCZL."Account No.";
        RegistrationNo := RegistrationLogCZL."Registration No.";
    end;

    procedure GetRecord(var RecordRef: RecordRef)
    begin
        RecordRef := GlobalRecordRef;
    end;

    local procedure PopulateFieldsFromRegLog(var RecordRef: RecordRef; RecordVariant: Variant; RegistrationLogCZL: Record "Registration Log CZL")
    var
        Contact: Record Contact;
        FieldRef: FieldRef;
        SecondFieldRef: FieldRef;
    begin
        DataTypeManagement.GetRecordRef(RecordVariant, RecordRef);

        if FieldUpdateMask[FieldType::Name] then
            if DataTypeManagement.FindFieldByName(RecordRef, FieldRef, Contact.FieldName(Name)) then
                FieldRef.Validate(CopyStr(RegistrationLogCZL."Verified Name", 1, FieldRef.Length));

        if FieldUpdateMask[FieldType::Address] then
            if DataTypeManagement.FindFieldByName(RecordRef, FieldRef, Contact.FieldName(Address)) then begin
                FieldRef.Value(CopyStr(RegistrationLogCZL."Verified Address", 1, FieldRef.Length));
                if StrLen(RegistrationLogCZL."Verified Address") > FieldRef.Length then
                    if DataTypeManagement.FindFieldByName(RecordRef, SecondFieldRef, Contact.FieldName("Address 2")) then
                        SecondFieldRef.Value(CopyStr(RegistrationLogCZL."Verified Address", SecondFieldRef.Length + 1, SecondFieldRef.Length));
            end;

        if FieldUpdateMask[FieldType::City] then
            if DataTypeManagement.FindFieldByName(RecordRef, FieldRef, Contact.FieldName(City)) then
                FieldRef.Value(CopyStr(RegistrationLogCZL."Verified City", 1, FieldRef.Length));

        if FieldUpdateMask[FieldType::PostCode] then
            if DataTypeManagement.FindFieldByName(RecordRef, FieldRef, Contact.FieldName("Post Code")) then
                FieldRef.Value(CopyStr(RegistrationLogCZL."Verified Post Code", 1, FieldRef.Length));

        if FieldUpdateMask[FieldType::VATRegNo] then
            if DataTypeManagement.FindFieldByName(RecordRef, FieldRef, Contact.FieldName("VAT Registration No.")) then
                FieldRef.Validate(CopyStr(RegistrationLogCZL."Verified VAT Registration No.", 1, FieldRef.Length));
    end;

    local procedure ValidateUpdateField(CalledFieldType: Option)
    begin
        if CalledFieldType = FieldType::All then begin
            FieldUpdateMask[FieldType::Name] := FieldUpdateMask[FieldType::All];
            FieldUpdateMask[FieldType::Address] := FieldUpdateMask[FieldType::All];
            FieldUpdateMask[FieldType::City] := FieldUpdateMask[FieldType::All];
            FieldUpdateMask[FieldType::PostCode] := FieldUpdateMask[FieldType::All];
            FieldUpdateMask[FieldType::VATRegNo] := FieldUpdateMask[FieldType::All];
            exit;
        end;

        if not FieldUpdateMask[CalledFieldType] then
            FieldUpdateMask[FieldType::All] := false;
    end;
}
#endif