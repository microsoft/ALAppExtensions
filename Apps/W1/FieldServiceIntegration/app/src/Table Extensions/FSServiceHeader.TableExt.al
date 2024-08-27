// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------
namespace Microsoft.Integration.DynamicsFieldService;

using Microsoft.Service.Document;
using System.Reflection;
using Microsoft.Integration.Dataverse;

tableextension 6615 "FS Service Header" extends "Service Header"
{
    fields
    {
        field(12000; "Work Description"; BLOB)
        {
            Caption = 'Work Description';
        }

        field(12001; "Coupled to Dataverse"; Boolean)
        {
            FieldClass = FlowField;
            Caption = 'Coupled to Dynamics 365 Sales';
            Editable = false;
            CalcFormula = exist("CRM Integration Record" where("Integration ID" = field(SystemId), "Table ID" = const(Database::"Service Header")));
        }
    }

    procedure SetWorkDescription(NewWorkDescription: Text)
    var
        OutStream: OutStream;
    begin
        Clear("Work Description");
        Rec."Work Description".CreateOutStream(OutStream, TextEncoding::UTF8);
        OutStream.WriteText(NewWorkDescription);
        Modify();
    end;

    procedure GetWorkDescription() WorkDescription: Text
    var
        TypeHelper: Codeunit "Type Helper";
        InStream: InStream;
    begin
        Rec.CalcFields("Work Description");
        Rec."Work Description".CreateInStream(InStream, TextEncoding::UTF8);
        exit(TypeHelper.TryReadAsTextWithSepAndFieldErrMsg(InStream, TypeHelper.LFSeparator(), Rec.FieldName("Work Description")));
    end;

}
