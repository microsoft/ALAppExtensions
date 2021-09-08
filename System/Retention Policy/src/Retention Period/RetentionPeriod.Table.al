// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------

/// <summary>
/// The Retention Periods table is used to define retention periods.
/// You define a retention period by selecting one of the default values in the Retention Period field, or by selecting the Custom value and providing a date formula.
/// The date formula must result in a date that is at least two days before the current date. 
/// </summary>
table 3900 "Retention Period"
{
    LookupPageId = "Retention Periods";
    Extensible = False;
    DataCaptionFields = Code, Description;

    fields
    {
        field(1; Code; Code[20])
        {
            NotBlank = true;
        }
        field(2; Description; Text[100])
        {
        }
        field(3; "Retention Period"; Enum "Retention Period Enum")
        {
            trigger OnValidate()
            var
                RetentionPeriod: Interface "Retention Period";
            begin
                if Rec."Retention Period" = Rec."Retention Period"::Custom then
                    Clear(Rec."Ret. Period Calculation"); // clear before getting again
                RetentionPeriod := Rec."Retention Period";
                Evaluate(Rec."Ret. Period Calculation", RetentionPeriod.RetentionPeriodDateFormula(Rec));
                if Rec."Retention Period" = Rec."Retention Period"::"Never Delete" then
                    Clear(Rec."Ret. Period Calculation"); // clear before validating, don't store as it changes with time

                Validate(Rec."Ret. Period Calculation");
            end;
        }
        field(4; "Ret. Period Calculation"; DateFormula)
        {
            trigger OnValidate()
            var
                RetentionPeriodImpl: Codeunit "Retention Period Impl.";
            begin
                // do not use interface here to avoid overriding of validation
                RetentionPeriodImpl.ValidateRetentionPeriodDateFormula("Ret. Period Calculation");
            end;
        }
    }

    keys
    {
        key(PrimaryKey; Code)
        {
            Clustered = true;
        }
    }
}