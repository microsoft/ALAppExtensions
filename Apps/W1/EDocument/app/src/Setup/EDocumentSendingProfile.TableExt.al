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
        field(6102; "Electronic Service Flow"; Code[20])
        {
            Caption = 'Electronic Service Flow Code';
            DataClassification = CustomerContent;
            TableRelation = Workflow where(Template = const(false), Category = const('EDOC'));
        }
    }

    internal procedure TrySendToEMailWithEDocument(
        ReportUsage: Integer;
        RecordVariant: Variant;
        DocumentNoFieldNo: Integer;
        DocName: Text[150];
        CustomerFieldNo: Integer;
        ShowDialog: Boolean)
    var
        IsCustomer: Boolean;
    begin
        IsCustomer := true;

        if ShowDialog then
            "E-Mail" := "E-Mail"::"Yes (Prompt for Settings)"
        else
            "E-Mail" := "E-Mail"::"Yes (Use Default Settings)";

        "E-Mail Attachment" := "E-Mail Attachment"::"E-Document";

        TrySendToEMailGroupedMultipleSelection(
            "Report Selection Usage".FromInteger(ReportUsage),
            RecordVariant,
            DocumentNoFieldNo,
            DocName,
            CustomerFieldNo,
            IsCustomer);
    end;
}
