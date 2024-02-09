namespace Microsoft.EServices;

using Microsoft.Foundation.Company;

pageextension 13609 "Companies Nemhandel Status" extends Companies
{
    var
        DeleteNemhandelRegisteredCompanyErr: Label 'You cannot delete a company that is registered in the Nemhandel service.';

    trigger OnDeleteRecord(): Boolean
    var
        CompanyInformation: Record "Company Information";
        NemhandelStatusMgt: Codeunit "Nemhandel Status Mgt.";
    begin
        if not NemhandelStatusMgt.IsSaaSProductionCompany() then
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