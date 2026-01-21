// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------
namespace Microsoft.Sustainability.FixedAssets;

using Microsoft.FixedAssets.Depreciation;
using Microsoft.FixedAssets.Ledger;
using Microsoft.Sustainability.Setup;

tableextension 6266 "Sust. FA Depreciation Book" extends "FA Depreciation Book"
{
    fields
    {
        field(6214; "Acquisition Total CO2e"; Decimal)
        {
            AutoFormatType = 11;
            AutoFormatExpression = SustainabilitySetup.GetFormat(SustainabilitySetup.FieldNo("Emission Decimal Places"));
            CalcFormula = sum("FA Ledger Entry"."Total CO2e" where("FA No." = field("FA No."),
                                                                   "Depreciation Book Code" = field("Depreciation Book Code"),
                                                                   "FA Posting Category" = const(" "),
                                                                   "FA Posting Type" = const("Acquisition Cost"),
                                                                   "FA Posting Date" = field("FA Posting Date Filter"),
                                                                   "Sust. Account No." = filter('<>''''')));
            Caption = 'Acquisition Total CO2e';
            Editable = false;
            FieldClass = FlowField;
        }
        field(6215; "Book Total CO2e"; Decimal)
        {
            AutoFormatType = 11;
            AutoFormatExpression = SustainabilitySetup.GetFormat(SustainabilitySetup.FieldNo("Emission Decimal Places"));
            CalcFormula = sum("FA Ledger Entry"."Total CO2e" where("FA No." = field("FA No."),
                                                              "Depreciation Book Code" = field("Depreciation Book Code"),
                                                              "Part of Book Value" = const(true),
                                                              "Sust. Account No." = filter('<>'''''),
                                                              "FA Posting Date" = field("FA Posting Date Filter")));
            Caption = 'Book Total CO2e';
            Editable = false;
            FieldClass = FlowField;
        }
        field(6216; "Proceeds on Disposal CO2e"; Decimal)
        {
            AutoFormatType = 11;
            AutoFormatExpression = SustainabilitySetup.GetFormat(SustainabilitySetup.FieldNo("Emission Decimal Places"));
            CalcFormula = sum("FA Ledger Entry"."Total CO2e" where("FA No." = field("FA No."),
                                                              "Depreciation Book Code" = field("Depreciation Book Code"),
                                                              "FA Posting Category" = const(" "),
                                                              "FA Posting Type" = const("Proceeds on Disposal"),
                                                              "Sust. Account No." = filter('<>'''''),
                                                              "FA Posting Date" = field("FA Posting Date Filter")));
            Caption = 'Proceeds on Disposal (Total CO2e)';
            Editable = false;
            FieldClass = FlowField;
        }
    }

    var
        SustainabilitySetup: Record "Sustainability Setup";
}