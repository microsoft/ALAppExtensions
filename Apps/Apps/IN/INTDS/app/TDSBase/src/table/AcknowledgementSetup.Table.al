// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------
namespace Microsoft.Finance.TDS.TDSBase;

using Microsoft.Finance.TaxBase;
using Microsoft.Inventory.Location;

table 18685 "Acknowledgement Setup"
{
    Caption = 'Acknowledgement Setup';
    DrillDownPageId = "Acknowledgement Setup";
    LookupPageId = "Acknowledgement Setup";
    Access = Public;
    Extensible = true;

    fields
    {
        field(1; "Financial Year"; Code[10])
        {
            DataClassification = CustomerContent;

            trigger OnLookup()
            var
                TaxAccountingPeriod: Record "Tax Accounting Period";
            begin
                if Page.RunModal(Page::"Tax Accounting Periods", TaxAccountingPeriod) = Action::LookupOK then//AS
                    "Financial Year" := TaxAccountingPeriod."Financial Year";
            end;
        }
        field(2; Quarter; Code[10])
        {
            DataClassification = CustomerContent;
        }
        field(3; "Acknowledgment No."; Code[20])
        {
            DataClassification = CustomerContent;
        }
        field(4; "Location"; Code[20])
        {
            TableRelation = Location;
            DataClassification = CustomerContent;
        }
    }

    keys
    {
        key(PK; "Financial Year")
        {
            Clustered = true;
        }
    }
}
