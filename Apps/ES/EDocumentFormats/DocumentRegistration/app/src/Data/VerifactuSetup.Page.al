// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------
namespace Microsoft.EServices.EDocument.Verifactu;

page 10777 "Verifactu Setup"
{
    ApplicationArea = All;
    Caption = 'Verifactu Setup';
    DeleteAllowed = false;
    InsertAllowed = false;
    LinksAllowed = false;
    PageType = Card;
    ShowFilter = false;
    SourceTable = "Verifactu Setup";
    UsageCategory = Administration;

    layout
    {
        area(content)
        {
            group(General)
            {
                field(Enabled; Rec.Enabled)
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies that the service for invoice validation with the tax authorities is activated.';
                }
                field("Show Advanced Actions"; Rec."Show Advanced Actions")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies whether to show advanced actions.';
                }
                field("Invoice Amount Threshold"; Rec."Invoice Amount Threshold")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies which value to include in the Macrodato node in the XML file that is exported to SII. If the invoice amount on the document is under the threshold, then value ''N'' will be exported. Otherwise, value ''S'' will be exported.';
                    AutoFormatType = 1;
                    AutoFormatExpression = '';
                }
                field("Starting Date"; Rec."Starting Date")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the date when the company starts to send entries to the SII system.';
                }
                field("Do Not Export Negative Lines"; Rec."Do Not Export Negative Lines")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies if you want to exclude lines that are negative from the export to the Verifactu file.';
                }
            }
            group(Certificate)
            {
                field("Certificate Code"; Rec."Certificate Code")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the code of certificate.';
                }
            }
        }
    }

    trigger OnOpenPage()
    begin
        Rec.Reset();
        if not Rec.Get() then begin
            Rec.Init();
            Rec.Insert(true);
        end;
    end;
}

