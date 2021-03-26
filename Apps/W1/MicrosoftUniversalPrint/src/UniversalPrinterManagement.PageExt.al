// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------

/// <summary>
/// Exposes functionality to get Universal Print printersers in Printer Management.
/// </summary>
pageextension 2751 "Universal Printer Management" extends "Printer Management"
{
    AdditionalSearchTerms = 'universal printers,universalprint';
    PromotedActionCategories = 'New, Process, Report, Manage, Email Print, Universal Print';

    actions
    {
        addlast(Creation)
        {
            action(AddUniversalPrinters)
            {
                ApplicationArea = All;
                Caption = 'Add all Universal Print printers';
                Image = Print;
                Promoted = true;
                PromotedIsBig = true;
                PromotedOnly = true;
                PromotedCategory = Category6;
                ToolTip = 'Add all the registered Universal Print printers that are shared with you, into Business Central.';
                RunObject = page "Add Universal Printers Wizard";
            }
            action(AddUniversalPrinter)
            {
                ApplicationArea = All;
                Caption = 'Add a Universal Print printer';
                Image = Print;
                Promoted = true;
                PromotedIsBig = true;
                PromotedOnly = true;
                RunPageMode = Create;
                PromotedCategory = Category6;
                ToolTip = 'Add a selected Universal Print printers that is shared with you, into Business Central.';
                RunObject = page "Universal Printer Settings";
            }
        }
        addlast(Navigation)
        {
            action(OpenUniversalPrintPortal)
            {
                ApplicationArea = All;
                Caption = 'Universal Print portal';
                Image = Open;
                Promoted = true;
                PromotedIsBig = true;
                PromotedOnly = true;
                PromotedCategory = Category6;
                ToolTip = 'Opens Universal Print portal.';
                trigger OnAction()
                begin
                    Hyperlink(UniversalPrintGraphHelper.GetUniversalPrintPortalUrl());
                end;
            }
        }
    }

    var
        UniversalPrintGraphHelper: Codeunit "Universal Print Graph Helper";
}
