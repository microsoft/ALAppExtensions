codeunit 4792 "Create Svc Contract Template"
{
    InherentEntitlements = X;
    InherentPermissions = X;

    trigger OnRun()
    var
        ContosoService: Codeunit "Contoso Service";
        SvcSetup: Codeunit "Create Svc Setup";
    begin
        ContosoService.InsertServiceContractTemplates(PrepaidMonthTok, true, 0, '<3M>', SvcSetup.BasicServiceContractAccountGroup());
        ContosoService.InsertServiceContractTemplates(PrepaidQuarterTok, true, 2, '<1M>', SvcSetup.BasicServiceContractAccountGroup());
        ContosoService.InsertServiceContractTemplates(NonPrepaidTok, false, 0, '<1M-1D>', SvcSetup.BasicServiceContractAccountGroup());
    end;

    var
        PrepaidMonthTok: Label 'Prepaid Contract - Monthly', MaxLength = 100;
        PrepaidQuarterTok: Label 'Prepaid Contract - Quarterly', MaxLength = 100;
        NonPrepaidTok: Label 'Non-Prepaid Contract - Monthly', MaxLength = 100;
}