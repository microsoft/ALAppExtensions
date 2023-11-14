// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------
namespace Microsoft.Inventory.Item;
#if not CLEAN22

using Microsoft.Foundation.Company;
#endif

tableextension 31018 "Item Charge CZL" extends "Item Charge"
{
    fields
    {
        field(31052; "Incl. in Intrastat Amount CZL"; Boolean)
        {
            Caption = 'Incl. in Intrastat Amount';
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
                if "Incl. in Intrastat Amount CZL" then begin
#pragma warning disable AL0432
                    StatutoryReportingSetupCZL.CheckItemChargesInIntrastatCZL();
#pragma warning restore AL0432
                    TestField("Incl. in Intrastat S.Value CZL", false);
                end;
            end;
#endif
        }
        field(31053; "Incl. in Intrastat S.Value CZL"; Boolean)
        {
            Caption = 'Incl. in Intrastat Stat. Value';
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
                if "Incl. in Intrastat S.Value CZL" then begin
#pragma warning disable AL0432
                    StatutoryReportingSetupCZL.CheckItemChargesInIntrastatCZL();
#pragma warning restore AL0432
                    TestField("Incl. in Intrastat Amount CZL", false);
                end;
            end;
#endif
        }
    }
#if not CLEAN22
    var
        StatutoryReportingSetupCZL: Record "Statutory Reporting Setup CZL";
#endif
}
