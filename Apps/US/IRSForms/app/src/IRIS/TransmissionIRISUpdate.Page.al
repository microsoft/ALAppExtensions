// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------
namespace Microsoft.Finance.VAT.Reporting;

using System.Telemetry;

page 10066 "Transmission IRIS Update"
{
    PageType = Card;
    ApplicationArea = BasicUS;
    Extensible = false;
    InsertAllowed = false;
    DeleteAllowed = false;
    ShowFilter = false;
    Permissions = tabledata "Transmission IRIS" = rm;
    InherentEntitlements = X;
    InherentPermissions = X;
    SourceTable = "Transmission IRIS";
    SourceTableTemporary = true;

    layout
    {
        area(Content)
        {
            group(General)
            {
                ShowCaption = false;

                field("Receipt ID"; Rec."Receipt ID")
                {
                    Editable = true;
                }
            }
        }
    }

    trigger OnOpenPage()
    begin
        xTransmission := Rec;
    end;

    trigger OnQueryClosePage(CloseAction: Action): Boolean
    begin
        if CloseAction = ACTION::LookupOK then
            if RecordChanged() then
                UpdateRec();
    end;

    var
        xTransmission: Record "Transmission IRIS";
        UpdateTransmissionReceiptIDEventTxt: Label 'UpdateTransmissionReceiptID', Locked = true;

    internal procedure SetRec(Transmission: Record "Transmission IRIS")
    begin
        Rec := Transmission;
        Rec.Insert();
    end;

    local procedure RecordChanged() IsChanged: Boolean
    begin
        IsChanged := Rec."Receipt ID" <> xTransmission."Receipt ID";
    end;

    local procedure UpdateRec()
    var
        Transmission: Record "Transmission IRIS";
        FeatureTelemetry: Codeunit "Feature Telemetry";
        Helper: Codeunit "Helper IRIS";
        CustomDimensions: Dictionary of [Text, Text];
        PrevReceiptIDLength: Integer;
        NewReceiptIDLength: Integer;
    begin
        Transmission.LockTable();
        Transmission.Get(Rec."Document ID");
        PrevReceiptIDLength := StrLen(Transmission."Receipt ID");
        Transmission."Receipt ID" := Rec."Receipt ID";
        Transmission.Modify(true);

        NewReceiptIDLength := StrLen(Rec."Receipt ID");
        CustomDimensions.Add('PrevReceiptIDLength', Format(PrevReceiptIDLength));
        CustomDimensions.Add('NewReceiptIDLength', Format(NewReceiptIDLength));
        FeatureTelemetry.LogUsage('0000PVM', Helper.GetIRISFeatureName(), UpdateTransmissionReceiptIDEventTxt, CustomDimensions);
    end;
}