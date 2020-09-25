// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------

page 11019 "Electronic VAT Decl. Setup"
{
    ApplicationArea = Basic, Suite;
    Caption = 'Electronic VAT Decl. Setup';
    DeleteAllowed = false;
    InsertAllowed = false;
    PageType = Card;
    SourceTable = "Elec. VAT Decl. Setup";
    UsageCategory = Tasks;

    layout
    {
        area(Content)
        {
            group(General)
            {
                Caption = 'General';
                field("Sales VAT Adv. Notif. Nos."; "Sales VAT Adv. Notif. Nos.")
                {
                    ApplicationArea = Basic, Suite;
                    ToolTip = 'Specifies the number series code used to assign numbers to sales VAT advance notifications.';
                }

                field("Sales VAT Adv. Notif. Path"; "Sales VAT Adv. Notif. Path")
                {
                    ApplicationArea = Basic, Suite;
                    ToolTip = 'Specifies the path and name of the folder where you want to store the XML files.';
                }

                field("XML File Default Name"; "XML File Default Name")
                {
                    ApplicationArea = Basic, Suite;
                    ToolTip = 'Specifies the name of the file what you want to store the XML files.';
                }
            }
        }
    }
}