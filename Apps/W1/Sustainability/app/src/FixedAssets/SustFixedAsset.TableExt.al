// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------
namespace Microsoft.Sustainability.FixedAssets;

using Microsoft.FixedAssets.FixedAsset;
using Microsoft.Sustainability.Account;
using Microsoft.Sustainability.Setup;

tableextension 6267 "Sust. Fixed Asset" extends "Fixed Asset"
{
    fields
    {
        field(6210; "Default Sust. Account"; Code[20])
        {
            DataClassification = CustomerContent;
            TableRelation = "Sustainability Account" where("Account Type" = const(Posting), Blocked = const(false));
            Caption = 'Default Sust. Account';

            trigger OnValidate()
            var
                SustainabilityAccount: Record "Sustainability Account";
            begin
                if Rec."Default Sust. Account" = '' then
                    ClearDefaultEmissionInformation(Rec)
                else begin
                    SustainabilityAccount.Get(Rec."Default Sust. Account");

                    SustainabilityAccount.CheckAccountReadyForPosting();
                    SustainabilityAccount.TestField("Direct Posting", true);
                end;
            end;
        }
        field(6211; "Default CO2 Emission"; Decimal)
        {
            AutoFormatType = 11;
            AutoFormatExpression = SustainabilitySetup.GetFormat(SustainabilitySetup.FieldNo("Emission Decimal Places"));
            Caption = 'Default CO2 Emission';
            CaptionClass = '102,10,1';
            DataClassification = CustomerContent;

            trigger OnValidate()
            begin
                if Rec."Default CO2 Emission" <> 0 then
                    Rec.TestField("Default Sust. Account");
            end;
        }
        field(6212; "Default CH4 Emission"; Decimal)
        {
            AutoFormatType = 11;
            AutoFormatExpression = SustainabilitySetup.GetFormat(SustainabilitySetup.FieldNo("Emission Decimal Places"));
            Caption = 'Default CH4 Emission';
            CaptionClass = '102,10,2';
            DataClassification = CustomerContent;

            trigger OnValidate()
            begin
                if Rec."Default CH4 Emission" <> 0 then
                    Rec.TestField("Default Sust. Account");
            end;
        }
        field(6213; "Default N2O Emission"; Decimal)
        {
            AutoFormatType = 11;
            AutoFormatExpression = SustainabilitySetup.GetFormat(SustainabilitySetup.FieldNo("Emission Decimal Places"));
            Caption = 'Default N2O Emission';
            CaptionClass = '102,10,3';
            DataClassification = CustomerContent;

            trigger OnValidate()
            begin
                if Rec."Default N2O Emission" <> 0 then
                    Rec.TestField("Default Sust. Account");
            end;
        }
    }

    var
        SustainabilitySetup: Record "Sustainability Setup";

    local procedure ClearDefaultEmissionInformation(var FixedAsset: Record "Fixed Asset")
    begin
        FixedAsset.Validate("Default N2O Emission", 0);
        FixedAsset.Validate("Default CH4 Emission", 0);
        FixedAsset.Validate("Default CO2 Emission", 0);
    end;
}