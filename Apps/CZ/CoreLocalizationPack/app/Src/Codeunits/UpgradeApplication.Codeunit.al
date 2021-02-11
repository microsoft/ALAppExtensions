#pragma warning disable AL0432
codeunit 31017 "Upgrade Application CZL"
{
    Subtype = Upgrade;

    var
        DataUpgradeMgt: Codeunit "Data Upgrade Mgt.";
        UpgradeTag: Codeunit "Upgrade Tag";
        UpgradeTagDefinitionsCZL: Codeunit "Upgrade Tag Definitions CZL";

    trigger OnUpgradePerDatabase()
    begin
        DataUpgradeMgt.SetUpgradeInProgress();

        UpdatePermission();

        if not UpgradeTag.HasUpgradeTag(UpgradeTagDefinitionsCZL.GetDataVersion174PerDatabaseUpgradeTag()) then
            UpgradeTag.SetUpgradeTag(UpgradeTagDefinitionsCZL.GetDataVersion174PerDatabaseUpgradeTag());
    end;

    trigger OnUpgradePerCompany()
    begin
        DataUpgradeMgt.SetUpgradeInProgress();

        UpdateCertificateCZCode();
        UpdateIsolatedCertificate();
        UpdateEETServiceSetup();
        UpdateEETBusinessPremises();
        UpdateEETCashRegister();
        UpdateEETEntry();
        UpdateEETEntryStatus();

        if not UpgradeTag.HasUpgradeTag(UpgradeTagDefinitionsCZL.GetDataVersion174PerCompanyUpgradeTag()) then
            UpgradeTag.SetUpgradeTag(UpgradeTagDefinitionsCZL.GetDataVersion174PerCompanyUpgradeTag());
    end;

    local procedure UpdateCertificateCZCode()
    var
        CertificateCZCode: Record "Certificate CZ Code";
        CertificateCodeCZL: Record "Certificate Code CZL";
    begin
        if UpgradeTag.HasUpgradeTag(UpgradeTagDefinitionsCZL.GetDataVersion174PerCompanyUpgradeTag()) then
            exit;

        if CertificateCZCode.FindSet() then
            repeat
                if not CertificateCodeCZL.Get(CertificateCZCode.Code) then begin
                    CertificateCodeCZL.Init();
                    CertificateCodeCZL.Code := CertificateCZCode.Code;
                    CertificateCodeCZL.Insert();
                end;
                CertificateCodeCZL.Description := CertificateCZCode.Description;
                CertificateCodeCZL.Modify(false);
            until CertificateCZCode.Next() = 0;
    end;

    local procedure UpdateIsolatedCertificate()
    var
        IsolatedCertificate: Record "Isolated Certificate";
    begin
        if UpgradeTag.HasUpgradeTag(UpgradeTagDefinitionsCZL.GetDataVersion174PerCompanyUpgradeTag()) then
            exit;

        if IsolatedCertificate.FindSet() then
            repeat
                IsolatedCertificate."Certificate Code CZL" := IsolatedCertificate."Certificate Code";
                IsolatedCertificate.Modify(false);
            until IsolatedCertificate.Next() = 0;
    end;

    local procedure UpdateEETServiceSetup()
    var
        EETServiceSetup: Record "EET Service Setup";
        EETServiceSetupCZL: Record "EET Service Setup CZL";
    begin
        if UpgradeTag.HasUpgradeTag(UpgradeTagDefinitionsCZL.GetDataVersion174PerCompanyUpgradeTag()) then
            exit;

        if EETServiceSetup.Get() then begin
            if not EETServiceSetupCZL.Get() then begin
                EETServiceSetupCZL.Init();
                EETServiceSetupCZL.Insert();
            end;

            EETServiceSetupCZL."Service URL" := EETServiceSetup."Service URL";
            EETServiceSetupCZL."Sales Regime" := "EET Sales Regime CZL".FromInteger(EETServiceSetup."Sales Regime");
            EETServiceSetupCZL."Limit Response Time" := EETServiceSetup."Limit Response Time";
            EETServiceSetupCZL."Appointing VAT Reg. No." := EETServiceSetup."Appointing VAT Reg. No.";
            EETServiceSetupCZL."Certificate Code" := EETServiceSetup."Certificate Code";
            if EETServiceSetup.Enabled then begin
                EETServiceSetupCZL.Enabled := true;
                EETServiceSetup.Validate(Enabled, false);
                EETServiceSetup.Modify(false);
            end;
            EETServiceSetupCZL.Modify(false);
        end;
    end;

    local procedure UpdateEETBusinessPremises()
    var
        EETBusinessPremises: Record "EET Business Premises";
        EETBusinessPremisesCZL: Record "EET Business Premises CZL";
    begin
        if UpgradeTag.HasUpgradeTag(UpgradeTagDefinitionsCZL.GetDataVersion174PerCompanyUpgradeTag()) then
            exit;

        if EETBusinessPremises.FindSet() then
            repeat
                if not EETBusinessPremisesCZL.Get(EETBusinessPremises.Code) then begin
                    EETBusinessPremisesCZL.Init();
                    EETBusinessPremisesCZL.Code := EETBusinessPremises.Code;
                    EETBusinessPremisesCZL.Insert();
                end;
                EETBusinessPremisesCZL.Description := EETBusinessPremises.Description;
                EETBusinessPremisesCZL.Identification := EETBusinessPremises.Identification;
                EETBusinessPremisesCZL."Certificate Code" := EETBusinessPremises."Certificate Code";
                EETBusinessPremisesCZL.Modify(false);
            until EETBusinessPremises.Next() = 0;
    end;

    local procedure UpdateEETCashRegister()
    var
        EETCashRegister: Record "EET Cash Register";
        EETCashRegisterCZL: Record "EET Cash Register CZL";
    begin
        if UpgradeTag.HasUpgradeTag(UpgradeTagDefinitionsCZL.GetDataVersion174PerCompanyUpgradeTag()) then
            exit;

        if EETCashRegister.FindSet() then
            repeat
                if not EETCashRegisterCZL.Get(EETCashRegister."Business Premises Code", EETCashRegister.Code) then begin
                    EETCashRegisterCZL.Init();
                    EETCashRegisterCZL."Business Premises Code" := EETCashRegister."Business Premises Code";
                    EETCashRegisterCZL.Code := EETCashRegister.Code;
                    EETCashRegisterCZL.Insert();
                end;
                EETCashRegisterCZL."Cash Register Type" := "EET Cash Register Type CZL".FromInteger(EETCashRegister."Register Type");
                EETCashRegisterCZL."Cash Register No." := EETCashRegister."Register No.";
                EETCashRegisterCZL."Cash Register Name" := EETCashRegister."Register Name";
                EETCashRegisterCZL."Certificate Code" := EETCashRegister."Certificate Code";
                EETCashRegisterCZL."Receipt Serial Nos." := EETCashRegister."Receipt Serial Nos.";
                EETCashRegisterCZL.Modify(false);
            until EETCashRegister.Next() = 0;
    end;

    local procedure UpdateEETEntry()
    var
        EETEntry: Record "EET Entry";
        EETEntryCZL: Record "EET Entry CZL";
    begin
        if UpgradeTag.HasUpgradeTag(UpgradeTagDefinitionsCZL.GetDataVersion174PerCompanyUpgradeTag()) then
            exit;

        if EETEntry.FindSet() then
            repeat
                if not EETEntryCZL.Get(EETEntry."Entry No.") then begin
                    EETEntryCZL.Init();
                    EETEntryCZL."Entry No." := EETEntry."Entry No.";
                    EETEntryCZL.Insert();
                end;
                EETEntryCZL."Cash Register Type" := "EET Cash Register Type CZL".FromInteger(EETEntry."Source Type");
                EETEntryCZL."Cash Register No." := EETEntry."Source No.";
                EETEntryCZL."Business Premises Code" := EETEntry."Business Premises Code";
                EETEntryCZL."Cash Register Code" := EETEntry."Cash Register Code";
                EETEntryCZL."Document No." := EETEntry."Document No.";
                EETEntryCZL.Description := EETEntry.Description;
                EETEntryCZL."Applied Document Type" := "EET Applied Document Type CZL".FromInteger(EETEntry."Applied Document Type");
                EETEntryCZL."Applied Document No." := EETEntry."Applied Document No.";
                EETEntryCZL."Created By" := EETEntry."User ID";
                EETEntryCZL."Created At" := EETEntry."Creation Datetime";
                EETEntryCZL."Status" := "EET Status CZL".FromInteger(EETEntry."EET Status");
                EETEntryCZL."Status Last Changed At" := EETEntry."EET Status Last Changed";
                EETEntryCZL."Message UUID" := EETEntry."Message UUID";
                EETEntry.CalcFields("Signature Code (PKP)");
                EETEntryCZL."Taxpayer's Signature Code" := EETEntry."Signature Code (PKP)";
                EETEntryCZL."Taxpayer's Security Code" := EETEntry."Security Code (BKP)";
                EETEntryCZL."Fiscal Identification Code" := EETEntry."Fiscal Identification Code";
                EETEntryCZL."Receipt Serial No." := EETEntry."Receipt Serial No.";
                EETEntryCZL."Total Sales Amount" := EETEntry."Total Sales Amount";
                EETEntryCZL."Amount Exempted From VAT" := EETEntry."Amount Exempted From VAT";
                EETEntryCZL."VAT Base (Basic)" := EETEntry."VAT Base (Basic)";
                EETEntryCZL."VAT Amount (Basic)" := EETEntry."VAT Amount (Basic)";
                EETEntryCZL."VAT Base (Reduced)" := EETEntry."VAT Base (Reduced)";
                EETEntryCZL."VAT Amount (Reduced)" := EETEntry."VAT Amount (Reduced)";
                EETEntryCZL."VAT Base (Reduced 2)" := EETEntry."VAT Base (Reduced 2)";
                EETEntryCZL."VAT Amount (Reduced 2)" := EETEntry."VAT Amount (Reduced 2)";
                EETEntryCZL."Amount - Art.89" := EETEntry."Amount - Art.89";
                EETEntryCZL."Amount (Basic) - Art.90" := EETEntry."Amount (Basic) - Art.90";
                EETEntryCZL."Amount (Reduced) - Art.90" := EETEntry."Amount (Reduced) - Art.90";
                EETEntryCZL."Amount (Reduced 2) - Art.90" := EETEntry."Amount (Reduced 2) - Art.90";
                EETEntryCZL."Amt. For Subseq. Draw/Settle" := EETEntry."Amt. For Subseq. Draw/Settle";
                EETEntryCZL."Amt. Subseq. Drawn/Settled" := EETEntry."Amt. Subseq. Drawn/Settled";
                EETEntryCZL."Canceled By Entry No." := EETEntry."Canceled By Entry No.";
                EETEntryCZL."Simple Registration" := EETEntry."Simple Registration";
                EETEntryCZL.Modify(false);
            until EETEntry.Next() = 0;
    end;

    local procedure UpdateEETEntryStatus()
    var
        EETEntryStatus: Record "EET Entry Status";
        EETEntryStatusLogCZL: Record "EET Entry Status Log CZL";
    begin
        if UpgradeTag.HasUpgradeTag(UpgradeTagDefinitionsCZL.GetDataVersion174PerCompanyUpgradeTag()) then
            exit;

        if EETEntryStatus.FindSet() then
            repeat
                if not EETEntryStatusLogCZL.Get(EETEntryStatus."Entry No.") then begin
                    EETEntryStatusLogCZL.Init();
                    EETEntryStatusLogCZL."Entry No." := EETEntryStatus."Entry No.";
                    EETEntryStatusLogCZL.Insert();
                end;
                EETEntryStatusLogCZL."EET Entry No." := EETEntryStatus."EET Entry No.";
                EETEntryStatusLogCZL.Description := EETEntryStatus.Description;
                EETEntryStatusLogCZL.Status := "EET Status CZL".FromInteger(EETEntryStatus.Status);
                EETEntryStatusLogCZL."Changed At" := EETEntryStatus."Change Datetime";
                EETEntryStatusLogCZL.Modify(false);
            until EETEntryStatus.Next() = 0;
    end;

    local procedure UpdatePermission()
    begin
        if UpgradeTag.HasUpgradeTag(UpgradeTagDefinitionsCZL.GetDataVersion174PerDatabaseUpgradeTag()) then
            exit;

        InsertTableDataPermissions(Database::"Certificate CZ Code", Database::"Certificate Code CZL");
        InsertTableDataPermissions(Database::"EET Business Premises", Database::"EET Business Premises CZL");
        InsertTableDataPermissions(Database::"EET Cash Register", Database::"EET Cash Register CZL");
        InsertTableDataPermissions(Database::"EET Entry", Database::"EET Entry CZL");
        InsertTableDataPermissions(Database::"EET Entry Status", Database::"EET Entry Status Log CZL");
        InsertTableDataPermissions(Database::"EET Service Setup", Database::"EET Service Setup CZL");
    end;

    local procedure InsertTableDataPermissions(OldTableID: Integer; NewTableID: Integer)
    var
        Permission: Record Permission;
        NewPermission: Record Permission;
    begin
        Permission.SetRange("Object Type", Permission."Object Type"::"Table Data");
        Permission.SetRange("Object ID", OldTableID);
        if not Permission.FindSet() then
            exit;
        repeat
            if not NewPermission.Get(Permission."Role ID", Permission."Object Type", Permission."Object ID") then begin
                NewPermission.Init();
                NewPermission := Permission;
                NewPermission."Object ID" := NewTableID;
                NewPermission.Insert();
            end;
        until Permission.Next() = 0;
    end;
}
