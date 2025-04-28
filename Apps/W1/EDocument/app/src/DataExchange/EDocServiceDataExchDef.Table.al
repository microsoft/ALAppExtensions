// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------
namespace Microsoft.eServices.EDocument.IO.Peppol;

using Microsoft.eServices.EDocument;
using System.IO;

table 6139 "E-Doc. Service Data Exch. Def."
{
    Access = Internal;
    DataClassification = CustomerContent;
    ReplicateData = false;

    fields
    {
        field(1; "E-Document Format Code"; Code[20])
        {
            Caption = 'Code';
        }
        field(2; "Document Type"; Enum "E-Document Type")
        {
            Caption = 'Document Type';
        }
        field(3; "Impt. Data Exchange Def. Code"; Code[20])
        {
            Caption = 'Import Data Exchange Def. Code';
            TableRelation = "Data Exch. Def";
        }
        field(4; "Impt. Data Exchange Def. Name"; Text[100])
        {
            Caption = 'Import Data Exchange Def. Name';
            FieldClass = FlowField;
            CalcFormula = lookup("Data Exch. Def".Name where(Code = field("Impt. Data Exchange Def. Code")));
            Editable = false;
        }
        field(5; "Expt. Data Exchange Def. Code"; Code[20])
        {
            Caption = 'Export Data Exchange Def. Code';
            TableRelation = "Data Exch. Def";
        }
        field(6; "Expt. Data Exchange Def. Name"; Text[100])
        {
            Caption = 'Export Data Exchange Def. Name';
            FieldClass = FlowField;
            CalcFormula = lookup("Data Exch. Def".Name where(Code = field("Expt. Data Exchange Def. Code")));
            Editable = false;
        }
    }

    keys
    {
        key(Key1; "E-Document Format Code", "Document Type")
        {
            Clustered = true;
        }
    }
}