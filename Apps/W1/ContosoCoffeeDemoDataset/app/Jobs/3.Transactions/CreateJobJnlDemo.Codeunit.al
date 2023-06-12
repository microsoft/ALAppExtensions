codeunit 5117 "Create Job Jnl Demo"
{
    Permissions = tabledata "Job Journal Template" = rim,
        tabledata "Job Journal Batch" = rim,
        tabledata "Job Journal Line" = rim;

    var
        JobsDemoDataSetup: Record "Jobs Demo Data Setup";
        AdjustJobsDemoData: Codeunit "Adjust Jobs Demo Data";
        CreateJobDemoData: Codeunit "Create Job Demo Data";
        XJOBTEMPLATETok: Label 'JOB', MaxLength = 10;
        XJOBBATCHTTok: Label 'CONTOSO', MaxLength = 10;
        XJournalTok: Label 'Journal', MaxLength = 100;
        TravelDescTok: Label 'Travel to Site', MaxLength = 100;
        InstallDescTok: Label 'Install Machine', MaxLength = 100;

    trigger OnRun()
    begin
        JobsDemoDataSetup.Get();

        InitJournalTemplateAndBatch(XJOBTEMPLATETok, XJOBBATCHTTok);

        CreateJobJournalLine(CreateJobDemoData.GetDeliveryFeeTaskNo(), Enum::"Job Journal Line Type"::Resource, JobsDemoDataSetup."Resource Installer No.", 2, TravelDescTok);
        CreateJobJournalLine(CreateJobDemoData.GetDeliveryFeeTaskNo(), Enum::"Job Journal Line Type"::Resource, JobsDemoDataSetup."Resource Vehicle No.", 2, TravelDescTok);
        CreateJobJournalLine(CreateJobDemoData.GetDeliveryFeeTaskNo(), Enum::"Job Journal Line Type"::Item, JobsDemoDataSetup."Item Machine No.", 1, '');

        CreateJobJournalLine(CreateJobDemoData.GetInstallationServiceTaskNo(), Enum::"Job Journal Line Type"::Resource, JobsDemoDataSetup."Resource Installer No.", 3, InstallDescTok);
        CreateJobJournalLine(CreateJobDemoData.GetInstallationServiceTaskNo(), Enum::"Job Journal Line Type"::Item, JobsDemoDataSetup."Item Consumable No.", 1, '');
    end;

    local procedure CreateJobJournalLine(JobTaskNo: Code[20]; JobJournalLineType: Enum "Job Journal Line Type"; WhichNo: Code[20]; Quantity: Decimal; LineDescription: Text[100])
    var
        JobJournalLine: Record "Job Journal Line";
        NextLineNo: Integer;
    begin
        JobJournalLine.SetRange("Journal Template Name", XJOBTEMPLATETok);
        JobJournalLine.SetRange("Journal Batch Name", XJOBBATCHTTok);
        if JobJournalLine.FindLast() then
            NextLineNo := JobJournalLine."Line No." + 10000
        else
            NextLineNo := 10000;

        JobJournalLine.Init();
        JobJournalLine."Journal Template Name" := XJOBTEMPLATETok;
        JobJournalLine."Journal Batch Name" := XJOBBATCHTTok;
        JobJournalLine."Line No." := NextLineNo;
        JobJournalLine.Insert(true);
        JobJournalLine.Validate("Job No.", CreateJobDemoData.GetJobNo());
        JobJournalLine.Validate("Job Task No.", JobTaskNo);
        JobJournalLine.Validate("Posting Date", AdjustJobsDemoData.AdjustDate(19020601D));
        JobJournalLine.Validate("Type", JobJournalLineType);
        JobJournalLine.Validate("No.", WhichNo);
        JobJournalLine.Validate("Quantity", Quantity);
        JobJournalLine.Validate("Line Type", JobJournalLine."Line Type"::Billable);
        if LineDescription <> '' then
            JobJournalLine.Validate(Description, LineDescription);
        OnBeforeCreateJobJournalLine(JobJournalLine);
        JobJournalLine.Modify(true);
    end;

    local procedure InitJournalTemplateAndBatch(JournalTemplateName: Text; JournalBatchName: Text)
    var
        JobJournalTemplate: Record "Job Journal Template";
        JobJournalBatch: Record "Job Journal Batch";
    begin
        if not JobJournalTemplate.Get(JournalTemplateName) then begin
            JobJournalTemplate.Init();
            JobJournalTemplate.Validate(Name, JournalTemplateName);
            JobJournalTemplate.Validate(Description, AdjustJobsDemoData.TitleCase(JournalTemplateName) + ' ' + XJournalTok);
            JobJournalTemplate.Insert(true);
        end;

        if not JobJournalBatch.Get(JournalTemplateName, JournalBatchName) then begin
            JobJournalBatch.Init();
            JobJournalBatch.Validate("Journal Template Name", JournalTemplateName);
            JobJournalBatch.Validate(Name, JournalBatchName);
            JobJournalBatch.Validate(Description, AdjustJobsDemoData.TitleCase(JournalBatchName) + ' ' + XJournalTok);
            JobJournalBatch.Insert(true);
        end;
    end;

    [IntegrationEvent(false, false)]
    local procedure OnBeforeCreateJobJournalLine(JobJournalLine: Record "Job Journal Line")
    begin
    end;
}