// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------
namespace Microsoft.Finance.VAT.Reporting;

page 10061 "Transmissions IRIS"
{
    PageType = List;
    CardPageId = "Transmission IRIS";
    Caption = 'IRIS Transmissions';
    AdditionalSearchTerms = 'IRS, 1099';
    RefreshOnActivate = true;
    AnalysisModeEnabled = false;
    InsertAllowed = false;
    ApplicationArea = BasicUS;
    UsageCategory = Documents;
    SourceTable = "Transmission IRIS";

    layout
    {
        area(Content)
        {
            repeater(Documents)
            {
                ShowCaption = false;

                field("Period No."; Rec."Period No.")
                {
                    Editable = false;
                }
                field(Status; Rec.Status)
                {
                    Editable = false;
                }
            }
        }
    }

    actions
    {
        area(Processing)
        {
            action(CreateIRISTransmission)
            {
                Caption = 'Create IRIS Transmission';
                Image = ElectronicDoc;
                ToolTip = 'Create the transmission document from all released forms that have not been submitted yet to the IRS for the given period. This document will be used later to create the XML file that is sent to the IRS using IRIS.';

                trigger OnAction()
                var
                    CreateTransmissionIRIS: Report "Create Transmission IRIS";
                begin
                    CreateTransmissionIRIS.RunModal();
                end;
            }
            action(TransmissionLog)
            {
                Caption = 'Transmission History';
                Image = Log;
                ToolTip = 'Show IRIS transmissions history.';
                RunObject = Page "Transmission Logs IRIS";
            }
        }
        area(Promoted)
        {
            actionref(CreateIRISTransmission_Promoted; CreateIRISTransmission)
            {
            }
        }
    }
}