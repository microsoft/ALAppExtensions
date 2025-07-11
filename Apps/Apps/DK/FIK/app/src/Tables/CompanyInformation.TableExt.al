// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------

namespace Microsoft.Bank.Payment;

using Microsoft.Foundation.Company;
using System.Telemetry;

tableextension 13614 CompanyInformation extends "Company Information"
{
    fields
    {
        field(13651; BankCreditorNo; Code[8])
        {
            Caption = 'Bank Creditor No.';
            trigger OnValidate();
            var
                FeatureTelemetry: Codeunit "Feature Telemetry";
                FikTok: Label 'DK FIK', Locked = true;
            begin
                FeatureTelemetry.LogUptake('0010H8X', FikTok, Enum::"Feature Uptake Status"::Discovered);
                IF BankCreditorNo = '' THEN
                    EXIT;
                IF STRLEN(BankCreditorNo) <> MAXSTRLEN(BankCreditorNo) THEN
                    ERROR(BankCreditorNumberLengthErr, FIELDCAPTION(BankCreditorNo));
            end;
        }
    }
    var
        BankCreditorNumberLengthErr: Label '%1 must be an 8-digit number.', Comment = '%1 = Bank Creditor Number';
}
