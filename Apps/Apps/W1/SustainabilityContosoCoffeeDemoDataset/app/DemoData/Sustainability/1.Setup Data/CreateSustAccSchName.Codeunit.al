#pragma warning disable AA0247
codeunit 5245 "Create Sust. Acc. Sch. Name"
{
    InherentEntitlements = X;
    InherentPermissions = X;

    trigger OnRun()
    var
        ContosoAccountSchedule: Codeunit "Contoso Account Schedule";
    begin
        ContosoAccountSchedule.InsertAccScheduleName(ESG(), EnvironmentalSocialGovernanceLbl, '');
    end;

    procedure ESG(): Code[10]
    begin
        exit(ESGTok);
    end;

    var
        ESGTok: Label 'ESG', MaxLength = 10, Locked = true;
        EnvironmentalSocialGovernanceLbl: Label 'Environmental, Social, and Governance', MaxLength = 80;
}
