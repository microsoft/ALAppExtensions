// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------
namespace Microsoft.eServices.EDocument.Processing.AI;

using Microsoft.eServices.EDocument.Processing.Import;
using Microsoft.eServices.EDocument.Processing.Import.Purchase;
using Microsoft.Purchases.Document;
using Microsoft.Purchases.History;
using System.AI;
using System.Azure.KeyVault;
using System.Telemetry;

codeunit 6177 "E-Doc. Historical Matching" implements "AOAI Function", IEDocAISystem
{
    Access = Internal;
    TableNo = "E-Document Purchase Line";
    EventSubscriberInstance = Manual;
    InherentPermissions = X;
    InherentEntitlements = X;

    var
        TempEDocLineMatchBuffer: Record "EDoc Line Match Buffer" temporary;
        TempHistoricalMatchBuffer: Record "EDoc Historical Match Buffer" temporary;
        EDocSimilarDescriptions: Codeunit "E-Doc. Similar Descriptions";
        EDocumentNo: Integer;

    trigger OnRun()
    var
        PurchInvLine: Record "Purch. Inv. Line";
        EDocumentAIProcessor: Codeunit "E-Doc. AI Tool Processor";
        Response: Codeunit "AOAI Operation Response";
        FunctionResponse: Codeunit "AOAI Function Response";
        FeatureTelemetry: Codeunit "Feature Telemetry";
        EDocImpSessionTelemetry: Codeunit "E-Doc. Imp. Session Telemetry";
        EDocPurchaseHistMapping: Codeunit "E-Doc. Purchase Hist. Mapping";
        MistakesCount: Integer;
        MatchedCount: Integer;
        TelemetryDimensions: Dictionary of [Text, Text];
        AIHistoricalMatchEventTok: Label 'Historical Matching AI Match', Locked = true;
    begin
        if not PrepareHistoricalData(Rec) then
            exit;

        if not EDocumentAIProcessor.Setup(this) then
            exit;
        if not EDocumentAIProcessor.Process(CreateUserMessage(Rec), Response) then
            exit;

        foreach FunctionResponse in Response.GetFunctionResponses() do begin
            TempEDocLineMatchBuffer := FunctionResponse.GetResult();
            OnGetHistoricalMatchFunctionResponse(TempEDocLineMatchBuffer);

            if not Rec.Get(Rec."E-Document Entry No.", TempEDocLineMatchBuffer."Line No.") then begin
                MistakesCount += 1;
                continue;
            end;

            if TryValidateHistoricalMatchingRecord(TempEDocLineMatchBuffer) then begin
                MatchedCount += 1;

                // Update the purchase line with historical data
                PurchInvLine.GetBySystemId(TempEDocLineMatchBuffer."Matched PurchInvLine SystemId");
                EDocPurchaseHistMapping.UpdateMissingLineValuesFromHistory(PurchInvLine, Rec, TempEDocLineMatchBuffer."Historical Matching Reasoning");
                Rec.Modify(true);

                EDocImpSessionTelemetry.SetLineBool(Rec.SystemId, AIHistoricalMatchEventTok, true);
            end;
        end;

        TelemetryDimensions.Add('Total lines', Format(Rec.Count()));
        TelemetryDimensions.Add('Proposed matches', Format(Response.GetFunctionResponses().Count));
        TelemetryDimensions.Add('Matched lines', Format(MatchedCount));
        TelemetryDimensions.Add('Processing mistakes', Format(MistakesCount));
        FeatureTelemetry.LogUsage('0000PUP', EDocumentAIProcessor.GetEDocumentMatchingAssistanceName(), GetFeatureName(), TelemetryDimensions);
    end;

    local procedure PrepareHistoricalData(var EDocumentPurchaseLine: Record "E-Document Purchase Line"): Boolean
    var
        EDocumentPurchaseHeader: Record "E-Document Purchase Header";
        EDocHistoricalMatchingSetup: Record "EDoc Historical Matching Setup";
        TempPurchInvLine: Record "Purch. Inv. Line" temporary;
        VendorNo: Code[20];
    begin
        if not EDocumentPurchaseLine.FindFirst() then
            exit(false);

        // Get vendor from header
        EDocumentPurchaseHeader.SetRange("E-Document Entry No.", EDocumentPurchaseLine."E-Document Entry No.");
        if not EDocumentPurchaseHeader.FindFirst() then
            exit(false);
        VendorNo := EDocumentPurchaseHeader."[BC] Vendor No.";

        // Get setup
        EDocHistoricalMatchingSetup.GetSetup();

        // Ensure we only process unmatched lines
        EDocumentPurchaseLine.SetRange("[BC] Purchase Type No.", '');
        if not EDocumentPurchaseLine.FindSet() then
            exit(false);

        // Load historical data
        LoadHistoricalDataIntoTempTable(TempPurchInvLine, VendorNo, EDocHistoricalMatchingSetup);
        if TempPurchInvLine.IsEmpty() then
            exit(false);

        // Collect potential matches
        Clear(TempHistoricalMatchBuffer);
        CollectPotentialMatches(EDocumentPurchaseLine, TempPurchInvLine, EDocHistoricalMatchingSetup, VendorNo);

        exit(not TempHistoricalMatchBuffer.IsEmpty());
    end;

    local procedure LoadHistoricalDataIntoTempTable(var TempPurchInvLine: Record "Purch. Inv. Line" temporary; VendorNo: Code[20]; EDocHistoricalMatchingSetup: Record "EDoc Historical Matching Setup")
    var
        PurchInvLine: Record "Purch. Inv. Line";
        OneYearAgoDate: Date;
        RecordCount: Integer;
        MaxHistoricalRecords: Integer;
    begin
        OneYearAgoDate := CalcDate('<-1Y>', Today);
        MaxHistoricalRecords := 5000; // Limit historical data to prevent performance issues

        PurchInvLine.Reset();
        PurchInvLine.ReadIsolation(IsolationLevel::ReadUncommitted);

        if EDocHistoricalMatchingSetup."Vendor Matching Scope" = EDocHistoricalMatchingSetup."Vendor Matching Scope"::"Same Vendor" then
            PurchInvLine.SetRange("Buy-from Vendor No.", VendorNo);

        PurchInvLine.SetFilter("Posting Date", '>=%1', OneYearAgoDate);
        PurchInvLine.SetFilter(Type, '<>%1', PurchInvLine.Type::" ");

        if PurchInvLine.FindSet() then begin
            TempPurchInvLine.Copy(PurchInvLine);
            repeat
                TempPurchInvLine := PurchInvLine;
                TempPurchInvLine.Insert();
                RecordCount += 1;
            until (PurchInvLine.Next() = 0) or (RecordCount >= MaxHistoricalRecords);
        end;
    end;

    local procedure CollectPotentialMatches(var EDocumentPurchaseLine: Record "E-Document Purchase Line"; var TempPurchInvLine: Record "Purch. Inv. Line" temporary; EDocHistoricalMatchingSetup: Record "EDoc Historical Matching Setup"; VendorNo: Code[20])
    var
        UseSimilarTerms: Boolean;
    begin
        UseSimilarTerms := EDocHistoricalMatchingSetup."Line Matching Scope" = EDocHistoricalMatchingSetup."Line Matching Scope"::"Similar Product Descriptions";

        if EDocumentPurchaseLine.FindSet() then
            repeat
                // Search for exact Product Code matches
                if EDocumentPurchaseLine."Product Code" <> '' then
                    SearchAndAddMatches(EDocumentPurchaseLine, TempPurchInvLine, 'Product Code', EDocumentPurchaseLine."Product Code", 1.0, VendorNo);

                // Search for exact Description matches
                if EDocumentPurchaseLine.Description <> '' then
                    SearchAndAddMatches(EDocumentPurchaseLine, TempPurchInvLine, 'Description', EDocumentPurchaseLine.Description, 0.9, VendorNo);

                // Search for similar descriptions if enabled using the new AI system
                if UseSimilarTerms and (EDocumentPurchaseLine.Description <> '') then
                    ProcessSimilarDescriptionsWithAI(EDocumentPurchaseLine, TempPurchInvLine, VendorNo);
            until EDocumentPurchaseLine.Next() = 0;
    end;

    local procedure ProcessSimilarDescriptionsWithAI(var EDocumentPurchaseLine: Record "E-Document Purchase Line"; var TempPurchInvLine: Record "Purch. Inv. Line" temporary; VendorNo: Code[20])
    var
        SimilarDescriptions: List of [Text];
        Description: Text;
    begin
        // Get similar descriptions using the simplified API
        SimilarDescriptions := EDocSimilarDescriptions.GetSimilarDescriptions(EDocumentPurchaseLine.Description);

        // Search for matches using each similar description
        foreach Description in SimilarDescriptions do begin
            Description := Description.Trim();
            if (Description <> '') and (StrLen(Description) > 3) then
                SearchAndAddMatches(EDocumentPurchaseLine, TempPurchInvLine, 'Similar Description', Description, 0.7, VendorNo);
        end;
    end;

    local procedure SearchAndAddMatches(var EDocumentPurchaseLine: Record "E-Document Purchase Line"; var TempPurchInvLine: Record "Purch. Inv. Line" temporary; MatchType: Text; SearchValue: Text; BaseConfidence: Decimal; VendorNo: Code[20])
    var
        PurchInvHeader: Record "Purch. Inv. Header";
        MatchReason: Text;
        Confidence: Decimal;
        MatchCount: Integer;
        MatchReasonLbl: Label 'Matched on %1: %2', Comment = '%1 = Match Type, %2 = Search Value', Locked = true;
    begin
        if SearchValue = '' then
            exit;

        // MatchCount limits total historical matches added per search operation to 5
        // This works in conjunction with IsSimilarHistoricalRecordTracked which prevents
        // adding similar historical records when 5 similar ones already exist
        // Together they ensure quality over quantity in historical matching
        MatchCount := 0;
        TempPurchInvLine.Reset();
        case MatchType of
            'Product Code':
                TempPurchInvLine.SetRange("No.", SearchValue);
            'Description':
                TempPurchInvLine.SetRange(Description, SearchValue);
            'Similar Description':
                TempPurchInvLine.SetFilter(Description, '%1', '@*' + SearchValue + '*');
        end;

        if TempPurchInvLine.FindSet() then
            repeat
                if not IsSimilarHistoricalRecordTracked(EDocumentPurchaseLine."Line No.", TempPurchInvLine) then
                    if PurchInvHeader.Get(TempPurchInvLine."Document No.") then begin
                        if PurchInvHeader."Buy-from Vendor No." = VendorNo then
                            Confidence := BaseConfidence
                        else
                            // Apply confidence penalty for cross-vendor matches
                            // Reduce confidence by 20% when historical match is from different vendor
                            // This reflects lower reliability of item mappings across vendors
                            Confidence := BaseConfidence * 0.8;

                        MatchReason := StrSubstNo(MatchReasonLbl, MatchType, SearchValue);
                        AddHistoricalMatchFromPurchInvLine(EDocumentPurchaseLine."Line No.", TempPurchInvLine, MatchReason, Confidence);
                        MatchCount += 1;
                    end;
            until (TempPurchInvLine.Next() = 0) or (MatchCount >= 5);
    end;

    local procedure IsSimilarHistoricalRecordTracked(LineNo: Integer; var PurchInvLine: Record "Purch. Inv. Line"): Boolean
    var
        TempHistoryCheck: Record "EDoc Historical Match Buffer" temporary;
        SimilarRecordCount: Integer;
        BufferQuantityGroup: Text[20];
    begin
        TempHistoryCheck.Copy(TempHistoricalMatchBuffer, true);
        TempHistoryCheck.SetRange("Line No.", LineNo);
        TempHistoryCheck.SetRange("Historical Line SystemId", PurchInvLine."SystemId");
        if not TempHistoryCheck.IsEmpty() then
            exit(true);

        BufferQuantityGroup := GetQuantityGroup(PurchInvLine.Quantity);
        TempHistoryCheck.Reset();
        TempHistoryCheck.SetRange("Line No.", LineNo);

        if TempHistoryCheck.FindSet() then
            repeat
                if IsSimilarVariant(
                    PurchInvLine.Quantity, PurchInvLine."Unit of Measure Code", PurchInvLine."Deferral Code",
                    PurchInvLine."Shortcut Dimension 1 Code", PurchInvLine."Shortcut Dimension 2 Code",
                    TempHistoryCheck.Quantity, TempHistoryCheck."Unit of Measure", TempHistoryCheck."Deferral Code",
                    TempHistoryCheck."Shortcut Dimension 1 Code", TempHistoryCheck."Shortcut Dimension 2 Code",
                    BufferQuantityGroup, PurchInvLine."Posting Date", TempHistoryCheck."Posting Date") then
                    SimilarRecordCount += 1;
            until TempHistoryCheck.Next() = 0;

        // Return true if 5 or more similar variants found (same limit as MatchCount in SearchAndAddMatches)
        // This prevents adding redundant similar matches and maintains match quality
        exit(SimilarRecordCount >= 5);
    end;

    local procedure AddHistoricalMatchFromPurchInvLine(LineNo: Integer; var PurchInvLine: Record "Purch. Inv. Line"; MatchReason: Text; Confidence: Decimal)
    begin
        TempHistoricalMatchBuffer.Init();
        TempHistoricalMatchBuffer."Line No." := LineNo;
        TempHistoricalMatchBuffer."Historical Line SystemId" := PurchInvLine."SystemId";
        TempHistoricalMatchBuffer."Posting Date" := PurchInvLine."Posting Date";
        TempHistoricalMatchBuffer."Vendor No." := PurchInvLine."Buy-from Vendor No.";
        TempHistoricalMatchBuffer."Purchase Type" := PurchInvLine.Type;
        TempHistoricalMatchBuffer."Purchase Type No." := PurchInvLine."No.";
        TempHistoricalMatchBuffer."Product Code" := CopyStr(PurchInvLine."No.", 1, MaxStrLen(TempHistoricalMatchBuffer."Product Code"));
        TempHistoricalMatchBuffer.Description := CopyStr(PurchInvLine.Description, 1, MaxStrLen(TempHistoricalMatchBuffer.Description));
        TempHistoricalMatchBuffer."Match Reason" := CopyStr(MatchReason, 1, MaxStrLen(TempHistoricalMatchBuffer."Match Reason"));
        TempHistoricalMatchBuffer."Confidence Score" := Confidence;
        TempHistoricalMatchBuffer."Is E-Document History" := false;
        TempHistoricalMatchBuffer.Quantity := PurchInvLine.Quantity;
        TempHistoricalMatchBuffer."Unit of Measure" := PurchInvLine."Unit of Measure Code";
        TempHistoricalMatchBuffer."Shortcut Dimension 1 Code" := PurchInvLine."Shortcut Dimension 1 Code";
        TempHistoricalMatchBuffer."Shortcut Dimension 2 Code" := PurchInvLine."Shortcut Dimension 2 Code";
        TempHistoricalMatchBuffer."Deferral Code" := PurchInvLine."Deferral Code";
        if TempHistoricalMatchBuffer.Insert() then;
    end;

    local procedure GetQuantityGroup(Quantity: Decimal): Text[20]
    begin
        if Quantity = 0 then
            exit('Zero');
        if Quantity <= 1 then
            exit('Single');
        if Quantity <= 10 then
            exit('Small');
        if Quantity <= 100 then
            exit('Medium');
        exit('Large');
    end;

    local procedure IsSimilarVariant(
        Quantity1: Decimal; UOM1: Code[10]; Deferral1: Code[10]; Dim1Code1: Code[20]; Dim2Code1: Code[20];
        Quantity2: Decimal; UOM2: Code[10]; Deferral2: Code[10]; Dim1Code2: Code[20]; Dim2Code2: Code[20];
        BufferQuantityGroup: Text[20]; PostingDate1: Date; PostingDate2: Date): Boolean
    var
        QuantityGroup1: Text[20];
        QuantityGroup2: Text[20];
    begin
        // Different posting dates mean different records, regardless of other similarities
        if PostingDate1 <> PostingDate2 then
            exit(false);

        QuantityGroup1 := GetQuantityGroup(Quantity1);
        QuantityGroup2 := GetQuantityGroup(Quantity2);
        if (QuantityGroup1 <> BufferQuantityGroup) or (QuantityGroup2 <> BufferQuantityGroup) then
            exit(false);

        if UOM1 <> UOM2 then
            exit(false);
        if Deferral1 <> Deferral2 then
            exit(false);
        if Dim1Code1 <> Dim1Code2 then
            exit(false);
        if Dim2Code1 <> Dim2Code2 then
            exit(false);

        exit(true);
    end;

    [TryFunction]
    local procedure TryValidateHistoricalMatchingRecord(var TempBuffer: Record "EDoc Line Match Buffer" temporary)
    var
        PurchaseLine: Record "Purch. Inv. Line";
        PurchInvLineNotFoundErr: Label 'The historical purchase invoice line with SystemId %1 could not be found for line %2.', Comment = '%1 = SystemId, %2 = Line No.';
    begin
        if IsNullGuid(TempBuffer."Matched PurchInvLine SystemId") then
            exit;

        if PurchaseLine.GetBySystemId(TempBuffer."Matched PurchInvLine SystemId") then
            exit
        else
            Error(PurchInvLineNotFoundErr, TempBuffer."Matched PurchInvLine SystemId", TempBuffer."Line No.");
    end;

    local procedure CreateUserMessage(var EDocumentPurchaseLine: Record "E-Document Purchase Line"): Text
    var
        EDocHistoricalMatchingSetup: Record "EDoc Historical Matching Setup";
        UserMessage: JsonObject;
        CurrentLinesJson: JsonArray;
        HistoricalMatchesJson: JsonArray;
        MatchingSetup: JsonObject;
        UserMessageTxt: Text;
    begin
        // Store document number for later use
        EDocumentNo := EDocumentPurchaseLine."E-Document Entry No.";

        // Build JSON structures
        CurrentLinesJson := BuildEDocumentPurchaseLinesJson(EDocumentPurchaseLine);
        HistoricalMatchesJson := BuildHistoricalMatchesJson();
        EDocHistoricalMatchingSetup.GetSetup();
        MatchingSetup.Add('vendorMatchingScope', Format(EDocHistoricalMatchingSetup."Vendor Matching Scope"));
        MatchingSetup.Add('lineMatchingScope', Format(EDocHistoricalMatchingSetup."Line Matching Scope"));

        // Build the user message
        UserMessage.Add('currentLines', CurrentLinesJson);
        UserMessage.Add('historicalMatches', HistoricalMatchesJson);
        UserMessage.Add('matchingSetup', MatchingSetup);
        UserMessage.WriteTo(UserMessageTxt);
        
        OnUserMessageCreated(UserMessageTxt);
        exit(UserMessageTxt);
    end;

    local procedure BuildEDocumentPurchaseLinesJson(var EDocumentPurchaseLine: Record "E-Document Purchase Line"): JsonArray
    var
        CurrentLinesJson: JsonArray;
        LineJson: JsonObject;
    begin
        if EDocumentPurchaseLine.FindSet() then
            repeat
                Clear(LineJson);
                LineJson.Add('lineNo', EDocumentPurchaseLine."Line No.");
                LineJson.Add('productCode', EDocumentPurchaseLine."Product Code");
                LineJson.Add('description', EDocumentPurchaseLine.Description);
                LineJson.Add('quantity', EDocumentPurchaseLine.Quantity);
                LineJson.Add('unitOfMeasure', EDocumentPurchaseLine."Unit of Measure");
                LineJson.Add('unitPrice', EDocumentPurchaseLine."Unit Price");
                CurrentLinesJson.Add(LineJson);
            until EDocumentPurchaseLine.Next() = 0;

        exit(CurrentLinesJson);
    end;

    local procedure BuildHistoricalMatchesJson(): JsonArray
    var
        HistoricalMatches: JsonArray;
        LineMatches: JsonObject;
        MatchArray: JsonArray;
        LineMatch: JsonObject;
        CurrentLineNo: Integer;
    begin
        if not TempHistoricalMatchBuffer.FindSet() then
            exit(HistoricalMatches);

        CurrentLineNo := 0;

        repeat
            if CurrentLineNo <> TempHistoricalMatchBuffer."Line No." then begin
                if CurrentLineNo <> 0 then begin
                    LineMatches.Add('matches', MatchArray);
                    HistoricalMatches.Add(LineMatches);
                end;

                CurrentLineNo := TempHistoricalMatchBuffer."Line No.";
                Clear(LineMatches);
                Clear(MatchArray);
                LineMatches.Add('lineNo', CurrentLineNo);
            end;

            Clear(LineMatch);
            LineMatch.Add('historicalLineSystemId', TempHistoricalMatchBuffer."Historical Line SystemId");
            LineMatch.Add('postingDate', TempHistoricalMatchBuffer."Posting Date");
            LineMatch.Add('vendorNo', TempHistoricalMatchBuffer."Vendor No.");
            LineMatch.Add('purchaseType', Format(TempHistoricalMatchBuffer."Purchase Type"));
            LineMatch.Add('itemNo', TempHistoricalMatchBuffer."Purchase Type No.");
            LineMatch.Add('productCode', TempHistoricalMatchBuffer."Product Code");
            LineMatch.Add('description', TempHistoricalMatchBuffer.Description);
            LineMatch.Add('matchReason', TempHistoricalMatchBuffer."Match Reason");
            LineMatch.Add('confidenceScore', TempHistoricalMatchBuffer."Confidence Score");
            LineMatch.Add('quantity', TempHistoricalMatchBuffer.Quantity);
            LineMatch.Add('unitOfMeasure', TempHistoricalMatchBuffer."Unit of Measure");
            LineMatch.Add('deferralCode', TempHistoricalMatchBuffer."Deferral Code");
            MatchArray.Add(LineMatch);
        until TempHistoricalMatchBuffer.Next() = 0;

        if CurrentLineNo <> 0 then begin
            LineMatches.Add('matches', MatchArray);
            HistoricalMatches.Add(LineMatches);
        end;

        exit(HistoricalMatches);
    end;

    #region "AOAI Function" interface implementation
    procedure GetPrompt(): JsonObject
    var
        ToolDefinition: JsonObject;
        FunctionDefinition: JsonObject;
        ParametersDefinition: JsonObject;
        FunctionDescriptionLbl: Label 'Matches invoice lines with Historical Patterns.', Locked = true;
    begin
        ParametersDefinition.ReadFrom(NavApp.GetResourceAsText('AITools/HistoricalMatching-ToolDef.json'));

        FunctionDefinition.Add('name', GetName());
        FunctionDefinition.Add('description', FunctionDescriptionLbl);
        FunctionDefinition.Add('parameters', ParametersDefinition);

        ToolDefinition.Add('type', 'function');
        ToolDefinition.Add('function', FunctionDefinition);

        exit(ToolDefinition);
    end;

    procedure Execute(Arguments: JsonObject): Variant
    var
        TempMatchBuffer: Record "EDoc Line Match Buffer" temporary;
    begin
        Clear(TempMatchBuffer);
        TempMatchBuffer."E-Document Entry No." := EDocumentNo;
        TempMatchBuffer."Line No." := Arguments.GetInteger('lineId');

        if Arguments.Contains('purchaseType') then
            TempMatchBuffer."Purchase Type" := Enum::"Purchase Line Type".FromInteger(Arguments.GetInteger('purchaseType'));

        if Arguments.Contains('itemNo') then
            TempMatchBuffer."Purchase Type No." := CopyStr(Arguments.GetText('itemNo'), 1, MaxStrLen(TempMatchBuffer."Purchase Type No."));

        if Arguments.Contains('deferralCode') then
            TempMatchBuffer."Deferral Code" := CopyStr(Arguments.GetText('deferralCode'), 1, MaxStrLen(TempMatchBuffer."Deferral Code"));

        if Arguments.Contains('dimension1Code') then
            TempMatchBuffer."Shortcut Dimension 1 Code" := CopyStr(Arguments.GetText('dimension1Code'), 1, MaxStrLen(TempMatchBuffer."Shortcut Dimension 1 Code"));
        if Arguments.Contains('dimension2Code') then
            TempMatchBuffer."Shortcut Dimension 2 Code" := CopyStr(Arguments.GetText('dimension2Code'), 1, MaxStrLen(TempMatchBuffer."Shortcut Dimension 2 Code"));

        if Arguments.Contains('confidenceScore') then
            TempMatchBuffer."Confidence Score" := Arguments.GetDecimal('confidenceScore');

        if Arguments.Contains('reasoning') then
            TempMatchBuffer."Historical Matching Reasoning" := CopyStr(Arguments.GetText('reasoning'), 1, 250);

        if Arguments.Contains('recentHistoricalRecordRef') then
            TempMatchBuffer."Matched PurchInvLine SystemId" := Arguments.GetText('recentHistoricalRecordRef');

        exit(TempMatchBuffer);
    end;

    procedure GetName(): Text
    begin
        exit('match_lines_historical');
    end;
    #endregion "AOAI Function" interface implementation

    #region "E-Document AI System" interface implementation
    procedure GetSystemPrompt(): SecretText
    var
        AzureKeyVault: Codeunit "Azure Key Vault";
        PromptSecretText: SecretText;
        PromptSecretNameTok: Label 'EDocHistoricalMatching-SystemPrompt', Locked = true;
    begin
        if not AzureKeyVault.GetAzureKeyVaultSecret(PromptSecretNameTok, PromptSecretText) then
            PromptSecretText := SecretStrSubstNo('');
        exit(PromptSecretText);
    end;

    procedure GetTools(): List of [Interface "AOAI Function"]
    var
        List: List of [Interface "AOAI Function"];
    begin
        List.Add(this);
        exit(List);
    end;

    procedure GetFeatureName(): Text
    begin
        exit('EDocument Historical Matching')
    end;
    #endregion "E-Document AI System" interface implementation

    [IntegrationEvent(false, false)]
    local procedure OnGetHistoricalMatchFunctionResponse(TempEDocLineMatchBuffer: Record "EDoc Line Match Buffer" temporary)
    begin
    end;

    [IntegrationEvent(false, false)]
    local procedure OnUserMessageCreated(UserMessageTxt: Text)
    begin
    end;

}
