// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------
namespace Microsoft.Finance.GST.Payments;

using Microsoft.Finance.GeneralLedger.Account;
using Microsoft.Finance.GST.Base;

table 18243 "Bank Charge"
{
    Caption = 'Bank Charge';
    DataCaptionFields = Code, Description;

    fields
    {
        field(1; Code; Code[10])
        {
            Caption = 'Code';
            DataClassification = CustomerContent;
        }
        field(2; Description; text[50])
        {
            Caption = 'Description';
            DataClassification = CustomerContent;
        }
        field(3; Account; code[20])
        {
            Caption = 'Account';
            DataClassification = CustomerContent;
            TableRelation = "G/L Account";
        }
        field(4; "Foreign Exchange"; Boolean)
        {
            Caption = 'Foreign Exchange';
            DataClassification = CustomerContent;
        }
        field(5; "GST Group Code"; code[10])
        {
            Caption = 'GST Group Code';
            DataClassification = CustomerContent;
            TableRelation = "GST Group";
        }
        field(6; "HSN/SAC Code"; Code[10])
        {
            Caption = 'HSN/SAC Code';
            DataClassification = CustomerContent;
            TableRelation = "HSN/SAC".Code where("GST Group Code" = field("GST Group Code"));
        }
        field(7; "GST Credit"; Enum "GST Credit")
        {
            Caption = 'GST Credit Availment';
            DataClassification = CustomerContent;
        }
        field(8; Exempted; boolean)
        {
            Caption = 'Exempted';
            DataClassification = CustomerContent;
        }
    }

    keys
    {
        key(PK; Code)
        {
            Clustered = true;
        }
    }
}
