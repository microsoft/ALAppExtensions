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
}
