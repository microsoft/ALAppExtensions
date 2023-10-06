// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------
namespace Microsoft.Finance.AuditFileExport;

page 5270 "Audit File Export Format Setup"
{
    PageType = List;
    SourceTable = "Audit File Export Format Setup";
    ApplicationArea = Basic, Suite;
    UsageCategory = Administration;
    Caption = 'Audit File Export Format Setup';
    PromotedActionCategories = 'New,Process,Report,Details';

    layout
    {
        area(Content)
        {
            repeater(Group)
            {
                field(AuditFileExportFormat; Rec."Audit File Export Format")
                {
                    ApplicationArea = Basic, Suite;
                    ToolTip = 'Audit File Export Format';
                }
                field(AuditFileName; Rec."Audit File Name")
                {
                    ApplicationArea = Basic, Suite;
                    ToolTip = 'Specifies the default file name or the file name template for the audit file.';
                }
                field(ArchiveToZip; Rec."Archive to Zip")
                {
                    ApplicationArea = Basic, Suite;
                    ToolTip = 'Archive to Zip';
                }
            }
        }
    }

    actions
    {
        area(Navigation)
        {
            action(SelectExportDataTypes)
            {
                ApplicationArea = Basic, Suite;
                Promoted = true;
                PromotedCategory = Category4;
                PromotedIsBig = true;
                PromotedOnly = true;
                Image = CheckList;
                Caption = 'Select Data Types for Export';
                ToolTip = 'Select data types that will be written to the audit file.';

                trigger OnAction()
                var
                    AuditExportDataTypeSetup: Record "Audit Export Data Type Setup";
                    AuditExportDataTypeSetupPage: Page "Audit Export Data Type Setup";
                begin
                    AuditExportDataTypeSetup.FilterGroup(2);
                    AuditExportDataTypeSetup.SetRange("Audit File Export Format", Rec."Audit File Export Format");
                    AuditExportDataTypeSetup.FilterGroup(0);

                    AuditExportDataTypeSetupPage.SetTableView(AuditExportDataTypeSetup);
                    AuditExportDataTypeSetupPage.RunModal();
                end;
            }
        }
    }
}
