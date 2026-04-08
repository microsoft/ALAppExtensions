#if not CLEAN28
// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------

#pragma warning disable AS0007
namespace Microsoft.Agent.PayablesAgent;

page 3308 "PA Demo Files To Download"
{
    Caption = 'Samples invoices available for download';
    PageType = List;
    SourceTable = "PA Demo File";
    SourceTableTemporary = true;
    InherentEntitlements = X;
    InherentPermissions = X;
    Editable = false;
    ObsoleteState = Pending;
    ObsoleteReason = 'Use E-Doc Sample Purch. Inv. Files page instead';
    ObsoleteTag = '28.0';

    layout
    {
        area(Content)
        {
            repeater(Group)
            {
                field("File Name"; Rec."File Name")
                {
                    ApplicationArea = All;
                    Caption = 'Invoice file name';
                    ToolTip = 'Specifies the file name of the invoice file to download.';
                }
                field("Vendor Name"; Rec."Vendor Name")
                {
                    ApplicationArea = All;
                    Caption = 'Vendor Name';
                    ToolTip = 'Specifies the name of the vendor associated with the invoice file.';
                }
                field(Scenario; Rec.Scenario)
                {
                    ApplicationArea = All;
                    Caption = 'Description';
                    ToolTip = 'Specifies a scenario to demo with the invoice file.';
                }
            }
        }
    }

    actions
    {
        area(Processing)
        {
            action(Download)
            {
                ApplicationArea = All;
                Caption = 'Download';
                ToolTip = 'Downloads the selected demo file.';
                Image = Download;

                trigger OnAction()
                var
                    PADemoGuide: Codeunit "PA Demo Guide";
                begin
#pragma warning disable AL0432
                    PADemoGuide.DownloadDemoFile(Rec);
#pragma warning restore AL0432
                end;
            }
        }
        area(Promoted)
        {
            actionref(Download_Promoted; Download)
            { }
        }
    }
}
#endif