// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------

codeunit 11022 "Elster - Data Migration"
{
    trigger OnRun()
    begin
        MigrateSalesVATAdvanceNotification();
    end;

    local procedure MigrateSalesVATAdvanceNotification()
    var
        SalesVATAdvanceNotification: Record "Sales VAT Advance Notification";
        SalesVATAdvanceNotif: Record "Sales VAT Advance Notif.";
    begin
        if SalesVATAdvanceNotification.FindSet() then
            repeat
                SalesVATAdvanceNotif.TransferFields(SalesVATAdvanceNotification, true);
                SalesVATAdvanceNotification.CalcFields("XML Submission Document");
                SalesVATAdvanceNotif."XML Submission Document" := SalesVATAdvanceNotification."XML Submission Document";
                SalesVATAdvanceNotif.Insert();
            until SalesVATAdvanceNotification.Next() = 0;
    end;

    local procedure MigrateElecVATDeclSetup()
    var
        ElectronicVATDeclSetup: Record "Electronic VAT Decl. Setup";
        ElecVATDeclSetup: Record "Elec. VAT Decl. Setup";
    begin
        if not ElectronicVATDeclSetup.Get() then
            exit;
        ElecVATDeclSetup.Get();
        ElecVATDeclSetup.Validate("Sales VAT Adv. Notif. Path", ElectronicVATDeclSetup."Sales VAT Adv. Notif. Path");
        ElecVATDeclSetup.Validate("XML File Default Name", ElectronicVATDeclSetup."Sales VAT Adv. Notif. Path");
        ElecVATDeclSetup.Modify(true);
    end;
}