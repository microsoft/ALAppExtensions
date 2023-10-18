// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------
namespace Microsoft.Finance.VAT.Reporting;

using Microsoft.Foundation.NoSeries;
using Microsoft.Purchases.Setup;
using System.Security.AccessControl;

table 10018 "IRS 1096 Form Header"
{
    Caption = 'IRS 1096 Form Header';

    fields
    {
        field(1; "No."; Code[20])
        {
            Caption = 'No.';

            trigger OnValidate()
            begin
                if "No." <> xRec."No." then begin
                    PurchPayablesSetup.GetRecordOnce();
                    NoSeriesMgt.TestManual(PurchPayablesSetup."IRS 1096 Form No. Series");
                    "No. Series" := '';
                end;
            end;
        }
        field(2; "Starting Date"; Date)
        {
            Caption = 'Starting Date';
        }
        field(3; "Ending Date"; Date)
        {
            Caption = 'Ending Date';
        }
        field(4; "IRS Code"; Code[20])
        {
            Caption = 'IRS Code';
        }
        field(5; "No. Series"; Code[20])
        {
            Caption = 'No. Series';
            Editable = false;
            TableRelation = "No. Series";
        }
        field(6; Status; Enum "IRS 1096 Form Status")
        {
            Caption = 'Status';
            Editable = false;
        }
        field(10; "Calc. Total Number Of Forms"; Integer)
        {
            Caption = 'Calculated Total Number Of Forms';
            Editable = false;
        }
        field(11; "Total Number Of Forms"; Integer)
        {
            Caption = 'Total Number Of Forms';
        }
        field(12; "Calc. Amount"; Decimal)
        {
            Caption = 'Calculated Amount';
            Editable = false;
        }
        field(13; "Total Amount To Report"; Decimal)
        {
            Caption = 'Total Amount To Report';
        }
        field(14; "Calc. Adjustment Amount"; Decimal)
        {
            Caption = 'Calculacted Adjustment Amount';
            Editable = false;
        }
        field(30; Printed; Boolean)
        {
            Caption = 'Printed';
            Editable = false;
        }
        field(31; "Printed By"; Code[50])
        {
            Caption = 'Printed By';
            Editable = false;
            DataClassification = EndUserIdentifiableInformation;
            TableRelation = User."User Name";
            ValidateTableRelation = false;
        }
        field(32; "Printed Date-Time"; DateTime)
        {
            Caption = 'Printed Date-Time';
            Editable = false;
        }
        field(40; "Changed By"; Code[50])
        {
            Caption = 'Changed By';
            Editable = false;
            DataClassification = EndUserIdentifiableInformation;
            TableRelation = User."User Name";
            ValidateTableRelation = false;
        }
        field(41; "Changed Date-Time"; DateTime)
        {
            Caption = 'Changed Date-Time';
            Editable = false;
        }
    }

    keys
    {
        key(PK; "No.")
        {
            Clustered = true;
        }
        key(Key2; "Starting Date", "Ending Date", Status)
        {

        }
    }

    var
        PurchPayablesSetup: Record "Purchases & Payables Setup";
        NoSeriesMgt: Codeunit NoSeriesManagement;

    trigger OnInsert()
    var
        IsHandled: Boolean;
    begin
        IsHandled := false;
        OnBeforeInitNo(Rec, xRec, IsHandled);
        if IsHandled then
            exit;

        if "No." = '' then begin
            GetPurchSetupWithIRS1096NoSeries();
            NoSeriesMgt.InitSeries(PurchPayablesSetup."IRS 1096 Form No. Series", xRec."No. Series", 0D, "No.", "No. Series");
        end;
    end;

    trigger OnModify()
    begin
        "Changed By" := CopyStr(UserId(), 1, MaxStrLen("Changed By"));
        "Changed Date-Time" := CurrentDateTime();
    end;

    trigger OnDelete()
    var
        IRS1099FormLine: Record "IRS 1096 Form Line";
    begin
        TestField(Status, Status::Open);
        IRS1099FormLine.SetRange("Form No.", "No.");
        IRS1099FormLine.DeleteAll(true);
    end;

    procedure AssistEdit(xIRS1096FormHeader: Record "IRS 1096 Form Header") Result: Boolean
    var
        IRS1096FormHeader: Record "IRS 1096 Form Header";
        IsHandled: Boolean;
    begin
        IsHandled := false;
        OnBeforeAssistEdit(Rec, xIRS1096FormHeader, Result, IsHandled);
        if IsHandled then
            exit(Result);

        IRS1096FormHeader := Rec;
        GetPurchSetupWithIRS1096NoSeries();
        if NoSeriesMgt.SelectSeries(PurchPayablesSetup."IRS 1096 Form No. Series", xIRS1096FormHeader."No. Series", IRS1096FormHeader."No. Series") then begin
            NoSeriesMgt.SetSeries(IRS1096FormHeader."No.");
            Rec := IRS1096FormHeader;
            exit(true);
        end;
    end;

    local procedure GetPurchSetupWithIRS1096NoSeries()
    begin
        PurchPayablesSetup.GetRecordOnce();
        PurchPayablesSetup.TestField("IRS 1096 Form No. Series");
    end;

    [IntegrationEvent(false, false)]
    local procedure OnBeforeInitNo(var IRS1096FormHeader: Record "IRS 1096 Form Header"; var xIRS1096FormHeader: Record "IRS 1096 Form Header"; var IsHandled: Boolean)
    begin
    end;

    [IntegrationEvent(false, false)]
    local procedure OnBeforeAssistEdit(var IRS1096FormHeader: Record "IRS 1096 Form Header"; var xIRS1096FormHeader: Record "IRS 1096 Form Header"; var Result: Boolean; var IsHandled: Boolean)
    begin
    end;
}
