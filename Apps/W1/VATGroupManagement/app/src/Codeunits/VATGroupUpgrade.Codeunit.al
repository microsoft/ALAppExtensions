codeunit 4709 "VAT Group Upgrade"
{
    Subtype = Upgrade;

    var
        UpgradeTag: Codeunit "Upgrade Tag";
        VATGroupUpgradeTags: Codeunit "VAT Group Upgrade Tags";

    trigger OnUpgradePerCompany()
    begin
        UpgradeVATGroupAuthEnum();
    end;

    local procedure UpgradeVATGroupAuthEnum()
    var
        VATReportSetup: Record "VAT Report Setup";
        VATReportSetupDataTransfer: DataTransfer;
    begin
        if UpgradeTag.HasUpgradeTag(VATGroupUpgradeTags.GetVATGroupAuthEnumRenameUpgradeTag()) then
            exit;

        VATReportSetupDataTransfer.SetTables(Database::"VAT Report Setup", Database::"VAT Report Setup");
        VATReportSetupDataTransfer.AddFieldValue(VATReportSetup.FieldNo("Authentication Type"), VATReportSetup.FieldNo("VAT Group Authentication Type"));
        VATReportSetupDataTransfer.UpdateAuditFields(false);
        VATReportSetupDataTransfer.CopyFields();

        UpgradeTag.SetUpgradeTag(VATGroupUpgradeTags.GetVATGroupAuthEnumRenameUpgradeTag());
    end;
}