// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------

pageextension 11026 "Elster Acc. Mgr Role Center" extends "Accounting Manager Role Center"
{
    actions
    {
        addafter("VAT Statements")
        {
            action("VAT Advanced Notifications")
            {
                Caption = 'VAT Advanced Notifications';
                ToolTip = 'Prepare to submit sales VAT advance notifications electronically to the ELSTER portal.';
                ApplicationArea = Basic, Suite;
                RunObject = page "Sales VAT Adv. Notif. List";
                Image = ElectronicDoc;
            }
        }
    }
}