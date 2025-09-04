// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------
namespace Microsoft.Finance.VAT.Reporting;

table 10050 "Transmission IRIS"
{
    DataClassification = CustomerContent;
    DataCaptionFields = "Period No.";

    fields
    {
        field(1; "Document ID"; Integer)
        {
            Caption = 'Document ID';
            ToolTip = 'Specifies the document ID of the transmission.';
            Editable = false;
        }
        field(2; "Period No."; Text[4])
        {
            Caption = 'Period No.';
            ToolTip = 'Specifies the tax year for which the transmission is being sent.';
            Editable = false;
        }
        field(10; Status; Enum "Transmission Status IRIS")
        {
            Caption = 'Status';
            ToolTip = 'Specifies the status of the transmission returned by the IRS after the transmission is sent.';
            Editable = false;
        }
        field(30; "Receipt ID"; Text[100])
        {
            Caption = 'Receipt ID';
            ToolTip = 'Specifies the receipt identifier returned by the IRIS system.';
        }
        field(31; "Original Receipt ID"; Text[100])
        {
            Caption = 'Original Receipt ID';
            ToolTip = 'Specifies the receipt identifier returned by the IRIS system for the original transmission.';
            Editable = false;
        }
        field(40; "Last Type"; Enum "Transmission Type IRIS")
        {
            Caption = 'Last Type';
            ToolTip = 'Specifies the type of the last transmission received by the IRS and for which the Receipt ID was returned.';
            Editable = false;
        }
    }

    keys
    {
        key(PK; "Document ID")
        {
            Clustered = true;
        }
    }

    var
        CannotDeleteTransmissionErr: Label 'A transmission with status other than None cannot be deleted.';

    trigger OnDelete()
    var
        IRS1099FormDocHeader: Record "IRS 1099 Form Doc. Header";
        ErrorInfo: Record "Error Information IRIS";
    begin
        if Rec.Status <> Enum::"Transmission Status IRIS"::None then
            Error(CannotDeleteTransmissionErr);

        IRS1099FormDocHeader.SetRange("IRIS Transmission Document ID", Rec."Document ID");
        IRS1099FormDocHeader.ModifyAll("IRIS Submission Status", Enum::"Transmission Status IRIS"::None);
        IRS1099FormDocHeader.ModifyAll("IRIS Needs Correction", false);
        IRS1099FormDocHeader.ModifyAll("Allow Correction", false);
        IRS1099FormDocHeader.ModifyAll("IRIS Transmission Document ID", 0);     // remove link to transmission - must be in the end

        ErrorInfo.SetRange("Transmission Document ID", Rec."Document ID");
        ErrorInfo.DeleteAll(true);
    end;

    internal procedure InitTransmissionRecord()
    var
        DocID: Integer;
    begin
        if Rec.FindLast() then
            DocID := Rec."Document ID";
        DocID += 1;
        Rec."Document ID" := DocID;
    end;
}