// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------
namespace Microsoft.WithholdingTax;

using Microsoft.Purchases.Vendor;

tableextension 6784 "Withholding Vendor Ext" extends Vendor
{
    fields
    {
        field(6784; "Wthldg. Tax Bus. Post. Group"; Code[20])
        {
            Caption = 'Withholding Tax Bus. Post. Group';
            TableRelation = "Wthldg. Tax Bus. Post. Group";
            DataClassification = CustomerContent;
        }
        field(6785; "WHT ABN"; Text[11])
        {
            Caption = 'ABN';
            DataClassification = CustomerContent;
            OptimizeForTextSearch = true;
            Numeric = true;

            trigger OnValidate()
            begin
                if "Wthldg. Tax Bus. Post. Group" <> '' then
                    Error(BlankFieldErr, FieldCaption("Wthldg. Tax Bus. Post. Group"));

                CheckABN("WHT ABN", 1);
                if "WHT ABN" = '' then
                    "WHT Registered" := false;
            end;
        }
        field(6786; "WHT Registered"; Boolean)
        {
            Caption = 'Registered';
            DataClassification = CustomerContent;

            trigger OnValidate()
            begin
                if "WHT Registered" then
                    TestField("WHT ABN");
            end;
        }
        field(6787; "WHT ABN Division Part No."; Text[3])
        {
            Caption = 'ABN Division Part No.';
            DataClassification = CustomerContent;
            OptimizeForTextSearch = true;
            Numeric = true;

            trigger OnValidate()
            begin
                if "Wthldg. Tax Bus. Post. Group" <> '' then
                    Error(BlankFieldErr, FieldCaption("Wthldg. Tax Bus. Post. Group"));
            end;
        }
        field(6788; "WHT Foreign Vend"; Boolean)
        {
            Caption = 'Foreign Vend';
            DataClassification = CustomerContent;
            trigger OnValidate()
            begin
                if "WHT Foreign Vend" then begin
                    "WHT ABN" := '';
                    "WHT ABN Division Part No." := '';
                end;
            end;
        }
        field(6789; "Withholding Tax Reg. ID"; Text[20])
        {
            Caption = 'Withholding Tax Registration ID';
            OptimizeForTextSearch = true;
        }
        field(6790; "Withholding Tax Liable"; Boolean)
        {
            DataClassification = CustomerContent;
            Caption = 'Withholding Tax Liable';
        }
    }

    local procedure CheckABN(ABN: Text[13]; Which: Option Customer,Vendor,Internal,Contact)
    var
        CheckDigit: Integer;
        AbnDigit: array[13] of Integer;
        WeightFactor: array[13] of Integer;
        AbnWeightSum: Integer;
        i: Integer;
        j: Integer;
        WeightLength: Integer;
        Reminder: Integer;
        LengthCheck: Boolean;
    begin
        if ABN = '' then
            exit;

        if StrPos(ABN, ' ') <> 0 then
            Error(OnlyNumberErr);

        LengthCheck := (StrLen(ABN) <> 13);

        if LengthCheck then
            LengthCheck := (StrLen(ABN) <> 11);

        if LengthCheck then
            Error(Enter11Or13DigitErr);

        if (StrLen(ABN) = 13) and (which = Which::Internal) then begin
            WeightLength := 15;
            for i := 1 to StrLen(ABN) do begin
                Evaluate(j, ABN[i]);
                AbnWeightSum += j * (WeightLength - 1);
            end;
            Reminder := AbnWeightSum mod 11;
            CheckDigit := 11 - Reminder;
            if CheckDigit <> 0 then
                Error(NumberInvalidErr);
            if CheckDigit <> ABN[StrLen(ABN)] then
                Error(NumberInvalidErr);
        end else begin
            j := -1;
            CheckDigit := 89;
            Clear(AbnDigit);
            Clear(WeightFactor);
            Clear(AbnWeightSum);

            for i := 1 to 11 do begin
                if not Evaluate(AbnDigit[i], CopyStr(ABN, i, 1)) then
                    Error(OnlyNumberErr);
                if i = 1 then begin
                    AbnDigit[i] := AbnDigit[i] - 1;
                    WeightFactor[i] := 10;
                end else begin
                    j += 2;
                    WeightFactor[i] := j;
                end;
                AbnWeightSum += (WeightFactor[i] * AbnDigit[i]);
            end;

            if AbnWeightSum mod CheckDigit <> 0 then
                Error(NumberInvalidErr);
        end;

        CheckForDuplicates(ABN, Which);
    end;

    local procedure CheckForDuplicates(ABN: Text[11]; Which: Option Customer,Vendor,Internal,Contact)
    var
        Vendor: Record Vendor;
    begin
        case Which of
            Which::Vendor:
                begin
                    Vendor.SetCurrentKey("WHT ABN");
                    Vendor.SetRange("WHT ABN", ABN);
                    if Vendor.FindFirst() then
                        if not Confirm(NumberAlreadyExistErr, false, Vendor.TableCaption(), Vendor."No.") then
                            Error('');
                end;
        end;
    end;

    var
        BlankFieldErr: Label 'The field %1 must be blank.', Comment = '%1 - Withholding Bus. Post. Group';
        OnlyNumberErr: Label 'You can enter only numbers in this field.';
        Enter11Or13DigitErr: Label 'You should enter an 11 or 13-digit number in this field.';
        NumberInvalidErr: Label 'The number is invalid.';
        NumberAlreadyExistErr: Label 'The number already exists for %1 %2. Do you wish to continue?', Comment = '%1 - TableCaption, %2-No.';
}