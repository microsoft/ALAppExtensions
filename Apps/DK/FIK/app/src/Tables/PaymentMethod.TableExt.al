// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------

namespace Microsoft.Bank.Payment;

using Microsoft.Bank.BankAccount;
using System.Telemetry;

tableextension 13620 PaymentMethod extends "Payment Method"
{
    fields
    {
        field(13652; PaymentTypeValidation; Enum "Payment Type Validation")
        {
            Caption = 'Payment Type Validation';

            trigger OnValidate()
            var
                FeatureTelemetry: Codeunit "Feature Telemetry";
                FikTok: Label 'DK FIK', Locked = true;
            begin
                FeatureTelemetry.LogUptake('0000H8X', FikTok, Enum::"Feature Uptake Status"::"Set up");
            end;
        }
    }
}
