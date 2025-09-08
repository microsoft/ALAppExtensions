// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------
namespace Microsoft.eServices.EDocument.Processing.AI;

using Microsoft.eServices.EDocument.Processing.Import;
using Microsoft.eServices.EDocument.Processing.Import.Purchase;
using Microsoft.Finance.GeneralLedger.Account;
using Microsoft.Finance.GeneralLedger.Setup;
using Microsoft.Finance.VAT.Setup;
using Microsoft.Foundation.Company;
using Microsoft.Purchases.Vendor;
using System.AI;
using System.Azure.KeyVault;
using System.Log;
using System.Telemetry;

codeunit 6126 "E-Doc. GL Account Matching" implements "AOAI Function", IEDocAISystem
{

    Access = Internal;
    TableNo = "E-Document Purchase Line";
    InherentEntitlements = X;
    InherentPermissions = X;
    EventSubscriberInstance = Manual;

    trigger OnRun()
    var
        GLAccount: Record "G/L Account";
        TempEDocLineMatchBuffer: Record "EDoc Line Match Buffer" temporary;
        EDocumentAIProcessor: Codeunit "E-Doc. AI Tool Processor";
        EDocActivityLogBuilder: Codeunit "Activity Log Builder";
        Response: Codeunit "AOAI Operation Response";
        FunctionResponse: Codeunit "AOAI Function Response";
        FeatureTelemetry: Codeunit "Feature Telemetry";
        EDocImpSessionTelemetry: Codeunit "E-Doc. Imp. Session Telemetry";
        RecordRef: RecordRef;
        MistakesCount: Integer;
        MatchedCount: Integer;
        TelemetryDimensions: Dictionary of [Text, Text];
        ActivityLogTitleTxt: Label 'GL Account %1', Comment = '%1 = G/L Account No.';
        AIAccountMatchEventTok: Label 'GL Account AI Match', Locked = true;
    begin
        if GLAccount.IsEmpty() then
            exit;

        if not EDocumentAIProcessor.Setup(this) then
            exit;
        if not EDocumentAIProcessor.Process(CreateUserMessage(Rec), Response) then
            exit;

        foreach FunctionResponse in Response.GetFunctionResponses() do begin
            TempEDocLineMatchBuffer := FunctionResponse.GetResult();
            OnGetGLAccountMatchFunctionResponse(TempEDocLineMatchBuffer);

            if not Rec.Get(Rec."E-Document Entry No.", TempEDocLineMatchBuffer."Line No.") then begin
                MistakesCount += 1;
                continue;
            end;

            if TryValidateGLAccountNo(Rec, TempEDocLineMatchBuffer."GL Account No.") then begin
                if not GLAccount.Get(TempEDocLineMatchBuffer."GL Account No.") then begin
                    MistakesCount += 1;
                    continue;
                end;

                MatchedCount += 1;
                Rec.Modify(true);
                RecordRef.GetTable(GLAccount);
                EDocActivityLogBuilder
                    .Init(Database::"E-Document Purchase Line", Rec.FieldNo("[BC] Purchase Type No."), Rec.SystemId)
                    .SetExplanation(TempEDocLineMatchBuffer."GL Account Reason")
                    .SetType(Enum::"Activity Log Type"::"AI")
                    .SetReferenceSource(Page::"G/L Account Card", RecordRef)
                    .SetReferenceTitle(StrSubstNo(ActivityLogTitleTxt, Rec."[BC] Purchase Type No."))
                    .Log();

                EDocImpSessionTelemetry.SetLineBool(Rec.SystemId, AIAccountMatchEventTok, true);
            end;
        end;

        TelemetryDimensions.Add('Total lines', Format(Rec.Count()));
        TelemetryDimensions.Add('Proposed accounts', Format(Response.GetFunctionResponses().Count));
        TelemetryDimensions.Add('Matched accounts', Format(MatchedCount));
        TelemetryDimensions.Add('Processing mistakes', Format(MistakesCount));
        FeatureTelemetry.LogUsage('0000PUN', EDocumentAIProcessor.GetEDocumentMatchingAssistanceName(), GetFeatureName(), TelemetryDimensions);
    end;

    [TryFunction]
    local procedure TryValidateGLAccountNo(var EDocumentPurchaseLine: Record "E-Document Purchase Line"; ValueSuggested: Code[20])
    begin
        EDocumentPurchaseLine."[BC] Purchase Line Type" := EDocumentPurchaseLine."[BC] Purchase Line Type"::"G/L Account";
        EDocumentPurchaseLine.Validate("[BC] Purchase Type No.", ValueSuggested);
    end;

    local procedure CreateUserMessage(var EDocumentPurchaseLine: Record "E-Document Purchase Line"): Text
    var
        EDocumentPurchaseHeader: Record "E-Document Purchase Header";
        Vendor: Record Vendor;
        UserMessage: JsonArray;
        UserMessageTxt: Text;
    begin
        EDocumentPurchaseHeader.SetRange("E-Document Entry No.", EDocumentPurchaseLine."E-Document Entry No.");
        if EDocumentPurchaseHeader.FindFirst() then
            if Vendor.Get(EDocumentPurchaseHeader."[BC] Vendor No.") then;

        UserMessage.Add(BuildContext(Vendor));
        UserMessage.Add(BuildGLAccounts());
        UserMessage.Add(BuildEDocumentPurchaseLines(EDocumentPurchaseLine));
        UserMessage.WriteTo(UserMessageTxt);

        OnUserMessageCreated(UserMessageTxt);
        exit(UserMessageTxt);
    end;

    procedure BuildContext(Vendor: Record Vendor) Context: JsonObject
    var
        CompanyInformation: Record "Company Information";
    begin
        CompanyInformation.Get();
        Context.Add('companyName', CompanyInformation.Name);
        Context.Add('companyCountry', CompanyInformation."Country/Region Code");
        if CompanyInformation.County <> '' then
            Context.Add('companyCountyState', CompanyInformation.County);

        if Vendor."No." <> '' then begin
            Context.Add('vendorName', Vendor.Name);
            Context.Add('vendorCountry', Vendor."Country/Region Code");
            if Vendor.County <> '' then
                Context.Add('vendorCountyState', Vendor.County);
        end;
    end;

    procedure BuildGLAccounts() GLAccounts: JsonObject
    var
        GLAccount: Record "G/L Account";
        GenBusPostingGroup: Record "Gen. Business Posting Group";
        GenProdPostingGroup: Record "Gen. Product Posting Group";
        VATBusPostingGroup: Record "VAT Business Posting Group";
        VATProdPostingGroup: Record "VAT Product Posting Group";
        JsonObject: JsonObject;
        GLAccountArray: JsonArray;
    begin
        GLAccount.SetRange("Direct Posting", true);
        GLAccount.SetRange("Account Type", GLAccount."Account Type"::"Posting");

        GLAccount.SetAutoCalcFields("Account Subcategory Descript.");
        if GLAccount.FindSet() then
            repeat
                Clear(JsonObject);
                JsonObject.Add('accountNumber', GLAccount."No.");
                JsonObject.Add('chartOfAccountName', BuildGLAccountName(GLAccount));
                JsonObject.Add('accountPostingType', Format(GLAccount."Gen. Posting Type"));
                JsonObject.Add('accountCategory', Format(GLAccount."Account Category"));
                if GLAccount."Account Subcategory Entry No." <> 0 then
                    JsonObject.Add('accountSubcategory', GLAccount."Account Subcategory Descript.");

                if GenBusPostingGroup.Get(GLAccount."Gen. Bus. Posting Group") then
                    if GenBusPostingGroup.Description <> '' then
                        JsonObject.Add('generalBusinessPostingGroup', GenBusPostingGroup.Description);
                if GenProdPostingGroup.Get(GLAccount."Gen. Prod. Posting Group") then
                    if GenProdPostingGroup.Description <> '' then
                        JsonObject.Add('generalProductPostingGroup', GenProdPostingGroup.Description);
                if VATBusPostingGroup.Get(GLAccount."VAT Bus. Posting Group") then
                    if VATBusPostingGroup.Description <> '' then
                        JsonObject.Add('vatBusinessPostingGroup', VATBusPostingGroup.Description);
                if VATProdPostingGroup.Get(GLAccount."VAT Prod. Posting Group") then
                    if VATProdPostingGroup.Description <> '' then
                        JsonObject.Add('vatProductPostingGroup', VATProdPostingGroup.Description);

                GLAccountArray.Add(JsonObject);
            until (GLAccount.Next() = 0);

        GLAccounts.Add('chartOfAccounts', GLAccountArray);
    end;

    local procedure BuildGLAccountName(GLAccount: Record "G/L Account") Name: Text
    var
        GLAccount2: Record "G/L Account";
        I, CurrentIndentation : Integer;
        Categories: List of [Text];
    begin
        GLAccount2.SetCurrentKey("No.");
        GlAccount2.SetAscending("No.", false);
        GLAccount2.SetFilter("No.", '<%1', GLAccount."No.");
        GlAccount2.SetFilter(Indentation, '<%1', GLAccount.Indentation);
        CurrentIndentation := GLAccount.Indentation;
        if GLAccount2.FindSet() then
            repeat
                if GLAccount2.Indentation < CurrentIndentation then
                    Categories.Add(GLAccount2.Name);

                CurrentIndentation := GLAccount2.Indentation;
                if CurrentIndentation = 0 then
                    break;

            until GLAccount2.Next() = 0;

        for I := Categories.Count() downto 1 do
            Name += Categories.Get(I) + ' > ';
        Name += GLAccount.Name;
    end;

    local procedure BuildEDocumentPurchaseLines(var EDocumentPurchaseLine: Record "E-Document Purchase Line") EDocumentPurchaseLinesJson: JsonObject
    var
        JsonObject: JsonObject;
        EDocumentPurchaseLineArray: JsonArray;
    begin
        EDocumentPurchaseLine.Ascending(true);
        if EDocumentPurchaseLine.FindSet() then
            repeat
                Clear(JsonObject);
                JsonObject.Add('lineId', EDocumentPurchaseLine."Line No.");
                JsonObject.Add('lineDescription', EDocumentPurchaseLine.Description);
                JsonObject.Add('unitPrice', EDocumentPurchaseLine."Unit Price");
                EDocumentPurchaseLineArray.Add(JsonObject);
            until EDocumentPurchaseLine.Next() = 0;

        EDocumentPurchaseLinesJson.Add('purchaseLinesToMatch', EDocumentPurchaseLineArray);
    end;

    #region "AOAI Function" interface implementation
    procedure GetPrompt(): JsonObject
    var
        ToolDefinition: JsonObject;
        FunctionDefinition: JsonObject;
        ParametersDefinition: JsonObject;
        FunctionDescriptionTok: Label 'Matches invoice lines with G/L Accounts.', Locked = true;
    begin
        ParametersDefinition.ReadFrom(NavApp.GetResourceAsText('AITools/GLAccountClassifier-ToolDef.txt'));

        FunctionDefinition.Add('name', GetName());
        FunctionDefinition.Add('description', FunctionDescriptionTok);
        FunctionDefinition.Add('parameters', ParametersDefinition);

        ToolDefinition.Add('type', 'function');
        ToolDefinition.Add('function', FunctionDefinition);

        exit(ToolDefinition);
    end;

    procedure Execute(Arguments: JsonObject): Variant
    var
        EDocMatchLineBuffer: Record "EDoc Line Match Buffer";
    begin
        EDocMatchLineBuffer."Line No." := Arguments.GetInteger('lineId');
        EDocMatchLineBuffer."GL Account No." := CopyStr(Arguments.GetText('accountId'), 1, MaxStrLen(EDocMatchLineBuffer."GL Account No."));
        EDocMatchLineBuffer."GL Account Reason" := CopyStr(Arguments.GetText('reasoning'), 1, MaxStrLen(EDocMatchLineBuffer."GL Account Reason"));
        EDocMatchLineBuffer."GL Account Candidate Count" := Arguments.GetInteger('totalNumberOfPotentialAccounts');
        exit(EDocMatchLineBuffer);
    end;

    procedure GetName(): Text
    begin
        exit('match_gl_account');
    end;
    #endregion "AOAI Function" interface implementation

    #region "E-Document AI System" interface implementation
    procedure GetSystemPrompt(): SecretText
    var
        AzureKeyVault: Codeunit "Azure Key Vault";
        PromptSecretText: SecretText;
        PromptSecretNameTok: Label 'EDocMatchLineToGLAccountV27', Locked = true;
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
        exit('EDocument GL Account Matching')
    end;
    #endregion "E-Document AI System" interface implementation

    [IntegrationEvent(false, false)]
    local procedure OnGetGLAccountMatchFunctionResponse(TempEDocMatchLineBuffer: Record "EDoc Line Match Buffer" temporary)
    begin
    end;

    [IntegrationEvent(false, false)]
    local procedure OnUserMessageCreated(UserMessageTxt: Text)
    begin
    end;

}