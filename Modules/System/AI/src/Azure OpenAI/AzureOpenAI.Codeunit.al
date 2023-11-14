// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------
namespace System.AI;

/// <summary>
/// Provides functionality for using the Azure OpenAI API.
/// </summary>
codeunit 7771 "Azure OpenAI"
{
    Access = Public;
    InherentEntitlements = X;
    InherentPermissions = X;

    var
        AzureOpenAIImpl: Codeunit "Azure OpenAI Impl";

    /// <summary>
    /// Checks if the Azure OpenAI API is enabled for the environment and if the capability is active on the environment.
    /// </summary>
    /// <param name="CopilotCapability">The copilot capability to check.</param>
    /// <returns>True if API and capability is enabled for environment.</returns>
    procedure IsEnabled(CopilotCapability: Enum "Copilot Capability"): Boolean
    var
        CallerModuleInfo: ModuleInfo;
    begin
        NavApp.GetCallerModuleInfo(CallerModuleInfo);
        exit(AzureOpenAIImpl.IsEnabled(CopilotCapability, CallerModuleInfo));
    end;

    /// <summary>
    /// Checks if the Azure OpenAI API is enabled for the environment and if the capability is active on the environment.
    /// </summary>
    /// <param name="CopilotCapability">The copilot capability to check.</param>
    /// <param name="Silent">If true, no error message will be shown if API is not enabled.</param>
    /// <returns>True if API and capability is enabled for environment.</returns>
    procedure IsEnabled(CopilotCapability: Enum "Copilot Capability"; Silent: Boolean): Boolean
    var
        CallerModuleInfo: ModuleInfo;
    begin
        NavApp.GetCallerModuleInfo(CallerModuleInfo);
        exit(AzureOpenAIImpl.IsEnabled(CopilotCapability, Silent, CallerModuleInfo));
    end;

    /// <summary>
    /// Checks if the Azure OpenAI API authorization is configured for the environment.
    /// </summary>
    /// <param name="ModelType">The model type to check authorization for.</param>
    /// <returns>True if API is authorized for environment.</returns>
    procedure IsAuthorizationConfigured(ModelType: Enum "AOAI Model Type"): Boolean
    var
        CallerModuleInfo: ModuleInfo;
    begin
        NavApp.GetCallerModuleInfo(CallerModuleInfo);
        exit(AzureOpenAIImpl.IsAuthorizationConfigured(ModelType, CallerModuleInfo));
    end;

    /// <summary>
    /// Checks if the Azure OpenAI API is enabled for the environment and authorization is configured for the modeltype.
    /// </summary>
    /// <param name="CopilotCapability">The copilot capability to check.</param>
    /// <param name="ModelType">The model type to check authorization for.</param>
    /// <returns>True if the API is enabled and model authorization has been configured.</returns>
    procedure IsInitialized(CopilotCapability: Enum "Copilot Capability"; ModelType: Enum "AOAI Model Type"): Boolean
    var
        CallerModuleInfo: ModuleInfo;
    begin
        NavApp.GetCallerModuleInfo(CallerModuleInfo);
        exit(AzureOpenAIImpl.IsInitialized(CopilotCapability, ModelType, CallerModuleInfo));
    end;

    /// <summary>
    /// Sets the Azure OpenAI API authorization to use for a specific model type and endpoint.
    /// </summary>
    /// <param name="ModelType">The model type to set authorization for.</param>
    /// <param name="Endpoint">The endpoint to use for the model type.</param>
    /// <param name="Deployment">The deployment to use for the endpoint.</param>
    /// <param name="ApiKey">The API key to use for the endpoint.</param>
    /// <remarks>Endpoint would look like: https://resource-name.openai.azure.com/ 
    /// Deployment would look like: gpt-35-turbo-16k
    /// </remarks>
    [NonDebuggable]
    procedure SetAuthorization(ModelType: Enum "AOAI Model Type"; Endpoint: Text; Deployment: Text; ApiKey: SecretText)
    begin
        AzureOpenAIImpl.SetAuthorization(ModelType, Endpoint, Deployment, ApiKey);
    end;

    /// <summary>
    /// Sets the Azure OpenAI API authorization to use for a specific model type.
    /// </summary>
    /// <param name="ModelType">The model type to set authorization for.</param>
    /// <param name="Deployment">The deployment name to use for the model type.</param>
    /// <remarks>Deployment would look like: gpt-35-turbo-16k</remarks>
    [NonDebuggable]
    procedure SetAuthorization(ModelType: Enum "AOAI Model Type"; Deployment: Text)
    begin
        AzureOpenAIImpl.SetAuthorization(ModelType, Deployment);
    end;

    /// <summary>
    /// Generates a text completion given a prompt.
    /// </summary>
    /// <param name="Prompt">The prompt to generate completion for.</param>
    /// <param name="AOAIOperationResponse">The response of the operation upon successful or failure execution.</param>
    /// <returns>The generated completion.</returns>
    /// <error>The completion authentication was not configured.</error>
    /// <error>The completion generation failed with status code %1.</error>
    [NonDebuggable]
    procedure GenerateTextCompletion(Prompt: SecretText; var AOAIOperationResponse: Codeunit "AOAI Operation Response"): Text
    var
        CallerModuleInfo: ModuleInfo;
    begin
        NavApp.GetCallerModuleInfo(CallerModuleInfo);
        exit(AzureOpenAIImpl.GenerateTextCompletion(Prompt, AOAIOperationResponse, CallerModuleInfo));
    end;

    /// <summary>
    /// Generates a completion given a prompt and completion parameters.
    /// </summary>
    /// <param name="Prompt">The prompt to generate completion for.</param>
    /// <param name="AOAICompletionParams">The optional completion parameters to use.</param>
    /// <param name="AOAIOperationResponse">The response of the operation upon successful or failure execution.</param>
    /// <returns>The generated completion.</returns>
    /// <error>The completion authentication was not configured.</error>
    /// <error>The completion generation failed with status code %1.</error>
    [NonDebuggable]
    procedure GenerateTextCompletion(Prompt: SecretText; AOAICompletionParams: Codeunit "AOAI Text Completion Params"; var AOAIOperationResponse: Codeunit "AOAI Operation Response"): Text
    var
        CallerModuleInfo: ModuleInfo;
    begin
        NavApp.GetCallerModuleInfo(CallerModuleInfo);
        exit(AzureOpenAIImpl.GenerateTextCompletion(Prompt, AOAICompletionParams, AOAIOperationResponse, CallerModuleInfo));
    end;

    /// <summary>
    /// Generates a text completion given a prompt.
    /// </summary>
    /// <param name="Metaprompt">The metaprompt to be appended with the prompt.</param>
    /// <param name="Prompt">The prompt to generate completion for.</param>
    /// <param name="AOAIOperationResponse">The response of the operation upon successful or failure execution.</param>
    /// <returns>The generated completion.</returns>
    /// <error>The completion authentication was not configured.</error>
    /// <error>The completion generation failed with status code %1.</error>
    [NonDebuggable]
    procedure GenerateTextCompletion(Metaprompt: SecretText; Prompt: SecretText; var AOAIOperationResponse: Codeunit "AOAI Operation Response"): Text
    var
        CallerModuleInfo: ModuleInfo;
    begin
        NavApp.GetCallerModuleInfo(CallerModuleInfo);
        exit(AzureOpenAIImpl.GenerateTextCompletion(Metaprompt, Prompt, AOAIOperationResponse, CallerModuleInfo));
    end;

    /// <summary>
    /// Generates a completion given a prompt and completion parameters.
    /// </summary>
    /// <param name="Metaprompt">The metaprompt to be appended with the prompt.</param>
    /// <param name="Prompt">The prompt to generate completion for.</param>
    /// <param name="AOAICompletionParams">The optional completion parameters to use.</param>
    /// <param name="AOAIOperationResponse">The response of the operation upon successful or failure execution.</param>
    /// <returns>The generated completion.</returns>
    /// <error>The completion authentication was not configured.</error>
    /// <error>The completion generation failed with status code %1.</error>
    [NonDebuggable]
    procedure GenerateTextCompletion(Metaprompt: SecretText; Prompt: SecretText; AOAICompletionParams: Codeunit "AOAI Text Completion Params"; var AOAIOperationResponse: Codeunit "AOAI Operation Response"): Text
    var
        CallerModuleInfo: ModuleInfo;
    begin
        NavApp.GetCallerModuleInfo(CallerModuleInfo);
        exit(AzureOpenAIImpl.GenerateTextCompletion(Metaprompt, Prompt, AOAICompletionParams, AOAIOperationResponse, CallerModuleInfo));
    end;


    /// <summary>
    /// Generates embeddings given an input.
    /// </summary>
    /// <param name="Input">The input to generate embedding for.</param>
    /// <param name="AOAIOperationResponse">The response of the operation upon successful or failure execution.</param>
    /// <returns>The generated list of embeddings.</returns>
    /// <error>The embedding authentication was not configured.</error>
    /// <error>The embedding generation failed with status code %1.</error>
    [NonDebuggable]
    procedure GenerateEmbeddings(Input: SecretText; var AOAIOperationResponse: Codeunit "AOAI Operation Response"): List of [Decimal]
    var
        CallerModuleInfo: ModuleInfo;
    begin
        NavApp.GetCallerModuleInfo(CallerModuleInfo);
        exit(AzureOpenAIImpl.GenerateEmbeddings(Input, AOAIOperationResponse, CallerModuleInfo));
    end;

    /// <summary>
    /// Generates a chat completion given a list of chat messages.
    /// </summary>
    /// <param name="AOAIChatMessages">The chat messages to generate completion for.</param>
    /// <param name="AOAIOperationResponse">The response of the operation upon successful or failure execution.</param>
    /// <returns>The generated chat completion.</returns>
    /// <error>The chat completion authentication was not configured.</error>
    /// <error>The chat completion generation failed with status code %1.</error>
    [NonDebuggable]
    procedure GenerateChatCompletion(var AOAIChatMessages: Codeunit "AOAI Chat Messages"; var AOAIOperationResponse: Codeunit "AOAI Operation Response")
    var
        CallerModuleInfo: ModuleInfo;
    begin
        NavApp.GetCallerModuleInfo(CallerModuleInfo);
        AzureOpenAIImpl.GenerateChatCompletion(AOAIChatMessages, AOAIOperationResponse, CallerModuleInfo);
    end;

    /// <summary>
    /// Generates a chat completion given a list of chat messages and completion parameters.
    /// </summary>
    /// <param name="AOAIChatMessages">The chat messages to generate completion for.</param>
    /// <param name="AOAIChatCompletionParams">The optional chat completion parameters to use.</param>
    /// <param name="AOAIOperationResponse">The response of the operation upon successful or failure execution.</param>
    /// <returns>The generated chat completion.</returns>
    /// <error>The chat completion authentication was not configured.</error>
    /// <error>The chat completion generation failed with status code %1.</error>
    [NonDebuggable]
    procedure GenerateChatCompletion(var AOAIChatMessages: Codeunit "AOAI Chat Messages"; AOAIChatCompletionParams: Codeunit "AOAI Chat Completion Params"; var AOAIOperationResponse: Codeunit "AOAI Operation Response")
    var
        CallerModuleInfo: ModuleInfo;
    begin
        NavApp.GetCallerModuleInfo(CallerModuleInfo);
        AzureOpenAIImpl.GenerateChatCompletion(AOAIChatMessages, AOAIChatCompletionParams, AOAIOperationResponse, CallerModuleInfo);
    end;

    /// <summary>
    /// Sets the copilot capability that the API is running for.
    /// </summary>
    /// <param name="CopilotCapability">The copilot capability to set.</param>
    [NonDebuggable]
    procedure SetCopilotCapability(CopilotCapability: Enum "Copilot Capability")
    var
        CallerModuleInfo: ModuleInfo;
    begin
        NavApp.GetCallerModuleInfo(CallerModuleInfo);
        AzureOpenAIImpl.SetCopilotCapability(CopilotCapability, CallerModuleInfo);
    end;
}