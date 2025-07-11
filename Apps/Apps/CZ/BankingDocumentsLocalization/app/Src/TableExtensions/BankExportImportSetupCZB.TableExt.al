// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------
namespace Microsoft.Bank.Documents;

using Microsoft.Bank.Setup;
using System.IO;
using System.Reflection;

tableextension 31284 "Bank Export/Import Setup CZB" extends "Bank Export/Import Setup"
{
    fields
    {
        field(11710; "Processing Report ID CZB"; Integer)
        {
            Caption = 'Processing Report ID';
            TableRelation = AllObjWithCaption."Object ID" where("Object Type" = const(Report));
            DataClassification = CustomerContent;

            trigger OnValidate()
            begin
                CalcFields("Processing Report Name CZB");
            end;
        }
        field(11711; "Processing Report Name CZB"; Text[249])
        {
            CalcFormula = lookup(AllObjWithCaption."Object Caption" where("Object Type" = const(Report), "Object ID" = field("Processing Report ID CZB")));
            Caption = 'Processing Report Name';
            Editable = false;
            FieldClass = FlowField;
        }
        field(11712; "Default File Type CZB"; Text[10])
        {
            Caption = 'Default File Type';
            DataClassification = CustomerContent;
        }
    }

    procedure GetFilterTextCZB(): Text
    var
        FileManagement: Codeunit "File Management";
        FileFilterTok: Label '*.%1', Comment = '%1 = Default File Type', Locked = true;
    begin
        exit(FileManagement.GetToFilterText('', StrSubstNo(FileFilterTok, "Default File Type CZB")));
    end;
}
