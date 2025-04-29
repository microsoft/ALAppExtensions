#pragma warning disable AA0247
codeunit 6167 "E-Doc. PO AOAI Function" implements "AOAI Function"
{
    Access = Internal;
    InherentPermissions = X;
    InherentEntitlements = X;

    [NonDebuggable]
    procedure GetPrompt() Prompt: JsonObject
    var
        AzureKeyVault: Codeunit "Azure Key Vault";
        EDocPOCopilotMatching: Codeunit "E-Doc. PO Copilot Matching";
        EDocumentMappingToolPrompt: Text;
    begin
        if AzureKeyVault.GetAzureKeyVaultSecret('EDocumentMappingToolStructV2', EDocumentMappingToolPrompt) then
            Prompt.ReadFrom(EDocumentMappingToolPrompt)
        else
            Session.LogMessage('0000MOW', FailedToGetPromptSecretErr, Verbosity::Error, DataClassification::SystemMetadata, TelemetryScope::All, 'Category', EDocPOCopilotMatching.FeatureName());
    end;

    procedure Execute(Arguments: JsonObject): Variant
    var
        Result, Results, PurchaseOrderLineId, EDocumentLineId : JsonToken;
    begin
        Data := Arguments;
        Arguments.Get('results', Results);

        foreach result in results.AsArray() do begin
            Result.AsObject().Get('PID', PurchaseOrderLineId);
            Result.AsObject().Get('EID', EDocumentLineId);

            TempEDocumentImportedLine.SetRange("Line No.", EDocumentLineId.AsValue().AsInteger());
            TempEDocumentImportedLine.FindFirst();
            TempPurchaseLine.SetRange("Line No.", PurchaseOrderLineId.AsValue().AsInteger());
            TempPurchaseLine.FindFirst();

            TempAIProposalBuffer."E-Document Description" := TempEDocumentImportedLine.Description;
            TempAIProposalBuffer."E-Document Direct Unit Cost" := TempEDocumentImportedLine."Direct Unit Cost";
            TempAIProposalBuffer."PO Direct Unit Cost" := TempPurchaseLine."Direct Unit Cost";
            TempAIProposalBuffer."E-Document Line Discount" := TempEDocumentImportedLine."Line Discount %";
            TempAIProposalBuffer."PO Line Discount" := TempPurchaseLine."Line Discount %";
            TempAIProposalBuffer."Document Order No." := TempPurchaseLine."Document No.";
            TempAIProposalBuffer."E-Document Entry No." := TempEDocumentImportedLine."E-Document Entry No.";
            TempAIProposalBuffer."PO Description" := TempPurchaseLine.Description;

            Evaluate(TempAIProposalBuffer."Document Line No.", PurchaseOrderLineId.AsValue().AsText());
            Evaluate(TempAIProposalBuffer."E-Document Line No.", EDocumentLineId.AsValue().AsText());
            TempAIProposalBuffer."AI Proposal" := StrSubstNo(MatchLineTxt, PurchaseOrderLineId.AsValue().AsText());
            if TempAIProposalBuffer.Insert() then;
        end;

        exit(TempAIProposalBuffer);
    end;

    procedure GetName(): Text
    begin
        exit(FunctionNameLbl);
    end;

    procedure SetRecords(var TempEDocumentImportedLineLocal: Record "E-Doc. Imported Line" temporary; var TempPurchaseLineLocal: Record "Purchase Line" temporary)
    var
    begin
        TempEDocumentImportedLineLocal.Reset();
        if TempEDocumentImportedLineLocal.FindSet() then
            repeat
                TempEDocumentImportedLine.TransferFields(TempEDocumentImportedLineLocal);
                TempEDocumentImportedLine.Insert();
            until TempEDocumentImportedLineLocal.Next() = 0;

        TempPurchaseLineLocal.Reset();
        if TempPurchaseLineLocal.FindSet() then
            repeat
                TempPurchaseLine.TransferFields(TempPurchaseLineLocal);
                TempPurchaseLine.Insert();
            until TempPurchaseLineLocal.Next() = 0;
    end;

    procedure GetArgumentsAsJson(): JsonObject
    begin
        exit(Data);
    end;

    var
        TempEDocumentImportedLine: Record "E-Doc. Imported Line" temporary;
        TempPurchaseLine: Record "Purchase Line" temporary;
        TempAIProposalBuffer: Record "E-Doc. PO Match Prop. Buffer" temporary;
        Data: JsonObject;
        FunctionNameLbl: Label 'match_lines', Locked = true;
        MatchLineTxt: Label 'Matched to Purchase Order Line %1', Comment = '%1 = Number of the order line that the E-Document line is matched to';
        FailedToGetPromptSecretErr: Label 'Failed to get the prompt secret from Azure Key Vault', Locked = true;
}
