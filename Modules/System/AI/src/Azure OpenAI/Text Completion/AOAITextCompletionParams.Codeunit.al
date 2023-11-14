// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------
namespace System.AI;

/// <summary>
/// Represents the Completion parameters used by the API. 
/// See more details at https://aka.ms/AAlsi39.
/// </summary>
codeunit 7765 "AOAI Text Completion Params"
{
    Access = Public;
    InherentEntitlements = X;
    InherentPermissions = X;

    var
        AOAITextCompletionParamsImpl: Codeunit "AOAI TextCompletionParams Impl";

    /// <summary>
    /// Get the maximum number of tokens to generate in the completion.
    /// </summary>
    /// <returns>The maximum number of tokens to generate in the completion.</returns>
    /// <remarks>0 or less uses the API default.</remarks>
    procedure GetMaxTokens(): Integer
    begin
        exit(AOAITextCompletionParamsImpl.GetMaxTokens());
    end;

    /// <summary>
    /// Get the sampling temperature to use.
    /// </summary>
    /// <returns>The sampling temperature to use.</returns>
    procedure GetTemperature(): Decimal
    begin
        exit(AOAITextCompletionParamsImpl.GetTemperature());
    end;

    /// <summary>
    /// Get the nucleus sampling to use.
    /// </summary>
    /// <returns>The nucleus sampling to use.</returns>
    procedure GetTopP(): Decimal
    begin
        exit(AOAITextCompletionParamsImpl.GetTopP());
    end;

    /// <summary>
    /// Get the suffix that comes after a completion of inserted text.
    /// </summary>
    /// <returns>The suffix that comes after a completion of inserted text.</returns>
    procedure GetSuffix(): Text
    begin
        exit(AOAITextCompletionParamsImpl.GetSuffix());
    end;

    /// <summary>
    /// Get the presence penalty to use.
    /// </summary>
    /// <returns>The presence penalty to use.</returns>
    procedure GetPresencePenalty(): Decimal
    begin
        exit(AOAITextCompletionParamsImpl.GetPresencePenalty());
    end;

    /// <summary>
    /// Get the frequency penalty to use.
    /// </summary>
    /// <returns>The frequency penalty to use.</returns>
    procedure GetFrequencyPenalty(): Decimal
    begin
        exit(AOAITextCompletionParamsImpl.GetFrequencyPenalty());
    end;

    /// <summary>
    /// The maximum number of tokens to generate in the completion. The token count of your prompt plus max_tokens can't exceed the model's context length. Most models have a context length of 2048 tokens (except for the newest models, which support 4096).
    /// </summary>
    /// <param name="NewMaxTokens">The new maximum number of tokens to generate in the completion.</param>
    /// <remarks>If the prompt's tokens + max_tokens exceeds the model's context length, the generate request will return an error.</remarks>
    /// <remarks>The default value is 256 however a value of 0 or less will use the deployment model's default.</remarks>
    procedure SetMaxTokens(NewMaxTokens: Integer)
    begin
        AOAITextCompletionParamsImpl.SetMaxTokens(NewMaxTokens);
    end;

    /// <summary>
    /// Sets the sampling temperature to use, between 0 and 2. A higher temperature increases the likelihood that the next most probable token will not be selected. When requesting structured data, set the temperature to 0. For human sounding speech, 0.7 is a typical value
    /// </summary>
    /// <param name="NewTemperature">The new sampling temperature to use.</param>
    /// <error>Temperature must be between 0.0 and 2.0</error>
    procedure SetTemperature(NewTemperature: Decimal)
    begin
        AOAITextCompletionParamsImpl.SetTemperature(NewTemperature);
    end;

    /// <summary>
    ///	An alternative to sampling with temperature, called nucleus sampling, where the model considers the results of the tokens with top_p probability mass. So 0.1 means only the tokens comprising the top 10% probability mass are considered. We generally recommend altering this or temperature but not both.
    /// </summary>
    /// <param name="NewTopP">New nucleus sampling to use</param>
    procedure SetTopP(NewTopP: Decimal)
    begin
        AOAITextCompletionParamsImpl.SetTopP(NewTopP);
    end;

    /// <summary>
    /// The suffix that comes after a completion of inserted text.
    /// </summary>
    /// <param name="NewSuffix">The new suffix that comes after a completion of inserted text.</param>
    procedure SetSuffix(NewSuffix: Text)
    begin
        AOAITextCompletionParamsImpl.SetSuffix(NewSuffix);
    end;

    /// <summary>
    /// Number between -2.0 and 2.0. Positive values penalize new tokens based on whether they appear in the text so far, increasing the model's likelihood to talk about new topics.
    /// </summary>
    /// <param name="NewPresencePenalty">The new presence penalty to use.</param>
    /// <error>Presence penalty must be between -2.0 and 2.0</error>
    procedure SetPresencePenalty(NewPresencePenalty: Decimal)
    begin
        AOAITextCompletionParamsImpl.SetPresencePenalty(NewPresencePenalty);
    end;

    /// <summary>
    /// Number between -2.0 and 2.0. Positive values penalize new tokens based on their existing frequency in the text so far, decreasing the model's likelihood to repeat the same line verbatim.
    /// </summary>
    /// <param name="NewFrequencyPenalty">The new frequency penalty to use.</param>
    /// <error>Frequency penalty must be between -2.0 and 2.0</error>
    procedure SetFrequencyPenalty(NewFrequencyPenalty: Decimal)
    begin
        AOAITextCompletionParamsImpl.SetFrequencyPenalty(NewFrequencyPenalty);
    end;

    /// <summary>
    /// Add the completion parameters to the payload.
    /// </summary>
    /// <param name="Payload">The JsonObject payload to add the completion parameters to.</param>
    [NonDebuggable]
    internal procedure AddCompletionsParametersToPayload(var Payload: JsonObject)
    begin
        AOAITextCompletionParamsImpl.AddCompletionsParametersToPayload(Payload);
    end;
}