#pragma warning disable AA0247
codeunit 5217 "Create Sustain. Jnl. Setup"
{
    InherentEntitlements = X;
    InherentPermissions = X;

    trigger OnRun()
    begin
        CreateJournalTemplate();
        CreateJournalBatch();
    end;

    local procedure CreateJournalTemplate()
    var
        ContosoSustainability: Codeunit "Contoso Sustainability";
    begin
        ContosoSustainability.InsertSustainabilityJournalTemplate(GeneralTemplate(), GeneralTemplateDescriptionLbl, false);
        ContosoSustainability.InsertSustainabilityJournalTemplate(RecurringTemplate(), RecurringTemplateDescriptionLbl, true);
    end;

    local procedure CreateJournalBatch()
    var
        ContosoSustainability: Codeunit "Contoso Sustainability";
        SustainabilitySetup: Codeunit "Create Sustainability Setup";
        SustainabilityNoSeries: Codeunit "Create Sustain. No Series";
    begin
        ContosoSustainability.InsertSustainabilityJournalBatch(GeneralTemplate(), DefaultBatch(), DefaultBatchDescriptionLbl, SustainabilityNoSeries.JournalNoSeries(), Enum::"Emission Scope"::" ", SustainabilitySetup.SustainabilitySourceCode());
        ContosoSustainability.InsertSustainabilityJournalBatch(RecurringTemplate(), RecurringDefaultBatch(), RecurringDefaultBatchDescriptionLbl, SustainabilityNoSeries.RecurringJournalNoSeries(), Enum::"Emission Scope"::" ", SustainabilitySetup.SustainabilitySourceCode());

        ContosoSustainability.InsertSustainabilityJournalBatch(GeneralTemplate(), Scope1Batch(), Scope1BatchDescriptionLbl, SustainabilityNoSeries.JournalNoSeries(), Enum::"Emission Scope"::"Scope 1", SustainabilitySetup.SustainabilitySourceCode());
        ContosoSustainability.InsertSustainabilityJournalBatch(GeneralTemplate(), Scope2Batch(), Scope2BatchDescriptionLbl, SustainabilityNoSeries.JournalNoSeries(), Enum::"Emission Scope"::"Scope 2", SustainabilitySetup.SustainabilitySourceCode());
        ContosoSustainability.InsertSustainabilityJournalBatch(GeneralTemplate(), Scope3Batch(), Scope3BatchDescriptionLbl, SustainabilityNoSeries.JournalNoSeries(), Enum::"Emission Scope"::"Scope 3", SustainabilitySetup.SustainabilitySourceCode());

        ContosoSustainability.InsertSustainabilityJournalBatch(RecurringTemplate(), Scope1RecurringBatch(), Scope1RecurringBatchDescriptionLbl, SustainabilityNoSeries.RecurringJournalNoSeries(), Enum::"Emission Scope"::"Scope 1", SustainabilitySetup.SustainabilitySourceCode());
        ContosoSustainability.InsertSustainabilityJournalBatch(RecurringTemplate(), Scope2RecurringBatch(), Scope2RecurringBatchDescriptionLbl, SustainabilityNoSeries.RecurringJournalNoSeries(), Enum::"Emission Scope"::"Scope 2", SustainabilitySetup.SustainabilitySourceCode());
        ContosoSustainability.InsertSustainabilityJournalBatch(RecurringTemplate(), Scope3RecurringBatch(), Scope3RecurringBatchDescriptionLbl, SustainabilityNoSeries.RecurringJournalNoSeries(), Enum::"Emission Scope"::"Scope 3", SustainabilitySetup.SustainabilitySourceCode());

        ContosoSustainability.InsertSustainabilityJournalBatch(GeneralTemplate(), WaterWasteBatch(), WaterWasteBatchDescriptionLbl, SustainabilityNoSeries.JournalNoSeries(), Enum::"Emission Scope"::"Water/Waste", SustainabilitySetup.SustainabilitySourceCode());
    end;

    procedure GeneralTemplate(): Code[10]
    begin
        exit(GeneralTemplateTok);
    end;

    procedure RecurringTemplate(): Code[10]
    begin
        exit(RecurringTemplateTok);
    end;

    procedure DefaultBatch(): Code[10]
    begin
        exit(DefaultBatchTok);
    end;

    procedure RecurringDefaultBatch(): Code[10]
    begin
        exit(RecurringDefaultBatchTok);
    end;

    procedure Scope1Batch(): Code[10]
    begin
        exit(Scope1BatchTok);
    end;

    procedure Scope2Batch(): Code[10]
    begin
        exit(Scope2BatchTok);
    end;

    procedure Scope3Batch(): Code[10]
    begin
        exit(Scope3BatchTok);
    end;

    procedure Scope1RecurringBatch(): Code[10]
    begin
        exit(Scope1RecurringBatchTok);
    end;

    procedure Scope2RecurringBatch(): Code[10]
    begin
        exit(Scope2RecurringBatchTok);
    end;

    procedure Scope3RecurringBatch(): Code[10]
    begin
        exit(Scope3RecurringBatchTok);
    end;

    procedure WaterWasteBatch(): Code[10]
    begin
        exit(WaterWasteBatchTok);
    end;

    var
        GeneralTemplateTok: Label 'GENERAL', MaxLength = 10;
        GeneralTemplateDescriptionLbl: Label 'General Emission', MaxLength = 80;
        RecurringTemplateTok: Label 'RECURRING', MaxLength = 10;
        RecurringTemplateDescriptionLbl: Label 'Recurring Emission', MaxLength = 80;
        DefaultBatchTok: Label 'DEFAULT', MaxLength = 10;
        DefaultBatchDescriptionLbl: Label 'Default Sustainability Journal Batch', MaxLength = 100;
        RecurringDefaultBatchTok: Label 'DEFAULT-RC', MaxLength = 10;
        RecurringDefaultBatchDescriptionLbl: Label 'Default Recurring Sustainability Journal Batch', MaxLength = 100;
        Scope1BatchTok: Label 'SCOPE1', MaxLength = 10;
        Scope1BatchDescriptionLbl: Label 'Scope 1 Sustainability Journal Batch', MaxLength = 100;
        Scope2BatchTok: Label 'SCOPE2', MaxLength = 10;
        Scope2BatchDescriptionLbl: Label 'Scope 2 Sustainability Journal Batch', MaxLength = 100;
        Scope3BatchTok: Label 'SCOPE3', MaxLength = 10;
        Scope3BatchDescriptionLbl: Label 'Scope 3 Sustainability Journal Batch', MaxLength = 100;
        Scope1RecurringBatchTok: Label 'SCOPE1-RC', MaxLength = 10;
        Scope1RecurringBatchDescriptionLbl: Label 'Scope 1 Recurring Sustainability Journal Batch', MaxLength = 100;
        Scope2RecurringBatchTok: Label 'SCOPE2-RC', MaxLength = 10;
        Scope2RecurringBatchDescriptionLbl: Label 'Scope 2 Recurring Sustainability Journal Batch', MaxLength = 100;
        Scope3RecurringBatchTok: Label 'SCOPE3-RC', MaxLength = 10;
        Scope3RecurringBatchDescriptionLbl: Label 'Scope 3 Recurring Sustainability Journal Batch', MaxLength = 100;
        WaterWasteBatchTok: Label 'WAT/WAS', MaxLength = 10;
        WaterWasteBatchDescriptionLbl: Label 'Water and Waste Journal Batch', MaxLength = 100;
}
