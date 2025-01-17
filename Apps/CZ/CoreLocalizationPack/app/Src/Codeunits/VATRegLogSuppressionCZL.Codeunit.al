// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------
namespace Microsoft.Finance.VAT.Registration;

using Microsoft.CRM.Contact;
using Microsoft.Purchases.Vendor;
using Microsoft.Sales.Customer;

codeunit 31378 "VAT Reg. Log Suppression CZL"
{
    EventSubscriberInstance = Manual;

    [EventSubscriber(ObjectType::Table, Database::Customer, 'OnBeforeVATRegistrationValidation', '', false, false)]
    local procedure SkipVATRegLogOnBeforeVATRegistrationValidationOnCustomer(var Customer: Record Customer; var IsHandled: Boolean)
    var
        VATRegistrationNoFormat: Record "VAT Registration No. Format";
        VATRegistrationLogMgt: Codeunit "VAT Registration Log Mgt.";
    begin
        if IsHandled then
            exit;

        IsHandled := true;
        if not VATRegistrationNoFormat.Test(Customer."VAT Registration No.", Customer."Country/Region Code", Customer."No.", DATABASE::Customer) then
            exit;
        VATRegistrationLogMgt.LogCustomer(Customer);
    end;

    [EventSubscriber(ObjectType::Table, Database::Vendor, 'OnBeforeVATRegistrationValidation', '', false, false)]
    local procedure SkipVATRegLogOnBeforeVATRegistrationValidationOnVendor(var Vendor: Record Vendor; var IsHandled: Boolean)
    var
        VATRegistrationNoFormat: Record "VAT Registration No. Format";
        VATRegistrationLogMgt: Codeunit "VAT Registration Log Mgt.";
    begin
        if IsHandled then
            exit;

        IsHandled := true;
        if not VATRegistrationNoFormat.Test(Vendor."VAT Registration No.", Vendor."Country/Region Code", Vendor."No.", DATABASE::Vendor) then
            exit;
        VATRegistrationLogMgt.LogVendor(Vendor);
    end;

    [EventSubscriber(ObjectType::Table, Database::Contact, 'OnBeforeVATRegistrationValidation', '', false, false)]
    local procedure SkipVATRegLogOnBeforeVATRegistrationValidationOnContact(var Contact: Record Contact; var IsHandled: Boolean)
    var
        VATRegistrationNoFormat: Record "VAT Registration No. Format";
        VATRegistrationLogMgt: Codeunit "VAT Registration Log Mgt.";
    begin
        if IsHandled then
            exit;

        IsHandled := true;
        if not VATRegistrationNoFormat.Test(Contact."VAT Registration No.", Contact."Country/Region Code", Contact."No.", DATABASE::Contact) then
            exit;
        VATRegistrationLogMgt.LogContact(Contact);
    end;
}
