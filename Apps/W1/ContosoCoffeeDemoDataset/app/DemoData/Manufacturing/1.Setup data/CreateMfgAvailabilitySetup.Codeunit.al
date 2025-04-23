// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------

namespace Microsoft.DemoData.Manufacturing;

using Microsoft.Foundation.Company;
using Microsoft.Foundation.Enums;

codeunit 4760 "Create Mfg Availability Setup"
{
    InherentEntitlements = X;
    InherentPermissions = X;
    Permissions = tabledata "Company Information" = rm;

    trigger OnRun()
    begin
        ModifyData('<90D>', Enum::"Analysis Period Type"::Week);
    end;

    var
        CompanyInformation: Record "Company Information";

    local procedure ModifyData(AvailPeriodCalc: Code[10]; AvailTimeBucket: Enum "Analysis Period Type")
    begin
        CompanyInformation.Get();
        Evaluate(CompanyInformation."Check-Avail. Period Calc.", AvailPeriodCalc);
        CompanyInformation.Validate("Check-Avail. Period Calc.");
        CompanyInformation.Validate("Check-Avail. Time Bucket", AvailTimeBucket);
        CompanyInformation.Modify();
    end;
}

