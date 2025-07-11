// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------
namespace Microsoft.Finance.GST.Payments;

page 18249 "Update GST TDS Cert. Details"
{
    Caption = 'Update GST TDS Cert. Details';
    DeleteAllowed = false;
    InsertAllowed = false;
    PageType = List;
    Permissions = TableData "GST TDS/TCS Entry" = rm;
    SourceTable = "GST TDS/TCS Entry";
    SourceTableView = sorting("Entry No.") order(ascending);

    layout
    {
        area(content)
        {
            repeater(GroupName)
            {
                field("Entry No."; Rec."Entry No.")
                {
                    Editable = false;
                    ApplicationArea = Basic, Suite;
                    ToolTip = 'Specifies the number of the entry.';
                }
                field("Source No."; Rec."Source No.")
                {
                    Editable = false;
                    ApplicationArea = Basic, Suite;
                    ToolTip = 'Specifies the customer number of the GST TDS/TCS Entry.';
                }
                field("Posting Date"; Rec."Posting Date")
                {
                    Editable = false;
                    ApplicationArea = Basic, Suite;
                    ToolTip = 'Specifies the entry posting date.';
                }
                field("Document Type"; Rec."Document Type")
                {
                    Editable = false;
                    ApplicationArea = Basic, Suite;
                    ToolTip = 'Specifies the document type that entry belongs to.';
                }
                field("Document No."; Rec."Document No.")
                {
                    Editable = false;
                    ApplicationArea = Basic, Suite;
                    ToolTip = 'Specifies the entry document number.';
                }
                field("Certificate No."; Rec."Certificate No.")
                {
                    Editable = false;
                    ApplicationArea = Basic, Suite;
                    ToolTip = 'Specifies the received certificate number for the entry.';
                }
                field("Certificated Received Date"; Rec."Certificated Received Date")
                {
                    ApplicationArea = Basic, Suite;
                    ToolTip = 'Specifies the date on which TDS certificate has been received.';
                }
                field("Certificate Received"; Rec."Certificate Received")
                {
                    ApplicationArea = Basic, Suite;
                    ToolTip = 'Specifies if the GST TDS/TCS certificate has been received for the entry.';
                }
            }
        }
    }

    actions
    {
        area(processing)
        {
            group("F&unctions")
            {
                Caption = 'F&unctions';
                Image = "Action";

                action("Update TDS Cert. Details")
                {
                    Caption = 'Update TDS Cert. Details';
                    Image = RefreshVATExemption;
                    ApplicationArea = Basic, Suite;
                    ToolTip = 'Specifies the function to update customer number, certificate number, date of receipts of certificate and rectification details on GST TDS/TCS Entry table.';

                    trigger OnAction()
                    begin
                        OnActionUpdateTDSCertDetails();
                    end;
                }
            }
        }
    }

    trigger OnClosePage()
    var
        GSTTdsTcsEntry: Record "GST TDS/TCS Entry";
    begin
        GSTTdsTcsEntry.Reset();
        GSTTdsTcsEntry.SetRange("Source No.", CustNo);
        GSTTdsTcsEntry.SetFilter("Certificate No.", '%1', '');
        GSTTdsTcsEntry.SetRange(Type, Rec.Type::TDS);
        GSTTdsTcsEntry.SetRange("Certificate Received", true);
        GSTTdsTcsEntry.ModifyAll("Certificate Received", false);

        GSTTdsTcsEntry.Reset();
        GSTTdsTcsEntry.SetRange("Source No.", CustNo);
        GSTTdsTcsEntry.SetFilter("Certificate No.", '<>%1', '');
        GSTTdsTcsEntry.SetRange(Type, Rec.Type::TDS);
        GSTTdsTcsEntry.SetRange("Certificate Received", false);
        GSTTdsTcsEntry.ModifyAll("Certificate Received", true);
    end;

    trigger OnOpenPage()
    begin
        Rec.FilterGroup(2);
        Rec.SetRange("Source No.", CustNo);
        Rec.SetRange(Type, Rec.Type::TDS);
        if RectDetails then begin
            Rec.SetRange("Certificate No.", CertNo);
            Rec.SetRange(Paid, false);
        end else
            Rec.SetRange("Certificate No.", '');

        Rec.SetRange(Reversed, false);
        Rec.FilterGroup(0);
    end;

    var
        CertNo: Code[20];
        CertDate: Date;
        CustNo: Code[20];
        RectDetails: Boolean;
        ShowMessage: Boolean;
        CertificateDetailSameErr: Label 'Certificate Details for Certificate No. %1 should be same as entered earlier.', Comment = '%1 = Certificate No.';
        NoSelectErr: Label 'All components of Document No. must be selected for Certificate updation. You must select %1 as %2 for Document No.: %3.', Comment = '%1 = Field Name, %2 = Value, %3 = Document No.';
        ShowMsg: Label 'Certificate No. %1 updated successfully.', Comment = '%1 = Certificate No.';

    procedure SetCertificateDetail(CertificateNo: Code[20]; CertificateDate: Date; CustomerNo: Code[20]; Rectify: Boolean)
    begin
        CertNo := CertificateNo;
        CertDate := CertificateDate;
        CustNo := CustomerNo;
        RectDetails := Rectify;
    end;

    local procedure OnActionUpdateTDSCertDetails()
    var
        GSTTdsTcsEntry: Record "GST TDS/TCS Entry";
    begin
        if Rec.FindSet() then
            repeat
                GSTTdsTcsEntry.SetRange("Source No.", CustNo);
                GSTTdsTcsEntry.SetRange("Certificate No.", CertNo);
                if GSTTdsTcsEntry.FindSet() then
                    repeat
                        if GSTTdsTcsEntry."Certificated Received Date" <> CertDate then
                            Error(CertificateDetailSameErr, CertNo);
                    until GSTTdsTcsEntry.Next() = 0;

                GSTTdsTcsEntry.Reset();
                GSTTdsTcsEntry.SetRange("Document No.", Rec."Document No.");
                if Rec."Certificate Received" then
                    GSTTdsTcsEntry.SetRange("Certificate Received", false)
                else
                    GSTTdsTcsEntry.SetRange("Certificate Received", true);

                GSTTdsTcsEntry.SetRange(Reversed, false);
                if GSTTdsTcsEntry.FindFirst() then
                    Error(NoSelectErr, GSTTdsTcsEntry.FieldCaption("Certificate Received"), Rec."Certificate Received", GSTTdsTcsEntry."Document No.");

                GSTTdsTcsEntry.Reset();
                GSTTdsTcsEntry.Get(Rec."Entry No.");
                if Rec."Certificate Received" then begin
                    GSTTdsTcsEntry."Certificate No." := CertNo;
                    GSTTdsTcsEntry."Certificated Received Date" := CertDate;
                    GSTTdsTcsEntry."Certificate Received" := true;
                    ShowMessage := true;
                end else begin
                    GSTTdsTcsEntry."Certificate No." := '';
                    GSTTdsTcsEntry."Certificated Received Date" := 0D;
                    GSTTdsTcsEntry."Certificate Received" := false;
                    ShowMessage := true;
                end;

                GSTTdsTcsEntry.Modify();
            until Rec.Next() = 0;

        if ShowMessage then
            Message(ShowMsg, CertNo);

        CurrPage.Close();
    end;
}
