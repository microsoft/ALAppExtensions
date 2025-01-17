// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------

namespace System.ExternalFileStorage;

/// <summary>
/// Displays an account that was registered via the Local File connector.
/// </summary>
page 4820 "Ext. Local File Account"
{
    ApplicationArea = All;
    Caption = 'Local File Account';
    DataCaptionExpression = Rec.Name;
    Extensible = false;
    InsertAllowed = false;
    PageType = Card;
    Permissions = tabledata "Ext. Local File Account" = rimd;
    SourceTable = "Ext. Local File Account";
    UsageCategory = None;

    layout
    {
        area(Content)
        {
            field(NameField; Rec.Name)
            {
                Caption = 'Account Name';
                NotBlank = true;
                ShowMandatory = true;
                ToolTip = 'Specifies the name of the storage account connection.';
            }
            field(BasePath; Rec."Base Path")
            {
                ApplicationArea = All;
                Caption = 'Base Path';
                NotBlank = true;
                ShowMandatory = true;
                ToolTip = 'Specifies the a base path of the account like D:\share\.';
            }
        }
    }

    trigger OnOpenPage()
    begin
        Rec.SetCurrentKey(Name);
    end;
}