// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------
namespace Microsoft.Integration.DynamicsFieldService;

using Microsoft.Projects.Project.Journal;

pageextension 6618 "FS Job Journal" extends "Job Journal"
{
    layout
    {
        addafter("Remaining Qty.")
        {
            field(FSQuantityToTransferToInvoice; Rec."Qty. to Transfer to Invoice")
            {
                ApplicationArea = Jobs;
                Visible = FSRelatedFieldsVisible;
                ToolTip = 'Specifies the number of units of the project journal''s No. field, that is, either the resource, item, or G/L account number, that applies. If you later change the value in the No. field, the quantity does not change on the journal line.';
                AutoFormatType = 0;
            }
        }
    }

    var
        FSRelatedFieldsVisible: Boolean;

    trigger OnOpenPage()
    var
        FSConnectionSetup: Record "FS Connection Setup";
    begin
        FSRelatedFieldsVisible := FSConnectionSetup.IsEnabled();
    end;
}