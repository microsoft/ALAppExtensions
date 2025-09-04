// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------
namespace Microsoft.Sustainability.ExciseTax;

using Microsoft.Foundation.NoSeries;

codeunit 6270 "Sust. Excise Journal Mgt."
{

    local procedure InitializeDefaultTemplate(): Record "Sust. Excise Journal Template"
    var
        SustainabilityExciseJnlTemplate: Record "Sust. Excise Journal Template";
    begin
        SustainabilityExciseJnlTemplate.Validate(Name, GeneralTemplateTok);
        SustainabilityExciseJnlTemplate.Validate(Description, GeneralTemplateDescriptionLbl);
        SustainabilityExciseJnlTemplate.Insert(true);

        exit(SustainabilityExciseJnlTemplate);
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
        NoSeriesLine.Validate("Starting No.", StartingNoLbl);
        NoSeriesLine.Validate("Ending No.", EndingNoLbl);
        NoSeriesLine.Validate("Increment-by No.", 1);
        NoSeriesLine.Validate(Implementation, Enum::"No. Series Implementation"::Normal);
        NoSeriesLine.Validate("Line No.", 1000);
        NoSeriesLine.Insert(true);

        exit(NoSeriesCode);
    end;

    local procedure InitializeDefaultBatch(TemplateName: Code[10]): Record "Sust. Excise Journal Batch"
    var
        SustainabilityExciseJnlBatch: Record "Sust. Excise Journal Batch";
        NoSeriesCode: Code[20];
    begin
        NoSeriesCode := InitializeDefaultNoSeries(ExciseNoSeriesTok, ExciseNoSeriesDescriptionLbl);

        SustainabilityExciseJnlBatch.Validate("Journal Template Name", TemplateName);
        SustainabilityExciseJnlBatch.Validate(Name, DefaultBatchTok);
        SustainabilityExciseJnlBatch.Validate("No Series", NoSeriesCode);
        SustainabilityExciseJnlBatch.Validate(Description, DefaultBatchDescriptionLbl);
        SustainabilityExciseJnlBatch.Insert(true);

        exit(SustainabilityExciseJnlBatch);
    end;

    internal procedure GetDocumentNo(IsPreviousDocumentNoValid: Boolean; SustainabilityExciseJnlBatch: Record "Sust. Excise Journal Batch"; PreviousDocumentNo: Code[20]; PostingDate: Date): Code[20]
    var
        NoSeriesBatch: Codeunit "No. Series - Batch";
    begin
        if SustainabilityExciseJnlBatch."No Series" <> '' then begin
            if not IsPreviousDocumentNoValid then
                exit(NoSeriesBatch.PeekNextNo(SustainabilityExciseJnlBatch."No Series", PostingDate));
            exit(NoSeriesBatch.SimulateGetNextNo(SustainabilityExciseJnlBatch."No Series", PostingDate, PreviousDocumentNo));
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
    procedure GetASustainabilityJournalBatch(): Record "Sust. Excise Journal Batch"
    begin
        exit(SelectBatch(SelectTemplate(), ''));
    end;

    /// <summary>
    /// Select a Sustainability Excise Journal Template.
    /// If more than one Template exists, the user will be prompted to select one.
    /// If no Template exists, a default one will be created.
    /// </summary>  
    internal procedure SelectTemplate() SustainabilityExciseJnlTemplate: Record "Sust. Excise Journal Template"
    begin
        case SustainabilityExciseJnlTemplate.Count() of
            0:
                SustainabilityExciseJnlTemplate := InitializeDefaultTemplate();
            1:
                SustainabilityExciseJnlTemplate.FindFirst();
            else
                if not (Page.RunModal(Page::"Sust. Excise Jnl. Templates", SustainabilityExciseJnlTemplate) = Action::LookupOK) then
                    Error('');
        end;
    end;

    /// <summary>
    /// Open the Sustainability Excise Journal for the active Sustainability Batch. 
    /// <param name="SustainabilityExciseJnlBatch"> Specifies the Sustainability Excise Journal Batch.</param>
    /// <param name="SustainabilityExciseJnlTemplate"> Specifies the "Sustainability Excise Jnl. Template"</param>
    /// </summary>  
    internal procedure OpenJournalPageFromBatch(SustainabilityExciseJnlBatch: Record "Sust. Excise Journal Batch"; SustainabilityExciseJnlTemplate: Record "Sust. Excise Journal Template")
    var
        SustainabilityExciseJnlLine: Record "Sust. Excise Jnl. Line";
    begin
        SustainabilityExciseJnlLine.FilterGroup := 2;
        SustainabilityExciseJnlLine.SetRange("Journal Template Name", SustainabilityExciseJnlTemplate.Name);
        SustainabilityExciseJnlLine.FilterGroup := 0;

        SustainabilityExciseJnlLine."Journal Template Name" := '';
        SustainabilityExciseJnlLine."Journal Batch Name" := SustainabilityExciseJnlBatch.Name;
        Page.Run(Page::"Sustainability Excise Journal", SustainabilityExciseJnlLine);
    end;


    internal procedure SelectBatch(SustainabilityExciseJnlTemplate: Record "Sust. Excise Journal Template"; PreviousBatchName: Code[10]) SustainabilityExciseJnlBatch: Record "Sust. Excise Journal Batch"
    begin
        SustainabilityExciseJnlBatch.SetRange("Journal Template Name", SustainabilityExciseJnlTemplate.Name);

        if not SustainabilityExciseJnlBatch.Get(SustainabilityExciseJnlTemplate.Name, PreviousBatchName) then
            if not SustainabilityExciseJnlBatch.FindFirst() then
                SustainabilityExciseJnlBatch := InitializeDefaultBatch(SustainabilityExciseJnlTemplate.Name);
    end;

    var
        GeneralTemplateTok: Label 'GENERAL', MaxLength = 10;
        GeneralTemplateDescriptionLbl: Label 'The Default Excise Journal Template', MaxLength = 80;
        DefaultBatchTok: Label 'DEFAULT', MaxLength = 10;
        DefaultBatchDescriptionLbl: Label 'The Default Excise Journal Batch', MaxLength = 100;
        ExciseNoSeriesTok: Label 'EXCISE', MaxLength = 20;
        ExciseNoSeriesDescriptionLbl: Label 'Excise Journal No. Series', MaxLength = 100;
        StartingNoLbl: Label '000010', MaxLength = 20;
        EndingNoLbl: Label '999990', MaxLength = 20;
}