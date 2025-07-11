// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------
namespace Microsoft.CRM;

using Microsoft.CRM.BusinessRelation;
using Microsoft.CRM.Contact;
using Microsoft.Finance.Registration;
using Microsoft.Purchases.Vendor;
using Microsoft.Sales.Customer;

codeunit 11751 "Contact Handler CZL"
{
    [EventSubscriber(ObjectType::Table, Database::Contact, 'OnAfterDeleteEvent', '', false, false)]
    local procedure DeleteRegistrationLogCZLOnAfterDelete(var Rec: Record Contact)
    var
        RegistrationLogMgtCZL: Codeunit "Registration Log Mgt. CZL";
    begin
        RegistrationLogMgtCZL.DeleteContactLog(Rec);
    end;

    [EventSubscriber(ObjectType::Table, Database::Contact, 'OnBeforeDuplicateCheck', '', false, false)]
    local procedure RegNoOnBeforeDuplicateCheck(Contact: Record Contact; xContact: Record Contact; var IsDuplicateCheckNeeded: Boolean)
    begin
        IsDuplicateCheckNeeded := IsDuplicateCheckNeeded or
            (Contact."Registration Number" <> xContact."Registration Number") or
            (Contact."Tax Registration No. CZL" <> xContact."Tax Registration No. CZL");
    end;

    [EventSubscriber(ObjectType::Table, Database::Contact, 'OnAfterSetTypeForContact', '', false, false)]
    local procedure RegNoOnAfterSetTypeForContact(var Contact: Record Contact)
    begin
        case Contact.Type of
            Contact.Type::Person:
                begin
                    Contact.TestField("Registration Number", '');
                    Contact.TestField("Tax Registration No. CZL", '');
                end;
        end;
    end;

    [EventSubscriber(ObjectType::Table, Database::Contact, 'OnBeforeIsUpdateNeeded', '', false, false)]
    local procedure RegNoOnBeforeIsUpdateNeeded(Contact: Record Contact; xContact: Record Contact; var UpdateNeeded: Boolean)
    begin
        UpdateNeeded := UpdateNeeded or
            (Contact."Registration Number" <> xContact."Registration Number") or
            (Contact."Tax Registration No. CZL" <> xContact."Tax Registration No. CZL");
    end;

    [EventSubscriber(ObjectType::Codeunit, Codeunit::"CustVendBank-Update", 'OnBeforeCustCopyFieldsFromCont', '', false, false)]
    local procedure SaveRegistrationNoOnBeforeCustCopyFieldsFromCont(var Customer: Record Customer)
    begin
        Customer.SaveRegistrationNoCZL();
    end;

    [EventSubscriber(ObjectType::Codeunit, Codeunit::"CustVendBank-Update", 'OnAfterUpdateCustomerProcedure', '', false, false)]
    local procedure RegNoLogInitOnAfterUpdateCustomer(var Customer: Record Customer)
    var
        RegistrationLogMgtCZL: Codeunit "Registration Log Mgt. CZL";
    begin
        if (Customer."Registration Number" <> '') and (Customer.GetSavedRegistrationNoCZL() <> Customer."Registration Number") then
            RegistrationLogMgtCZL.LogCustomer(Customer);
    end;

    [EventSubscriber(ObjectType::Codeunit, Codeunit::"CustVendBank-Update", 'OnBeforeVendCopyFieldsFromCont', '', false, false)]
    local procedure SaveRegistrationNoOnBeforeVendCopyFieldsFromCont(var Vendor: Record Vendor)
    begin
        Vendor.SaveRegistrationNoCZL();
    end;

    [EventSubscriber(ObjectType::Codeunit, Codeunit::"CustVendBank-Update", 'OnAfterUpdateVendorProcedure', '', false, false)]
    local procedure RegNoLogInitOnAfterUpdateVendorProcedure(var Vendor: Record Vendor)
    var
        RegistrationLogMgtCZL: Codeunit "Registration Log Mgt. CZL";
    begin
        if (Vendor."Registration Number" <> '') and (Vendor.GetSavedRegistrationNoCZL() <> Vendor."Registration Number") then
            RegistrationLogMgtCZL.LogVendor(Vendor);
    end;

    [EventSubscriber(ObjectType::Codeunit, Codeunit::"CustCont-Update", 'OnAfterTransferFieldsFromCustToCont', '', false, false)]
    local procedure RegNoLogOnAfterTransferFieldsFromCustToCont(var Contact: Record Contact; Customer: Record Customer)
    begin
        if CreateContactRegNumberLogFromCustomerLog(Customer, Contact) then
            Contact.Validate("Registration Number", Customer."Registration Number");
    end;

    [EventSubscriber(ObjectType::Codeunit, Codeunit::"VendCont-Update", 'OnAfterTransferFieldsFromVendToCont', '', false, false)]
    local procedure RegNoLogOnAfterTransferFieldsFromVendToCont(var Contact: Record Contact; Vendor: Record Vendor)
    begin
        if CreateContactRegNumberLogFromVendorLog(Vendor, Contact) then
            Contact.Validate("Registration Number", Vendor."Registration Number");
    end;

    local procedure CreateContactRegNumberLogFromCustomerLog(Customer: Record Customer; Contact: Record Contact): Boolean
    var
        RegistrationLog: Record "Registration Log CZL";
        RegNoServiceConfig: Record "Reg. No. Service Config CZL";
    begin
        if Customer."Registration Number" = '' then
            exit(false);
        if not RegNoServiceConfig.RegNoSrvIsEnabled() then
            exit(false);

        RegistrationLog.SetRange("Account Type", RegistrationLog."Account Type"::Customer);
        RegistrationLog.SetRange("Account No.", Customer."No.");
        RegistrationLog.SetRange("Registration No.", Customer."Registration Number");
        if RegistrationLog.IsEmpty() then
            exit(false);

        RegistrationLog.SetRange("Account Type", RegistrationLog."Account Type"::Contact);
        RegistrationLog.SetRange("Account No.", Contact."No.");
        RegistrationLog.SetRange("Registration No.", Customer."Registration Number");
        if RegistrationLog.IsEmpty() then
            exit(true);
    end;

    local procedure CreateContactRegNumberLogFromVendorLog(Vendor: Record Vendor; Contact: Record Contact): Boolean
    var
        RegistrationLog: Record "Registration Log CZL";
        RegNoServiceConfig: Record "Reg. No. Service Config CZL";
    begin
        if Vendor."Registration Number" = '' then
            exit(false);
        if not RegNoServiceConfig.RegNoSrvIsEnabled() then
            exit(false);

        RegistrationLog.SetRange("Account Type", RegistrationLog."Account Type"::Vendor);
        RegistrationLog.SetRange("Account No.", Vendor."No.");
        RegistrationLog.SetRange("Registration No.", Vendor."Registration Number");
        if RegistrationLog.IsEmpty() then
            exit(false);

        RegistrationLog.SetRange("Account Type", RegistrationLog."Account Type"::Contact);
        RegistrationLog.SetRange("Account No.", Contact."No.");
        RegistrationLog.SetRange("Registration No.", Vendor."Registration Number");
        if RegistrationLog.IsEmpty() then
            exit(true);
    end;
}
