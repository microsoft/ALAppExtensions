// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------
namespace Microsoft.Inventory.Setup;

using Microsoft.Finance.GeneralLedger.Account;
using Microsoft.Foundation.NoSeries;
using Microsoft.Inventory.Location;

tableextension 18006 "GST Inventory Setup Ext" extends "Inventory Setup"
{
    fields
    {
        field(18000; "Service Transfer Order Nos."; code[20])
        {
            caption = 'Service Transfer Order Nos.';
            DataClassification = CustomerContent;
            TableRelation = "No. Series";
        }
        field(18001; "Posted Serv. Trans. Shpt. Nos."; code[20])
        {
            Caption = 'Posted Serv. Trans. Shpt. Nos.';
            DataClassification = CustomerContent;
            TableRelation = "No. Series";
        }
        field(18002; "Posted Serv. Trans. Rcpt. Nos."; code[20])
        {
            Caption = 'Posted Serv. Trans. Rcpt. Nos.';
            DataClassification = CustomerContent;
            TableRelation = "No. Series";
        }
        field(18003; "Service Rounding Account"; Code[20])
        {
            DataClassification = CustomerContent;
            TableRelation = "G/L Account" where(Blocked = const(False), "Account Type" = filter(Posting));
        }
        field(18004; "Sub. Component Location"; Code[10])
        {
            Caption = 'Sub. Component Location';
            DataClassification = CustomerContent;
            TableRelation = Location where("Subcontracting Location" = const(false));
        }
        field(18005; "Job Work Return Period"; Integer)
        {
            Caption = 'Job Work Return Period';
            DataClassification = CustomerContent;
        }
    }
}
