// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------
namespace Microsoft.eServices.EDocument;

using Microsoft.Foundation.Reporting;
using System.Automation;

tableextension 6100 "E-Document Sending Profile" extends "Document Sending Profile"
{
    fields
    {
        modify("E-Mail Attachment")
        {
            trigger OnAfterValidate()
            begin
                if Rec."E-Mail Attachment" in [Rec."E-Mail Attachment"::"PDF & E-Document", Rec."E-Mail Attachment"::"E-Document"] then
                    ValidateThatEDocumentWorkflow();
            end;
        }

        field(6102; "Electronic Service Flow"; Code[20])
        {
            Caption = 'Electronic Service Flow Code';
            DataClassification = CustomerContent;
            TableRelation = Workflow where(Template = const(false), Category = const('EDOC'));
        }
    }

    local procedure ValidateThatEDocumentWorkflow()
    var
        Workflow: Record Workflow;
    begin
        Rec.TestField("Electronic Document", Rec."Electronic Document"::"Extended E-Document Service Flow");
        Rec.Validate("Electronic Service Flow");

        Workflow.Get(Rec."Electronic Service Flow");
        Workflow.TestField(Enabled, true);
    end;

}
