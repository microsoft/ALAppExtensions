// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------

namespace System.Apps;

/// <summary>
/// Displays details about the selected extension, and offers features for installing and uninstalling it.
/// </summary>
page 2513 "Extn. Orphaned App Details"
{
    Caption = 'Orphaned Extension Data Details';
    Extensible = false;
    DeleteAllowed = false;
    InsertAllowed = false;
    PageType = NavigatePage;
    SourceTable = "Extension Database Snapshot";
    ContextSensitiveHelpPage = 'ui-extensions';
    Permissions = tabledata "Extension Database Snapshot" = r;

    layout
    {
        area(content)
        {
            group(UninstallGroup)
            {
                Caption = 'Delete Extension Data';
                InstructionalText = 'Warning: Deletes tables that contain data owned by this extension. This action cannot be undone.';
                field(Name; Rec.Name)
                {
                    ApplicationArea = All;
                    Caption = 'Name';
                    Editable = false;
                    ToolTip = 'Specifies the name of the extension.';
                }
                field(Ver; Rec."Schema Version")
                {
                    ApplicationArea = All;
                    Caption = 'Version';
                    ToolTip = 'Specifies the version of the extension.';
                    Editable = false;
                }
                field(Pub; Rec.Publisher)
                {
                    ApplicationArea = All;
                    Caption = 'Publisher';
                    ToolTip = 'Specifies the publisher of the extension.';
                    Editable = false;
                }
                field(Id; AppIdDisplay)
                {
                    ApplicationArea = All;
                    Caption = 'App ID';
                    ToolTip = 'Specifies the app ID of the extension.';
                    Editable = false;
                }
            }
        }
    }

    actions
    {
        area(processing)
        {
            action(DeleteData)
            {
                ApplicationArea = All;
                Caption = 'Delete Extension Data';
                ToolTip = 'Delete Extension Data';
                Image = Delete;
                InFooterBar = true;

                trigger OnAction()
                begin
                    ExtensionInstallationImpl.DeleteOrphanData(Rec."Package Id", Rec."Name");
                    CurrPage.Close();
                end;
            }
        }
    }

    trigger OnOpenPage()
    begin
        InstalledAndSyncedAppRecord.SetRange("Package Id", Rec."Package Id");

        AppIdDisplay := LowerCase(DelChr(Format(Rec."App Id"), '=', '{}'));
        if not InstalledAndSyncedAppRecord.FindFirst() then
            CurrPage.Close();

    end;

    var
        InstalledAndSyncedAppRecord: Record "Extension Database Snapshot";
        ExtensionInstallationImpl: Codeunit "Extension Installation Impl";
        AppIdDisplay: Text;
}

