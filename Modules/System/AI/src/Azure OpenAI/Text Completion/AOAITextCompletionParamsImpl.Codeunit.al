// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------
namespace System.AI;

codeunit 7766 "AOAI TextCompletionParams Impl"
{
    Access = Internal;
    InherentEntitlements = X;
    InherentPermissions = X;

    var
        Initialized: Boolean;
        MaxTokens: Integer;
        Temperature: Decimal;
        TopP: Decimal;
        Suffix: Text;
        PresencePenalty: Decimal;
        FrequencyPenalty: Decimal;
        TemperatureErr: Label 'Temperature must be between 0.0 and 2.0.';
        PresencePenaltyErr: Label 'Presence penalty must be between -2.0 and 2.0.';
        FrequencyPenaltyErr: Label 'Frequency penalty must be between -2.0 and 2.0.';

    procedure GetMaxTokens(): Integer
    begin
        if not Initialized then
            InitializeDefaults();

        exit(MaxTokens);
    end;

    procedure GetTemperature(): Decimal
    begin
        if not Initialized then
            InitializeDefaults();

        exit(Temperature);
    end;

    procedure GetTopP(): Decimal
    begin
        if not Initialized then
            InitializeDefaults();

        exit(TopP);
    end;

    procedure GetSuffix(): Text
    begin
        if not Initialized then
            InitializeDefaults();

        exit(Suffix);
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

    procedure SetMaxTokens(NewMaxTokens: Integer)
    begin
        if not Initialized then
            InitializeDefaults();

        MaxTokens := NewMaxTokens;
    end;

    procedure SetTemperature(NewTemperature: Decimal)
    begin
        if not Initialized then
            InitializeDefaults();

        if (NewTemperature < 0.0) or (NewTemperature > 2.0) then
            Error(TemperatureErr);

        Temperature := NewTemperature;
    end;

    procedure SetTopP(NewTopP: Decimal)
    begin
        if not Initialized then
            InitializeDefaults();

        TopP := NewTopP;
    end;

    procedure SetSuffix(NewSuffix: Text)
    begin
        if not Initialized then
            InitializeDefaults();

        Suffix := NewSuffix;
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
    procedure AddCompletionsParametersToPayload(var Payload: JsonObject)
    begin
        if GetMaxTokens() > 0 then
            Payload.Add('max_tokens', GetMaxTokens());

        if GetSuffix() <> '' then
            Payload.Add('suffix', GetSuffix());

        Payload.Add('temperature', GetTemperature());
        Payload.Add('top_p', GetTopP());
        Payload.Add('presence_penalty', GetPresencePenalty());
        Payload.Add('frequency_penalty', GetFrequencyPenalty());
    end;

    local procedure InitializeDefaults()
    begin
        Initialized := true;

        SetMaxTokens(256);
        SetTemperature(1);
        SetTopP(1);
        SetPresencePenalty(0);
        SetFrequencyPenalty(0);
    end;
}