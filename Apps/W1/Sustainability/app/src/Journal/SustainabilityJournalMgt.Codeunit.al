namespace Microsoft.Sustainability.Journal;

using Microsoft.Foundation.NoSeries;
using Microsoft.Sustainability.Account;

codeunit 6211 "Sustainability Journal Mgt."
{
    Access = Public;
    Permissions =
        tabledata "Sustainability Jnl. Template" = ri,
        tabledata "Sustainability Jnl. Batch" = ri,
        tabledata "No. Series" = i;

    /// <summary>
    /// Insert the default Sustainability Journal Template, with Primary Key set to `GENERAL`.
    /// Should only be used to initialize a new environment.
    /// </summary>
    /// <param name="IsRecurring">Specifies whether the default template is recurring.</param>
    /// <returns>The created template.</returns>
    /// <error>If the default template already exists.</error>
    procedure InitializeDefaultTemplate(IsRecurring: Boolean): Record "Sustainability Jnl. Template"
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
        NoSeriesLine.Validate("Allow Gaps in Nos.", false);
        NoSeriesLine.Validate("Line No.", 1000);
        NoSeriesLine.Insert(true);

        exit(NoSeriesCode);
    end;

    /// <summary>
    /// Insert the default Sustainability Journal Batch, with Primary Key set to `DEFAULT`.
    /// Should only be used to initialize a new environment.
    /// </summary>
    /// <param name="TemplateName">Specifies the name of the template to initialize the Batch with.</param>
    /// <param name="IsRecurring">Specifies whether the default batch is recurring.</param>
    /// <returns>The created batch.</returns>
    /// <error>If the default batch already exists.</error>
    procedure InitializeDefaultBatch(TemplateName: Code[10]; IsRecurring: Boolean): Record "Sustainability Jnl. Batch"
    var
        SustainabilityJnlBatch: Record "Sustainability Jnl. Batch";
        NoSeriesCode: Code[20];
    begin
        if IsRecurring then
            NoSeriesCode := InitializeDefaultNoSeries(GetRecurringNoSeriesCode(), RecurringNoSeriesDescriptionLbl)
        else
            NoSeriesCode := InitializeDefaultNoSeries(GetSustainabilityNoSeriesCode(), SustainabilityNoSeriesDescriptionLbl);

        SustainabilityJnlBatch.Validate("Journal Template Name", TemplateName);
        SustainabilityJnlBatch.Validate(Name, DefaultBatchTok);
        SustainabilityJnlBatch.Validate("No Series", NoSeriesCode);
        SustainabilityJnlBatch.Validate(Description, DefaultBatchDescriptionLbl);
        SustainabilityJnlBatch.Insert(true);

        exit(SustainabilityJnlBatch);
    end;

    procedure GetSustainabilityNoSeriesCode(): Code[20]
    begin
        exit(SustainabilityNoSeriesTok);
    end;

    procedure GetRecurringNoSeriesCode(): Code[20]
    begin
        exit(RecurringNoSeriesTok);
    end;

    internal procedure GetDocumentNo(IsPreviousDocumentNoValid: Boolean; SustainabilityJnlBatch: Record "Sustainability Jnl. Batch"; PreviousDocumentNo: Code[20]; PostingDate: Date): Code[20]
    var
        NoSeriesLine: Record "No. Series Line";
        NoSeriesMgt: Codeunit NoSeriesManagement;
    begin
        if SustainabilityJnlBatch."No Series" <> '' then begin
            if not IsPreviousDocumentNoValid then
                exit(NoSeriesMgt.TryGetNextNo(SustainabilityJnlBatch."No Series", PostingDate))
            else begin
                NoSeriesMgt.FindNoSeriesLine(NoSeriesLine, SustainabilityJnlBatch."No Series", PostingDate);
                // TODO: need to check if the ending is integer otherwise runtime error
                NoSeriesMgt.IncrementNoText(PreviousDocumentNo, NoSeriesLine."Increment-by No.");
                exit(PreviousDocumentNo);
            end
        end else
            if PreviousDocumentNo = '' then
                exit('')
            else
                exit(IncStr(PreviousDocumentNo));
    end;

    /// <summary>
    /// Get a Sustainability Journal Batch.
    /// If more than one Template exists, the user will be prompted to select one.
    /// If no Template exists, a default one will be created.
    /// </summary>  
    /// <param name="IsRecurring">Specifies whether the template is recurring.</param>
    procedure GetASustainabilityJournalBatch(IsRecurring: Boolean): Record "Sustainability Jnl. Batch"
    var
        SustainabilityJnlTemplate: Record "Sustainability Jnl. Template";
        SustainabilityJnlBatch: Record "Sustainability Jnl. Batch";
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

        SustainabilityJnlBatch.SetRange("Journal Template Name", SustainabilityJnlTemplate.Name);

        if not SustainabilityJnlBatch.FindFirst() then
            SustainabilityJnlBatch := InitializeDefaultBatch(SustainabilityJnlTemplate.Name, IsRecurring);

        exit(SustainabilityJnlBatch);
    end;

    /// <summary>
    /// Emission Scope from Account Category must match the Emission Scope on the Journal Batch.
    /// Unless the Emission Scope on the Journal Batch is not set.
    /// </summary>  
    procedure CheckScopeMatchWithBatch(SustainabilityJnlLine: Record "Sustainability Jnl. Line")
    var
        SustainabilityJnlBatch: Record "Sustainability Jnl. Batch";
        SustainAccountCategory: Record "Sustain. Account Category";
    begin
        SustainAccountCategory.Get(SustainabilityJnlLine."Account Category");
        SustainAccountCategory.TestField("Emission Scope");

        SustainabilityJnlBatch.Get(SustainabilityJnlLine."Journal Template Name", SustainabilityJnlLine."Journal Batch Name");
        if SustainabilityJnlBatch."Emission Scope" <> Enum::"Emission Scope"::" " then
            SustainAccountCategory.TestField("Emission Scope", SustainabilityJnlBatch."Emission Scope", ErrorInfo.Create());
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