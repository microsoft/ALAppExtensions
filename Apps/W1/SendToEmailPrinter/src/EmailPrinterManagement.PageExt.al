// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------

/// <summary>
/// Exposes functionality to add new Email Printer in Printer Management.
/// </summary>
pageextension 2651 "Email Printer Management" extends "Printer Management"
{
    AdditionalSearchTerms = 'email printers,emailprint';
    PromotedActionCategories = 'New, Process, Report, Manage, Email Print, Universal Print';

    actions
    {
        // Adding a new action in the 'Creation' area
        addlast(Creation)
        {
            action(NewPrinter)
            {
                ApplicationArea = All;
                Caption = 'Add an email printer';
                Image = Print;
                Promoted = true;
                PromotedIsBig = true;
                PromotedOnly = true;
                RunPageMode = Create;
                PromotedCategory = Category5;
                RunObject = Page "Email Printer Settings";
                ToolTip = 'Create a new email printer.';
            }
        }
    }
}
