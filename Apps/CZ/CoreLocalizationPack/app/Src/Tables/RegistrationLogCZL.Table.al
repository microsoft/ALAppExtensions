// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------
namespace Microsoft.Finance.Registration;

using Microsoft.CRM.BusinessRelation;
using Microsoft.CRM.Contact;
using Microsoft.Finance.VAT.Registration;
using Microsoft.Foundation.Address;
using Microsoft.Purchases.Vendor;
using Microsoft.Sales.Customer;
using System.IO;
using System.Reflection;
using System.Security.AccessControl;

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
        field(16; "Verified Country/Region Code"; Code[10])
        {
            Caption = 'Verified Country/Region Code';
            TableRelation = "Country/Region";
            ValidateTableRelation = false;
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

    procedure OpenModifyDetails()
    var
        Customer: Record Customer;
        Vendor: Record Vendor;
        Contact: Record Contact;
        CustContUpdate: Codeunit "CustCont-Update";
        VendContUpdate: Codeunit "VendCont-Update";
        RecordRef: RecordRef;
    begin
        GetAccountRecordRef(RecordRef);
        if OpenDetailForRecRef(RecordRef) then
            case RecordRef.Number of
                Database::Customer:
                    begin
                        RecordRef.Modify();
                        RecordRef.SetTable(Customer);
                        CustContUpdate.OnModify(Customer);
                    end;
                Database::Vendor:
                    begin
                        RecordRef.Modify();
                        RecordRef.SetTable(Vendor);
                        VendContUpdate.OnModify(Vendor);
                    end;
                Database::Contact:
                    begin
                        RecordRef.SetTable(Contact);
                        Contact.Modify(true);
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
        DummyCustomer: Record Customer;
        RegistrationLogDetail: Record "Registration Log Detail CZL";
        VATRegLogSuppression: Codeunit "VAT Reg. Log Suppression CZL";
        IsHandled: Boolean;
    begin
        OnBeforeApplyDetailChanges(RecordRef, Result, IsHandled);
        if IsHandled then
            exit;
        RegistrationLogDetail.SetRange("Log Entry No.", "Entry No.");
        RegistrationLogDetail.SetRange(Status, RegistrationLogDetail.Status::Accepted);
        Result := RegistrationLogDetail.FindSet();
        if Result then begin
            repeat
                case RegistrationLogDetail."Field Name" of
                    RegistrationLogDetail."Field Name"::Name:
                        ValidateField(RecordRef, DummyCustomer.FieldName(Name), RegistrationLogDetail.Response, true);
                    RegistrationLogDetail."Field Name"::Address:
                        ValidateField(RecordRef, DummyCustomer.FieldName(Address), RegistrationLogDetail.Response, true);
                    RegistrationLogDetail."Field Name"::City:
                        ValidateField(RecordRef, DummyCustomer.FieldName(City), RegistrationLogDetail.Response, false);
                    RegistrationLogDetail."Field Name"::"Post Code":
                        ValidateField(RecordRef, DummyCustomer.FieldName("Post Code"), RegistrationLogDetail.Response, false);
                    RegistrationLogDetail."Field Name"::"Country/Region Code":
                        ValidateField(RecordRef, DummyCustomer.FieldName("Country/Region Code"), RegistrationLogDetail.Response, false);
                    RegistrationLogDetail."Field Name"::"VAT Registration No.":
                        begin
                            BindSubscription(VATRegLogSuppression);
                            ValidateField(RecordRef, DummyCustomer.FieldName("VAT Registration No."), RegistrationLogDetail.Response, true);
                            UnbindSubscription(VATRegLogSuppression)
                        end;
                    else
                        OnApplyDetailChanges(RegistrationLogDetail, RecordRef, Result);
                end;
            until RegistrationLogDetail.Next() = 0;
            RegistrationLogDetail.ModifyAll(Status, RegistrationLogDetail.Status::Applied);
            ShowDetailUpdatedMessage(RecordRef.Number());
        end;
        OnAfterApplyDetailChanges(RecordRef, Result);
    end;

    local procedure ValidateField(var RecordRef: RecordRef; FieldName: Text; Value: Text; Validate: Boolean)
    var
        ConfigValidateManagement: Codeunit "Config. Validate Management";
        DataTypeManagement: Codeunit "Data Type Management";
        FieldRef: FieldRef;
    begin
        if DataTypeManagement.FindFieldByName(RecordRef, FieldRef, FieldName) then
            if Validate then
                ConfigValidateManagement.EvaluateValueWithValidate(FieldRef, CopyStr(Value, 1, FieldRef.Length()), false)
            else
                ConfigValidateManagement.EvaluateValue(FieldRef, CopyStr(Value, 1, FieldRef.Length()), false)
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
          TotalCount, ValidCount, Enum::"Reg. Log Detail Field CZL"::"Country/Region Code", GetFieldValue(RecordRef, DummyCustomer.FieldName("Country/Region Code")), "Verified Country/Region Code");
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

    [IntegrationEvent(false, false)]
    local procedure OnBeforeApplyDetailChanges(var RecordRef: RecordRef; var Result: Boolean; var IsHandled: Boolean)
    begin
    end;

    [IntegrationEvent(false, false)]
    local procedure OnApplyDetailChanges(RegistrationLogDetail: Record "Registration Log Detail CZL"; var RecordRef: RecordRef; var Result: Boolean)
    begin
    end;

    [IntegrationEvent(false, false)]
    local procedure OnAfterApplyDetailChanges(var RecordRef: RecordRef; var Result: Boolean)
    begin
    end;
}
