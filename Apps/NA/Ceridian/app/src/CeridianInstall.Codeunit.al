namespace Microsoft.Payroll.Ceridian;

using Microsoft.Foundation.Company;
using System.Environment;
using System.Privacy;

codeunit 1667 "Ceridian Install"
{
    Subtype = install;

    trigger OnInstallAppPerCompany()    
    begin       
        CompanyInitialize();
    end;

    [EventSubscriber(ObjectType::Codeunit, Codeunit::"Company-Initialize", 'OnCompanyInitialize', '', false, false)]
    local procedure CompanyInitialize()
    begin
        ApplyEvaluationClassificationsForPrivacy();
    end;

    local procedure ApplyEvaluationClassificationsForPrivacy()
    var
        MSCeridianPayrollSetup: Record "MS Ceridian Payroll Setup";
        Company: Record Company;
        DataClassificationMgt: Codeunit "Data Classification Mgt.";
    begin
        Company.Get(CompanyName());
        if not Company."Evaluation Company" then
            exit;

        DataClassificationMgt.SetTableFieldsToNormal(Database::"MS Ceridian Payroll Setup");
        DataClassificationMgt.SetFieldToPersonal(Database::"MS Ceridian Payroll Setup", MSCeridianPayrollSetup.FieldNo("User Name"));
        DataClassificationMgt.SetFieldToPersonal(Database::"MS Ceridian Payroll Setup", MSCeridianPayrollSetup.FieldNo("Service URL"));
    end;
}

