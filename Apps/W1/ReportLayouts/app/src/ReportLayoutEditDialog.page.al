// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------
/// <summary>
/// A dialog page for editting report layout information.
/// </summary>
page 9661 "Report Layout Edit Dialog"
{
    Caption = 'Edit Report Layout';
    PageType = StandardDialog;
    Extensible = false;
    Permissions = tabledata "Tenant Report Layout" = r;

    layout
    {
        area(content)
        {
            field(ReportID; ReportID)
            {
                ApplicationArea = Basic, Suite;
                Caption = 'Report ID';
                Enabled = false;
                ToolTip = 'Specifies the ID of the report.';
            }
            field(ReportName; ReportName)
            {
                ApplicationArea = Basic, Suite;
                Caption = 'Report Name';
                Enabled = false;
                ToolTip = 'Specifies the name of the report.';
            }
            field(LayoutName; LayoutName)
            {
                ApplicationArea = Basic, Suite;
                NotBlank = true;
                ShowMandatory = true;
                Caption = 'Layout Name';
                ToolTip = 'Specifies the name of the layout.';

                trigger OnValidate()
                begin
                    "LayoutName" := "LayoutName".Trim();
                    if "LayoutName" = '' then
                        Error(LayoutNameEmptyErr);
                    if TenantReportLayout.Get(ReportID, LayoutName, emptyGuid) then
                        Error(LayoutAlreadyExistsErr, LayoutName);
                end;
            }
            field(Description; Description)
            {
                ApplicationArea = Basic, Suite;
                Caption = 'Description';
                ToolTip = 'Specifies a description for the layout.';

                trigger OnValidate()
                begin
                    Description := Description.Trim();
                end;
            }
            field(CreateCopy; CreateCopy)
            {
                ApplicationArea = Basic, Suite;
                Caption = 'Save Changes to a Copy';
                ToolTip = 'Create a copy of the selected layout with the specified changes.';
                Editable = CreateCopyEditable;
            }
        }
    }

    var
        TenantReportLayout: Record "Tenant Report Layout";
        ReportID: Integer;
        LayoutName: Text[250];
        ReportName: Text;
        Description: Text[250];
        LayoutAlreadyExistsErr: Label 'A layout named %1 already exists.', Comment = '%1 = Layout Name';
        LayoutNameEmptyErr: Label 'The layout name cannot be an empty value.';
        emptyGuid: Guid;
        CreateCopy: Boolean;
        CreateCopyEditable: Boolean;

    internal procedure SelectedLayoutDescription(): Text[250]
    begin
        exit(Description);
    end;

    internal procedure SelectedLayoutName(): Text[250]
    begin
        exit(LayoutName);
    end;

    internal procedure CopyOperationEnabled(): Boolean
    begin
        exit(CreateCopy);
    end;

    internal procedure SetupDialog(ReportLayoutList: Record "Report Layout List"; ForceCopy: Boolean): Text
    begin
        ReportID := ReportLayoutList."Report ID";
        ReportName := ReportLayoutList."Report Name";
        Description := ReportLayoutList."Description";
        LayoutName := ReportLayoutList."Name";

        if ForceCopy then begin
            CreateCopy := true;
            CreateCopyEditable := false;
        end else begin
            CreateCopy := false;
            CreateCopyEditable := true;
        end;
    end;
}
