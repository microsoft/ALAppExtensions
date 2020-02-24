// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------

codeunit 11022 "Elster - Data Migration"
{
    Subtype = Upgrade;

    trigger OnUpgradePerCompany()
    begin
        UpgradeOldTables();
        CleanupOldTables();
    end;

    local procedure UpgradeOldTables()
    var
        UpgradeTag: Codeunit "Upgrade Tag";
        ElsterManagement: Codeunit "Elster Management";
    begin
        if UpgradeTag.HasUpgradeTag(ElsterManagement.GetElsterUpgradeTag()) then
            exit;

        MigrateSalesVATAdvanceNotification();
        MigrateElecVATDeclSetup();

        UpgradeTag.SetUpgradeTag(ElsterManagement.GetElsterUpgradeTag());
    end;

    local procedure MigrateSalesVATAdvanceNotification()
    var
        SalesVATAdvanceNotification: Record "Sales VAT Advance Notification";
        SalesVATAdvanceNotif: Record "Sales VAT Advance Notif.";
    begin
        if not SalesVATAdvanceNotif.IsEmpty() then
            exit;

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
        if ElecVATDeclSetup.Get() then
            exit;

        if not ElectronicVATDeclSetup.Get() then
            exit;

        ElecVATDeclSetup.Validate("Sales VAT Adv. Notif. Path", ElectronicVATDeclSetup."Sales VAT Adv. Notif. Path");
        ElecVATDeclSetup.Validate("XML File Default Name", ElectronicVATDeclSetup."Sales VAT Adv. Notif. Path");
        ElecVATDeclSetup.insert(true);
    end;

    local procedure CleanupOldTables()
    var
        SalesVATAdvanceNotification: Record "Sales VAT Advance Notification";
        ElectronicVATDeclSetup: Record "Electronic VAT Decl. Setup";
        UpgradeTag: Codeunit "Upgrade Tag";
        ElsterManagement: Codeunit "Elster Management";
    begin
        if UpgradeTag.HasUpgradeTag(ElsterManagement.GetCleanupElsterTag()) then
            exit;

        SalesVATAdvanceNotification.DeleteAll();
        ElectronicVATDeclSetup.DeleteAll();

        UpgradeTag.SetUpgradeTag(ElsterManagement.GetCleanupElsterTag());
    end;
}
