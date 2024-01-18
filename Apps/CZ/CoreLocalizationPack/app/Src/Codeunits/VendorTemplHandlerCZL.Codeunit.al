// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------
namespace Microsoft.Purchases.Vendor;

using Microsoft.Finance.Registration;

codeunit 31386 "Vendor Templ. Handler CZL"
{
    [EventSubscriber(ObjectType::Table, Database::"Vendor Templ.", 'OnBeforeValidateEvent', 'Validate EU Vat Reg. No.', false, false)]
    local procedure CheckValidateRegistrationNoOnBeforeModifyValidateEUVATRegNo(var Rec: Record "Vendor Templ.")
    begin
        if Rec."Validate EU Vat Reg. No." then
            Rec.TestField("Validate Registration No. CZL", false);
    end;

    [EventSubscriber(ObjectType::Codeunit, Codeunit::"Vendor Templ. Mgt.", 'OnApplyTemplateOnBeforeVendorModify', '', false, false)]
    local procedure OnApplyTemplateOnBeforeCustomerModify(var Vendor: Record Vendor; VendorTempl: Record "Vendor Templ.")
    begin
        Vendor."Validate Registration No. CZL" := VendorTempl."Validate Registration No. CZL";
    end;

    [EventSubscriber(ObjectType::Codeunit, Codeunit::"Vendor Templ. Mgt.", 'OnAfterCreateVendorFromTemplate', '', false, false)]
    local procedure VerifyRegNoOnAfterCreateVendorFromTemplate(var Vendor: Record Vendor)
    var
        RegNoServiceConfig: Record "Reg. No. Service Config CZL";
        RegistrationLogMgt: Codeunit "Registration Log Mgt. CZL";
    begin
        if not GuiAllowed() or
           not Vendor."Validate Registration No. CZL"
        then
            exit;

        if not RegNoServiceConfig.RegNoSrvIsEnabled() then
            exit;

        RegistrationLogMgt.RunRegistrationNoCheck(Vendor).SetTable(Vendor);
    end;
}
