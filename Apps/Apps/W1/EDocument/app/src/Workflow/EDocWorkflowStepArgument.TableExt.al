// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------
namespace Microsoft.eServices.EDocument;

using System.Automation;

tableextension 6134 EDocWorkflowStepArgument extends "Workflow Step Argument"
{
    fields
    {
        field(6134; "E-Document Service"; Code[20])
        {
            TableRelation = "E-Document Service";
            DataClassification = CustomerContent;
        }
    }
}
