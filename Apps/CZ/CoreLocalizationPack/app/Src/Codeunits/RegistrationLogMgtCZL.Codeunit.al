// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------
namespace Microsoft.Finance.Registration;

using Microsoft.CRM.Contact;
using Microsoft.Purchases.Vendor;
using Microsoft.Sales.Customer;
using Microsoft.Utilities;
using System.Reflection;

codeunit 11755 "Registration Log Mgt. CZL"
{
    var
        ServiceConditionsURLTok: Label 'http://wwwinfo.mfcr.cz/ares/ares_podminky.html.cz', Locked = true;
        ValidRegNoMsg: Label 'The registration number is valid.';
        InvalidRegNoMsg: Label 'We didn''t find a match for this number. Verify that you entered the correct number.';
        NotVerifiedRegNoMsg: Label 'We couldn''t verify the registration number. Try again later.';
        DetailNotVerifiedMsg: Label 'Registration number is valid.\No details information was provided by ARES service.';
        DescriptionLbl: Label 'Registration No. Validation Service Setup';

    procedure LogCustomer(Customer: Record Customer)
    begin
        InsertLogRegistration(Customer.GetRegistrationNoTrimmedCZL(), Enum::"Reg. Log Account Type CZL"::Customer, Customer."No.");
    end;

    procedure LogVendor(Vendor: Record Vendor)
    begin
        InsertLogRegistration(Vendor.GetRegistrationNoTrimmedCZL(), Enum::"Reg. Log Account Type CZL"::Vendor, Vendor."No.");
    end;

    procedure LogContact(Contact: Record Contact)
    begin
        InsertLogRegistration(Contact.GetRegistrationNoTrimmedCZL(), Enum::"Reg. Log Account Type CZL"::Contact, Contact."No.");
    end;

    local procedure InsertLogRegistration(RegNo: Text[20]; AccType: Enum "Reg. Log Account Type CZL"; AccNo: Code[20])
    var
        NewRegistrationLogCZL: Record "Registration Log CZL";
    begin
        NewRegistrationLogCZL.Init();
        NewRegistrationLogCZL."Registration No." := RegNo;
        NewRegistrationLogCZL."Account Type" := AccType;
        NewRegistrationLogCZL."Account No." := AccNo;
        NewRegistrationLogCZL."User ID" := CopyStr(UserId(), 1, MaxStrLen(NewRegistrationLogCZL."User ID"));
        NewRegistrationLogCZL.Insert(true);
    end;

    procedure LogError(var NewRegistrationLogCZL: Record "Registration Log CZL"; JsonObject: JsonObject)
    var
        ErrorDescription: Text;
        ErrorDescriptionKeyTok: Label 'popis', Locked = true;
    begin
        NewRegistrationLogCZL."Entry No." := 0;
        NewRegistrationLogCZL."Verified Date" := CurrentDateTime;
        NewRegistrationLogCZL.Status := NewRegistrationLogCZL.Status::Invalid;
        NewRegistrationLogCZL."User ID" := CopyStr(UserId(), 1, MaxStrLen(NewRegistrationLogCZL."User ID"));
        if GetValue(JsonObject, ErrorDescriptionKeyTok, ErrorDescription) then
            NewRegistrationLogCZL."Verified Result" := CopyStr(ErrorDescription, 1, MaxStrLen(NewRegistrationLogCZL."Verified Result"));
        NewRegistrationLogCZL."Verified Name" := '';
        NewRegistrationLogCZL."Verified Address" := '';
        NewRegistrationLogCZL."Verified City" := '';
        NewRegistrationLogCZL."Verified Post Code" := '';
        NewRegistrationLogCZL."Verified Country/Region Code" := '';
        NewRegistrationLogCZL."Verified VAT Registration No." := '';
        NewRegistrationLogCZL.Insert(true);
    end;

    procedure LogVerification(var NewRegistrationLogCZL: Record "Registration Log CZL"; ResponseObject: JsonObject)
    var
        AddressObject: JsonObject;
        ResourceStatusObject: JsonObject;
        Address: array[10] of Text;
        AddressText: Text;
        Value: Text;
        VATSourceStatus: Text;
        CZCodeTok: Label 'CZ', Locked = true;
        VATRegistrationNoKeyTok: Label 'dic', Locked = true;
        GroupVATRegistrationNoKeyTok: Label 'dicSkDph', Locked = true;
        NameKeyTok: Label 'obchodniJmeno', Locked = true;
        AddressKeyTok: Label 'sidlo', Locked = true;
        CityKeyTok: Label 'nazevObce', Locked = true;
        PostCodeKeyTok: Label 'psc', Locked = true;
        StreetKeyTok: Label 'nazevUlice', Locked = true;
        QuarterKeyTok: Label 'nazevCastiObce', Locked = true;
        HouseNoKeyTok: Label 'cisloDomovni', Locked = true;
        OrientationNoKeyTok: Label 'cisloOrientacni', Locked = true;
        OrientationNoLetterKeyTok: Label 'cisloOrientacniPismeno', Locked = true;
        AddressTextKeyTok: Label 'textovaAdresa', Locked = true;
        RegistrationListKeyTok: Label 'seznamRegistraci', Locked = true;
        VATSourceStatusKeyTok: Label 'stavZdrojeDph', Locked = true;
        ActiveSourceKeyTok: Label 'AKTIVNI', Locked = true;
        NAKeyTok: Label 'N/A', Locked = true;
        CountryCodeKeyTok: Label 'kodStatu', Locked = true;
    begin
        NewRegistrationLogCZL."Entry No." := 0;
        NewRegistrationLogCZL.Status := NewRegistrationLogCZL.Status::Valid;
        NewRegistrationLogCZL."Verified Date" := CurrentDateTime;
        NewRegistrationLogCZL."User ID" := CopyStr(UserId(), 1, MaxStrLen(NewRegistrationLogCZL."User ID"));

        // VAT Source Status
        if GetValue(ResponseObject, RegistrationListKeyTok, ResourceStatusObject) then
            GetValue(ResourceStatusObject, VATSourceStatusKeyTok, VATSourceStatus);

        // VAT Registration No.
        if VATSourceStatus = ActiveSourceKeyTok then
            if GetValue(ResponseObject, VATRegistrationNoKeyTok, Value) then begin
                if CopyStr(Value, 1, 2) <> CZCodeTok then
                    Value := CZCodeTok + Value;
                NewRegistrationLogCZL."Verified VAT Registration No." :=
                    CopyStr(Value, 1, MaxStrLen(NewRegistrationLogCZL."Verified VAT Registration No."))
            end;

        // Group VAT Registration No.
        if GetValue(ResponseObject, GroupVATRegistrationNoKeyTok, Value) then
            if Value <> NAKeyTok then
                NewRegistrationLogCZL."Verified VAT Registration No." :=
                    CopyStr(Value, 1, MaxStrLen(NewRegistrationLogCZL."Verified VAT Registration No."));

        // Name
        if GetValue(ResponseObject, NameKeyTok, Value) then
            NewRegistrationLogCZL."Verified Name" :=
                CopyStr(Value, 1, MaxStrLen(NewRegistrationLogCZL."Verified Name"));

        // Address information
        if GetValue(ResponseObject, AddressKeyTok, AddressObject) then begin
            // Country Code
            if GetValue(AddressObject, CountryCodeKeyTok, Value) then
                NewRegistrationLogCZL."Verified Country/Region Code" :=
                    CopyStr(Value, 1, MaxStrLen(NewRegistrationLogCZL."Verified Country/Region Code"));

            // City
            if GetValue(AddressObject, CityKeyTok, Value) then
                NewRegistrationLogCZL."Verified City" :=
                    CopyStr(Value, 1, MaxStrLen(NewRegistrationLogCZL."Verified City"));

            // Post Code
            if GetValue(AddressObject, PostCodeKeyTok, Value) then
                NewRegistrationLogCZL."Verified Post Code" :=
                    FormatPostCode(CopyStr(Value, 1, MaxStrLen(NewRegistrationLogCZL."Verified Post Code")));

            if GetValue(AddressObject, StreetKeyTok, Value) then
                Address[1] := Value;  // Street
            if GetValue(AddressObject, QuarterKeyTok, Value) then
                Address[2] := Value;  // Quarter
            if GetValue(AddressObject, HouseNoKeyTok, Value) then
                Address[3] := Value;  // House No.
            if GetValue(AddressObject, OrientationNoKeyTok, Value) then
                Address[4] := Value;  // Orientation No.
            if GetValue(AddressObject, OrientationNoLetterKeyTok, Value) then
                Address[5] := Value;  // Orientation No. Letter
            if GetValue(AddressObject, AddressTextKeyTok, Value) then
                AddressText := Value;  // Address Text
        end;

        NewRegistrationLogCZL."Verified Address" := CopyStr(FormatAddress(Address), 1, MaxStrLen(NewRegistrationLogCZL."Verified Address"));
        if NewRegistrationLogCZL."Verified Address" = '' then
            NewRegistrationLogCZL."Verified Address" := CopyStr(AddressText, 1, MaxStrLen(NewRegistrationLogCZL."Verified Address"));
        NewRegistrationLogCZL.Insert(true);

        if NewRegistrationLogCZL.LogDetails() then
            NewRegistrationLogCZL.Modify();
    end;

    local procedure FormatPostCode(PostCode: Text): Code[20]
    var
        RegNoServiceConfig: Record "Reg. No. Service Config CZL";
        PostCodeTok: Label '%1 %2', Locked = true;
    begin
        RegNoServiceConfig.Get();
        if ((StrLen(PostCode) <> 5) and not RegNoServiceConfig."Post Code without Space") or
           ((StrLen(PostCode) = 5) and RegNoServiceConfig."Post Code without Space")
        then
            exit(CopyStr(PostCode, 1, 20));
        if not RegNoServiceConfig."Post Code without Space" then
            exit(StrSubstNo(PostCodeTok, CopyStr(PostCode, 1, 3), CopyStr(PostCode, 4, 2)));
        exit(CopyStr(DelChr(PostCode, '=', ' '), 1, 20));
    end;

    local procedure FormatAddress(Address: array[10] of Text): Text
    var
        DummyRegistrationLog: Record "Registration Log CZL";
        FormatedAddress: Text;
        TwoPlaceholdersTok: Label '%1 %2', Locked = true;
        ThreePlaceholdersTok: Label '%1 %2/%3', Locked = true;
    begin
        FormatedAddress := Address[1];
        if FormatedAddress = '' then
            FormatedAddress := Address[2];
        if (Address[4] <> '') and (Address[5] <> '') then
            Address[4] += Address[5];
        if (Address[3] <> '') and (Address[4] <> '') then
            FormatedAddress := CopyStr(StrSubstNo(ThreePlaceholdersTok, FormatedAddress, Address[3], Address[4]), 1, MaxStrLen(DummyRegistrationLog."Verified Address"));
        if (Address[3] <> '') xor (Address[4] <> '') then begin
            if Address[3] = '' then
                Address[3] := Address[4];
            FormatedAddress := CopyStr(StrSubstNo(TwoPlaceholdersTok, FormatedAddress, Address[3]), 1, MaxStrLen(DummyRegistrationLog."Verified Address"));
        end;
        exit(DelChr(FormatedAddress, '<>', ' '));
    end;

    local procedure CheckAndLogUnloggedRegistrationNumbers(var RegistrationLogCZL: Record "Registration Log CZL"; AccountType: Enum "Reg. Log Account Type CZL"; AccountNo: Code[20])
    begin
        RegistrationLogCZL.SetRange("Account Type", AccountType);
        RegistrationLogCZL.SetRange("Account No.", AccountNo);
        if RegistrationLogCZL.IsEmpty() then
            LogUnloggedRegistrationNumbers(AccountType, AccountNo);
    end;

    local procedure LogUnloggedRegistrationNumbers(AccountType: Enum "Reg. Log Account Type CZL"; AccountNo: Code[20])
    var
        NewRegistrationLogCZL: Record "Registration Log CZL";
        Customer: Record Customer;
        Vendor: Record Vendor;
        Contact: Record Contact;
    begin
        case AccountType of
            AccountType::Customer:
                if Customer.Get(AccountNo) then begin
                    NewRegistrationLogCZL.SetRange("Registration No.", Customer."Registration Number");
                    if NewRegistrationLogCZL.IsEmpty() then
                        LogCustomer(Customer);
                end;
            AccountType::Vendor:
                if Vendor.Get(AccountNo) then begin
                    NewRegistrationLogCZL.SetRange("Registration No.", Vendor."Registration Number");
                    if NewRegistrationLogCZL.IsEmpty() then
                        LogVendor(Vendor);
                end;
            AccountType::Contact:
                if Contact.Get(AccountNo) then begin
                    NewRegistrationLogCZL.SetRange("Registration No.", Contact."Registration Number");
                    if NewRegistrationLogCZL.IsEmpty() then
                        LogContact(Contact);
                end;
        end;
    end;

    procedure DeleteCustomerLog(Customer: Record Customer)
    begin
        DeleteLogRegistration(Enum::"Reg. Log Account Type CZL"::Customer, Customer."No.");
    end;

    procedure DeleteVendorLog(Vendor: Record Vendor)
    begin
        DeleteLogRegistration(Enum::"Reg. Log Account Type CZL"::Vendor, Vendor."No.");
    end;

    procedure DeleteContactLog(Contact: Record Contact)
    begin
        DeleteLogRegistration(Enum::"Reg. Log Account Type CZL"::Contact, Contact."No.");
    end;

    local procedure DeleteLogRegistration(AccountType: Enum "Reg. Log Account Type CZL"; AccountNo: Code[20])
    var
        DeletedRegistrationLogCZL: Record "Registration Log CZL";
    begin
        DeletedRegistrationLogCZL.SetRange(DeletedRegistrationLogCZL."Account Type", AccountType);
        DeletedRegistrationLogCZL.SetRange(DeletedRegistrationLogCZL."Account No.", AccountNo);
        DeletedRegistrationLogCZL.DeleteAll();
    end;

    procedure AssistEditCustomerRegNo(Customer: Record Customer)
    begin
        AssistEditRegNo(Enum::"Reg. Log Account Type CZL"::Customer, Customer."No.");
    end;

    procedure AssistEditVendorRegNo(Vendor: Record Vendor)
    begin
        AssistEditRegNo(Enum::"Reg. Log Account Type CZL"::Vendor, Vendor."No.");
    end;

    procedure AssistEditContactRegNo(Contact: Record Contact)
    begin
        AssistEditRegNo(Enum::"Reg. Log Account Type CZL"::Contact, Contact."No.");
    end;

    local procedure AssistEditRegNo(AccountType: Enum "Reg. Log Account Type CZL"; AccountNo: Code[20])
    var
        AssistedRegistrationLogCZL: Record "Registration Log CZL";
    begin
        CheckAndLogUnloggedRegistrationNumbers(AssistedRegistrationLogCZL, AccountType, AccountNo);
        Commit();
        Page.RunModal(Page::"Registration Log CZL", AssistedRegistrationLogCZL);
    end;

    procedure InitServiceSetup()
    var
        RegNoServiceConfigCZL: Record "Reg. No. Service Config CZL";
        RegLookupExtDataCZL: Codeunit "Reg. Lookup Ext. Data CZL";
    begin
        if not RegNoServiceConfigCZL.FindFirst() then begin
            RegNoServiceConfigCZL.Init();
            RegNoServiceConfigCZL.Insert();
        end;
        RegNoServiceConfigCZL."Service Endpoint" := RegLookupExtDataCZL.GetRegistrationNoValidationWebServiceURL();
        RegNoServiceConfigCZL.Enabled := false;
        RegNoServiceConfigCZL.Modify();
    end;

    procedure SetupService()
    var
        RegNoServiceConfigCZL: Record "Reg. No. Service Config CZL";
    begin
        if not RegNoServiceConfigCZL.IsEmpty() then
            exit;
        InitServiceSetup();
    end;

    local procedure GetValue(JsonObject: JsonObject; JsonKey: Text; var Result: Text): Boolean
    var
        JsonToken: JsonToken;
    begin
        if not JsonObject.Get(JsonKey, JsonToken) then
            exit(false);

        exit(GetValue(JsonToken, Result));
    end;

    local procedure GetValue(JsonObject: JsonObject; JsonKey: Text; var Result: JsonObject): Boolean
    var
        JsonToken: JsonToken;
    begin
        if not JsonObject.Get(JsonKey, JsonToken) then
            exit(false);

        exit(GetValue(JsonToken, Result));
    end;

    local procedure GetValue(JsonToken: JsonToken; var Result: Text): Boolean
    var
        JsonValue: JsonValue;
    begin
        if not JsonToken.IsValue() then
            exit(false);

        JsonValue := JsonToken.AsValue();
        if JsonValue.IsUndefined() or JsonValue.IsNull() then
            exit(false);

        Result := JsonValue.AsText();
        exit(true);
    end;

    local procedure GetValue(JsonToken: JsonToken; var Result: JsonObject): Boolean
    begin
        if not JsonToken.IsObject() then
            exit(false);

        Result := JsonToken.AsObject();
        exit(true);
    end;

    procedure CheckARESForRegNo(var RecordRef: RecordRef; var RegistrationLogCZL: Record "Registration Log CZL"; RecordVariant: Variant; EntryNo: Code[20]; AccountType: Enum "Reg. Log Account Type CZL")
    var
        Contact: Record Contact;
        RegNoServiceConfigCZL: Record "Reg. No. Service Config CZL";
        DataTypeManagement: Codeunit "Data Type Management";
        RegNoFieldRef: FieldRef;
        RegNo: Text[20];
    begin
        DataTypeManagement.GetRecordRef(RecordVariant, RecordRef);
        if RegNoServiceConfigCZL.RegNoSrvIsEnabled() then begin
            if not DataTypeManagement.FindFieldByName(RecordRef, RegNoFieldRef, Contact.FieldName("Registration Number")) then
                exit;
            RegNo := RegNoFieldRef.Value;
            RegistrationLogCZL.InitRegLog(RegistrationLogCZL, AccountType, EntryNo, RegNo);
            Codeunit.Run(Codeunit::"Reg. Lookup Ext. Data CZL", RegistrationLogCZL);
        end;
    end;

    procedure UpdateRecordFromRegLog(var RecordRef: RecordRef; RecordVariant: Variant; RegistrationLogCZL: Record "Registration Log CZL")
    var
        DataTypeManagement: Codeunit "Data Type Management";
    begin
        if not GuiAllowed() then
            exit;

        case RegistrationLogCZL.Status of
            RegistrationLogCZL.Status::Valid:
                case RegistrationLogCZL."Detail Status" of
                    RegistrationLogCZL."Detail Status"::"Not Verified":
                        Message(DetailNotVerifiedMsg);
                    RegistrationLogCZL."Detail Status"::Valid:
                        Message(ValidRegNoMsg);
                    RegistrationLogCZL."Detail Status"::"Partially Valid",
                    RegistrationLogCZL."Detail Status"::"Not Valid":
                        begin
                            DataTypeManagement.GetRecordRef(RecordVariant, RecordRef);
                            RegistrationLogCZL.OpenDetailForRecRef(RecordRef);
                        end;
                end;
            RegistrationLogCZL.Status::Invalid:
                Message(InvalidRegNoMsg);
            else
                Message(NotVerifiedRegNoMsg);
        end;
    end;

    procedure ValidateRegNoWithARES(var RecordRef: RecordRef; RecordVariant: Variant; EntryNo: Code[20]; AccountType: Enum "Reg. Log Account Type CZL")
    var
        UpdatedRegistrationLogCZL: Record "Registration Log CZL";
    begin
        CheckARESForRegNo(RecordRef, UpdatedRegistrationLogCZL, RecordVariant, EntryNo, AccountType);
        if UpdatedRegistrationLogCZL.Find() then // Only update if the log was created
            UpdateRecordFromRegLog(RecordRef, RecordVariant, UpdatedRegistrationLogCZL);
    end;

    procedure GetServiceConditionsURL(): Text
    begin
        exit(ServiceConditionsURLTok);
    end;

    procedure RunRegistrationNoCheck(RecordVariant: Variant) ResultRecord: RecordRef
    var
        RegistrationNoCheck: Page "Registration No. Check CZL";
    begin
        RegistrationNoCheck.SetRecordRef(RecordVariant);
        Commit();
        RegistrationNoCheck.RunModal();
        RegistrationNoCheck.GetRecordRef(ResultRecord);
    end;

    [EventSubscriber(ObjectType::Table, Database::"Service Connection", 'OnRegisterServiceConnection', '', false, false)]
    local procedure HandleAresRegisterServiceConnection(var ServiceConnection: Record "Service Connection")
    var
        RegNoServiceConfigCZL: Record "Reg. No. Service Config CZL";
        ServiceConfigRecordRef: RecordRef;
    begin
        SetupService();
        RegNoServiceConfigCZL.FindFirst();
        ServiceConfigRecordRef.GetTable(RegNoServiceConfigCZL);

        if RegNoServiceConfigCZL.Enabled then
            ServiceConnection.Status := ServiceConnection.Status::Enabled
        else
            ServiceConnection.Status := ServiceConnection.Status::Disabled;
        ServiceConnection.InsertServiceConnection(
              ServiceConnection, ServiceConfigRecordRef.RecordId, DescriptionLbl, RegNoServiceConfigCZL."Service Endpoint", Page::"Reg. No. Service Config CZL");
    end;
}
