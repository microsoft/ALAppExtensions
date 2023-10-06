// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------
namespace Microsoft.Finance.AuditFileExport;

using System.Utilities;

page 5271 "Audit Export Data Type Setup"
{
    PageType = List;
    SourceTable = "Audit Export Data Type Setup";
    Caption = 'Audit Export Data Type Setup';
    InsertAllowed = false;
    DeleteAllowed = false;

    layout
    {
        area(Content)
        {
            repeater(Group)
            {
                field(ExportDataType; Rec."Export Data Type")
                {
                    ApplicationArea = Basic, Suite;
                    ToolTip = 'Specifies the data type that can be written to the audit file.';
                    Editable = false;
                }
                field(ExportDataClass; Rec."Export Data Class")
                {
                    ApplicationArea = Basic, Suite;
                    ToolTip = 'Specifies the data class.';
                    Editable = false;
                    Visible = false;
                }
                field(ExportEnabled; Rec."Export Enabled")
                {
                    ApplicationArea = Basic, Suite;
                    ToolTip = 'Specifies if the selected data type is written to the audit file.';
                }
            }
        }
    }

    actions
    {
        area(Processing)
        {
            action(RestoreDefaults)
            {
                ApplicationArea = Basic, Suite;
                Promoted = true;
                PromotedCategory = Process;
                PromotedIsBig = true;
                PromotedOnly = true;
                Image = Restore;
                Caption = 'Restore Default Setup';
                ToolTip = 'Recreate records in the Audit Export Data Type Setup.';

                trigger OnAction()
                var
                    ConfirmMgt: Codeunit "Confirm Management";
                    IAuditFileExportDataHandling: Interface "Audit File Export Data Handling";
                begin
                    if not ConfirmMgt.GetResponseOrDefault(RestoreDefaultsQst, false) then
                        exit;

                    IAuditFileExportDataHandling := Rec."Audit File Export Format";
                    IAuditFileExportDataHandling.InitAuditExportDataTypeSetup();
                end;
            }
        }
    }

    var
        RestoreDefaultsQst: label 'All the existing records will be removed from the audit export data type setup table and new default records will be created. Do you want to continue?';
}
