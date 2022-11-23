﻿// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------

/// <summary>
/// List page that contains all of the application objects.
/// </summary>
page 358 Objects
{
    Extensible = false;
    Editable = false;
    PageType = List;
    DeleteAllowed = false;
    InsertAllowed = false;
    ModifyAllowed = false;
    SourceTable = AllObjWithCaption;
    Permissions = tabledata AllObjWithCaption = r, tabledata "Published Application" = r;

    layout
    {
        area(content)
        {
            repeater(Control1)
            {
                ShowCaption = false;
                field("Object Type"; Rec."Object Type")
                {
                    ApplicationArea = All;
                    Caption = 'Type';
                    ToolTip = 'Specifies the object type.';
                    Visible = VisibleObjType;
                }
                field("Object ID"; Rec."Object ID")
                {
                    ApplicationArea = All;
                    Caption = 'ID';
                    ToolTip = 'Specifies the object ID.';
                }
                field("Object Caption"; Rec."Object Caption")
                {
                    ApplicationArea = All;
                    Caption = 'Object Caption';
                    DrillDown = false;
                    ToolTip = 'Specifies the caption of the object.';
                    Visible = not HiddenObjCaption;
                }
                field("Object Name"; Rec."Object Name")
                {
                    ApplicationArea = All;
                    Caption = 'Object Name';
                    ToolTip = 'Specifies the name of the object.';
                    Visible = VisibleObjName;
                }
                field("Object Subtype"; Rec."Object Subtype")
                {
                    ApplicationArea = All;
                    Caption = 'Object Subtype';
                    ToolTip = 'Specifies the subtype of the object.';
                    Visible = VisibleObjType;
                }
                field(ExtensionName; AppName)
                {
                    ApplicationArea = All;
                    Caption = 'Extension Name';
                    ToolTip = 'Specifies the name of the extension the object comes from.';
                    Visible = false;
                }
            }
        }
    }

    actions
    {
    }

    // Used to set the Extension Name field
    // in case the object comes from an installed extension.
    trigger OnAfterGetRecord()
    var
        PublishedApplication: Record "Published Application";
    begin
        AppName := '';

        if IsNullGuid("App Package ID") then
            exit;

        if not PublishedApplication.ReadPermission() then
            exit;

        PublishedApplication.SetRange("Package ID", "App Package ID");
        PublishedApplication.SetRange("Tenant Visible", true);

        if PublishedApplication.FindFirst() then
            AppName := PublishedApplication.Name;
    end;

    procedure SetObjectTypeVisible(Visible: Boolean)
    begin
        VisibleObjType := Visible;
    end;

    procedure SetObjectNameVisible(Visible: Boolean)
    begin
        VisibleObjName := Visible;
    end;

    procedure SetObjectCaptionVisible(Visible: Boolean)
    begin
        HiddenObjCaption := not Visible;
    end;

    procedure GetSelectedRecords(var CurrSelectedRecords: Record AllObjWithCaption)
    begin
        CurrPage.SetSelectionFilter(Rec);

        if Rec.FindSet() then
            repeat
                CurrSelectedRecords.Copy(Rec);
                CurrSelectedRecords.Insert();
            until Rec.Next() = 0;
    end;

    var
        AppName: Text;
        VisibleObjType: Boolean;
        VisibleObjName: Boolean;
        HiddenObjCaption: Boolean;
}

