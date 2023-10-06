// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------
namespace Microsoft.Sales.FinanceCharge;

using Microsoft.Finance.GST.Base;

tableextension 18162 "GST Issued Fin Chrge Memo Line" extends "Issued Fin. Charge Memo Line"
{
    fields
    {
        field(18141; "GST Place of Supply"; Enum "GST Dependency Type")
        {
            Caption = 'GST Place of Supply';
            DataClassification = CustomerContent;
        }
        field(18142; "GST Group Code"; Code[20])
        {
            Caption = 'GST Group Code';
            TableRelation = "GST Group";
            DataClassification = CustomerContent;
        }
        field(18143; "GST Group Type"; Enum "GST Group Type")
        {
            Caption = 'GST Group Type';
            DataClassification = CustomerContent;
            Editable = false;
        }
        field(18144; "HSN/SAC Code"; Code[10])
        {
            Caption = 'HSN/SAC Code';
            TableRelation = "HSN/SAC".Code where("GST Group Code" = field("GST Group Code"));
            DataClassification = CustomerContent;
        }
        field(18145; "GST Jurisdiction Type"; Enum "GST Jurisdiction Type")
        {
            Caption = 'GST Jurisdiction Type';
            DataClassification = CustomerContent;
            Editable = false;
        }
        field(18146; "GST Rounding Line"; Boolean)
        {
            Caption = 'GST Rounding Line';
            DataClassification = CustomerContent;
        }
        field(18147; "Exempted"; Boolean)
        {
            Caption = 'Exempted';
            DataClassification = CustomerContent;
        }
        field(18148; "Non-GST Line"; Boolean)
        {
            Caption = 'Non-GST Line';
            DataClassification = CustomerContent;
        }
    }
}
