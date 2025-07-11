// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------
namespace Microsoft.Inventory.Intrastat;

pageextension 148121 "Intrastat Report IT" extends "Intrastat Report"
{
    layout
    {
        addafter(General)
        {
            group(ExportParamenters)
            {
                Caption = 'Export Parameters';
                field(Periodicity; Rec.Periodicity)
                {
                    ApplicationArea = BasicEU;
                    ToolTip = 'Specifies the periodicity for the Intrastat reporting.';
                }
                field(Type; Rec.Type)
                {
                    ApplicationArea = BasicEU;
                    ToolTip = 'Specifies the type of item ledger entries to be included.';
                }
                field("Corrective Entry"; Rec."Corrective Entry")
                {
                    ApplicationArea = BasicEU;
                    ToolTip = 'Specifies if the Intrastat report has an adjusting entry.';
                }
                field("File Disk No."; Rec."File Disk No.")
                {
                    ApplicationArea = BasicEU;
                    ToolTip = 'Specifies the floppy disk number if you are creating a reporting disk.';
                }
                field("Corrected Intrastat Rep. No."; Rec."Corrected Intrastat Rep. No.")
                {
                    ApplicationArea = BasicEU;
                    Enabled = Rec."Corrective Entry";
                    ToolTip = 'Specifies the corrected report.';
                }
                field("Include Community Entries"; Rec."Include Community Entries")
                {
                    ApplicationArea = BasicEU;
                    ToolTip = 'Specifies if you want to include intra-community entries from drop shipment documents to Intrastat Report.';
                }
            }
        }
    }
}