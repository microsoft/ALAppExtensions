// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------

/// <summary>
/// List page that contains all of the retention periods that have been defined.
/// </summary>
page 3900 "Retention Periods"
{
    PageType = List;
    SourceTable = "Retention Period";
    Extensible = false;

    layout
    {
        area(Content)
        {
            repeater(General)
            {
                field(Code; Rec.Code)
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the identifier of the retention period.';
                    ShowMandatory = true;
                }
                field(Description; Rec.Description)
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies a short description of the retention period.';
                }
                field("Retention Period"; Rec."Retention Period")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies a default or custom value for a retention period.';

                    trigger OnValidate()
                    begin
                        Rec.Validate("Retention Period");
                        CalcExpirationDate();
                    end;
                }
                field("Ret. Period Calculation"; Rec."Ret. Period Calculation")
                {
                    ApplicationArea = All;
                    Tooltip = 'Specifies the date formula used to calculate the expiration date for the retention period.';
                    Editable = Rec."Retention Period" = Rec."Retention Period"::Custom;
                    ShowMandatory = Rec."Retention Period" = Rec."Retention Period"::Custom;

                    trigger OnValidate()
                    begin
                        Rec.Validate("Ret. Period Calculation");
                        CalcExpirationDate();
                    end;
                }
                field("Expiration Date"; ExpirationDate)
                {
                    ApplicationArea = All;
                    Caption = 'Expiration Date';
                    Tooltip = 'Specifies the expiration date. Records created on or before this date will be deleted.';
                    Editable = false;
                }
            }
        }
    }

    var
        ExpirationDate: Date;

    trigger OnAfterGetRecord()
    begin
        CalcExpirationDate();
    end;

    trigger OnNewRecord(BelowxRec: Boolean)
    begin
        ExpirationDate := 0D;
    end;

    local procedure CalcExpirationDate()
    var
        RetentionPeriodInterface: Interface "Retention Period";
    begin
        RetentionPeriodInterface := Rec."Retention Period";
        ExpirationDate := RetentionPeriodInterface.CalculateExpirationDate(Rec);
        if ExpirationDate >= Today() then
            Clear(ExpirationDate);
    end;
}