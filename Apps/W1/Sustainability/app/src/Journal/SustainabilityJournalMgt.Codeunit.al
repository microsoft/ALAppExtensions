namespace Microsoft.Sustainability.Journal;

using Microsoft.Foundation.NoSeries;
using Microsoft.Sustainability.Account;

codeunit 6211 "Sustainability Journal Mgt."
{
    Access = Public;

    local procedure InitializeDefaultTemplate(IsRecurring: Boolean): Record "Sustainability Jnl. Template"
    var
        SustainabilityJnlTemplate: Record "Sustainability Jnl. Template";
    begin
        if IsRecurring then begin
            SustainabilityJnlTemplate.Validate(Name, RecurringTemplateTok);
            SustainabilityJnlTemplate.Validate(Description, RecurringTemplateDescriptionLbl);
        end else begin
            SustainabilityJnlTemplate.Validate(Name, GeneralTemplateTok);
            SustainabilityJnlTemplate.Validate(Description, GeneralTemplateDescriptionLbl);
        end;

        SustainabilityJnlTemplate.Validate(Recurring, IsRecurring);
        SustainabilityJnlTemplate.Insert(true);

        exit(SustainabilityJnlTemplate);
    end;

    local procedure InitializeDefaultNoSeries(NoSeriesCode: Code[20]; Description: Text[100]): Code[20]
    var
        NoSeries: Record "No. Series";
        NoSeriesLine: Record "No. Series Line";
    begin
        if NoSeries.Get(NoSeriesCode) then
            exit(NoSeriesCode);

        NoSeries.Validate(Code, NoSeriesCode);
        NoSeries.Validate(Description, Description);
        NoSeries.Validate("Default Nos.", true);
        NoSeries.Validate("Manual Nos.", false);
        NoSeries.Insert(true);

        NoSeriesLine.Validate("Series Code", NoSeries.Code);
        NoSeriesLine.Validate("Starting No.", '000010');
        NoSeriesLine.Validate("Ending No.", '999990');
        NoSeriesLine.Validate("Increment-by No.", 1);
        NoSeriesLine.Validate(Implementation, Enum::"No. Series Implementation"::Normal);
        NoSeriesLine.Validate("Line No.", 1000);
        NoSeriesLine.Insert(true);

        exit(NoSeriesCode);
    end;

    local procedure InitializeDefaultBatch(TemplateName: Code[10]; IsRecurring: Boolean): Record "Sustainability Jnl. Batch"
    var
        SustainabilityJnlBatch: Record "Sustainability Jnl. Batch";
        NoSeriesCode: Code[20];
    begin
        if IsRecurring then
            NoSeriesCode := InitializeDefaultNoSeries(RecurringNoSeriesTok, RecurringNoSeriesDescriptionLbl)
        else
            NoSeriesCode := InitializeDefaultNoSeries(SustainabilityNoSeriesTok, SustainabilityNoSeriesDescriptionLbl);

        SustainabilityJnlBatch.Validate("Journal Template Name", TemplateName);
        SustainabilityJnlBatch.Validate(Name, DefaultBatchTok);
        SustainabilityJnlBatch.Validate("No Series", NoSeriesCode);
        SustainabilityJnlBatch.Validate(Description, DefaultBatchDescriptionLbl);
        SustainabilityJnlBatch.Insert(true);

        exit(SustainabilityJnlBatch);
    end;

    internal procedure GetDocumentNo(IsPreviousDocumentNoValid: Boolean; SustainabilityJnlBatch: Record "Sustainability Jnl. Batch"; PreviousDocumentNo: Code[20]; PostingDate: Date): Code[20]
    var
        NoSeriesBatch: Codeunit "No. Series - Batch";
    begin
        if SustainabilityJnlBatch."No Series" <> '' then begin
            if not IsPreviousDocumentNoValid then
                exit(NoSeriesBatch.PeekNextNo(SustainabilityJnlBatch."No Series", PostingDate));
            exit(NoSeriesBatch.SimulateGetNextNo(SustainabilityJnlBatch."No Series", PostingDate, PreviousDocumentNo));
        end else
            if PreviousDocumentNo = '' then
                exit('')
            else
                exit(IncStr(PreviousDocumentNo));
    end;

    /// <summary>
    /// Get a Sustainability Journal Batch.
    /// If more than one Template exists, the user will be prompted to select one.
    /// If no Template/Batch exists, a default one will be created.
    /// </summary>  
    /// <param name="IsRecurring">Specifies whether the template is recurring.</param>
    procedure GetASustainabilityJournalBatch(IsRecurring: Boolean): Record "Sustainability Jnl. Batch"
    begin
        exit(SelectBatch(SelectTemplate(IsRecurring), ''));
    end;

    /// <summary>
    /// Select a Sustainability Journal Template.
    /// If more than one Template exists, the user will be prompted to select one.
    /// If no Template exists, a default one will be created.
    /// </summary>  
    /// <param name="IsRecurring">Specifies whether the template is recurring.</param>
    internal procedure SelectTemplate(IsRecurring: Boolean) SustainabilityJnlTemplate: Record "Sustainability Jnl. Template"
    begin
        SustainabilityJnlTemplate.SetRange(Recurring, IsRecurring);

        case SustainabilityJnlTemplate.Count() of
            0:
                SustainabilityJnlTemplate := InitializeDefaultTemplate(IsRecurring);
            1:
                SustainabilityJnlTemplate.FindFirst();
            else
                if not (Page.RunModal(Page::"Sustainability Jnl. Templates", SustainabilityJnlTemplate) = Action::LookupOK) then
                    Error('');
        end;
    end;

    /// <summary>
    /// Open the Sustainability Journal for the active Sustainability Batch. 
    /// <param name="SustainabilityJnlBatch"> Specifies the Sustainability Journal Batch.</param>
    /// <param name="SustainabilityJnlTemplate"> Specifies the "Sustainability Jnl. Template"</param>
    /// </summary>  
    procedure OpenJournalPageFromBatch(SustainabilityJnlBatch: Record "Sustainability Jnl. Batch"; SustainabilityJnlTemplate: Record "Sustainability Jnl. Template")
    var
        SustainabilityJnlLine: Record "Sustainability Jnl. Line";
    begin
        SustainabilityJnlLine.FilterGroup := 2;
        SustainabilityJnlLine.SetRange("Journal Template Name", SustainabilityJnlTemplate.Name);
        SustainabilityJnlLine.FilterGroup := 0;

        SustainabilityJnlLine."Journal Template Name" := '';
        SustainabilityJnlLine."Journal Batch Name" := SustainabilityJnlBatch.Name;
        PAGE.Run(Page::"Sustainability Journal", SustainabilityJnlLine);
    end;


    internal procedure SelectBatch(SustainabilityJnlTemplate: Record "Sustainability Jnl. Template"; PreviousBatchName: Code[10]) SustainabilityJnlBatch: Record "Sustainability Jnl. Batch"
    begin
        SustainabilityJnlBatch.SetRange("Journal Template Name", SustainabilityJnlTemplate.Name);

        if not SustainabilityJnlBatch.Get(SustainabilityJnlTemplate.Name, PreviousBatchName) then
            if not SustainabilityJnlBatch.FindFirst() then
                SustainabilityJnlBatch := InitializeDefaultBatch(SustainabilityJnlTemplate.Name, SustainabilityJnlTemplate.Recurring);
    end;

    /// <summary>
    /// Emission Scope from Account Category must match the Emission Scope on the Journal Batch.
    /// Unless the Emission Scope on the Journal Batch is not set.
    /// </summary>  
    procedure CheckScopeMatchWithBatch(SustainabilityJnlLine: Record "Sustainability Jnl. Line")
    var
        SustainabilityJnlBatch: Record "Sustainability Jnl. Batch";
        SustainAccountCategory: Record "Sustain. Account Category";
        EmissionScopeErr: Label 'The Emission Scope "%1" on the Account Category does not match the Emission Scope "%2" on the Journal Batch.', Comment = '%1 = Account Category Emission Scope, %2 = Journal Batch Emission Scope';
    begin
        SustainAccountCategory.Get(SustainabilityJnlLine."Account Category");
        SustainAccountCategory.TestField("Emission Scope");

        if SustainabilityJnlBatch.Get(SustainabilityJnlLine."Journal Template Name", SustainabilityJnlLine."Journal Batch Name") then
            if (SustainabilityJnlBatch."Emission Scope" <> Enum::"Emission Scope"::" ") and (SustainabilityJnlBatch."Emission Scope" <> SustainAccountCategory."Emission Scope") then
                Error(EmissionScopeErr, SustainabilityJnlBatch."Emission Scope", SustainAccountCategory."Emission Scope");
    end;

    var
        GeneralTemplateTok: Label 'GENERAL', MaxLength = 10;
        GeneralTemplateDescriptionLbl: Label 'The Default Sustainability Journal Template', MaxLength = 80;
        RecurringTemplateTok: Label 'RECURRING', MaxLength = 10;
        RecurringTemplateDescriptionLbl: Label 'The Default Recurring Sustainability Journal', MaxLength = 100;
        DefaultBatchTok: Label 'DEFAULT', MaxLength = 10;
        DefaultBatchDescriptionLbl: Label 'The Default Sustainability Journal Batch', MaxLength = 100;
        SustainabilityNoSeriesTok: Label 'SUSTAINABILITY', MaxLength = 20;
        SustainabilityNoSeriesDescriptionLbl: Label 'Sustainability Journal No. Series', MaxLength = 100;
        RecurringNoSeriesTok: Label 'SUSTAIN RECUR', MaxLength = 20;
        RecurringNoSeriesDescriptionLbl: Label 'Recurring Sustainability Journal No. Series', MaxLength = 100;
}