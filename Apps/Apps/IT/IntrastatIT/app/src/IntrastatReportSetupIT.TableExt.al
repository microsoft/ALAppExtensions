// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------
namespace Microsoft.Inventory.Intrastat;

using System.IO;

tableextension 148123 "Intrastat Report Setup IT" extends "Intrastat Report Setup"
{
    fields
    {
        field(148121; "Data Exch. Def. Code NPM"; Code[20])
        {
            Caption = 'Data Exch. Def. Normal Purchase Monthly Code';
            TableRelation = "Data Exch. Def";
        }
        field(148122; "Data Exch. Def. Name NPM"; Text[100])
        {
            Caption = 'Data Exch. Def. Normal Purchase Monthly Name';
            CalcFormula = Lookup("Data Exch. Def".Name where(Code = field("Data Exch. Def. Code NPM")));
            Editable = false;
            FieldClass = FlowField;
        }
        field(148123; "Data Exch. Def. Code NSM"; Code[20])
        {
            Caption = 'Data Exch. Def. Normal Sale Monthly Code';
            TableRelation = "Data Exch. Def";
        }
        field(148124; "Data Exch. Def. Name NSM"; Text[100])
        {
            Caption = 'Data Exch. Def. Normal Sale Monthly Name';
            CalcFormula = Lookup("Data Exch. Def".Name where(Code = field("Data Exch. Def. Code NSM")));
            Editable = false;
            FieldClass = FlowField;
        }
        field(148125; "Data Exch. Def. Code NPQ"; Code[20])
        {
            Caption = 'Data Exch. Def. Normal Purchase Quarterly Code';
            TableRelation = "Data Exch. Def";
        }
        field(148126; "Data Exch. Def. Name NPQ"; Text[100])
        {
            Caption = 'Data Exch. Def. Normal Purchase Quarterly Name';
            CalcFormula = Lookup("Data Exch. Def".Name where(Code = field("Data Exch. Def. Code NPQ")));
            Editable = false;
            FieldClass = FlowField;
        }
        field(148127; "Data Exch. Def. Code NSQ"; Code[20])
        {
            Caption = 'Data Exch. Def. Normal Sale Quarterly Code';
            TableRelation = "Data Exch. Def";
        }
        field(148128; "Data Exch. Def. Name NSQ"; Text[100])
        {
            Caption = 'Data Exch. Def. Normal Sale Quarterly Name';
            CalcFormula = Lookup("Data Exch. Def".Name where(Code = field("Data Exch. Def. Code NSQ")));
            Editable = false;
            FieldClass = FlowField;
        }
        field(148129; "Data Exch. Def. Code CPM"; Code[20])
        {
            Caption = 'Data Exch. Def. Corrective Purchase Monthly Code';
            TableRelation = "Data Exch. Def";
        }
        field(148130; "Data Exch. Def. Name CPM"; Text[100])
        {
            Caption = 'Data Exch. Def. Corrective Purchase Monthly Name';
            CalcFormula = Lookup("Data Exch. Def".Name where(Code = field("Data Exch. Def. Code CPM")));
            Editable = false;
            FieldClass = FlowField;
        }
        field(148131; "Data Exch. Def. Code CSM"; Code[20])
        {
            Caption = 'Data Exch. Def. Corrective Sale Monthly Code';
            TableRelation = "Data Exch. Def";
        }
        field(148132; "Data Exch. Def. Name CSM"; Text[100])
        {
            Caption = 'Data Exch. Def. Corrective Sale Monthly Name';
            CalcFormula = Lookup("Data Exch. Def".Name where(Code = field("Data Exch. Def. Code CSM")));
            Editable = false;
            FieldClass = FlowField;
        }
        field(148133; "Data Exch. Def. Code CPQ"; Code[20])
        {
            Caption = 'Data Exch. Def. Corrective Purchase Quarterly Code';
            TableRelation = "Data Exch. Def";
        }
        field(148134; "Data Exch. Def. Name CPQ"; Text[100])
        {
            Caption = 'Data Exch. Def. Corrective Purchase Quarterly Name';
            CalcFormula = Lookup("Data Exch. Def".Name where(Code = field("Data Exch. Def. Code CPQ")));
            Editable = false;
            FieldClass = FlowField;
        }
        field(148135; "Data Exch. Def. Code CSQ"; Code[20])
        {
            Caption = 'Data Exch. Def. Corrective Sale Quarterly Code';
            TableRelation = "Data Exch. Def";
        }
        field(148136; "Data Exch. Def. Name CSQ"; Text[100])
        {
            Caption = 'Data Exch. Def. Corrective Sale Quarterly Name';
            CalcFormula = Lookup("Data Exch. Def".Name where(Code = field("Data Exch. Def. Code CSQ")));
            Editable = false;
            FieldClass = FlowField;
        }
    }
}