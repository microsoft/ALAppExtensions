// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------
namespace System.AI;

codeunit 7762 "AOAI Chat Compl Params Impl"
{
    Access = Internal;
    InherentEntitlements = X;
    InherentPermissions = X;

    var
        Initialized: Boolean;
        Temperature: Decimal;
        MaxTokens: Integer;
        MaxHistory: Integer;
        PresencePenalty: Decimal;
        FrequencyPenalty: Decimal;
        TemperatureErr: Label 'Temperature must be between 0.0 and 2.0.';
        PresencePenaltyErr: Label 'Presence penalty must be between -2.0 and 2.0.';
        FrequencyPenaltyErr: Label 'Frequency penalty must be between -2.0 and 2.0.';
        MaxHistoryErr: Label 'Max history cannot be less than 1.';

    procedure GetTemperature(): Decimal
    begin
        if not Initialized then
            InitializeDefaults();

        exit(Temperature);
    end;

    procedure GetMaxTokens(): Integer
    begin
        if not Initialized then
            InitializeDefaults();

        exit(MaxTokens);
    end;

    procedure GetMaxHistory(): Integer
    begin
        if not Initialized then
            InitializeDefaults();

        exit(MaxHistory);
    end;

    procedure GetPresencePenalty(): Decimal
    begin
        if not Initialized then
            InitializeDefaults();

        exit(PresencePenalty);
    end;

    procedure GetFrequencyPenalty(): Decimal
    begin
        if not Initialized then
            InitializeDefaults();

        exit(FrequencyPenalty);
    end;

    procedure SetTemperature(NewTemperature: Decimal)
    begin
        if not Initialized then
            InitializeDefaults();

        if (NewTemperature < 0.0) or (NewTemperature > 2.0) then
            Error(TemperatureErr);

        Temperature := NewTemperature;
    end;

    procedure SetMaxTokens(NewMaxTokens: Integer)
    begin
        if not Initialized then
            InitializeDefaults();

        MaxTokens := NewMaxTokens;
    end;

    procedure SetMaxHistory(NewMaxHistory: Integer)
    begin
        if not Initialized then
            InitializeDefaults();

        if NewMaxHistory < 1 then
            Error(MaxHistoryErr);

        MaxHistory := NewMaxHistory;
    end;

    procedure SetPresencePenalty(NewPresencePenalty: Decimal)
    begin
        if not Initialized then
            InitializeDefaults();

        if (NewPresencePenalty < -2.0) or (NewPresencePenalty > 2.0) then
            Error(PresencePenaltyErr);
        PresencePenalty := NewPresencePenalty;
    end;

    procedure SetFrequencyPenalty(NewFrequencyPenalty: Decimal)
    begin
        if not Initialized then
            InitializeDefaults();

        if (NewFrequencyPenalty < -2.0) or (NewFrequencyPenalty > 2.0) then
            Error(FrequencyPenaltyErr);
        FrequencyPenalty := NewFrequencyPenalty;
    end;

    [NonDebuggable]
    procedure AddChatCompletionsParametersToPayload(var Payload: JsonObject)
    begin
        if GetMaxTokens() > 0 then
            Payload.Add('max_tokens', GetMaxTokens());

        Payload.Add('temperature', GetTemperature());
        Payload.Add('presence_penalty', GetPresencePenalty());
        Payload.Add('frequency_penalty', GetFrequencyPenalty());
    end;

    local procedure InitializeDefaults()
    begin
        Initialized := true;

        SetTemperature(1);
        SetPresencePenalty(0);
        SetFrequencyPenalty(0);
        SetMaxTokens(0);
        SetMaxHistory(10);
    end;
}