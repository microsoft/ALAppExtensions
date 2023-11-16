// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------
namespace Microsoft.Foundation.Shipping;
#if not CLEAN22

using Microsoft.Inventory.Intrastat;
using Microsoft.Foundation.Company;
#endif

tableextension 11796 "Shipment Method CZL" extends "Shipment Method"
{
    fields
    {
        field(31065; "Incl. Item Charges (Amt.) CZL"; Boolean)
        {
            Caption = 'Include Item Charges (Amount)';
            DataClassification = CustomerContent;
#if not CLEAN22
            ObsoleteState = Pending;
            ObsoleteTag = '22.0';
#else
            ObsoleteState = Removed;
            ObsoleteTag = '25.0';
#endif
            ObsoleteReason = 'Intrastat related functionalities are moved to Intrastat extensions.';
        }
        field(31066; "Intrastat Deliv. Grp. Code CZL"; Code[10])
        {
            Caption = 'Intrastat Delivery Group Code';
            DataClassification = CustomerContent;
#if not CLEAN22
            TableRelation = "Intrastat Delivery Group CZL".Code;
            ObsoleteState = Pending;
            ObsoleteTag = '22.0';
#else
            ObsoleteState = Removed;
            ObsoleteTag = '25.0';
#endif
            ObsoleteReason = 'Intrastat related functionalities are moved to Intrastat extensions.';
        }
        field(31067; "Incl. Item Charges (S.Val) CZL"; Boolean)
        {
            Caption = 'Incl. Item Charges (Stat.Val.)';
            DataClassification = CustomerContent;
#if not CLEAN22
            ObsoleteState = Pending;
            ObsoleteTag = '22.0';
#else
            ObsoleteState = Removed;
            ObsoleteTag = '25.0';
#endif
            ObsoleteReason = 'Intrastat related functionalities are moved to Intrastat extensions.';
#if not CLEAN22

            trigger OnValidate()
            begin
                if "Incl. Item Charges (S.Val) CZL" then begin
                    TestField("Adjustment % CZL", 0);
#pragma warning disable AL0432
                    CheckIncludeIntrastatCZL();
#pragma warning restore AL0432
                end;
            end;
#endif
        }
        field(31068; "Adjustment % CZL"; Decimal)
        {
            Caption = 'Adjustment %';
            MaxValue = 100;
            MinValue = -100;
            DataClassification = CustomerContent;
#if not CLEAN22
            ObsoleteState = Pending;
            ObsoleteTag = '22.0';
#else
            ObsoleteState = Removed;
            ObsoleteTag = '25.0';
#endif
            ObsoleteReason = 'Intrastat related functionalities are moved to Intrastat extensions.';
#if not CLEAN22

            trigger OnValidate()
            begin
                if "Adjustment % CZL" <> 0 then begin
                    TestField("Incl. Item Charges (S.Val) CZL", false);
                    TestField("Incl. Item Charges (Amt.) CZL", false);
                end;
            end;
#endif
        }
    }
#if not CLEAN22
    [Obsolete('Intrastat related functionalities are moved to Intrastat extensions.', '22.0')]
    procedure CheckIncludeIntrastatCZL()
    var
        StatutoryReportingSetupCZL: Record "Statutory Reporting Setup CZL";
    begin
        StatutoryReportingSetupCZL.Get();
        StatutoryReportingSetupCZL.TestField("No Item Charges in Intrastat", false);
    end;
#endif
}
