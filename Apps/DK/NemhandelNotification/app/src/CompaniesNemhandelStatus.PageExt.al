namespace Microsoft.EServices;

using Microsoft.Foundation.Company;
using Microsoft.Finance.GeneralLedger.Ledger;

pageextension 13609 "Companies Nemhandel Status" extends Companies
{
    var
        DeleteNemhandelRegisteredCompanyErr: Label 'You cannot delete a company that is registered in the Nemhandel service.';

    trigger OnDeleteRecord(): Boolean
    var
        CompanyInformation: Record "Company Information";
        GLEntry: Record "G/L Entry";
        NemhandelStatusMgt: Codeunit "Nemhandel Status Mgt.";
    begin
        if not NemhandelStatusMgt.IsSaaSProductionCompany() then
            exit(true);

        CompanyInformation.ChangeCompany(Rec.Name);
        if not CompanyInformation.Get() then
            exit(true);

        if GLEntry.ReadPermission() then begin
            GLEntry.Reset();
            GLEntry.ChangeCompany(Rec.Name);
            if GLEntry.IsEmpty() then
                exit(true);
        end;

        if CompanyInformation."Registered with Nemhandel" = "Nemhandel Company Status"::Registered then begin
            Message(DeleteNemhandelRegisteredCompanyErr);
            Error('');
        end;

        exit(true);
    end;
}