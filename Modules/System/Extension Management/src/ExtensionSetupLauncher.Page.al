// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------

/// <summary>
/// This page is a launch pad for running setup after installation of an extension.
/// </summary>
page 2512 "Extension Setup Launcher"
{
    Extensible = false;
    Editable = false;
    PageType = Card;
    ApplicationArea = All;
    Caption = 'Almost there...';

    layout
    {
        area(content)
        {
        }
    }

    trigger OnOpenPage()
    var
        ExtensionMarketplace: Codeunit "Extension Marketplace";
    begin
        if not NoSetupOnOpen then begin
            ExtensionMarketplace.RunPendingSetup();
            Commit();
            Error('');//Close the page after pending setup has been handled
        end;
    end;

    internal procedure SetNoSetupOnOpen(State: Boolean)
    begin
        NoSetupOnOpen := State;
    end;

    var
        NoSetupOnOpen: Boolean;
}

