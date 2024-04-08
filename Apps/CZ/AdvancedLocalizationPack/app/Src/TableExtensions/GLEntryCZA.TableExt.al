// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------
namespace Microsoft.Finance.GeneralLedger.Ledger;

#pragma warning disable AA0232
tableextension 31265 "G/L Entry CZA" extends "G/L Entry"
{
    fields
    {
        field(11782; "Closed at Date CZA"; Date)
        {
            Caption = 'Closed at Date';
        }
        field(11783; "Applies-to ID CZA"; Code[50])
        {
            Caption = 'Applies-to ID';

            trigger OnValidate()
            var
                ApplyGLEntriesCZA: Page "Apply G/L Entries CZA";
            begin
                ApplyGLEntriesCZA.CheckAppliesToID(Rec);
            end;
        }
        field(11784; "Date Filter CZA"; Date)
        {
            Caption = 'Date Filter';
            FieldClass = FlowFilter;
        }
        field(11785; "Amount to Apply CZA"; Decimal)
        {
            AutoFormatType = 1;
            Caption = 'Amount to Apply';

            trigger OnValidate()
            var
                SameSignErr: Label '%1 must have the same sign as %2.', Comment = '%1 = FieldCaption Amount to Apply, %2 = FieldCaption Amount';
                DifferenceErr: Label '%1 must not be larger than difference between %2 and %3.', Comment = '%1 = FieldCaption Amount to Apply, %2 = FieldCaption Amount, %3 = FieldCaption Applied Amount';
            begin
                CalcFields("Applied Amount CZA");
                if "Amount to Apply CZA" * Amount < 0 then
                    Error(SameSignErr, FieldCaption("Amount to Apply CZA"), FieldCaption(Amount));
                if Abs("Amount to Apply CZA") > Abs(Amount - "Applied Amount CZA") then
                    Error(DifferenceErr, FieldCaption("Amount to Apply CZA"), FieldCaption(Amount), FieldCaption("Applied Amount CZA"));
            end;
        }
        field(11786; "Applying Entry CZA"; Boolean)
        {
            Caption = 'Applying Entry';
        }
        field(11787; "Closed CZA"; Boolean)
        {
            Caption = 'Closed';
        }
        field(11788; "Applied Amount CZA"; Decimal)
        {

            CalcFormula = - Sum("Detailed G/L Entry CZA".Amount where("G/L Entry No." = field("Entry No."),
                                                                  "Posting Date" = field("Date Filter CZA")));
            Caption = 'Applied Amount';
            Editable = false;
            FieldClass = FlowField;
        }
    }

    keys
    {
        key(AppliestoIDKeyCZA; "Applies-to ID CZA", "Applying Entry CZA")
        {
            SumIndexFields = "Amount to Apply CZA";
        }
    }

    procedure RemainingAmountCZA() Result: Decimal
    var
        IsHandled: Boolean;
    begin
        IsHandled := false;
        Result := 0;
        OnBeforeRemainingAmountCZA(Rec, Result, IsHandled);
        if IsHandled then
            exit(Result);

        if not Rec."Closed CZA" then begin
            Rec.CalcFields("Applied Amount CZA");
            Result := (Rec.Amount - Rec."Applied Amount CZA");
        end;
        exit(Result);
    end;

    [IntegrationEvent(true, false)]
    local procedure OnBeforeRemainingAmountCZA(var GLEntry: Record "G/L Entry"; var Result: Decimal; var IsHandled: Boolean)
    begin
    end;
}
