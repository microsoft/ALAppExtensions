// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------
namespace Microsoft.EServices.EDocumentConnector.Microsoft365;

using System.Telemetry;

page 6381 "OneDrive Setup"
{
    Permissions = tabledata "OneDrive Setup" = rim;
    ApplicationArea = Basic, Suite;
    Caption = 'OneDrive Document Import Setup';
    PageType = StandardDialog;
    DeleteAllowed = false;
    InsertAllowed = false;
    LinksAllowed = false;
    ShowFilter = false;
    SourceTable = "OneDrive Setup";
    UsageCategory = None;
    InherentPermissions = X;
    InherentEntitlements = X;

    layout
    {
        area(content)
        {
            group(Status)
            {
                Caption = ' ';
                ShowCaption = false;

                field(Enabled; Rec.Enabled)
                {
                    ApplicationArea = Basic, Suite;
                    ToolTip = 'Specifies is the document import enabled.';
                }
            }
            group(General)
            {
                Caption = 'Shared Links to Document Folders';
                InstructionalText = 'Use the OneDrive ''Copy Link'' feature to create the shared links and define who they work for, then paste them to the corresponding fields.';

                field("Incoming Documents"; Rec."Documents Folder")
                {
                    Caption = 'Document Folder';
                    ApplicationArea = Basic, Suite;
                    Editable = EditableByNotEnabled;
                    ShowMandatory = true;
                    ToolTip = 'Specifies the shared link of the folder from which to import documents.';
                }
                field("Archived Documents"; Rec."Imp. Documents Folder")
                {
                    Caption = 'Archive Folder';
                    ApplicationArea = Basic, Suite;
                    Editable = EditableByNotEnabled;
                    ShowMandatory = true;
                    ToolTip = 'Specifies the shared link of the folder to which the imported documents will be moved.';
                }
            }
        }
    }

    trigger OnAfterGetRecord()
    begin
        UpdateBasedOnEnable();
    end;

    trigger OnOpenPage()
    var
        FeatureTelemetry: Codeunit "Feature Telemetry";
        DriveProcessing: Codeunit "Drive Processing";
    begin
        Rec.Reset();
        if not Rec.Get() then begin
            if not Rec.WritePermission() then begin
                UpdateBasedOnEnable();
                exit;
            end;
            Rec.Init();
            Rec.Insert(true);
            FeatureTelemetry.LogUptake('0000OBD', DriveProcessing.FeatureName(), Enum::"Feature Uptake Status"::Discovered);
            FeatureTelemetry.LogUsage('0000OBE', DriveProcessing.FeatureName(), 'OneDrive');
        end;
        UpdateBasedOnEnable();
    end;

    trigger OnQueryClosePage(CloseAction: Action): Boolean
    begin
        if not Rec.Enabled then
            if not Confirm(StrSubstNo(EnableServiceQst, CurrPage.Caption), true) then
                exit(false);
    end;

    var
        EditableByNotEnabled: Boolean;
        EnableServiceQst: Label 'The %1 is not enabled. Are you sure you want to exit?', Comment = '%1 = page caption';

    local procedure UpdateBasedOnEnable()
    begin
        EditableByNotEnabled := (not Rec.Enabled) and CurrPage.Editable;
    end;

}

