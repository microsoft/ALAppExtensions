// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------
namespace Microsoft.Sales.Setup;

pageextension 13666 "OIOUBL-Sales Receivables Setup" extends "Sales & Receivables Setup"
{
    layout
    {
        addafter("Background Posting")
        {
            group("OIOUBL-Group")
            {
                Caption = 'OIOUBL';

                field("OIOUBL-Default Profile Code"; "OIOUBL-Default Profile Code")
                {
                    caption = 'Default Profile Code';
                    Tooltip = 'Specifies the default profile that you use in the electronic documents that you send to customers in the Danish public sector.';
                    ApplicationArea = Basic, Suite;
                    ShowMandatory = true;
                }

                field("Document No. as Ext. Doc. No."; "Document No. as Ext. Doc. No.")
                {
                    ApplicationArea = Basic, Suite;
                    ToolTip = 'Use the internal document number if the External Document No. field is empty.';
                }

                group(OutputPaths)
                {
                    Caption = 'Output Paths';
                    Visible = false;

                    field("OIOUBL-Invoice Path"; "OIOUBL-Invoice Path")
                    {
                        Caption = 'Invoice Path';
                        Tooltip = 'Specifies the path and name of the folder where you want to store the files for electronic invoices.';
                        ApplicationArea = Basic, Suite;
                        ShowMandatory = true;
                    }

                    field("OIOUBL-Cr. Memo Path"; "OIOUBL-Cr. Memo Path")
                    {
                        Caption = 'Cr. Memo Path';
                        Tooltip = 'Specifies the path and name of the folder where you want to store the files for electronic credit memos.';
                        ApplicationArea = Basic, Suite;
                        ShowMandatory = true;
                    }

                    field("OIOUBL-Reminder Path"; "OIOUBL-Reminder Path")
                    {
                        Caption = 'Reminder Path';
                        Tooltip = 'Specifies the path and name of the folder where you want to store the files for electronic reminders.';
                        ApplicationArea = Basic, Suite;
                        ShowMandatory = true;
                    }

                    field("OIOUBL-Fin. Chrg. Memo Path"; "OIOUBL-Fin. Chrg. Memo Path")
                    {
                        Caption = 'Fin. Chrg. Memo Path';
                        Tooltip = 'Specifies the path and name of the folder where you want to store the files for electronic finance charge memos.';
                        ApplicationArea = Basic, Suite;
                        ShowMandatory = true;
                    }
                }
            }
        }
    }
}
