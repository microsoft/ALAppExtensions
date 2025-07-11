// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------
namespace Microsoft.Service.Reports;

using Microsoft.Finance.GeneralLedger.Setup;
using Microsoft.Foundation.NoSeries;
using System.IO;

table 5010 "Service Declaration Setup"
{

    fields
    {
        field(1; "Primary Key"; Integer)
        {
            Caption = 'Primary Key';
        }
        field(2; "Declaration No. Series"; Code[20])
        {
            Caption = 'Declaration No. Series';
            TableRelation = "No. Series";
        }
        field(3; "Report Item Charges"; Boolean)
        {
            Caption = 'Report Item Charges';
        }
        field(5; "Sell-To/Bill-To Customer No."; Enum "G/L Setup VAT Calculation")
        {
            Caption = 'Sell-To/Bill-To Customer No.';
        }
        field(6; "Buy-From/Pay-To Vendor No."; Enum "G/L Setup VAT Calculation")
        {
            Caption = 'Buy-From/Pay-To Vendor No.';
        }
        field(7; "Data Exch. Def. Code"; Code[20])
        {
            TableRelation = "Data Exch. Def";
        }
        field(8; "Enable VAT Registration No."; Boolean)
        {
            Caption = 'Enable VAT Registration No.';
        }
        field(9; "Enable Serv. Trans. Types"; Boolean)
        {
            Caption = 'Enable Service Transaction Types';
        }
        field(10; "Show Serv. Decl. Overview"; Boolean)
        {
            Caption = 'Show Serv. Devl. Overview';
        }
        field(11; "Cust. VAT Reg. No. Type"; Enum "Serv. Decl. VAT Reg. No. Type")
        {
            Caption = 'Cust. VAT Reg. No. Type';
        }
        field(12; "Vend. VAT Reg. No. Type"; Enum "Serv. Decl. VAT Reg. No. Type")
        {
            Caption = 'Vend. VAT Reg. No. Type';
        }
        field(13; "Def. Private Person VAT No."; Text[50])
        {
            Caption = 'Def. Private Person VAT No.';
        }
        field(14; "Def. Customer/Vendor VAT No."; Text[50])
        {
            Caption = 'Def. Customer/Vendor VAT No.';
        }
    }

    keys
    {
        key(Key1; "Primary Key")
        {
            Clustered = true;
        }
    }
}

