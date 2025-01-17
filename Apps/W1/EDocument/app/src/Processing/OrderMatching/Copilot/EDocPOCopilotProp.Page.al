namespace Microsoft.eServices.EDocument.OrderMatch.Copilot;

using Microsoft.eServices.EDocument;
using Microsoft.eServices.EDocument.OrderMatch;
using Microsoft.Purchases.Document;
using System.Telemetry;

page 6166 "E-Doc. PO Copilot Prop"
{
    Caption = 'E-Document Match Order Lines with Copilot';
    PageType = PromptDialog;
    ApplicationArea = All;
    SourceTable = "E-Document";
    SourceTableTemporary = true;
    IsPreview = true;
    Extensible = false;
    Editable = true;
    InherentPermissions = X;
    InherentEntitlements = X;
    ContextSensitiveHelpPage = 'map-edocuments-with-copilot';

    layout
    {
        area(Content)
        {
            group(EDocHeader)
            {
                ShowCaption = false;

                field("Lines matched Automatically"; AutoMatchedLinesTxt)
                {
                    ApplicationArea = All;
                    Caption = 'Auto-matched';
                    Editable = false;
                    ToolTip = 'Specifies the number of matches proposed automatically';

                    trigger OnDrillDown()
                    begin
                        if not TempEDocOrderMatches.IsEmpty() then
                            Page.Run(Page::"E-Doc. Order Match", TempEDocOrderMatches);
                    end;
                }
                field("Lines matched by Copilot"; CopilotMatchedLinesTxt)
                {
                    ApplicationArea = All;
                    Caption = 'Copilot matched';
                    Editable = false;
                    ToolTip = 'Specifies the number of matches proposed by Copilot';
                }
                field("E-Document No."; Format(Rec."Entry No"))
                {
                    ApplicationArea = All;
                    Caption = 'E-Document No.';
                    Editable = false;
                    ToolTip = 'Specifies the E-Document number';
                }
                field("Summary Text"; SummaryTxt)
                {
                    ApplicationArea = All;
                    Caption = '';
                    ShowCaption = false;
                    Editable = false;
                    StyleExpr = SummaryStyleTxt;
                    ToolTip = 'Specifies the matching summary';
                }
                field("Invoice Total Amount"; Rec."Amount Excl. VAT")
                {
                    ApplicationArea = All;
                    Caption = 'Invoice Total Amount Excl. VAT';
                    Editable = false;
                    ToolTip = 'Specifies the total invoice amount excluding VAT';
                }
                field("Matched Total Amount"; MatchedTotal)
                {
                    ApplicationArea = All;
                    Caption = 'Matched Total Amount Excl. VAT';
                    Editable = false;
                    ToolTip = 'Specifies the matched amount excluding VAT';
                }
            }
            group(Warning)
            {
                Caption = '';
                ShowCaption = false;
                Visible = (WarningTxt <> '');

                field("Warning Text"; WarningTxt)
                {
                    ApplicationArea = All;
                    Caption = '';
                    ShowCaption = false;
                    Editable = false;
                    Style = Ambiguous;
                    MultiLine = true;
                    ToolTip = 'Specifies a warning text';
                }
            }
            part(ProposalDetails; "E-Doc. PO Match Prop. Sub")
            {
                Caption = 'Match proposals';
                ShowFilter = false;
                ApplicationArea = All;
                Editable = true;
                Enabled = true;
            }
        }
    }

    actions
    {
        area(SystemActions)
        {
            systemaction(Generate)
            {
                Caption = 'Generate';
                Enabled = true;
                ToolTip = 'Generate bank account reconciliation and run auto-matching with Copilot.';

                trigger OnAction()
                begin
                    GenerateCopilotMatchProposals();

                    if WasCopilotMatchesFound() then
                        CurrPage.PromptMode := PromptMode::Content
                    else
                        CurrPage.Close();
                end;

            }
            systemaction(OK)
            {
                Caption = 'Keep it';
                ToolTip = 'Save purchase order line matching proposed by Copilot.';
            }
            systemaction(Cancel)
            {
                Caption = 'Discard it';
                ToolTip = 'Discard purchase order line matching proposed by Copilot.';
            }
        }
    }

    var
        TempPurchaseOrderLine: Record "Purchase Line" temporary;
        TempEDocumentImportedLine: Record "E-Doc. Imported Line" temporary;
        TempEDocOrderMatches: Record "E-Doc. Order Match" temporary;
        EDocLineMatching: Codeunit "E-Doc. Line Matching";
        AIMatchingImpl: Codeunit "E-Doc. PO Copilot Matching";
        FeatureTelemetry: Codeunit "Feature Telemetry";
        SummaryTxt, SummaryStyleTxt : Text;
        WarningTxt: Text;
        MatchedTotal: Decimal;
        AutoMatchedLinesTxt, CopilotMatchedLinesTxt : Text;
        AcceptedProposalCount: Decimal;
        IsCopilotReqSuccessful: Boolean;
        NumberOfEDocumentLines, NumberOfFullAutoMatchedLines, NumberOfCopilotMatchedLines : Integer;
        AutoMatchedLinesLbl: label '%1 of %2 lines (%3%)', Comment = '%1 - an integer; %2 - an integer; %3 a decimal between 0 and 100';
        AllLinesMatchedTxt: label 'All lines (100%) are matched. Review match proposals.';
        SubsetOfLinesMatchedTxt: label '%1% of lines are matched. Review match proposals.', Comment = '%1 - a decimal between 0 and 100';
        MultipleMatchTxt: Label 'Matched to multiple entries. Drill down to see more.';
        FullMatchAlreadyErr: Label 'E-Document line selection is already fully matched.';

    trigger OnQueryClosePage(CloseAction: Action): Boolean
    var
        TelemetryDimensions: Dictionary of [Text, Text];
    begin
        if CloseAction = Action::OK then
            PersistSuggestedMatches();

        AcceptedProposalCount := TempEDocOrderMatches.Count;

        TelemetryDimensions.Add('Category', AIMatchingImpl.FeatureName());
        TelemetryDimensions.Add('CopilotMatchingLines', Format(NumberOfCopilotMatchedLines));
        TelemetryDimensions.Add('AutoMatchingLines', Format(NumberOfFullAutoMatchedLines));
        TelemetryDimensions.Add('EDocumentLines', Format(NumberOfEDocumentLines));
        TelemetryDimensions.Add('AcceptedProposalCount', Format(AcceptedProposalCount));
        TelemetryDimensions.Add('UserAction', Format(CloseAction));
        FeatureTelemetry.LogUsage('0000MMG', AIMatchingImpl.FeatureName(), 'CopilotMatchingComplete', TelemetryDimensions);
    end;

    procedure WasCopilotMatchesFound(): Boolean
    begin
        exit(NumberOfCopilotMatchedLines + NumberOfFullAutoMatchedLines > 0);
    end;

    procedure IsCopilotRequestSuccessful(): Boolean
    begin
        exit(IsCopilotReqSuccessful);
    end;

    internal procedure SetGenerateMode();
    begin
        CurrPage.PromptMode := PromptMode::Generate;
    end;

    local procedure PersistSuggestedMatches()
    begin
        CurrPage.ProposalDetails.Page.GetRecords(TempEDocOrderMatches);
        EDocLineMatching.PersistsUpdates(TempEDocOrderMatches, false);
    end;

    internal procedure SetData(InputEDocument: Record "E-Document"; var InputEDocumentImportedLine: Record "E-Doc. Imported Line" temporary; var InputPurchaseOrderLine: Record "Purchase Line" temporary)
    begin
        InputEDocumentImportedLine.SetRange("Fully Matched", false);
        if InputEDocumentImportedLine.IsEmpty() then
            Error(FullMatchAlreadyErr);

        if InputEDocumentImportedLine.FindSet() then
            repeat
                TempEDocumentImportedLine.Copy(InputEDocumentImportedLine);
                TempEDocumentImportedLine.Insert();
            until InputEDocumentImportedLine.Next() = 0;

        InputPurchaseOrderLine.Reset();
        if InputPurchaseOrderLine.FindSet() then
            repeat
                TempPurchaseOrderLine.Copy(InputPurchaseOrderLine);
                TempPurchaseOrderLine.Insert();
            until InputPurchaseOrderLine.Next() = 0;

        Rec := InputEDocument;
        CurrPage.Update();
    end;

    local procedure CountFullMatches(var EDocOrderMatches: Record "E-Doc. Order Match" temporary): Integer;
    begin
        EDocOrderMatches.SetRange("Fully Matched", true);
        exit(EDocOrderMatches.Count());
    end;

    local procedure SumUnitCost(var EDocOrderMatches: Record "E-Doc. Order Match" temporary) Sum: Decimal
    var
        EDocument: Record "E-Document";
        EDocumentImportHelper: Codeunit "E-Document Import Helper";
        RoundPrecision, Discount, DiscountedUnitCost : Decimal;
    begin
        EDocOrderMatches.Reset();
        if EDocOrderMatches.FindSet() then
            repeat
                EDocument.Get(EDocOrderMatches."E-Document Entry No.");
                RoundPrecision := EDocumentImportHelper.GetCurrencyRoundingPrecision(EDocument."Currency Code");
                Discount := Round((EDocOrderMatches."E-Document Direct Unit Cost" * EDocOrderMatches."Line Discount %") / 100, RoundPrecision);
                DiscountedUnitCost := EDocOrderMatches."E-Document Direct Unit Cost" - Discount;
                Sum += EDocOrderMatches."Precise Quantity" * DiscountedUnitCost;
            until EDocOrderMatches.Next() = 0;
    end;

    local procedure CombineOneToManyInBuffer(var TempAIProposalBuffer: Record "E-Doc. PO Match Prop. Buffer" temporary; var TempLocalEdocOrderMatches: Record "E-Doc. Order Match" temporary)
    var
        TempAIProposalBuffer2: Record "E-Doc. PO Match Prop. Buffer" temporary;
        EDocLineNos: List of [Integer];
        EDocLineNo: Integer;
        Sum: Decimal;
    begin
        if TempAIProposalBuffer.FindSet() then
            repeat
                if not EDocLineNos.Contains(TempAIProposalBuffer."E-Document Line No.") then
                    EDocLineNos.Add(TempAIProposalBuffer."E-Document Line No.");
            until TempAIProposalBuffer.Next() = 0;


        foreach EDocLineNO in EDocLineNos do begin
            TempAIProposalBuffer.SetRange("E-Document Line No.", EDocLineNo);

            if TempAIProposalBuffer.FindSet() then
                repeat
                    TempLocalEdocOrderMatches.InsertMatch(TempAIProposalBuffer, TempLocalEdocOrderMatches);
                until TempAIProposalBuffer.Next() = 0;

            if TempAIProposalBuffer.Count() > 1 then begin
                TempAIProposalBuffer.CalcSums("Matched Quantity");
                Sum := TempAIProposalBuffer."Matched Quantity";
                TempAIProposalBuffer.FindFirst();
                TempAIProposalBuffer."AI Proposal" := MultipleMatchTxt;
                TempAIProposalBuffer."Matched Quantity" := Sum;
                TempAIProposalBuffer.Modify();
            end;

            TempAIProposalBuffer2 := TempAIProposalBuffer;
            TempAIProposalBuffer2.Insert();
        end;

        TempAIProposalBuffer.Reset();
        TempAIProposalBuffer.DeleteAll();
        if TempAIProposalBuffer2.FindSet() then
            repeat
                TempAIProposalBuffer := TempAIProposalBuffer2;
                TempAIProposalBuffer.Insert();
            until TempAIProposalBuffer2.Next() = 0;

    end;

    local procedure GenerateCopilotMatchProposals()
    var
        TempLocalEDocOrderMatches: Record "E-Doc. Order Match" temporary;
        TempAIProposalBuffer: Record "E-Doc. PO Match Prop. Buffer" temporary;
        Pct: Decimal;
    begin
        NumberOfEDocumentLines := TempEDocumentImportedLine.Count();

        EDocLineMatching.MatchAutomatically(Rec, TempEDocumentImportedLine, TempPurchaseOrderLine, TempEDocOrderMatches);
        NumberOfFullAutoMatchedLines := CountFullMatches(TempEDocOrderMatches);
        MatchedTotal := SumUnitCost(TempEDocOrderMatches);

        Pct := Round((NumberOfFullAutoMatchedLines / NumberOfEDocumentLines) * 100, 0.1);
        AutoMatchedLinesTxt := StrSubstNo(AutoMatchedLinesLbl, NumberOfFullAutoMatchedLines, NumberOfEDocumentLines, Pct);
        EDocLineMatching.FilterOutFullyMatchedLines(TempEDocumentImportedLine, TempPurchaseOrderLine);

        AIMatchingImpl.SetGrounding(true);
        IsCopilotReqSuccessful := AIMatchingImpl.MatchWithCopilot(TempEDocumentImportedLine, TempPurchaseOrderLine, TempAIProposalBuffer);

        CombineOneToManyInBuffer(TempAIProposalBuffer, TempLocalEDocOrderMatches);
        NumberOfCopilotMatchedLines := TempAIProposalBuffer.Count();

        MatchedTotal += AIMatchingImpl.SumUnitCostForAIMatches(TempAIProposalBuffer);

        Pct := Round((NumberOfCopilotMatchedLines / NumberOfEDocumentLines) * 100, 0.1);
        CopilotMatchedLinesTxt := StrSubstNo(AutoMatchedLinesLbl, NumberOfCopilotMatchedLines, NumberOfEDocumentLines, Pct);

        if NumberOfEDocumentLines <= (NumberOfFullAutoMatchedLines + NumberOfCopilotMatchedLines) then begin
            SummaryStyleTxt := 'Favorable';
            SummaryTxt := AllLinesMatchedTxt;
        end else begin
            Pct := Round(((NumberOfFullAutoMatchedLines + NumberOfCopilotMatchedLines) / NumberOfEDocumentLines) * 100, 0.1);
            SummaryStyleTxt := 'Ambiguous';
            SummaryTxt := StrSubstNo(SubsetOfLinesMatchedTxt, Pct);
        end;


        CurrPage.ProposalDetails.Page.Load(TempAIProposalBuffer, TempLocalEDocOrderMatches);
    end;
}