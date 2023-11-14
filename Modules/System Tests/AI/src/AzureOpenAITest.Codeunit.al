// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------

namespace System.Test.AI;

using System.AI;
using System.Privacy;
using System.TestLibraries.AI;
using System.TestLibraries.Utilities;

codeunit 132684 "Azure OpenAI Test"
{
    Subtype = Test;

    var
        CopilotTestLibrary: Codeunit "Copilot Test Library";
        LibraryAssert: Codeunit "Library Assert";
        Any: codeunit Any;
        AzureOpenAiTxt: Label 'Azure OpenAI', Locked = true;
        EndpointTxt: Label 'https://resourcename.openai.azure.com/', Locked = true;
        DeploymentTxt: Label 'deploymentid', Locked = true;

    [Test]
    [HandlerFunctions('HandleCopilotNotAvailable')]
    procedure TestIsEnabledRejectPrivacyNotice()
    var
        PrivacyNotice: Codeunit "Privacy Notice";
        AzureOpenAI: Codeunit "Azure OpenAI";
    begin
        // [SCENARIO] IsEnabled returns true when privacy notice is set to "Not Set" and is not in geo.

        // [GIVEN] Privacy notice has not been agreed nor disagreed to.
        PrivacyNotice.SetApprovalState(AzureOpenAITxt, "Privacy Notice Approval State"::"Not set");
        RegisterCapability(Enum::"Copilot Capability"::"Text Capability");

        // [WHEN] IsEnabled is called
        // [THEN] IsEnabled opens "Copilot Not Available" page and also returns false
        LibraryAssert.IsFalse(AzureOpenAI.IsEnabled(Enum::"Copilot Capability"::"Text Capability"), 'IsEnabled should return false when privacy notice is "Not Set" and not in geo.');
    end;

    [Test]
    procedure TestIsEnabledPrivacyNoticeAccepted()
    var
        PrivacyNotice: Codeunit "Privacy Notice";
        AzureOpenAI: Codeunit "Azure OpenAI";
    begin
        // [SCENARIO] IsEnabled returns true when privacy notice is accepted and is not in geo

        // [GIVEN] Privacy notice has been accepted
        PrivacyNotice.SetApprovalState(AzureOpenAITxt, "Privacy Notice Approval State"::Agreed);
        RegisterCapability(Enum::"Copilot Capability"::"Text Capability");

        // [WHEN] IsEnabled is called
        // [THEN] IsEnabled returns true
        LibraryAssert.IsTrue(AzureOpenAI.IsEnabled(Enum::"Copilot Capability"::"Text Capability", true), 'IsEnabled should return true when privacy notice has been accepted');
    end;

    [Test]
    [HandlerFunctions('HandleCopilotNotAvailable')]
    procedure TestIsEnabledPrivacyNoticeDisagreed()
    var
        PrivacyNotice: Codeunit "Privacy Notice";
        AzureOpenAI: Codeunit "Azure OpenAI";
    begin
        // [SCENARIO] IsEnabled returns false when privacy notice is not accepted

        // [GIVEN] Privacy notice has been rejected
        PrivacyNotice.SetApprovalState(AzureOpenAITxt, "Privacy Notice Approval State"::Disagreed);
        RegisterCapability(Enum::"Copilot Capability"::"Text Capability");

        // [WHEN] IsEnabled is called
        // [THEN] IsEnabled opens "Copilot Not Available" page and also returns false
        LibraryAssert.IsFalse(AzureOpenAI.IsEnabled(Enum::"Copilot Capability"::"Text Capability"), 'IsEnabled should return false when privacy notice has been accepted');
    end;

    [Test]
    procedure TestIsEnabledSilentPrivacyNoticeDisagreed()
    var
        PrivacyNotice: Codeunit "Privacy Notice";
        AzureOpenAI: Codeunit "Azure OpenAI";
    begin
        // [SCENARIO] IsEnabled returns false when privacy notice is not accepted

        // [GIVEN] Privacy notice has been rejected
        PrivacyNotice.SetApprovalState(AzureOpenAITxt, "Privacy Notice Approval State"::Disagreed);
        RegisterCapability(Enum::"Copilot Capability"::"Text Capability");

        // [WHEN] IsEnabled is called
        // [THEN] IsEnabled returns false
        LibraryAssert.IsFalse(AzureOpenAI.IsEnabled(Enum::"Copilot Capability"::"Text Capability", true), 'IsEnabled should return false when privacy notice has been accepted');
    end;

    [Test]
    procedure TestIsAuthorizationConfiguredAuthorizationNotSet()
    var
        AzureOpenAI: Codeunit "Azure OpenAI";
    begin
        // [SCENARIO] IsAuthorizationConfigured returns false when authorization is not set

        // [GIVEN] Authorization is not set
        // [WHEN] IsAuthorizationConfigured is called
        // [THEN] IsAuthorizationConfigured returns false
        LibraryAssert.IsFalse(AzureOpenAI.IsAuthorizationConfigured(Enum::"AOAI Model Type"::"Text Completions"), 'IsAuthorizationConfigured should return false when the authorization is not set');
        LibraryAssert.IsFalse(AzureOpenAI.IsAuthorizationConfigured(Enum::"AOAI Model Type"::Embeddings), 'IsAuthorizationConfigured should return false when the authorization is not set');
        LibraryAssert.IsFalse(AzureOpenAI.IsAuthorizationConfigured(Enum::"AOAI Model Type"::"Chat Completions"), 'IsAuthorizationConfigured should return false when the authorization is not set');
    end;

    [Test]
    procedure TestIsAuthorizationConfiguredOnlyEndpointSet()
    var
        AzureOpenAI: Codeunit "Azure OpenAI";
        ApiKey: SecretText;
    begin
        // [SCENARIO] IsAuthorizationConfigured returns true when authorization is set only with endpoint and key is empty

        // [GIVEN] The authorization is set without apikey
        AzureOpenAI.SetAuthorization(Enum::"AOAI Model Type"::"Text Completions", EndpointTxt, DeploymentTxt, ApiKey);
        AzureOpenAI.SetAuthorization(Enum::"AOAI Model Type"::Embeddings, EndpointTxt, DeploymentTxt, ApiKey);
        AzureOpenAI.SetAuthorization(Enum::"AOAI Model Type"::"Chat Completions", EndpointTxt, DeploymentTxt, ApiKey);

        // [WHEN] IsAuthorizationConfigured is called
        // [THEN] IsAuthorizationConfigured returns false
        LibraryAssert.IsFalse(AzureOpenAI.IsAuthorizationConfigured(Enum::"AOAI Model Type"::"Text Completions"), 'IsAuthorizationConfigured should return false when the authorization key is set only with endpoint and key is empty');
        LibraryAssert.IsFalse(AzureOpenAI.IsAuthorizationConfigured(Enum::"AOAI Model Type"::Embeddings), 'IsAuthorizationConfigured should return false when the authorization key is set only with endpoint and key is empty');
        LibraryAssert.IsFalse(AzureOpenAI.IsAuthorizationConfigured(Enum::"AOAI Model Type"::"Chat Completions"), 'IsAuthorizationConfigured should return false when the authorization key is set only with endpoint and key is empty');
    end;

    [Test]
    procedure TestIsAuthorizationConfiguredIsSet()
    var
        AzureOpenAI: Codeunit "Azure OpenAI";
    begin
        // [SCENARIO] IsAuthorizationConfigured returns false when authorization is set only with endpoint and key is empty

        // [GIVEN] The authorization key is set
        AzureOpenAI.SetAuthorization(Enum::"AOAI Model Type"::"Text Completions", EndpointTxt, DeploymentTxt, Any.AlphanumericText(10));
        AzureOpenAI.SetAuthorization(Enum::"AOAI Model Type"::Embeddings, EndpointTxt, DeploymentTxt, Any.AlphanumericText(10));
        AzureOpenAI.SetAuthorization(Enum::"AOAI Model Type"::"Chat Completions", EndpointTxt, DeploymentTxt, Any.AlphanumericText(10));

        // [WHEN] IsAuthorizationConfigured is called
        // [THEN] IsAuthorizationConfigured returns false
        LibraryAssert.IsTrue(AzureOpenAI.IsAuthorizationConfigured(Enum::"AOAI Model Type"::"Text Completions"), 'IsAuthorizationConfigured should return true when the authorization key is set');
        LibraryAssert.IsTrue(AzureOpenAI.IsAuthorizationConfigured(Enum::"AOAI Model Type"::Embeddings), 'IsAuthorizationConfigured should return true when the authorization key is set');
        LibraryAssert.IsTrue(AzureOpenAI.IsAuthorizationConfigured(Enum::"AOAI Model Type"::"Chat Completions"), 'IsAuthorizationConfigured should return true when the authorization key is set');
    end;

    [Test]
    procedure TestSetCopilotCapabilityInactive()
    var
        AzureOpenAI: Codeunit "Azure OpenAI";
        PrivacyNotice: Codeunit "Privacy Notice";
    begin
        // [SCENARIO] SetCopilotCapability returns an error when the capability is inactive

        // [GIVEN] The authorization key is not set
        PrivacyNotice.SetApprovalState(AzureOpenAITxt, "Privacy Notice Approval State"::Agreed);

        // [GIVEN] Capability is set
        RegisterCapability(Enum::"Copilot Capability"::"Text Capability");
        CopilotTestLibrary.SetCopilotStatus(Enum::"Copilot Capability"::"Text Capability", GetModuleAppId(), Enum::"Copilot Status"::Inactive);

        // [WHEN] SetCopilotCapability is called
        asserterror AzureOpenAI.SetCopilotCapability(Enum::"Copilot Capability"::"Text Capability");

        // [THEN] SetCopilotCapability returns an error
        LibraryAssert.ExpectedError('Copilot capability ''Text Capability'' has not been enabled. Please contact your system administrator.');
    end;

    [Test]
    procedure GenerateTextCompletionsCopilotCapabilityNotSet()
    var
        AzureOpenAI: Codeunit "Azure OpenAI";
        AOAIOperationResponse: Codeunit "AOAI Operation Response";
        PrivacyNotice: Codeunit "Privacy Notice";
    begin
        // [SCENARIO] GenerateTextCompletion returns an error when authorization is not set

        // [GIVEN] The authorization key is not set
        PrivacyNotice.SetApprovalState(AzureOpenAITxt, "Privacy Notice Approval State"::Agreed);

        // [WHEN] GenerateTextCompletion is called
        asserterror AzureOpenAI.GenerateTextCompletion(Any.AlphanumericText(10), AOAIOperationResponse);

        // [THEN] GenerateTextCompletion returns an error
        LibraryAssert.ExpectedError('Copilot capability has not been set.');
    end;

    [Test]
    procedure GenerateTextCompletionsCapabilityInactive()
    var
        AzureOpenAI: Codeunit "Azure OpenAI";
        AOAIOperationResponse: Codeunit "AOAI Operation Response";
        PrivacyNotice: Codeunit "Privacy Notice";
    begin
        // [SCENARIO] GenerateTextCompletion returns an error when capability is set to inactive

        // [GIVEN] The privacy notice is agreed to
        PrivacyNotice.SetApprovalState(AzureOpenAITxt, "Privacy Notice Approval State"::Agreed);

        // [GIVEN] Capability is set
        RegisterCapability(Enum::"Copilot Capability"::"Text Capability");
        AzureOpenAI.SetCopilotCapability(Enum::"Copilot Capability"::"Text Capability");
        CopilotTestLibrary.SetCopilotStatus(Enum::"Copilot Capability"::"Text Capability", GetModuleAppId(), Enum::"Copilot Status"::Inactive);

        // [WHEN] GenerateTextCompletion is called
        asserterror AzureOpenAI.GenerateTextCompletion(Any.AlphanumericText(10), AOAIOperationResponse);

        // [THEN] GenerateTextCompletion returns an error
        LibraryAssert.ExpectedError('Copilot is not enabled. Please contact your system administrator.');
    end;

    [Test]
    procedure GenerateTextCompletionsAuthorizationNotSet()
    var
        AzureOpenAI: Codeunit "Azure OpenAI";
        AOAIOperationResponse: Codeunit "AOAI Operation Response";
        PrivacyNotice: Codeunit "Privacy Notice";
    begin
        // [SCENARIO] GenerateTextCompletion returns an error when authorization is not set

        // [GIVEN] The privacy notice is agreed to
        PrivacyNotice.SetApprovalState(AzureOpenAITxt, "Privacy Notice Approval State"::Agreed);

        // [GIVEN] Capability is set
        RegisterCapability(Enum::"Copilot Capability"::"Text Capability");
        AzureOpenAI.SetCopilotCapability(Enum::"Copilot Capability"::"Text Capability");

        // [WHEN] GenerateTextCompletion is called
        asserterror AzureOpenAI.GenerateTextCompletion(Any.AlphanumericText(10), AOAIOperationResponse);

        // [THEN] GenerateTextCompletion returns an error
        LibraryAssert.ExpectedError('The authentication was not configured.');
    end;

    [Test]
    procedure GenerateTextCompletionsMetapromptNotSetFails()
    var
        AzureOpenAI: Codeunit "Azure OpenAI";
        AOAIOperationResponse: Codeunit "AOAI Operation Response";
        PrivacyNotice: Codeunit "Privacy Notice";
    begin
        // [SCENARIO] GenerateTextCompletion returns an error when generate complete is called

        // [GIVEN] The privacy notice is agreed to
        // [GIVEN] The authorization key is set
        PrivacyNotice.SetApprovalState(AzureOpenAITxt, "Privacy Notice Approval State"::Agreed);
        AzureOpenAI.SetAuthorization(Enum::"AOAI Model Type"::"Text Completions", EndpointTxt, DeploymentTxt, Any.AlphanumericText(10));

        // [GIVEN] Capability is set
        RegisterCapability(Enum::"Copilot Capability"::"Text Capability");
        AzureOpenAI.SetCopilotCapability(Enum::"Copilot Capability"::"Text Capability");

        // [WHEN] GenerateTextCompletion is called
        asserterror AzureOpenAI.GenerateTextCompletion(Any.AlphanumericText(10), AOAIOperationResponse);

        // [THEN] GenerateTextCompletion returns an error
        LibraryAssert.ExpectedError('The metaprompt has not been set, please provide a metaprompt.');
    end;

    [Test]
    procedure GenerateTextCompletionsFails()
    var
        AzureOpenAI: Codeunit "Azure OpenAI";
        AOAIOperationResponse: Codeunit "AOAI Operation Response";
        PrivacyNotice: Codeunit "Privacy Notice";
        Metaprompt: Text;
    begin
        // [SCENARIO] GenerateTextCompletion returns an error when generate complete is called

        // [GIVEN] The privacy notice is agreed to
        // [GIVEN] The authorization key is set
        PrivacyNotice.SetApprovalState(AzureOpenAITxt, "Privacy Notice Approval State"::Agreed);
        AzureOpenAI.SetAuthorization(Enum::"AOAI Model Type"::"Text Completions", EndpointTxt, DeploymentTxt, Any.AlphanumericText(10));

        // [GIVEN] Capability is set
        RegisterCapability(Enum::"Copilot Capability"::"Text Capability");
        AzureOpenAI.SetCopilotCapability(Enum::"Copilot Capability"::"Text Capability");
        Metaprompt := 'metaprompt';

        // [WHEN] GenerateTextCompletion is called
        AzureOpenAI.GenerateTextCompletion(Metaprompt, Any.AlphanumericText(10), AOAIOperationResponse);

        // [THEN] GenerateTextCompletion should not be successful
        LibraryAssert.IsFalse(AOAIOperationResponse.IsSuccess(), 'The text completions generation succeeded when it should fail.');
    end;

    [Test]
    procedure GenerateEmbeddingCopilotCapabilityNotSet()
    var
        AzureOpenAI: Codeunit "Azure OpenAI";
        AOAIOperationResponse: Codeunit "AOAI Operation Response";
        PrivacyNotice: Codeunit "Privacy Notice";
    begin
        // [SCENARIO] GenerateTextCompletion returns an error when capability is not set

        // [GIVEN] The privacy notice is agreed to
        PrivacyNotice.SetApprovalState(AzureOpenAITxt, "Privacy Notice Approval State"::Agreed);

        // [WHEN] GenerateTextCompletion is called
        asserterror AzureOpenAI.GenerateTextCompletion(Any.AlphanumericText(10), AOAIOperationResponse);

        // [THEN] GenerateTextCompletion returns an error
        LibraryAssert.ExpectedError('Copilot capability has not been set.');
    end;

    [Test]
    procedure GenerateEmbeddingCapabilityInactive()
    var
        AzureOpenAI: Codeunit "Azure OpenAI";
        AOAIOperationResponse: Codeunit "AOAI Operation Response";
        PrivacyNotice: Codeunit "Privacy Notice";
    begin
        // [SCENARIO] GenerateEmbedding returns an error when capability is set to inactive

        // [GIVEN] The privacy notice is agreed to
        PrivacyNotice.SetApprovalState(AzureOpenAITxt, "Privacy Notice Approval State"::Agreed);

        // [GIVEN] Capability is set
        RegisterCapability(Enum::"Copilot Capability"::"Embedding Capability");
        AzureOpenAI.SetCopilotCapability(Enum::"Copilot Capability"::"Embedding Capability");
        CopilotTestLibrary.SetCopilotStatus(Enum::"Copilot Capability"::"Embedding Capability", GetModuleAppId(), Enum::"Copilot Status"::Inactive);

        // [WHEN] GenerateEmbedding is called
        asserterror AzureOpenAI.GenerateEmbeddings(Any.AlphanumericText(10), AOAIOperationResponse);

        // [THEN] GenerateEmbedding returns an error
        LibraryAssert.ExpectedError('Copilot is not enabled. Please contact your system administrator.');
    end;

    [Test]
    procedure GenerateEmbeddingsAuthorizationNotSet()
    var
        AzureOpenAI: Codeunit "Azure OpenAI";
        AOAIOperationResponse: Codeunit "AOAI Operation Response";
        PrivacyNotice: Codeunit "Privacy Notice";
    begin
        // [SCENARIO] GenerateEmbeddings returns an error when authorization is not set

        // [GIVEN] The privacy notice is agreed to
        PrivacyNotice.SetApprovalState(AzureOpenAITxt, "Privacy Notice Approval State"::Agreed);

        // [GIVEN] Capability is set
        RegisterCapability(Enum::"Copilot Capability"::"Embedding Capability");
        AzureOpenAI.SetCopilotCapability(Enum::"Copilot Capability"::"Embedding Capability");

        // [WHEN] GenerateEmbeddings is called
        asserterror AzureOpenAI.GenerateEmbeddings(Any.AlphanumericText(10), AOAIOperationResponse);

        // [THEN] GenerateEmbeddings returns an error
        LibraryAssert.ExpectedError('The authentication was not configured.');
    end;

    [Test]
    procedure GenerateEmbeddingsFails()
    var
        AzureOpenAI: Codeunit "Azure OpenAI";
        AOAIOperationResponse: Codeunit "AOAI Operation Response";
        PrivacyNotice: Codeunit "Privacy Notice";
    begin
        // [SCENARIO] GenerateEmbeddings returns an error when generate complete is called

        // [GIVEN] The privacy notice is agreed to
        // [GIVEN] The authorization key is set
        PrivacyNotice.SetApprovalState(AzureOpenAITxt, "Privacy Notice Approval State"::Agreed);
        AzureOpenAI.SetAuthorization(Enum::"AOAI Model Type"::Embeddings, EndpointTxt, DeploymentTxt, Any.AlphanumericText(10));

        // [GIVEN] Capability is set
        RegisterCapability(Enum::"Copilot Capability"::"Embedding Capability");
        AzureOpenAI.SetCopilotCapability(Enum::"Copilot Capability"::"Embedding Capability");

        // [WHEN] GenerateEmbeddings is called
        AzureOpenAI.GenerateEmbeddings(Any.AlphanumericText(10), AOAIOperationResponse);

        // [THEN] GenerateEmbeddings returns an error
        LibraryAssert.IsFalse(AOAIOperationResponse.IsSuccess(), 'The embeddings generation succeeded when it should fail.');
    end;

    [Test]
    procedure GenerateChatCompletionCopilotCapabilityNotSet()
    var
        AzureOpenAI: Codeunit "Azure OpenAI";
        AOAIChatMessages: Codeunit "AOAI Chat Messages";
        AOAIOperationResponse: Codeunit "AOAI Operation Response";
        PrivacyNotice: Codeunit "Privacy Notice";
    begin
        // [SCENARIO] GenerateChatCompletion returns an error when capability is not set

        // [GIVEN] The privacy notice is agreed to
        PrivacyNotice.SetApprovalState(AzureOpenAITxt, "Privacy Notice Approval State"::Agreed);

        // [WHEN] GenerateChatCompletion is called
        asserterror AzureOpenAI.GenerateChatCompletion(AOAIChatMessages, AOAIOperationResponse);

        // [THEN] GenerateChatCompletion returns an error
        LibraryAssert.ExpectedError('Copilot capability has not been set.');
    end;

    [Test]
    procedure GenerateChatCompletionCapabilityInactive()
    var
        AzureOpenAI: Codeunit "Azure OpenAI";
        AOAIChatMessages: Codeunit "AOAI Chat Messages";
        AOAIOperationResponse: Codeunit "AOAI Operation Response";
        PrivacyNotice: Codeunit "Privacy Notice";
    begin
        // [SCENARIO] procedure GenerateChatCompletion returns an error when capability is set to inactive

        // [GIVEN] The privacy notice is agreed to
        PrivacyNotice.SetApprovalState(AzureOpenAITxt, "Privacy Notice Approval State"::Agreed);

        // [GIVEN] Capability is set
        RegisterCapability(Enum::"Copilot Capability"::"Chat Capability");
        AzureOpenAI.SetCopilotCapability(Enum::"Copilot Capability"::"Chat Capability");
        CopilotTestLibrary.SetCopilotStatus(Enum::"Copilot Capability"::"Chat Capability", GetModuleAppId(), Enum::"Copilot Status"::Inactive);

        // [WHEN] GenerateChatCompletion is called
        asserterror AzureOpenAI.GenerateChatCompletion(AOAIChatMessages, AOAIOperationResponse);

        // [THEN] GenerateChatCompletion returns an error
        LibraryAssert.ExpectedError('Copilot is not enabled. Please contact your system administrator.');
    end;

    [Test]
    procedure GenerateChatCompletionAuthorizationNotSet()
    var
        AzureOpenAI: Codeunit "Azure OpenAI";
        AOAIChatMessages: Codeunit "AOAI Chat Messages";
        AOAIOperationResponse: Codeunit "AOAI Operation Response";
        PrivacyNotice: Codeunit "Privacy Notice";
    begin
        // [SCENARIO] GenerateChatCompletion returns an error when authorization is not set

        // [GIVEN] The authorization key is not set
        PrivacyNotice.SetApprovalState(AzureOpenAITxt, "Privacy Notice Approval State"::Agreed);

        // [GIVEN] Capability is set
        RegisterCapability(Enum::"Copilot Capability"::"Chat Capability");
        AzureOpenAI.SetCopilotCapability(Enum::"Copilot Capability"::"Chat Capability");

        // [WHEN] GenerateChatCompletion is called
        asserterror AzureOpenAI.GenerateChatCompletion(AOAIChatMessages, AOAIOperationResponse);

        // [THEN] GenerateChatCompletion returns an error
        LibraryAssert.ExpectedError('The authentication was not configured.');
    end;

    [Test]
    procedure GenerateChatCompletionFails()
    var
        AzureOpenAI: Codeunit "Azure OpenAI";
        AOAIChatMessages: Codeunit "AOAI Chat Messages";
        AOAIOperationResponse: Codeunit "AOAI Operation Response";
        PrivacyNotice: Codeunit "Privacy Notice";
    begin
        // [SCENARIO] GenerateEmbeddings returns an error when generate chat complete is called

        // [GIVEN] The authorization key is set
        PrivacyNotice.SetApprovalState(AzureOpenAITxt, "Privacy Notice Approval State"::Agreed);
        AzureOpenAI.SetAuthorization(Enum::"AOAI Model Type"::"Chat Completions", EndpointTxt, DeploymentTxt, Any.AlphanumericText(10));

        // [GIVEN] Capability is set
        RegisterCapability(Enum::"Copilot Capability"::"Chat Capability");
        AzureOpenAI.SetCopilotCapability(Enum::"Copilot Capability"::"Chat Capability");

        // [WHEN] GenerateChatCompletion is called
        AzureOpenAI.GenerateChatCompletion(AOAIChatMessages, AOAIOperationResponse);

        // [THEN] GenerateChatCompletion fails
        LibraryAssert.IsFalse(AOAIOperationResponse.IsSuccess(), 'The chat completions generation succeeded when it should fail.');
    end;

    [Test]
    procedure TestChatCompletionPrepareHistory()
    var
        AOAIChatMessages: Codeunit "AOAI Chat Messages";
        AzureOpenAITestLibrary: Codeunit "Azure OpenAI Test Library";
        HistoryJsonArray: JsonArray;
        HistoryMessage: JsonToken;
        JsonObject: JsonObject;
    begin
        // [SCENARIO] Prepare history gets the proper length of history to send to the model and the last message is the actual last message

        // [GIVEN] A history length of 10 messages and one specific last message
        InitializeChatHistory(AOAIChatMessages, 10);
        AOAIChatMessages.AddUserMessage('Last message');

        // [WHEN] Calling PrepareHistory
        HistoryJsonArray := AzureOpenAITestLibrary.GetAOAIHistory(5, AOAIChatMessages);

        // [THEN] The history length is 5
        LibraryAssert.AreEqual(5, HistoryJsonArray.Count, 'The history length should be 5');

        // [THEN] The last message in the history should be 'Last message'
        HistoryJsonArray.Get(4, HistoryMessage);
        JsonObject := HistoryMessage.AsObject();
        JsonObject.Get('content', HistoryMessage);
        LibraryAssert.AreEqual('Last message', HistoryMessage.AsValue().AsText(), 'The last message should be "Last message"');
    end;

    [Test]
    procedure TestChatCompletionPrepareHistoryWithPrimaryandOneMessage()
    var
        AOAIChatMessages: Codeunit "AOAI Chat Messages";
        AzureOpenAITestLibrary: Codeunit "Azure OpenAI Test Library";
        HistoryJsonArray: JsonArray;
        Metaprompt: Text;
    begin
        // [SCENARIO] Prepare history gets the proper length of history to send to the model and the last message is the actual last message

        // [GIVEN] A history length of 1 primary system message and 1 message
        Metaprompt := 'Primary system message';
        AOAIChatMessages.SetPrimarySystemMessage(Metaprompt);
        AOAIChatMessages.AddUserMessage('Last message');

        // [WHEN] Calling PrepareHistory
        HistoryJsonArray := AzureOpenAITestLibrary.GetAOAIHistory(5, AOAIChatMessages);

        // [THEN] The history length is 2
        LibraryAssert.AreEqual(2, HistoryJsonArray.Count, 'The history length should be 2');
    end;

    [Test]
    procedure TestChatCompletionPrepareHistoryWithNoHistory()
    var
        AOAIChatMessages: Codeunit "AOAI Chat Messages";
        AzureOpenAITestLibrary: Codeunit "Azure OpenAI Test Library";
        HistoryJsonArray: JsonArray;
    begin
        // [SCENARIO] Prepare history gets the proper length of history to send to the model

        // [GIVEN] A chat messages with no history
        // [WHEN] Calling PrepareHistory with 5 history length of 5
        HistoryJsonArray := AzureOpenAITestLibrary.GetAOAIHistory(5, AOAIChatMessages);

        // [THEN] The history length is 0
        LibraryAssert.AreEqual(0, HistoryJsonArray.Count, 'The history length should be 0');
    end;

    [Test]
    procedure TestAOAIChatMessagesAddUserMessage()
    var
        AOAIChatMessages: Codeunit "AOAI Chat Messages";
        UserMessageTxt: Label 'User message', Locked = true;
    begin
        // [SCENARIO] AddUserMessage adds a user message to the history

        // [GIVEN] An empty history
        // [WHEN] Calling AddUserMessage
        AOAIChatMessages.AddUserMessage(UserMessageTxt);

        // [THEN] The history length is 1
        LibraryAssert.AreEqual(1, AOAIChatMessages.GetHistory().Count, 'The history length should be 1');

        // [THEN] The last message in the history should be 'User message'
        LibraryAssert.AreEqual(UserMessageTxt, AOAIChatMessages.GetLastMessage(), 'The last message should be "User message"');

        // [THEN] The last message in the history should be a user message
        LibraryAssert.AreEqual(Enum::"AOAI Chat Roles"::User, AOAIChatMessages.GetLastRole(), 'The last message should be a user message');
    end;

    [Test]
    procedure TestAOAIChatMessagesAddSystemMessage()
    var
        AOAIChatMessages: Codeunit "AOAI Chat Messages";
        SystemMessageTxt: Label 'System message', Locked = true;
    begin
        // [SCENARIO] AddSystemMessage adds a system message to the history

        // [GIVEN] An empty history
        // [WHEN] Calling AddSystemMessage
        AOAIChatMessages.AddSystemMessage(SystemMessageTxt);

        // [THEN] The history length is 1
        LibraryAssert.AreEqual(1, AOAIChatMessages.GetHistory().Count, 'The history length should be 1');

        // [THEN] The message in the history should be 'System message'
        LibraryAssert.AreEqual(SystemMessageTxt, AOAIChatMessages.GetLastMessage(), 'The message should be "System message"');

        // [THEN] The message in the history should be a system message
        LibraryAssert.AreEqual(Enum::"AOAI Chat Roles"::System, AOAIChatMessages.GetLastRole(), 'The message should be a system message');
    end;

    [Test]
    procedure TestAOAIChatMessagesAddAssistantMessage()
    var
        AOAIChatMessages: Codeunit "AOAI Chat Messages";
        AssistantMessageTxt: Label 'Assistant message', Locked = true;
    begin
        // [SCENARIO] AddAssistantMessage adds a system message to the history

        // [GIVEN] An empty history
        // [WHEN] Calling AddAssistantMessage
        AOAIChatMessages.AddAssistantMessage(AssistantMessageTxt);

        // [THEN] The history length is 1
        LibraryAssert.AreEqual(1, AOAIChatMessages.GetHistory().Count, 'The history length should be 1');

        // [THEN] The message in the history should be 'Assistant message'
        LibraryAssert.AreEqual(AssistantMessageTxt, AOAIChatMessages.GetLastMessage(), 'The message should be "Assistant message"');

        // [THEN] The message in the history should be a Assistant message
        LibraryAssert.AreEqual(Enum::"AOAI Chat Roles"::Assistant, AOAIChatMessages.GetLastRole(), 'The message should be a assistant message');
    end;

    [Test]
    procedure TestAOAIChatMessagesDifferentUserNames()
    var
        AOAIChatMessages: Codeunit "AOAI Chat Messages";
        HistoryNames: List of [Text[2048]];
    begin
        // [SCENARIO] User messages have specific names when specified

        // [GIVEN] 2 user messages with different names
        AOAIChatMessages.AddUserMessage(Any.AlphabeticText(10), 'User 1');
        AOAIChatMessages.AddUserMessage(Any.AlphabeticText(10), 'User 2');

        // [WHEN] Check the user names
        // [THEN] They have different names
        HistoryNames := AOAIChatMessages.GetHistoryNames();
        LibraryAssert.AreEqual('User 1', HistoryNames.Get(1), 'The user name should be "User 1"');
        LibraryAssert.AreEqual('User 2', HistoryNames.Get(2), 'The user name should be "User 2"');
    end;

    [PageHandler()]
    procedure HandleCopilotNotAvailable(var CurrPage: TestPage "Copilot Not Available")
    begin
        CurrPage.ActionFinish.Invoke();
    end;

    local procedure InitializeChatHistory(var AOAIChatMessages: Codeunit "AOAI Chat Messages"; HistoryLength: Integer)
    var
        Counter: Integer;
    begin
        AOAIChatMessages.AddSystemMessage(Any.AlphabeticText(10));

        for Counter := 2 to HistoryLength do
            if (Counter mod 2) = 0 then
                AOAIChatMessages.AddUserMessage(Any.AlphabeticText(10))
            else
                AOAIChatMessages.AddAssistantMessage(Any.AlphabeticText(10));
    end;

    local procedure RegisterCapability(Capability: Enum "Copilot Capability")
    var
        CopilotCapability: Codeunit "Copilot Capability";
    begin
        if CopilotCapability.IsCapabilityRegistered(Capability) then
            exit;

        CopilotCapability.RegisterCapability(Capability, '');
    end;

    local procedure GetModuleAppId(): Guid
    var
        CurrentModuleInfo: ModuleInfo;
    begin
        NavApp.GetCurrentModuleInfo(CurrentModuleInfo);
        exit(CurrentModuleInfo.Id());
    end;
}