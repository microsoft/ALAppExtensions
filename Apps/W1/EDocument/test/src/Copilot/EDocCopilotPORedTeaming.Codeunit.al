namespace Microsoft.Sales.Document.Test;

using Microsoft.eServices.EDocument;
using Microsoft.eServices.EDocument.OrderMatch;
using Microsoft.Purchases.Document;
using Microsoft.eServices.EDocument.OrderMatch.Copilot;
using System.TestLibraries.Environment;
using System.TestTools.AITestToolkit;

codeunit 133501 EDocCopilotPORedTeaming
{
    Subtype = Test;
    TestPermissions = Disabled;

    var
        EDocPOCopilotMatching: Codeunit "E-Doc. PO Copilot Matching";

    [Test]
    procedure TestPromptAccuacy()
    var
        EDocument: Record "E-Document";
        TempEDocumentImportedLine: Record "E-Doc. Imported Line" temporary;
        PH: Record "Purchase Header";
        PurchaseLine: Record "Purchase Line";
        EDocumentImportedLine: Record "E-Doc. Imported Line";
        TempPurchaseLine: Record "Purchase Line" temporary;
        TempAIProposalBuffer: Record "E-Doc. PO Match Prop. Buffer" temporary;
        Assert: Codeunit Assert;
        AITContext: Codeunit "AIT Test Context";
        EDocPOAOAIFunctionE2E: Codeunit "E-Doc. PO AOAI Function";
        LibraryPurchase: Codeunit "Library - Purchase";
        EnvironmentInfoTestLibrary: Codeunit "Environment Info Test Library";
        JsonContent: JsonObject;
        JsonToken: JsonToken;
        UserQuery: Text;
    begin
        // [FEATURE] [E-Document] [Copilot Redteaming] 
        // [SCENARIO] Match LLM output for redteam content 

        PurchaseLine.DeleteAll();
        EDocumentImportedLine.DeleteAll();
        PH.DeleteAll();
        EDocument.DeleteAll();
        EnvironmentInfoTestLibrary.SetTestabilitySoftwareAsAService(true);

        // TODO: Remove once process for KV is hardened
        // If need of specific promp uncomment and set KV in the function
        // SetupKeyVault();


        EDocument.Init();
        EDocument."Entry No" := 0;
        EDocument.Insert();
        LibraryPurchase.CreatePurchHeader(PH, PH."Document Type"::Order, LibraryPurchase.CreateVendorNo());

        JsonContent.ReadFrom(AITContext.GetInput().ToText());
        JsonContent.Get('user_query', JsonToken);
        UserQuery := JsonToken.AsValue().AsText();

        EDocumentImportedLine.Init();
        EDocumentImportedLine."E-Document Entry No." := EDocument."Entry No";
        EDocumentImportedLine.Quantity := 1;
        EDocumentImportedLine."Line No." := 10000;
        EDocumentImportedLine.Description := CopyStr(UserQuery, 1, 100);
        EDocumentImportedLine."Unit Of Measure Code" := 'PCS';
        EDocumentImportedLine."Direct Unit Cost" := 100;
        EDocumentImportedLine.Insert();

        PurchaseLine.Init();
        PurchaseLine.Validate("Document Type", PH."Document Type");
        PurchaseLine.Validate("Document No.", PH."No.");
        PurchaseLine.Quantity := 1;
        PurchaseLine."Quantity Received" := 1;
        PurchaseLine."Line No." := 10000;
        PurchaseLine.Description := 'Computer';
        PurchaseLine."Unit Of Measure Code" := 'PCS';
        PurchaseLine."Direct Unit Cost" := 100;
        PurchaseLine.Insert();

        if PurchaseLine.FindSet() then
            repeat
                TempPurchaseLine.Copy(PurchaseLine);
                TempPurchaseLine.Insert();
            until PurchaseLine.Next() = 0;

        if EDocumentImportedLine.FindSet() then
            repeat
                TempEDocumentImportedLine.Copy(EDocumentImportedLine);
                TempEDocumentImportedLine.Insert();
            until EDocumentImportedLine.Next() = 0;

        if TryMatch(TempEDocumentImportedLine, TempPurchaseLine, TempAIProposalBuffer) then;
        EDocPOCopilotMatching.GetFunction(EDocPOAOAIFunctionE2E);
        EDocPOAOAIFunctionE2E.GetArgumentsAsJson().WriteTo(UserQuery);
        AITContext.SetTestOutput(UserQuery);
        Assert.RecordIsEmpty(TempAIProposalBuffer);

    end;

    [TryFunction]
    local procedure TryMatch(var TempEDocumentImportedLine: Record "E-Doc. Imported Line" temporary; var TempPurchaseLine: Record "Purchase Line" temporary; var TempAIProposalBuffer: Record "E-Doc. PO Match Prop. Buffer" temporary)
    begin
        EDocPOCopilotMatching.MatchWithCopilot(TempEDocumentImportedLine, TempPurchaseLine, TempAIProposalBuffer);
    end;

    local procedure SetupKeyVault()
    var
        LibraryAzureKVMockMgmt: Codeunit "Library - Azure KV Mock Mgmt.";
    begin
        LibraryAzureKVMockMgmt.InitMockAzureKeyvaultSecretProvider();

        // Always enter prompts when running tests locally.
        // TODO: Fix when there exits solution to load prompts at runtime
        LibraryAzureKVMockMgmt.AddMockAzureKeyvaultSecretProviderMapping('EDocumentMappingToolStruct', '');
        LibraryAzureKVMockMgmt.AddMockAzureKeyvaultSecretProviderMapping('EDocumentMappingPrompt', '');
        LibraryAzureKVMockMgmt.UseAzureKeyvaultSecretProvider();
    end;
}