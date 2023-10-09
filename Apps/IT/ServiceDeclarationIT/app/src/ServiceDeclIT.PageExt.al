// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------
namespace Microsoft.Service.Reports;

pageextension 12216 "Service Decl. IT" extends "Service Declaration"
{
    layout
    {
        addafter("Config. Code")
        {
            field("Statistics Period"; Rec."Statistics Period")
            {
                ApplicationArea = BasicEU;
                ToolTip = 'Specifies the month or quarter to report data for. Enter the period as a four-digit number, with no spaces or symbols. Enter the year first and then the month or quarter, for example, enter 1706 for June, 2017';
            }
        }
        modify("Starting Date")
        {
            Enabled = false;
        }
        modify("Ending Date")
        {
            Enabled = false;
        }
        addafter("Ending Date")
        {
            field(Periodicity; Rec.Periodicity)
            {
                ApplicationArea = BasicEU;
                ToolTip = 'Specifies the periodicity for the Service Declaration.';
            }
            field(Type; Rec.Type)
            {
                ApplicationArea = BasicEU;
                ToolTip = 'Specifies the type of entries to be included.';
            }
            field("Corrective Entry"; Rec."Corrective Entry")
            {
                ApplicationArea = BasicEU;
                ToolTip = 'Specifies if the Service Declaration has an adjusting entry.';
            }
            field("File Disk No."; Rec."File Disk No.")
            {
                ApplicationArea = BasicEU;
                ToolTip = 'Specifies the floppy disk number if you are creating a reporting disk.';
            }
            field("Customs Office No."; Rec."Customs Office No.")
            {
                ApplicationArea = BasicEU;
                ToolTip = 'Specifies the customs office that the trade of services passes through.';
            }
            field("Corrected Serv. Decl. No."; Rec."Corrected Serv. Decl. No.")
            {
                ApplicationArea = BasicEU;
                Enabled = Rec."Corrective Entry";
                ToolTip = 'Specifies the corrected Service Declaration.';
            }
        }
    }

    actions
    {
        modify(Overview_Promoted)
        {
            Visible = false;
        }
        modify(Overview)
        {
            Visible = false;
        }
    }
}
