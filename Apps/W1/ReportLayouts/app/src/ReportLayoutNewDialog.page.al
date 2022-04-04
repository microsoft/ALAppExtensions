// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------
/// <summary>
/// A dialog page for adding new report layouts.
/// </summary>
page 9662 "Report Layout New Dialog"
{
    Caption = 'Add New Layout for a Report';
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
                Enabled = true;
                TableRelation = "Report Metadata"."ID";
                ToolTip = 'Specifies the ID of the report.';

                trigger OnValidate()
                begin
                    if not ReportMetadata.Get(ReportID) then
                        Error(ReportNotFoundErr, ReportID);
                end;
            }
            field(ReportName; ReportMetadata."Name")
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
            field("Format Options"; FormatOptions)
            {
                ApplicationArea = Basic, Suite;
                Visible = true;
                ToolTip = 'Specified the format of the layout.';
                OptionCaption = 'RDLC,Word,Excel,External';
            }
        }
    }

    trigger OnOpenPage()
    begin
        FormatOptions := FormatOptions::Excel;
        LayoutName := '';
        if ReportID <> 0 then
            if ReportMetadata.Get(ReportID) then;
    end;

    var
        ReportMetadata: Record "Report Metadata";
        TenantReportLayout: Record "Tenant Report Layout";
        ReportID: Integer;
        LayoutName: Text[250];
        Description: Text[250];
        LayoutAlreadyExistsErr: Label 'A layout named "%1" already exists.', Comment = '%1 = LayoutName';
        LayoutNameEmptyErr: Label 'The layout name cannot be an empty value.';
        ReportNotFoundErr: Label 'A report with ID "%1" does not exist.', Comment = '%1 = ReportID';
        FormatOptions: Option "RDLC","Word","Excel","Custom"; // For Custom type, 'External' will be shown in UI
        emptyGuid: Guid;

    internal procedure SetReportID(NewReportID: Integer)
    begin
        ReportID := NewReportID;
    end;

    internal procedure SelectedReportID(): Integer
    begin
        exit(ReportID);
    end;

    internal procedure SelectedLayoutName(): Text[250]
    begin
        exit(LayoutName);
    end;

    internal procedure SelectedLayoutDescription(): Text[250]
    begin
        exit(Description);
    end;

    internal procedure SelectedAddCustomLayout(): Boolean
    begin
        exit(FormatOptions = FormatOptions::Custom);
    end;

    internal procedure SelectedAddExcelLayout(): Boolean
    begin
        exit(FormatOptions = FormatOptions::Excel);
    end;

    internal procedure SelectedAddRDLCLayout(): Boolean
    begin
        exit(FormatOptions = FormatOptions::RDLC);
    end;

    internal procedure SelectedAddWordLayout(): Boolean
    begin
        exit(FormatOptions = FormatOptions::Word);
    end;
}
