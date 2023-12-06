namespace Microsoft.EServices;

using Microsoft.Foundation.Company;
using System.Environment;

pageextension 13609 "Companies Nemhandel Status" extends Companies
{
    var
        DeleteNemhandelRegisteredCompanyErr: Label 'You cannot delete a company that is registered in the Nemhandel service.';

    trigger OnDeleteRecord(): Boolean
    var
        CompanyInformation: Record "Company Information";
        EnvironmentInformation: Codeunit "Environment Information";
#if not CLEAN24
        NemhandelStatusMgt: Codeunit "Nemhandel Status Mgt.";
#endif
    begin
#if not CLEAN24
        if not NemhandelStatusMgt.IsFeatureEnableDatePassed() then
            exit(true);
#endif
        if not EnvironmentInformation.IsProduction() then
            exit(true);

        if Rec."Evaluation Company" then
            exit(true);

        CompanyInformation.ChangeCompany(Rec.Name);
        if not CompanyInformation.Get() then
            exit(true);

        if CompanyInformation."Registered with Nemhandel" = "Nemhandel Company Status"::Registered then begin
            Message(DeleteNemhandelRegisteredCompanyErr);
            Error('');
        end;

        exit(true);
    end;
}