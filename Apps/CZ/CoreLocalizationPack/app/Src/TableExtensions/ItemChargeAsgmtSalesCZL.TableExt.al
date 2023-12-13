// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------
namespace Microsoft.Sales.Document;

#if not CLEAN22
using Microsoft.Foundation.Company;
#endif

tableextension 31020 "Item Charge Asgmt. (Sales) CZL" extends "Item Charge Assignment (Sales)"
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
#pragma warning disable AL0432
                StatutoryReportingSetupCZL.CheckItemChargesInIntrastatCZL();
#pragma warning restore AL0432
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
#pragma warning disable AL0432
                StatutoryReportingSetupCZL.CheckItemChargesInIntrastatCZL();
#pragma warning restore AL0432
            end;
#endif            
        }
    }
#if not CLEAN22
    var
        StatutoryReportingSetupCZL: Record "Statutory Reporting Setup CZL";
#endif
}
