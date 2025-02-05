codeunit 5451 "Create Campaign Status"
{
    InherentEntitlements = X;
    InherentPermissions = X;

    trigger OnRun()
    var
        ContosoCRM: Codeunit "Contoso CRM";
    begin
        ContosoCRM.InsertCampaignStatus(Planned(), PlannedLbl);
        ContosoCRM.InsertCampaignStatus(Approved(), ApprovedLbl);
        ContosoCRM.InsertCampaignStatus(Initiated(), InitiatedLbl);
        ContosoCRM.InsertCampaignStatus(Scheduled(), ScheduledLbl);
        ContosoCRM.InsertCampaignStatus(Started(), StartedLbl);
        ContosoCRM.InsertCampaignStatus(Done(), DoneLbl);
    end;

    procedure Planned(): Code[10]
    begin
        exit(PlanTemplateTok);
    end;

    procedure Approved(): Code[10]
    begin
        exit(AppTemplateTok);
    end;

    procedure Initiated(): Code[10]
    begin
        exit(InitTemplateTok);
    end;

    procedure Scheduled(): Code[10]
    begin
        exit(SchTemplateTok);
    end;

    procedure Started(): Code[10]
    begin
        exit(StartTemplateTok);
    end;

    procedure Done(): Code[10]
    begin
        exit(DoneTemplateTok);
    end;

    var
        PlanTemplateTok: Label '1-PLAN', MaxLength = 10;
        AppTemplateTok: Label '2-APP', MaxLength = 10;
        InitTemplateTok: Label '3-INIT', MaxLength = 10;
        SchTemplateTok: Label '4-SCH', MaxLength = 10;
        StartTemplateTok: Label '5-START', MaxLength = 10;
        DoneTemplateTok: Label '9-DONE', MaxLength = 10;
        PlannedLbl: Label 'Planned', MaxLength = 100;
        ApprovedLbl: Label 'Approved', MaxLength = 100;
        InitiatedLbl: Label 'Initiated', MaxLength = 100;
        ScheduledLbl: Label 'Scheduled', MaxLength = 100;
        StartedLbl: Label 'Started', MaxLength = 100;
        DoneLbl: Label 'Done', MaxLength = 100;
}