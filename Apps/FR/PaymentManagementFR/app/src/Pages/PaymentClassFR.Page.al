// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------
namespace Microsoft.Bank.Payment;

using System.IO;

page 10834 "Payment Class FR"
{
    ApplicationArea = Basic, Suite;
    Caption = 'Payment Slip Setup';
    DelayedInsert = true;
    PageType = List;
    SourceTable = "Payment Class FR";
    UsageCategory = Administration;

    layout
    {
        area(content)
        {
            repeater(Control1)
            {
                ShowCaption = false;
                field(Enable; Rec.Enable)
                {
                    ApplicationArea = Basic, Suite;
                    ToolTip = 'Specifies the user is allowed to use this payment class.';
                }
                field("Code"; Rec.Code)
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies a payment class code.';
                }
                field(Name; Rec.Name)
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies text to describe the payment class.';
                }
                field("Header No. Series"; Rec."Header No. Series")
                {
                    ApplicationArea = Basic, Suite;
                    ToolTip = 'Specifies the number series code used to assign numbers to the header of a payment slip.';
                }
                field("Line No. Series"; Rec."Line No. Series")
                {
                    ApplicationArea = Basic, Suite;
                    ToolTip = 'Specifies the number series code used to assign numbers to the lines of a payment slip.';
                }
                field(Suggestions; Rec.Suggestions)
                {
                    ApplicationArea = Basic, Suite;
                    ToolTip = 'Specifies what kind of payments proposals are allowed to be created automatically on a payment slip.';
                }
                field("Unrealized VAT Reversal"; Rec."Unrealized VAT Reversal")
                {
                    ApplicationArea = Basic, Suite;
                    ToolTip = 'Specifies how unrealized VAT should be handled.';
                }
                field("SEPA Transfer Type"; Rec."SEPA Transfer Type")
                {
                    ApplicationArea = Basic, Suite;
                    ToolTip = 'Specifies the type, if the payment class is used to export payments according to the SEPA standard.';
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
                action(DuplicateParameter)
                {
                    ApplicationArea = Basic, Suite;
                    Caption = 'Duplicate Parameter';
                    Image = CopySerialNo;
                    ToolTip = 'Create a new payment class based on an existing payment class.';

                    trigger OnAction()
                    var
                        PaymentClass: Record "Payment Class FR";
                        DuplicateParameter: Report "Duplicate parameter FR";
                    begin
                        if Rec.Code <> '' then begin
                            PaymentClass.SetRange(Code, Rec.Code);
                            DuplicateParameter.SetTableView(PaymentClass);
                            DuplicateParameter.InitParameter(Rec.Code);
                            DuplicateParameter.RunModal();
                        end;
                    end;
                }
                action("Import Parameters")
                {
                    ApplicationArea = Basic, Suite;
                    Caption = 'Import Parameters';
                    Image = Import;
                    ToolTip = 'Import payment management parameters. You can use the following formats: ETEBAC (XMLport 10860) to create a bill of exchange remittance. Withdraw (XMLport 10861) to create a customer payment withdrawal (direct debit). Transfer (XMLport 10862) to create a vendor payment transfer (credit transfer). You choose these formats when you set up the payment status for your payment class.';

                    trigger OnAction()
                    var
                        Instream: InStream;
                        ImportFile: File;
                        ToFile: Text;
                    begin
                        Upload('', '', '', '', ToFile);
                        ImportFile.Open(ToFile);
                        ImportFile.CreateInStream(Instream);
                        XMLPORT.Import(XMLPORT::"Import/Export Parameters FR", Instream);
                        ImportFile.Close();
                    end;
                }
                action("Export Parameters")
                {
                    ApplicationArea = Basic, Suite;
                    Caption = 'Export Parameters';
                    Image = Export;
                    ToolTip = 'Import or export parameters for your payment management setup.';

                    trigger OnAction()
                    var
                        RBAutoMgt: Codeunit "File Management";
                        ServerFile: File;
                        Fileoutstream: OutStream;
                        ToFile: Text;
                        ServerFileName: Text;
                    begin
                        ServerFileName := RBAutoMgt.ServerTempFileName(Text002Lbl);

                        ServerFile.Create(ServerFileName);
                        ServerFile.CreateOutStream(Fileoutstream);
                        XMLPORT.Export(XMLPORT::"Import/Export Parameters FR", Fileoutstream);
                        ServerFile.Close();

                        ToFile := Text003Lbl;
                        Download(ServerFileName, '', '', '', ToFile);
                        Erase(ServerFileName);
                    end;
                }
            }
            action(Status)
            {
                ApplicationArea = Basic, Suite;
                Caption = 'St&atus';
                Image = "Report";
                RunObject = Page "Payment Status FR";
                RunPageLink = "Payment Class" = field(Code);
                ToolTip = 'Manage a series of states that indicate the progress of a payment document.';
            }
            action(Steps)
            {
                ApplicationArea = Basic, Suite;
                Caption = 'Ste&ps';
                Image = MoveToNextPeriod;
                RunObject = Page "Payment Steps FR";
                RunPageLink = "Payment Class" = field(Code);
                ToolTip = 'Manage the steps that must be performed for this status in order to move to the next.';
            }
        }
        area(Promoted)
        {
            group(Category_Process)
            {
                Caption = 'Process';

                actionref(Status_Promoted; Status)
                {
                }
                actionref(Steps_Promoted; Steps)
                {
                }
            }
        }
    }

    var
        Text002Lbl: Label '''txt''';
        Text003Lbl: Label 'Import_Export Parameters.txt';
}

