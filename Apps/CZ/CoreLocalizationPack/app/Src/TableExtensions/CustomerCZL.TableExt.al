// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------
namespace Microsoft.Sales.Customer;

using Microsoft.CRM.BusinessRelation;
using Microsoft.Finance.Registration;
using Microsoft.Inventory.Intrastat;
using Microsoft.Sales.Receivables;

tableextension 11701 "Customer CZL" extends Customer
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
                IsHandled: Boolean;
            begin
                OnBeforeOnValidateRegistrationNoCZL(Rec, xRec, IsHandled);
                if IsHandled then
                    exit;

                if not RegistrationNoMgtCZL.CheckRegistrationNo(GetRegistrationNoTrimmedCZL(), "No.", Database::Customer) then
                    exit;

                LogNotVerified := true;
                if "Registration Number" <> xRec."Registration Number" then
                    if RegNoServiceConfigCZL.RegNoSrvIsEnabled() then begin
                        LogNotVerified := false;
                        RegistrationLogMgtCZL.ValidateRegNoWithARES(ResultRecordRef, Rec, "No.", RegistrationLogCZL."Account Type"::Customer);
                        ResultRecordRef.SetTable(Rec);
                    end;

                if LogNotVerified then
                    RegistrationLogMgtCZL.LogCustomer(Rec);
            end;
        }
        field(11770; "Registration No. CZL"; Text[20])
        {
            Caption = 'Registration No.';
            DataClassification = CustomerContent;
            ObsoleteState = Removed;
            ObsoleteTag = '26.0';
            ObsoleteReason = 'Replaced by standard "Registration Number" field.';
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
            ObsoleteState = Removed;
            ObsoleteTag = '25.0';
            ObsoleteReason = 'Intrastat related functionalities are moved to Intrastat extensions.';
        }
        field(31071; "Transaction Specification CZL"; Code[10])
        {
            Caption = 'Transaction Specification';
            TableRelation = "Transaction Specification";
            DataClassification = CustomerContent;
            ObsoleteState = Removed;
            ObsoleteTag = '25.0';
            ObsoleteReason = 'Intrastat related functionalities are moved to Intrastat extensions. This field will not be used anymore.';
        }
        field(31072; "Transport Method CZL"; Code[10])
        {
            Caption = 'Transport Method';
            TableRelation = "Transport Method";
            DataClassification = CustomerContent;
            ObsoleteState = Removed;
            ObsoleteTag = '25.0';
            ObsoleteReason = 'Intrastat related functionalities are moved to Intrastat extensions.';
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

    [IntegrationEvent(true, false)]
    local procedure OnBeforeOnValidateRegistrationNoCZL(Customer: Record "Customer"; xCustomer: Record "Customer"; var IsHandled: Boolean)
    begin
    end;
}
