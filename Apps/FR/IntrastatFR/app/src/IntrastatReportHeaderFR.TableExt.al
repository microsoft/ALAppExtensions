// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------
namespace Microsoft.Inventory.Intrastat;

tableextension 10851 "Intrastat Report Header FR" extends "Intrastat Report Header"
{
    fields
    {
        field(10851; "Obligation Level"; Enum "Obligation Level")
        {
            Caption = 'Obligation Level';

            trigger OnValidate()
            begin
                SetTransactionSpecFilter();
            end;
        }
        field(10852; "Trans. Spec. Filter"; Text[256])
        {
            Caption = 'Transaction Specification Filter';
        }
    }
    local procedure SetTransactionSpecFilter()
    begin
        // transaction codes 11 and 19 are for receipts, they are not reported for level 4 and 5.
        case Rec."Obligation Level" of
            Rec."Obligation Level"::"1":
                "Trans. Spec. Filter" := '11|19|21|29';
            Rec."Obligation Level"::"4":
                "Trans. Spec. Filter" := '<>29&<>11&<>19';
            Rec."Obligation Level"::"5":
                "Trans. Spec. Filter" := '<>11&<>19';
            else
                "Trans. Spec. Filter" := '';
        end;
    end;
}