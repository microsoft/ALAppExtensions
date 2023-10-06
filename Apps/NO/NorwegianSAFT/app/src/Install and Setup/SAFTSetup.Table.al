﻿// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------
namespace Microsoft.Finance.AuditFileExport;

using Microsoft.Finance.VAT.Reporting;
using Microsoft.Finance.VAT.Setup;
using Microsoft.Foundation.NoSeries;

table 10670 "SAF-T Setup"
{
    DataClassification = CustomerContent;
    Caption = 'SAF-T Setup';
    fields
    {
        field(1; "Primary Key"; Integer)
        {
            DataClassification = CustomerContent;
            Caption = 'Primary Key';
        }
        field(2; "Dimension No. Series Code"; Code[20])
        {
            DataClassification = CustomerContent;
            Caption = 'Dimension No. Series Code';
            TableRelation = "No. Series";
            ObsoleteState = Pending;
            ObsoleteReason = 'Replaced with Dimension No.';
            ObsoleteTag = '17.0';
        }
        field(3; "Last Tax Code"; Integer)
        {
            DataClassification = CustomerContent;
            Caption = 'Last Tax Code';
        }
        field(4; "Not Applicable VAT Code"; Code[20])
        {
            Caption = 'Not Applicable VAT Code';
            DataClassification = CustomerContent;
            TableRelation = "VAT Code";
            ObsoleteReason = 'Use the field "Not Applic. VAT Code" instead';
#if CLEAN23
            ObsoleteState = Removed;
            ObsoleteTag = '26.0';
#else
            ObsoleteState = Pending;
            ObsoleteTag = '23.0';
#endif
        }
        field(5; "Dimension No."; Integer)
        {
            DataClassification = CustomerContent;
            Caption = 'Dimension No.';
        }
        field(6; "Default Post Code"; Code[20])
        {
            Caption = 'Default Post Code';
        }
        field(7; "Not Applic. VAT Code"; Code[20])
        {
            Caption = 'Not Applicable VAT Code';
            TableRelation = "VAT Reporting Code".Code;
        }
        field(20; "Check Company Information"; Boolean)
        {
            DataClassification = CustomerContent;
            Caption = 'Check Company Information';
        }
        field(21; "Check Customer"; Boolean)
        {
            DataClassification = CustomerContent;
            Caption = 'Check Customer';
        }
        field(22; "Check Vendor"; Boolean)
        {
            DataClassification = CustomerContent;
            Caption = 'Check Vendor';
        }
        field(23; "Check Bank Account"; Boolean)
        {
            DataClassification = CustomerContent;
            Caption = 'Check Bank Account';
        }
        field(24; "Check Post Code"; Boolean)
        {
            DataClassification = CustomerContent;
            Caption = 'Check Post Code';
        }
        field(25; "Check Address"; Boolean)
        {
            DataClassification = CustomerContent;
            Caption = 'Check Address';
        }
    }

    keys
    {
        key(PK; "Primary Key")
        {
            Clustered = true;
        }
    }
}
