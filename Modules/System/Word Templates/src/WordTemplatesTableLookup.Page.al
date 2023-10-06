// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------

namespace System.Integration.Word;

/// <summary>
/// A look-up page to select a table to be used in a Word template.
/// </summary>
page 9988 "Word Templates Table Lookup"
{
    PageType = List;
    Caption = 'Word Templates Tables';
    SourceTable = "Word Templates Table";
    Permissions = tabledata "Word Templates Table" = r;
    Extensible = false;
    InherentEntitlements = X;
    InherentPermissions = X;

    layout
    {
        area(Content)
        {
            repeater(GroupName)
            {
                field(ID; Rec."Table ID")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the Table ID.';
                    Caption = 'Id';
                }
                field(Name; Rec."Table Caption")
                {
                    ApplicationArea = All;
                    Caption = 'Caption';
                    ToolTip = 'Specifies the table caption.';
                }
            }
        }
    }

#if not CLEAN22
    [Obsolete('Use Page.GetRecord instead.', '22.0')]
#pragma warning disable AL0523, AL0749, AL0755
    procedure GetRecord(var SelectedWordTemplatesTable: Record "Word Templates Table")
#pragma warning restore AL0523, AL0749, AL0755
    begin
        SelectedWordTemplatesTable := Rec;
    end;
#endif
}

