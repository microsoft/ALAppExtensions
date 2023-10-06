// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------
namespace Microsoft.EServices.EDocument;

using Microsoft.Sales.Setup;
using System.Telemetry;

page 13646 "OIOUBL-setup"
{
    PageType = Card;
    SourceTable = "Sales & Receivables Setup";

    layout
    {
        area(content)
        {
            group(General)
            {
                field("OIOUBL-Invoice Path"; "OIOUBL-Invoice Path")
                {
                    ApplicationArea = Basic, Suite;
                    Tooltip = 'Specifies the path and name of the folder where you want to store the files for electronic invoices.';
                }
                field("OIOUBL-Cr. Memo Path"; "OIOUBL-Cr. Memo Path")
                {
                    ApplicationArea = Basic, Suite;
                    Tooltip = 'Specifies the path and name of the folder where you want to store the files for electronic credit memos.';
                }
                field("OIOUBL-Reminder Path"; "OIOUBL-Reminder Path")
                {
                    ApplicationArea = Basic, Suite;
                    Tooltip = 'Specifies the path and name of the folder where you want to store the files for electronic reminders.';
                }
                field("OIOUBL-Fin. Chrg. Memo Path"; "OIOUBL-Fin. Chrg. Memo Path")
                {
                    ApplicationArea = Basic, Suite;
                    Tooltip = 'Specifies the path and name of the folder where you want to store the files for electronic finance charge memos.';
                }
                field("OIOUBL-Default Profile Code"; "OIOUBL-Default Profile Code")
                {
                    ApplicationArea = Basic, Suite;
                    Tooltip = 'Specifies the default profile that you use in the electronic documents that you send to customers in the Danish public sector.';
                }
            }
        }
    }

    actions
    {
    }

    trigger OnOpenPage()
    var
        FeatureTelemetry: Codeunit "Feature Telemetry";
        OIOUBLTok: Label 'DK OIOUBL extension', Locked = true;
    begin
        FeatureTelemetry.LogUptake('0000H8K', OIOUBLTok, Enum::"Feature Uptake Status"::"Set up");
    end;
}
