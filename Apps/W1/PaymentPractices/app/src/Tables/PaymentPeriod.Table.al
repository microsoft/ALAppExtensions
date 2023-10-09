// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------
namespace Microsoft.Finance.Analysis;

using System.Environment;

table 685 "Payment Period"
{
    Caption = 'Payment Period';
    DataClassification = CustomerContent;

    fields
    {
        field(1; Code; Code[20])
        {

        }
        field(2; "Days From"; Integer)
        {
            MinValue = 0;

            trigger OnValidate()
            begin
                CheckDatePeriodConsistency();
                UpdateDescription();
            end;
        }
        field(3; "Days To"; Integer)
        {
            MinValue = 0;

            trigger OnValidate()
            begin
                CheckDatePeriodConsistency();
                UpdateDescription();
            end;
        }
        field(4; Description; Text[250])
        {

        }
    }

    keys
    {
        key(Key1; Code)
        {
            Clustered = true;
        }
        key(Key2; "Days From")
        {
        }
    }

    fieldgroups
    {
    }

    trigger OnInsert()
    begin
        if ("Days From" = 0) and ("Days To" = 0) then
            Error(DaysFromAndDaysToNotSpecifiedErr);
    end;

    var
        DaysFromLessThanDaysToErr: Label 'Days From must not be less than Days To.';
        DaysFromAndDaysToNotSpecifiedErr: Label 'Days From and Days To are not specified.';
        DescriptionTemplateTxt: Label '%1 to %2 days.', Comment = '%1,%2 - number of days';
        DescriptionTemplateEndlessTxt: Label 'More than %1 days.', Comment = '%1 - number of days';

    procedure SetupDefaults()
    var
        EnvironmentInformation: Codeunit "Environment Information";
        IsHandled: Boolean;
    begin
        OnBeforeSetupDefaults(IsHandled);
        if IsHandled then
            exit;

        if Rec.FindFirst() then
            exit;

        case EnvironmentInformation.GetApplicationFamily() of
            'GB':
                InsertDefaultPeriods_GB();
            'FR':
                InsertDefaultPeriods_FR();
            'AU', 'NZ':
                InsertDefaultPeriods_AUNZ();
            else
                InsertDefaultPeriods();
        end;
    end;

    local procedure CheckDatePeriodConsistency()
    begin
        if ("Days To" <> 0) and ("Days From" > "Days To") then
            Error(DaysFromLessThanDaysToErr);
    end;

    local procedure UpdateDescription()
    begin
        if Rec."Days To" > 0 then
            Rec.Description := CopyStr(StrSubstNo(DescriptionTemplateTxt, "Days From", "Days To"), 1, MaxStrLen(Rec.Description))
        else
            Rec.Description := CopyStr(StrSubstNo(DescriptionTemplateEndlessTxt, "Days From"), 1, MaxStrLen(Rec.Description));
    end;

    local procedure InsertPeriod(NewCode: Code[10]; DaysFrom: Integer; DaysTo: Integer)
    begin
        Rec.Init();
        Rec.Code := NewCode;
        Rec.Validate("Days From", DaysFrom);
        Rec.Validate("Days To", DaysTo);
        if Rec.Insert() then;
    end;

    local procedure InsertDefaultPeriods()
    begin
        InsertPeriod('P0_30', 0, 30);
        InsertPeriod('P31_60', 31, 60);
        InsertPeriod('P61_90', 61, 90);
        InsertPeriod('P91_120', 91, 120);
        InsertPeriod('P121+', 121, 0);
    end;

    local procedure InsertDefaultPeriods_FR()
    begin
        InsertPeriod('P0_30', 0, 30);
        InsertPeriod('P31_60', 31, 60);
        InsertPeriod('P61_90', 61, 90);
        InsertPeriod('P91+', 91, 0);
    end;

    local procedure InsertDefaultPeriods_GB()
    begin
        InsertPeriod('P0_30', 0, 30);
        InsertPeriod('P31_60', 31, 60);
        InsertPeriod('P61_90', 61, 120);
        InsertPeriod('P121+', 121, 0);
    end;

    local procedure InsertDefaultPeriods_AUNZ()
    begin
        InsertPeriod('P0_21', 0, 21);
        InsertPeriod('P22_30', 22, 30);
        InsertPeriod('P31_60', 31, 60);
        InsertPeriod('P61_90', 61, 120);
        InsertPeriod('P121+', 121, 0);
    end;

    [IntegrationEvent(false, false)]
    local procedure OnBeforeSetupDefaults(var IsHandled: Boolean)
    begin
    end;
}

