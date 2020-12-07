codeunit 4004 "Create Companies IC"
{
    TableNo = "Hybrid Company";

    trigger OnRun();
    begin
        CreateCompanies();
    end;

    local procedure CreateCompanies();
    var
        Company: Record Company;
        HybridCompany: Record "Hybrid Company";
        IntelligentCloudSetup: Record "Intelligent Cloud Setup";
        AssistedCompanySetup: Codeunit "Assisted Company Setup";
        CompanyDataType: Option "Evaluation Data","Standard Data","None","Extended Data","Full No Data";
    begin
        CompanyDataType := CompanyDataType::None;

        if IntelligentCloudSetup.Get() then
            OnBeforeCreateCompany(IntelligentCloudSetup."Product ID", CompanyDataType);

        HybridCompany.Reset();
        HybridCompany.SetRange(Replicate, true);
        if HybridCompany.FindSet() then
            repeat
                if not Company.Get(HybridCompany."Name") then begin
                    AssistedCompanySetup.CreateNewCompany(CopyStr(HybridCompany."Name", 1, 30));

                    if Company.Get(HybridCompany."Name") then
                        if HybridCompany."Display Name" <> '' then begin
                            Company."Display Name" := HybridCompany."Display Name";
                            Company.Modify();
                        end;
                    AssistedCompanySetup.SetUpNewCompany(CopyStr(HybridCompany."Name", 1, 30), CompanyDataType);
                end;
            until HybridCompany.Next() = 0;

        HybridCompany.ModifyAll("Company Initialization Status", HybridCompany."Company Initialization Status"::"Not Initialized", true);
        IntelligentCloudSetup.LockTable();
        IntelligentCloudSetup.Get();
        IntelligentCloudSetup."Company Creation Task Status" := IntelligentCloudSetup."Company Creation Task Status"::Completed;
        IntelligentCloudSetup.Modify();
    end;

    [IntegrationEvent(false, false)]
    procedure OnBeforeCreateCompany(ProductId: Text; var CompanyDataType: Option "Evaluation Data","Standard Data","None","Extended Data","Full No Data")
    begin
    end;
}
