// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------
namespace Microsoft.eServices.EDocument;

using System.Automation;

pageextension 6134 EDocWorkflowResponseOptions extends "Workflow Response Options"
{
    layout
    {
        addlast(content)
        {
            group(EDoc)
            {
                Visible = Rec."Response Option Group" = 'GROUP 50100';
                ShowCaption = false;

                field("E-Document Service"; Rec."E-Document Service")
                {
                    ApplicationArea = Basic, Suite;
                    ToolTip = 'Specifies the electronic document service.';
                }
            }
        }
    }
}
