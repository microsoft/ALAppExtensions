// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------
namespace Microsoft.Sustainability.FixedAssets;

using Microsoft.FixedAssets.Ledger;
using Microsoft.Foundation.AuditCodes;
using Microsoft.Sustainability.Account;
using Microsoft.Sustainability.Setup;

tableextension 6263 "Sust. FA Ledger Entry" extends "FA Ledger Entry"
{
    fields
    {
        field(6214; "Sust. Account No."; Code[20])
        {
            Caption = 'Sustainability Account No.';
            TableRelation = "Sustainability Account" where("Account Type" = const(Posting), Blocked = const(false));
            DataClassification = CustomerContent;
        }
        field(6215; "Sust. Account Name"; Text[100])
        {
            Caption = 'Sustainability Account Name';
            DataClassification = CustomerContent;
        }
        field(6216; "Sust. Account Category"; Code[20])
        {
            Caption = 'Sustainability Account Category';
            Editable = false;
            TableRelation = "Sustain. Account Category";
            DataClassification = CustomerContent;
        }
        field(6217; "Sust. Account Subcategory"; Code[20])
        {
            Caption = 'Sustainability Account Subcategory';
            Editable = false;
            TableRelation = "Sustain. Account Subcategory".Code where("Category Code" = field("Sust. Account Category"));
            DataClassification = CustomerContent;
        }
        field(6219; "Total CO2e"; Decimal)
        {
            AutoFormatType = 11;
            AutoFormatExpression = SustainabilitySetup.GetFormat(SustainabilitySetup.FieldNo("Emission Decimal Places"));
            Caption = 'Total CO2e';
            DataClassification = CustomerContent;
        }
    }

    var
        SustainabilitySetup: Record "Sustainability Setup";

    internal procedure IsSourcePurchase(): Boolean
    var
        SourceCodeSetup: Record "Source Code Setup";
    begin
        SourceCodeSetup.SetLoadFields(Purchases);
        SourceCodeSetup.Get();

        exit(Rec."Source Code" = SourceCodeSetup.Purchases);
    end;

    internal procedure IsSourceSales(): Boolean
    var
        SourceCodeSetup: Record "Source Code Setup";
    begin
        SourceCodeSetup.SetLoadFields(Sales);
        SourceCodeSetup.Get();

        exit(Rec."Source Code" = SourceCodeSetup.Sales);
    end;
}