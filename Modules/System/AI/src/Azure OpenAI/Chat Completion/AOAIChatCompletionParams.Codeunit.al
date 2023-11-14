// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------
namespace System.AI;

/// <summary>
/// Represents the Chat Completion parameters used by the API. 
/// See more details at https://aka.ms/AAlrz36.
/// </summary>
codeunit 7761 "AOAI Chat Completion Params"
{
    Access = Public;
    InherentEntitlements = X;
    InherentPermissions = X;

    var
        AOAIChatComplParamsImpl: Codeunit "AOAI Chat Compl Params Impl";

    /// <summary>
    /// What sampling temperature to use, between 0 and 2. Higher values like 0.8 will make the output more random, while lower values like 0.2 will make it more focused and deterministic.
    /// </summary>
    /// <returns>The sampling temperature being used.</returns>
    procedure GetTemperature(): Decimal
    begin
        exit(AOAIChatComplParamsImpl.GetTemperature());
    end;

    /// <summary>
    /// Gets the maximum number of tokens allowed for the generated answer.
    /// </summary>
    /// <returns>The maximum number of tokens allowed for the generated answer.</returns>
    /// <remarks>0 or less uses the API default.</remarks>
    procedure GetMaxTokens(): Integer
    begin
        exit(AOAIChatComplParamsImpl.GetMaxTokens());
    end;

    /// <summary>
    /// Gets the maximum number of messages to send back as the message history.
    /// </summary>
    /// <returns>The maximum number of messages to send.</returns>
    procedure GetMaxHistory(): Integer
    begin
        exit(AOAIChatComplParamsImpl.GetMaxHistory());
    end;

    /// <summary>
    /// Gets the presence penalty value.
    /// </summary>
    /// <returns>The presence penalty value.</returns>
    procedure GetPresencePenalty(): Decimal
    begin
        exit(AOAIChatComplParamsImpl.GetPresencePenalty());
    end;

    /// <summary>
    /// Gets the frequency penalty value.
    /// </summary>
    /// <returns>The frequency penalty value.</returns>
    procedure GetFrequencyPenalty(): Decimal
    begin
        exit(AOAIChatComplParamsImpl.GetFrequencyPenalty());
    end;

    /// <summary>
    /// Sets the sampling temperature to use, between 0 and 2. A higher temperature increases the likelihood that the next most probable token will not be selected. When requesting structured data, set the temperature to 0. For human sounding speech, 0.7 is a typical value
    /// </summary>
    /// <param name="NewTemperature">The new sampling temperature to use.</param>
    /// <error>Temperature must be between 0.0 and 2.0.</error>
    procedure SetTemperature(NewTemperature: Decimal)
    begin
        AOAIChatComplParamsImpl.SetTemperature(NewTemperature);
    end;

    /// <summary>
    /// Sets the maximum number of tokens allowed for the generated answer. The maximum number of tokens allowed for the generated answer. By default, the number of tokens the model can return will be (4096 - prompt tokens).
    /// </summary>
    /// <param name="NewMaxTokens">The new maximum number of tokens allowed for the generated answer.</param>
    /// <remarks>If the prompt's tokens + max_tokens exceeds the model's context length, the generate request will return an error.</remarks>
    /// <remarks>0 or less uses the API default.</remarks>
    procedure SetMaxTokens(NewMaxTokens: Integer)
    begin
        AOAIChatComplParamsImpl.SetMaxTokens(NewMaxTokens);
    end;

    /// <summary>
    /// Sets the maximum number of messages to send back as the message history.
    /// </summary>
    /// <param name="NewMaxHistory">The new maximum number of messages to send.</param>
    /// <error>Max history cannot be less than 1.</error>
    /// <remarks>The default is 10 messages including the primary System Message.</remarks>
    procedure SetMaxHistory(NewMaxHistory: Integer)
    begin
        AOAIChatComplParamsImpl.SetMaxHistory(NewMaxHistory);
    end;

    /// <summary>
    /// Number between -2.0 and 2.0. Positive values penalize new tokens based on whether they appear in the text so far, increasing the model's likelihood to talk about new topics.
    /// </summary>
    /// <param name="NewPresencePenalty">The new presence penalty value.</param>
    /// <error>Presence penalty must be between -2.0 and 2.0.</error>
    procedure SetPresencePenalty(NewPresencePenalty: Decimal)
    begin
        AOAIChatComplParamsImpl.SetPresencePenalty(NewPresencePenalty);
    end;

    /// <summary>
    /// Number between -2.0 and 2.0. Positive values penalize new tokens based on their existing frequency in the text so far, decreasing the model's likelihood to repeat the same line verbatim.
    /// </summary>
    /// <param name="NewFrequencyPenalty">The new frequency penalty value.</param>
    /// <error>Frequency penalty must be between -2.0 and 2.0.</error>
    procedure SetFrequencyPenalty(NewFrequencyPenalty: Decimal)
    begin
        AOAIChatComplParamsImpl.SetFrequencyPenalty(NewFrequencyPenalty);
    end;

    /// <summary>
    /// Adds the Chat Completion parameters to the payload.
    /// </summary>
    /// <param name="Payload">JsonObject to add parameters to.</param>
    [NonDebuggable]
    internal procedure AddChatCompletionsParametersToPayload(var Payload: JsonObject)
    begin
        AOAIChatComplParamsImpl.AddChatCompletionsParametersToPayload(Payload);
    end;
}