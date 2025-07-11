// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------
namespace Microsoft.Finance.GST.ReturnSettlement;

page 18324 "Pay GST Calculation Details"
{
    Caption = 'Pay GST Calculation Details';
    DeleteAllowed = false;
    Editable = false;
    InsertAllowed = false;
    ModifyAllowed = false;
    PageType = List;
    SourceTable = "GST Payment Buffer Details";
    SourceTableView = sorting("GST Registration No.", "Document No.", "GST Component Code", "Line No.") order(ascending);

    layout
    {
        area(content)
        {
            repeater(Group)
            {
                field("GST Component Code"; Rec."GST Component Code")
                {
                    HideValue = HideFieldData;
                    Style = Strong;
                    StyleExpr = true;
                    ApplicationArea = Basic, Suite;
                    ToolTip = 'Specifies the GST component code for which the payment is being done.';
                }
                field("Net Payment Liability"; Rec."Net Payment Liability")
                {
                    HideValue = HideFieldData;
                    Style = Strong;
                    StyleExpr = true;
                    ApplicationArea = Basic, Suite;
                    ToolTip = 'Specifies the Net Payment Liability against the component code.';
                }
                field("Payment Liability"; Rec."Payment Liability")
                {
                    Visible = false;
                    ApplicationArea = Basic, Suite;
                    ToolTip = 'Specifies the value which defines the liability of payment for the component code.';
                }
                field("SetOff Component Code"; Rec."SetOff Component Code")
                {
                    ApplicationArea = Basic, Suite;
                    ToolTip = 'Specify the component code defined to setoff payment and liability.';
                }
                field("Total Credit Available"; Rec."Total Credit Available")
                {
                    ApplicationArea = Basic, Suite;
                    ToolTip = 'Specifies the Total Credit Available against the component code';
                }
                field("Credit Utilized"; Rec."Credit Utilized")
                {
                    ApplicationArea = Basic, Suite;
                    ToolTip = 'Specifies the value of Credit Utilized for the component code.';
                }
                field("Surplus Credit"; Rec."Surplus Credit")
                {
                    ApplicationArea = Basic, Suite;
                    ToolTip = 'Specify the difference of total credit available and credit utilized.';
                }
            }
        }
    }

    actions
    {
    }

    trigger OnAfterGetRecord()
    begin
        if Rec."GST Component Code" <> xRec."GST Component Code" then
            HideFieldData := false
        else
            HideFieldData := true;
    end;

    trigger OnClosePage()
    var
        GSTPaymentBufferDetails: Record "GST Payment Buffer Details";
    begin
        GSTPaymentBufferDetails.SetRange("Document No.", DocumentNo);
        GSTPaymentBufferDetails.DeleteAll();
    end;

    trigger OnOpenPage()
    begin
        Rec.FilterGroup(2);
        Rec.SetRange("GST Registration No.", GSTNNo);
        Rec.SetRange("Document No.", DocumentNo);
        Rec.FilterGroup(0);
    end;

    var
        GSTNNo: Code[20];
        DocumentNo: Code[20];
        HideFieldData: Boolean;

    procedure SetParameter(GSTN: Code[20]; PaymentDocumentNo: Code[20])
    begin
        GSTNNo := GSTN;
        DocumentNo := PaymentDocumentNo;
    end;
}
