// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------

codeunit 8890 "Send Email"
{
    Access = Internal;
    TableNo = "Email Message";

    trigger OnRun()
    var
        EmailMessage: Codeunit "Email Message";
        FeatureTelemetry: Codeunit "Feature Telemetry";
    begin
        FeatureTelemetry.LogUptake('0000D0X', EmailFeatureNameLbl, Enum::"Feature Uptake Status"::Used, false, Dimensions);

        EmailMessage.Get(Rec.Id);
        EmailConnector.Send(EmailMessage, AccountId);
    end;

    procedure SetConnector(NewEmailConnector: Interface "Email Connector")
    begin
        EmailConnector := NewEmailConnector;
    end;

    procedure SetAccount(NewAccountId: Guid)
    begin
        AccountId := NewAccountId;
    end;

    procedure SetTelemetryDimensions(TelemetryDimensions: Dictionary of [Text, Text])
    begin
        Dimensions := TelemetryDimensions;
    end;

    var
        EmailConnector: Interface "Email Connector";
        Dimensions: Dictionary of [Text, Text];
        AccountId: Guid;
        EmailFeatureNameLbl: Label 'Emailing', Locked = true;
}