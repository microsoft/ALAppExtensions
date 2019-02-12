// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------

pageextension 11025 "Elster Small Bus. Owner RC" extends "Small Business Owner RC"
{
    actions
    {
        addafter("VAT Statements")
        {
            action("VAT Advanced Notification")
            {
                Caption = 'VAT Advanced Notification';
                ToolTip = 'Prepare to submit sales VAT advance notifications electronically to the ELSTER portal.';
                ApplicationArea = Basic, Suite;
                RunObject = page "Sales VAT Adv. Notif. List";
                Image = ElectronicDoc;
            }
        }
    }
}