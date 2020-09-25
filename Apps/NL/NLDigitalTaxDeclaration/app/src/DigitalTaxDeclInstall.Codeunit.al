codeunit 11425 "Digital Tax Decl. Install"
{
    Subtype = Install;

    var
        DigitalTaxDeclLbl: Label 'DigitalTaxDecl', Locked = true;

    trigger OnInstallAppPerCompany()
    begin
        if InitializeDone() then
            exit;
        OnCompanyInitialize();
    end;

    [EventSubscriber(ObjectType::Codeunit, Codeunit::"Company-Initialize", 'OnCompanyInitialize', '', false, false)]
    local procedure OnCompanyInitialize()
    var
        VATReportsConfiguration: Record "VAT Reports Configuration";
    begin
        with VATReportsConfiguration do begin
            "VAT Report Type" := "VAT Report Type"::"VAT Return";
            "VAT Report Version" := CopyStr(DigitalTaxDeclLbl, 1, MaxStrLen("VAT Report Version"));
            if Find() then
                exit;
            "Suggest Lines Codeunit ID" := CODEUNIT::"VAT Report Suggest Lines";
            "Content Codeunit ID" := CODEUNIT::"Create Elec. Tax Declaration";
            "Submission Codeunit ID" := CODEUNIT::"Submit Elec. Tax Declaration";
            "Response Handler Codeunit ID" := CODEUNIT::"Receive Elec. Tax Declaration";
            "Validate Codeunit ID" := CODEUNIT::"Validate Elec. Tax Declaration";
            Insert();
        end;
    end;

    local procedure InitializeDone(): boolean
    var
        AppInfo: ModuleInfo;
    begin
        NavApp.GetCurrentModuleInfo(AppInfo);
        exit(AppInfo.DataVersion() <> Version.Create('0.0.0.0'));
    end;
}