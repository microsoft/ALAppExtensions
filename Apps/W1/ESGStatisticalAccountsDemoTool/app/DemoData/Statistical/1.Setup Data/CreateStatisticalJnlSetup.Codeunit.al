#pragma warning disable AA0247
codeunit 5270 "Create Statistical Jnl. Setup"
{
    InherentEntitlements = X;
    InherentPermissions = X;

    trigger OnRun()
    begin
        CreateJournalBatch();
    end;

    local procedure CreateJournalBatch()
    var
        ContosoStatistical: Codeunit "Contoso Statistical Account";
    begin
        ContosoStatistical.InsertStatisticalJournalBatch(BlankTemplate(), ESGBatch(), ESGBatchDescriptionLbl);
    end;

    procedure BlankTemplate(): Code[10]
    begin
        exit(BlankTemplateTok);
    end;

    procedure ESGBatch(): Code[10]
    begin
        exit(ESGBatchTok);
    end;

    var
        BlankTemplateTok: Label '', MaxLength = 10, Locked = true;
        ESGBatchTok: Label 'ESG', MaxLength = 10, Locked = true;
        ESGBatchDescriptionLbl: Label 'Environmental, Social, and Governance', MaxLength = 100;
}
