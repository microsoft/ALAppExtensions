namespace Microsoft.Finance.VAT.Reporting;

using Microsoft.Foundation.Company;

codeunit 10060 "Generate Xml File IRIS Events"
{
    procedure RunOnAddIssuerDetailsOnAfterGetCompanyInfoAndIRSFormSetup(var CompanyInformation: Record "Company Information"; var IRSFormsSetup: Record "IRS Forms Setup")
    begin
        OnAddIssuerDetailsOnAfterGetCompanyInfoAndIRSFormSetup(CompanyInformation, IRSFormsSetup);
    end;

    procedure RunOnAddContactPersonInformationGrpOnAfterGetCompanyInformationSetup(var CompanyInformation: Record "Company Information")
    begin
        OnAddContactPersonInformationGrpOnAfterGetCompanyInformationSetup(CompanyInformation);
    end;

    [IntegrationEvent(false, false)]
    procedure OnAddIssuerDetailsOnAfterGetCompanyInfoAndIRSFormSetup(var CompanyInformation: Record "Company Information"; var IRSFormsSetup: Record "IRS Forms Setup")
    begin
    end;

    [IntegrationEvent(false, false)]
    procedure OnAddContactPersonInformationGrpOnAfterGetCompanyInformationSetup(var CompanyInformation: Record "Company Information")
    begin
    end;
}