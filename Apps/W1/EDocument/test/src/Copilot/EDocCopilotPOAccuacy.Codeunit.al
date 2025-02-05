namespace Microsoft.Sales.Document.Test;

using Microsoft.eServices.EDocument;
using Microsoft.eServices.EDocument.OrderMatch;
using Microsoft.Purchases.Document;
using Microsoft.eServices.EDocument.OrderMatch.Copilot;
using System.Reflection;
using System.TestTools.AITestToolkit;
using System.TestLibraries.Environment;


codeunit 133502 EDocCopilotPOAccuacy
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
        TempAIProposalBuffer, TempAIProposalBuffer2 : Record "E-Doc. PO Match Prop. Buffer" temporary;
        Assert: Codeunit Assert;
        AITContext: Codeunit "AIT Test Context";
        EDocPOAOAIFunction, EDocPOAOAIFunctionE2E : Codeunit "E-Doc. PO AOAI Function";
        EnvironmentInfoTestLibrary: Codeunit "Environment Info Test Library";
        TypeHelp: Codeunit "Type Helper";
        LibraryPurchase: Codeunit "Library - Purchase";
        JsonContent, JsonOutput : JsonObject;
        JsonToken: JsonToken;
        Lines, Items, Attributes : List of [Text];
        Input, Line, Item, K, V, Output : Text;
        LineNo: Integer;
    begin
        // [FEATURE] [E-Document] [Copilot Accuacy] 
        // [SCENARIO] Match exact LLM output to datai in accuacy.jsonl

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
        JsonContent.Get('input', JsonToken);
        Input := JsonToken.AsValue().AsText();
        Lines := Input.Split(TypeHelp.LFSeparator(), TypeHelp.CRLFSeparator(), TypeHelp.NewLine());
        LineNo := 0;
        foreach Line in Lines do begin
            LineNo += 10000;
            case Line[1] of
                'E':
                    begin
                        EDocumentImportedLine.Init();
                        EDocumentImportedLine."E-Document Entry No." := EDocument."Entry No";
                        EDocumentImportedLine.Quantity := 1;
                        Items := Line.Split(',');
                        foreach Item in Items do begin
                            Attributes := Item.Split(':');
                            Attributes.Get(1, K);
                            Attributes.Get(2, V);

                            case K.Trim() of
                                'EID':
                                    Evaluate(EDocumentImportedLine."Line No.", V.Trim());
                                'description':
                                    EDocumentImportedLine.Description := V.Trim();
                                'Unit of Measure':
                                    EDocumentImportedLine."Unit Of Measure Code" := V.Trim();
                                'Cost':
                                    Evaluate(EDocumentImportedLine."Direct Unit Cost", V.Trim());
                            end;

                        end;

                        EDocumentImportedLine.Insert();
                    end;
                'P':
                    begin
                        PurchaseLine.Init();
                        PurchaseLine.Validate("Document Type", PH."Document Type");
                        PurchaseLine.Validate("Document No.", PH."No.");
                        PurchaseLine.Quantity := 1;
                        PurchaseLine."Quantity Received" := 1;

                        Items := Line.Split(',');
                        foreach Item in Items do begin
                            Attributes := Item.Split(':');
                            Attributes.Get(1, K);
                            Attributes.Get(2, V);

                            case K.Trim() of
                                'PID':
                                    Evaluate(PurchaseLine."Line No.", V.Trim());
                                'description':
                                    PurchaseLine.Description := V.Trim();
                                'Unit of Measure':
                                    PurchaseLine."Unit Of Measure Code" := V.Trim();
                                'Cost':
                                    Evaluate(PurchaseLine."Direct Unit Cost", V.Trim());
                            end;
                        end;
                        PurchaseLine.Insert();
                    end;
            end;

        end;

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

        EDocPOCopilotMatching.MatchWithCopilot(TempEDocumentImportedLine, TempPurchaseLine, TempAIProposalBuffer);
        EDocPOCopilotMatching.GetFunction(EDocPOAOAIFunctionE2E);

        JsonContent.Get('expected_output', JsonToken);
        Output := JsonToken.AsValue().AsText();
        JsonOutput.ReadFrom(Output);
        EDocPOAOAIFunction.SetRecords(TempEDocumentImportedLine, TempPurchaseLine);
        TempAIProposalBuffer2.Copy(EDocPOAOAIFunction.Execute(JsonOutput), true);

        EDocPOAOAIFunctionE2E.GetArgumentsAsJson().WriteTo(Input);
        AITContext.SetTestOutput(Input);

        Assert.AreEqual(TempAIProposalBuffer2.Count(), TempAIProposalBuffer.Count(), '');
        if TempAIProposalBuffer2.FindSet() then
            repeat
                TempAIProposalBuffer.SetRange("Document Order No.", PH."No.");
                TempAIProposalBuffer.SetRange("Document Line No.", TempAIProposalBuffer2."Document Line No.");
                TempAIProposalBuffer.SetRange("E-Document Entry No.", EDocument."Entry No");
                TempAIProposalBuffer.SetRange("E-Document Line No.", TempAIProposalBuffer2."E-Document Line No.");
                Assert.RecordIsNotEmpty(TempAIProposalBuffer, '');
            until TempAIProposalBuffer2.Next() = 0;


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