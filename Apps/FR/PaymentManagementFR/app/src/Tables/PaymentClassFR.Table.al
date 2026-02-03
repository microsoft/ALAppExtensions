// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------
namespace Microsoft.Bank.Payment;

using Microsoft.Finance.GeneralLedger.Setup;
using Microsoft.Foundation.NoSeries;
using System.Telemetry;

table 10833 "Payment Class FR"
{
    Caption = 'Payment Class';
    LookupPageID = "Payment Class List FR";
    DataClassification = CustomerContent;

    fields
    {
        field(1; "Code"; Text[30])
        {
            Caption = 'Code';
            NotBlank = true;

            trigger OnValidate()
            begin
                if Name = '' then
                    Name := Code;
            end;
        }
        field(2; Name; Text[50])
        {
            Caption = 'Name';
        }
        field(3; "Header No. Series"; Code[20])
        {
            Caption = 'Header No. Series';
            TableRelation = "No. Series";

            trigger OnValidate()
            var
                NoSeriesLine: Record "No. Series Line";
            begin
                if "Header No. Series" <> '' then begin
                    NoSeriesLine.SetRange("Series Code", "Header No. Series");
                    if NoSeriesLine.FindLast() then
                        if (StrLen(NoSeriesLine."Starting No.") > 10) or (StrLen(NoSeriesLine."Ending No.") > 10) then
                            Error(Text002Lbl);
                end;
            end;
        }
        field(4; Enable; Boolean)
        {
            Caption = 'Enable';
            InitValue = true;
        }
        field(5; "Line No. Series"; Code[20])
        {
            Caption = 'Line No. Series';
            TableRelation = "No. Series";

            trigger OnValidate()
            var
                NoSeriesLine: Record "No. Series Line";
            begin
                if "Line No. Series" <> '' then begin
                    NoSeriesLine.SetRange("Series Code", "Line No. Series");
                    if NoSeriesLine.FindLast() then
                        if (StrLen(NoSeriesLine."Starting No.") > 10) or (StrLen(NoSeriesLine."Ending No.") > 10) then
                            Error(Text002Lbl);
                end;
            end;
        }
        field(6; Suggestions; Option)
        {
            Caption = 'Suggestions';
            OptionCaption = 'None,Customer,Vendor';
            OptionMembers = "None",Customer,Vendor;
        }
        field(10; "Is Create Document"; Boolean)
        {
            CalcFormula = exist("Payment Step FR" where("Payment Class" = field(Code),
                                                      "Action Type" = const("Create New Document")));
            Caption = 'Is Create Document';
            Editable = false;
            FieldClass = FlowField;
        }
        field(11; "Unrealized VAT Reversal"; Option)
        {
            Caption = 'Unrealized VAT Reversal';
            OptionCaption = 'Application,Delayed';
            OptionMembers = Application,Delayed;

            trigger OnValidate()
            begin
                if "Unrealized VAT Reversal" = "Unrealized VAT Reversal"::Delayed then begin
                    GLSetup.Get();
                    GLSetup.TestField("Unrealized VAT", true);
                end else begin
                    PaymentStep.SetRange("Payment Class", Code);
                    PaymentStep.SetRange("Realize VAT", true);
                    if PaymentStep.FindFirst() then
                        Error(
                          Text003Lbl, TableCaption(), Code,
                          PaymentStep.TableCaption(), PaymentStep.FieldCaption("Realize VAT"));
                end;
            end;
        }
        field(12; "SEPA Transfer Type"; Option)
        {
            Caption = 'SEPA Transfer Type';
            OptionCaption = ' ,Credit Transfer,Direct Debit';
            OptionMembers = " ","Credit Transfer","Direct Debit";
        }
    }

    keys
    {
        key(Key1; "Code")
        {
            Clustered = true;
        }
        key(Key2; Suggestions)
        {
        }
    }

    fieldgroups
    {
        fieldgroup(DropDown; "Code", Name)
        {
        }
    }

    trigger OnDelete()
    var
        Status: Record "Payment Status FR";
        Step: Record "Payment Step FR";
        StepLedger: Record "Payment Step Ledger FR";
        PaymentHeader: Record "Payment Header FR";
        PaymentLine: Record "Payment Line FR";
    begin
        PaymentHeader.SetRange("Payment Class", Code);
        PaymentLine.SetRange("Payment Class", Code);
        if not PaymentHeader.IsEmpty() then
            Error(Text001Lbl);
        if not PaymentLine.IsEmpty() then
            Error(Text001Lbl);
        Status.SetRange("Payment Class", Code);
        Status.DeleteAll();
        Step.SetRange("Payment Class", Code);
        Step.DeleteAll();
        StepLedger.SetRange("Payment Class", Code);
        StepLedger.DeleteAll();
    end;

    trigger OnInsert()
    begin
        FeatureTelemetry.LogUptake('1000HP1', FRPaymentSlipTok, Enum::"Feature Uptake Status"::"Set up");
    end;

    var
        GLSetup: Record "General Ledger Setup";
        PaymentStep: Record "Payment Step FR";
        FeatureTelemetry: Codeunit "Feature Telemetry";
        FRPaymentSlipTok: Label 'FR Create Payment Slips', Locked = true;
        Text001Lbl: Label 'You cannot delete this Payment Class because it is already in use.';
        Text002Lbl: Label 'You cannot assign numbers longer than 10 characters.';
        Text003Lbl: Label '%1 %2 has at least one %3 for which %4 is checked.', Comment = '%1 = TableCaption, %2 = code, %3 = fieldCaption, %4 = Realize VAT';
}

