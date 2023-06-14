codeunit 5122 "Create Job Jnl Demo"
{
    Permissions = tabledata "Job Journal Template" = rim,
        tabledata "Job Journal Batch" = rim,
        tabledata "Job Journal Line" = rim;

    var
        JobsDemoDataSetup: Record "Jobs Demo Data Setup";
        AdjustJobsDemoData: Codeunit "Adjust Jobs Demo Data";
        CreateJobDemoTasks: Codeunit "Create Job Demo Tasks";
        XJOBTEMPLATETok: Label 'JOB', MaxLength = 10;
        XJOBBATCHTTok: Label 'CONTOSO', MaxLength = 10;
        XJournalTok: Label 'Journal', MaxLength = 100;
        TravelDescTok: Label 'Travel to Site', MaxLength = 100;
        InstallDescTok: Label 'Install Machine', MaxLength = 100;

    trigger OnRun()
    begin
        JobsDemoDataSetup.Get();

        InitJournalTemplate(XJOBTEMPLATETok);
        InitJournalBatch(XJOBTEMPLATETok, XJOBBATCHTTok);

        CreateJobJournalLine(CreateJobDemoTasks.GetDeliveryFeeTaskNo(), Enum::"Job Journal Line Type"::Resource, JobsDemoDataSetup."Resource Installer No.", 2, TravelDescTok);
        CreateJobJournalLine(CreateJobDemoTasks.GetDeliveryFeeTaskNo(), Enum::"Job Journal Line Type"::Resource, JobsDemoDataSetup."Resource Vehicle No.", 2, TravelDescTok);
        CreateJobJournalLine(CreateJobDemoTasks.GetDeliveryFeeTaskNo(), Enum::"Job Journal Line Type"::Item, JobsDemoDataSetup."Item Machine No.", 1, '');

        CreateJobJournalLine(CreateJobDemoTasks.GetInstallationServiceTaskNo(), Enum::"Job Journal Line Type"::Resource, JobsDemoDataSetup."Resource Installer No.", 3, InstallDescTok);
        CreateJobJournalLine(CreateJobDemoTasks.GetInstallationServiceTaskNo(), Enum::"Job Journal Line Type"::Item, JobsDemoDataSetup."Item Consumable No.", 1, '');
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
        JobJournalLine.Validate("Job No.", CreateJobDemoTasks.GetJobNo());
        JobJournalLine.Validate("Job Task No.", JobTaskNo);
        JobJournalLine.Validate("Posting Date", AdjustJobsDemoData.AdjustDate(19020601D));
        JobJournalLine.Validate("Type", JobJournalLineType);
        JobJournalLine.Validate("No.", WhichNo);
        JobJournalLine.Validate("Quantity", Quantity);
        JobJournalLine.Validate("Line Type", JobJournalLine."Line Type"::Billable);
        if LineDescription <> '' then
            JobJournalLine.Validate(Description, LineDescription);
        JobJournalLine.Modify(true);
    end;

    local procedure InitJournalTemplate(JournalTemplateName: Text)
    var
        JobJournalTemplate: Record "Job Journal Template";
    begin
        if JobJournalTemplate.Get(JournalTemplateName) then
            exit;
        JobJournalTemplate.Init();
        JobJournalTemplate.Validate(Name, JournalTemplateName);
        JobJournalTemplate.Validate(Description, AdjustJobsDemoData.TitleCase(JournalTemplateName) + ' ' + XJournalTok);
        JobJournalTemplate.Insert(true);
    end;

    local procedure InitJournalBatch(JournalTemplateName: Text; JournalBatchName: Text)
    var
        JobJournalBatch: Record "Job Journal Batch";
    begin
        if JobJournalBatch.Get(JournalTemplateName, JournalBatchName) then
            exit;
        JobJournalBatch.Init();
        JobJournalBatch.Validate("Journal Template Name", JournalTemplateName);
        JobJournalBatch.Validate(Name, JournalBatchName);
        JobJournalBatch.Validate(Description, AdjustJobsDemoData.TitleCase(JournalBatchName) + ' ' + XJournalTok);
        JobJournalBatch.Insert(true);
    end;
}