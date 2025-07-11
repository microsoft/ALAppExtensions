// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------
namespace Microsoft.Sales.Customer;

using Microsoft.Finance.Registration;

codeunit 31385 "Customer Templ. Handler CZL"
{
    [EventSubscriber(ObjectType::Table, Database::"Customer Templ.", 'OnBeforeValidateEvent', 'Validate EU Vat Reg. No.', false, false)]
    local procedure CheckValidateRegistrationNoOnBeforeModifyValidateEUVATRegNo(var Rec: Record "Customer Templ.")
    begin
        if Rec."Validate EU Vat Reg. No." then
            Rec.TestField("Validate Registration No. CZL", false);
    end;

    [EventSubscriber(ObjectType::Codeunit, Codeunit::"Customer Templ. Mgt.", 'OnApplyTemplateOnBeforeCustomerModify', '', false, false)]
    local procedure OnApplyTemplateOnBeforeCustomerModify(var Customer: Record Customer; CustomerTempl: Record "Customer Templ.")
    begin
        Customer."Validate Registration No. CZL" := CustomerTempl."Validate Registration No. CZL";
    end;

    [EventSubscriber(ObjectType::Codeunit, Codeunit::"Customer Templ. Mgt.", 'OnAfterCreateCustomerFromTemplate', '', false, false)]
    local procedure VerifyRegNoOnAfterCreateCustomerFromTemplate(var Customer: Record Customer)
    var
        RegNoServiceConfig: Record "Reg. No. Service Config CZL";
        RegistrationLogMgt: Codeunit "Registration Log Mgt. CZL";
    begin
        if not GuiAllowed() or
           not Customer."Validate Registration No. CZL"
        then
            exit;

        if not RegNoServiceConfig.RegNoSrvIsEnabled() then
            exit;

        RegistrationLogMgt.RunRegistrationNoCheck(Customer).SetTable(Customer);
    end;
}
