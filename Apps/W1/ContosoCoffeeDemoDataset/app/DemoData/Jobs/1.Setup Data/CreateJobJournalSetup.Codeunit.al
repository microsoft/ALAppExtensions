codeunit 5197 "Create Job Journal Setup"
{
    InherentEntitlements = X;
    InherentPermissions = X;

    trigger OnRun()
    var
        ContosoJob: Codeunit "Contoso Job";
    begin
        ContosoJob.InsertJobJournalTemplate(JobTemplate(), JobJournalTemplateDescriptionLbl);
        ContosoJob.InsertJobJournalBatch(JobTemplate(), ContosoBatch(), JobBatchDescriptionLbl);
    end;

    var
        JobTemplateTok: Label 'PROJECT', MaxLength = 10;
        ContosoJobBatchTok: Label 'CONTOSO', MaxLength = 10;
        JobJournalTemplateDescriptionLbl: Label 'Project Journal', MaxLength = 80;
        JobBatchDescriptionLbl: Label 'Project Batch', MaxLength = 100;

    procedure JobTemplate(): Code[10]
    begin
        exit(JobTemplateTok)
    end;

    procedure ContosoBatch(): Code[10]
    begin
        exit(ContosoJobBatchTok)
    end;
}