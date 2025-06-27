// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------
namespace Microsoft.Finance.VAT.Setup;

using Microsoft.Finance.VAT.Calculation;

#if not CLEAN25
#pragma warning disable AL0432
#endif
tableextension 10552 "VAT Amount Line" extends "VAT Amount Line"
#if not CLEAN25
#pragma warning restore  AL0432
#endif
{
    fields
    {
        field(10507; "Reverse Charge GB"; Decimal)
        {
            AutoFormatType = 1;
            Caption = 'Reverse Charge';
            DataClassification = CustomerContent;

            trigger OnValidate()
            begin
                TestField("VAT %");
                TestField("VAT Base");
                if "VAT Amount" / "VAT Base" < 0 then
                    Error(Text002Err, FieldCaption("VAT Amount"));
                "VAT Difference" := "VAT Amount" - "Calculated VAT Amount";
            end;
        }
    }

    var
        Text002Err: Label '%1 must not be negative.', Comment = '%1 = number';
}