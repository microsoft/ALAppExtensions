// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------
namespace Microsoft.Purchases.History;

using Microsoft.Finance.TDS.TDSBase;

tableextension 18719 "Purch Inv Line" extends "Purch. Inv. Line"
{
    fields
    {
        field(18716; "TDS Section Code"; Code[10])
        {
            Caption = 'TDS Section Code';
            DataClassification = CustomerContent;
        }
        field(18717; "Nature of Remittance"; Code[10])
        {
            Caption = 'Nature of Remittance';
            TableRelation = "TDS Nature of Remittance";
            DataClassification = CustomerContent;
        }
        field(18718; "Act Applicable"; Code[10])
        {
            Caption = 'Act Applicable';
            TableRelation = "Act Applicable";
            DataClassification = CustomerContent;
        }
    }
}
