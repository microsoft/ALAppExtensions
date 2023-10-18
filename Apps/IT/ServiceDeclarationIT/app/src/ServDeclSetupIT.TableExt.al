// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------
namespace Microsoft.Service.Reports;

using System.IO;

tableextension 12214 "Serv. Decl. Setup IT" extends "Service Declaration Setup"
{
    fields
    {
        field(12214; "Data Exch. Def. Purch. Code"; Code[20])
        {
            Caption = 'Data Exch. Def. Purchase Code';
            TableRelation = "Data Exch. Def";
        }
        field(12215; "Data Exch. Def. Purch. Name"; Text[100])
        {
            Caption = 'Data Exch. Def. Purchase Name';
            CalcFormula = Lookup("Data Exch. Def".Name where(Code = field("Data Exch. Def. Purch. Code")));
            Editable = false;
            FieldClass = FlowField;
        }
        field(12216; "Data Exch. Def. Sale Code"; Code[20])
        {
            Caption = 'Data Exch. Def. Sale Code';
            TableRelation = "Data Exch. Def";
        }
        field(12217; "Data Exch. Def. Sale Name"; Text[100])
        {
            Caption = 'Data Exch. Def. Sale Name';
            CalcFormula = Lookup("Data Exch. Def".Name where(Code = field("Data Exch. Def. Sale Code")));
            Editable = false;
            FieldClass = FlowField;
        }
        field(12218; "Data Exch. Def. P. Corr. Code"; Code[20])
        {
            Caption = 'Data Exch. Def. Purchase Correction Code';
            TableRelation = "Data Exch. Def";
        }
        field(12219; "Data Exch. Def. P. Corr. Name"; Text[100])
        {
            Caption = 'Data Exch. Def. Purchase Correction Name';
            CalcFormula = Lookup("Data Exch. Def".Name where(Code = field("Data Exch. Def. P. Corr. Code")));
            Editable = false;
            FieldClass = FlowField;
        }
        field(12220; "Data Exch. Def. S. Corr. Code"; Code[20])
        {
            Caption = 'Data Exch. Def. Sale Correction Code';
            TableRelation = "Data Exch. Def";
        }
        field(12221; "Data Exch. Def. S. Corr. Name"; Text[100])
        {
            Caption = 'Data Exch. Def. Sale Correction Name';
            CalcFormula = Lookup("Data Exch. Def".Name where(Code = field("Data Exch. Def. S. Corr. Code")));
            Editable = false;
            FieldClass = FlowField;
        }
    }
}
