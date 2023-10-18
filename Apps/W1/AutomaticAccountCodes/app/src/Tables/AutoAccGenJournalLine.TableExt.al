// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------
namespace Microsoft.Finance.AutomaticAccounts;

using Microsoft.Finance.GeneralLedger.Journal;
using System.Telemetry;

tableextension 4851 "AutoAcc Gen. Journal Line" extends "Gen. Journal Line"
{
    fields
    {
        field(4852; "Automatic Account Group"; Code[10])
        {
            Caption = 'Automatic Account Group';
            TableRelation = "Automatic Account Header";

            trigger OnValidate()
            var
                FeatureTelemetry: Codeunit "Feature Telemetry";
                AacTok: Label 'W1 Automatic Account', Locked = true;
            begin
                FeatureTelemetry.LogUptake('0001P9M', AacTok, Enum::"Feature Uptake Status"::"Used");
                TestField("Account Type", "Account Type"::"G/L Account");
                FeatureTelemetry.LogUsage('0001P9N', AacTok, 'Automatic account codes generated');
            end;

        }

    }
}
