namespace Microsoft.eServices.EDocument.OrderMatch.Copilot;

using System.Azure.KeyVault;
using System.AI;
using Microsoft.Purchases.Document;
using Microsoft.Purchases.Setup;
using Microsoft.eServices.EDocument.OrderMatch;
using System.Environment;
using Microsoft.eServices.EDocument;
using System.Telemetry;

codeunit 6163 "E-Doc. PO Copilot Matching"
{
    Access = Internal;
    InherentPermissions = X;
    InherentEntitlements = X;

    var
        EDocAIMatchingFunction: Codeunit "E-Doc. PO AOAI Function";
        FeatureTelemetry: Codeunit "Feature Telemetry";
        GroundResult: Boolean;
        CostDifferenceThreshold: Decimal;
        AzureOpenAIFailureErr: Label 'Sorry, something went wrong. Please try again.';
        LearnMoreUrlTxt: Label 'https://go.microsoft.com/fwlink/?linkid=2262630', Locked = true;
        MatchingCountTxt: Label 'E-Document mapping with AI returned %1 matching', Locked = true;
        NotSuccessfulRequestErr: Label 'E-Document Chat Completion Status Code: %1, Error: %2', Locked = true;
        SuccessfulRequestMsg: Label 'E-Document Chat Completion was successful', Locked = true;
        AttempToUseCopilotMsg: Label 'Attempting to use E-Docoument matching assistance ', Locked = true;
        FailedToGetPromptSecretErr: Label 'Failed to get the prompt secret from Azure Key Vault', Locked = true;
        NoLinesCouldBeMatchedMsg: Label 'No matches were found for Copilot because the conditions regarding prices or quantities have not been met.';
        FunctionCallErr: Label 'Function call to %1 failed', Comment = '%1 = Function name';

    [NonDebuggable]
    procedure MatchWithCopilot(var TempEDocumentImportedLine: Record "E-Doc. Imported Line" temporary; var TempPurchaseLine: Record "Purchase Line" temporary; var TempAIProposalBuffer: Record "E-Doc. PO Match Prop. Buffer" temporary) IsRequestSuccessful: Boolean
    var
        PurchasesPayablesSetup: Record "Purchases & Payables Setup";
        SystemPromptTxt: SecretText;
        UserPromptText, EDocumentImportLinesTxt, PurchaseLineTxt : Text;
        TaskTokenCount, PromtTokenCount : Integer;
    begin
        FeatureTelemetry.LogUptake('0000MMH', FeatureName(), Enum::"Feature Uptake Status"::Used);

        if PurchasesPayablesSetup.Get() then
            CostDifferenceThreshold := PurchasesPayablesSetup."E-Document Matching Difference";

        SystemPromptTxt := GetSystemPrompt();
        if TempEDocumentImportedLine.IsEmpty() or TempPurchaseLine.IsEmpty() then
            exit(true);

        TaskTokenCount := ApproximateTokenCount(SystemPromptTxt);

        if TempEDocumentImportedLine.FindSet() then begin
            repeat
                // Build user prompt to include the edocument line and the related purchase order lines
                BuildUserPrompt(TempEDocumentImportedLine, TempPurchaseLine, EDocumentImportLinesTxt, PurchaseLineTxt);

                // If the prompt is too large, then send it to the AI Matching service
                PromtTokenCount := TaskTokenCount + ApproximateTokenCount(EDocumentImportLinesTxt) + ApproximateTokenCount(PurchaseLineTxt);
                if PromtTokenCount > PromptSizeThreshold() then begin
                    UserPromptText := 'E-document lines:\n' + EDocumentImportLinesTxt + 'Purchase order lines:\n' + PurchaseLineTxt;
                    UserPromptText := PreparePrompt(UserPromptText);
                    IsRequestSuccessful := Match(TempAIProposalBuffer, TempEDocumentImportedLine, TempPurchaseLine, SystemPromptTxt, UserPromptText);
                    EDocumentImportLinesTxt := '';
                    PurchaseLineTxt := '';
                    UserPromptText := '';
                end;
            until TempEDocumentImportedLine.Next() = 0;

            if (EDocumentImportLinesTxt <> '') and (PurchaseLineTxt <> '') then begin
                UserPromptText := 'E-document lines:\n' + EDocumentImportLinesTxt + 'Purchase order lines:\n' + PurchaseLineTxt;

                UserPromptText := PreparePrompt(UserPromptText);
                IsRequestSuccessful := Match(TempAIProposalBuffer, TempEDocumentImportedLine, TempPurchaseLine, SystemPromptTxt, UserPromptText);
            end
            else
                Message(NoLinesCouldBeMatchedMsg);
        end;

        if GroundResult then
            GroundCopilotMatching(TempEDocumentImportedLine, TempPurchaseLine, TempAIProposalBuffer);
    end;

    procedure CostDifference(POCost: Decimal; PODiscount: Decimal; EdocCost: Decimal; EDocDiscount: Decimal): Decimal
    begin
        if PODiscount > 0 then
            POCost := POCost - (POCost * PODiscount) / 100;
        if EDocDiscount > 0 then
            EdocCost := EdocCost - (EdocCost * EDocDiscount) / 100;

        exit((Abs(POCost - EdocCost)) * 100 / POCost);
    end;

    [NonDebuggable]
    procedure Match(var TempAIProposalBuffer: Record "E-Doc. PO Match Prop. Buffer" temporary; var TempEDocumentImportedLine: Record "E-Doc. Imported Line" temporary; var TempPurchaseLine: Record "Purchase Line" temporary; CompletionPromptTxt: SecretText; UserInputTxt: Text): Boolean
    begin
        Match(CompletionPromptTxt, UserInputTxt, TempAIProposalBuffer, TempEDocumentImportedLine, TempPurchaseLine);
        exit(true)
    end;

    [NonDebuggable]
    procedure Match(CompletionPromptTxt: SecretText; UserInputTxt: Text; var TempAIProposalBuffer: Record "E-Doc. PO Match Prop. Buffer" temporary; var TempEDocumentImportedLine: Record "E-Doc. Imported Line" temporary; var TempPurchaseLine: Record "Purchase Line" temporary) NumberOfFoundMatches: Integer
    var
        AzureOpenAI: Codeunit "Azure OpenAi";
        AOAIDeployments: Codeunit "AOAI Deployments";
        AOAIChatCompletionParams: Codeunit "AOAI Chat Completion Params";
        AOAIChatMessages: Codeunit "AOAI Chat Messages";
        AOAIFunctionResponse: Codeunit "AOAI Function Response";
        AOAIOperationResponse: Codeunit "AOAI Operation Response";
    begin
        Session.LogMessage('0000MOT', AttempToUseCopilotMsg, Verbosity::Normal, DataClassification::SystemMetadata, TelemetryScope::All, 'Category', FeatureName());

        // Generate OpenAI Completion
        AzureOpenAI.SetAuthorization(Enum::"AOAI Model Type"::"Chat Completions", AOAIDeployments.GetGPT41Latest());
        AzureOpenAI.SetCopilotCapability(Enum::"Copilot Capability"::"E-Document Matching Assistance");

        AOAIChatCompletionParams.SetMaxTokens(MaxTokens());
        AOAIChatCompletionParams.SetTemperature(0);

        EDocAIMatchingFunction.SetRecords(TempEDocumentImportedLine, TempPurchaseLine);

        AOAIChatMessages.AddTool(EDocAIMatchingFunction);
        AOAIChatMessages.SetFunctionAsToolChoice(EDocAIMatchingFunction.GetName());

        AOAIChatMessages.SetPrimarySystemMessage(CompletionPromptTxt);
        AOAIChatMessages.AddUserMessage(UserInputTxt);

        AzureOpenAI.GenerateChatCompletion(AOAIChatMessages, AOAIChatCompletionParams, AOAIOperationResponse);
        if AOAIOperationResponse.IsSuccess() then begin
            Session.LogMessage('0000MOU', SuccessfulRequestMsg, Verbosity::Normal, DataClassification::SystemMetadata, TelemetryScope::All, 'Category', FeatureName());

            if AOAIOperationResponse.IsFunctionCall() then begin
                AOAIFunctionResponse := AOAIOperationResponse.GetFunctionResponses().Get(1); // There will only be one result due to tool choice
                if AOAIFunctionResponse.IsSuccess() then begin
                    TempAIProposalBuffer.Copy(AOAIFunctionResponse.GetResult(), true);
                    Session.LogMessage('0000MMJ', StrSubstNo(MatchingCountTxt, NumberOfFoundMatches), Verbosity::Normal, DataClassification::SystemMetadata, TelemetryScope::ExtensionPublisher, 'Category', FeatureName());
                end else
                    FeatureTelemetry.LogError('0000MTC', FeatureName(), 'FunctionCall', StrSubstNo(FunctionCallErr, AOAIFunctionResponse.GetFunctionName()))
            end else
                FeatureTelemetry.LogError('0000MJD', FeatureName(), 'ProcessAnswer', 'tool_calls not found in the completion answer');
        end
        else begin
            Session.LogMessage('0000MFN', StrSubstNo(NotSuccessfulRequestErr, AOAIOperationResponse.GetStatusCode(), AOAIOperationResponse.GetError()), Verbosity::Error, DataClassification::SystemMetadata, TelemetryScope::All, 'Category', FeatureName());
            Error(AzureOpenAIFailureErr);
        end;
    end;

    procedure SumUnitCostForAIMatches(var TempAIProposalBuffer: Record "E-Doc. PO Match Prop. Buffer" temporary) Sum: Decimal
    var
        EDocument: Record "E-Document";
        EDocumentImportHelper: Codeunit "E-Document Import Helper";
        RoundPrecision, Discount, DiscountedUnitCost : Decimal;
    begin
        if TempAIProposalBuffer.FindSet() then
            repeat
                EDocument.Get(TempAIProposalBuffer."E-Document Entry No.");
                RoundPrecision := EDocumentImportHelper.GetCurrencyRoundingPrecision(EDocument."Currency Code");
                Discount := Round((TempAIProposalBuffer."E-Document Direct Unit Cost" * TempAIProposalBuffer."E-Document Line Discount") / 100, RoundPrecision);
                DiscountedUnitCost := TempAIProposalBuffer."E-Document Direct Unit Cost" - Discount;
                Sum += TempAIProposalBuffer."Matched Quantity" * DiscountedUnitCost;
            until TempAIProposalBuffer.Next() = 0;
    end;

    procedure RegisterAICapability()
    var
        CopilotCapability: Codeunit "Copilot Capability";
        EnvironmentInformation: Codeunit "Environment Information";
    begin
        if not EnvironmentInformation.IsSaaSInfrastructure() then
            exit;

        if not CopilotCapability.IsCapabilityRegistered(Enum::"Copilot Capability"::"E-Document Matching Assistance") then begin
            CopilotCapability.RegisterCapability(Enum::"Copilot Capability"::"E-Document Matching Assistance", LearnMoreUrlTxt);
            FeatureTelemetry.LogUptake('0000MMI', FeatureName(), Enum::"Feature Uptake Status"::"Set up");
        end;
    end;

    local procedure PreparePrompt(Prompt: Text): Text
    var
        NewLineChar: Char;
    begin
        NewLineChar := 10;
        Prompt := Prompt.Replace('\n', NewLineChar);
        exit(Prompt);
    end;

    local procedure GroundCopilotMatching(var TempEDocumentImportedLine: Record "E-Doc. Imported Line" temporary; var TempPurchaseLine: Record "Purchase Line" temporary; var TempAIProposalBuffer: Record "E-Doc. PO Match Prop. Buffer" temporary)
    var
        TempEDocMatchesThatWasMatched: Record "E-Doc. Order Match" temporary;
        EDocLineMatching: Codeunit "E-Doc. Line Matching";
    begin
        TempAIProposalBuffer.Reset();
        if TempAIProposalBuffer.FindSet() then
            repeat
                if TempEDocumentImportedLine.Get(TempAIProposalBuffer."E-Document Entry No.", TempAIProposalBuffer."E-Document Line No.") then
                    if TempPurchaseLine.Get(Enum::"Purchase Document Type"::Order, TempAIProposalBuffer."Document Order No.", TempAIProposalBuffer."Document Line No.") then begin
                        Clear(TempEDocMatchesThatWasMatched);
                        EDocLineMatching.MatchOneToOne(TempEDocumentImportedLine, TempPurchaseLine, TempEDocMatchesThatWasMatched);
                        if (TempEDocMatchesThatWasMatched."Precise Quantity" > 0) then begin

                            TempAIProposalBuffer."Matched Quantity" := TempEDocMatchesThatWasMatched."Precise Quantity";
                            TempAIProposalBuffer.Modify();
                        end else
                            TempAIProposalBuffer.Delete();
                    end else
                        TempAIProposalBuffer.Delete();

            until TempAIProposalBuffer.Next() = 0;
    end;

    local procedure BuildUserPrompt(var TempEDocumentImportedLine: Record "E-Doc. Imported Line" temporary; var TempPurchaseLine: Record "Purchase Line" temporary; var EDocumentImportLinesTxt: Text; var PurchaseLineTxt: Text)
    var
        TempPotentialPurchaseOrderLines: Record "Purchase Line" temporary;
    begin
        // Find potential PO lines that has the same cost (within threshold) and has quantity to match
        if PotentialMatchingPurchaseOrderLine(TempEDocumentImportedLine, TempPurchaseLine, TempPotentialPurchaseOrderLines) then begin
            PrepareEDocumentLineStatement(TempEDocumentImportedLine, EDocumentImportLinesTxt);
            PreparePurchaseOrderLineStatement(TempPotentialPurchaseOrderLines, PurchaseLineTxt);
        end
    end;


    local procedure PotentialMatchingPurchaseOrderLine(var TempEDocumentImportedLine: Record "E-Doc. Imported Line" temporary; var TempPurchaseLine: Record "Purchase Line" temporary; var PurchaseOrderLines: Record "Purchase Line" temporary) PotentialMatchingPurchaseOrderLine: Boolean
    var
    begin
        if TempPurchaseLine.FindSet() then
            repeat
                if IsPOLineWithinCostThreshold(TempEDocumentImportedLine, TempPurchaseLine) and DoesLinesHaveQuantityToMatch(TempEDocumentImportedLine, TempPurchaseLine) then begin
                    PurchaseOrderLines.TransferFields(TempPurchaseLine);
                    PurchaseOrderLines.Insert();
                    PotentialMatchingPurchaseOrderLine := true;
                end
            until TempPurchaseLine.Next() = 0;
    end;

    local procedure IsPOLineWithinCostThreshold(var TempEDocumentImportedLine: Record "E-Doc. Imported Line" temporary; var TempPurchaseLine: Record "Purchase Line" temporary): Boolean
    begin
        exit(CostDifference(TempPurchaseLine."Direct Unit Cost", TempPurchaseLine."Line Discount %", TempEDocumentImportedLine."Direct Unit Cost", TempEDocumentImportedLine."Line Discount %") <= CostDifferenceThreshold);
    end;

    local procedure DoesLinesHaveQuantityToMatch(var TempEDocumentImportedLine: Record "E-Doc. Imported Line" temporary; var TempPurchaseLine: Record "Purchase Line" temporary): Boolean
    begin
        exit(((TempEDocumentImportedLine.Quantity - TempEDocumentImportedLine."Matched Quantity") > 0) and
            (((TempPurchaseLine."Quantity Received" - TempPurchaseLine."Quantity Invoiced") - TempPurchaseLine."Qty. to Invoice") > 0));
    end;

    local procedure PrepareEDocumentLineStatement(var TempEDocumentImportedLine: Record "E-Doc. Imported Line" temporary; var EDocumentImportLinesTxt: Text)
    begin
        EDocumentImportLinesTxt += 'EID: ' + Format(TempEDocumentImportedLine."Line No.");
        EDocumentImportLinesTxt += ', Description: ' + TempEDocumentImportedLine.Description;
        EDocumentImportLinesTxt += ', Unit of Measure: ' + TempEDocumentImportedLine."Unit of Measure Code";
        if TempEDocumentImportedLine."Line Discount %" <> 0 then
            EDocumentImportLinesTxt += ', Cost: ' + Format(TempEDocumentImportedLine."Direct Unit Cost" - ((TempEDocumentImportedLine."Direct Unit Cost" * TempEDocumentImportedLine."Line Discount %") / 100.0))
        else
            EDocumentImportLinesTxt += ', Cost: ' + Format(TempEDocumentImportedLine."Direct Unit Cost");
        EDocumentImportLinesTxt += '\n';
    end;

    local procedure PreparePurchaseOrderLineStatement(var PurchaseOrderLines: Record "Purchase Line" temporary; var PurchaseLineTxt: Text)
    begin
        if PurchaseOrderLines.FindSet() then
            repeat
                if not PurchaseLineTxt.Contains('PID: ' + Format(PurchaseOrderLines."Line No.")) then begin
                    PurchaseLineTxt += 'PID: ' + Format(PurchaseOrderLines."Line No.");
                    PurchaseLineTxt += ', Description: ' + PurchaseOrderLines.Description;
                    PurchaseLineTxt += ', Unit of Measure: ' + PurchaseOrderLines."Unit of Measure Code";
                    if PurchaseOrderLines."Line Discount %" <> 0 then
                        PurchaseLineTxt += ', Cost: ' + Format(PurchaseOrderLines."Direct Unit Cost" - ((PurchaseOrderLines."Direct Unit Cost" * PurchaseOrderLines."Line Discount %") / 100.0))
                    else
                        PurchaseLineTxt += ', Cost: ' + Format(PurchaseOrderLines."Direct Unit Cost");
                    PurchaseLineTxt += '\n';
                end;
            until PurchaseOrderLines.Next() = 0;
    end;

    local procedure GetSystemPrompt(): SecretText
    var
        AzureKeyVault: Codeunit "Azure Key Vault";
        Prompt: SecretText;
    begin
        if AzureKeyVault.GetAzureKeyVaultSecret('EDocumentMappingPromptV2', Prompt) then
            exit(Prompt);

        Session.LogMessage('0000MOV', FailedToGetPromptSecretErr, Verbosity::Error, DataClassification::SystemMetadata, TelemetryScope::All, 'Category', FeatureName());
    end;

    local procedure PromptSizeThreshold(): Integer
    begin
        // GPT4 which has a 32K token limit
        exit(22000);
    end;

    local procedure MaxTokens(): Integer
    begin
        // this is specifying how many tokens of the AI Model token limit are set aside (reserved) for the response
        exit(4096);
    end;

    procedure FeatureName(): Text
    begin
        exit('E-Document Purchase Order Matching with AI');
    end;

    procedure GetFunction(var Response: Codeunit "E-Doc. PO AOAI Function")
    begin
        Response := EDocAIMatchingFunction;
    end;

    procedure SetGrounding(Ground: Boolean)
    begin
        GroundResult := Ground;
    end;

    [NonDebuggable]
    local procedure ApproximateTokenCount(TextInput: SecretText): Decimal
    var
        AverageWordsPerToken: Decimal;
        TokenCount: Integer;
        WordsInInput: Integer;
    begin
        AverageWordsPerToken := 0.6; // Based on OpenAI estimate
        WordsInInput := TextInput.Unwrap().Split(' ', ',', '.', '!', '?', ';', ':', '/n').Count;
        TokenCount := Round(WordsInInput / AverageWordsPerToken, 1);
        exit(TokenCount);
    end;

    [EventSubscriber(ObjectType::Page, Page::"Copilot AI Capabilities", OnRegisterCopilotCapability, '', false, false)]
    local procedure HandleOnRegisterCopilotCapability()
    begin
        RegisterAICapability();
    end;
}