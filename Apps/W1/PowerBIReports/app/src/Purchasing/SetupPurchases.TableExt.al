// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------
namespace Microsoft.Purchases.PowerBIReports;

using Microsoft.PowerBIReports;

tableextension 36956 "Setup - Purchases" extends "PowerBI Reports Setup"
{
    fields
    {
        field(36964; "Item Purch. Load Date Type"; Option)
        {
            Caption = 'Item Purchases Report Load Date Type';
            OptionCaption = ' ,Start/End Date,Relative Date';
            OptionMembers = " ","Start/End Date","Relative Date";
            DataClassification = CustomerContent;
        }
        field(36965; "Item Purch. Start Date"; Date)
        {
            Caption = 'Item Purchases Report Start Date';
            DataClassification = CustomerContent;
        }
        field(36966; "Item Purch. End Date"; Date)
        {
            Caption = 'Item Purchases Report End Date';
            DataClassification = CustomerContent;
        }
        field(36967; "Item Purch. Date Formula"; DateFormula)
        {
            Caption = 'Item Purchases Report Date Formula';
            DataClassification = CustomerContent;
        }
        field(36974; "Purchases Report Id"; Guid)
        {
            Caption = 'Purchases Report ID';
            DataClassification = CustomerContent;
        }
        field(36975; "Purchases Report Name"; Text[200])
        {
            Caption = 'Purchases Report Name';
            DataClassification = CustomerContent;
        }
    }
}